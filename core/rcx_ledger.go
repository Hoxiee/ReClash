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
	Origin      rcxOrigin     `json:"o"`
	Country     string        `json:"c"`
	EverGood    bool          `json:"g"`
	OpenedUnder string        `json:"of,omitempty"`
	Exit        rcxOrigin     `json:"x,omitempty"`
	ExitCountry string        `json:"xc,omitempty"`
	ExitAt      time.Time     `json:"xa,omitempty"`
	Trust       rcxTrust      `json:"tr,omitempty"`
	TrustConf   rcxConfidence `json:"tk,omitempty"`
	TrustAt     time.Time     `json:"ta,omitempty"`
}

// Per (node x environment) on purpose: the dominant cause of a dial failure here
// is the network blocking it, not the node dying, so a global failure count would
// condemn the whole park after one whitelist episode.
type rcxMarkerEvidence struct {
	Outcome rcxProbeOutcome `json:"o"`
	At      time.Time       `json:"a"`
	DelayMs int             `json:"d,omitempty"`
	Role    rcxRole         `json:"r,omitempty"`
	Under   string          `json:"u,omitempty"`
}

type rcxNodeEnv struct {
	OpenWorld        rcxProof                     `json:"w"`
	Domestic         rcxProof                     `json:"m"`
	FailStreak       int                          `json:"f"`
	CoolUntil        time.Time                    `json:"c"`
	LastGoodAt       time.Time                    `json:"l"`
	LastFailAt       time.Time                    `json:"lf"`
	DegradedAt       time.Time                    `json:"g"`
	Samples          []rcxSample                  `json:"s"`
	OpenAt           time.Time                    `json:"oa"`
	DomesticAt       time.Time                    `json:"ma"`
	ProgressAt       time.Time                    `json:"p"`
	TrafficAt        time.Time                    `json:"ta,omitempty"`
	ProbeGoodAt      time.Time                    `json:"pg,omitempty"`
	HarvestAt        time.Time                    `json:"ha,omitempty"`
	QualitySamples   []rcxQualitySample           `json:"qs,omitempty"`
	RecurrenceEvents []rcxFailureEpisode          `json:"re,omitempty"`
	RecurrenceAt     time.Time                    `json:"ra,omitempty"`
	ProbeAt          time.Time                    `json:"pa"`
	ProofStall       bool                         `json:"ps"`
	OpenUnder        string                       `json:"owf,omitempty"`
	HomeUnder        string                       `json:"dmf,omitempty"`
	LastSeenAt       time.Time                    `json:"ls,omitempty"`
	Markers          map[string]rcxMarkerEvidence `json:"me,omitempty"`

	// Failures stamped while the terrain was not normal, rolled back once it is.
	provisionalFails int
	failureCharges   []time.Time
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
	mu              sync.Mutex
	policy          rcxLedgerPolicy
	global          map[string]*rcxNodeGlobal
	envs            map[string]map[string]*rcxNodeEnv
	episodes        map[string]time.Time
	openFingerprint string
	homeFingerprint string
}

func newRcxLedger(policy rcxLedgerPolicy) *rcxLedger {
	return &rcxLedger{
		policy:          policy,
		global:          map[string]*rcxNodeGlobal{},
		envs:            map[string]map[string]*rcxNodeEnv{},
		episodes:        map[string]time.Time{},
		openFingerprint: "legacy",
		homeFingerprint: "legacy",
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

// A marker one node still passes is not down: the failures elsewhere are node
// deaths, so they must not quarantine it and blind every other node with it.
func (l *rcxLedger) MarkerFreshlyPassing(envKey, markerID string, now time.Time) bool {
	l.mu.Lock()
	defer l.mu.Unlock()
	for _, state := range l.envs[envKey] {
		evidence, ok := state.Markers[markerID]
		if ok && evidence.Outcome == rcxProbeOK && rcxFreshAt(evidence.At, now, l.policy.ProofTTL) {
			return true
		}
	}
	return false
}

func (l *rcxLedger) SetFingerprints(open, domestic string) {
	l.mu.Lock()
	defer l.mu.Unlock()
	l.openFingerprint = open
	l.homeFingerprint = domestic
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

func (l *rcxLedger) SetExit(node, country string, exit rcxOrigin, now time.Time) {
	l.mu.Lock()
	defer l.mu.Unlock()
	state := l.globalState(node)
	state.Exit = exit
	state.ExitCountry = country
	state.ExitAt = now
	// A home exit only bars to last resort (Exit already ranks it down); the hard brand is the behavioural check's alone.
	if exit == rcxOriginForeign {
		l.setTrustLocked(state, rcxTrusted, rcxConfMeasured, now)
	}
}

func (l *rcxLedger) setTrustLocked(state *rcxNodeGlobal, trust rcxTrust, conf rcxConfidence, now time.Time) {
	// A measured foreign exit contradicts a brand outright, so it clears one even
	// though the brand was recorded at higher confidence: no node stays branded forever.
	unbrands := trust == rcxTrusted && conf >= rcxConfMeasured
	if conf < state.TrustConf && !unbrands {
		return
	}
	state.Trust = trust
	state.TrustConf = conf
	state.TrustAt = now
}

// A Suspect prior never overwrites a measured verdict, so a flag cannot un-brand a node.
func (l *rcxLedger) SetTrust(node string, trust rcxTrust, conf rcxConfidence, now time.Time) {
	l.mu.Lock()
	defer l.mu.Unlock()
	state := l.globalState(node)
	if trust == rcxTrustSuspect && state.Trust != rcxTrustUnknown {
		return
	}
	l.setTrustLocked(state, trust, conf, now)
}

func (l *rcxLedger) Trust(node string) (rcxTrust, rcxConfidence) {
	l.mu.Lock()
	defer l.mu.Unlock()
	state := l.globalState(node)
	return state.Trust, state.TrustConf
}

func (l *rcxLedger) ExitCountry(node string) string {
	l.mu.Lock()
	defer l.mu.Unlock()
	return l.globalState(node).ExitCountry
}

func (l *rcxLedger) ExitAt(node string) time.Time {
	l.mu.Lock()
	defer l.mu.Unlock()
	return l.globalState(node).ExitAt
}

func (l *rcxLedger) Exit(node string, now time.Time) rcxOrigin {
	l.mu.Lock()
	defer l.mu.Unlock()
	state := l.globalState(node)
	return rcxExitAged(state.Exit, state.ExitAt, now)
}

const rcxDegradedWindow = 10 * time.Minute

const rcxExitTTL = 6 * time.Hour

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
	destination := l.envs[to]
	if destination == nil {
		destination = map[string]*rcxNodeEnv{}
		l.envs[to] = destination
	}
	for node, incoming := range source {
		oldEpisode, newEpisode := from+"\x00"+node, to+"\x00"+node
		if l.episodes[oldEpisode].After(l.episodes[newEpisode]) {
			l.episodes[newEpisode] = l.episodes[oldEpisode]
		}
		delete(l.episodes, oldEpisode)
		if current := destination[node]; current != nil {
			mergeNodeEnv(current, incoming, l.policy.SampleDepth)
		} else {
			destination[node] = incoming
		}
	}
	delete(l.envs, from)
}

func mergeNodeEnv(current, incoming *rcxNodeEnv, sampleDepth int) {
	if incoming == nil {
		return
	}
	if incoming.OpenAt.After(current.OpenAt) {
		current.OpenWorld, current.OpenAt, current.OpenUnder = incoming.OpenWorld, incoming.OpenAt, incoming.OpenUnder
	}
	if incoming.DomesticAt.After(current.DomesticAt) {
		current.Domestic, current.DomesticAt, current.HomeUnder = incoming.Domestic, incoming.DomesticAt, incoming.HomeUnder
	}
	if incoming.LastGoodAt.After(current.LastGoodAt) {
		current.LastGoodAt = incoming.LastGoodAt
	}
	if incoming.LastFailAt.After(current.LastFailAt) {
		current.FailStreak, current.LastFailAt, current.CoolUntil = incoming.FailStreak, incoming.LastFailAt, incoming.CoolUntil
	}
	if incoming.DegradedAt.After(current.DegradedAt) {
		current.DegradedAt, current.ProofStall = incoming.DegradedAt, incoming.ProofStall
	}
	if incoming.ProgressAt.After(current.ProgressAt) {
		current.ProgressAt = incoming.ProgressAt
	}
	if incoming.ProbeAt.After(current.ProbeAt) {
		current.ProbeAt = incoming.ProbeAt
	}
	if incoming.LastSeenAt.After(current.LastSeenAt) {
		current.LastSeenAt = incoming.LastSeenAt
	}
	current.Samples = mergeSamples(current.Samples, incoming.Samples, sampleDepth)
	mergeQualityState(current, incoming)
	if current.Markers == nil {
		current.Markers = map[string]rcxMarkerEvidence{}
	}
	for id, evidence := range incoming.Markers {
		if known, ok := current.Markers[id]; !ok || evidence.At.After(known.At) {
			current.Markers[id] = evidence
		}
	}
}

func mergeSamples(current, incoming []rcxSample, depth int) []rcxSample {
	merged := append(append([]rcxSample(nil), current...), incoming...)
	sort.SliceStable(merged, func(i, j int) bool { return merged[i].At.Before(merged[j].At) })
	if depth > 0 && len(merged) > depth {
		merged = merged[len(merged)-depth:]
	}
	return merged
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

	return l.noteFailureLocked(node, envKey, "", terrain, now)
}

func (l *rcxLedger) noteFailureLocked(node, envKey, marker string, terrain rcxTerrain, now time.Time) bool {
	state := l.envState(envKey, node)
	l.decayLocked(state, now)
	key := envKey + "\x00" + node
	started := l.episodes[key]
	if len(state.RecurrenceEvents) > 0 {
		latest := state.RecurrenceEvents[len(state.RecurrenceEvents)-1].At
		if latest.After(started) {
			started = latest
		}
	}
	if !started.IsZero() && now.Sub(started) < l.policy.EpisodeTTL {
		l.attachFailureSourceLocked(state, marker, started)
		return false
	}
	l.episodes[key] = now
	l.expireEpisodesLocked(now)
	state.failureCharges = append(state.failureCharges, now)
	if len(state.failureCharges) > rcxRecurrenceLimit {
		state.failureCharges = state.failureCharges[len(state.failureCharges)-rcxRecurrenceLimit:]
	}
	if terrain == rcxTerrainNormal {
		l.noteRecurrenceLocked(state, marker, now)
	}
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
	l.decayRecurrenceLocked(state, now)
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
		l.rollbackRecurrenceLocked(state, count)
		for id, evidence := range state.Markers {
			if evidence.Outcome != rcxProbeOK {
				delete(state.Markers, id)
			}
		}
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
	answered, _ := l.noteDialSuccess(node, envKey, elapsed, now)
	return answered
}

func (l *rcxLedger) noteDialSuccess(node, envKey string, elapsed time.Duration, now time.Time) (answered, changed bool) {
	if elapsed < rcxDialProofFloor {
		return false, false
	}
	l.mu.Lock()
	defer l.mu.Unlock()

	state := l.envState(envKey, node)
	streak, coolUntil, recurrence := state.FailStreak, state.CoolUntil, len(state.RecurrenceEvents)
	l.decayLocked(state, now)
	l.refundLocked(state, 1)
	return true, streak != state.FailStreak || !coolUntil.Equal(state.CoolUntil) || recurrence != len(state.RecurrenceEvents)
}

func (l *rcxLedger) NoteTrafficProgress(node, envKey string, openWorld bool, now time.Time) {
	l.mu.Lock()
	defer l.mu.Unlock()

	state := l.envState(envKey, node)
	state.LastGoodAt = now
	state.ProgressAt = now
	state.TrafficAt = now
	state.FailStreak = 0
	state.provisionalFails = 0
	state.LastFailAt = time.Time{}
	state.CoolUntil = time.Time{}
	state.ProofStall = false
	if openWorld {
		state.OpenWorld = rcxProofProven
		state.OpenAt = now
		state.OpenUnder = l.openFingerprint
		l.globalState(node).OpenedUnder = l.openFingerprint
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
	rcxRoleLocal
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
	l.noteProbeLocked(node, l.envState(envKey, node), role, outcome, delayMs, now)
}

func (l *rcxLedger) NoteMarkerProbe(
	node, envKey string,
	role rcxRole,
	markerID string,
	outcome rcxProbeOutcome,
	delayMs int,
	now time.Time,
) {
	l.mu.Lock()
	defer l.mu.Unlock()
	state := l.envState(envKey, node)
	if state.Markers == nil {
		state.Markers = map[string]rcxMarkerEvidence{}
	}
	if outcome == rcxProbeOK && rcxImplausibleDelay(delayMs) {
		state.ProbeAt = now
		return
	}
	if outcome != rcxProbeOverloaded {
		under := l.openFingerprint
		if role == rcxRoleDomestic {
			under = l.homeFingerprint
		}
		state.Markers[markerID] = rcxMarkerEvidence{Outcome: outcome, At: now, DelayMs: delayMs, Role: role, Under: under}
	}
	if outcome == rcxProbeOK {
		l.noteProbeLocked(node, state, role, outcome, delayMs, now)
	} else if outcome != rcxProbeOverloaded {
		state.ProbeAt = now
	}
}

func (l *rcxLedger) RecomputeRole(
	node, envKey string,
	role rcxRole,
	markerIDs []string,
	now time.Time,
) {
	l.mu.Lock()
	defer l.mu.Unlock()
	state := l.envState(envKey, node)
	proof := rcxProofUnknown
	at := time.Time{}
	failureAt := time.Time{}
	under := l.openFingerprint
	if role == rcxRoleDomestic {
		under = l.homeFingerprint
	}
	complete := len(markerIDs) > 0
	for _, markerID := range markerIDs {
		evidence, ok := state.Markers[markerID]
		if !ok || evidence.Outcome == rcxProbeOverloaded || evidence.Role != role || evidence.Under != under || !rcxFreshAt(evidence.At, now, l.policy.ProofTTL) {
			complete = false
			continue
		}
		if evidence.Outcome == rcxProbeOK {
			proof = rcxProofProven
			if evidence.At.After(at) {
				at = evidence.At
			}
		} else if failureAt.IsZero() || evidence.At.Before(failureAt) {
			failureAt = evidence.At
		}
	}
	if proof != rcxProofProven && complete {
		proof = rcxProofDisproven
		at = failureAt
	}
	if role == rcxRoleOpen {
		state.OpenWorld = proof
		state.OpenAt = at
		state.OpenUnder = l.openFingerprint
		if proof == rcxProofProven {
			l.globalState(node).OpenedUnder = l.openFingerprint
		}
	} else {
		state.Domestic = proof
		state.DomesticAt = at
		state.HomeUnder = l.homeFingerprint
	}
}

func (l *rcxLedger) noteProbeLocked(
	node string,
	state *rcxNodeEnv,
	role rcxRole,
	outcome rcxProbeOutcome,
	delayMs int,
	now time.Time,
) {
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
			state.OpenUnder = l.openFingerprint
			l.globalState(node).OpenedUnder = l.openFingerprint
		} else {
			state.Domestic = rcxProofProven
			state.DomesticAt = now
			state.HomeUnder = l.homeFingerprint
		}
		state.LastGoodAt = now
		state.ProgressAt = now
		state.ProbeGoodAt = now
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
			state.OpenAt = now
			state.OpenUnder = l.openFingerprint
		} else {
			state.Domestic = rcxProofDisproven
			state.DomesticAt = now
			state.HomeUnder = l.homeFingerprint
		}
	}
}

func (l *rcxLedger) NoteHarvestedProbe(node, envKey string, delayMs int, now time.Time) {
	l.mu.Lock()
	defer l.mu.Unlock()

	if rcxImplausibleDelay(delayMs) {
		return
	}
	state := l.envState(envKey, node)
	if delayMs > 0 {
		state.LastGoodAt = now
		state.ProgressAt = now
		state.HarvestAt = now
		state.FailStreak = 0
		state.provisionalFails = 0
		state.LastFailAt = time.Time{}
		state.CoolUntil = time.Time{}
		state.DegradedAt = time.Time{}
		state.ProofStall = false
		l.globalState(node).EverGood = true
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
		Exit:        rcxExitAged(global.Exit, global.ExitAt, now),
		OpenedOnce:  global.OpenedUnder != "" && global.OpenedUnder == l.openFingerprint,
		OpenWorld:   rcxProofForFingerprint(state.OpenWorld, state.OpenAt, state.OpenUnder, l.openFingerprint, now, proofTTL),
		Domestic:    rcxProofForFingerprint(state.Domestic, state.DomesticAt, state.HomeUnder, l.homeFingerprint, now, proofTTL),
		SupportsUDP: supportsUDP,
		Trust:       global.Trust,
	}
	switch {
	case !state.CoolUntil.IsZero() && now.Before(state.CoolUntil):
		facts.Transit = rcxProofDisproven
	case !state.CoolUntil.IsZero():
		// The backoff expired: the node is worth a retry, but not a proven rank.
		facts.Transit = rcxProofUnknown
	case rcxFreshAt(state.ProgressAt, now, proofTTL):
		facts.Transit = rcxProofProven
	}
	return facts
}

func rcxExitAged(exit rcxOrigin, measuredAt, now time.Time) rcxOrigin {
	if exit == rcxOriginUnknown || measuredAt.IsZero() || now.Sub(measuredAt) > rcxExitTTL {
		return rcxOriginUnknown
	}
	return exit
}

func rcxProofForFingerprint(proof rcxProof, provenAt time.Time, stored, active string, now time.Time, ttl time.Duration) rcxProof {
	if stored == "" || stored != active {
		return rcxProofUnknown
	}
	return rcxProofAged(proof, provenAt, now, ttl)
}

func rcxProofAged(proof rcxProof, provenAt, now time.Time, ttl time.Duration) rcxProof {
	if proof == rcxProofUnknown {
		return proof
	}
	if !rcxFreshAt(provenAt, now, ttl) {
		return rcxProofUnknown
	}
	return proof
}

func (l *rcxLedger) PreviouslyGood(node, envKey string) bool {
	l.mu.Lock()
	defer l.mu.Unlock()
	return !l.envState(envKey, node).LastGoodAt.IsZero()
}

func (l *rcxLedger) LastFailureAt(node, envKey string) time.Time {
	l.mu.Lock()
	defer l.mu.Unlock()
	return l.envState(envKey, node).LastFailAt
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
	if rcxFreshAt(state.TrafficAt, now, liveWindow) {
		return rcxEvidenceLiveTraffic
	}
	latest := time.Time{}
	for _, at := range []time.Time{state.TrafficAt, state.ProbeGoodAt, state.HarvestAt} {
		if at.After(latest) && !at.After(now) {
			latest = at
		}
	}
	if latest.IsZero() || latest.After(now) {
		return rcxEvidenceNone
	}
	if rcxFreshAt(latest, now, freshWindow) {
		return rcxEvidenceFreshProbe
	}
	return rcxEvidenceStaleProbe
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

func (l *rcxLedger) OpenProven(node, envKey string, now time.Time, ttl time.Duration) bool {
	l.mu.Lock()
	defer l.mu.Unlock()
	state := l.envState(envKey, node)
	return rcxProofForFingerprint(state.OpenWorld, state.OpenAt, state.OpenUnder, l.openFingerprint, now, ttl) == rcxProofProven
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

const (
	rcxRemovedKeepPerEnv = 64
	rcxRemovedTTL        = 7 * 24 * time.Hour
)

func (l *rcxLedger) MarkMembers(nodes map[string]struct{}, now time.Time) {
	l.mu.Lock()
	defer l.mu.Unlock()
	for _, env := range l.envs {
		for node := range nodes {
			if state, ok := env[node]; ok {
				state.LastSeenAt = now
			}
		}
	}
}

func (l *rcxLedger) Invalidate(openChanged, domesticChanged, countriesChanged, egressChanged bool) {
	l.mu.Lock()
	defer l.mu.Unlock()
	if countriesChanged {
		for _, global := range l.global {
			global.Origin = rcxOriginUnknown
			global.Country = ""
		}
	}
	if countriesChanged || egressChanged {
		for _, global := range l.global {
			global.Exit = rcxOriginUnknown
			global.ExitCountry = ""
			global.ExitAt = time.Time{}
			global.Trust = rcxTrustUnknown
			global.TrustConf = rcxConfNone
			global.TrustAt = time.Time{}
		}
	}
	if !openChanged && !domesticChanged {
		return
	}
	for _, nodes := range l.envs {
		for _, state := range nodes {
			for id, evidence := range state.Markers {
				if (openChanged && evidence.Role == rcxRoleOpen) || (domesticChanged && evidence.Role == rcxRoleDomestic) {
					delete(state.Markers, id)
				}
			}
			quality := state.QualitySamples[:0]
			for _, sample := range state.QualitySamples {
				if (openChanged && sample.Role == rcxRoleOpen) || (domesticChanged && sample.Role == rcxRoleDomestic) {
					continue
				}
				quality = append(quality, sample)
			}
			state.QualitySamples = quality
			if openChanged {
				state.OpenWorld = rcxProofUnknown
				state.OpenAt = time.Time{}
				state.OpenUnder = ""
			}
			if domesticChanged {
				state.Domestic = rcxProofUnknown
				state.DomesticAt = time.Time{}
				state.HomeUnder = ""
			}
		}
	}
}

func (l *rcxLedger) Prune(active, protected map[string]struct{}, now time.Time) {
	l.mu.Lock()
	defer l.mu.Unlock()

	l.expireEpisodesLocked(now)
	keptGlobal := make(map[string]struct{}, len(active)+len(protected))
	for envKey, nodes := range l.envs {
		type aged struct {
			node string
			at   time.Time
		}
		removed := make([]aged, 0, len(nodes))
		for node, state := range nodes {
			if _, ok := active[node]; ok {
				keptGlobal[node] = struct{}{}
				continue
			}
			if _, ok := protected[node]; ok {
				keptGlobal[node] = struct{}{}
				continue
			}
			at := state.LastSeenAt
			if state.LastGoodAt.After(at) {
				at = state.LastGoodAt
			}
			removed = append(removed, aged{node: node, at: at})
		}
		sort.Slice(removed, func(i, j int) bool { return removed[i].at.After(removed[j].at) })
		for i, item := range removed {
			if i >= rcxRemovedKeepPerEnv || (!item.at.IsZero() && now.Sub(item.at) > rcxRemovedTTL) {
				delete(nodes, item.node)
				continue
			}
			keptGlobal[item.node] = struct{}{}
		}
		if len(nodes) == 0 {
			delete(l.envs, envKey)
		}
	}
	for node := range active {
		keptGlobal[node] = struct{}{}
	}
	for node := range protected {
		keptGlobal[node] = struct{}{}
	}
	for node := range l.global {
		if _, ok := keptGlobal[node]; !ok {
			delete(l.global, node)
		}
	}
}
