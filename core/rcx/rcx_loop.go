package rcx

import (
	"time"
)

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
	rcxWarmPoolCap    = 16
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
