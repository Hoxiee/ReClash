package rcx

import (
	"context"
	"sync"
	"time"

	"github.com/metacubex/mihomo/tunnel/statistic"
)

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
	TestURL() string
	Publish(status rcxStatus)
	Now() time.Time
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
	odometer       Odometer
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
	pendingSweep     bool

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
	openMiss            map[string]time.Time
	locateAt            map[string]time.Time
	accountedAt         time.Time
	incidentAt          time.Time
}

func newRcxEngine(runtime rcxRuntime) *rcxEngine {
	return &rcxEngine{
		runtime:       runtime,
		odometer:      rcxNoopOdometer{},
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
		openMiss:      map[string]time.Time{},
		locateAt:      map[string]time.Time{},
		rescueSeen:    map[string]struct{}{},
		lanes:         map[string]*rcxLaneState{},
		laneProbeSeen: map[string]map[string]struct{}{},
		laneProbeAt:   map[string]time.Time{},
	}
}

// SetOdometer swaps in the host's counter. The host calls it once at startup;
// left unset the engine keeps its no-op, so tests need not wire one.
func (e *rcxEngine) SetOdometer(o Odometer) {
	if o == nil {
		o = rcxNoopOdometer{}
	}
	e.odometer = o
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

// ExitCountryFor returns a node's last measured exit country, or "" when the
// ledger never proved one. It reads stored state only and issues no geo query.
func (e *rcxEngine) ExitCountryFor(node string) string {
	return e.ledger.ExitCountry(e.key(node))
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

// Flips the hot-path gate directly for host tests that drive the suspend and dial
// hooks against an engine whose control loop is not running.
func (e *rcxEngine) SetEnabledForTest(enabled bool) {
	e.mu.Lock()
	e.enabled = enabled
	e.mu.Unlock()
}
func (e *rcxEngine) NoteHarvestedProbe(url, node string, delayMs int) {
	if !e.Enabled() || url != e.runtime.TestURL() {
		return
	}
	e.send(rcxEvent{Kind: rcxEventHarvested, Node: node, DelayMs: delayMs})
}

// The host's changeProxy already wrote the selector: the engine only pins.
func (e *rcxEngine) OnManualAsserted(node string) {
	e.control.Pick(rcxEvent{Kind: rcxEventManualAssert, Node: node})
}
func (e *rcxEngine) DeepScan() { e.control.DeepScan() }

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
