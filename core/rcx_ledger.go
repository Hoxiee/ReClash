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
	EverGood bool      `json:"g"`
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
	DegradedAt time.Time   `json:"g"`
	Samples    []rcxSample `json:"s"`

	// Failures stamped while the terrain was not normal, rolled back once it is.
	provisionalFails int
}

type rcxEpisodeKey struct {
	node string
	src  string
}

type rcxLedgerPolicy struct {
	SampleDepth    int
	StaleAfter     time.Duration
	EpisodeTTL     time.Duration
	DeadRetry      time.Duration
	MaxDeadRetry   time.Duration
	CoolAfterFails int
}

func rcxDefaultLedgerPolicy() rcxLedgerPolicy {
	return rcxLedgerPolicy{
		SampleDepth:    8,
		StaleAfter:     6 * time.Hour,
		EpisodeTTL:     10 * time.Second,
		DeadRetry:      15 * time.Minute,
		MaxDeadRetry:   24 * time.Hour,
		CoolAfterFails: 3,
	}
}

type rcxLedger struct {
	mu       sync.Mutex
	policy   rcxLedgerPolicy
	global   map[string]*rcxNodeGlobal
	envs     map[string]map[string]*rcxNodeEnv
	episodes map[rcxEpisodeKey]time.Time
}

func newRcxLedger(policy rcxLedgerPolicy) *rcxLedger {
	return &rcxLedger{
		policy:   policy,
		global:   map[string]*rcxNodeGlobal{},
		envs:     map[string]map[string]*rcxNodeEnv{},
		episodes: map[rcxEpisodeKey]time.Time{},
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

func (l *rcxLedger) SetOrigin(node string, origin rcxOrigin) {
	l.mu.Lock()
	defer l.mu.Unlock()
	l.globalState(node).Origin = origin
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

// Folds every attempt of one user connection into a single episode: retry() gives
// a dead node up to ten attempts inside one 5s context, so counting attempts
// would read as ten failures in a fraction of a second.
func (l *rcxLedger) NoteDialFailure(
	node, src, envKey string,
	terrain rcxTerrain,
	now time.Time,
) bool {
	l.mu.Lock()
	defer l.mu.Unlock()

	key := rcxEpisodeKey{node: node, src: src}
	if started, ok := l.episodes[key]; ok && now.Sub(started) < l.policy.EpisodeTTL {
		return false
	}
	l.episodes[key] = now
	l.expireEpisodesLocked(now)

	state := l.envState(envKey, node)
	state.FailStreak++
	if terrain != rcxTerrainNormal {
		state.provisionalFails++
	}
	if state.FailStreak >= l.policy.CoolAfterFails {
		state.CoolUntil = now.Add(l.backoffLocked(state.FailStreak))
	}
	return true
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

func (l *rcxLedger) NoteDialSuccess(node, src, envKey string, elapsed time.Duration, now time.Time) {
	l.mu.Lock()
	defer l.mu.Unlock()

	delete(l.episodes, rcxEpisodeKey{node: node, src: src})
	state := l.envState(envKey, node)
	state.FailStreak = 0
	state.provisionalFails = 0
	state.CoolUntil = time.Time{}
	state.LastGoodAt = now
	l.globalState(node).EverGood = true
	l.addSampleLocked(state, int(elapsed/time.Millisecond), now)
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
	switch outcome {
	case rcxProbeOverloaded:
		return
	case rcxProbeOK:
		if role == rcxRoleOpen {
			state.OpenWorld = rcxProofProven
		} else {
			state.Domestic = rcxProofProven
		}
		state.LastGoodAt = now
		state.FailStreak = 0
		state.provisionalFails = 0
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
		state.FailStreak -= state.provisionalFails
		if state.FailStreak < 0 {
			state.FailStreak = 0
		}
		state.provisionalFails = 0
		if state.FailStreak < l.policy.CoolAfterFails {
			state.CoolUntil = time.Time{}
		}
	}
}

func (l *rcxLedger) Facts(node, envKey string, supportsUDP bool, now time.Time) rcxFacts {
	l.mu.Lock()
	defer l.mu.Unlock()

	state := l.envState(envKey, node)
	facts := rcxFacts{
		Origin:      l.globalState(node).Origin,
		OpenWorld:   state.OpenWorld,
		Domestic:    state.Domestic,
		SupportsUDP: supportsUDP,
	}
	switch {
	case !state.CoolUntil.IsZero() && now.Before(state.CoolUntil):
		facts.Transit = rcxProofDisproven
	case !state.LastGoodAt.IsZero():
		facts.Transit = rcxProofProven
	}
	return facts
}

func (l *rcxLedger) CoolUntil(node, envKey string) time.Time {
	l.mu.Lock()
	defer l.mu.Unlock()
	return l.envState(envKey, node).CoolUntil
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
	if state.LastGoodAt.IsZero() {
		return rcxEvidenceNone
	}
	age := now.Sub(state.LastGoodAt)
	switch {
	case age <= liveWindow:
		return rcxEvidenceLiveTraffic
	case age <= freshWindow:
		return rcxEvidenceFreshProbe
	default:
		return rcxEvidenceStaleProbe
	}
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
