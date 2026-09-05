package main

import (
	"sort"
	"sync"
	"time"
)

type rcxSample struct {
	DelayMs int       `json:"d"`
	At      time.Time `json:"t"`
}

type rcxNodeGlobal struct {
	Origin   rcxOrigin `json:"o"`
	Country  string    `json:"c"`
	EverGood bool      `json:"g"`
	// One reach no domestic egress could make outranks the database for good.
	EverOpen bool `json:"eo"`
}

// Per (node x environment) on purpose: the dominant cause of a dial failure here
// is the network blocking it, not the node dying, so a global failure count would
// condemn the whole park after one whitelist episode.
type rcxNodeEnv struct {
	OpenWorld  rcxProof    `json:"w"`
	Domestic   rcxProof    `json:"m"`
	FailStreak int         `json:"f"`
	CoolUntil  time.Time   `json:"c"`
	LastGoodAt time.Time   `json:"l"`
	LastFailAt time.Time   `json:"lf"`
	DegradedAt time.Time   `json:"g"`
	Samples    []rcxSample `json:"s"`
	OpenAt     time.Time   `json:"oa"`
	DomesticAt time.Time   `json:"ma"`
	ProgressAt time.Time   `json:"p"`
	ProbeAt    time.Time   `json:"pa"`
	ProofStall bool        `json:"ps"`

	// Failures stamped while the terrain was not normal, rolled back once it is.
	provisionalFails int
}

type rcxLedgerPolicy struct {
	SampleDepth    int
	StaleAfter     time.Duration
	EpisodeTTL     time.Duration
	DeadRetry      time.Duration
	MaxDeadRetry   time.Duration
	CoolAfterFails int
	MaxFailStreak  int
	ProofTTL       time.Duration
	FailDecay      time.Duration
}

func rcxDefaultLedgerPolicy() rcxLedgerPolicy {
	return rcxLedgerPolicy{
		SampleDepth:    8,
		StaleAfter:     6 * time.Hour,
		EpisodeTTL:     10 * time.Second,
		DeadRetry:      15 * time.Minute,
		MaxDeadRetry:   2 * time.Hour,
		CoolAfterFails: 3,
		MaxFailStreak:  6,
		ProofTTL:       time.Duration(rcxProofTTLMinutes) * time.Minute,
		FailDecay:      time.Hour,
	}
}

var rcxLedgerProofTTL = rcxDefaultLedgerPolicy().ProofTTL

type rcxLedger struct {
	mu       sync.Mutex
	policy   rcxLedgerPolicy
	global   map[string]*rcxNodeGlobal
	envs     map[string]map[string]*rcxNodeEnv
	episodes map[string]time.Time
}

func newRcxLedger(policy rcxLedgerPolicy) *rcxLedger {
	return &rcxLedger{
		policy:   policy,
		global:   map[string]*rcxNodeGlobal{},
		envs:     map[string]map[string]*rcxNodeEnv{},
		episodes: map[string]time.Time{},
	}
}

func (l *rcxLedger) envState(envKey, node string) *rcxNodeEnv {
	nodes, ok := l.envs[envKey]
	if !ok {
		nodes = map[string]*rcxNodeEnv{}
		l.envs[envKey] = nodes
	}
	state, ok := nodes[node]
	if !ok {
		state = &rcxNodeEnv{}
		nodes[node] = state
	}
	return state
}

func (l *rcxLedger) globalState(node string) *rcxNodeGlobal {
	state, ok := l.global[node]
	if !ok {
		state = &rcxNodeGlobal{}
		l.global[node] = state
	}
	return state
}

func (l *rcxLedger) ProofTTL() time.Duration {
	l.mu.Lock()
	defer l.mu.Unlock()
	return l.policy.ProofTTL
}

func (l *rcxLedger) SetOrigin(node, country string, origin rcxOrigin) {
	l.mu.Lock()
	defer l.mu.Unlock()
	state := l.globalState(node)
	state.Origin = origin
	state.Country = country
}

func (l *rcxLedger) Country(node string) string {
	l.mu.Lock()
	defer l.mu.Unlock()
	return l.globalState(node).Country
}

func (l *rcxLedger) Origin(node string) rcxOrigin {
	l.mu.Lock()
	defer l.mu.Unlock()
	return l.globalState(node).Origin
}

const rcxDegradedWindow = 10 * time.Minute

func (l *rcxLedger) NoteDegraded(node, envKey string, now time.Time) {
	l.mu.Lock()
	defer l.mu.Unlock()
	l.envState(envKey, node).DegradedAt = now
}

func (l *rcxLedger) ClearDegraded(node, envKey string) {
	l.mu.Lock()
	defer l.mu.Unlock()
	l.envState(envKey, node).DegradedAt = time.Time{}
}

// Throttling expires on its own: an operator's squeeze is a phase of the
// network, and a node condemned by one is worth reconsidering later.
func (l *rcxLedger) Degraded(node, envKey string, now time.Time) bool {
	l.mu.Lock()
	defer l.mu.Unlock()
	at := l.envState(envKey, node).DegradedAt
	return !at.IsZero() && now.Sub(at) < rcxDegradedWindow
}

// Carries a record written before the SSID became readable to the key it will be
// found under from now on.
func (l *rcxLedger) Migrate(from, to string) {
	l.mu.Lock()
	defer l.mu.Unlock()
	if from == to || from == "" || to == "" {
		return
	}
	source, ok := l.envs[from]
	if !ok || len(source) == 0 {
		return
	}
	if existing, ok := l.envs[to]; ok && len(existing) > 0 {
		return
	}
	l.envs[to] = source
	delete(l.envs, from)
}

func (l *rcxLedger) Export() (map[string]*rcxNodeGlobal, map[string]map[string]*rcxNodeEnv) {
	l.mu.Lock()
	defer l.mu.Unlock()
	return l.global, l.envs
}

func (l *rcxLedger) Import(
	global map[string]*rcxNodeGlobal,
	envs map[string]map[string]*rcxNodeEnv,
) {
	l.mu.Lock()
	defer l.mu.Unlock()
	if global != nil {
		l.global = global
	}
	if envs != nil {
		l.envs = envs
	}
}

// One accusation per window: retry() gives ten attempts and an outage a socket each.
func (l *rcxLedger) NoteDialFailure(
	node, envKey string,
	terrain rcxTerrain,
	now time.Time,
) bool {
	l.mu.Lock()
	defer l.mu.Unlock()

	if started, ok := l.episodes[node]; ok && now.Sub(started) < l.policy.EpisodeTTL {
		return false
	}
	l.episodes[node] = now
	l.expireEpisodesLocked(now)

	state := l.envState(envKey, node)
	l.decayLocked(state, now)
	state.FailStreak++
	state.LastFailAt = now
	if terrain != rcxTerrainNormal {
		state.provisionalFails++
	}
	l.clampStreakLocked(state)
	l.recoolLocked(state)
	return true
}

// The streak is the debt the decay repays, so unbounded it bans for the day.
func (l *rcxLedger) clampStreakLocked(state *rcxNodeEnv) {
	limit := l.policy.MaxFailStreak
	if limit <= 0 || state.FailStreak <= limit {
		return
	}
	state.FailStreak = limit
	if state.provisionalFails > limit {
		state.provisionalFails = limit
	}
}

// A cooling node is never dialled, so a streak clearing only on success is a ban.
func (l *rcxLedger) decayLocked(state *rcxNodeEnv, now time.Time) {
	if state.FailStreak == 0 || state.LastFailAt.IsZero() || l.policy.FailDecay <= 0 {
		return
	}
	credits := int(now.Sub(state.LastFailAt) / l.policy.FailDecay)
	if credits <= 0 {
		return
	}
	state.LastFailAt = state.LastFailAt.Add(time.Duration(credits) * l.policy.FailDecay)
	l.refundLocked(state, credits)
}

// The anchor moves forward as the streak decays, so a refund may only shorten.
func (l *rcxLedger) refundLocked(state *rcxNodeEnv, credits int) {
	before := state.CoolUntil
	state.FailStreak -= credits
	if state.FailStreak < 0 {
		state.FailStreak = 0
	}
	if state.provisionalFails > state.FailStreak {
		state.provisionalFails = state.FailStreak
	}
	l.recoolLocked(state)
	if !before.IsZero() && state.CoolUntil.After(before) {
		state.CoolUntil = before
	}
}

func (l *rcxLedger) recoolLocked(state *rcxNodeEnv) {
	if state.FailStreak < l.policy.CoolAfterFails || state.LastFailAt.IsZero() {
		state.CoolUntil = time.Time{}
		return
	}
	state.CoolUntil = state.LastFailAt.Add(l.backoffLocked(state.FailStreak))
}

// One node failing while the rest carry traffic is the node; a batch is the link.
func (l *rcxLedger) RollbackFailures(envKey string, counts map[string]int) {
	l.mu.Lock()
	defer l.mu.Unlock()

	for node, count := range counts {
		state := l.envState(envKey, node)
		l.refundLocked(state, count)
		if state.OpenWorld == rcxProofDisproven {
			state.OpenWorld = rcxProofUnknown
		}
		if state.Domestic == rcxProofDisproven {
			state.Domestic = rcxProofUnknown
		}
		state.DegradedAt = time.Time{}
		state.ProofStall = false
	}
}

func (l *rcxLedger) backoffLocked(failStreak int) time.Duration {
	shift := failStreak - l.policy.CoolAfterFails
	backoff := l.policy.DeadRetry
	for i := 0; i < shift && backoff < l.policy.MaxDeadRetry; i++ {
		backoff *= 2
	}
	if backoff > l.policy.MaxDeadRetry {
		backoff = l.policy.MaxDeadRetry
	}
	return backoff
}

// Nothing remote answers this fast: such a dial never left the local session.
const rcxDialProofFloor = 3 * time.Millisecond

// Same physics one exchange later: a sub-floor answer is local, not the node's.
const rcxHarvestFloorMs = 3

func rcxImplausibleDelay(delayMs int) bool {
	return delayMs > 0 && delayMs < rcxHarvestFloorMs
}

// A handshake refutes one dial charge: an SNI block still swallows the payload.
func (l *rcxLedger) NoteDialSuccess(node, envKey string, elapsed time.Duration, now time.Time) bool {
	l.mu.Lock()
	defer l.mu.Unlock()

	if elapsed < rcxDialProofFloor {
		return false
	}
	state := l.envState(envKey, node)
	l.decayLocked(state, now)
	l.refundLocked(state, 1)
	return true
}

func (l *rcxLedger) NoteTrafficProgress(node, envKey string, openWorld bool, now time.Time) {
	l.mu.Lock()
	defer l.mu.Unlock()

	state := l.envState(envKey, node)
	state.LastGoodAt = now
	state.ProgressAt = now
	state.FailStreak = 0
	state.provisionalFails = 0
	state.LastFailAt = time.Time{}
	state.CoolUntil = time.Time{}
	state.ProofStall = false
	if openWorld {
		state.OpenWorld = rcxProofProven
		state.OpenAt = now
		l.globalState(node).EverOpen = true
	}
	l.globalState(node).EverGood = true
}

func (l *rcxLedger) addSampleLocked(state *rcxNodeEnv, delayMs int, now time.Time) {
	if delayMs <= 0 {
		return
	}
	state.Samples = append(state.Samples, rcxSample{DelayMs: delayMs, At: now})
	if len(state.Samples) > l.policy.SampleDepth {
		state.Samples = state.Samples[len(state.Samples)-l.policy.SampleDepth:]
	}
}

func (l *rcxLedger) expireEpisodesLocked(now time.Time) {
	for key, started := range l.episodes {
		if now.Sub(started) >= l.policy.EpisodeTTL {
			delete(l.episodes, key)
		}
	}
}

type rcxProbeOutcome uint8

const (
	rcxProbeOK rcxProbeOutcome = iota
	rcxProbeStatusMismatch
	rcxProbeFail
	rcxProbeOverloaded
)

type rcxRole uint8

const (
	rcxRoleOpen rcxRole = iota
	rcxRoleDomestic
)

func (l *rcxLedger) NoteProbe(
	node, envKey string,
	role rcxRole,
	outcome rcxProbeOutcome,
	delayMs int,
	now time.Time,
) {
	l.mu.Lock()
	defer l.mu.Unlock()

	state := l.envState(envKey, node)
	if outcome != rcxProbeOverloaded {
		state.ProbeAt = now
	}
	switch outcome {
	case rcxProbeOverloaded:
		return
	case rcxProbeOK:
		if rcxImplausibleDelay(delayMs) {
			return
		}
		if role == rcxRoleOpen {
			state.OpenWorld = rcxProofProven
			state.OpenAt = now
			l.globalState(node).EverOpen = true
		} else {
			state.Domestic = rcxProofProven
			state.DomesticAt = now
		}
		state.LastGoodAt = now
		state.ProgressAt = now
		state.ProofStall = false
		state.DegradedAt = time.Time{}
		state.FailStreak = 0
		state.provisionalFails = 0
		state.LastFailAt = time.Time{}
		state.CoolUntil = time.Time{}
		l.globalState(node).EverGood = true
		l.addSampleLocked(state, delayMs, now)
	case rcxProbeStatusMismatch, rcxProbeFail:
		if role == rcxRoleOpen {
			state.OpenWorld = rcxProofDisproven
		} else {
			state.Domestic = rcxProofDisproven
		}
	}
}

// Only lowers a class: UrlTestHook fires before URLTest stores its verdict, and
// the UI's delay test accepts any HTTP status, so a success seen here proves
// nothing.
func (l *rcxLedger) NoteHarvestedProbe(node, envKey string, delayMs int, now time.Time) {
	l.mu.Lock()
	defer l.mu.Unlock()

	if rcxImplausibleDelay(delayMs) {
		return
	}
	state := l.envState(envKey, node)
	if delayMs > 0 {
		l.addSampleLocked(state, delayMs, now)
		return
	}
	if state.OpenWorld == rcxProofProven {
		state.OpenWorld = rcxProofUnknown
	}
}

// Rolls back what a shutdown or a dead radio wrote: without it one commute leaves
// the whole park cooling for hours on a network that is perfectly healthy.
func (l *rcxLedger) PromoteTerrainNormal(envKey string) {
	l.mu.Lock()
	defer l.mu.Unlock()

	for _, state := range l.envs[envKey] {
		if state.provisionalFails == 0 {
			continue
		}
		charged := state.provisionalFails
		state.provisionalFails = 0
		l.refundLocked(state, charged)
	}
}

func (l *rcxLedger) Facts(
	node, envKey string,
	supportsUDP bool,
	now time.Time,
	proofTTL time.Duration,
) rcxFacts {
	l.mu.Lock()
	defer l.mu.Unlock()

	state := l.envState(envKey, node)
	l.decayLocked(state, now)
	global := l.globalState(node)
	facts := rcxFacts{
		Origin:      global.Origin,
		OpenedOnce:  global.EverOpen,
		OpenWorld:   rcxProofAged(state.OpenWorld, state.OpenAt, now, proofTTL),
		Domestic:    rcxProofAged(state.Domestic, state.DomesticAt, now, proofTTL),
		SupportsUDP: supportsUDP,
	}
	switch {
	case !state.CoolUntil.IsZero() && now.Before(state.CoolUntil):
		facts.Transit = rcxProofDisproven
	case !state.CoolUntil.IsZero():
		// The backoff expired: the node is worth a retry, but not a proven rank.
		facts.Transit = rcxProofUnknown
	case !state.ProgressAt.IsZero():
		facts.Transit = rcxProofProven
	}
	return facts
}

func rcxProofAged(proof rcxProof, provenAt, now time.Time, ttl time.Duration) rcxProof {
	if proof != rcxProofProven {
		return proof
	}
	if provenAt.IsZero() || now.Sub(provenAt) > ttl {
		return rcxProofUnknown
	}
	return proof
}

func (l *rcxLedger) FailStreak(node, envKey string) int {
	l.mu.Lock()
	defer l.mu.Unlock()
	return l.envState(envKey, node).FailStreak
}

func (l *rcxLedger) CoolUntil(node, envKey string, now time.Time) time.Time {
	l.mu.Lock()
	defer l.mu.Unlock()
	state := l.envState(envKey, node)
	l.decayLocked(state, now)
	return state.CoolUntil
}

// Samples stamped inside a suspension window are dropped: a phone waking from
// Doze records a wave of zeroes that would read as the entire park being dead.
func (l *rcxLedger) MedianMs(node, envKey string, now, suspendFrom, suspendTo time.Time) int {
	l.mu.Lock()
	defer l.mu.Unlock()

	state := l.envState(envKey, node)
	fresh := make([]int, 0, len(state.Samples))
	for _, sample := range state.Samples {
		if now.Sub(sample.At) > l.policy.StaleAfter {
			continue
		}
		if !suspendFrom.IsZero() && !sample.At.Before(suspendFrom) && !sample.At.After(suspendTo) {
			continue
		}
		fresh = append(fresh, sample.DelayMs)
	}
	if len(fresh) == 0 {
		return 0
	}
	sort.Ints(fresh)
	return fresh[len(fresh)/2]
}

func (l *rcxLedger) Evidence(
	node, envKey string,
	now time.Time,
	liveWindow, freshWindow time.Duration,
) rcxEvidence {
	l.mu.Lock()
	defer l.mu.Unlock()

	state := l.envState(envKey, node)
	if state.ProgressAt.IsZero() {
		return rcxEvidenceNone
	}
	age := now.Sub(state.ProgressAt)
	switch {
	case age <= liveWindow:
		return rcxEvidenceLiveTraffic
	case age <= freshWindow:
		return rcxEvidenceFreshProbe
	default:
		return rcxEvidenceStaleProbe
	}
}

// Costs the proof, never the eligibility: only a measurement may evict a node.
func (l *rcxLedger) NoteIncumbentStalled(node, envKey string, now time.Time) {
	l.mu.Lock()
	defer l.mu.Unlock()

	state := l.envState(envKey, node)
	state.ProofStall = true
	state.OpenWorld = rcxProofUnknown
	state.OpenAt = time.Time{}
}

func (l *rcxLedger) Stalled(node, envKey string) bool {
	l.mu.Lock()
	defer l.mu.Unlock()
	return l.envState(envKey, node).ProofStall
}

func (l *rcxLedger) ProbeAt(node, envKey string) time.Time {
	l.mu.Lock()
	defer l.mu.Unlock()
	return l.envState(envKey, node).ProbeAt
}

func (l *rcxLedger) OpenAt(node, envKey string) time.Time {
	l.mu.Lock()
	defer l.mu.Unlock()
	return l.envState(envKey, node).OpenAt
}

func (l *rcxLedger) ProgressAt(node, envKey string) time.Time {
	l.mu.Lock()
	defer l.mu.Unlock()
	return l.envState(envKey, node).ProgressAt
}

func (l *rcxLedger) Samples(node, envKey string) []rcxSample {
	l.mu.Lock()
	defer l.mu.Unlock()
	return l.envState(envKey, node).Samples
}

func (l *rcxLedger) Prune(nodeKeep int, now time.Time) {
	l.mu.Lock()
	defer l.mu.Unlock()

	l.expireEpisodesLocked(now)
	for envKey, nodes := range l.envs {
		if len(nodes) > nodeKeep {
			type aged struct {
				node string
				at   time.Time
			}
			order := make([]aged, 0, len(nodes))
			for node, state := range nodes {
				order = append(order, aged{node: node, at: state.LastGoodAt})
			}
			sort.Slice(order, func(i, j int) bool { return order[i].at.After(order[j].at) })
			for _, item := range order[nodeKeep:] {
				delete(nodes, item.node)
			}
		}
		if len(nodes) == 0 {
			delete(l.envs, envKey)
		}
	}
}
