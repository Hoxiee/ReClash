package main

import (
	"context"
	"sort"
	"strings"
	"sync"
	"time"

	"github.com/metacubex/mihomo/tunnel/statistic"
)

type rcxMember struct {
	Name        string
	ID          string
	Type        string
	Port        int
	SupportsUDP bool
	HostMs      int
	HostDead    bool
	Order       uint16
}

func (m rcxMember) key() string {
	if m.ID != "" {
		return m.ID
	}
	return m.Name
}

// An aggregate falls when a connection closes, so it cannot show a freeze.
type rcxConnSample struct {
	Key   string
	Node  string
	Host  string
	Up    int64
	Down  int64
	Start time.Time
}

// The hook fires before a single byte, so a sighting keeps the counter to judge.
type rcxOpenSighting struct {
	node string
	at   time.Time
	info *statistic.TrackerInfo
}

// Comparable on purpose: publish diffs it to keep the host from redrawing on
// every tick, so it carries only the summary the hero row needs.
type rcxStatus struct {
	Enabled    bool   `json:"enabled"`
	Preset     string `json:"preset"`
	Strategy   string `json:"strategy"`
	Mode       string `json:"mode"`
	Terrain    string `json:"terrain"`
	Env        string `json:"env"`
	Node       string `json:"node"`
	DelayMs    int    `json:"delay"`
	Reason     string `json:"reason"`
	Searching  bool   `json:"searching"`
	Deep       bool   `json:"deep"`
	Pinned     bool   `json:"pinned"`
	PinNode    string `json:"pinNode"`
	Direct     string `json:"direct"`
	Candidates int    `json:"candidates"`
	Eligible   int    `json:"eligible"`
	SwitchedAt int64  `json:"switchedAt"`
}

type rcxCandidateReport struct {
	Node     string `json:"node"`
	Country  string `json:"country"`
	Origin   string `json:"origin"`
	Verdict  string `json:"verdict"`
	Evidence string `json:"evidence"`
	Block    string `json:"block"`
	DelayMs  int    `json:"delay"`
	HostMs   int    `json:"hostDelay"`
	Band     int    `json:"band"`
	Degraded bool   `json:"degraded"`
	Breaker  bool   `json:"breaker"`
	UDP      bool   `json:"udp"`
	Fails    int    `json:"fails"`
	CoolFor  int    `json:"coolFor"`
	Current  bool   `json:"current"`
}

type rcxSwitchReport struct {
	From   string `json:"from"`
	To     string `json:"to"`
	Reason string `json:"reason"`
	At     int64  `json:"at"`
}

type rcxCanaryReport struct {
	Addr     string `json:"addr"`
	Domestic bool   `json:"domestic"`
	Outcome  string `json:"outcome"`
	DelayMs  int    `json:"delay"`
}

type rcxLinkReport struct {
	Transport string `json:"transport"`
	Validated bool   `json:"validated"`
	Portal    bool   `json:"portal"`
	Metered   bool   `json:"metered"`
	Foreign   string `json:"foreign"`
	Domestic  string `json:"domestic"`
	Since     int64  `json:"since"`
}

// The overview's whole payload, pulled on demand rather than pushed: it is large,
// it changes on every tick, and nobody reads it while the page is closed.
type rcxReport struct {
	Status     rcxStatus            `json:"status"`
	Link       rcxLinkReport        `json:"link"`
	Canaries   []rcxCanaryReport    `json:"canaries"`
	Candidates []rcxCandidateReport `json:"candidates"`
	History    []rcxSwitchReport    `json:"history"`
	Bands      []int                `json:"bands"`
	ProbesLeft int                  `json:"probesLeft"`
	ProbeCap   int                  `json:"probeCap"`
	Manual     bool                 `json:"manual"`
	At         int64                `json:"at"`
}

// The seam that keeps the actor testable: everything touching tunnel locks,
// mmdb, the statistics manager or the host message queue lives behind it.
type rcxRuntime interface {
	Members() []rcxMember
	Selected() string
	Select(node string) error
	SelectedIn(group string) string
	SelectIn(group, node string) error
	Mode() string
	Country(node string) string
	Test(ctx context.Context, node string, marker rcxMarker) (delayMs int, satisfied bool, err error)
	Reach(ctx context.Context, addr string) rcxProbeOutcome
	Connections() []rcxConnSample
	CloseConnections(node string)
	SampleLink() (rcxNetworkPayload, bool)
	Publish(status rcxStatus)
	Now() time.Time
}

type rcxDialEvent struct {
	Node    string
	Failed  bool
	Elapsed time.Duration
	At      time.Time
}

type rcxEventKind uint8

const (
	rcxEventConfigure rcxEventKind = iota
	rcxEventNetwork
	rcxEventConfigApplied
	rcxEventProvidersLoaded
	rcxEventSuspend
	rcxEventManualPick
	rcxEventManualAssert
	rcxEventProbeResults
	rcxEventTerrainReach
	rcxEventSetEnabled
	rcxEventHarvested
	rcxEventDeepScan
)

type rcxEvent struct {
	Kind     rcxEventKind
	Config   rcxConfig
	Payload  rcxNetworkPayload
	Flag     bool
	Node     string
	DelayMs  int
	Results  []rcxProbeResult
	Foreign  rcxProbeOutcome
	Domestic rcxProbeOutcome
	Canaries []rcxCanaryReport
	Gen      uint32
}

const (
	rcxDialQueueSize  = 512
	rcxEventQueueSize = 64
	rcxTickInterval   = 30 * time.Second
	rcxProbeWave      = 20 * time.Second
	rcxDeepProbeWave  = 90 * time.Second
	rcxRescueWave     = 30 * time.Second
	rcxRescueRepeat   = 5 * time.Minute
	rcxPinWaveRetry   = time.Minute
	rcxSweepTimeout   = 5 * time.Second
	rcxSweepParallel  = 6
	rcxCanaryTimeout  = 3 * time.Second
	rcxCanaryRound    = 2 * rcxCanaryTimeout
	rcxProbeBudgetCap = 240
	rcxMaxProofTTL    = 6 * time.Hour
	rcxProbeBudgetWin = time.Hour
	rcxProbeReserve   = 40
	rcxMaintainWidth  = 2
	rcxKeepPerEnv     = 64
	rcxHistoryDepth   = 12

	rcxReachRefresh  = 5 * time.Minute
	rcxReachUrgent   = 30 * time.Second
	rcxTerrainMaxAge = 10 * time.Minute

	rcxConnStallAge    = 10 * time.Second
	rcxOpenSightWindow = time.Minute
	rcxOpenSightCap    = 64

	rcxWakeGrace      = 45 * time.Second
	rcxLinkDark       = 40 * time.Second
	rcxLinkFailQuorum = 2
	// One full canary round plus the slack for its verdict to reach the loop.
	rcxSwitchProbation = rcxCanaryRound + rcxCanaryTimeout
)

type rcxEngine struct {
	runtime rcxRuntime
	ledger  *rcxLedger
	store   *rcxStore
	budget  *rcxProbeBudget

	dials   chan rcxDialEvent
	events  chan rcxEvent
	control *rcxControl
	wake    chan struct{}
	quit    chan struct{}
	done    chan struct{}

	// Guards only what other goroutines read: the enabled flag on the hot dial
	// path, the published status, the host's report, the markers and sightings.
	mu        sync.RWMutex
	enabled   bool
	status    rcxStatus
	report    rcxReport
	openHosts map[string]struct{}
	openSeen  map[string]rcxOpenSighting

	snapshot   *rcxSnapshot
	cfg        rcxConfig
	terrain    rcxTerrainState
	envKey     string
	transport  string
	metered    bool
	validated  bool
	portal     bool
	reachF     rcxProbeOutcome
	reachD     rcxProbeOutcome
	canaries   []rcxCanaryReport
	incumbent  string
	since      time.Time
	switchedAt time.Time
	suspendAt  time.Time
	suspendTo  time.Time
	conns      map[string]int64
	keys       map[string]string
	names      map[string]string
	direct     string
	history    []rcxSwitchReport
	probing    bool
	deep       bool
	paidWave   int
	reaching   bool
	started    bool
	rescueAt   time.Time
	rescueMark rcxRescueStamp

	reachGen     uint32
	probeGen     uint32
	reachAgain   bool
	lastReachAt  time.Time
	pendingGrant bool
	pinWaveAt    time.Time
	hostLinked   bool
	wantPick     string
	downFrozen   map[string]time.Time
	charged      map[string]int
	chargedAt    time.Time
}

func newRcxEngine(runtime rcxRuntime) *rcxEngine {
	return &rcxEngine{
		runtime:    runtime,
		ledger:     newRcxLedger(rcxDefaultLedgerPolicy()),
		store:      newRcxStore(),
		budget:     newRcxProbeBudget(rcxProbeBudgetCap, rcxProbeBudgetWin),
		cfg:        rcxDefaultConfig(),
		dials:      make(chan rcxDialEvent, rcxDialQueueSize),
		events:     make(chan rcxEvent, rcxEventQueueSize),
		control:    newRcxControl(),
		wake:       make(chan struct{}, 1),
		downFrozen: map[string]time.Time{},
		openSeen:   map[string]rcxOpenSighting{},
		charged:    map[string]int{},
	}
}

// NoteDial runs on the dial path under configMux.RLock, so it must never take a
// core lock: a synchronous selector write here would deadlock against match().
func (e *rcxEngine) NoteDial(node string, failed bool, elapsed time.Duration, now time.Time) {
	if !e.Enabled() {
		return
	}
	select {
	case e.dials <- rcxDialEvent{
		Node:    node,
		Failed:  failed,
		Elapsed: elapsed,
		At:      now,
	}:
	default:
		return
	}
	select {
	case e.wake <- struct{}{}:
	default:
	}
}

// Runs on the notify path, so it must be cheap, lock-bounded and failure-free.
func (e *rcxEngine) NoteTracker(tracker statistic.Tracker) {
	if !e.Enabled() {
		return
	}
	info := tracker.Info()
	if info == nil || info.Metadata == nil {
		return
	}
	node := info.Chain.Last()
	if node == "" || node == "DIRECT" || !e.isMember(node) {
		return
	}
	key := tracker.ID()
	if key == "" {
		return
	}
	at := e.runtime.Now()
	e.mu.Lock()
	defer e.mu.Unlock()
	if len(e.openSeen) >= rcxOpenSightCap ||
		!rcxMarkerRelated(e.openHosts, info.Metadata.Host) {
		return
	}
	e.openSeen[key] = rcxOpenSighting{node: node, at: at, info: info}
}

func rcxMarkerRelated(markers map[string]struct{}, host string) bool {
	if host == "" {
		return false
	}
	for marker := range markers {
		if rcxHostRelated(host, marker) {
			return true
		}
	}
	return false
}

func rcxHostRelated(host, marker string) bool {
	return host == marker ||
		strings.HasSuffix(host, "."+marker) ||
		strings.HasSuffix(marker, "."+host)
}

func (e *rcxEngine) Enabled() bool {
	e.mu.RLock()
	defer e.mu.RUnlock()
	return e.enabled
}

func (e *rcxEngine) Status() rcxStatus {
	e.mu.RLock()
	defer e.mu.RUnlock()
	return e.status
}

func (e *rcxEngine) Report() rcxReport {
	e.mu.RLock()
	defer e.mu.RUnlock()
	return e.report
}

func (e *rcxEngine) Start() {
	if e.started {
		return
	}
	e.started = true
	e.quit = make(chan struct{})
	e.done = make(chan struct{})
	e.snapshot = e.store.Load()
	e.ledger.Import(e.snapshot.Global, e.snapshot.Envs)
	e.applyConfigLocked(e.snapshot.Config)
	e.sampleLink()
	safeGoDetached("rcx engine", e.loop)
}

func (e *rcxEngine) Stop() {
	if !e.started {
		return
	}
	e.started = false
	close(e.quit)
	<-e.done
}

func (e *rcxEngine) send(event rcxEvent) {
	select {
	case e.events <- event:
	default:
	}
}

// Dropped under queue pressure, a wave stays in flight for the whole session.
func (e *rcxEngine) sendResult(event rcxEvent, quit <-chan struct{}) {
	select {
	case e.events <- event:
	case <-quit:
	}
}

func (e *rcxEngine) Configure(config rcxConfig) { e.control.Configure(config) }
func (e *rcxEngine) Network(payload rcxNetworkPayload) {
	e.control.Network(payload)
}
func (e *rcxEngine) OnConfigApplied()   { e.send(rcxEvent{Kind: rcxEventConfigApplied}) }
func (e *rcxEngine) OnProvidersLoaded() { e.send(rcxEvent{Kind: rcxEventProvidersLoaded}) }
func (e *rcxEngine) OnSuspend(suspended bool) {
	e.control.Suspend(suspended)
}
func (e *rcxEngine) SetEnabled(enabled bool) { e.control.SetEnabled(enabled) }
func (e *rcxEngine) NoteHarvestedProbe(url, node string, delayMs int) {
	if !e.Enabled() || url != currentTestURL() {
		return
	}
	e.send(rcxEvent{Kind: rcxEventHarvested, Node: node, DelayMs: delayMs})
}

// The host's changeProxy already wrote the selector: the engine only pins.
func (e *rcxEngine) OnManualAsserted(node string) {
	e.control.Pick(rcxEvent{Kind: rcxEventManualAssert, Node: node})
}
func (e *rcxEngine) DeepScan() { e.control.DeepScan() }

func (e *rcxEngine) loop() {
	defer close(e.done)
	ticker := time.NewTicker(rcxTickInterval)
	defer ticker.Stop()

	for {
		select {
		case <-e.quit:
			e.drainDials()
			e.persist(true)
			return
		case <-e.control.wake:
			e.drainControl()
		case event := <-e.events:
			e.handle(event)
		case <-e.wake:
			e.drainDials()
			e.reconsider()
		case <-ticker.C:
			e.drainDials()
			e.sampleLink()
			e.sampleTraffic()
			e.maybeRefreshTerrain()
			e.reconsider()
			e.maintain()
			e.persist(false)
		}
	}
}

func (e *rcxEngine) drainControl() {
	for _, event := range e.control.take() {
		e.handle(event)
	}
}

func (e *rcxEngine) handle(event rcxEvent) {
	switch event.Kind {
	case rcxEventConfigure:
		e.applyConfigLocked(event.Config)
		e.reconsider()
		e.persist(true)
	case rcxEventNetwork:
		e.hostLinked = true
		e.applyNetwork(event.Payload)
	case rcxEventConfigApplied, rcxEventProvidersLoaded:
		e.reconsider()
	case rcxEventSuspend:
		e.applySuspend(event.Flag)
	case rcxEventSetEnabled:
		config := e.cfg
		config.Enabled = event.Flag
		e.applyConfigLocked(config)
		e.reconsider()
		e.persist(true)
	case rcxEventHarvested:
		now := e.runtime.Now()
		negative := event.DelayMs <= 0
		e.ensureIdentity()
		if !e.isMember(event.Node) || (negative && !e.chargesNegative(now)) {
			break
		}
		e.ledger.NoteHarvestedProbe(e.key(event.Node), e.envKey, event.DelayMs, now)
		if negative {
			e.escrowNegative(event.Node, 0, now)
			break
		}
		if !rcxImplausibleDelay(event.DelayMs) {
			e.noteLinkAlive(now)
		}
	case rcxEventManualPick:
		e.applyManualPick(event.Node, true)
	case rcxEventManualAssert:
		e.applyManualPick(event.Node, false)
	case rcxEventDeepScan:
		e.startDeepScan()
	case rcxEventProbeResults:
		if event.Gen != e.probeGen {
			break
		}
		e.probing = false
		e.deep = false
		now := e.runtime.Now()
		answered := false
		measured := map[string]struct{}{}
		for _, result := range event.Results {
			negative := result.Outcome == rcxProbeFail || result.Outcome == rcxProbeStatusMismatch
			if negative && !e.chargesNegative(now) {
				continue
			}
			e.ledger.NoteProbe(e.key(result.Node), e.envKey, result.Role, result.Outcome, result.DelayMs, now)
			if result.Outcome != rcxProbeOverloaded {
				measured[result.Node] = struct{}{}
			}
			if negative {
				e.escrowNegative(result.Node, 0, now)
				continue
			}
			answered = answered || result.Outcome == rcxProbeOK
		}
		e.budget.Refund(e.paidWave - len(measured))
		e.paidWave = 0
		// A wave that got an answer proves the link, so its failures are the nodes'.
		if answered {
			e.noteLinkAlive(now)
			e.rescueAt = time.Time{}
		}
		e.reconsider()
		e.persist(false)
	case rcxEventTerrainReach:
		e.reaching = false
		if event.Gen == e.reachGen {
			e.reachF, e.reachD = event.Foreign, event.Domestic
			e.canaries = event.Canaries
			e.lastReachAt = e.runtime.Now()
			if e.reachF == rcxProbeOK || e.reachD == rcxProbeOK {
				e.noteLinkAlive(e.lastReachAt)
			}
			e.classifyTerrain(true)
			e.reconsider()
		}
		if e.reachAgain {
			e.reachAgain = false
			e.startReach()
		}
	}
}

func (e *rcxEngine) applyConfigLocked(config rcxConfig) {
	// The host does not carry this: shipped defaults are the core's to migrate.
	config.DefaultsVersion = rcxDefaultsVersion
	config = config.normalized()
	// A toggle must not refill the probe budget, or it becomes a way to farm one.
	if config.Preset != e.cfg.Preset {
		e.budget = newRcxProbeBudget(rcxProbeBudgetCap, rcxProbeBudgetWin)
	}
	// Enabling starts from measurements: one full wave rides outside the cap.
	if config.operable() && (!e.cfg.operable() || config.Strategy != e.cfg.Strategy) {
		e.pendingGrant = true
	}
	e.cfg = config
	e.mu.Lock()
	e.enabled = config.operable()
	e.openHosts = rcxMarkerHosts(config.OpenMarkers)
	e.mu.Unlock()
	if e.snapshot != nil {
		e.snapshot.Config = config
	}
}

func rcxMarkerHosts(markers []rcxMarker) map[string]struct{} {
	if len(markers) == 0 {
		return nil
	}
	hosts := make(map[string]struct{}, len(markers))
	for _, marker := range markers {
		if at := strings.Index(marker.URL, "://"); at >= 0 {
			if host := marker.URL[at+3:]; host != "" {
				if slash := strings.IndexAny(host, "/?#"); slash >= 0 {
					host = host[:slash]
				}
				if host != "" {
					hosts[host] = struct{}{}
				}
			}
		}
	}
	return hosts
}

// A handoff re-arms the canaries, so re-applying one link would re-probe it.
func (e *rcxEngine) sampleLink() {
	if e.hostLinked {
		return
	}
	payload, ok := e.runtime.SampleLink()
	if !ok {
		return
	}
	if primary, _ := rcxEnvKeys(payload); primary == e.envKey {
		return
	}
	e.applyNetwork(payload)
}

func (e *rcxEngine) applyNetwork(payload rcxNetworkPayload) {
	if !rcxPayloadIdentifies(payload) {
		return
	}
	primary, secondary := rcxEnvKeys(payload)
	e.transport = payload.Transport
	e.metered = payload.Metered
	e.validated = payload.Validated
	e.portal = payload.CaptivePortal
	e.terrain.noteValidation(payload.Validated, e.runtime.Now())

	if primary != e.envKey {
		e.rollbackEscrow()
		e.envKey = primary
		e.ledger.Migrate(secondary, primary)
		e.migratePick(secondary, primary)
		e.supersedeProbe()
		e.reachF, e.reachD = rcxProbeOverloaded, rcxProbeOverloaded
		e.incumbent = ""
		e.since = time.Time{}
		e.wantPick = e.snapshot.Picks[primary]
		if pin, ok := e.snapshot.Pins[primary]; ok {
			e.wantPick = pin
		}
	}
	e.classifyTerrain(false)
	e.supersedeReach()
	e.startReach()
	e.reconsider()
}

// A round in flight was bought by the previous link: the new one cannot use it.
func (e *rcxEngine) supersedeReach() {
	e.reachGen++
	if e.reaching {
		e.reachAgain = true
	}
}

// The dials really ran, so the charge stands; only the verdicts go stale.
func (e *rcxEngine) supersedeProbe() {
	e.probeGen++
	e.probing = false
	e.deep = false
}

func (e *rcxEngine) migratePick(from, to string) {
	if from == to {
		return
	}
	if _, ok := e.snapshot.Picks[to]; ok {
		return
	}
	if pick, ok := e.snapshot.Picks[from]; ok {
		e.snapshot.Picks[to] = pick
		delete(e.snapshot.Picks, from)
	}
}

func (e *rcxEngine) classifyTerrain(measured bool) {
	now := e.runtime.Now()
	if e.terrain.portalExpired(now) {
		e.portal = false
	}
	terrain := rcxClassifyTerrain(rcxTerrainFacts{
		Validated:      e.validated,
		CaptivePortal:  e.portal,
		UnvalidatedFor: e.terrain.unvalidatedFor(now),
		ForeignReach:   e.reachF,
		DomesticReach:  e.reachD,
	})
	terrain = e.terrain.settle(terrain, measured)
	if terrain == rcxTerrainOffline {
		e.rollbackEscrow()
	}
	if !e.terrain.observe(terrain, now) {
		return
	}
	if terrain == rcxTerrainNormal {
		e.ledger.PromoteTerrainNormal(e.envKey)
	}
	if e.envKey != "" {
		e.snapshot.Regimes[e.envKey] = rcxRegimeMemory{Terrain: terrain, At: now}
	}
}

func (e *rcxEngine) applySuspend(suspended bool) {
	now := e.runtime.Now()
	if suspended {
		e.suspendAt = now
		e.suspendTo = now
		e.persist(true)
		return
	}
	e.suspendTo = now
	// Nothing measured while the device was frozen says anything about a node,
	// and the incumbent is the only one worth a probe on the way back.
	e.reachF, e.reachD = rcxProbeOverloaded, rcxProbeOverloaded
	e.supersedeReach()
	e.startReach()
	e.reconsider()
}

// A pick pins across a death and earns its return with a measurement; off, it hints.
func (e *rcxEngine) applyManualPick(node string, withSelect bool) {
	if node == "" {
		delete(e.snapshot.Pins, e.envKey)
		// The host already cleared the selector, so a hold would keep member zero.
		if e.incumbent != "" {
			_ = e.runtime.Select(e.incumbent)
		}
		e.reconsider()
		return
	}
	if withSelect {
		if err := e.runtime.Select(node); err != nil {
			return
		}
	}
	e.incumbent = node
	e.since = e.runtime.Now()
	e.ensureIdentity()
	e.snapshot.Picks[e.envKey] = e.key(node)
	if e.cfg.RespectPick {
		e.snapshot.Pins[e.envKey] = e.key(node)
	} else {
		delete(e.snapshot.Pins, e.envKey)
	}
	e.reconsider()
}

// Evidence is only worth keeping while rules decide the route and only about
// nodes the skeleton actually offers: DIRECT and canary dials go through the same
// hook.
func (e *rcxEngine) drainDials() {
	now := e.runtime.Now()
	terrain := e.terrainCurrent()
	keep := e.runtime.Mode() == "rule"
	if keep {
		e.ensureIdentity()
	}
	answered := false
drain:
	for {
		select {
		case event := <-e.dials:
			if !keep || !e.isMember(event.Node) {
				continue
			}
			at := event.At
			if at.IsZero() {
				at = now
			}
			if event.Failed {
				if !e.chargesNegative(at) {
					continue
				}
				if e.ledger.NoteDialFailure(e.key(event.Node), e.envKey, terrain, at) {
					e.escrowNegative(event.Node, 1, at)
				}
				continue
			}
			if e.ledger.NoteDialSuccess(e.key(event.Node), e.envKey, event.Elapsed, at) {
				answered = true
			}
		default:
			break drain
		}
	}
	if answered {
		e.noteLinkAlive(now)
	}
}

type rcxNodeFlow struct {
	live     int
	stalled  int
	progress bool
	open     bool
}

// Only what comes back proves transit: a black hole absorbs upload unacknowledged.
func (e *rcxEngine) sampleTraffic() {
	now := e.runtime.Now()
	conns := e.runtime.Connections()
	previous := e.conns
	e.conns = make(map[string]int64, len(conns))
	e.mu.RLock()
	markers := e.openHosts
	e.mu.RUnlock()
	flows := make(map[string]*rcxNodeFlow, len(conns))
	alive := false
	for _, conn := range conns {
		answered := conn.Down > previous[conn.Key]
		alive = alive || answered
		e.conns[conn.Key] = conn.Down
		if conn.Node == "" || conn.Node == "DIRECT" {
			continue
		}
		flow := flows[conn.Node]
		if flow == nil {
			flow = &rcxNodeFlow{}
			flows[conn.Node] = flow
		}
		flow.live++
		switch {
		case answered:
			flow.progress = true
			flow.open = flow.open || rcxMarkerRelated(markers, conn.Host)
		// Answered once means idle, not starved: only payload never answered accuses.
		case conn.Down == 0 && conn.Up > 0 && now.Sub(conn.Start) >= rcxConnStallAge:
			flow.stalled++
		}
	}
	if alive {
		e.noteLinkAlive(now)
	}
	for node, flow := range flows {
		switch {
		case flow.progress:
			e.notePayload(node, flow.open, now)
		case flow.stalled*2 > flow.live:
			e.trackFrozenPayload(node, now)
		default:
			delete(e.downFrozen, e.key(node))
		}
	}
	active := make(map[string]struct{}, len(flows))
	for node := range flows {
		active[e.key(node)] = struct{}{}
	}
	for key := range e.downFrozen {
		if _, ok := active[key]; !ok {
			delete(e.downFrozen, key)
		}
	}
	e.harvestOpenSightings(now)
}

// Muted only where nothing is measurable: a woken radio, a link measured dead.
func (e *rcxEngine) chargesNegative(now time.Time) bool {
	if !e.suspendTo.IsZero() && now.Sub(e.suspendTo) < rcxWakeGrace {
		return false
	}
	return e.terrain.terrain != rcxTerrainOffline
}

// The weight is what the fact added to the streak, so a refund gives that back.
func (e *rcxEngine) escrowNegative(node string, weight int, now time.Time) {
	if len(e.charged) == 0 {
		e.chargedAt = now
	}
	e.charged[e.key(node)] += weight
	if len(e.charged) >= e.escrowQuorum() {
		e.startReach()
	}
}

// A dead uplink shows on the one node carrying traffic, so a pair never fires.
func (e *rcxEngine) escrowQuorum() int {
	if e.incumbent != "" {
		if _, ok := e.charged[e.key(e.incumbent)]; ok {
			return 1
		}
	}
	return rcxLinkFailQuorum
}

func (e *rcxEngine) noteLinkAlive(now time.Time) {
	if len(e.charged) == 0 {
		return
	}
	if len(e.charged) >= e.escrowQuorum() && now.Sub(e.chargedAt) >= rcxLinkDark {
		e.ledger.RollbackFailures(e.envKey, e.charged)
	}
	e.charged = map[string]int{}
	e.chargedAt = time.Time{}
}

// The answer that ends an escrow may never come; a settled dark verdict stands.
func (e *rcxEngine) rollbackEscrow() {
	if len(e.charged) == 0 {
		return
	}
	e.ledger.RollbackFailures(e.envKey, e.charged)
	e.charged = map[string]int{}
	e.chargedAt = time.Time{}
}

func (e *rcxEngine) notePayload(node string, openWorld bool, now time.Time) {
	key := e.key(node)
	delete(e.downFrozen, key)
	e.ledger.NoteTrafficProgress(key, e.envKey, openWorld, now)
	e.ledger.ClearDegraded(key, e.envKey)
}

func (e *rcxEngine) trackFrozenPayload(node string, now time.Time) {
	if !e.chargesNegative(now) {
		return
	}
	key := e.key(node)
	if now.Before(e.ledger.CoolUntil(key, e.envKey, now)) {
		return
	}
	if e.runtime.Mode() != "rule" || e.runtime.Members() == nil {
		return
	}
	if e.ledger.ProgressAt(key, e.envKey).IsZero() && len(e.ledger.Samples(key, e.envKey)) > 0 {
		return
	}
	frozen := e.downFrozen[key]
	if frozen.IsZero() {
		e.downFrozen[key] = now
		return
	}
	if now.Sub(frozen) < time.Duration(e.cfg.DegradeConfirmSeconds)*time.Second {
		return
	}
	e.ledger.NoteDegraded(key, e.envKey, now)
	e.escrowNegative(node, 0, now)
	if node == e.incumbent {
		e.ledger.NoteIncumbentStalled(key, e.envKey, now)
	}
}

// Progress beside a sighting is a coincidence: only marker bytes prove it.
func (e *rcxEngine) harvestOpenSightings(now time.Time) {
	answered := make([]string, 0, 2)
	e.mu.Lock()
	for key, sighting := range e.openSeen {
		down := sighting.info.DownloadTotal.Load()
		if down <= 0 && now.Sub(sighting.at) < rcxOpenSightWindow {
			continue
		}
		delete(e.openSeen, key)
		if down > 0 {
			answered = append(answered, sighting.node)
		}
	}
	e.mu.Unlock()
	for _, node := range answered {
		e.notePayload(node, true, now)
	}
}

func (e *rcxEngine) maybeRefreshTerrain() {
	now := e.runtime.Now()
	if e.lastReachAt.IsZero() {
		e.startReach()
		return
	}
	if now.Sub(e.lastReachAt) >= e.reachInterval() {
		e.startReach()
	}
}

// The pair of rounds that confirms a whitelist must not be five minutes apart.
func (e *rcxEngine) reachInterval() time.Duration {
	if e.terrain.terrain == rcxTerrainNormal {
		return rcxReachRefresh
	}
	return rcxReachUrgent
}

// A stale terrain says nothing: unknown keeps the last-resort rows honest.
func (e *rcxEngine) terrainCurrent() rcxTerrain {
	if e.lastReachAt.IsZero() {
		return e.terrain.terrain
	}
	if e.runtime.Now().Sub(e.lastReachAt) > rcxTerrainMaxAge {
		return rcxTerrainUnknown
	}
	return e.terrain.terrain
}

// Geography is a prior and nothing else: a node whose address resolves inside the
// censoring country still earns its verdict from behaviour.
func (e *rcxEngine) originOf(node string) (string, rcxOrigin) {
	code := e.runtime.Country(node)
	if code == "" {
		return "", rcxOriginUnknown
	}
	if e.cfg.censors(code) {
		return code, rcxOriginDomestic
	}
	return code, rcxOriginForeign
}

func (e *rcxEngine) isMember(node string) bool {
	e.mu.RLock()
	defer e.mu.RUnlock()
	if e.keys == nil {
		return true
	}
	_, ok := e.keys[node]
	return ok
}

func (e *rcxEngine) key(node string) string {
	e.mu.RLock()
	defer e.mu.RUnlock()
	if key, ok := e.keys[node]; ok {
		return key
	}
	return node
}

func (e *rcxEngine) nameOf(key string) string {
	e.mu.RLock()
	defer e.mu.RUnlock()
	if name, ok := e.names[key]; ok {
		return name
	}
	// A snapshot older than endpoint identity, or a collision, stores the name.
	if _, ok := e.keys[key]; ok {
		return key
	}
	return ""
}

// The pick is an endpoint, the selector speaks names, and a refresh renames it.
func (e *rcxEngine) pin() string {
	if e.snapshot == nil {
		return ""
	}
	return e.nameOf(e.snapshot.Pins[e.envKey])
}

func (e *rcxEngine) resolvePick() {
	if e.wantPick == "" {
		return
	}
	name := e.nameOf(e.wantPick)
	e.wantPick = ""
	if name != "" {
		e.incumbent = name
	}
}

// A record written under a name before the park is read is never found again.
func (e *rcxEngine) ensureIdentity() {
	e.mu.RLock()
	known := e.keys != nil
	e.mu.RUnlock()
	if !known {
		e.syncIdentity(e.runtime.Members())
	}
}

func (e *rcxEngine) orderOf(key string, declared uint16) uint16 {
	if e.snapshot == nil || e.snapshot.Seed == 0 {
		return declared
	}
	return rcxOrderOf(e.snapshot.Seed, key)
}

func (e *rcxEngine) syncIdentity(members []rcxMember) {
	keys := make(map[string]string, len(members))
	names := make(map[string]string, len(members))
	for _, member := range members {
		keys[member.Name] = member.key()
		names[member.key()] = member.Name
	}
	e.mu.Lock()
	e.keys = keys
	e.names = names
	e.mu.Unlock()
}

func (e *rcxEngine) candidates(members []rcxMember) []rcxCandidate {
	now := e.runtime.Now()
	e.syncIdentity(members)
	live := time.Duration(rcxLiveWindowSeconds) * time.Second
	fresh := time.Duration(rcxFreshWindowSeconds) * time.Second
	proofTTL := rcxScaledProofTTL(e.ledger.ProofTTL(), len(members))
	candidates := make([]rcxCandidate, 0, len(members))
	for _, member := range members {
		key := member.key()
		if e.ledger.Origin(key) == rcxOriginUnknown {
			country, origin := e.originOf(member.Name)
			e.ledger.SetOrigin(key, country, origin)
		}
		facts := e.ledger.Facts(key, e.envKey, member.SupportsUDP, now, proofTTL)
		facts.Breaker = e.cfg.breaker(member.Name)
		candidates = append(candidates, rcxCandidate{
			Name:       member.Name,
			Order:      e.orderOf(key, member.Order),
			Facts:      facts,
			Evidence:   e.ledger.Evidence(key, e.envKey, now, live, fresh),
			MedianMs:   e.ledger.MedianMs(key, e.envKey, now, e.suspendAt, e.suspendTo),
			HostMs:     member.HostMs,
			HostDead:   member.HostDead,
			CoolUntil:  e.ledger.CoolUntil(key, e.envKey, now),
			InSkeleton: true,
			Degraded:   e.ledger.Degraded(key, e.envKey, now),
		})
	}
	return candidates
}

// At 240 probes an hour a 250-node park cannot revisit a node inside half an
// hour, so a fixed TTL there expires every proof the engine owns.
func rcxScaledProofTTL(base time.Duration, park int) time.Duration {
	if park <= 0 {
		return base
	}
	scaled := time.Duration(park) * rcxProbeBudgetWin / rcxProbeBudgetCap
	if scaled < base {
		return base
	}
	if scaled > rcxMaxProofTTL {
		return rcxMaxProofTTL
	}
	return scaled
}

func (e *rcxEngine) reconsider() {
	if !e.Enabled() {
		e.publish(rcxReasonHold, nil, rcxDecisionInput{})
		return
	}
	if mode := e.runtime.Mode(); mode != "rule" {
		e.publish(rcxReasonHold, nil, rcxDecisionInput{})
		return
	}

	members := e.runtime.Members()
	if len(members) == 0 {
		e.publish(rcxReasonNoCandidate, nil, rcxDecisionInput{})
		return
	}

	now := e.runtime.Now()
	if e.incumbent == "" {
		e.incumbent = e.runtime.Selected()
	}

	terrain := e.terrainCurrent()
	e.applyDirectSplit()

	candidates := e.candidates(members)
	e.resolvePick()
	pin := e.pin()
	input := rcxDecisionInput{
		Terrain:        terrain,
		Incumbent:      e.incumbent,
		IncumbentSince: e.since,
		Pin:            pin,
		Candidates:     candidates,
		Policy:         e.cfg.policy(),
		Now:            now,
	}
	decision := rcxDecide(input)

	if decision.Reason == rcxReasonIncumbentDead && e.ledger.Stalled(e.key(e.incumbent), e.envKey) {
		decision.Reason = rcxReasonDegraded
	}

	// The measurement that settles a suspicion must precede the switch it buys.
	if decision.Switch && e.awaitsMeasurement(input) {
		e.startProbe(candidates, members, rcxWaveRoutine)
		if e.probing {
			decision.Switch = false
			decision.Reason = rcxReasonMeasuring
		}
	}

	if decision.Switch && decision.Reason == rcxReasonPinReturn && !rcxPinProven(input) {
		if !e.probing && (e.pinWaveAt.IsZero() || now.Sub(e.pinWaveAt) >= rcxPinWaveRetry) {
			e.pinWaveAt = now
			e.startProbe(candidates, members, rcxWaveRoutine)
		}
		decision.Switch = false
		decision.To = ""
		decision.Reason = rcxReasonHold
		if e.probing {
			decision.Reason = rcxReasonMeasuring
		}
	}

	if decision.Switch && e.holdsForLink(decision.Reason, now) {
		decision.Switch = false
		decision.Reason = rcxReasonMeasuring
	}

	if decision.Switch && decision.To != e.incumbent {
		from := e.incumbent
		if err := e.runtime.Select(decision.To); err == nil {
			if rcxDeathSwitch(decision.Reason) {
				e.runtime.CloseConnections(from)
			}
			e.noteSwitch(from, decision.To, decision.Reason, now)
			input.Incumbent = decision.To
			input.IncumbentSince = now
		}
	} else if !decision.Switch && decision.To == "" && decision.Reason == rcxReasonHold {
		e.reassertIncumbent()
	}

	if e.pendingGrant && !e.probing {
		e.pendingGrant = false
		e.startProbe(candidates, members, rcxWaveGrant)
	} else if e.needsProbe(decision, candidates) {
		kind := rcxWaveRoutine
		if decision.Reason == rcxReasonStranded || decision.Reason == rcxReasonNoCandidate {
			kind = rcxWaveRescue
		}
		e.startProbe(candidates, members, kind)
	}
	e.publish(decision.Reason, rcxRank(input), input)
}

// A domestic canary that answers proves the direct path lives, while a home
// service through a foreign egress breaks: they tunnel only when it dies.
func (e *rcxEngine) applyDirectSplit() {
	if !e.Enabled() {
		return
	}
	want := "DIRECT"
	if e.reachD == rcxProbeFail {
		want = rcxGroupNode
	}
	got := e.runtime.SelectedIn(rcxGroupDirect)
	if got == want {
		e.setDirectState(want)
		return
	}
	if err := e.runtime.SelectIn(rcxGroupDirect, want); err == nil {
		e.setDirectState(want)
	}
}

func (e *rcxEngine) setDirectState(selected string) {
	if selected == rcxGroupNode {
		e.direct = "node"
	} else {
		e.direct = "direct"
	}
}

// Mihomo rebuilds a selector at index 0, so even a hold must re-assert it.
func (e *rcxEngine) reassertIncumbent() {
	if e.incumbent == "" {
		return
	}
	if e.runtime.Selected() != e.incumbent {
		_ = e.runtime.Select(e.incumbent)
	}
}

// Connections on a buried node are already hung: closing lets the app redial.
func rcxDeathSwitch(reason rcxReason) bool {
	return reason == rcxReasonIncumbentDead || reason == rcxReasonDegraded
}

func (e *rcxEngine) noteSwitch(from, to string, reason rcxReason, now time.Time) {
	e.incumbent = to
	e.since = now
	e.switchedAt = now
	// The pin died with the node; its successor must not inherit it.
	e.snapshot.Picks[e.envKey] = e.key(to)
	e.snapshot.Dirty = true
	e.history = append(e.history, rcxSwitchReport{
		From:   from,
		To:     to,
		Reason: string(reason),
		At:     rcxMillis(now),
	})
	if len(e.history) > rcxHistoryDepth {
		e.history = e.history[len(e.history)-rcxHistoryDepth:]
	}
}

// Five switches in five seconds are one dark uplink misread five times: the round
// in flight tells a dead node from a dead link, so the second switch waits for it.
func (e *rcxEngine) holdsForLink(reason rcxReason, now time.Time) bool {
	if !e.reaching || e.since.IsZero() {
		return false
	}
	if reason == rcxReasonPinReturn || reason == rcxReasonColdStart {
		return false
	}
	return now.Sub(e.since) < rcxSwitchProbation
}

func (e *rcxEngine) awaitsMeasurement(in rcxDecisionInput) bool {
	if !e.suspected(in.Now) {
		return false
	}
	for _, candidate := range in.Candidates {
		if candidate.Name != e.incumbent {
			continue
		}
		return rcxEligible(candidate, in)
	}
	return false
}

// An incumbent is disproven by the traffic it carries; a pin carries none, so
// only a measurement tells a recovery from a cooldown that merely expired.
func rcxPinProven(in rcxDecisionInput) bool {
	for _, candidate := range in.Candidates {
		if candidate.Name == in.Pin {
			return candidate.Facts.Transit == rcxProofProven
		}
	}
	return false
}

func (e *rcxEngine) suspected(now time.Time) bool {
	return e.incumbent != "" &&
		(e.ledger.Stalled(e.key(e.incumbent), e.envKey) ||
			e.ledger.Degraded(e.key(e.incumbent), e.envKey, now))
}

// Probes are bought, never scheduled: a decision that had nothing to go on, or
// one that could not route at all, is the only thing worth paying for.
func (e *rcxEngine) needsProbe(decision rcxDecision, candidates []rcxCandidate) bool {
	if e.probing {
		return false
	}
	switch decision.Reason {
	case rcxReasonNoCandidate, rcxReasonStranded, rcxReasonIncumbentDead,
		rcxReasonColdStart, rcxReasonDegraded:
		return true
	}
	// Holding a frozen incumbent is only correct while its probe is on the way.
	if e.incumbent != "" && e.ledger.Stalled(e.key(e.incumbent), e.envKey) {
		return true
	}
	for _, candidate := range candidates {
		if candidate.Name == e.incumbent {
			return candidate.Evidence == rcxEvidenceNone
		}
	}
	return e.incumbent == ""
}

// A rescue and a hand-asked sweep answer what the user sees, outside the cap.
type rcxWaveKind uint8

const (
	rcxWaveRoutine rcxWaveKind = iota
	rcxWaveMaintain
	rcxWaveGrant
	rcxWaveRescue
	rcxWaveDeep
)

// A trickle is a rate, so it hangs off the tick: one tick reconsiders often.
func (e *rcxEngine) maintain() {
	if !e.Enabled() || e.probing || e.runtime.Mode() != "rule" {
		return
	}
	members := e.runtime.Members()
	if len(members) == 0 {
		return
	}
	e.startProbe(e.candidates(members), members, rcxWaveMaintain)
}

func (e *rcxEngine) startDeepScan() {
	if !e.Enabled() || e.probing || e.runtime.Mode() != "rule" {
		return
	}
	members := e.runtime.Members()
	if len(members) == 0 {
		return
	}
	e.deep = true
	e.startProbe(e.candidates(members), members, rcxWaveDeep)
	e.reconsider()
}

func (e *rcxEngine) planWave(
	candidates []rcxCandidate,
	members []rcxMember,
	kind rcxWaveKind,
) []rcxProbeNode {
	if len(e.cfg.OpenMarkers) == 0 {
		return nil
	}
	// A link both canary groups measured dead earns no wave the user did not ask.
	if kind != rcxWaveDeep && e.terrain.terrain == rcxTerrainOffline {
		return nil
	}
	now := e.runtime.Now()

	byName := make(map[string]rcxCandidate, len(candidates))
	for _, candidate := range candidates {
		byName[candidate.Name] = candidate
	}
	suspect := ""
	if e.suspected(now) {
		suspect = e.incumbent
	}
	pool := make([]rcxProbeNode, 0, len(members))
	stamps := make(map[string]time.Time, len(members))
	for _, member := range members {
		candidate := byName[member.Name]
		// Bytes moving prove transit, not that the admission proof is inside its TTL.
		if kind == rcxWaveMaintain {
			if !e.proofDue(member.Name, now) {
				continue
			}
		} else if kind != rcxWaveDeep && member.Name != suspect &&
			candidate.Evidence == rcxEvidenceLiveTraffic {
			continue
		}
		// Every other kind looks for anything that answers, and a backoff is a guess.
		if kind == rcxWaveRoutine || kind == rcxWaveMaintain {
			if !candidate.CoolUntil.IsZero() && now.Before(candidate.CoolUntil) {
				continue
			}
		}
		stamps[member.Name] = e.ledger.ProbeAt(member.key(), e.envKey)
		pool = append(pool, rcxProbeNode{
			Name: member.Name,
			Key:  member.key(),
			Type: member.Type,
			Port: member.Port,
		})
	}
	// Least recently measured first, or every wave re-measures the same head.
	sort.SliceStable(pool, func(i, j int) bool {
		return stamps[pool[i].Name].Before(stamps[pool[j].Name])
	})
	// Diversity alone would spend a wave on neighbours of the node under suspicion.
	if suspect != "" {
		rcxHoistNode(pool, suspect)
	}
	if pin := e.pin(); pin != "" && pin != e.incumbent {
		if candidate, ok := byName[pin]; ok && candidate.Facts.Transit != rcxProofProven {
			rcxHoistNode(pool, pin)
		}
	}

	if kind == rcxWaveMaintain {
		rcxHoistNode(pool, e.incumbent)
		if len(pool) > rcxMaintainWidth {
			pool = pool[:rcxMaintainWidth]
		}
		return e.afford(pool, rcxProbeReserve, now)
	}

	width := e.cfg.WaveWidth
	if kind == rcxWaveRescue || kind == rcxWaveDeep {
		width = len(pool)
	}
	wave := rcxDiverseWave(pool, width)
	if len(wave) == 0 {
		return nil
	}
	if kind == rcxWaveRescue && !e.rescueAdmitted(len(pool), now) {
		return nil
	}
	e.paidWave = 0
	if kind == rcxWaveRoutine {
		return e.afford(wave, 0, now)
	}
	return wave
}

type rcxRescueStamp struct {
	terrain rcxTerrain
	env     string
	park    int
}

// A rescue that found nothing waits before asking again: the cooling its
// failures bought is the schedule. Anything learned since buys an immediate try.
func (e *rcxEngine) rescueAdmitted(park int, now time.Time) bool {
	stamp := rcxRescueStamp{terrain: e.terrain.terrain, env: e.envKey, park: park}
	if !e.rescueAt.IsZero() && e.rescueMark == stamp && now.Sub(e.rescueAt) < rcxRescueRepeat {
		return false
	}
	e.rescueAt = now
	e.rescueMark = stamp
	return true
}

// A trickle stops at a reserve, or it starves the waves that answer an event.
func (e *rcxEngine) afford(wave []rcxProbeNode, reserve int, now time.Time) []rcxProbeNode {
	e.paidWave = 0
	spare := e.budget.Remaining(now) - reserve
	if spare <= 0 {
		return nil
	}
	if len(wave) > spare {
		wave = wave[:spare]
	}
	affordable := e.budget.Take(len(wave), now)
	if affordable <= 0 {
		return nil
	}
	e.paidWave = affordable
	return wave[:affordable]
}

// Half the TTL: a proof expiring between two passes is the gap this closes.
func (e *rcxEngine) proofDue(node string, now time.Time) bool {
	at := e.ledger.OpenAt(e.key(node), e.envKey)
	if at.IsZero() {
		return true
	}
	return now.Sub(at) >= e.ledger.ProofTTL()/2
}

func (e *rcxEngine) startProbe(candidates []rcxCandidate, members []rcxMember, kind rcxWaveKind) {
	wave := e.planWave(candidates, members, kind)
	if len(wave) == 0 {
		return
	}
	sweeps := kind == rcxWaveRescue || kind == rcxWaveDeep
	targets := e.probeTargets(wave, e.terrainCurrent(), kind)

	e.probing = true
	gen := e.probeGen
	prober := newRcxProber(e.runtime.Test)
	window := rcxProbeWave
	switch kind {
	case rcxWaveRescue:
		window = rcxRescueWave
		prober.enough = func(result rcxProbeResult) bool { return result.Outcome == rcxProbeOK }
	case rcxWaveDeep:
		window = rcxDeepProbeWave
	}
	if sweeps {
		prober.concurrency = rcxSweepParallel
		prober.timeout = rcxSweepTimeout
	}
	quit := e.quit
	safeGoDetached("rcx probe wave", func() {
		ctx, cancel := context.WithTimeout(context.Background(), window)
		defer cancel()
		results := prober.Run(ctx, targets)
		e.sendResult(rcxEvent{Kind: rcxEventProbeResults, Results: results, Gen: gen}, quit)
	})
}

// Off a normal terrain every node is asked both markers, the origin only orders.
func (e *rcxEngine) probeTargets(
	wave []rcxProbeNode,
	terrain rcxTerrain,
	kind rcxWaveKind,
) []rcxProbeTarget {
	paired := kind == rcxWaveRescue || kind == rcxWaveDeep
	open := rcxProbeTarget{Role: rcxRoleOpen, Marker: e.cfg.OpenMarkers[0]}
	both := len(e.cfg.DomesticMarkers) > 0 &&
		(terrain == rcxTerrainWhitelist || terrain == rcxTerrainUnknown)
	var home rcxProbeTarget
	if both {
		home = rcxProbeTarget{Role: rcxRoleDomestic, Marker: e.cfg.DomesticMarkers[0]}
	}
	primaries := make([]rcxProbeTarget, 0, len(wave))
	secondaries := make([]rcxProbeTarget, 0, len(wave))
	for _, node := range wave {
		primary, secondary := open, home
		if both && e.ledger.Origin(node.Key) == rcxOriginDomestic {
			primary, secondary = home, open
		}
		primary.Node = node.Name
		primaries = append(primaries, primary)
		if !both {
			continue
		}
		secondary.Node = node.Name
		if paired {
			primaries = append(primaries, secondary)
			continue
		}
		secondaries = append(secondaries, secondary)
	}
	return append(primaries, secondaries...)
}

func (e *rcxEngine) startReach() {
	if e.reaching || len(e.cfg.CanaryForeign) == 0 {
		return
	}
	e.lastReachAt = e.runtime.Now()
	foreign := append([]string(nil), e.cfg.CanaryForeign...)
	domestic := append([]string(nil), e.cfg.CanaryDomestic...)
	e.reaching = true
	gen := e.reachGen
	quit := e.quit
	safeGoDetached("rcx canary round", func() {
		var (
			domesticRows    []rcxCanaryReport
			domesticOutcome rcxProbeOutcome
		)
		done := make(chan struct{})
		safeGoDetached("rcx canary domestic", func() {
			defer close(done)
			domesticOutcome = e.reachGroup(domestic, true, &domesticRows)
		})
		foreignRows := make([]rcxCanaryReport, 0, len(foreign))
		foreignOutcome := e.reachGroup(foreign, false, &foreignRows)
		<-done
		e.sendResult(rcxEvent{
			Kind:     rcxEventTerrainReach,
			Foreign:  foreignOutcome,
			Domestic: domesticOutcome,
			Canaries: append(foreignRows, domesticRows...),
			Gen:      gen,
		}, quit)
	})
}

// Each group owns its deadline, or foreign timeouts spend the domestic dials.
func (e *rcxEngine) reachGroup(
	addresses []string,
	domestic bool,
	rows *[]rcxCanaryReport,
) rcxProbeOutcome {
	ctx, cancel := context.WithTimeout(context.Background(), rcxCanaryRound)
	defer cancel()
	return e.reachAny(ctx, addresses, domestic, rows)
}

// In order, one black-holed address spends the round the others needed.
func (e *rcxEngine) reachAny(
	ctx context.Context,
	addresses []string,
	domestic bool,
	rows *[]rcxCanaryReport,
) rcxProbeOutcome {
	if len(addresses) == 0 {
		return rcxProbeOverloaded
	}
	ctx, cancel := context.WithCancel(ctx)
	defer cancel()

	type result struct {
		index   int
		row     rcxCanaryReport
		outcome rcxProbeOutcome
	}
	results := make(chan result, len(addresses))
	for index, address := range addresses {
		index, address := index, address
		safeGoDetached("rcx canary dial", func() {
			started := e.runtime.Now()
			outcome := rcxProbeOverloaded
			defer func() {
				results <- result{
					index: index,
					row: rcxCanaryReport{
						Addr:     address,
						Domestic: domestic,
						Outcome:  rcxOutcomeName(outcome),
						DelayMs:  int(e.runtime.Now().Sub(started) / time.Millisecond),
					},
					outcome: outcome,
				}
			}()
			outcome = e.runtime.Reach(ctx, address)
		})
	}

	measured := make([]*rcxCanaryReport, len(addresses))
	verdict := rcxProbeOverloaded
	for range addresses {
		got := <-results
		measured[got.index] = &got.row
		if got.outcome == rcxProbeOK {
			verdict = rcxProbeOK
			break
		}
		if got.outcome == rcxProbeFail {
			verdict = rcxProbeFail
		}
	}
	for _, row := range measured {
		if row != nil {
			*rows = append(*rows, *row)
		}
	}
	return verdict
}

func (e *rcxEngine) delayOf(node string) int {
	if node == "" {
		return 0
	}
	return e.ledger.MedianMs(e.key(node), e.envKey, e.runtime.Now(), e.suspendAt, e.suspendTo)
}

func rcxMillis(at time.Time) int64 {
	if at.IsZero() {
		return 0
	}
	return at.UnixMilli()
}

func rcxOutcomeName(outcome rcxProbeOutcome) string {
	switch outcome {
	case rcxProbeOK:
		return "ok"
	case rcxProbeStatusMismatch:
		return "mismatch"
	case rcxProbeFail:
		return "fail"
	default:
		return "unknown"
	}
}

func (e *rcxEngine) publish(reason rcxReason, ranked []rcxRanked, input rcxDecisionInput) {
	now := e.runtime.Now()
	eligible := 0
	for _, row := range ranked {
		if row.Block == rcxBlockNone {
			eligible++
		}
	}
	status := rcxStatus{
		Enabled:    e.Enabled(),
		Preset:     e.cfg.Preset,
		Mode:       e.runtime.Mode(),
		Terrain:    e.terrainCurrent().String(),
		Env:        e.envKey,
		Node:       e.incumbent,
		DelayMs:    e.delayOf(e.incumbent),
		Reason:     string(reason),
		Searching:  e.probing,
		Deep:       e.deep,
		Pinned:     input.Pin != "",
		PinNode:    input.Pin,
		Direct:     e.direct,
		Candidates: len(ranked),
		Eligible:   eligible,
		SwitchedAt: rcxMillis(e.switchedAt),
	}
	report := rcxReport{
		Status: status,
		Link: rcxLinkReport{
			Transport: e.transport,
			Validated: e.validated,
			Portal:    e.portal,
			Metered:   e.metered,
			Foreign:   rcxOutcomeName(e.reachF),
			Domestic:  rcxOutcomeName(e.reachD),
			Since:     rcxMillis(e.terrain.since),
		},
		Canaries:   append([]rcxCanaryReport(nil), e.canaries...),
		Candidates: e.candidateReports(ranked, input, now),
		History:    append([]rcxSwitchReport(nil), e.history...),
		Bands:      rcxLatencyBands(),
		ProbesLeft: e.budget.Remaining(now),
		ProbeCap:   rcxProbeBudgetCap,
		Manual:     input.Pin != "",
		At:         rcxMillis(now),
	}

	e.mu.Lock()
	changed := e.status != status
	e.status = status
	e.report = report
	e.mu.Unlock()
	if changed {
		e.runtime.Publish(status)
	}
}

func (e *rcxEngine) candidateReports(
	ranked []rcxRanked,
	input rcxDecisionInput,
	now time.Time,
) []rcxCandidateReport {
	rows := make([]rcxCandidateReport, 0, len(ranked))
	for _, row := range ranked {
		candidate := row.Candidate
		cool := 0
		if !candidate.CoolUntil.IsZero() && now.Before(candidate.CoolUntil) {
			cool = int(candidate.CoolUntil.Sub(now) / time.Second)
		}
		rows = append(rows, rcxCandidateReport{
			Node:     candidate.Name,
			Country:  e.ledger.Country(e.key(candidate.Name)),
			Origin:   candidate.Facts.Origin.String(),
			Verdict:  rcxAdmit(input.Terrain, candidate.Facts).String(),
			Evidence: candidate.Evidence.String(),
			Block:    string(row.Block),
			DelayMs:  candidate.MedianMs,
			HostMs:   candidate.HostMs,
			Band:     int(row.Key.latBucket),
			Breaker:  candidate.Facts.Breaker,
			Degraded: candidate.Degraded,
			UDP:      candidate.Facts.SupportsUDP,
			Fails:    e.ledger.FailStreak(e.key(candidate.Name), e.envKey),
			CoolFor:  cool,
			Current:  candidate.Name == e.incumbent,
		})
	}
	return rows
}

func (e *rcxEngine) persist(force bool) {
	if e.snapshot == nil {
		return
	}
	now := e.runtime.Now()
	e.ledger.Prune(rcxKeepPerEnv, now)
	e.snapshot.Global, e.snapshot.Envs = e.ledger.Export()
	e.store.Save(e.snapshot, now, force)
}
