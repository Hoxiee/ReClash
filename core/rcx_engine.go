package main

import (
	"context"
	"sync"
	"time"
)

type rcxMember struct {
	Name        string
	Type        string
	Port        int
	SupportsUDP bool
	Order       uint16
}

type rcxTrafficSample struct {
	Up   int64
	Down int64
}

// Comparable on purpose: publish diffs it to keep the host from redrawing on
// every tick, so it carries only the summary the hero row needs.
type rcxStatus struct {
	Enabled    bool   `json:"enabled"`
	Preset     string `json:"preset"`
	Mode       string `json:"mode"`
	Terrain    string `json:"terrain"`
	Env        string `json:"env"`
	Node       string `json:"node"`
	DelayMs    int    `json:"delay"`
	Reason     string `json:"reason"`
	Searching  bool   `json:"searching"`
	Deep       bool   `json:"deep"`
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
	ManualTill int64                `json:"manualTill"`
	At         int64                `json:"at"`
}

// The seam that keeps the actor testable: everything touching tunnel locks,
// mmdb, the statistics manager or the host message queue lives behind it.
type rcxRuntime interface {
	Members() []rcxMember
	Selected() string
	Select(node string) error
	Mode() string
	Country(node string) string
	Test(ctx context.Context, node string, marker rcxMarker) (delayMs int, satisfied bool, err error)
	Reach(ctx context.Context, addr string) rcxProbeOutcome
	Traffic() map[string]rcxTrafficSample
	Publish(status rcxStatus)
	Now() time.Time
}

type rcxDialEvent struct {
	Node    string
	Source  string
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
}

const (
	rcxDialQueueSize  = 512
	rcxEventQueueSize = 64
	rcxTickInterval   = 30 * time.Second
	rcxProbeWave      = 20 * time.Second
	rcxDeepProbeWave  = 90 * time.Second
	rcxCanaryTimeout  = 3 * time.Second
	rcxProbeBudgetCap = 40
	rcxProbeBudgetWin = time.Hour
	rcxKeepPerEnv     = 64
	rcxHistoryDepth   = 12
)

type rcxEngine struct {
	runtime rcxRuntime
	ledger  *rcxLedger
	store   *rcxStore
	budget  *rcxProbeBudget

	dials  chan rcxDialEvent
	events chan rcxEvent
	wake   chan struct{}
	quit   chan struct{}
	done   chan struct{}

	// Guards only what other goroutines read: the enabled flag on the hot dial
	// path, the last published status and the report the host pulls.
	mu      sync.RWMutex
	enabled bool
	status  rcxStatus
	report  rcxReport

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
	manualTill time.Time
	suspendAt  time.Time
	suspendTo  time.Time
	traffic    map[string]rcxTrafficSample
	memberSet  map[string]struct{}
	history    []rcxSwitchReport
	probing    bool
	deep       bool
	reaching   bool
	started    bool
}

func newRcxEngine(runtime rcxRuntime) *rcxEngine {
	return &rcxEngine{
		runtime: runtime,
		ledger:  newRcxLedger(rcxDefaultLedgerPolicy()),
		store:   newRcxStore(),
		budget:  newRcxProbeBudget(rcxProbeBudgetCap, rcxProbeBudgetWin),
		cfg:     rcxDefaultConfig(),
		dials:   make(chan rcxDialEvent, rcxDialQueueSize),
		events:  make(chan rcxEvent, rcxEventQueueSize),
		wake:    make(chan struct{}, 1),
	}
}

// NoteDial runs on the dial path under configMux.RLock, so it must never take a
// core lock: a synchronous selector write here would deadlock against match().
func (e *rcxEngine) NoteDial(node, source string, failed bool, elapsed time.Duration, now time.Time) {
	if !e.Enabled() {
		return
	}
	select {
	case e.dials <- rcxDialEvent{
		Node:    node,
		Source:  source,
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
	go e.loop()
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

func (e *rcxEngine) Configure(config rcxConfig) {
	e.send(rcxEvent{Kind: rcxEventConfigure, Config: config})
}
func (e *rcxEngine) Network(payload rcxNetworkPayload) {
	e.send(rcxEvent{Kind: rcxEventNetwork, Payload: payload})
}
func (e *rcxEngine) OnConfigApplied()   { e.send(rcxEvent{Kind: rcxEventConfigApplied}) }
func (e *rcxEngine) OnProvidersLoaded() { e.send(rcxEvent{Kind: rcxEventProvidersLoaded}) }
func (e *rcxEngine) OnSuspend(suspended bool) {
	e.send(rcxEvent{Kind: rcxEventSuspend, Flag: suspended})
}
func (e *rcxEngine) SetEnabled(enabled bool) {
	e.send(rcxEvent{Kind: rcxEventSetEnabled, Flag: enabled})
}
func (e *rcxEngine) NoteHarvestedProbe(node string, delayMs int) {
	e.send(rcxEvent{Kind: rcxEventHarvested, Node: node, DelayMs: delayMs})
}
func (e *rcxEngine) NoteManualPick(node string) {
	e.send(rcxEvent{Kind: rcxEventManualPick, Node: node})
}
func (e *rcxEngine) DeepScan() { e.send(rcxEvent{Kind: rcxEventDeepScan}) }

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
		case event := <-e.events:
			e.handle(event)
		case <-e.wake:
			e.drainDials()
			e.reconsider()
		case <-ticker.C:
			e.drainDials()
			e.sampleTraffic()
			e.reconsider()
			e.persist(false)
		}
	}
}

func (e *rcxEngine) handle(event rcxEvent) {
	switch event.Kind {
	case rcxEventConfigure:
		e.applyConfigLocked(event.Config)
		e.reconsider()
		e.persist(true)
	case rcxEventNetwork:
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
		e.ledger.NoteHarvestedProbe(event.Node, e.envKey, event.DelayMs, e.runtime.Now())
	case rcxEventManualPick:
		e.applyManualPick(event.Node)
	case rcxEventDeepScan:
		e.startDeepScan()
	case rcxEventProbeResults:
		e.probing = false
		e.deep = false
		for _, result := range event.Results {
			e.ledger.NoteProbe(result.Node, e.envKey, result.Role, result.Outcome, result.DelayMs, e.runtime.Now())
		}
		e.reconsider()
		e.persist(false)
	case rcxEventTerrainReach:
		e.reaching = false
		e.reachF, e.reachD = event.Foreign, event.Domestic
		e.canaries = event.Canaries
		e.classifyTerrain()
		e.reconsider()
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
	e.cfg = config
	e.mu.Lock()
	e.enabled = config.operable()
	e.mu.Unlock()
	if e.snapshot != nil {
		e.snapshot.Config = config
	}
}

func (e *rcxEngine) applyNetwork(payload rcxNetworkPayload) {
	primary, secondary := rcxEnvKeys(payload)
	e.transport = payload.Transport
	e.metered = payload.Metered
	e.validated = payload.Validated
	e.portal = payload.CaptivePortal
	e.terrain.noteValidation(payload.Validated, e.runtime.Now())

	if primary != e.envKey {
		e.envKey = primary
		e.ledger.Migrate(secondary, primary)
		e.migratePick(secondary, primary)
		e.reachF, e.reachD = rcxProbeOverloaded, rcxProbeOverloaded
		e.incumbent = ""
		e.since = time.Time{}
		if pick, ok := e.snapshot.Picks[primary]; ok {
			e.incumbent = pick
		}
	}
	e.classifyTerrain()
	e.startReach()
	e.reconsider()
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

func (e *rcxEngine) classifyTerrain() {
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
	if !e.terrain.observe(terrain, now) {
		return
	}
	if terrain == rcxTerrainNormal {
		e.ledger.PromoteTerrainNormal(e.envKey)
	}
	e.snapshot.Regimes[e.envKey] = rcxRegimeMemory{Terrain: terrain, At: now}
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
	e.startReach()
	e.reconsider()
}

func (e *rcxEngine) applyManualPick(node string) {
	if node == "" {
		return
	}
	minutes := e.cfg.ManualHoldMinutes
	if minutes <= 0 {
		return
	}
	e.incumbent = node
	e.since = e.runtime.Now()
	e.manualTill = e.since.Add(time.Duration(minutes) * time.Minute)
	e.snapshot.Picks[e.envKey] = node
	e.reconsider()
}

// Evidence is only worth keeping while rules decide the route and only about
// nodes the skeleton actually offers: DIRECT and canary dials go through the same
// hook.
func (e *rcxEngine) drainDials() {
	now := e.runtime.Now()
	terrain := e.terrain.terrain
	keep := e.runtime.Mode() == "rule"
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
				e.ledger.NoteDialFailure(event.Node, event.Source, e.envKey, terrain, at)
				continue
			}
			e.ledger.NoteDialSuccess(event.Node, event.Source, e.envKey, event.Elapsed, at)
		default:
			return
		}
	}
}

// A node whose upload keeps growing while nothing comes back is being throttled,
// which no dial verdict can show: the handshake succeeded.
func (e *rcxEngine) sampleTraffic() {
	current := e.runtime.Traffic()
	previous := e.traffic
	e.traffic = current
	if previous == nil {
		return
	}
	for node, now := range current {
		before, ok := previous[node]
		if !ok {
			continue
		}
		if now.Up > before.Up && now.Down == before.Down {
			e.ledger.NoteDegraded(node, e.envKey, e.runtime.Now())
			continue
		}
		if now.Down > before.Down {
			e.ledger.ClearDegraded(node, e.envKey)
		}
	}
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
	if e.memberSet == nil {
		return true
	}
	_, ok := e.memberSet[node]
	return ok
}

func (e *rcxEngine) candidates(members []rcxMember) []rcxCandidate {
	now := e.runtime.Now()
	e.memberSet = make(map[string]struct{}, len(members))
	for _, member := range members {
		e.memberSet[member.Name] = struct{}{}
	}
	live := time.Duration(rcxLiveWindowSeconds) * time.Second
	fresh := time.Duration(rcxFreshWindowSeconds) * time.Second
	candidates := make([]rcxCandidate, 0, len(members))
	for _, member := range members {
		if e.ledger.Origin(member.Name) == rcxOriginUnknown {
			country, origin := e.originOf(member.Name)
			e.ledger.SetOrigin(member.Name, country, origin)
		}
		facts := e.ledger.Facts(member.Name, e.envKey, member.SupportsUDP, now)
		facts.Breaker = e.cfg.breaker(member.Name)
		candidates = append(candidates, rcxCandidate{
			Name:       member.Name,
			Order:      member.Order,
			Facts:      facts,
			Evidence:   e.ledger.Evidence(member.Name, e.envKey, now, live, fresh),
			MedianMs:   e.ledger.MedianMs(member.Name, e.envKey, now, e.suspendAt, e.suspendTo),
			CoolUntil:  e.ledger.CoolUntil(member.Name, e.envKey),
			InSkeleton: true,
			Degraded:   e.ledger.Degraded(member.Name, e.envKey, now),
		})
	}
	return candidates
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
	if !e.manualTill.IsZero() && now.After(e.manualTill) {
		e.manualTill = time.Time{}
	}
	if e.incumbent == "" {
		e.incumbent = e.runtime.Selected()
	}

	candidates := e.candidates(members)
	input := rcxDecisionInput{
		Terrain:        e.terrain.terrain,
		Incumbent:      e.incumbent,
		IncumbentSince: e.since,
		ManualHold:     !e.manualTill.IsZero(),
		Candidates:     candidates,
		Policy:         e.cfg.policy(),
		Now:            now,
	}
	decision := rcxDecide(input)

	if decision.Switch && decision.To != e.incumbent {
		if err := e.runtime.Select(decision.To); err == nil {
			e.noteSwitch(e.incumbent, decision.To, decision.Reason, now)
			input.Incumbent = decision.To
			input.IncumbentSince = now
		}
	}

	if e.needsProbe(decision, candidates) {
		e.startProbe(candidates, members, false)
	}
	e.publish(decision.Reason, rcxRank(input), input)
}

func (e *rcxEngine) noteSwitch(from, to string, reason rcxReason, now time.Time) {
	e.incumbent = to
	e.since = now
	e.switchedAt = now
	e.snapshot.Picks[e.envKey] = to
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

// Probes are bought, never scheduled: a decision that had nothing to go on, or
// one that could not route at all, is the only thing worth paying for.
func (e *rcxEngine) needsProbe(decision rcxDecision, candidates []rcxCandidate) bool {
	if e.probing {
		return false
	}
	switch decision.Reason {
	case rcxReasonNoCandidate, rcxReasonStranded, rcxReasonIncumbentDead, rcxReasonColdStart:
		return true
	}
	for _, candidate := range candidates {
		if candidate.Name == e.incumbent {
			return candidate.Evidence == rcxEvidenceNone
		}
	}
	return e.incumbent == ""
}

// A hand-asked sweep answers a question the user is looking at, so it ignores the
// metered narrowing and the hourly budget the background waves live under.
func (e *rcxEngine) startDeepScan() {
	if !e.Enabled() || e.probing || e.runtime.Mode() != "rule" {
		return
	}
	members := e.runtime.Members()
	if len(members) == 0 {
		return
	}
	e.deep = true
	e.startProbe(e.candidates(members), members, true)
	e.reconsider()
}

func (e *rcxEngine) startProbe(candidates []rcxCandidate, members []rcxMember, deep bool) {
	if len(e.cfg.OpenMarkers) == 0 {
		return
	}
	width, ok := rcxWavePlan(e.cfg, e.metered, true)
	if deep {
		width, ok = rcxDeepScanWidth, true
	}
	if !ok || width <= 0 {
		return
	}
	granted := width
	if !deep {
		granted = e.budget.Take(width, e.runtime.Now())
		if granted <= 0 {
			return
		}
	}

	byName := make(map[string]rcxCandidate, len(candidates))
	for _, candidate := range candidates {
		byName[candidate.Name] = candidate
	}
	pool := make([]rcxProbeNode, 0, len(members))
	for _, member := range members {
		candidate := byName[member.Name]
		if !deep && candidate.Evidence == rcxEvidenceLiveTraffic {
			continue
		}
		if !deep && !candidate.CoolUntil.IsZero() && e.runtime.Now().Before(candidate.CoolUntil) {
			continue
		}
		pool = append(pool, rcxProbeNode{Name: member.Name, Type: member.Type, Port: member.Port})
	}

	wave := rcxDiverseWave(pool, granted)
	if len(wave) == 0 {
		return
	}
	targets := make([]rcxProbeTarget, 0, len(wave))
	for _, node := range wave {
		role, marker := rcxRoleOpen, e.cfg.OpenMarkers[0]
		if e.terrain.terrain == rcxTerrainWhitelist &&
			e.ledger.Origin(node.Name) == rcxOriginDomestic &&
			len(e.cfg.DomesticMarkers) > 0 {
			role, marker = rcxRoleDomestic, e.cfg.DomesticMarkers[0]
		}
		targets = append(targets, rcxProbeTarget{Node: node.Name, Role: role, Marker: marker})
	}

	e.probing = true
	prober := newRcxProber(e.runtime.Test)
	window := rcxProbeWave
	if deep {
		window = rcxDeepProbeWave
	}
	go func() {
		ctx, cancel := context.WithTimeout(context.Background(), window)
		defer cancel()
		results := prober.Run(ctx, targets)
		e.send(rcxEvent{Kind: rcxEventProbeResults, Results: results})
	}()
}

func (e *rcxEngine) startReach() {
	if e.reaching || len(e.cfg.CanaryForeign) == 0 {
		return
	}
	foreign := append([]string(nil), e.cfg.CanaryForeign...)
	domestic := append([]string(nil), e.cfg.CanaryDomestic...)
	e.reaching = true
	go func() {
		ctx, cancel := context.WithTimeout(context.Background(), 2*rcxCanaryTimeout)
		defer cancel()
		rows := make([]rcxCanaryReport, 0, len(foreign)+len(domestic))
		foreignOutcome := e.reachAny(ctx, foreign, false, &rows)
		domesticOutcome := e.reachAny(ctx, domestic, true, &rows)
		e.send(rcxEvent{
			Kind:     rcxEventTerrainReach,
			Foreign:  foreignOutcome,
			Domestic: domesticOutcome,
			Canaries: rows,
		})
	}()
}

// The first answer settles the verdict, so the addresses after it stay unprobed
// and unreported rather than being invented as untested rows.
func (e *rcxEngine) reachAny(
	ctx context.Context,
	addresses []string,
	domestic bool,
	rows *[]rcxCanaryReport,
) rcxProbeOutcome {
	if len(addresses) == 0 {
		return rcxProbeOverloaded
	}
	worst := rcxProbeOverloaded
	for _, address := range addresses {
		started := e.runtime.Now()
		outcome := e.runtime.Reach(ctx, address)
		*rows = append(*rows, rcxCanaryReport{
			Addr:     address,
			Domestic: domestic,
			Outcome:  rcxOutcomeName(outcome),
			DelayMs:  int(e.runtime.Now().Sub(started) / time.Millisecond),
		})
		switch outcome {
		case rcxProbeOK:
			return rcxProbeOK
		case rcxProbeFail:
			worst = rcxProbeFail
		}
	}
	return worst
}

func (e *rcxEngine) delayOf(node string) int {
	if node == "" {
		return 0
	}
	return e.ledger.MedianMs(node, e.envKey, e.runtime.Now(), e.suspendAt, e.suspendTo)
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
		Terrain:    e.terrain.terrain.String(),
		Env:        e.envKey,
		Node:       e.incumbent,
		DelayMs:    e.delayOf(e.incumbent),
		Reason:     string(reason),
		Searching:  e.probing,
		Deep:       e.deep,
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
		ManualTill: rcxMillis(e.manualTill),
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
			Country:  e.ledger.Country(candidate.Name),
			Origin:   candidate.Facts.Origin.String(),
			Verdict:  rcxAdmit(input.Terrain, candidate.Facts).String(),
			Evidence: candidate.Evidence.String(),
			Block:    string(row.Block),
			DelayMs:  candidate.MedianMs,
			Band:     int(row.Key.latBucket),
			Breaker:  candidate.Facts.Breaker,
			Degraded: candidate.Degraded,
			UDP:      candidate.Facts.SupportsUDP,
			Fails:    e.ledger.FailStreak(candidate.Name, e.envKey),
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
