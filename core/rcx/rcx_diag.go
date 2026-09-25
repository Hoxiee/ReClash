package rcx

import (
	"hash/fnv"
	"io"
	"strconv"
	"sync"
	"sync/atomic"
	"time"
)

// A live-session capture, not a log file: bounded, in memory, and gone when the
// process exits. The host opts in per session and pulls by cursor.
const rcxDiagCapacity = 4096

type rcxDiagKind string

const (
	rcxDiagDecision rcxDiagKind = "decision"
	rcxDiagSwitch   rcxDiagKind = "switch"
	rcxDiagEvent    rcxDiagKind = "event"
	rcxDiagProbe    rcxDiagKind = "probe"
)

// The moment's system state behind one cycle, flattened so the host can show why
// a decision landed where it did without re-deriving anything from the engine.
type rcxDiagContext struct {
	Terrain       string `json:"terrain"`
	Env           string `json:"env"`
	Incumbent     string `json:"incumbent"`
	IncumbentMs   int    `json:"incumbentMs"`
	SinceMs       int64  `json:"sinceMs"`
	Pin           string `json:"pin"`
	Strategy      string `json:"strategy"`
	Preset        string `json:"preset"`
	Mode          string `json:"mode"`
	ScreenOff     bool   `json:"screenOff"`
	Suspended     bool   `json:"suspended"`
	Probing       bool   `json:"probing"`
	Deep          bool   `json:"deep"`
	Transport     string `json:"transport"`
	Portal        bool   `json:"portal"`
	Metered       bool   `json:"metered"`
	Validated     bool   `json:"validated"`
	ReachF        string `json:"reachF"`
	ReachD        string `json:"reachD"`
	Direct        string `json:"direct"`
	ProbesLeft    int    `json:"probesLeft"`
	Candidates    int    `json:"candidates"`
	Eligible      int    `json:"eligible"`
	IncidentConns int    `json:"incidentConns"`
	FrozenNodes   int    `json:"frozenNodes"`
}

type rcxDiagEntry struct {
	Seq    uint64               `json:"seq"`
	At     int64                `json:"at"`
	Kind   rcxDiagKind          `json:"kind"`
	Msg    string               `json:"msg"`
	From   string               `json:"from,omitempty"`
	To     string               `json:"to,omitempty"`
	Repeat int                  `json:"repeat"`
	Ctx    *rcxDiagContext      `json:"ctx,omitempty"`
	Cands  []rcxCandidateReport `json:"cands,omitempty"`
}

type rcxDiagQuery struct {
	Since uint64 `json:"since"`
}

type rcxDiagBatch struct {
	Entries []rcxDiagEntry `json:"entries"`
	Cursor  uint64         `json:"cursor"`
	Dropped uint64         `json:"dropped"`
	Enabled bool           `json:"enabled"`
}

// The ring carries its own lock and an atomic gate: the record path is a cheap
// no-op while off, and the host polls from a goroutine other than the actor that
// writes, so the two must not share the engine's report mutex.
type rcxDiagRing struct {
	on atomic.Bool

	mu      sync.Mutex
	entries []rcxDiagEntry
	start   int
	count   int
	seq     uint64
	dropped uint64
	lastSig uint64
}

func newRcxDiagRing() *rcxDiagRing {
	return &rcxDiagRing{entries: make([]rcxDiagEntry, rcxDiagCapacity)}
}

func (r *rcxDiagRing) enabled() bool {
	return r != nil && r.on.Load()
}

func (r *rcxDiagRing) setEnabled(on bool) {
	if r == nil {
		return
	}
	// A fresh session starts clean so the host's cursor-0 pull is the whole
	// session and never a tail of an earlier one.
	if on && !r.on.Swap(true) {
		r.mu.Lock()
		r.start, r.count, r.seq, r.dropped, r.lastSig = 0, 0, 0, 0, 0
		r.mu.Unlock()
		return
	}
	r.on.Store(on)
}

func (r *rcxDiagRing) push(entry rcxDiagEntry) {
	if !r.enabled() {
		return
	}
	sig := entry.signature()
	r.mu.Lock()
	defer r.mu.Unlock()
	// A quiet hold reconsidered every tick collapses into one row, but the row is
	// re-emitted with a fresh seq so a polling host still sees its repeat climb.
	if r.count > 0 && sig == r.lastSig {
		idx := (r.start + r.count - 1) % len(r.entries)
		r.seq++
		last := r.entries[idx]
		last.Repeat++
		last.Seq = r.seq
		last.At = entry.At
		r.entries[idx] = last
		return
	}
	r.seq++
	entry.Seq = r.seq
	entry.Repeat = 1
	r.lastSig = sig
	if r.count == len(r.entries) {
		r.start = (r.start + 1) % len(r.entries)
		r.count--
		r.dropped++
	}
	idx := (r.start + r.count) % len(r.entries)
	r.entries[idx] = entry
	r.count++
}

func (r *rcxDiagRing) since(cursor uint64) rcxDiagBatch {
	on := r.on.Load()
	r.mu.Lock()
	defer r.mu.Unlock()
	batch := rcxDiagBatch{Cursor: r.seq, Dropped: r.dropped, Enabled: on}
	// Physical order equals seq order: appends raise seq, and the only in-place
	// rewrite (the dedupe tail) only ever raises the last row's seq. So one
	// forward scan stays monotonic and preserves ordering.
	for i := 0; i < r.count; i++ {
		idx := (r.start + i) % len(r.entries)
		if r.entries[idx].Seq > cursor {
			batch.Entries = append(batch.Entries, r.entries[idx])
		}
	}
	return batch
}

func diagHashString(h io.Writer, value string) {
	_, _ = io.WriteString(h, value)
	_, _ = io.WriteString(h, "\x00")
}

// Signature over what a reader would call "the same cycle": the kind, message,
// endpoints, the decision-shaping context, and each candidate's identity and
// standing. Volatile fields (timestamps, probe budgets) are left out so a steady
// hold dedupes instead of emitting an identical row every tick.
func (entry rcxDiagEntry) signature() uint64 {
	h := fnv.New64a()
	diagHashString(h, string(entry.Kind))
	diagHashString(h, entry.Msg)
	diagHashString(h, entry.From)
	diagHashString(h, entry.To)
	if entry.Ctx != nil {
		c := entry.Ctx
		diagHashString(h, c.Terrain)
		diagHashString(h, c.Incumbent)
		diagHashString(h, c.Pin)
		diagHashString(h, c.Strategy)
		diagHashString(h, c.Transport)
		diagHashString(h, c.ReachF)
		diagHashString(h, c.ReachD)
		diagHashString(h, strconv.Itoa(c.Eligible))
		diagHashString(h, strconv.Itoa(c.Candidates))
		diagHashString(h, strconv.FormatBool(c.ScreenOff))
		diagHashString(h, strconv.FormatBool(c.Suspended))
		diagHashString(h, strconv.FormatBool(c.Probing))
	}
	for i := range entry.Cands {
		c := &entry.Cands[i]
		diagHashString(h, c.Node)
		diagHashString(h, c.Block)
		diagHashString(h, c.Verdict)
		diagHashString(h, strconv.Itoa(c.Order))
		diagHashString(h, strconv.Itoa(c.DelayMs))
		diagHashString(h, strconv.FormatBool(c.Current))
	}
	return h.Sum64()
}

func rcxWaveName(kind rcxWaveKind) string {
	switch kind {
	case rcxWaveRoutine:
		return "routine"
	case rcxWaveMaintain:
		return "maintain"
	case rcxWaveGrant:
		return "grant"
	case rcxWaveRescue:
		return "rescue"
	case rcxWaveIncident:
		return "incident"
	case rcxWaveHandoff:
		return "handoff"
	case rcxWaveDeep:
		return "deep"
	case rcxWaveDiscover:
		return "discover"
	case rcxWaveQuality:
		return "quality"
	case rcxWaveLocate:
		return "locate"
	default:
		return "wave"
	}
}

func rcxEventLabel(event rcxEvent) string {
	switch event.Kind {
	case rcxEventConfigure:
		return "configure"
	case rcxEventNetwork:
		return "network " + event.Payload.Transport
	case rcxEventConfigApplied:
		return "config-applied"
	case rcxEventProvidersLoaded:
		return "providers-loaded"
	case rcxEventScreenOff:
		return "screen " + rcxOnOff(event.Flag)
	case rcxEventSuspend:
		return "suspend " + rcxOnOff(event.Flag)
	case rcxEventSetEnabled:
		return "set-enabled " + rcxOnOff(event.Flag)
	case rcxEventHarvested:
		return "harvested " + event.Node + " " + strconv.Itoa(event.DelayMs) + "ms"
	case rcxEventManualPick:
		return "manual-pick " + event.Node
	case rcxEventManualAssert:
		return "manual-assert " + event.Node
	case rcxEventDeepScan:
		return "deep-scan"
	case rcxEventHostSweep:
		return "host-sweep"
	case rcxEventProbeResult:
		return "probe-result"
	case rcxEventProbeResults:
		return "probe-results " + strconv.Itoa(len(event.Results))
	case rcxEventWakeResults:
		return "wake-results " + strconv.Itoa(len(event.Wake))
	case rcxEventTerrainReach:
		return "terrain-reach f=" + rcxOutcomeName(event.Foreign) + " d=" + rcxOutcomeName(event.Domestic)
	default:
		return "event"
	}
}

func rcxOnOff(flag bool) string {
	if flag {
		return "on"
	}
	return "off"
}

func (e *rcxEngine) diagContext(input rcxDecisionInput, ranked []rcxRanked) *rcxDiagContext {
	eligible := 0
	for _, row := range ranked {
		if row.Block == rcxBlockNone {
			eligible++
		}
	}
	return &rcxDiagContext{
		Terrain:       e.terrainCurrent().String(),
		Env:           e.envKey,
		Incumbent:     e.incumbent,
		IncumbentMs:   e.delayOf(e.incumbent),
		SinceMs:       rcxMillis(e.since),
		Pin:           input.Pin,
		Strategy:      e.cfg.Strategy,
		Preset:        e.cfg.Preset,
		Mode:          e.runtime.Mode(),
		ScreenOff:     e.screenOff,
		Suspended:     e.suspended,
		Probing:       e.probing,
		Deep:          e.deep,
		Transport:     e.transport,
		Portal:        e.portal,
		Metered:       e.metered,
		Validated:     e.validated,
		ReachF:        rcxOutcomeName(e.reachF),
		ReachD:        rcxOutcomeName(e.reachD),
		Direct:        e.direct,
		ProbesLeft:    e.budget.Remaining(e.runtime.Now()),
		Candidates:    len(ranked),
		Eligible:      eligible,
		IncidentConns: len(e.incidentConns),
		FrozenNodes:   len(e.downFrozen),
	}
}

// Every decision cycle passes through publish, so this is the one hook that sees
// cold-start picks, holds, and comparisons alike, with the full candidate table.
func (e *rcxEngine) recordDecision(reason rcxReason, ranked []rcxRanked, input rcxDecisionInput) {
	if !e.diag.enabled() {
		return
	}
	now := e.runtime.Now()
	e.diag.push(rcxDiagEntry{
		At:    rcxMillis(now),
		Kind:  rcxDiagDecision,
		Msg:   string(reason),
		Ctx:   e.diagContext(input, ranked),
		Cands: e.candidateReports(ranked, input, now),
	})
}

func (e *rcxEngine) recordSwitch(from, to string, reason rcxReason, now time.Time) {
	if !e.diag.enabled() {
		return
	}
	e.diag.push(rcxDiagEntry{
		At:   rcxMillis(now),
		Kind: rcxDiagSwitch,
		Msg:  string(reason),
		From: from,
		To:   to,
	})
}

func (e *rcxEngine) recordEvent(event rcxEvent) {
	if !e.diag.enabled() {
		return
	}
	e.diag.push(rcxDiagEntry{
		At:   rcxMillis(e.runtime.Now()),
		Kind: rcxDiagEvent,
		Msg:  rcxEventLabel(event),
	})
}

func (e *rcxEngine) recordWave(kind rcxWaveKind, lane string, size int) {
	if !e.diag.enabled() {
		return
	}
	msg := rcxWaveName(kind) + " x" + strconv.Itoa(size)
	if lane != "" {
		msg += " [" + lane + "]"
	}
	e.diag.push(rcxDiagEntry{
		At:   rcxMillis(e.runtime.Now()),
		Kind: rcxDiagProbe,
		Msg:  msg,
	})
}

func (e *rcxEngine) SetDiag(on bool)              { e.diag.setEnabled(on) }
func (e *rcxEngine) DiagEnabled() bool            { return e.diag.enabled() }
func (e *rcxEngine) DiagLog(since uint64) rcxDiagBatch { return e.diag.since(since) }
