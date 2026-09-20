package main

import (
	"context"
	"reflect"
	"sort"
	"strings"
	"sync"
	"time"

	"github.com/metacubex/mihomo/tunnel/statistic"
)

type rcxMember struct {
	Name             string
	ID               string
	Provider         string
	Transport        string
	Type             string
	Port             int
	SupportsUDP      bool
	HostMs           int
	HostAt           time.Time
	HostDead         bool
	Order            int
	Ingress          string
	ExternalProvider bool
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
type rcxLaneStatus struct {
	ID         string `json:"id"`
	Group      string `json:"group"`
	State      string `json:"state"`
	Node       string `json:"node"`
	Candidates int    `json:"candidates"`
	Eligible   int    `json:"eligible"`
	Searching  bool   `json:"searching"`
	Fallback   string `json:"fallback"`
	Reason     string `json:"reason"`
	SwitchedAt int64  `json:"switchedAt"`
}

type rcxStatus struct {
	Enabled    bool            `json:"enabled"`
	Preset     string          `json:"preset"`
	Strategy   string          `json:"strategy"`
	Mode       string          `json:"mode"`
	Terrain    string          `json:"terrain"`
	Env        string          `json:"env"`
	Node       string          `json:"node"`
	DelayMs    int             `json:"delay"`
	Reason     string          `json:"reason"`
	Searching  bool            `json:"searching"`
	Deep       bool            `json:"deep"`
	Pinned     bool            `json:"pinned"`
	PinNode    string          `json:"pinNode"`
	Direct     string          `json:"direct"`
	Candidates int             `json:"candidates"`
	Eligible   int             `json:"eligible"`
	SwitchedAt int64           `json:"switchedAt"`
	Lanes      []rcxLaneStatus `json:"lanes,omitempty"`
}

type rcxCandidateReport struct {
	Node       string `json:"node"`
	Country    string `json:"country"`
	Exit       string `json:"exit"`
	Origin     string `json:"origin"`
	Verdict    string `json:"verdict"`
	Evidence   string `json:"evidence"`
	Block      string `json:"block"`
	DelayMs    int    `json:"delay"`
	HostMs     int    `json:"hostDelay"`
	Band       int    `json:"band"`
	LatencyMs  int    `json:"latencyMs"`
	Unproven   bool   `json:"unproven"`
	Order      int    `json:"order"`
	Degraded   bool   `json:"degraded"`
	Recurrence int    `json:"recurrence"`
	Confirmed  bool   `json:"confirmed"`
	Breaker    bool   `json:"breaker"`
	UDP        bool   `json:"udp"`
	Fails      int    `json:"fails"`
	CoolFor    int    `json:"coolFor"`
	Current    bool   `json:"current"`
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

type rcxMetricsReport struct {
	EnabledMillis     int64    `json:"enabledMillis"`
	AvailableMillis   int64    `json:"availableMillis"`
	Availability      int      `json:"availability"`
	Incidents         int      `json:"incidents"`
	StandbyHits       int      `json:"standbyHits"`
	ProviderIncidents int      `json:"providerIncidents"`
	MarkerIncidents   int      `json:"markerIncidents"`
	LastFailover      int64    `json:"lastFailover"`
	AverageFailover   int64    `json:"averageFailover"`
	LastOutage        int64    `json:"lastOutage"`
	AverageOutage     int64    `json:"averageOutage"`
	ActiveCircuits    []string `json:"activeCircuits"`
	ActiveMarkers     []string `json:"activeMarkers"`
}

// The overview's whole payload, pulled on demand rather than pushed: it is large,
// it changes on every tick, and nobody reads it while the page is closed.
type rcxReport struct {
	Status     rcxStatus            `json:"status"`
	Link       rcxLinkReport        `json:"link"`
	Canaries   []rcxCanaryReport    `json:"canaries"`
	Candidates []rcxCandidateReport `json:"candidates"`
	History    []rcxSwitchReport    `json:"history"`
	Metrics    rcxMetricsReport     `json:"metrics"`
	Bands      []int                `json:"bands"`
	ProbesLeft int                  `json:"probesLeft"`
	ProbeCap   int                  `json:"probeCap"`
	Manual     bool                 `json:"manual"`
	Discovery  rcxDiscoveryReport   `json:"discovery"`
	At         int64                `json:"at"`
}

// The seam that keeps the actor testable: everything touching tunnel locks,
// mmdb, the statistics manager or the host message queue lives behind it.
type rcxRuntime interface {
	TopologyValid(config rcxConfig) bool
	Members() []rcxMember
	Selected() string
	Select(node string) error
	SelectedIn(group string) string
	SelectIn(group, node string) error
	GroupMembers(group string) []string
	Mode() string
	Country(node string) string
	Locate(ctx context.Context, node, echo string) string
	Test(ctx context.Context, node string, marker rcxMarker) (delayMs int, satisfied bool, err error)
	Reach(ctx context.Context, addr string, domestic bool) rcxProbeOutcome
	Sweep(ctx context.Context, nodes []string)
	Connections() []rcxConnSample
	CloseConnections(ids []string)
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
	rcxEventScreenOff
	rcxEventSuspend
	rcxEventManualPick
	rcxEventManualAssert
	rcxEventProbeResults
	rcxEventProbeResult
	rcxEventWakeResults
	rcxEventTerrainReach
	rcxEventSetEnabled
	rcxEventHarvested
	rcxEventDeepScan
	rcxEventHostSweep
)

type rcxEvent struct {
	Dispatched int
	Accounting bool
	Kind       rcxEventKind
	Config     rcxConfig
	Payload    rcxNetworkPayload
	Flag       bool
	Node       string
	DelayMs    int
	Results    []rcxProbeResult
	Foreign    rcxProbeOutcome
	Domestic   rcxProbeOutcome
	Canaries   []rcxCanaryReport
	Gen        uint32
	ConfigGen  uint32
	Lane       string
	Wake       []rcxWakeResult
	Episode    uint64
}

const (
	rcxWakeSettle   = 500 * time.Millisecond
	rcxWakeTimeout  = 5 * time.Second
	rcxWakeDeadline = 7 * time.Second
)

type rcxWakeResult struct {
	Node    string
	Outcome rcxProbeOutcome
	DelayMs int
}

const (
	rcxDialQueueSize  = 512
	rcxEventQueueSize = 64
	rcxTickInterval   = 30 * time.Second
	rcxWatchInterval  = 5 * time.Second
	rcxProbeWave      = 20 * time.Second
	rcxDeepProbeWave  = 90 * time.Second
	rcxRescueWave     = 30 * time.Second
	rcxRescueRepeat   = 5 * time.Minute
	rcxPinWaveRetry   = time.Minute
	rcxSweepTimeout   = 5 * time.Second
	rcxSweepParallel  = 6
	rcxCanaryTimeout  = 3 * time.Second
	// A fresh radio attach does not complete TCP+TLS in the steady-state budget,
	// and a round that times out on both groups is read as "unknown terrain".
	rcxCanaryWarmup   = 5 * time.Second
	rcxCanaryRound    = rcxCanaryWarmup + 2*time.Second
	rcxCanaryBlindly  = 2
	rcxProbeBudgetCap = 240
	rcxMaxProofTTL    = 6 * time.Hour
	rcxProbeBudgetWin = time.Hour
	rcxProbeReserve   = 40
	rcxMaintainWidth  = 3
	rcxHistoryDepth   = 12

	rcxReachRefresh  = 5 * time.Minute
	rcxReachUrgent   = 30 * time.Second
	rcxTerrainMaxAge = 10 * time.Minute

	rcxConnStallAge    = 10 * time.Second
	rcxOpenSightWindow = time.Minute
	rcxOpenSightCap    = 64

	// The handoff answers a live network change, so it buys a narrow wave it can
	// finish inside the window a user spends reading the screen.
	rcxHandoffWave     = 6 * time.Second
	rcxHandoffParallel = 16
	rcxHandoffTimeout  = 4 * time.Second
	rcxHandoffWidth    = 8
	rcxHostSweepWindow = 4 * time.Second

	rcxWakeGrace      = 45 * time.Second
	rcxLinkDark       = 40 * time.Second
	rcxLinkFailQuorum = 2
	// One full canary round plus the slack for its verdict to reach the loop.
	rcxSwitchProbation = rcxCanaryRound + rcxCanaryTimeout
)

type rcxLaneState struct {
	config              rcxLaneConfig
	incumbent           string
	since               time.Time
	switchedAt          time.Time
	reason              rcxReason
	candidates          int
	eligible            int
	screenConfirmedDead string
	screenFailoverUsed  bool
}

type rcxEngine struct {
	manualPick     rcxManualPick
	discovery      map[string]*rcxDiscoveryState
	discoverySpent []time.Time
	quality        rcxQualityCheck
	laneBurst      int
	paidAt         time.Time
	receipts       map[uint32]rcxWaveReceipt
	sentinels      map[string]time.Time
	sessionEpoch   uint64
	runtime        rcxRuntime
	ledger         *rcxLedger
	store          *rcxStore
	budget         *rcxProbeBudget

	dials   chan rcxDialEvent
	events  chan rcxEvent
	control *rcxControl
	wake    chan struct{}
	quit    chan struct{}
	done    chan struct{}
	lifeMu  sync.Mutex

	// Guards only what other goroutines read: the enabled flag on the hot dial
	// path, the published status, the host's report, the markers and sightings.
	mu            sync.RWMutex
	enabled       bool
	status        rcxStatus
	report        rcxReport
	reportRanked  []rcxRanked
	reportInput   rcxDecisionInput
	reportVersion uint64
	reportBuilt   uint64
	openHosts     map[string]struct{}
	openSeen      map[string]rcxOpenSighting

	snapshot         *rcxSnapshot
	cfg              rcxConfig
	configFP         rcxConfigFingerprints
	terrain          rcxTerrainState
	envKey           string
	networkFacts     *rcxNetworkPayload
	transport        string
	metered          bool
	validated        bool
	portal           bool
	reachF           rcxProbeOutcome
	reachD           rcxProbeOutcome
	canaries         []rcxCanaryReport
	incumbent        string
	since            time.Time
	switchedAt       time.Time
	suspendAt        time.Time
	suspendTo        time.Time
	suspended        bool
	screenOff        bool
	screenEpisode    uint64
	screenDead       string
	screenFailedOver bool
	conns            map[string]int64
	upConns          map[string]int64
	keys             map[string]string
	names            map[string]string
	direct           string
	history          []rcxSwitchReport
	lanes            map[string]*rcxLaneState
	laneProbeSeen    map[string]map[string]struct{}
	laneProbeAt      map[string]time.Time
	probing          bool
	deep             bool
	paidWave         int
	paidWaveGen      uint32
	reaching         bool
	reachCancel      context.CancelFunc
	started          bool
	rescueAt         time.Time
	rescueMark       rcxRescueStamp
	rescueSeen       map[string]struct{}
	rescueExhausted  bool
	pendingHandoff   bool

	reachGen            uint32
	probeGen            uint32
	configGen           uint32
	sweepGen            uint32
	reachAgain          bool
	reachBlind          int
	reachWarm           bool
	sweeping            bool
	sweptAt             time.Time
	envSince            time.Time
	lastReachAt         time.Time
	pendingGrant        bool
	pinWaveAt           time.Time
	hostLinked          bool
	wantPick            string
	downFrozen          map[string]time.Time
	charged             map[string]int
	chargedAt           time.Time
	escrowReach         bool
	providerFails       map[string]time.Time
	probeLaunchedAt     time.Time
	probeResults        []rcxProbeResult
	probeStarted        map[string]struct{}
	probeKind           rcxWaveKind
	probeLane           string
	probeRecovered      bool
	probeDecisionClosed bool
	probeScreenOff      bool
	probeScreenEpisode  uint64
	probeIncumbent      string
	probeCancel         context.CancelFunc
	wakeGen             uint32
	wakePending         bool
	wakeEpisode         uint64
	wakeIncumbent       string
	wakeStandby         string
	wakeStartedAt       time.Time
	wakeIncumbentKey    string
	wakeStandbyKey      string
	wakeCancel          context.CancelFunc
	incidentConns       map[string]struct{}
	accountedAt         time.Time
	incidentAt          time.Time
}

func newRcxEngine(runtime rcxRuntime) *rcxEngine {
	return &rcxEngine{
		runtime:       runtime,
		sessionEpoch:  rcxNewSeed(),
		ledger:        newRcxLedger(rcxDefaultLedgerPolicy()),
		store:         newRcxStore(),
		budget:        newRcxProbeBudget(rcxProbeBudgetCap, rcxProbeBudgetWin),
		cfg:           rcxDefaultConfig(),
		configFP:      rcxConfigFingerprints{},
		dials:         make(chan rcxDialEvent, rcxDialQueueSize),
		events:        make(chan rcxEvent, rcxEventQueueSize),
		control:       newRcxControl(),
		wake:          make(chan struct{}, 1),
		downFrozen:    map[string]time.Time{},
		openSeen:      map[string]rcxOpenSighting{},
		charged:       map[string]int{},
		providerFails: map[string]time.Time{},
		probeStarted:  map[string]struct{}{},
		incidentConns: map[string]struct{}{},
		rescueSeen:    map[string]struct{}{},
		lanes:         map[string]*rcxLaneState{},
		laneProbeSeen: map[string]map[string]struct{}{},
		laneProbeAt:   map[string]time.Time{},
	}
}

// NoteDial runs on the dial path under configMux.RLock, so it must never take a
// core lock: a synchronous selector write here would deadlock against match().
func (e *rcxEngine) NoteDial(node string, failed bool, elapsed time.Duration, now time.Time) {
	if node == "" || node == "DIRECT" || !e.Enabled() {
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
	for {
		e.mu.RLock()
		if e.reportBuilt == e.reportVersion {
			report := e.report
			e.mu.RUnlock()
			return report
		}
		report := e.report
		ranked := append([]rcxRanked(nil), e.reportRanked...)
		input := e.reportInput
		version := e.reportVersion
		e.mu.RUnlock()

		report.Candidates = e.candidateReports(ranked, input, input.Now)
		e.mu.Lock()
		if e.reportVersion == version {
			e.report = report
			e.reportBuilt = version
			e.mu.Unlock()
			return report
		}
		e.mu.Unlock()
	}
}

func (e *rcxEngine) Start() {
	e.lifeMu.Lock()
	defer e.lifeMu.Unlock()
	if e.started {
		return
	}
	e.quit = make(chan struct{})
	e.done = make(chan struct{})
	e.snapshot = e.store.Load()
	if runtime, ok := e.runtime.(interface{ SetIdentitySalt([]byte) }); ok {
		runtime.SetIdentitySalt(e.snapshot.IdentitySalt)
	}
	e.ledger.Import(e.snapshot.Global, e.snapshot.Envs)
	e.configFP = e.snapshot.Fingerprints
	e.ledger.SetFingerprints(e.configFP.Open, e.configFP.Domestic)
	e.applyConfigLocked(e.snapshot.Config)
	e.networkFacts = nil
	e.sampleLink()
	e.started = true
	safeGoDetached("rcx engine", e.loop)
}

func (e *rcxEngine) Stop() {
	e.lifeMu.Lock()
	defer e.lifeMu.Unlock()
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
func (e *rcxEngine) OnScreenOff(off bool) {
	e.control.ScreenOff(off)
}
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
	var ticker, watchdog *time.Ticker
	var tick, watch <-chan time.Time
	syncTickers := func() {
		active := e.Enabled() && !e.screenOff && !e.suspended
		if active && ticker == nil {
			ticker = time.NewTicker(rcxTickInterval)
			watchdog = time.NewTicker(rcxWatchInterval)
			tick = ticker.C
			watch = watchdog.C
		} else if !active && ticker != nil {
			e.persist(false)
			ticker.Stop()
			watchdog.Stop()
			ticker, watchdog = nil, nil
			tick, watch = nil, nil
		}
	}
	defer func() {
		if ticker != nil {
			ticker.Stop()
			watchdog.Stop()
		}
	}()
	syncTickers()

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
			if e.drainDials() {
				e.reconsider()
			}
		case <-watch:
			e.maybeRefreshTerrain()
			e.watchIncumbent()
		case <-tick:
			e.drainDials()
			e.sampleLink()
			e.sampleTraffic()
			e.maybeRefreshTerrain()
			e.reconsider()
			e.maintain()
			e.persist(false)
		}
		syncTickers()
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
		e.refreshEffectiveEnabled()
		members := e.runtime.Members()
		e.syncIdentity(members)
		e.reconcileCircuits(members, e.runtime.Now())
		e.reconsider()
	case rcxEventScreenOff:
		e.applyScreenOff(event.Flag)
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
		if negative {
			// One health-check miss leaves any freshly proven node's proof standing; escrow still accrues.
			if !e.freshlyOpenProven(e.key(event.Node), now) {
				e.ledger.NoteHarvestedProbe(e.key(event.Node), e.envKey, event.DelayMs, now)
			}
			e.escrowNegative(event.Node, 0, now)
			break
		}
		e.ledger.NoteHarvestedProbe(e.key(event.Node), e.envKey, event.DelayMs, now)
		if !rcxImplausibleDelay(event.DelayMs) {
			e.noteProviderSuccess(event.Node)
			e.noteLinkAlive(now)
		}
	case rcxEventManualPick:
		e.applyManualPick(event.Node, true)
	case rcxEventManualAssert:
		e.applyManualPick(event.Node, false)
	case rcxEventDeepScan:
		e.startDeepScan()
	case rcxEventHostSweep:
		e.applyHostSweep(event.Gen)
	case rcxEventProbeResult:
		e.applyProbeResult(event)
	case rcxEventProbeResults:
		if event.Accounting {
			e.settleWaveReceipt(event.Gen, event.Dispatched)
		}
		if event.Gen != 0 && event.Gen != e.probeGen || event.Lane != e.probeLane ||
			(event.ConfigGen != 0 && event.ConfigGen != e.configGen) {
			break
		}
		for _, result := range event.Results {
			e.applyProbeResult(rcxEvent{Kind: rcxEventProbeResult, Results: []rcxProbeResult{result}, Gen: event.Gen, ConfigGen: event.ConfigGen, Lane: event.Lane})
		}
		e.finishProbe()
	case rcxEventWakeResults:
		e.applyWakeResults(event)
	case rcxEventTerrainReach:
		if event.Gen != e.reachGen || (event.ConfigGen != 0 && event.ConfigGen != e.configGen) {
			break
		}
		e.reaching = false
		e.reachCancel = nil
		{
			e.reachF, e.reachD = event.Foreign, event.Domestic
			e.canaries = event.Canaries
			e.lastReachAt = e.runtime.Now()
			e.reachWarm = false
			measured := e.reachF != rcxProbeOverloaded || e.reachD != rcxProbeOverloaded
			if measured {
				e.reachBlind = 0
			} else if e.reachBlind++; e.reachBlind < rcxCanaryBlindly {
				e.reachAgain = true
			}
			if e.reachF == rcxProbeOK || e.reachD == rcxProbeOK {
				e.noteLinkAlive(e.lastReachAt)
			}
			e.classifyTerrain(measured)
			if e.terrain.confirming() {
				e.reachAgain = true
			}
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
	previous := e.configFP
	next := config.fingerprints()
	hasPrevious := previous != (rcxConfigFingerprints{})
	changed := hasPrevious && previous != next
	if changed {
		e.configGen++
		e.supersedeProbe()
		e.supersedeWake()
		e.laneProbeSeen = map[string]map[string]struct{}{}
		e.laneProbeAt = map[string]time.Time{}
		e.resetRescue()
		e.supersedeReach()
		e.ledger.Invalidate(
			previous.Open != next.Open,
			previous.Domestic != next.Domestic,
			previous.Countries != next.Countries,
			previous.Egress != next.Egress,
		)
		if previous.Canaries != next.Canaries {
			e.reachF, e.reachD = rcxProbeOverloaded, rcxProbeOverloaded
			e.lastReachAt = time.Time{}
		}
	}
	// A toggle must not refill the probe budget, or it becomes a way to farm one.
	if config.Preset != e.cfg.Preset {
		e.budget = newRcxProbeBudget(rcxProbeBudgetCap, rcxProbeBudgetWin)
	}
	// Enabling starts from measurements: one full wave rides outside the cap.
	if config.operable() && (!e.cfg.operable() || config.Strategy != e.cfg.Strategy) {
		e.pendingGrant = true
	}
	e.cfg = config
	e.syncLaneConfigs(config.Lanes)
	e.configFP = next
	e.ledger.SetFingerprints(next.Open, next.Domestic)
	now := e.runtime.Now()
	e.accountMetrics(now)
	e.mu.Lock()
	e.openHosts = rcxMarkerHosts(config.OpenMarkers)
	e.mu.Unlock()
	e.refreshEffectiveEnabled()
	if !config.operable() {
		e.closeIncident(now, false)
	}
	if e.snapshot != nil {
		e.snapshot.Config = config
		e.snapshot.Fingerprints = next
	}
}

func (e *rcxEngine) refreshEffectiveEnabled() {
	want := e.cfg.operable() && e.runtime.TopologyValid(e.cfg)
	e.mu.Lock()
	was := e.enabled
	e.enabled = want
	e.mu.Unlock()
	if was && !want {
		e.supersedeProbe()
		e.supersedeWake()
		e.supersedeReach()
	}
	if !was && want {
		e.pendingGrant = true
	}
}

func (e *rcxEngine) syncLaneConfigs(configs []rcxLaneConfig) {
	lanes := make(map[string]*rcxLaneState, len(configs))
	for _, config := range configs {
		lane := e.lanes[config.ID]
		if lane == nil {
			lane = &rcxLaneState{}
		}
		if lane.config.ID != "" && !reflect.DeepEqual(lane.config, config) {
			delete(e.laneProbeSeen, config.ID)
			delete(e.laneProbeAt, config.ID)
		}
		if lane.config.Group != "" && lane.config.Group != config.Group {
			lane.incumbent = ""
			lane.since = time.Time{}
		}
		lane.config = config
		lanes[config.ID] = lane
	}
	e.lanes = lanes
	for id := range e.laneProbeSeen {
		if lanes[id] == nil {
			delete(e.laneProbeSeen, id)
			delete(e.laneProbeAt, id)
		}
	}
	if e.snapshot != nil {
		for id := range e.snapshot.LanePicks {
			if lanes[id] == nil {
				delete(e.snapshot.LanePicks, id)
				e.snapshot.Dirty = true
			}
		}
		for id := range e.snapshot.LaneStandbys {
			if lanes[id] == nil {
				delete(e.snapshot.LaneStandbys, id)
				e.snapshot.Dirty = true
			}
		}
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
	e.applyNetwork(payload)
}

func (e *rcxEngine) applyNetwork(payload rcxNetworkPayload) {
	payload = normalizedNetworkFacts(payload)
	if !rcxPayloadIdentifies(payload) {
		return
	}
	if e.networkFacts != nil && equalNetworkFacts(*e.networkFacts, payload) {
		return
	}
	e.networkFacts = &payload
	primary, aliases := rcxEnvKeys(payload)
	e.transport = payload.Transport
	e.metered = payload.Metered
	e.validated = payload.Validated
	e.portal = payload.CaptivePortal
	e.terrain.noteValidation(payload.Validated, e.runtime.Now())

	changed := primary != e.envKey
	if changed {
		e.rollbackEscrow()
		e.resetRescue()
		e.supersedeWake()
		e.laneProbeSeen = map[string]map[string]struct{}{}
		e.laneProbeAt = map[string]time.Time{}
		e.pendingHandoff = true
		e.providerFails = map[string]time.Time{}
		e.envKey = primary
		e.envSince = e.runtime.Now()
		e.reachWarm = true
		e.reachBlind = 0
		e.terrain.forget()
		e.migrateEnvironment(aliases, primary)
		e.supersedeProbe()
		e.reachF, e.reachD = rcxProbeOverloaded, rcxProbeOverloaded
		e.incumbent = ""
		e.since = time.Time{}
		e.wantPick = e.snapshot.Picks[primary]
		if pin, ok := e.snapshot.Pins[primary]; ok {
			e.wantPick = pin
		}
		for id, lane := range e.lanes {
			lane.incumbent = ""
			lane.since = time.Time{}
			if picks := e.snapshot.LanePicks[id]; picks != nil {
				lane.incumbent = e.nameOf(picks[primary])
			}
		}
	}
	e.classifyTerrain(false)
	e.supersedeReach()
	e.startReach()
	if changed {
		e.startHostSweep()
	}
	e.reconsider()
}

// The host's own delay test is the signal the user reads by eye, and it is the
// only one that covers a whole park inside seconds. Nothing refreshes it on a
// link change, so the engine buys its own round rather than ranking the new
// network by the greens the old one left behind.
func (e *rcxEngine) startHostSweep() {
	if !e.Enabled() {
		e.pendingHandoff = false
		return
	}
	members := e.runtime.Members()
	if len(members) == 0 {
		e.pendingHandoff = false
		return
	}
	nodes := make([]string, 0, len(members))
	for _, member := range members {
		nodes = append(nodes, member.Name)
	}
	e.sweepGen++
	e.sweeping = true
	gen := e.sweepGen
	quit := e.quit
	sweep := e.runtime.Sweep
	safeGoDetached("rcx host sweep", func() {
		ctx, cancel := context.WithTimeout(context.Background(), rcxHostSweepWindow)
		defer cancel()
		sweep(ctx, nodes)
		e.sendResult(rcxEvent{Kind: rcxEventHostSweep, Gen: gen}, quit)
	})
}

// A pick made before the sweep landed was made blind, so the reading that
// arrives may not spend its dwell defending it.
func (e *rcxEngine) applyHostSweep(gen uint32) {
	if gen != e.sweepGen {
		return
	}
	e.sweeping = false
	e.sweptAt = e.runtime.Now()
	if e.incumbent != "" && e.ledger.Facts(
		e.key(e.incumbent), e.envKey, false, e.sweptAt, e.ledger.ProofTTL(),
	).Transit != rcxProofProven {
		e.since = time.Time{}
	}
	e.reconsider()
}

// A wave dispatched before the sweep would order itself by the previous link.
func (e *rcxEngine) awaitsHostSweep(now time.Time) bool {
	return e.sweeping && !e.envSince.IsZero() &&
		now.Sub(e.envSince) < rcxHostSweepWindow
}

// A round in flight was bought by the previous link: the new one cannot use it.
func (e *rcxEngine) supersedeReach() {
	e.reachGen++
	e.escrowReach = false
	if e.reachCancel != nil {
		e.reachCancel()
		e.reachCancel = nil
	}
	e.reaching = false
	e.reachAgain = false
}

// The dials really ran, so the charge stands; only the verdicts go stale.
func (e *rcxEngine) supersedeProbe() {
	if e.probeCancel != nil {
		e.probeCancel()
		e.probeCancel = nil
	}
	e.probeGen++
	e.probing = false
	e.deep = false
	e.probeResults = nil
	e.probeStarted = map[string]struct{}{}
	e.probeRecovered = false
	e.probeDecisionClosed = false
	e.probeLane = ""
	e.paidWave = 0
	e.paidWaveGen = e.probeGen
}

func (e *rcxEngine) supersedeWake() {
	if e.wakeCancel != nil {
		e.wakeCancel()
		e.wakeCancel = nil
	}
	e.wakeGen++
	e.wakePending = false
	e.wakeIncumbent = ""
	e.wakeStandby = ""
}

func (e *rcxEngine) migrateEnvironment(aliases []string, to string) {
	for _, from := range aliases {
		if from == to {
			continue
		}
		e.ledger.Migrate(from, to)
		migrateLatestString(e.snapshot.Picks, from, to)
		migrateLatestString(e.snapshot.Pins, from, to)
		migrateLatestRegime(e.snapshot.Regimes, from, to)
		migrateStandbys(e.snapshot.Standbys, from, to)
		for _, picks := range e.snapshot.LanePicks {
			migrateLatestString(picks, from, to)
		}
		for _, standbys := range e.snapshot.LaneStandbys {
			migrateStandbys(standbys, from, to)
		}
		e.migrateCircuits(from, to)
	}
}

func migrateLatestString(values map[string]string, from, to string) {
	if values[to] == "" && values[from] != "" {
		values[to] = values[from]
	}
	delete(values, from)
}

func migrateLatestRegime(values map[string]rcxRegimeMemory, from, to string) {
	incoming, ok := values[from]
	if !ok {
		return
	}
	if current, exists := values[to]; !exists || incoming.At.After(current.At) {
		values[to] = incoming
	}
	delete(values, from)
}

func migrateStandbys(values map[string][]string, from, to string) {
	incoming, ok := values[from]
	if !ok {
		return
	}
	seen := map[string]struct{}{}
	merged := make([]string, 0, rcxStandbyCount)
	for _, key := range append(append([]string(nil), values[to]...), incoming...) {
		if _, ok := seen[key]; ok || key == "" {
			continue
		}
		seen[key] = struct{}{}
		merged = append(merged, key)
		if len(merged) == rcxStandbyCount {
			break
		}
	}
	values[to] = merged
	delete(values, from)
}

func (e *rcxEngine) migrateCircuits(from, to string) {
	prefix := from + "\x00"
	for key, incoming := range e.snapshot.Circuits {
		if !strings.HasPrefix(key, prefix) {
			continue
		}
		destination := to + key[len(from):]
		if current, ok := e.snapshot.Circuits[destination]; !ok || incoming.OpenedAt.After(current.OpenedAt) {
			e.snapshot.Circuits[destination] = incoming
		}
		delete(e.snapshot.Circuits, key)
	}
}

// The marker answered through the tunnel, so it is evidence about the link the
// canaries are still arguing over, not about the node that carried it.
func (e *rcxEngine) witnessWhitelist(role rcxRole) {
	if role != rcxRoleDomestic || e.reachD != rcxProbeOK || e.reachF == rcxProbeOK {
		return
	}
	if e.terrain.witnessWhitelist() {
		e.classifyTerrain(false)
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
	e.resetRescue()
	if terrain == rcxTerrainNormal {
		e.ledger.PromoteTerrainNormal(e.envKey)
	}
	if e.envKey != "" {
		e.snapshot.Regimes[e.envKey] = rcxRegimeMemory{Terrain: terrain, At: now}
	}
}

func (e *rcxEngine) applyScreenOff(off bool) {
	if e.screenOff == off {
		return
	}
	e.screenOff = off
	if off && e.improvementWave() {
		e.supersedeProbe()
	}
	if !off {
		e.screenDead = ""
		e.screenFailedOver = false
		if e.probing && e.probeScreenOff {
			e.sealProbeDecision()
		}
		e.startWakeProbe()
		e.startReach()
		return
	}
	e.supersedeReach()
	e.reachAgain = false
	e.supersedeWake()
	e.screenEpisode++
	e.screenDead = ""
	e.screenFailedOver = false
	for _, lane := range e.lanes {
		lane.screenConfirmedDead = ""
		lane.screenFailoverUsed = false
	}
}

func (e *rcxEngine) applySuspend(suspended bool) {
	now := e.runtime.Now()
	e.suspended = suspended
	if suspended {
		e.supersedeProbe()
		e.supersedeWake()
		e.supersedeReach()
		e.reachAgain = false
		e.accountMetrics(now)
		e.closeIncident(now, false)
		e.suspendAt = now
		e.suspendTo = now
		e.accountedAt = time.Time{}
		e.persist(true)
		return
	}
	e.suspendTo = now
	e.accountedAt = now
	e.reachF, e.reachD = rcxProbeOverloaded, rcxProbeOverloaded
	e.supersedeReach()
	if !e.screenOff {
		e.startWakeProbe()
	}
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
	if withSelect || e.runtime.Selected() != node {
		if err := e.runtime.Select(node); err != nil {
			return
		}
	}
	e.supersedeProbe()
	e.supersedeWake()
	e.resetRescue()
	e.quality = rcxQualityCheck{}
	e.wantPick = ""
	e.pinWaveAt = time.Time{}
	e.incumbent = node
	e.since = e.runtime.Now()
	e.syncIdentity(e.runtime.Members())
	e.manualPick = rcxManualPick{Key: e.key(node), Environment: e.envKey, At: e.since}
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
func (e *rcxEngine) drainDials() bool {
	if len(e.dials) == 0 {
		return false
	}
	now := e.runtime.Now()
	terrain := e.terrainCurrent()
	keep := e.Enabled() && e.runtime.Mode() == "rule"
	if keep {
		e.ensureIdentity()
	}
	answered, changed := false, false
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
					changed = true
					e.escrowNegative(event.Node, 1, at)
					e.noteProviderNodeFailure(event.Node, at)
				}
				continue
			}
			valid, refunded := e.ledger.noteDialSuccess(e.key(event.Node), e.envKey, event.Elapsed, at)
			answered = answered || valid
			changed = changed || refunded
		default:
			break drain
		}
	}
	if answered {
		changed = changed || len(e.charged) > 0
		e.noteLinkAlive(now)
	}
	return changed
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
	previousUp := e.upConns
	e.conns = make(map[string]int64, len(conns))
	e.upConns = make(map[string]int64, len(conns))
	e.mu.RLock()
	markers := e.openHosts
	e.mu.RUnlock()
	flows := make(map[string]*rcxNodeFlow, len(conns))
	alive := false
	for _, conn := range conns {
		answered := conn.Down > previous[conn.Key]
		_, seen := previous[conn.Key]
		uploading := seen && conn.Up > previousUp[conn.Key]
		alive = alive || answered
		e.conns[conn.Key] = conn.Down
		e.upConns[conn.Key] = conn.Up
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
		// Growing Up is a live link (§1.9); only payload never answered nor still uploading accuses.
		case conn.Down == 0 && conn.Up > 0 && !uploading && now.Sub(conn.Start) >= rcxConnStallAge:
			flow.stalled++
			if conn.Node == e.incumbent {
				e.incidentConns[conn.Key] = struct{}{}
			}
		}
	}
	if alive {
		e.noteLinkAlive(now)
	}
	for node, flow := range flows {
		switch {
		case flow.progress:
			e.notePayload(node, flow.open, now)
			if node == e.incumbent {
				for _, conn := range conns {
					if conn.Node == node && conn.Down > previous[conn.Key] {
						delete(e.incidentConns, conn.Key)
					}
				}
			}
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

// Negative evidence is durable only after the direct path has established its
// regime. Unknown links, portals and dead radios cannot identify a bad node.
func (e *rcxEngine) chargesNegative(now time.Time) bool {
	if !e.suspendTo.IsZero() && now.Sub(e.suspendTo) < rcxWakeGrace {
		return false
	}
	switch e.terrainCurrent() {
	case rcxTerrainNormal, rcxTerrainWhitelist:
		return true
	default:
		return false
	}
}

// The weight is what the fact added to the streak, so a refund gives that back.
func (e *rcxEngine) escrowNegative(node string, weight int, now time.Time) {
	if len(e.charged) == 0 {
		e.chargedAt = now
	}
	e.charged[e.key(node)] += weight
	if len(e.charged) >= e.escrowQuorum() && !e.escrowReach {
		e.supersedeReach()
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
	e.escrowReach = false
}

// The answer that ends an escrow may never come; a settled dark verdict stands.
func (e *rcxEngine) rollbackEscrow() {
	if len(e.charged) == 0 {
		return
	}
	e.ledger.RollbackFailures(e.envKey, e.charged)
	e.charged = map[string]int{}
	e.chargedAt = time.Time{}
	e.escrowReach = false
}

func (e *rcxEngine) notePayload(node string, openWorld bool, now time.Time) {
	key := e.key(node)
	delete(e.downFrozen, key)
	e.ledger.NoteTrafficProgress(key, e.envKey, openWorld, now)
	e.ledger.ClearDegraded(key, e.envKey)
	if node == e.incumbent {
		e.closeIncident(now, true)
	}
	e.noteProviderSuccess(node)
}

func (e *rcxEngine) confirmWindow(key, node string) time.Duration {
	full := time.Duration(e.cfg.DegradeConfirmSeconds) * time.Second
	if node != e.incumbent {
		return full
	}
	if !e.ledger.ProgressAt(key, e.envKey).IsZero() || !e.ledger.OpenAt(key, e.envKey).IsZero() {
		return full
	}
	cold := rcxColdConfirmSec * time.Second
	if cold < full {
		return cold
	}
	return full
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
	if e.ledger.TrafficAt(key, e.envKey).IsZero() && len(e.ledger.Samples(key, e.envKey)) > 0 {
		return
	}
	frozen := e.downFrozen[key]
	if frozen.IsZero() {
		e.downFrozen[key] = now
		return
	}
	if now.Sub(frozen) < e.confirmWindow(key, node) {
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

// The pair of rounds that confirms a whitelist is the whole latency of the
// verdict, so it runs back to back rather than on the refresh cadence.
func (e *rcxEngine) reachInterval() time.Duration {
	if e.terrain.confirming() {
		return 0
	}
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
	return code, e.sideOf(code)
}

func (e *rcxEngine) sideOf(code string) rcxOrigin {
	if e.cfg.censors(code) {
		return rcxOriginDomestic
	}
	return rcxOriginForeign
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

func (e *rcxEngine) orderOf(_ string, declared int) int { return declared }

func (e *rcxEngine) syncIdentity(members []rcxMember) {
	keys := make(map[string]string, len(members))
	names := make(map[string]string, len(members))
	for _, member := range members {
		keys[member.Name] = member.key()
		if _, exists := names[member.key()]; !exists || member.Name == e.incumbent || member.Name == e.runtime.Selected() {
			names[member.key()] = member.Name
		}
	}
	e.mu.Lock()
	e.keys = keys
	e.names = names
	e.mu.Unlock()
}

func (e *rcxEngine) candidates(members []rcxMember) []rcxCandidate {
	return e.candidatesFor(members, e.incumbent)
}

func (e *rcxEngine) candidatesFor(members []rcxMember, incumbent string) []rcxCandidate {
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
		member = e.freshHost(member)
		candidates = append(candidates, rcxCandidate{
			Name:             member.Name,
			Order:            e.orderOf(key, member.Order),
			Facts:            facts,
			Evidence:         e.ledger.Evidence(key, e.envKey, now, live, fresh),
			MedianMs:         e.comparableMedian(key, now),
			Recurrence:       e.ledger.Recurrence(key, e.envKey, now),
			QualityConfirmed: e.qualityConfirmed(key, now),
			HostMs:           member.HostMs,
			HostAt:           member.HostAt,
			HostDead:         member.HostDead,
			CoolUntil:        e.ledger.CoolUntil(key, e.envKey, now),
			InSkeleton:       true,
			Degraded:         e.ledger.Degraded(key, e.envKey, now),
			Circuit:          e.providerCircuitOpenFor(member.Provider, member.Name, incumbent, now),
		})
	}
	return candidates
}

// A delay measured on the link before this one says nothing about this one: a
// home-WiFi green survives half an hour of freshness and would otherwise hoist a
// node the new network cannot reach to the front of every ranking and wave.
func (e *rcxEngine) freshHost(member rcxMember) rcxMember {
	if member.HostDead {
		now := e.runtime.Now()
		proof := e.ledger.ProbeGoodAt(member.key(), e.envKey)
		if e.trafficSince(member.key(), member.HostAt, now) ||
			(!proof.IsZero() && proof.After(member.HostAt) && !proof.Before(e.envSince) && now.Sub(proof) <= e.ledger.ProofTTL()) {
			member.HostDead = false
		}
	}
	if e.envSince.IsZero() || member.HostAt.IsZero() || !member.HostAt.Before(e.envSince) {
		return member
	}
	member.HostMs, member.HostAt, member.HostDead = 0, time.Time{}, false
	return member
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

func rcxLaneMatches(config rcxLaneConfig, member rcxMember, groups map[string]map[string]struct{}) bool {
	for _, selector := range config.Selectors {
		if selector.Provider != "" && selector.Provider != member.Provider {
			continue
		}
		if selector.NameContains != "" && !strings.Contains(member.Name, selector.NameContains) {
			continue
		}
		if selector.Group != "" {
			set, ok := groups[selector.Group]
			if !ok {
				continue
			}
			if _, in := set[member.Name]; !in {
				continue
			}
		}
		return true
	}
	return false
}

func (e *rcxEngine) laneGroupSets(config rcxLaneConfig) map[string]map[string]struct{} {
	var sets map[string]map[string]struct{}
	for _, selector := range config.Selectors {
		if selector.Group == "" {
			continue
		}
		if sets == nil {
			sets = map[string]map[string]struct{}{}
		}
		if _, done := sets[selector.Group]; done {
			continue
		}
		set := map[string]struct{}{}
		for _, name := range e.runtime.GroupMembers(selector.Group) {
			set[name] = struct{}{}
		}
		sets[selector.Group] = set
	}
	return sets
}

// Gates on the measured egress, never a proof, so an unmeasured node stays probeable.
func rcxLaneRoleAdmits(role string, f rcxFacts) bool {
	switch role {
	case rcxLaneRoleForeign:
		return f.Exit != rcxOriginDomestic
	case rcxLaneRoleDomestic:
		return f.Exit != rcxOriginForeign
	default:
		return true
	}
}

func (e *rcxEngine) laneCandidates(lane *rcxLaneState, members []rcxMember) []rcxCandidate {
	candidates := e.candidatesFor(members, lane.incumbent)
	byName := make(map[string]rcxMember, len(members))
	for _, member := range members {
		byName[member.Name] = member
	}
	groups := e.laneGroupSets(lane.config)
	for i := range candidates {
		member, ok := byName[candidates[i].Name]
		candidates[i].InSkeleton = ok && rcxLaneMatches(lane.config, member, groups) &&
			rcxLaneRoleAdmits(lane.config.Role, candidates[i].Facts)
	}
	return candidates
}

// Only the strategy is per-lane; the rest of the policy stays the park's.
func (e *rcxEngine) lanePolicy(config rcxLaneConfig) rcxPolicy {
	policy := e.cfg.policy()
	if config.Strategy != "" {
		policy.Strategy = config.Strategy
	}
	return policy
}

func (e *rcxEngine) reconsiderLanes(members []rcxMember, now time.Time) {
	for _, config := range e.cfg.Lanes {
		lane := e.lanes[config.ID]
		if lane == nil {
			continue
		}
		if lane.incumbent == "" {
			selected := e.runtime.SelectedIn(config.Group)
			if selected != "REJECT" && selected != rcxGroupNode {
				lane.incumbent = selected
			}
		}
		candidates := e.laneCandidates(lane, members)
		input := rcxDecisionInput{
			Terrain:        e.terrainCurrent(),
			Incumbent:      lane.incumbent,
			IncumbentSince: lane.since,
			Candidates:     candidates,
			Policy:         e.lanePolicy(config),
			Now:            now,
		}
		decision := rcxDecide(input)
		if decision.Reason == rcxReasonQualityConfirming {
			e.queueQuality(decision.Detail)
		}
		if decision.Switch && decision.To != lane.incumbent {
			e.tryAutomaticLaneSelect(lane, decision.To, decision.Reason, now)
		} else if lane.incumbent != "" && e.runtime.SelectedIn(config.Group) != lane.incumbent {
			_ = e.runtime.SelectIn(config.Group, lane.incumbent)
		}
		ranked := rcxRank(input)
		e.rebuildLaneStandbys(lane, ranked)
		lane.candidates = 0
		lane.eligible = 0
		for _, row := range ranked {
			if row.Candidate.InSkeleton {
				lane.candidates++
			}
			if row.Block == rcxBlockNone {
				lane.eligible++
			}
		}
		lane.reason = decision.Reason
		// Index 0 of the skeleton only covers the window before the core speaks:
		// once a lane holds no endpoint the user's own fallback owns the group,
		// whether the specialists are gone or merely unproven so far.
		if !rcxLaneHolds(lane, ranked) && !e.screenOff {
			fallback := "REJECT"
			if config.Fallback == rcxLaneFallbackMain {
				fallback = rcxGroupNode
			}
			if e.runtime.SelectedIn(config.Group) != fallback {
				if err := e.runtime.SelectIn(config.Group, fallback); err != nil {
					continue
				}
			}
			lane.incumbent = ""
			lane.since = time.Time{}
		}
	}
}

// A lane holds its group only while its own endpoint is still selectable: a
// dead or barred incumbent leaves the group to the configured fallback.
func rcxLaneHolds(lane *rcxLaneState, ranked []rcxRanked) bool {
	if lane.incumbent == "" {
		return false
	}
	for _, row := range ranked {
		if row.Candidate.Name == lane.incumbent {
			return row.Block == rcxBlockNone
		}
	}
	return false
}

func (e *rcxEngine) laneStatuses() []rcxLaneStatus {
	statuses := make([]rcxLaneStatus, 0, len(e.cfg.Lanes))
	for _, config := range e.cfg.Lanes {
		lane := e.lanes[config.ID]
		if lane == nil {
			continue
		}
		state := "fallback"
		searching := e.probing && e.probeLane == config.ID
		if lane.incumbent != "" {
			state = "active"
		} else if searching || (lane.candidates > 0 && !e.laneExhausted(config.ID)) {
			state = "searching"
		}
		statuses = append(statuses, rcxLaneStatus{
			ID:         config.ID,
			Group:      config.Group,
			State:      state,
			Node:       lane.incumbent,
			Candidates: lane.candidates,
			Eligible:   lane.eligible,
			Searching:  searching,
			Fallback:   config.Fallback,
			Reason:     string(lane.reason),
			SwitchedAt: rcxMillis(lane.switchedAt),
		})
	}
	return statuses
}

// A lane is exhausted once its rescue episode has measured every match it has;
// until then it is still searching, however its group is routed meanwhile.
func (e *rcxEngine) laneExhausted(id string) bool {
	return !e.laneProbeAt[id].IsZero()
}

func (e *rcxEngine) laneProbeReplacement(lane *rcxLaneState, node string, now time.Time) bool {
	candidates := e.laneCandidates(lane, e.runtime.Members())
	input := rcxDecisionInput{
		Terrain:        e.terrainCurrent(),
		Incumbent:      lane.incumbent,
		IncumbentSince: lane.since,
		Candidates:     candidates,
		Policy:         e.lanePolicy(lane.config),
		Now:            now,
	}
	for _, candidate := range candidates {
		if candidate.Name == node {
			return rcxEligible(candidate, input)
		}
	}
	return false
}

func (e *rcxEngine) queueLaneRecovery() {
	if e.probing {
		return
	}
	if e.laneBurst >= 2 && e.startImprovement(true) {
		return
	}
	members := e.runtime.Members()
	if len(members) == 0 {
		return
	}
	for _, config := range e.cfg.Lanes {
		lane := e.lanes[config.ID]
		if lane == nil || lane.incumbent != "" || lane.candidates == 0 ||
			len(config.Selectors) == 0 {
			continue
		}
		if e.startLaneProbe(lane, members) {
			return
		}
	}
}

func (e *rcxEngine) startLaneProbe(lane *rcxLaneState, members []rcxMember) bool {
	candidates := e.laneCandidates(lane, members)
	byName := make(map[string]rcxCandidate, len(candidates))
	pool := make([]rcxProbeNode, 0, len(candidates))
	seen := e.laneProbeSeen[lane.config.ID]
	if len(seen) > 0 && !e.laneProbeAt[lane.config.ID].IsZero() &&
		e.runtime.Now().Sub(e.laneProbeAt[lane.config.ID]) >= rcxRescueRepeat {
		seen = nil
		delete(e.laneProbeSeen, lane.config.ID)
	}
	if seen == nil {
		seen = map[string]struct{}{}
		e.laneProbeSeen[lane.config.ID] = seen
	}
	for i, candidate := range candidates {
		byName[candidate.Name] = candidate
		if !candidate.InSkeleton {
			continue
		}
		if _, measured := seen[candidate.Name]; measured {
			continue
		}
		member := members[i]
		pool = append(pool, rcxProbeNode{
			Name: candidate.Name, Key: member.key(), Provider: member.Provider,
			Transport: member.Transport, Type: member.Type, Port: member.Port,
		})
	}
	if len(pool) == 0 {
		if e.laneProbeAt[lane.config.ID].IsZero() {
			e.laneProbeAt[lane.config.ID] = e.runtime.Now()
		}
		return false
	}
	width := e.cfg.WaveWidth
	if width > len(pool) {
		width = len(pool)
	}
	rank := map[string]int{}
	if lane.incumbent != "" {
		rank[lane.incumbent] = 0
	}
	if e.snapshot != nil {
		if picks := e.snapshot.LanePicks[lane.config.ID]; picks != nil {
			rank[e.nameOf(picks[e.envKey])] = 1
		}
	}
	for index, node := range e.laneStandbyNames(lane) {
		rank[node] = 2 + index
	}
	sort.SliceStable(pool, func(i, j int) bool {
		ri, iok := rank[pool[i].Name]
		rj, jok := rank[pool[j].Name]
		if iok != jok {
			return iok
		}
		if iok && ri != rj {
			return ri < rj
		}
		return byName[pool[i].Name].Evidence < byName[pool[j].Name].Evidence
	})
	pool = rcxUniqueProbeNodes(pool, lane.incumbent)
	wave := pool[:min(width, len(pool))]
	wave = e.afford(wave, rcxProbeReserve+e.discoveryProtected(e.runtime.Now()), e.runtime.Now())
	if len(wave) == 0 {
		return false
	}
	for _, node := range wave {
		seen[node.Name] = struct{}{}
	}
	e.laneProbeAt[lane.config.ID] = time.Time{}
	e.startProbeWave(wave, rcxWaveRescue, lane.config.ID)
	return true
}

func (e *rcxEngine) screenTargetEligible(node, incumbent string, lane *rcxLaneState, now time.Time) bool {
	members := e.runtime.Members()
	candidates := e.candidatesFor(members, incumbent)
	if lane != nil {
		byName := make(map[string]rcxMember, len(members))
		for _, member := range members {
			byName[member.Name] = member
		}
		groups := e.laneGroupSets(lane.config)
		for i := range candidates {
			member, ok := byName[candidates[i].Name]
			candidates[i].InSkeleton = ok && rcxLaneMatches(lane.config, member, groups) &&
				rcxLaneRoleAdmits(lane.config.Role, candidates[i].Facts)
		}
	}
	policy := e.cfg.policy()
	if lane != nil {
		policy = e.lanePolicy(lane.config)
	}
	input := rcxDecisionInput{
		Terrain: e.terrainCurrent(), Incumbent: incumbent, Candidates: candidates,
		Policy: policy, Now: now,
	}
	for _, candidate := range candidates {
		if candidate.Name == node {
			return rcxEligible(candidate, input) && candidate.Facts.OpenWorld == rcxProofProven
		}
	}
	return false
}

func (e *rcxEngine) tryAutomaticMainSelect(to string, reason rcxReason, now time.Time) bool {
	from := e.incumbent
	if to == "" || to == from {
		return false
	}
	if e.screenOff {
		if e.screenFailedOver || e.screenDead != from || !rcxDeathSwitch(reason) ||
			!e.screenTargetEligible(to, from, nil, now) {
			return false
		}
	}
	if !e.automaticMainAllowed(to, reason, now) {
		return false
	}
	if err := e.runtime.Select(to); err != nil {
		return false
	}
	if rcxDeathSwitch(reason) {
		e.runtime.CloseConnections(e.drainIDs(from))
	}
	e.noteSwitch(from, to, reason, now)
	if e.screenOff {
		e.screenFailedOver = true
		e.sealProbeDecision()
	}
	return true
}

func (e *rcxEngine) tryAutomaticLaneSelect(lane *rcxLaneState, to string, reason rcxReason, now time.Time) bool {
	from := lane.incumbent
	if to == "" || to == from {
		return false
	}
	if e.screenOff {
		if lane.screenFailoverUsed || lane.screenConfirmedDead != from || !rcxDeathSwitch(reason) ||
			!e.screenTargetEligible(to, from, lane, now) {
			return false
		}
	} else if !e.screenTargetEligible(to, from, lane, now) {
		return false
	}
	if err := e.runtime.SelectIn(lane.config.Group, to); err != nil {
		return false
	}
	lane.incumbent = to
	lane.since = now
	lane.switchedAt = now
	if e.snapshot != nil {
		picks := e.snapshot.LanePicks[lane.config.ID]
		if picks == nil {
			picks = map[string]string{}
			e.snapshot.LanePicks[lane.config.ID] = picks
		}
		picks[e.envKey] = e.key(to)
		e.snapshot.Dirty = true
	}
	if e.screenOff {
		lane.screenFailoverUsed = true
	}
	e.sealProbeDecision()
	return true
}

func (e *rcxEngine) sealProbeDecision() {
	e.probeDecisionClosed = true
	if e.probeCancel != nil {
		e.probeCancel()
	}
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
	e.reconsiderLanes(members, now)

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
	if e.holdsManualPick() && decision.Reason != rcxReasonManualHold {
		e.verifyManualPick(members, now)
		decision = rcxDecision{Reason: rcxReasonManualHold, Detail: e.incumbent}
	}
	odometerInstance.NoteAutoDecision()

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
		if e.tryAutomaticMainSelect(decision.To, decision.Reason, now) {
			input.Incumbent = decision.To
			input.IncumbentSince = now
		} else {
			decision.Switch = false
			decision.To = ""
			decision.Reason = rcxReasonHold
		}
	} else if !decision.Switch && decision.To == "" && (decision.Reason == rcxReasonHold || decision.Reason == rcxReasonManualHold) {
		e.reassertIncumbent()
	}

	if e.pendingHandoff && !e.probing {
		if !e.awaitsHostSweep(now) {
			e.pendingHandoff = false
			e.startProbe(candidates, members, rcxWaveHandoff)
		}
	} else if e.pendingGrant && !e.probing {
		e.pendingGrant = false
		e.startProbe(candidates, members, rcxWaveGrant)
	} else if e.needsProbe(decision, candidates) {
		kind := rcxWaveRoutine
		if decision.Reason == rcxReasonStranded || decision.Reason == rcxReasonNoCandidate {
			kind = rcxWaveRescue
		}
		e.startProbe(candidates, members, kind)
	}
	if e.probing && (decision.Reason == rcxReasonStranded || decision.Reason == rcxReasonNoCandidate) {
		decision.Reason = rcxReasonMeasuring
	}
	if !e.probing {
		e.queueLaneRecovery()
	}

	ranked := rcxRank(input)
	e.rebuildStandbys(ranked)
	e.publish(decision.Reason, ranked, input)
}

// A domestic canary that answers proves the direct path lives, while a home
// service through a foreign egress breaks: they tunnel only when it dies.
func (e *rcxEngine) applyDirectSplit() {
	if !e.Enabled() || e.screenOff {
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

func (e *rcxEngine) accountMetrics(now time.Time) {
	if e.snapshot == nil {
		return
	}
	if e.accountedAt.IsZero() {
		e.accountedAt = now
		return
	}
	elapsed := now.Sub(e.accountedAt)
	e.accountedAt = now
	if elapsed <= 0 || !e.Enabled() || (!e.suspendAt.IsZero() && e.suspendTo.Equal(e.suspendAt)) {
		return
	}
	e.snapshot.Metrics.EnabledMillis += elapsed.Milliseconds()
	if e.incidentAt.IsZero() {
		e.snapshot.Metrics.AvailableMillis += elapsed.Milliseconds()
	}
	e.snapshot.Dirty = true
}

func (e *rcxEngine) startIncident(now time.Time) {
	if e.snapshot == nil || !e.incidentAt.IsZero() {
		return
	}
	e.accountMetrics(now)
	e.incidentAt = now
	e.snapshot.Metrics.Incidents++
	e.snapshot.Dirty = true
}

func (e *rcxEngine) closeIncident(now time.Time, recovered bool) {
	if e.snapshot == nil || e.incidentAt.IsZero() {
		return
	}
	e.accountMetrics(now)
	outage := now.Sub(e.incidentAt)
	e.incidentAt = time.Time{}
	if recovered && outage >= 0 {
		millis := outage.Milliseconds()
		e.snapshot.Metrics.LastOutageMillis = millis
		e.snapshot.Metrics.TotalOutageMillis += millis
		e.snapshot.Metrics.RecoveredOutages++
		odometerInstance.NoteRecovery()
	}
	e.snapshot.Dirty = true
}

func (e *rcxEngine) recordFailover(now time.Time, standby bool) {
	if e.snapshot == nil || e.incidentAt.IsZero() {
		return
	}
	duration := now.Sub(e.incidentAt)
	if duration < 0 {
		duration = 0
	}
	millis := duration.Milliseconds()
	e.snapshot.Metrics.LastFailoverMillis = millis
	e.snapshot.Metrics.FailoverMillis += millis
	e.snapshot.Metrics.Failovers++
	if standby {
		e.snapshot.Metrics.StandbyHits++
	}
	e.closeIncident(now, true)
}

func (e *rcxEngine) metricsReport(now time.Time) rcxMetricsReport {
	e.accountMetrics(now)
	state := e.snapshot.Metrics
	report := rcxMetricsReport{
		EnabledMillis:     state.EnabledMillis,
		AvailableMillis:   state.AvailableMillis,
		Incidents:         state.Incidents,
		StandbyHits:       state.StandbyHits,
		ProviderIncidents: state.ProviderIncidents,
		MarkerIncidents:   state.MarkerIncidents,
		LastFailover:      state.LastFailoverMillis,
		LastOutage:        state.LastOutageMillis,
		ActiveCircuits:    e.activeCircuitReasons(now),
		ActiveMarkers:     e.activeMarkerReasons(now),
	}
	if state.EnabledMillis > 0 {
		report.Availability = int(state.AvailableMillis * 100 / state.EnabledMillis)
	}
	if state.Failovers > 0 {
		report.AverageFailover = state.FailoverMillis / int64(state.Failovers)
	}
	if state.RecoveredOutages > 0 {
		report.AverageOutage = state.TotalOutageMillis / int64(state.RecoveredOutages)
	}
	return report
}

func (e *rcxEngine) noteSwitch(from, to string, reason rcxReason, now time.Time) {
	standby := false
	for _, key := range e.snapshot.Standbys[e.envKey] {
		standby = standby || key == e.key(to)
	}
	if rcxDeathSwitch(reason) {
		e.recordFailover(now, standby)
	}
	odometerInstance.NoteCountry(e.ledger.ExitCountry(e.key(to)))
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
	rcxWaveIncident
	rcxWaveHandoff
	rcxWaveDeep
	rcxWaveDiscover
	rcxWaveQuality
)

// A trickle is a rate, so it hangs off the tick: one tick reconsiders often.
func (e *rcxEngine) maintain() {
	if !e.canImprove() || e.probing {
		return
	}
	if e.startImprovement(true) {
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
	if kind != rcxWaveDeep && e.terrain.terrain == rcxTerrainOffline {
		return nil
	}
	now := e.runtime.Now()
	if kind == rcxWaveMaintain {
		return e.planMaintenance(candidates, members)
	}
	reactive := kind == rcxWaveHandoff || kind == rcxWaveIncident || kind == rcxWaveRescue
	if reactive {
		e.prepareRescue(members)
		if e.rescueExhausted && !e.rescueAt.IsZero() && now.Sub(e.rescueAt) < rcxRescueRepeat {
			return nil
		}
		if e.rescueExhausted {
			e.resetRescue()
			e.prepareRescue(members)
		}
	}

	halfOpen := map[string]struct{}{}
	if kind == rcxWaveRoutine || kind == rcxWaveMaintain {
		halfOpen = e.circuitHalfOpenMembers(members, now)
	}
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
		if candidate.Circuit && !reactive && kind != rcxWaveDeep {
			if _, allowed := halfOpen[member.Provider]; !allowed {
				continue
			}
			delete(halfOpen, member.Provider)
		}
		if kind == rcxWaveMaintain {
			if !e.proofDue(member.Name, now) {
				continue
			}
		} else if !reactive && kind != rcxWaveDeep && member.Name != suspect &&
			candidate.Evidence == rcxEvidenceLiveTraffic {
			continue
		}
		if kind == rcxWaveRoutine || kind == rcxWaveMaintain {
			if !candidate.CoolUntil.IsZero() && now.Before(candidate.CoolUntil) {
				continue
			}
		}
		if reactive {
			if _, seen := e.rescueSeen[member.Name]; seen {
				continue
			}
		}
		stamps[member.Name] = e.ledger.ProbeAt(member.key(), e.envKey)
		pool = append(pool, rcxProbeNode{
			Name:      member.Name,
			Key:       member.key(),
			Provider:  member.Provider,
			Transport: member.Transport,
			Type:      member.Type,
			Port:      member.Port,
		})
	}
	pool = rcxUniqueProbeNodes(pool, e.incumbent)
	if kind == rcxWaveRoutine {
		sort.SliceStable(pool, func(i, j int) bool { return stamps[pool[i].Name].Before(stamps[pool[j].Name]) })
	}
	if suspect != "" {
		rcxHoistNode(pool, suspect)
	}
	if pin := e.pin(); pin != "" && pin != e.incumbent {
		if candidate, ok := byName[pin]; ok && candidate.Facts.Transit != rcxProofProven {
			rcxHoistNode(pool, pin)
		}
	}

	if kind == rcxWaveMaintain {
		rcxHoistNodes(pool, e.standbyNames())
		rcxHoistNode(pool, e.incumbent)
		if len(pool) > rcxMaintainWidth {
			pool = pool[:rcxMaintainWidth]
		}
		return e.afford(pool, rcxProbeReserve, now)
	}

	width := e.cfg.WaveWidth
	if kind == rcxWaveDeep {
		width = len(pool)
	} else if kind == rcxWaveHandoff && width > rcxHandoffWidth {
		width = rcxHandoffWidth
	}
	var wave []rcxProbeNode
	if reactive {
		wave = e.memoryFirstWave(pool, byName, width, now)
	} else {
		wave = append([]rcxProbeNode(nil), pool[:min(width, len(pool))]...)
	}
	if len(wave) == 0 {
		if reactive {
			e.rescueExhausted = true
			e.rescueAt = now
		}
		return nil
	}
	if reactive {
		for _, node := range wave {
			e.rescueSeen[node.Name] = struct{}{}
		}
		e.rescueExhausted = len(wave) == len(pool)
		if e.rescueExhausted {
			e.rescueAt = now
		}
	}
	e.paidWave = 0
	e.paidWaveGen = e.probeGen
	if kind == rcxWaveRoutine || kind == rcxWaveIncident || kind == rcxWaveHandoff {
		return e.afford(wave, 0, now)
	}
	return wave
}

func (e *rcxEngine) memoryFirstWave(
	pool []rcxProbeNode,
	candidates map[string]rcxCandidate,
	width int,
	now time.Time,
) []rcxProbeNode {
	if width <= 0 {
		return nil
	}
	memoryRank := map[string]int{}
	remember := func(node string, rank int) {
		if node == "" {
			return
		}
		if old, ok := memoryRank[node]; !ok || rank < old {
			memoryRank[node] = rank
		}
	}
	remember(e.incumbent, 0)
	remember(e.pin(), 1)
	if e.snapshot != nil {
		remember(e.nameOf(e.snapshot.Picks[e.envKey]), 2)
	}
	for index, node := range e.standbyNames() {
		remember(node, 3+index)
	}

	const tiers = 6
	grouped := make([][]rcxProbeNode, tiers)
	freshGreen := make(map[string]bool, len(pool))
	green := make(map[string]bool, len(pool))
	for _, node := range pool {
		candidate := candidates[node.Name]
		green[node.Name] = candidate.HostMs > 0 && !candidate.HostDead
		freshGreen[node.Name] = green[node.Name] && !candidate.HostAt.IsZero() &&
			now.Sub(candidate.HostAt) <= time.Duration(rcxFreshWindowSeconds)*time.Second
		tier := 4
		_, remembered := memoryRank[node.Name]
		switch {
		case candidate.HostDead || candidate.Facts.Transit == rcxProofDisproven ||
			(!candidate.CoolUntil.IsZero() && now.Before(candidate.CoolUntil)) ||
			e.ledger.FailStreak(node.Key, e.envKey) > 0:
			tier = 5
		case remembered:
			tier = 0
		case candidate.Facts.OpenWorld == rcxProofProven || candidate.Facts.Domestic == rcxProofProven ||
			candidate.Facts.Transit == rcxProofProven || candidate.Evidence != rcxEvidenceNone ||
			e.ledger.PreviouslyGood(node.Key, e.envKey):
			tier = 1
		case green[node.Name] && candidate.Facts.Origin != rcxOriginDomestic:
			tier = 2
		case green[node.Name]:
			tier = 3
		}
		grouped[tier] = append(grouped[tier], node)
	}

	for tier := range grouped {
		sort.SliceStable(grouped[tier], func(i, j int) bool {
			a, b := grouped[tier][i].Name, grouped[tier][j].Name
			if tier == 0 && memoryRank[a] != memoryRank[b] {
				return memoryRank[a] < memoryRank[b]
			}
			if freshGreen[a] != freshGreen[b] {
				return freshGreen[a]
			}
			if green[a] != green[b] {
				return green[a]
			}
			ca, cb := candidates[a], candidates[b]
			if tier < 4 {
				if ca.Recurrence != cb.Recurrence {
					return ca.Recurrence < cb.Recurrence
				}
				aMs, bMs := rcxDiscoveryLatency(ca), rcxDiscoveryLatency(cb)
				if aMs > 0 && bMs > 0 && aMs != bMs {
					return aMs < bMs
				}
			}
			return false
		})
	}

	wave := make([]rcxProbeNode, 0, width)
	for tier, nodes := range grouped {
		if len(wave) == width {
			break
		}
		ordered := nodes
		if tier == 4 {
			ordered = rcxEmergencyOrder(nodes, width-len(wave))
		}
		left := width - len(wave)
		if len(ordered) > left {
			ordered = ordered[:left]
		}
		wave = append(wave, ordered...)
	}
	return wave
}

type rcxRescueStamp struct {
	terrain rcxTerrain
	env     string
	park    string
}

func (e *rcxEngine) prepareRescue(members []rcxMember) {
	keys := make([]string, 0, len(members))
	for _, member := range members {
		keys = append(keys, member.key())
	}
	sort.Strings(keys)
	stamp := rcxRescueStamp{terrain: e.terrain.terrain, env: e.envKey, park: strings.Join(keys, "\x00")}
	if e.rescueMark == stamp {
		return
	}
	e.resetRescue()
	e.rescueMark = stamp
}

func (e *rcxEngine) resetRescue() {
	e.rescueAt = time.Time{}
	e.rescueMark = rcxRescueStamp{}
	e.rescueSeen = map[string]struct{}{}
	e.rescueExhausted = false
}

func (e *rcxEngine) recoveryWave() bool {
	return e.probeKind == rcxWaveHandoff || e.probeKind == rcxWaveIncident || e.probeKind == rcxWaveRescue
}

// A trickle stops at a reserve, or it starves the waves that answer an event.
func (e *rcxEngine) afford(wave []rcxProbeNode, reserve int, now time.Time) []rcxProbeNode {
	e.paidWave = 0
	e.paidWaveGen = e.probeGen
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
	e.paidAt = now
	return wave[:affordable]
}

func (e *rcxEngine) exitDue(key string, now time.Time) bool {
	at := e.ledger.ExitAt(key)
	return at.IsZero() || now.Sub(at) >= rcxExitTTL
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
	if e.wakePending || e.suspended {
		return
	}
	wave := e.planWave(candidates, members, kind)
	if len(wave) == 0 {
		return
	}
	e.startProbeWave(wave, kind, "")
}

func (e *rcxEngine) startProbeWave(wave []rcxProbeNode, kind rcxWaveKind, lane string) {
	targets := e.probeTargets(wave, e.terrainCurrent(), kind)
	e.probeGen++
	e.paidWaveGen = e.probeGen
	if e.receipts == nil {
		e.receipts = map[uint32]rcxWaveReceipt{}
	}
	e.receipts[e.probeGen] = rcxWaveReceipt{
		Paid:        e.paidWave,
		ReservedAt:  e.paidAt,
		Environment: e.envKey,
		Discovery:   kind == rcxWaveDiscover,
		Quality:     kind == rcxWaveQuality,
	}
	if lane != "" {
		e.laneBurst++
	}
	e.probing = true
	e.probeLaunchedAt = e.runtime.Now()
	e.probeKind = kind
	e.probeLane = lane
	e.probeResults = nil
	e.probeStarted = map[string]struct{}{}
	e.probeRecovered = false
	e.probeDecisionClosed = false
	e.probeScreenOff = e.screenOff
	e.probeScreenEpisode = e.screenEpisode
	e.probeIncumbent = e.incumbent
	if lane != "" {
		if state := e.lanes[lane]; state != nil {
			e.probeIncumbent = state.incumbent
		}
	}
	gen := e.probeGen
	configGen := e.configGen
	prober := newRcxProber(e.runtime.Test, e.runtime.Locate)
	window := rcxProbeWave
	if kind == rcxWaveHandoff {
		window = rcxHandoffWave
		prober.concurrency = rcxHandoffParallel
		prober.timeout = rcxHandoffTimeout
	} else if kind == rcxWaveRescue || kind == rcxWaveIncident {
		window = rcxRescueWave
		prober.concurrency = rcxSweepParallel
		prober.timeout = rcxSweepTimeout
	} else if kind == rcxWaveDeep {
		window = rcxDeepProbeWave
		prober.concurrency = rcxSweepParallel
		prober.timeout = rcxSweepTimeout
	}
	quit := e.quit
	ctx, cancel := context.WithTimeout(context.Background(), window)
	e.probeCancel = cancel
	safeGoDetached("rcx probe wave", func() {
		defer cancel()
		var spentMu sync.Mutex
		spent := map[string]bool{}
		prober.Stream(ctx, targets, func(_ int, result rcxProbeResult) {
			if result.Dispatched {
				spentMu.Lock()
				spent[result.Node] = true
				spentMu.Unlock()
			}
			e.sendResult(rcxEvent{Kind: rcxEventProbeResult, Results: []rcxProbeResult{result}, Gen: gen, ConfigGen: configGen, Lane: lane}, quit)
		})
		e.sendResult(rcxEvent{Kind: rcxEventProbeResults, Gen: gen, ConfigGen: configGen, Lane: lane, Accounting: true, Dispatched: len(spent)}, quit)
	})
}

// Off a normal terrain every node is asked both markers, the origin only orders.
func (e *rcxEngine) probeTargets(
	wave []rcxProbeNode,
	terrain rcxTerrain,
	kind rcxWaveKind,
) []rcxProbeTarget {
	if kind == rcxWaveQuality {
		for _, marker := range e.activeMarkers(rcxRoleOpen, e.runtime.Now()) {
			if rcxMarkerID(rcxRoleOpen, marker) == e.quality.Marker {
				targets := make([]rcxProbeTarget, 0, len(wave))
				for _, node := range wave {
					targets = append(targets, rcxProbeTarget{Node: node.Name, Key: node.Key, Role: rcxRoleOpen, Markers: []rcxMarker{marker}})
				}
				return targets
			}
		}
		return nil
	}
	paired := kind == rcxWaveRescue || kind == rcxWaveIncident || kind == rcxWaveHandoff || kind == rcxWaveDeep
	now := e.runtime.Now()
	open := rcxProbeTarget{Role: rcxRoleOpen, Markers: e.activeMarkers(rcxRoleOpen, now)}
	both := len(e.cfg.DomesticMarkers) > 0 &&
		(terrain == rcxTerrainWhitelist || terrain == rcxTerrainUnknown)
	// The canaries decide the terrain; asking a second marker here only halves
	// the nodes a handoff can reach inside its window.
	if kind == rcxWaveHandoff && terrain == rcxTerrainUnknown {
		both = false
	}
	home := rcxProbeTarget{Role: rcxRoleDomestic, Markers: e.activeMarkers(rcxRoleDomestic, now)}
	primaries := make([]rcxProbeTarget, 0, len(wave))
	secondaries := make([]rcxProbeTarget, 0, len(wave))
	for _, node := range wave {
		primary, secondary := open, home
		if both && e.ledger.Origin(node.Key) == rcxOriginDomestic {
			primary, secondary = home, open
		}
		primary.Node, primary.Key = node.Name, node.Key
		secondary.Node, secondary.Key = node.Name, node.Key
		if len(e.cfg.EgressEchoes) > 0 && e.exitDue(node.Key, now) {
			if primary.Role == rcxRoleOpen {
				primary.Echoes = e.cfg.EgressEchoes
			} else {
				secondary.Echoes = e.cfg.EgressEchoes
			}
		}
		if len(primary.Markers) > 0 || len(primary.Echoes) > 0 {
			primaries = append(primaries, primary)
		}
		if !both || len(secondary.Markers) == 0 && len(secondary.Echoes) == 0 {
			continue
		}
		if paired {
			primaries = append(primaries, secondary)
		} else {
			secondaries = append(secondaries, secondary)
		}
	}
	return append(primaries, secondaries...)
}

func (e *rcxEngine) startReach() {
	if !e.Enabled() || e.reaching || e.screenOff || e.suspended ||
		len(e.cfg.CanaryForeign) == 0 {
		return
	}
	e.lastReachAt = e.runtime.Now()
	foreign := append([]string(nil), e.cfg.CanaryForeign...)
	domestic := append([]string(nil), e.cfg.CanaryDomestic...)
	e.reaching = true
	if len(e.charged) >= e.escrowQuorum() {
		e.escrowReach = true
	}
	dial := rcxCanaryTimeout
	if e.reachWarm {
		dial = rcxCanaryWarmup
	}
	gen := e.reachGen
	configGen := e.configGen
	quit := e.quit
	ctx, cancel := context.WithCancel(context.Background())
	e.reachCancel = cancel
	safeGoDetached("rcx canary round", func() {
		var (
			domesticRows    []rcxCanaryReport
			domesticOutcome rcxProbeOutcome
		)
		done := make(chan struct{})
		safeGoDetached("rcx canary domestic", func() {
			defer close(done)
			domesticOutcome = e.reachGroup(ctx, domestic, true, dial, &domesticRows)
		})
		foreignRows := make([]rcxCanaryReport, 0, len(foreign))
		foreignOutcome := e.reachGroup(ctx, foreign, false, dial, &foreignRows)
		<-done
		e.sendResult(rcxEvent{
			Kind:      rcxEventTerrainReach,
			Foreign:   foreignOutcome,
			Domestic:  domesticOutcome,
			Canaries:  append(foreignRows, domesticRows...),
			Gen:       gen,
			ConfigGen: configGen,
		}, quit)
	})
}

// Each group owns its deadline, or foreign timeouts spend the domestic dials.
func (e *rcxEngine) reachGroup(
	parent context.Context,
	addresses []string,
	domestic bool,
	dial time.Duration,
	rows *[]rcxCanaryReport,
) rcxProbeOutcome {
	ctx, cancel := context.WithTimeout(parent, dial+2*time.Second)
	defer cancel()
	return e.reachAny(ctx, addresses, domestic, dial, rows)
}

// In order, one black-holed address spends the round the others needed.
func (e *rcxEngine) reachAny(
	ctx context.Context,
	addresses []string,
	domestic bool,
	dial time.Duration,
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
			dialCtx, cancelDial := context.WithTimeout(ctx, dial)
			defer cancelDial()
			outcome = e.runtime.Reach(dialCtx, address, domestic)
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
		Searching:  e.probing && e.probeLane == "",
		Deep:       e.deep,
		Pinned:     input.Pin != "",
		PinNode:    input.Pin,
		Direct:     e.direct,
		Candidates: len(ranked),
		Eligible:   eligible,
		SwitchedAt: rcxMillis(e.switchedAt),
		Lanes:      e.laneStatuses(),
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
		History:    append([]rcxSwitchReport(nil), e.history...),
		Metrics:    e.metricsReport(now),
		Bands:      rcxLatencyBands(),
		ProbesLeft: e.budget.Remaining(now),
		ProbeCap:   rcxProbeBudgetCap,
		Manual:     input.Pin != "",
		Discovery:  e.discoveryReport(),
		At:         rcxMillis(now),
	}

	e.mu.Lock()
	changed := !reflect.DeepEqual(e.status, status)
	e.status = status
	e.report = report
	e.reportRanked = append(e.reportRanked[:0], ranked...)
	e.reportInput = input
	e.reportVersion++
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
			Node:       candidate.Name,
			Country:    e.ledger.Country(e.key(candidate.Name)),
			Exit:       e.freshExitCountry(e.key(candidate.Name), now),
			Origin:     candidate.Facts.Origin.String(),
			Verdict:    rcxAdmit(input.Terrain, candidate.Facts).String(),
			Evidence:   candidate.Evidence.String(),
			Block:      string(row.Block),
			DelayMs:    candidate.MedianMs,
			HostMs:     candidate.HostMs,
			Band:       int(row.Key.latBucket),
			LatencyMs:  rcxDiscoveryLatency(candidate),
			Unproven:   row.Key.unproven,
			Order:      row.Key.order,
			Breaker:    candidate.Facts.Breaker,
			Degraded:   candidate.Degraded,
			Recurrence: candidate.Recurrence,
			Confirmed:  candidate.QualityConfirmed,
			UDP:        candidate.Facts.SupportsUDP,
			Fails:      e.ledger.FailStreak(e.key(candidate.Name), e.envKey),
			CoolFor:    cool,
			Current:    candidate.Name == e.incumbent,
		})
	}
	return rows
}

func (e *rcxEngine) persist(force bool) {
	if e.snapshot == nil || !force && !e.snapshot.Dirty && !e.store.Pending() {
		return
	}
	now := e.runtime.Now()
	e.accountMetrics(now)
	active := map[string]struct{}{}
	for _, member := range e.runtime.Members() {
		active[member.key()] = struct{}{}
	}
	protected := map[string]struct{}{}
	keys := make([]string, 0, 3+len(e.snapshot.Standbys[e.envKey]))
	keys = append(keys, e.key(e.incumbent), e.snapshot.Picks[e.envKey], e.snapshot.Pins[e.envKey])
	for _, pick := range e.snapshot.Picks {
		keys = append(keys, pick)
	}
	for _, pin := range e.snapshot.Pins {
		keys = append(keys, pin)
	}
	for _, standbys := range e.snapshot.Standbys {
		keys = append(keys, standbys...)
	}
	for id, lane := range e.lanes {
		keys = append(keys, e.key(lane.incumbent))
		if picks := e.snapshot.LanePicks[id]; picks != nil {
			for _, pick := range picks {
				keys = append(keys, pick)
			}
		}
		if standbys := e.snapshot.LaneStandbys[id]; standbys != nil {
			for _, envStandbys := range standbys {
				keys = append(keys, envStandbys...)
			}
		}
	}
	for _, key := range keys {
		if key != "" {
			protected[key] = struct{}{}
		}
	}
	e.ledger.MarkMembers(active, now)
	e.ledger.Prune(active, protected, now)
	e.snapshot.Global, e.snapshot.Envs = e.ledger.Export()
	e.store.Save(e.snapshot, now, force)
}
