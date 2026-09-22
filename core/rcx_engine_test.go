package main

import (
	"context"
	"errors"
	"reflect"
	"sync"
	"testing"
	"time"

	C "github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/tunnel/statistic"
)

func TestPersistSkipsCleanSnapshot(t *testing.T) {
	runtime := newFakeRuntime()
	engine := newTestEngine(runtime, "ru")
	storage := newFakeStorage()
	engine.store = testStore(storage)
	engine.store.Load()
	engine.snapshot.Dirty = false

	engine.persist(false)

	if storage.writes != 0 {
		t.Fatalf("writes = %d, want no serialization for a clean snapshot", storage.writes)
	}
}

func TestEngineLifecycleCallsAreSerialized(t *testing.T) {
	e := newRcxEngine(newFakeRuntime())
	e.Start()

	var stops sync.WaitGroup
	stops.Add(2)
	for i := 0; i < 2; i++ {
		go func() {
			defer stops.Done()
			e.Stop()
		}()
	}
	stops.Wait()

	e.Start()
	e.Stop()
}

type fakeRuntime struct {
	mu            sync.Mutex
	members       []rcxMember
	memberReads   int
	topologyValid bool
	selected      string
	selects       []string
	selectErr     error
	mode          string
	countries     map[string]string
	exits         map[string]string
	results       map[string]rcxProbeResult
	reach         map[string]rcxProbeOutcome
	conns         map[string]rcxConnSample
	hang          map[string]bool
	panics        map[string]bool
	closed        []string
	published     []rcxStatus
	link          rcxNetworkPayload
	linked        bool
	now           time.Time
	tested        []string
	testStarted   chan string
	testRelease   chan struct{}
	swept         [][]string
	sweepStarted  chan struct{}
	sweepRelease  chan struct{}

	groupSelected map[string]string
	groupMembers  map[string][]string
}

func newFakeRuntime() *fakeRuntime {
	return &fakeRuntime{
		topologyValid: true,
		mode:          "rule",
		countries:     map[string]string{},
		exits:         map[string]string{},
		results:       map[string]rcxProbeResult{},
		reach:         map[string]rcxProbeOutcome{},
		conns:         map[string]rcxConnSample{},
		hang:          map[string]bool{},
		panics:        map[string]bool{},
		now:           time.Unix(1_700_000_000, 0),
	}
}

func (r *fakeRuntime) TopologyValid(rcxConfig) bool {
	r.mu.Lock()
	defer r.mu.Unlock()
	return r.topologyValid
}

func (r *fakeRuntime) Members() []rcxMember {
	r.mu.Lock()
	defer r.mu.Unlock()
	r.memberReads++
	return append([]rcxMember(nil), r.members...)
}

func (r *fakeRuntime) Selected() string {
	r.mu.Lock()
	defer r.mu.Unlock()
	return r.selected
}

func (r *fakeRuntime) Select(node string) error {
	r.mu.Lock()
	defer r.mu.Unlock()
	if r.selectErr != nil {
		return r.selectErr
	}
	r.selected = node
	r.selects = append(r.selects, node)
	return nil
}

func (r *fakeRuntime) SelectedIn(group string) string {
	r.mu.Lock()
	defer r.mu.Unlock()
	return r.groupSelected[group]
}

func (r *fakeRuntime) SelectIn(group, node string) error {
	r.mu.Lock()
	defer r.mu.Unlock()
	if r.selectErr != nil {
		return r.selectErr
	}
	if r.groupSelected == nil {
		r.groupSelected = map[string]string{}
	}
	r.groupSelected[group] = node
	return nil
}

func (r *fakeRuntime) GroupMembers(group string) []string {
	r.mu.Lock()
	defer r.mu.Unlock()
	return append([]string(nil), r.groupMembers[group]...)
}

func (r *fakeRuntime) Mode() string { return r.mode }

func (r *fakeRuntime) Country(node string) string { return r.countries[node] }

func (r *fakeRuntime) Locate(_ context.Context, node, _ string) string {
	r.mu.Lock()
	defer r.mu.Unlock()
	return r.exits[node]
}

func (r *fakeRuntime) Test(ctx context.Context, node string, _ rcxMarker) (int, bool, error) {
	r.mu.Lock()
	r.tested = append(r.tested, node)
	started := r.testStarted
	release := r.testRelease
	result, ok := r.results[node]
	r.mu.Unlock()
	if started != nil {
		select {
		case started <- node:
		case <-ctx.Done():
			return 0, false, ctx.Err()
		}
	}
	if release != nil {
		select {
		case <-release:
		case <-ctx.Done():
			return 0, false, ctx.Err()
		}
	}
	if !ok {
		return 0, false, context.DeadlineExceeded
	}
	switch result.Outcome {
	case rcxProbeOK:
		return result.DelayMs, true, nil
	case rcxProbeStatusMismatch:
		return result.DelayMs, false, nil
	default:
		return 0, false, context.DeadlineExceeded
	}
}

func (r *fakeRuntime) testedNodes() []string {
	r.mu.Lock()
	defer r.mu.Unlock()
	return append([]string(nil), r.tested...)
}

func (r *fakeRuntime) Sweep(ctx context.Context, nodes []string) {
	r.mu.Lock()
	r.swept = append(r.swept, append([]string(nil), nodes...))
	started, release := r.sweepStarted, r.sweepRelease
	r.mu.Unlock()
	if started != nil {
		select {
		case started <- struct{}{}:
		case <-ctx.Done():
			return
		}
	}
	if release == nil {
		return
	}
	select {
	case <-release:
	case <-ctx.Done():
	}
}

func (r *fakeRuntime) sweptNodes() [][]string {
	r.mu.Lock()
	defer r.mu.Unlock()
	return append([][]string(nil), r.swept...)
}

func (r *fakeRuntime) Reach(ctx context.Context, addr string, domestic bool) rcxProbeOutcome {
	r.mu.Lock()
	outcome, ok := r.reach[addr]
	hang := r.hang[addr]
	boom := r.panics[addr]
	r.mu.Unlock()
	if boom {
		panic("reach exploded on " + addr)
	}
	if hang {
		<-ctx.Done()
	}
	if ctx.Err() != nil {
		return rcxProbeOverloaded
	}
	if ok {
		return outcome
	}
	return rcxProbeFail
}

func (r *fakeRuntime) CloseConnections(ids []string) {
	r.mu.Lock()
	defer r.mu.Unlock()
	r.closed = append(r.closed, ids...)
}

func (r *fakeRuntime) hungUpOn() []string {
	r.mu.Lock()
	defer r.mu.Unlock()
	return append([]string(nil), r.closed...)
}

func (r *fakeRuntime) Connections() []rcxConnSample {
	r.mu.Lock()
	defer r.mu.Unlock()
	out := make([]rcxConnSample, 0, len(r.conns))
	for _, conn := range r.conns {
		out = append(out, conn)
	}
	return out
}

func (r *fakeRuntime) SampleLink() (rcxNetworkPayload, bool) {
	r.mu.Lock()
	defer r.mu.Unlock()
	return r.link, r.linked
}

func (r *fakeRuntime) Publish(status rcxStatus) {
	r.mu.Lock()
	defer r.mu.Unlock()
	r.published = append(r.published, status)
}

func (r *fakeRuntime) Now() time.Time {
	r.mu.Lock()
	defer r.mu.Unlock()
	return r.now
}

// The key is what deltas are counted against, so a test that wants another
// request opens another row rather than growing this one.
func (r *fakeRuntime) openConn(key, node, host string) {
	r.mu.Lock()
	defer r.mu.Unlock()
	r.conns[key] = rcxConnSample{Key: key, Node: node, Host: host, Start: r.now}
}

func (r *fakeRuntime) closeConn(key string) {
	r.mu.Lock()
	defer r.mu.Unlock()
	delete(r.conns, key)
}

func (r *fakeRuntime) bumpConn(key string, up, down int64) {
	r.mu.Lock()
	defer r.mu.Unlock()
	conn := r.conns[key]
	conn.Up += up
	conn.Down += down
	r.conns[key] = conn
}

func (r *fakeRuntime) advance(d time.Duration) {
	r.mu.Lock()
	defer r.mu.Unlock()
	r.now = r.now.Add(d)
}

func (r *fakeRuntime) lastStatus() rcxStatus {
	r.mu.Lock()
	defer r.mu.Unlock()
	if len(r.published) == 0 {
		return rcxStatus{}
	}
	return r.published[len(r.published)-1]
}

// Stands in for what the host ships: the core no longer owns a preset table, so a
// test has to hand it the same fields a bundle would.
func testConfig(preset string) rcxConfig {
	config := rcxDefaultConfig()
	config.Enabled = true
	config.Preset = preset
	config.CensorCountries = []string{"RU"}
	config.CanaryForeign = []string{"1.1.1.1:443"}
	config.CanaryDomestic = []string{"77.88.8.8:443"}
	config.OpenMarkers = []rcxMarker{
		{URL: "https://www.youtube.com/generate_204", Statuses: []int{204}},
	}
	config.DomesticMarkers = []rcxMarker{
		{URL: "https://ya.ru/", Statuses: []int{200, 301, 302}},
	}
	return config
}

func newTestEngine(runtime *fakeRuntime, preset string) *rcxEngine {
	engine := newRcxEngine(runtime)
	engine.snapshot = rcxEmptySnapshot()
	config := testConfig(preset)
	engine.applyConfigLocked(config)
	engine.envKey = "w:Home"
	engine.snapshot.Seed = rcxTestSeed
	engine.terrain.observe(rcxTerrainNormal, runtime.Now())
	return engine
}

// Fixed so a test reads the same park order every run, while still exercising the
// permutation the shipped engine applies.
const rcxTestSeed = 0x5243580000000001

func foreignMembers(names ...string) []rcxMember {
	members := make([]rcxMember, 0, len(names))
	for i, name := range names {
		members = append(members, rcxMember{
			Name:        name,
			Type:        "Vless",
			Port:        443,
			SupportsUDP: true,
			Order:       i,
		})
	}
	return members
}

func providerMembers(provider string, names ...string) []rcxMember {
	members := foreignMembers(names...)
	for i := range members {
		members[i].Provider = provider
		members[i].Transport = "transport-" + names[i]
		members[i].Ingress = names[i] + ".example"
		members[i].ExternalProvider = true
	}
	return members
}

func TestWakeStandbyPrefersLowestKnownDelay(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = []rcxMember{
		{Name: "current", ID: "current-id", SupportsUDP: true},
		{Name: "slow", ID: "slow-id", SupportsUDP: true, HostMs: 120, HostAt: runtime.Now()},
		{Name: "fast", ID: "fast-id", SupportsUDP: true, HostMs: 30, HostAt: runtime.Now()},
	}
	engine := newTestEngine(runtime, "ru")
	engine.incumbent = "current"
	engine.candidates(runtime.members)
	engine.snapshot.Standbys[engine.envKey] = []string{"slow-id", "fast-id"}
	for index, node := range []string{"slow", "fast"} {
		engine.ledger.NoteProbe(engine.key(node), engine.envKey, rcxRoleOpen, rcxProbeOK, runtime.members[index+1].HostMs, runtime.Now())
	}

	if got := engine.selectWakeStandby(runtime.Now()); got != "fast" {
		t.Fatalf("standby = %q, want lowest known-delay proven standby", got)
	}
}

func TestScreenOffKeepsLivingIncumbentAcrossLatencyGain(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("current", "faster")
	runtime.selected = "current"
	engine := newTestEngine(runtime, "ru")
	engine.incumbent = "current"
	engine.since = runtime.Now().Add(-time.Hour)
	engine.ledger.NoteProbe("current", engine.envKey, rcxRoleOpen, rcxProbeOK, 400, runtime.Now())
	engine.ledger.NoteProbe("faster", engine.envKey, rcxRoleOpen, rcxProbeOK, 20, runtime.Now())
	engine.applyScreenOff(true)

	engine.reconsider()
	if runtime.selected != "current" || len(runtime.selects) != 0 {
		t.Fatalf("selected = %q, selects = %v, background latency gain displaced a living incumbent", runtime.selected, runtime.selects)
	}
}

func TestScreenOffAlternativeSuccessNeedsIncumbentDeath(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("current", "standby")
	runtime.selected = "current"
	engine := newTestEngine(runtime, "ru")
	engine.incumbent = "current"
	engine.applyScreenOff(true)
	engine.probing = true
	engine.probeKind = rcxWaveIncident
	engine.probeScreenOff = true
	engine.probeScreenEpisode = engine.screenEpisode
	engine.probeIncumbent = "current"
	engine.probeStarted = map[string]struct{}{}

	engine.applyProbeResult(rcxEvent{Gen: engine.probeGen, Results: []rcxProbeResult{{Node: "standby", Role: rcxRoleOpen, Outcome: rcxProbeOK, DelayMs: 30}}})

	if runtime.selected != "current" || engine.probeDecisionClosed {
		t.Fatalf("selected = %q, closed = %v, alternative success acted as incumbent death", runtime.selected, engine.probeDecisionClosed)
	}
}

func TestScreenOffProbeEpisodeCommitsOnlyOneFailover(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("current", "first", "late")
	runtime.selected = "current"
	engine := newTestEngine(runtime, "ru")
	engine.incumbent = "current"
	engine.applyScreenOff(true)
	engine.probing = true
	engine.probeKind = rcxWaveIncident
	engine.probeScreenOff = true
	engine.probeScreenEpisode = engine.screenEpisode
	engine.probeIncumbent = "current"
	engine.probeStarted = map[string]struct{}{}

	engine.applyProbeResult(rcxEvent{Gen: engine.probeGen, Results: []rcxProbeResult{{Node: "current", Role: rcxRoleOpen, Outcome: rcxProbeFail}}})
	engine.applyProbeResult(rcxEvent{Gen: engine.probeGen, Results: []rcxProbeResult{{Node: "first", Role: rcxRoleOpen, Outcome: rcxProbeOK, DelayMs: 40}}})
	engine.applyProbeResult(rcxEvent{Gen: engine.probeGen, Results: []rcxProbeResult{{Node: "late", Role: rcxRoleOpen, Outcome: rcxProbeOK, DelayMs: 20}}})

	if runtime.selected != "first" || len(runtime.selects) != 1 || !engine.probeDecisionClosed {
		t.Fatalf("selected = %q, selects = %v, closed = %v, want one background failover", runtime.selected, runtime.selects, engine.probeDecisionClosed)
	}
	facts := engine.ledger.Facts("late", engine.envKey, true, runtime.Now(), rcxLedgerProofTTL)
	if facts.OpenWorld != rcxProofProven {
		t.Fatalf("late result was not retained as evidence: %+v", facts)
	}
}

func TestScreenOffFailedSelectDoesNotSpendEpisode(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("current", "standby")
	runtime.selected = "current"
	runtime.selectErr = context.DeadlineExceeded
	engine := newTestEngine(runtime, "ru")
	engine.incumbent = "current"
	engine.applyScreenOff(true)
	engine.screenDead = "current"
	engine.ledger.NoteProbe("standby", engine.envKey, rcxRoleOpen, rcxProbeOK, 30, runtime.Now())

	if engine.tryAutomaticMainSelect("standby", rcxReasonIncumbentDead, runtime.Now()) || engine.screenFailedOver {
		t.Fatal("failed selector write spent the background episode")
	}
	runtime.selectErr = nil
	if !engine.tryAutomaticMainSelect("standby", rcxReasonIncumbentDead, runtime.Now()) || !engine.screenFailedOver {
		t.Fatal("successful retry was blocked after a failed selector write")
	}
}

func waitForWakeEvent(t *testing.T, engine *rcxEngine) rcxEvent {
	t.Helper()
	timer := time.NewTimer(time.Second)
	defer timer.Stop()
	for {
		select {
		case event := <-engine.events:
			if event.Kind == rcxEventWakeResults {
				return event
			}
			engine.handle(event)
		case <-timer.C:
			t.Fatal("wake probe did not finish")
			return rcxEvent{}
		}
	}
}

func armWakeStandby(engine *rcxEngine, runtime *fakeRuntime, incumbent, standby string) {
	engine.incumbent = incumbent
	runtime.selected = incumbent
	engine.candidates(runtime.members)
	engine.snapshot.Standbys[engine.envKey] = []string{standby}
	engine.ledger.NoteProbe(standby, engine.envKey, rcxRoleOpen, rcxProbeOK, 40, runtime.Now())
}

func TestWakeProbeTestsIncumbentAndStandbyInParallel(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("current", "standby")
	runtime.results["current"] = rcxProbeResult{Outcome: rcxProbeOK, DelayMs: 100}
	runtime.results["standby"] = rcxProbeResult{Outcome: rcxProbeOK, DelayMs: 30}
	runtime.testStarted = make(chan string, 2)
	runtime.testRelease = make(chan struct{})
	engine := newTestEngine(runtime, "ru")
	armWakeStandby(engine, runtime, "current", "standby")
	engine.screenOff = true
	engine.suspended = true
	engine.screenEpisode = 1
	previous := rcxWakeSettleDelay
	rcxWakeSettleDelay = 0
	defer func() { rcxWakeSettleDelay = previous }()

	engine.applyScreenOff(false)
	engine.suspended = false
	engine.startWakeProbe()
	started := map[string]bool{}
	for len(started) < 2 {
		select {
		case node := <-runtime.testStarted:
			started[node] = true
		case <-time.After(time.Second):
			t.Fatalf("started = %v, want both named outbounds before either finishes", started)
		}
	}
	if runtime.selected != "current" {
		t.Fatalf("selected = %q before wake results, named tests mutated the selector", runtime.selected)
	}
	close(runtime.testRelease)
	engine.handle(waitForWakeEvent(t, engine))

	if got := runtime.testedNodes(); len(got) != 2 || !started["current"] || !started["standby"] {
		t.Fatalf("tested = %v, want current and remembered standby", got)
	}
	if len(runtime.selects) != 0 || runtime.selected != "current" {
		t.Fatalf("selects = %v, selected = %q, faster standby displaced a live incumbent", runtime.selects, runtime.selected)
	}
}

func TestWakeProbeWaitsUntilResumeAfterScreenOn(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("current", "standby")
	engine := newTestEngine(runtime, "ru")
	armWakeStandby(engine, runtime, "current", "standby")
	engine.screenOff = true
	engine.suspended = true
	engine.screenEpisode = 1
	previous := rcxWakeSettleDelay
	rcxWakeSettleDelay = 0
	defer func() { rcxWakeSettleDelay = previous }()

	engine.applyScreenOff(false)
	if engine.wakePending {
		t.Fatal("wake probe started before resume")
	}
	engine.applySuspend(false)
	defer engine.supersedeWake()
	if !engine.wakePending {
		t.Fatal("wake probe did not start after resume")
	}
}

func TestWakeProbeSwitchesOnceOnlyAfterIncumbentFailure(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("current", "standby")
	runtime.results["current"] = rcxProbeResult{Outcome: rcxProbeFail}
	runtime.results["standby"] = rcxProbeResult{Outcome: rcxProbeOK, DelayMs: 30}
	engine := newTestEngine(runtime, "ru")
	armWakeStandby(engine, runtime, "current", "standby")
	engine.screenOff = true
	engine.suspended = true
	engine.screenEpisode = 4
	previous := rcxWakeSettleDelay
	rcxWakeSettleDelay = 0
	defer func() { rcxWakeSettleDelay = previous }()

	engine.applyScreenOff(false)
	engine.applySuspend(false)
	event := waitForWakeEvent(t, engine)
	engine.handle(event)
	engine.handle(event)

	if runtime.selected != "standby" || len(runtime.selects) != 1 {
		t.Fatalf("selected = %q, selects = %v, wake=%+v, want one confirmed-death wake failover", runtime.selected, runtime.selects, event.Wake)
	}
	if engine.screenFailedOver || engine.incumbent != "standby" {
		t.Fatalf("episode state = used:%v incumbent:%q", engine.screenFailedOver, engine.incumbent)
	}
}

func TestWakeProbeTreatsTimeoutAsEvidenceOnly(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("current", "standby")
	engine := newTestEngine(runtime, "ru")
	armWakeStandby(engine, runtime, "current", "standby")
	engine.screenOff = true
	engine.screenEpisode = 2
	engine.applyScreenOff(false)
	defer engine.supersedeWake()

	engine.applyWakeResults(rcxEvent{
		Kind: rcxEventWakeResults, Gen: engine.wakeGen, ConfigGen: engine.configGen, Episode: engine.screenEpisode,
		Wake: []rcxWakeResult{{Node: "current", Outcome: rcxProbeOverloaded}, {Node: "standby", Outcome: rcxProbeOK, DelayMs: 20}},
	})

	if runtime.selected != "current" || len(runtime.selects) != 0 {
		t.Fatalf("selected = %q, selects = %v, timeout displaced an unproven incumbent", runtime.selected, runtime.selects)
	}
}

func TestCapabilityLaneSelectsSpecialistAndKeepsBaseSelector(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = []rcxMember{
		{Name: "plain", Provider: "main", Type: "Vless", Port: 443, SupportsUDP: true},
		{Name: "premium ⭐", Provider: "premium", Type: "Vless", Port: 443, SupportsUDP: true},
	}
	runtime.selected = "plain"
	engine := newTestEngine(runtime, "ru")
	config := engine.cfg
	config.Lanes = []rcxLaneConfig{{
		ID: "gemini-access", Group: "RCX-CAP-GEMINI_ACCESS", Fallback: "reject",
		Selectors: []rcxLaneSelector{{Provider: "premium", NameContains: "⭐"}},
	}}
	engine.applyConfigLocked(config)
	for _, member := range runtime.members {
		engine.ledger.NoteProbe(member.key(), engine.envKey, rcxRoleOpen, rcxProbeOK, 40, runtime.Now())
	}

	engine.reconsider()

	if got := runtime.SelectedIn("RCX-CAP-GEMINI_ACCESS"); got != "premium ⭐" {
		t.Fatalf("lane selected = %q, want its specialist", got)
	}
	if runtime.selected != "plain" {
		t.Fatalf("base selected = %q, want its independent incumbent", runtime.selected)
	}
	status := engine.Status()
	if len(status.Lanes) != 1 || status.Lanes[0].Node != "premium ⭐" || status.Lanes[0].State != "active" {
		t.Fatalf("lanes = %+v, want the active specialist status", status.Lanes)
	}
}

func TestCapabilityLaneUsesConfiguredFallbackWithoutSpecialists(t *testing.T) {
	for _, tc := range []struct {
		fallback string
		want     string
	}{
		{fallback: "main", want: rcxGroupNode},
		{fallback: "reject", want: "REJECT"},
	} {
		t.Run(tc.fallback, func(t *testing.T) {
			runtime := newFakeRuntime()
			runtime.members = foreignMembers("plain")
			runtime.selected = "plain"
			engine := newTestEngine(runtime, "ru")
			config := engine.cfg
			config.Lanes = []rcxLaneConfig{{
				ID: "gemini-access", Group: "RCX-CAP-GEMINI_ACCESS", Fallback: tc.fallback,
			}}
			engine.applyConfigLocked(config)

			engine.reconsider()

			if got := runtime.SelectedIn("RCX-CAP-GEMINI_ACCESS"); got != tc.want {
				t.Fatalf("selected = %q, want fallback %q", got, tc.want)
			}
		})
	}
}

func TestCapabilityLaneRidesFallbackWhileItsMatchesAreUnproven(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = []rcxMember{
		{Name: "plain", Provider: "main", Type: "Vless", Port: 443, SupportsUDP: true},
		{Name: "premium ⭐", Provider: "premium", Type: "Vless", Port: 443, SupportsUDP: true},
	}
	runtime.selected = "plain"
	runtime.groupSelected = map[string]string{"RCX-CAP-YOUTUBE_ADFREE": "REJECT"}
	engine := newTestEngine(runtime, "ru")
	config := engine.cfg
	config.Lanes = []rcxLaneConfig{{
		ID: "youtube-adfree", Group: "RCX-CAP-YOUTUBE_ADFREE", Fallback: "main",
		Selectors: []rcxLaneSelector{{NameContains: "⭐"}},
	}}
	engine.applyConfigLocked(config)

	engine.reconsider()

	if got := runtime.SelectedIn("RCX-CAP-YOUTUBE_ADFREE"); got != rcxGroupNode {
		t.Fatalf("selected = %q, want the configured fallback while no match is proven yet", got)
	}
	status := engine.Status()
	if len(status.Lanes) != 1 || status.Lanes[0].State != "searching" {
		t.Fatalf("lanes = %+v, want a searching lane rather than a settled fallback", status.Lanes)
	}
}

func TestCapabilityLaneProbesItsOwnUnprovenMatches(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = []rcxMember{
		{Name: "plain", Provider: "main", Type: "Vless", Port: 443, SupportsUDP: true},
		{Name: "premium ⭐", Provider: "premium", Type: "Vless", Port: 443, SupportsUDP: true},
	}
	runtime.selected = "plain"
	engine := newTestEngine(runtime, "ru")
	config := engine.cfg
	config.Lanes = []rcxLaneConfig{{
		ID: "youtube-adfree", Group: "RCX-CAP-YOUTUBE_ADFREE", Fallback: "main",
		Selectors: []rcxLaneSelector{{NameContains: "⭐"}},
	}}
	engine.applyConfigLocked(config)
	engine.ledger.NoteProbe(runtime.members[0].key(), engine.envKey, rcxRoleOpen, rcxProbeOK, 40, runtime.Now())

	before := engine.budget.Remaining(runtime.Now())
	engine.reconsiderLanes(runtime.members, runtime.Now())
	engine.queueLaneRecovery()

	if !engine.probing || engine.probeLane != "youtube-adfree" {
		t.Fatalf("probing = %v, lane = %q, want the lane measuring its own claim",
			engine.probing, engine.probeLane)
	}
	if _, queued := engine.laneProbeSeen["youtube-adfree"]["premium ⭐"]; !queued {
		t.Fatalf("seen = %v, want the unproven specialist in the wave",
			engine.laneProbeSeen["youtube-adfree"])
	}
	if got := engine.budget.Remaining(runtime.Now()); got != before-1 {
		t.Fatalf("budget left = %d, want the lane wave charged one probe", got)
	}
}

func TestCapabilityLaneWaitsWhenProbeBudgetIsSpent(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = []rcxMember{
		{Name: "plain", Provider: "main", Type: "Vless", Port: 443, SupportsUDP: true},
		{Name: "premium ⭐", Provider: "premium", Type: "Vless", Port: 443, SupportsUDP: true},
	}
	runtime.selected = "plain"
	engine := newTestEngine(runtime, "ru")
	config := engine.cfg
	config.Lanes = []rcxLaneConfig{{
		ID: "youtube-adfree", Group: "RCX-CAP-YOUTUBE_ADFREE", Fallback: "main",
		Selectors: []rcxLaneSelector{{NameContains: "⭐"}},
	}}
	engine.applyConfigLocked(config)
	engine.budget.Take(rcxProbeBudgetCap, runtime.Now())
	engine.reconsiderLanes(runtime.members, runtime.Now())

	engine.queueLaneRecovery()

	if engine.probing {
		t.Fatal("lane probe started after the shared budget was spent")
	}
	if _, queued := engine.laneProbeSeen["youtube-adfree"]["premium ⭐"]; queued {
		t.Fatal("an unaffordable specialist was marked as measured")
	}
	if engine.laneExhausted("youtube-adfree") {
		t.Fatal("budget starvation must not exhaust the lane search")
	}
}

func TestCapabilityLaneReleasesGroupWhenItsIncumbentDies(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = []rcxMember{
		{Name: "plain", Provider: "main", Type: "Vless", Port: 443, SupportsUDP: true},
		{Name: "premium ⭐", Provider: "premium", Type: "Vless", Port: 443, SupportsUDP: true},
	}
	runtime.selected = "plain"
	runtime.groupSelected = map[string]string{"RCX-CAP-YOUTUBE_ADFREE": "premium ⭐"}
	engine := newTestEngine(runtime, "ru")
	config := engine.cfg
	config.Lanes = []rcxLaneConfig{{
		ID: "youtube-adfree", Group: "RCX-CAP-YOUTUBE_ADFREE", Fallback: "main",
		Selectors: []rcxLaneSelector{{NameContains: "⭐"}},
	}}
	engine.applyConfigLocked(config)
	lane := engine.lanes["youtube-adfree"]
	lane.incumbent = "premium ⭐"
	key := runtime.members[1].key()
	engine.ledger.NoteProbe(key, engine.envKey, rcxRoleOpen, rcxProbeFail, 0, runtime.Now())

	engine.reconsider()

	if got := runtime.SelectedIn("RCX-CAP-YOUTUBE_ADFREE"); got != rcxGroupNode {
		t.Fatalf("selected = %q, want the fallback after its only specialist died", got)
	}
	if lane.incumbent != "" {
		t.Fatalf("incumbent = %q, want a released lane", lane.incumbent)
	}
}

func TestCapabilityLaneFallbackKeepsStateWhenSelectorWriteFails(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("plain")
	runtime.groupSelected = map[string]string{"RCX-CAP-GEMINI_ACCESS": "old-specialist"}
	engine := newTestEngine(runtime, "ru")
	config := engine.cfg
	config.Lanes = []rcxLaneConfig{{
		ID: "gemini-access", Group: "RCX-CAP-GEMINI_ACCESS", Fallback: "reject",
		Selectors: []rcxLaneSelector{{NameContains: "star"}},
	}}
	engine.applyConfigLocked(config)
	lane := engine.lanes["gemini-access"]
	lane.incumbent = "old-specialist"
	runtime.selectErr = errors.New("selector unavailable")

	engine.reconsider()

	if lane.incumbent != "old-specialist" {
		t.Fatalf("incumbent = %q, want state preserved after failed fallback", lane.incumbent)
	}
	if got := runtime.SelectedIn("RCX-CAP-GEMINI_ACCESS"); got != "old-specialist" {
		t.Fatalf("selected = %q, want unchanged selector", got)
	}
}

func TestCapabilityLaneRestoresItsEnvironmentPick(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = []rcxMember{{Name: "premium ⭐", ID: "premium-id", Provider: "premium", SupportsUDP: true}}
	runtime.selected = "premium ⭐"
	engine := newTestEngine(runtime, "ru")
	config := engine.cfg
	config.Lanes = []rcxLaneConfig{{
		ID: "gemini-access", Group: "RCX-CAP-GEMINI_ACCESS", Fallback: "main",
		Selectors: []rcxLaneSelector{{NameContains: "⭐"}},
	}}
	engine.applyConfigLocked(config)
	engine.candidates(runtime.members)
	engine.snapshot.LanePicks["gemini-access"] = map[string]string{"w:Cell": "premium-id"}

	engine.applyNetwork(rcxNetworkPayload{Transport: "wifi", SSID: "Cell", Validated: true})

	lane := engine.lanes["gemini-access"]
	if lane == nil || lane.incumbent != "premium ⭐" {
		t.Fatalf("lane = %+v, want its remembered endpoint restored", lane)
	}
}

func TestCapabilityLaneProbeResultSwitchesOnlyItsSelector(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = []rcxMember{{Name: "premium ⭐", Provider: "premium", SupportsUDP: true}}
	runtime.selected = "plain"
	engine := newTestEngine(runtime, "ru")
	config := engine.cfg
	config.Lanes = []rcxLaneConfig{{
		ID: "gemini-access", Group: "RCX-CAP-GEMINI_ACCESS", Fallback: "reject",
		Selectors: []rcxLaneSelector{{NameContains: "⭐"}},
	}}
	engine.applyConfigLocked(config)
	engine.candidates(runtime.members)
	engine.probing = true
	engine.probeKind = rcxWaveRescue
	engine.probeLane = "gemini-access"
	engine.probeStarted = map[string]struct{}{}
	cancelled := false
	engine.probeCancel = func() { cancelled = true }

	engine.applyProbeResult(rcxEvent{
		Gen: engine.probeGen, ConfigGen: engine.configGen, Lane: "gemini-access",
		Results: []rcxProbeResult{{Node: "premium ⭐", Role: rcxRoleOpen, Outcome: rcxProbeOK, DelayMs: 40}},
	})

	if got := runtime.SelectedIn("RCX-CAP-GEMINI_ACCESS"); got != "premium ⭐" || !cancelled {
		t.Fatalf("selected = %q, cancelled = %v, want early lane recovery", got, cancelled)
	}
	if runtime.selected != "plain" {
		t.Fatalf("base selected = %q, lane recovery changed it", runtime.selected)
	}
}

func TestLaneSelectorMatchesBySubscriptionGroup(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = []rcxMember{
		{Name: "us-01", Provider: "main", Type: "Vless", Port: 443, SupportsUDP: true},
		{Name: "de-01", Provider: "main", Type: "Vless", Port: 443, SupportsUDP: true},
	}
	runtime.selected = "us-01"
	runtime.groupMembers = map[string][]string{"🇺🇸 US": {"us-01"}}
	engine := newTestEngine(runtime, "ru")
	config := engine.cfg
	config.Lanes = []rcxLaneConfig{{
		ID: "gemini-access", Group: "RCX-CAP-GEMINI_ACCESS", Fallback: "reject",
		Selectors: []rcxLaneSelector{{Group: "🇺🇸 US"}},
	}}
	engine.applyConfigLocked(config)
	now := runtime.Now()
	for _, member := range runtime.members {
		engine.ledger.NoteProbe(member.key(), engine.envKey, rcxRoleOpen, rcxProbeOK, 40, now)
	}

	engine.reconsider()

	if got := runtime.SelectedIn("RCX-CAP-GEMINI_ACCESS"); got != "us-01" {
		t.Fatalf("lane selected = %q, want the sole member of the named subscription group", got)
	}
}

func TestForeignLaneBarsANodeProvenToEgressDomestic(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = []rcxMember{
		{Name: "abroad", Provider: "premium", Type: "Vless", Port: 443, SupportsUDP: true},
		{Name: "home", Provider: "premium", Type: "Vless", Port: 443, SupportsUDP: true},
	}
	runtime.selected = "plain"
	engine := newTestEngine(runtime, "ru")
	config := engine.cfg
	config.Lanes = []rcxLaneConfig{{
		ID: "gemini-access", Group: "RCX-CAP-GEMINI_ACCESS", Fallback: "reject",
		Role: rcxLaneRoleForeign, Selectors: []rcxLaneSelector{{Provider: "premium"}},
	}}
	engine.applyConfigLocked(config)
	now := runtime.Now()
	engine.ledger.SetExit("abroad", "US", rcxOriginForeign, now)
	engine.ledger.SetExit("home", "RU", rcxOriginDomestic, now)
	for _, member := range runtime.members {
		engine.ledger.NoteProbe(member.key(), engine.envKey, rcxRoleOpen, rcxProbeOK, 40, now)
	}

	engine.reconsider()

	if got := runtime.SelectedIn("RCX-CAP-GEMINI_ACCESS"); got != "abroad" {
		t.Fatalf("lane selected = %q, want the foreign-egress node, never the home-egress one", got)
	}
}

func TestForeignLaneStillProbesAnUnmeasuredMatch(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = []rcxMember{{Name: "premium ⭐", Provider: "premium", Type: "Vless", Port: 443, SupportsUDP: true}}
	runtime.selected = "plain"
	engine := newTestEngine(runtime, "ru")
	config := engine.cfg
	config.Lanes = []rcxLaneConfig{{
		ID: "gemini-access", Group: "RCX-CAP-GEMINI_ACCESS", Fallback: "reject",
		Role: rcxLaneRoleForeign, Selectors: []rcxLaneSelector{{NameContains: "⭐"}},
	}}
	engine.applyConfigLocked(config)

	engine.reconsider()

	status := engine.Status()
	if len(status.Lanes) != 1 || status.Lanes[0].State != "searching" {
		t.Fatalf("lanes = %+v, want an unmeasured foreign match to stay searchable, not barred by role", status.Lanes)
	}
}

func TestLaneStrategyOverridesTheParkStrategy(t *testing.T) {
	// On a whitelist a breaker outranks a plain node under balanced/stable
	// ordering, but the lowest-latency comparator drops that misfit axis, so a
	// faster plain node wins instead. That divergence is the per-lane strategy.
	newLane := func(strategy string) string {
		runtime := newFakeRuntime()
		now := runtime.Now()
		runtime.members = []rcxMember{
			{Name: "breaker ⭐", Provider: "premium", Type: "Vless", Port: 443, SupportsUDP: true, HostMs: 300, HostAt: now},
			{Name: "plain ⭐", Provider: "premium", Type: "Vless", Port: 443, SupportsUDP: true, HostMs: 40, HostAt: now},
		}
		runtime.selected = "base"
		engine := newTestEngine(runtime, "ru")
		config := engine.cfg
		config.Strategy = rcxStrategyStable
		config.BreakerPatterns = []string{"breaker"}
		config.Lanes = []rcxLaneConfig{{
			ID: "youtube-adfree", Group: "RCX-CAP-YOUTUBE_ADFREE", Fallback: "main",
			Strategy: strategy, Selectors: []rcxLaneSelector{{NameContains: "⭐"}},
		}}
		engine.applyConfigLocked(config)
		engine.terrain.observe(rcxTerrainWhitelist, now)
		for _, member := range runtime.members {
			engine.ledger.NoteProbe(member.key(), engine.envKey, rcxRoleOpen, rcxProbeOK, member.HostMs, now)
		}
		engine.reconsider()
		return runtime.SelectedIn("RCX-CAP-YOUTUBE_ADFREE")
	}

	if got := newLane(""); got != "breaker ⭐" {
		t.Fatalf("inherited strategy selected %q, want the breaker the park's stable order prefers", got)
	}
	if got := newLane(rcxStrategyLatency); got != "plain ⭐" {
		t.Fatalf("lane strategy selected %q, want the faster node its lowest-latency order prefers", got)
	}
}

func TestProbeResultForReplacedEndpointNameIsIgnored(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = []rcxMember{{Name: "same", ID: "new-id", SupportsUDP: true}}
	engine := newTestEngine(runtime, "ru")
	engine.syncIdentity(runtime.members)
	engine.probing = true

	engine.applyProbeResult(rcxEvent{
		Gen: engine.probeGen,
		Results: []rcxProbeResult{{
			Node: "same", Key: "old-id", Role: rcxRoleOpen, Outcome: rcxProbeOK, DelayMs: 40,
		}},
	})

	if len(engine.probeResults) != 0 {
		t.Fatal("stale endpoint result entered the active wave")
	}
	facts := engine.ledger.Facts("new-id", engine.envKey, true, runtime.Now(), rcxLedgerProofTTL)
	if facts.OpenWorld != rcxProofUnknown {
		t.Fatalf("new endpoint inherited stale proof: %+v", facts)
	}
}

func TestProbeResultsRefreshTheAppliedMemberState(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = providerMembers("one", "a", "b")
	engine := newTestEngine(runtime, "ru")
	engine.handle(rcxEvent{Kind: rcxEventProvidersLoaded})
	reads := runtime.memberReads

	engine.probeGen = 1
	engine.handle(rcxEvent{
		Kind: rcxEventProbeResults,
		Gen:  1,
		Results: []rcxProbeResult{
			{Node: "a", Outcome: rcxProbeOK},
			{Node: "b", Outcome: rcxProbeOK},
		},
	})

	if runtime.memberReads <= reads {
		t.Fatal("probe completion reused stale member metadata")
	}
}

func TestProviderCircuitNeedsIndependentFailures(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = providerMembers("one", "a", "b")
	engine := newTestEngine(runtime, "ru")

	engine.noteProviderNodeFailure("a", runtime.Now())
	engine.noteProviderNodeFailure("a", runtime.Now())
	if engine.providerCircuitOpen("one", "b", runtime.Now()) {
		t.Fatal("one endpoint must not condemn its provider")
	}

	engine.noteProviderNodeFailure("b", runtime.Now())
	if !engine.providerCircuitOpen("one", "b", runtime.Now()) {
		t.Fatal("two independent endpoint failures must open the circuit")
	}
}

func TestProviderCircuitDoesNotGateTheLivingIncumbent(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = providerMembers("one", "a", "b")
	engine := newTestEngine(runtime, "ru")
	engine.incumbent = "a"

	engine.noteProviderNodeFailure("a", runtime.Now())
	engine.noteProviderNodeFailure("b", runtime.Now())
	candidates := engine.candidates(runtime.members)

	if candidates[0].Circuit {
		t.Error("an open circuit must not evict the incumbent on its own")
	}
	if !candidates[1].Circuit {
		t.Error("an unproven challenger from the failed provider must be gated")
	}
}

func TestProviderCircuitAllowsOnlyOneHalfOpenProbe(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = providerMembers("one", "a", "b", "c")
	engine := newTestEngine(runtime, "ru")
	engine.noteProviderNodeFailure("a", runtime.Now())
	engine.noteProviderNodeFailure("b", runtime.Now())

	if wave := engine.planWave(engine.candidates(runtime.members), runtime.members, rcxWaveRoutine); len(wave) != 0 {
		t.Fatalf("wave = %v, want the circuit quiet before half-open", wave)
	}
	runtime.advance(rcxProviderHalfOpenAfter)
	wave := engine.planWave(engine.candidates(runtime.members), runtime.members, rcxWaveRoutine)
	if len(wave) != 1 {
		t.Fatalf("wave = %v, want one half-open probe", wave)
	}
	if next := engine.planWave(engine.candidates(runtime.members), runtime.members, rcxWaveRoutine); len(next) != 0 {
		t.Fatalf("second wave = %v, want half-open rate-limited", next)
	}
}

func TestProviderCircuitSurvivesOtherEnvironmentReconcile(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = providerMembers("one", "a", "b")
	engine := newTestEngine(runtime, "ru")
	engine.snapshot.Circuits[rcxCircuitKey("c:25001", "other")] = rcxProviderCircuit{
		Until:   runtime.Now().Add(time.Minute),
		Members: map[string]struct{}{"x": {}},
	}

	engine.reconcileCircuits(runtime.members, runtime.Now())

	if _, ok := engine.snapshot.Circuits[rcxCircuitKey("c:25001", "other")]; !ok {
		t.Error("refreshing one environment must not delete another environment's circuit")
	}
}

func TestProviderSuccessClosesItsCircuit(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = providerMembers("one", "a", "b")
	engine := newTestEngine(runtime, "ru")
	engine.noteProviderNodeFailure("a", runtime.Now())
	engine.noteProviderNodeFailure("b", runtime.Now())

	engine.noteProviderSuccess("a")

	if engine.providerCircuitOpen("one", "b", runtime.Now()) {
		t.Error("successful provider evidence must close the circuit")
	}
}

func TestHarvestedSuccessClosesItsProviderCircuit(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = providerMembers("one", "a", "b")
	engine := newTestEngine(runtime, "ru")
	engine.syncIdentity(runtime.members)
	engine.noteProviderNodeFailure("a", runtime.Now())
	engine.noteProviderNodeFailure("b", runtime.Now())

	engine.handle(rcxEvent{Kind: rcxEventHarvested, Node: "a", DelayMs: 80})

	if engine.providerCircuitOpen("one", "b", runtime.Now()) {
		t.Error("returned host payload must close the provider-wide circuit")
	}
}

func TestEnvironmentMigrationMergesEveryPersistedDomain(t *testing.T) {
	runtime := newFakeRuntime()
	engine := newTestEngine(runtime, "ru")
	old, destination := "w:Home", "v2:w:Home#stable"
	now := runtime.Now()
	engine.snapshot.Picks[old] = "old-pick"
	engine.snapshot.Pins[old] = "old-pin"
	engine.snapshot.Regimes[old] = rcxRegimeMemory{Terrain: rcxTerrainWhitelist, At: now.Add(time.Minute)}
	engine.snapshot.Regimes[destination] = rcxRegimeMemory{Terrain: rcxTerrainNormal, At: now}
	engine.snapshot.Standbys[old] = []string{"b", "c"}
	engine.snapshot.Standbys[destination] = []string{"a", "b"}
	circuit := rcxProviderCircuit{OpenedAt: now, Until: now.Add(time.Minute)}
	engine.snapshot.Circuits[rcxCircuitKey(old, "one")] = circuit

	engine.migrateEnvironment([]string{old}, destination)

	if engine.snapshot.Picks[destination] != "old-pick" || engine.snapshot.Pins[destination] != "old-pin" {
		t.Fatalf("pick/pin = %q/%q, want migrated values", engine.snapshot.Picks[destination], engine.snapshot.Pins[destination])
	}
	if got := engine.snapshot.Regimes[destination].Terrain; got != rcxTerrainWhitelist {
		t.Fatalf("terrain = %v, want the fresher regime", got)
	}
	if got := engine.snapshot.Standbys[destination]; len(got) != 3 || got[0] != "a" || got[1] != "b" || got[2] != "c" {
		t.Fatalf("standbys = %v, want stable deduplicated merge", got)
	}
	if _, ok := engine.snapshot.Circuits[rcxCircuitKey(destination, "one")]; !ok {
		t.Error("provider circuit did not follow the environment alias")
	}
	if _, ok := engine.snapshot.Circuits[rcxCircuitKey(old, "one")]; ok {
		t.Error("legacy provider circuit was retained")
	}
}

func TestEngineDoesNothingOutsideRuleMode(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.mode = "global"
	runtime.members = foreignMembers("a", "b")
	engine := newTestEngine(runtime, "ru")

	engine.reconsider()

	if len(runtime.selects) != 0 {
		t.Errorf("selects = %v, want none: Global means the user took the wheel", runtime.selects)
	}
	if got := runtime.lastStatus().Mode; got != "global" {
		t.Errorf("status mode = %q, want the real core mode", got)
	}
}

func TestEngineLeavesADeadIncumbentForALivingNode(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("dead", "alive")
	engine := newTestEngine(runtime, "ru")
	engine.incumbent = "dead"
	engine.since = runtime.Now().Add(-time.Hour)

	engine.ledger.NoteProbe("alive", "w:Home", rcxRoleOpen, rcxProbeOK, 90, runtime.Now())
	rcxChargeFailures(engine.ledger, "dead", "w:Home", rcxTerrainNormal, runtime.Now(), 3)

	engine.reconsider()

	if got := runtime.selected; got != "alive" {
		t.Fatalf("selected = %q, want the node with evidence", got)
	}
	if got := runtime.lastStatus().Reason; got != string(rcxReasonIncumbentDead) {
		t.Errorf("reason = %q, want incumbent-dead", got)
	}
}

func TestEngineHoldsAStrandedIncumbentInsteadOfLeaking(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("only")
	engine := newTestEngine(runtime, "ru")
	engine.incumbent = "only"
	engine.ledger.NoteProbe("only", "w:Home", rcxRoleOpen, rcxProbeFail, 0, runtime.Now())

	engine.reconsider()

	if len(runtime.selects) != 0 {
		t.Errorf("selects = %v, want none: DIRECT would put the real SNI on the wire", runtime.selects)
	}
	status := runtime.lastStatus()
	if status.Reason != string(rcxReasonMeasuring) || !status.Searching {
		t.Errorf("status = %+v, want measuring while bounded recovery runs", status)
	}
}

func TestEngineStartsFromTheNodeRememberedForThisNetwork(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("a", "remembered")
	engine := newTestEngine(runtime, "ru")
	engine.snapshot.Picks["w:Home"] = "remembered"
	engine.ledger.NoteProbe("remembered", "w:Home", rcxRoleOpen, rcxProbeOK, 120, runtime.Now())
	engine.envKey = ""

	engine.handle(rcxEvent{Kind: rcxEventNetwork, Payload: rcxNetworkPayload{
		Transport: "wifi",
		SSID:      "Home",
		Validated: true,
	}})

	if got := engine.incumbent; got != "remembered" {
		t.Errorf("incumbent = %q, want the remembered pick: a cold start must not search", got)
	}
}

func TestEngineKeepsFailureMemoryPerNetwork(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("node")
	engine := newTestEngine(runtime, "ru")

	rcxChargeFailures(engine.ledger, "node", "w:Home", rcxTerrainNormal, runtime.Now(), 3)

	if engine.ledger.CoolUntil("node", "w:Home", engine.runtime.Now()).IsZero() {
		t.Fatal("three failed connections on one network must cool the node there")
	}
	if !engine.ledger.CoolUntil("node", "c:25001", engine.runtime.Now()).IsZero() {
		t.Error("a whitelist episode on wifi must not condemn the node on LTE")
	}
}

func TestEngineKeepsCarrierMemoryWhenCellularDetailsChange(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("node", "spare")
	engine := newTestEngine(runtime, "ru")
	engine.envKey = ""
	first := rcxNetworkPayload{Transport: "cellular", Carrier: "25001", Gateways: []string{"10.1.0.1"}, IPv4: []string{"10.1.0.2"}, Validated: true}
	engine.handle(rcxEvent{Kind: rcxEventNetwork, Payload: first})
	key := engine.envKey
	engine.snapshot.Picks[key] = "node"
	engine.snapshot.Pins[key] = "node"
	engine.snapshot.Standbys[key] = []string{"spare"}
	engine.ledger.NoteProbe("node", key, rcxRoleOpen, rcxProbeOK, 80, runtime.Now())
	engine.ledger.NoteProbe("spare", key, rcxRoleOpen, rcxProbeOK, 90, runtime.Now())

	second := rcxNetworkPayload{Transport: "cellular", Carrier: "25001", Gateways: []string{"10.99.0.1"}, IPv4: []string{"10.99.0.2"}, Validated: true}
	engine.handle(rcxEvent{Kind: rcxEventNetwork, Payload: second})

	if engine.envKey != key || engine.snapshot.Picks[key] != "node" || engine.snapshot.Pins[key] != "node" || len(engine.snapshot.Standbys[key]) != 1 {
		t.Fatalf("carrier memory was split: env=%q pick=%q pin=%q standby=%v", engine.envKey, engine.snapshot.Picks[key], engine.snapshot.Pins[key], engine.snapshot.Standbys[key])
	}
	if engine.ledger.Facts("node", key, true, runtime.Now(), rcxLedgerProofTTL).OpenWorld != rcxProofProven {
		t.Error("carrier ledger was lost when cellular details changed")
	}
}

func TestEngineCarriesMemoryWhenTheSsidBecomesReadable(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("node")
	engine := newTestEngine(runtime, "ru")
	engine.envKey = ""

	anonymous := rcxNetworkPayload{
		Transport:  "wifi",
		Gateways:   []string{"192.168.1.1"},
		DHCPServer: "192.168.1.1",
		IPv4:       []string{"192.168.1.55"},
		Validated:  true,
	}
	engine.handle(rcxEvent{Kind: rcxEventNetwork, Payload: anonymous})
	engine.ledger.NoteProbe("node", engine.envKey, rcxRoleOpen, rcxProbeOK, 80, runtime.Now())
	engine.snapshot.Picks[engine.envKey] = "node"

	named := anonymous
	named.SSID = "Home"
	engine.handle(rcxEvent{Kind: rcxEventNetwork, Payload: named})
	namedKey, _ := rcxEnvKeys(named)

	if engine.envKey != namedKey {
		t.Fatalf("env key = %q, want %q once the SSID is readable", engine.envKey, namedKey)
	}
	if got := engine.snapshot.Picks[namedKey]; got != "node" {
		t.Errorf("pick = %q, want the record migrated, not orphaned", got)
	}
	if engine.ledger.Facts("node", namedKey, true, runtime.Now(), rcxLedgerProofTTL).OpenWorld != rcxProofProven {
		t.Error("the proof gathered before the permission was granted was lost")
	}
}

func TestNoteDialNeitherBlocksNorTakesCoreLocks(t *testing.T) {
	runtime := newFakeRuntime()
	engine := newTestEngine(runtime, "ru")

	// match() holds configMux while a rule resolves, and patchSelectGroup takes
	// selectMu under configMu: a hook that reached for either would deadlock.
	configMu.Lock()
	selectMu.Lock()
	defer func() {
		selectMu.Unlock()
		configMu.Unlock()
	}()

	done := make(chan struct{})
	go func() {
		defer close(done)
		for i := 0; i < rcxDialQueueSize*2; i++ {
			engine.NoteDial("node", true, time.Millisecond, runtime.Now())
		}
	}()

	select {
	case <-done:
	case <-time.After(2 * time.Second):
		t.Fatal("the dial hook blocked: it must drop events, never wait")
	}
}

func TestNoteDialIsSilentWhileDisabled(t *testing.T) {
	runtime := newFakeRuntime()
	engine := newTestEngine(runtime, "ru")
	engine.SetEnabled(false)
	engine.drainControl()

	engine.NoteDial("node", true, time.Millisecond, runtime.Now())

	if len(engine.dials) != 0 {
		t.Error("a disabled engine must not collect evidence")
	}
}

func TestEngineIgnoresEvidenceThatIsNotAboutItsOwnNodes(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("node")
	engine := newTestEngine(runtime, "ru")
	engine.reconsider()

	for i := 0; i < 3; i++ {
		engine.NoteDial("DIRECT", true, time.Millisecond, runtime.Now())
	}
	engine.drainDials()

	if !engine.ledger.CoolUntil("DIRECT", "w:Home", engine.runtime.Now()).IsZero() {
		t.Error("a DIRECT dial is not evidence about a node in the skeleton")
	}
}

func TestEngineIgnoresANetworkEventThatIdentifiesNothing(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("a", "b")
	engine := newTestEngine(runtime, "ru")
	engine.incumbent = "a"

	engine.handle(rcxEvent{Kind: rcxEventNetwork, Payload: rcxNetworkPayload{Transport: "wifi"}})

	if got := engine.envKey; got != "w:Home" {
		t.Errorf("envKey = %q, want the known env: a blank payload names no network", got)
	}
	if got := engine.incumbent; got != "a" {
		t.Errorf("incumbent = %q, want the pick kept: a placeholder event must not cold-start the engine", got)
	}
	if len(runtime.selects) != 0 {
		t.Errorf("selects = %v, want no switch bought by a payload that described no network", runtime.selects)
	}
}

func TestEngineAdoptsALinkTheTransportNameMissed(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("a", "b")
	engine := newTestEngine(runtime, "ru")

	desktop := rcxNetworkPayload{IPv4: []string{"192.168.31.44"}, Validated: true}
	engine.handle(rcxEvent{Kind: rcxEventNetwork, Payload: desktop})

	want, _ := rcxEnvKeys(desktop)
	if got := engine.envKey; got != want {
		t.Errorf("envKey = %q, want %q: a link without a transport name still has a fingerprint", got, want)
	}
}

func cellularHandoff(engine *rcxEngine) string {
	payload := rcxNetworkPayload{
		Transport: "cellular",
		Carrier:   "25001",
		Validated: true,
	}
	engine.handle(rcxEvent{Kind: rcxEventNetwork, Payload: payload})
	key, _ := rcxEnvKeys(payload)
	return key
}

func TestHandoffBudgetFitsTenSeconds(t *testing.T) {
	if rcxHostSweepWindow+rcxHandoffWave > 10*time.Second {
		t.Fatalf("handoff budget = %v, want at most 10s", rcxHostSweepWindow+rcxHandoffWave)
	}
}

func TestHandoffMarkerGeometryFinishesInItsWindow(t *testing.T) {
	batches := (rcxHandoffWidth + rcxHandoffParallel - 1) / rcxHandoffParallel
	if time.Duration(batches)*rcxHandoffTimeout > rcxHandoffWave {
		t.Fatalf("handoff marker geometry cannot finish in %v", rcxHandoffWave)
	}
}

func TestEngineHandoffStartsAHostSweep(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("a", "b")
	runtime.sweepStarted = make(chan struct{}, 1)
	engine := newTestEngine(runtime, "ru")

	cellularHandoff(engine)
	select {
	case <-runtime.sweepStarted:
	case <-time.After(time.Second):
		t.Fatal("host sweep did not start")
	}

	sweeps := runtime.sweptNodes()
	if len(sweeps) != 1 || !reflect.DeepEqual(sweeps[0], []string{"a", "b"}) {
		t.Fatalf("sweeps = %v, want one whole-park sweep", sweeps)
	}
}

func TestEngineDropsHostReadingsFromThePreviousLink(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = []rcxMember{{
		Name: "node", SupportsUDP: true, HostMs: 40, HostAt: runtime.Now(),
	}}
	engine := newTestEngine(runtime, "ru")
	runtime.advance(time.Second)
	engine.envSince = runtime.Now()

	candidate := engine.candidates(runtime.members)[0]
	if candidate.HostMs != 0 || candidate.HostDead {
		t.Fatalf("host reading = %d dead=%v, want no reading from the old link", candidate.HostMs, candidate.HostDead)
	}
}

func TestEngineHoldsHandoffProbeUntilHostSweepLands(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("a", "b")
	runtime.reach["1.1.1.1:443"] = rcxProbeOK
	runtime.sweepStarted = make(chan struct{}, 1)
	runtime.sweepRelease = make(chan struct{})
	engine := newTestEngine(runtime, "ru")
	engine.quit = make(chan struct{})

	cellularHandoff(engine)
	select {
	case <-runtime.sweepStarted:
	case <-time.After(time.Second):
		t.Fatal("host sweep did not start")
	}
	if engine.probing {
		t.Fatal("handoff marker wave started before the host sweep landed")
	}

	close(runtime.sweepRelease)
	deadline := time.After(time.Second)
	for engine.sweeping {
		select {
		case event := <-engine.events:
			engine.handle(event)
		case <-deadline:
			t.Fatal("host sweep did not finish")
		}
	}
	if !engine.probing {
		t.Fatal("handoff marker wave did not start after the host sweep")
	}
}

func drainHostSweep(t *testing.T, engine *rcxEngine) {
	t.Helper()
	deadline := time.After(time.Second)
	for engine.sweeping {
		select {
		case event := <-engine.events:
			engine.handle(event)
		case <-deadline:
			t.Fatal("host sweep did not finish")
		}
	}
	for engine.pendingHandoff {
		select {
		case event := <-engine.events:
			engine.handle(event)
		case <-deadline:
			t.Fatal("handoff did not leave the host-sweep gate")
		}
	}
}

func TestEngineDropsTheWaveTheOldNetworkBought(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("a", "b")
	engine := newTestEngine(runtime, "ru")
	members := runtime.members
	engine.startProbe(engine.candidates(members), members, rcxWaveRoutine)
	if !engine.probing {
		t.Fatal("want a wave in flight on the network the user is leaving")
	}

	cellularKey := cellularHandoff(engine)
	if engine.envKey != cellularKey {
		t.Fatalf("envKey = %q, want %q", engine.envKey, cellularKey)
	}
	left := engine.budget.Remaining(runtime.Now())

	engine.handle(rcxEvent{Kind: rcxEventProbeResults, Results: []rcxProbeResult{
		{Node: "a", Role: rcxRoleOpen, Outcome: rcxProbeFail},
	}})

	if got := engine.ledger.Facts("a", cellularKey, true, runtime.Now(), rcxLedgerProofTTL).OpenWorld; got == rcxProofDisproven {
		t.Error("a verdict measured on the old network must not condemn the node on the new one")
	}
	if got := engine.ledger.Facts("a", "w:Home", true, runtime.Now(), rcxLedgerProofTTL).OpenWorld; got == rcxProofDisproven {
		t.Error("the wave outlived the network it measured: its verdicts are about nothing")
	}
	if !engine.sweeping && !engine.probing {
		t.Error("a stale wave must not unlatch the new network measurement")
	}
	if got := engine.budget.Remaining(runtime.Now()); got != left {
		t.Errorf("budget left = %d, want %d: a discarded wave refunds nothing", got, left)
	}
}

func TestEngineMeasuresAfterTheHostSweepOnTheNetworkThatArrived(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("a", "b")
	runtime.reach["1.1.1.1:443"] = rcxProbeOK
	engine := newTestEngine(runtime, "ru")
	engine.quit = make(chan struct{})
	members := runtime.members
	engine.reconsider()
	before := engine.budget.Remaining(runtime.Now())

	cellularHandoff(engine)
	drainHostSweep(t, engine)

	if !engine.probing {
		t.Fatal("the new network did not start its marker wave after the host sweep")
	}
	if got := before - engine.budget.Remaining(runtime.Now()); got != len(members) {
		t.Errorf("probes spent = %d, want %d: one per node on the new network", got, len(members))
	}
}

func TestEngineRefundsWhatALinkHandoffCharged(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("a", "b")
	engine := newTestEngine(runtime, "ru")
	engine.reconsider()

	failDial(engine, runtime, "a")
	runtime.advance(rcxLinkDark)
	failDial(engine, runtime, "b")
	if engine.ledger.FailStreak("a", "w:Home") != 1 {
		t.Fatal("want both nodes charged while the old link was going dark")
	}

	cellularHandoff(engine)

	for _, node := range []string{"a", "b"} {
		if got := engine.ledger.FailStreak(node, "w:Home"); got != 0 {
			t.Errorf("streak on %s = %d, want 0: the dead link failed those dials, not the nodes", node, got)
		}
	}
	if len(engine.charged) != 0 {
		t.Errorf("escrow = %v, want it closed: the network it was opened against is gone", engine.charged)
	}
}

func TestEngineRetiresTheDeepScanTheHandoffSuperseded(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("a", "b")
	engine := newTestEngine(runtime, "ru")
	engine.startDeepScan()
	engine.budget.Take(rcxProbeBudgetCap, runtime.Now())
	if !engine.deep {
		t.Fatal("want a deep sweep in flight")
	}

	cellularHandoff(engine)

	if engine.deep {
		t.Error("the sweep measured the old network: its verdicts are discarded, so it is over")
	}
	if engine.Status().Deep {
		t.Error("the hero row must not claim a sweep whose results nobody will read")
	}
}

func TestEngineDeliversTheWaveTheNewNetworkBought(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("a", "b")
	runtime.reach["1.1.1.1:443"] = rcxProbeOK
	runtime.results = map[string]rcxProbeResult{
		"a": {Node: "a", Outcome: rcxProbeOK, DelayMs: 120},
	}
	runtime.testStarted = make(chan string, 2)
	runtime.testRelease = make(chan struct{})
	engine := newTestEngine(runtime, "ru")
	engine.quit = make(chan struct{})

	cellularKey := cellularHandoff(engine)
	drainHostSweep(t, engine)
	select {
	case <-runtime.testStarted:
	case <-time.After(time.Second):
		t.Fatal("want the new network's own wave in flight")
	}
	close(runtime.testRelease)
	gen := engine.probeGen
	defer engine.supersedeProbe()
	defer engine.supersedeReach()

	deadline := time.After(2 * time.Second)
	completed := false
	for !completed {
		select {
		case event := <-engine.events:
			engine.handle(event)
			completed = event.Kind == rcxEventProbeResults && event.Gen == gen
		case <-runtime.testStarted:
		case <-deadline:
			t.Fatal("the wave the new network bought never delivered its completion")
		}
	}

	if got := engine.ledger.MedianMs("a", cellularKey, runtime.Now(), time.Time{}, time.Time{}); got != 120 {
		t.Errorf("median = %d, want 120 recorded against the network that paid for it", got)
	}
}

func TestEngineStopsCollectingEvidenceOutsideRuleMode(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("node")
	engine := newTestEngine(runtime, "ru")
	engine.reconsider()
	runtime.mode = "global"

	for i := 0; i < 3; i++ {
		engine.NoteDial("node", true, time.Millisecond, runtime.Now())
	}
	engine.drainDials()

	if !engine.ledger.CoolUntil("node", "w:Home", engine.runtime.Now()).IsZero() {
		t.Error("in Global every request goes to one proxy: its failures say nothing about the park")
	}
}

func failDial(engine *rcxEngine, runtime *fakeRuntime, node string) {
	engine.NoteDial(node, true, time.Millisecond, runtime.Now())
	engine.drainDials()
}

// Three episodes, which is what a cooling window costs: an outage that folds into
// one accusation has not yet earned a ban.
func failDials(engine *rcxEngine, runtime *fakeRuntime, node string) {
	for i := 0; i < 3; i++ {
		if i > 0 {
			runtime.advance(rcxDefaultLedgerPolicy().EpisodeTTL + time.Second)
		}
		failDial(engine, runtime, node)
	}
}

// Bytes coming back on any row, the home path included, are what says the link
// itself is up.
func linkAnswers(engine *rcxEngine, runtime *fakeRuntime) {
	runtime.openConn("home", "DIRECT", "ya.ru")
	runtime.bumpConn("home", 200, 900)
	engine.sampleTraffic()
	runtime.closeConn("home")
}

func TestEngineRefundsWhatADarkLinkCharged(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("first", "second")
	engine := newTestEngine(runtime, "ru")
	engine.quit = make(chan struct{})

	failDial(engine, runtime, "first")
	runtime.advance(rcxLinkDark)
	failDial(engine, runtime, "second")
	linkAnswers(engine, runtime)

	for _, node := range []string{"first", "second"} {
		if got := engine.ledger.FailStreak(node, "w:Home"); got != 0 {
			t.Errorf("%s streak = %d, want it back: a blink accuses every node the user reaches for", node, got)
		}
	}
}

func TestEngineKeepsCoolingTheNodeThatFailedAlone(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("dead", "spare")
	engine := newTestEngine(runtime, "ru")

	failDials(engine, runtime, "dead")
	runtime.advance(rcxLinkDark)
	linkAnswers(engine, runtime)

	if engine.ledger.CoolUntil("dead", "w:Home", runtime.Now()).IsZero() {
		t.Error("one node failing while the link carries traffic is the node, and the cooling it earned stands")
	}
}

// Leaving a dead incumbent for the next dead node takes one tick, so a tick of
// separation is not yet darkness: the two verdicts stand or the engine walks the
// same corpses again.
func TestEngineKeepsTheVerdictsOfNodesEvictedOneTickApart(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("first", "second")
	engine := newTestEngine(runtime, "ru")
	engine.quit = make(chan struct{})

	failDial(engine, runtime, "first")
	runtime.advance(rcxTickInterval)
	failDial(engine, runtime, "second")
	linkAnswers(engine, runtime)

	for _, node := range []string{"first", "second"} {
		if got := engine.ledger.FailStreak(node, "w:Home"); got != 1 {
			t.Errorf("%s streak = %d, want the verdict it earned kept", node, got)
		}
	}
}

func TestEngineChargesNothingWhileTheRadioComesBack(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("node")
	engine := newTestEngine(runtime, "ru")
	engine.quit = make(chan struct{})

	engine.handle(rcxEvent{Kind: rcxEventSuspend, Flag: false})
	failDials(engine, runtime, "node")

	if !engine.ledger.CoolUntil("node", "w:Home", runtime.Now()).IsZero() {
		t.Fatal("the health checks a wake fires land before the radio is up: their failures are the sleep, not the park")
	}

	runtime.advance(rcxWakeGrace)
	failDials(engine, runtime, "node")

	if engine.ledger.CoolUntil("node", "w:Home", runtime.Now()).IsZero() {
		t.Error("past the grace a failing node is a failing node")
	}
}

func TestEngineChargesNothingOnALinkTheCanariesFoundDead(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("node")
	engine := newTestEngine(runtime, "ru")
	engine.terrain.observe(rcxTerrainOffline, runtime.Now())

	failDials(engine, runtime, "node")

	if !engine.ledger.CoolUntil("node", "w:Home", runtime.Now()).IsZero() {
		t.Error("nothing is measurable through a link both canary groups found dead")
	}
}

// A stale subscription is mostly dead nodes, and a wave that reached one of them
// has proven the link on its own: those verdicts are the nodes' to keep.
func TestEngineKeepsTheVerdictsOfAWaveThatGotAnAnswer(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("gone-a", "gone-b", "good")
	engine := newTestEngine(runtime, "ru")

	engine.handle(rcxEvent{Kind: rcxEventProbeResults, Results: []rcxProbeResult{
		{Node: "gone-a", Role: rcxRoleOpen, Outcome: rcxProbeFail},
		{Node: "gone-b", Role: rcxRoleOpen, Outcome: rcxProbeFail},
		{Node: "good", Role: rcxRoleOpen, Outcome: rcxProbeOK, DelayMs: 60},
	}})
	runtime.advance(rcxLinkDark + time.Second)
	linkAnswers(engine, runtime)

	for _, node := range []string{"gone-a", "gone-b"} {
		if got := openWorldProof(engine, node); got != rcxProofDisproven {
			t.Errorf("%s openWorld = %v, want it disproven", node, got)
		}
	}
}

// A request that asked and was never answered, held open across a confirmation
// window.
func freezePayload(engine *rcxEngine, runtime *fakeRuntime, node string) {
	// A stuck ClientHello bursts Up once then goes silent; the second sample only crosses the confirm window.
	runtime.openConn("starved", node, "example.org")
	runtime.bumpConn("starved", 1000, 0)
	runtime.advance(rcxConnStallAge)
	engine.sampleTraffic()
	runtime.advance(time.Duration(engine.cfg.DegradeConfirmSeconds+1) * time.Second)
	engine.sampleTraffic()
}

func openWorldProof(engine *rcxEngine, node string) rcxProof {
	facts := engine.ledger.Facts(
		node, engine.envKey, true, engine.runtime.Now(), engine.ledger.ProofTTL(),
	)
	return facts.OpenWorld
}

func TestEngineConfirmsAFreezeBeforeBlamingTheNode(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("node")
	engine := newTestEngine(runtime, "ru")
	engine.incumbent = "node"

	runtime.openConn("req", "node", "example.org")
	runtime.bumpConn("req", 1000, 0)
	runtime.advance(rcxConnStallAge)
	engine.sampleTraffic()

	if engine.ledger.Degraded("node", "w:Home", runtime.Now()) {
		t.Fatal("one tick of unanswered payload is a suspicion, not a confirmed freeze")
	}

	runtime.advance(time.Duration(engine.cfg.DegradeConfirmSeconds+1) * time.Second)
	engine.sampleTraffic()

	if !engine.ledger.Degraded("node", "w:Home", runtime.Now()) {
		t.Fatal("payload that left and never came back is throttling, which no dial verdict shows")
	}
	if !engine.ledger.Stalled("node", "w:Home") {
		t.Error("a frozen incumbent must owe a probe")
	}

	runtime.bumpConn("req", 1000, 9000)
	engine.sampleTraffic()

	if engine.ledger.Degraded("node", "w:Home", runtime.Now()) {
		t.Error("bytes coming back must clear the verdict")
	}
	if engine.ledger.Stalled("node", "w:Home") {
		t.Error("payload is the answer the suspicion was waiting for")
	}
}

func TestEngineConfirmsAColdIncumbentFasterThanASettledOne(t *testing.T) {
	shortWindow := time.Duration(rcxColdConfirmSec)*time.Second + time.Second

	runtime := newFakeRuntime()
	runtime.members = foreignMembers("node")
	engine := newTestEngine(runtime, "ru")
	engine.incumbent = "node"
	runtime.openConn("req", "node", "example.org")
	runtime.bumpConn("req", 1000, 0)
	runtime.advance(rcxConnStallAge)
	engine.sampleTraffic()
	runtime.advance(shortWindow)
	engine.sampleTraffic()

	if !engine.ledger.Degraded("node", "w:Home", runtime.Now()) {
		t.Fatal("a cold incumbent that never moved a byte owes no benefit of the doubt")
	}

	proven := newFakeRuntime()
	proven.members = foreignMembers("node")
	engine2 := newTestEngine(proven, "ru")
	engine2.incumbent = "node"
	engine2.ledger.NoteTrafficProgress("node", "w:Home", false, proven.Now())
	proven.openConn("req", "node", "example.org")
	proven.bumpConn("req", 1000, 0)
	proven.advance(rcxConnStallAge)
	engine2.sampleTraffic()
	proven.advance(shortWindow)
	engine2.sampleTraffic()

	if engine2.ledger.Degraded("node", "w:Home", proven.Now()) {
		t.Error("a node that proved passage keeps the full window against noise")
	}
}

// The aggregate a node used to be judged by falls whenever a download ends, and a
// counter that falls is indistinguishable from one that froze.
func TestEngineReadsAClosedDownloadAsProgress(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("node")
	engine := newTestEngine(runtime, "ru")
	engine.incumbent = "node"

	runtime.openConn("big", "node", "cdn.example")
	runtime.bumpConn("big", 2000, 10<<20)
	runtime.openConn("small", "node", "api.example")
	runtime.bumpConn("small", 500, 4000)
	engine.sampleTraffic()

	runtime.closeConn("big")
	for i := 0; i < 2; i++ {
		runtime.advance(time.Duration(engine.cfg.DegradeConfirmSeconds+1) * time.Second)
		runtime.bumpConn("small", 500, 2000)
		engine.sampleTraffic()
	}

	if engine.ledger.Degraded("node", "w:Home", runtime.Now()) ||
		engine.ledger.Stalled("node", "w:Home") {
		t.Error("a download that finished is the opposite of a freeze")
	}
	if len(engine.downFrozen) != 0 {
		t.Error("requests that keep answering leave nothing to confirm")
	}
}

// A connection that answered once and went quiet is idle: the keepalives leaving
// it carry no accusation.
func TestEngineTreatsAnIdleTunnelAsAlive(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("node")
	engine := newTestEngine(runtime, "ru")
	engine.incumbent = "node"

	runtime.openConn("req", "node", "example.org")
	runtime.bumpConn("req", 1000, 500)
	engine.sampleTraffic()
	for i := 0; i < 3; i++ {
		runtime.advance(time.Duration(engine.cfg.DegradeConfirmSeconds+1) * time.Second)
		runtime.bumpConn("req", 200, 0)
		engine.sampleTraffic()
	}

	if engine.ledger.Degraded("node", "w:Home", runtime.Now()) ||
		engine.ledger.Stalled("node", "w:Home") {
		t.Error("nothing was asked of the node: an idle tunnel is not a dead one")
	}
	if len(engine.downFrozen) != 0 {
		t.Error("with no payload outstanding there is no freeze to confirm")
	}
}

// Bytes written to a proxy connection reach a send buffer that autotunes into
// megabytes, so a black hole absorbs an upload without acknowledging one byte.
func TestEngineRefusesUploadAsProofOfTransit(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("node")
	engine := newTestEngine(runtime, "ru")
	engine.incumbent = "node"

	runtime.openConn("req", "node", "example.org")
	runtime.bumpConn("req", 4<<20, 0)
	runtime.advance(rcxConnStallAge)
	engine.sampleTraffic()

	if !engine.ledger.ProgressAt("node", "w:Home").IsZero() {
		t.Error("an upload nobody answered is not transit")
	}
	if len(engine.downFrozen) == 0 {
		t.Error("payload that left and was never answered is the freeze signal itself")
	}
}

// Growing Up is proof the link is alive (§1.9), so a minutes-long upload with
// nothing coming back must never freeze, even past a stuck ClientHello's window.
func TestEngineKeepsAGrowingUploadAlive(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("node")
	engine := newTestEngine(runtime, "ru")
	engine.incumbent = "node"

	runtime.openConn("upload", "node", "example.org")
	runtime.bumpConn("upload", 1<<20, 0)
	runtime.advance(rcxConnStallAge)
	engine.sampleTraffic()

	ticks := engine.cfg.DegradeConfirmSeconds/int(rcxWatchInterval/time.Second) + 2
	for i := 0; i < ticks; i++ {
		runtime.advance(rcxWatchInterval)
		runtime.bumpConn("upload", 1<<20, 0)
		engine.sampleTraffic()
	}

	if len(engine.downFrozen) != 0 {
		t.Error("a still-growing upload is a live link, not a stuck handshake")
	}
	if engine.ledger.Stalled(engine.key("node"), engine.envKey) {
		t.Error("a node moving upload bytes must not be marked stalled")
	}
}

// Downloading from a domestic host through the same node while the marker request
// hangs used to prove the open world for free.
func TestEngineProvesTheOpenWorldOnlyFromMarkerBytes(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("node")
	engine := newTestEngine(runtime, "ru")
	engine.incumbent = "node"

	runtime.openConn("marker", "node", "www.youtube.com")
	runtime.openConn("home", "node", "ya.ru")
	engine.sampleTraffic()

	runtime.bumpConn("home", 500, 8000)
	runtime.bumpConn("marker", 500, 0)
	engine.sampleTraffic()

	if openWorldProof(engine, "node") == rcxProofProven {
		t.Error("a domestic answer beside a hanging marker is a coincidence, not a proof")
	}
	if engine.ledger.ProgressAt("node", "w:Home").IsZero() {
		t.Error("bytes did come back: the node moves traffic")
	}

	runtime.bumpConn("marker", 0, 204)
	engine.sampleTraffic()

	if openWorldProof(engine, "node") != rcxProofProven {
		t.Error("an answer on the marker connection itself is the proof")
	}
}

// The answer can land on a request that closed between two ticks, so the sighting
// keeps the counter it will be judged by.
func TestEngineProvesTheOpenWorldFromAClosedMarkerRequest(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("node")
	engine := newTestEngine(runtime, "ru")
	tracker := newFakeTracker("marker-1", "node", "www.youtube.com")

	engine.NoteTracker(tracker)
	engine.sampleTraffic()

	if openWorldProof(engine, "node") == rcxProofProven {
		t.Fatal("a request that only opened proves nothing")
	}

	tracker.info.DownloadTotal.Store(204)
	engine.sampleTraffic()

	if openWorldProof(engine, "node") != rcxProofProven {
		t.Error("bytes on the marker connection prove it whether or not it is still open")
	}
	if len(engine.openSeen) != 0 {
		t.Error("a sighting that paid off must not be reconsidered every tick")
	}
}

func TestEngineForgetsAMarkerThatNeverAnswered(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("node")
	engine := newTestEngine(runtime, "ru")
	engine.NoteTracker(newFakeTracker("marker-1", "node", "www.youtube.com"))

	runtime.advance(rcxOpenSightWindow + time.Second)
	engine.sampleTraffic()

	if len(engine.openSeen) != 0 {
		t.Error("an unanswered sighting must expire, not pin a tracker for the session")
	}
	if openWorldProof(engine, "node") == rcxProofProven {
		t.Error("a marker request that timed out is evidence against, never for")
	}
}

func TestEngineHoldsAFrozenIncumbentUntilAProbeAnswers(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("node", "spare")
	engine := newTestEngine(runtime, "ru")
	engine.incumbent = "node"
	engine.since = runtime.Now().Add(-time.Hour)
	runtime.selected = "node"
	engine.ledger.NoteTrafficProgress("node", "w:Home", false, runtime.Now())

	freezePayload(engine, runtime, "node")
	engine.reconsider()

	if got := runtime.selected; got != "node" {
		t.Fatalf("selected = %q: a suspicion may not tear down what it cannot disprove", got)
	}
	if !engine.probing {
		t.Fatal("the freeze must buy the probe that settles it")
	}

	engine.handle(rcxEvent{Kind: rcxEventProbeResults, Results: []rcxProbeResult{
		{Node: "node", Role: rcxRoleOpen, Outcome: rcxProbeFail},
	}})

	if got := runtime.selected; got != "node" {
		t.Errorf("selected = %q: a frozen server survives the miss its own freeze provoked", got)
	}

	engine.handle(rcxEvent{Kind: rcxEventProbeResults, Results: []rcxProbeResult{
		{Node: "node", Role: rcxRoleOpen, Outcome: rcxProbeFail},
	}})

	if got := runtime.selected; got != "spare" {
		t.Errorf("selected = %q, want a second consecutive miss to evict the node it disproved", got)
	}
}

// The switch a suspicion would justify has to wait for the measurement: the
// traffic used to move first and the probe arrived once it no longer mattered.
func TestEngineMeasuresASuspicionBeforeItMovesTraffic(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("node", "spare")
	engine := newTestEngine(runtime, "ru")
	engine.incumbent = "node"
	engine.since = runtime.Now().Add(-time.Hour)
	runtime.selected = "node"
	engine.ledger.NoteTrafficProgress("node", "w:Home", false, runtime.Now())
	engine.ledger.NoteProbe("spare", "w:Home", rcxRoleOpen, rcxProbeOK, 40, runtime.Now())

	freezePayload(engine, runtime, "node")
	engine.reconsider()

	if got := runtime.selected; got != "node" {
		t.Fatalf("selected = %q: the gain over a suspicion is still unmeasured", got)
	}
	if got := runtime.lastStatus().Reason; got != string(rcxReasonQualityConfirming) {
		t.Errorf("reason = %q, want the trace to name what the hold waits for", got)
	}

	engine.handle(rcxEvent{Kind: rcxEventProbeResults, Results: []rcxProbeResult{
		{Node: "node", Role: rcxRoleOpen, Outcome: rcxProbeOK, DelayMs: 30},
	}})

	if got := runtime.selected; got != "node" {
		t.Errorf("selected = %q, want the node the measurement cleared", got)
	}
}

func TestEngineDeliversARoundCompletionUnderQueuePressure(t *testing.T) {
	engine := newTestEngine(newFakeRuntime(), "ru")
	for len(engine.events) < cap(engine.events) {
		engine.send(rcxEvent{Kind: rcxEventHarvested})
	}

	quit := make(chan struct{})
	landed := make(chan struct{})
	go func() {
		engine.sendResult(rcxEvent{Kind: rcxEventProbeResults}, quit)
		close(landed)
	}()

	select {
	case <-landed:
		t.Fatal("a full queue must make the round wait, not drop its completion")
	case <-time.After(20 * time.Millisecond):
	}

	<-engine.events
	select {
	case <-landed:
	case <-time.After(2 * time.Second):
		t.Fatal("the completion never landed: probing would stay latched all session")
	}

	stopped := make(chan struct{})
	go func() {
		engine.sendResult(rcxEvent{Kind: rcxEventProbeResults}, quit)
		close(stopped)
	}()
	close(quit)
	select {
	case <-stopped:
	case <-time.After(2 * time.Second):
		t.Fatal("a stopped engine must not hold its prober goroutine forever")
	}
}

func TestEngineBuysOneWaveAtATime(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("a", "b", "c")
	engine := newTestEngine(runtime, "ru")

	engine.reconsider()
	if !engine.probing {
		t.Fatal("a cold start with no evidence is exactly what a probe is for")
	}
	before := engine.budget.Remaining(runtime.Now())

	engine.reconsider()

	if got := engine.budget.Remaining(runtime.Now()); got != before {
		t.Errorf("budget went from %d to %d: a wave in flight must not buy another", before, got)
	}
}

func TestEngineChargesTheBudgetForTheWaveItRuns(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("a", "b")
	engine := newTestEngine(runtime, "ru")
	// The enablement wave is free, so charging is only visible on the next one.
	engine.reconsider()
	engine.handle(rcxEvent{Kind: rcxEventProbeResults})
	engine.incumbent = ""
	engine.reconsider()

	spent := rcxProbeBudgetCap - engine.budget.Remaining(runtime.Now())
	if spent != len(runtime.members) {
		t.Errorf("spent %d probes on a park of %d: an hour of budget goes to waves never run",
			spent, len(runtime.members))
	}
}

func TestEngineSplitsDirectOnlyWhenTheHomePathIsDead(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("node")
	engine := newTestEngine(runtime, "ru")

	engine.reconsider()
	if got := runtime.groupSelected[rcxGroupDirect]; got != "DIRECT" {
		t.Fatalf("direct split = %q on an open network, want DIRECT", got)
	}
	if engine.direct != "direct" {
		t.Errorf("status direct = %q, want direct", engine.direct)
	}

	// A whitelist is measured by a domestic canary that answered, so home
	// services reach the device directly; tunnelling them through a foreign
	// egress is what breaks the geo-filtered ones.
	engine.reachD = rcxProbeOK
	engine.terrain.observe(rcxTerrainWhitelist, runtime.Now())
	engine.reconsider()
	if got := runtime.groupSelected[rcxGroupDirect]; got != "DIRECT" {
		t.Fatalf("direct split = %q under a whitelist, want DIRECT while home answers", got)
	}

	engine.reachD = rcxProbeFail
	engine.reconsider()
	if got := runtime.groupSelected[rcxGroupDirect]; got != rcxGroupNode {
		t.Fatalf("direct split = %q with the home path dead, want the node group", got)
	}
	if engine.direct != "node" {
		t.Errorf("status direct = %q, want node", engine.direct)
	}
}

func TestEngineImmediatelyConfirmsAWhitelistSighting(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.reach["1.1.1.1:443"] = rcxProbeFail
	runtime.reach["77.88.8.8:443"] = rcxProbeOK
	engine := newTestEngine(runtime, "ru")
	engine.quit = make(chan struct{})
	engine.reaching = true
	engine.validated = true

	engine.handle(rcxEvent{
		Kind: rcxEventTerrainReach, Gen: engine.reachGen,
		Foreign: rcxProbeFail, Domestic: rcxProbeOK,
	})

	if !engine.reaching {
		t.Fatal("second whitelist confirmation round did not start immediately")
	}
}

func TestEngineRetriesABlindCanaryRoundImmediately(t *testing.T) {
	runtime := newFakeRuntime()
	engine := newTestEngine(runtime, "ru")
	engine.quit = make(chan struct{})
	engine.reaching = true

	engine.handle(rcxEvent{
		Kind: rcxEventTerrainReach, Gen: engine.reachGen,
		Foreign: rcxProbeOverloaded, Domestic: rcxProbeOverloaded,
	})

	if !engine.reaching || engine.reachBlind != 1 {
		t.Fatalf("reaching=%v blind=%d, want one immediate retry", engine.reaching, engine.reachBlind)
	}
}

func TestEngineDefersCanaryWhileScreenOffOrSuspended(t *testing.T) {
	runtime := newFakeRuntime()
	engine := newTestEngine(runtime, "ru")
	engine.cfg.CanaryForeign = []string{"1.1.1.1:443"}
	engine.quit = make(chan struct{})

	engine.screenOff = true
	engine.startReach()
	if engine.reaching {
		t.Fatal("screen-off engine started a canary round")
	}
	engine.screenOff = false
	engine.suspended = true
	engine.startReach()
	if engine.reaching {
		t.Fatal("suspended engine started a canary round")
	}
	engine.suspended = false
	engine.startReach()
	if !engine.reaching {
		t.Fatal("active engine did not start its deferred canary round")
	}
}

func TestScreenOffCancelsCanaryRound(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.hang = map[string]bool{"1.1.1.1:443": true}
	engine := newTestEngine(runtime, "ru")
	engine.cfg.CanaryForeign = []string{"1.1.1.1:443"}
	engine.quit = make(chan struct{})
	engine.startReach()
	gen := engine.reachGen

	engine.applyScreenOff(true)
	if engine.reaching || engine.reachGen == gen {
		t.Fatal("screen-off did not cancel and supersede the canary round")
	}
	select {
	case event := <-engine.events:
		engine.handle(event)
		if engine.reaching {
			t.Fatal("cancelled canary result restarted while the screen was off")
		}
	case <-time.After(time.Second):
		t.Fatal("cancelled canary round did not finish")
	}
}

func TestEngineGivesEachCanaryGroupItsOwnDeadline(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.reach = map[string]rcxProbeOutcome{
		"77.88.8.8:443": rcxProbeOK,
	}
	engine := newTestEngine(runtime, "ru")
	engine.cfg.CanaryForeign = []string{"1.1.1.1:443", "9.9.9.9:443"}
	engine.quit = make(chan struct{})

	engine.startReach()
	event := <-engine.events

	if event.Domestic != rcxProbeOK {
		t.Errorf("domestic = %s, want ok: foreign timeouts must not spend the home group's deadline",
			rcxOutcomeName(event.Domestic))
	}
	if len(event.Canaries) != 3 {
		t.Errorf("canaries = %d, want a row per address", len(event.Canaries))
	}
}

func TestEngineProbesBothMarkersWhereGeographyIsUnknown(t *testing.T) {
	runtime := newFakeRuntime()
	engine := newTestEngine(runtime, "ru")
	wave := []rcxProbeNode{{Name: "foreign", Key: "foreign"}, {Name: "home", Key: "home"}}
	engine.ledger.SetOrigin("home", "RU", rcxOriginDomestic)

	normal := engine.probeTargets(wave, rcxTerrainNormal, rcxWaveRoutine)
	if len(normal) != 2 {
		t.Fatalf("targets = %d on an open network, want one marker per node", len(normal))
	}

	targets := engine.probeTargets(wave, rcxTerrainWhitelist, rcxWaveRoutine)
	if len(targets) != 4 {
		t.Fatalf("targets = %d, want both markers per node", len(targets))
	}
	if targets[0].Role != rcxRoleOpen || targets[0].Node != "foreign" {
		t.Errorf("first target = %v, want the open marker on the foreign node", targets[0])
	}
	if targets[1].Role != rcxRoleDomestic || targets[1].Node != "home" {
		t.Errorf("second target = %v, want the home marker first on a domestic node", targets[1])
	}
	// Every node is measured once before any is measured twice.
	if targets[2].Node != "foreign" || targets[2].Role != rcxRoleDomestic {
		t.Errorf("third target = %v, want the secondary pass to start after the first", targets[2])
	}

	// A sweep walks the pool once and never returns to it, so a node's second
	// marker rides beside its first or is never asked at all.
	paired := engine.probeTargets(wave, rcxTerrainWhitelist, rcxWaveRescue)
	if paired[0].Node != "foreign" || paired[1].Node != "foreign" {
		t.Errorf("sweep targets = %v, want both markers of the first node adjacent", paired[:2])
	}
	if paired[0].Role == paired[1].Role {
		t.Error("a node asked the same marker twice measures one fact twice")
	}
}

func TestEngineShortensTheCanaryCycleOffANormalTerrain(t *testing.T) {
	runtime := newFakeRuntime()
	engine := newTestEngine(runtime, "ru")

	if got := engine.reachInterval(); got != rcxReachRefresh {
		t.Errorf("interval = %v, want the slow cycle on a healthy network", got)
	}

	engine.terrain.observe(rcxTerrainUnknown, runtime.Now())
	if got := engine.reachInterval(); got != rcxReachUrgent {
		t.Errorf("interval = %v, want the urgent cycle: two rounds confirm a whitelist", got)
	}
}

func TestEngineRotatesTheWaveAcrossTheWholePark(t *testing.T) {
	runtime := newFakeRuntime()
	names := make([]string, 0, 24)
	for i := 0; i < 24; i++ {
		names = append(names, "n"+string(rune('a'+i)))
	}
	runtime.members = foreignMembers(names...)
	engine := newTestEngine(runtime, "ru")
	members := runtime.members

	first := engine.planWave(engine.candidates(members), members, rcxWaveRoutine)
	if len(first) != rcxWaveWidth {
		t.Fatalf("wave = %d nodes, want the configured width", len(first))
	}
	for _, node := range first {
		engine.ledger.NoteProbe(node.Name, engine.envKey, rcxRoleOpen, rcxProbeFail, 0, runtime.Now())
	}
	runtime.advance(time.Second)
	second := engine.planWave(engine.candidates(members), members, rcxWaveRoutine)

	seen := map[string]bool{}
	for _, node := range append(append([]rcxProbeNode{}, first...), second...) {
		seen[node.Name] = true
	}
	if len(seen) != len(names) {
		t.Errorf("two waves covered %d of %d nodes: a park larger than one wave is never checked", len(seen), len(names))
	}
}

func rescuePark(t *testing.T) (*fakeRuntime, *rcxEngine, []rcxMember) {
	t.Helper()
	runtime := newFakeRuntime()
	names := make([]string, 0, 30)
	for i := 0; i < 30; i++ {
		names = append(names, "n"+string(rune('a'+i)))
	}
	runtime.members = foreignMembers(names...)
	engine := newTestEngine(runtime, "ru")
	return runtime, engine, runtime.members
}

func TestEngineWalksRescueInBoundedBatchesBeforeTheFloor(t *testing.T) {
	runtime, engine, members := rescuePark(t)
	seen := map[string]bool{}
	for batch := 0; batch < 3; batch++ {
		wave := engine.planWave(engine.candidates(members), members, rcxWaveRescue)
		if len(wave) != rcxWaveWidth && batch < 2 {
			t.Fatalf("batch %d = %d nodes, want the configured width", batch, len(wave))
		}
		for _, node := range wave {
			if seen[node.Name] {
				t.Fatalf("batch %d repeated %q before exhausting the park", batch, node.Name)
			}
			seen[node.Name] = true
		}
	}
	if len(seen) != len(members) {
		t.Fatalf("rescue covered %d of %d nodes before the floor", len(seen), len(members))
	}
	if got := engine.planWave(engine.candidates(members), members, rcxWaveRescue); got != nil {
		t.Errorf("post-exhaustion rescue = %d nodes, want the floor", len(got))
	}
	if got := engine.planWave(engine.candidates(members), members, rcxWaveDeep); len(got) != len(members) {
		t.Errorf("deep sweep = %d nodes, want the whole park", len(got))
	}

	runtime.advance(rcxRescueRepeat)
	if got := engine.planWave(engine.candidates(members), members, rcxWaveRescue); len(got) != rcxWaveWidth {
		t.Errorf("rescue after floor = %d nodes, want a fresh bounded batch", len(got))
	}
}

func TestEngineResetsRecoveryWhenTerrainChanges(t *testing.T) {
	runtime, engine, members := rescuePark(t)
	first := engine.planWave(engine.candidates(members), members, rcxWaveRescue)
	if len(first) != rcxWaveWidth {
		t.Fatalf("first rescue = %d nodes, want a bounded batch", len(first))
	}

	runtime.advance(rcxTickInterval)
	engine.terrain.observe(rcxTerrainWhitelist, runtime.Now())
	second := engine.planWave(engine.candidates(members), members, rcxWaveRescue)
	if len(second) != rcxWaveWidth {
		t.Fatalf("rescue after terrain change = %d nodes", len(second))
	}
	if second[0].Name != first[0].Name {
		t.Errorf("first node = %q, want %q: a new terrain starts a new episode", second[0].Name, first[0].Name)
	}
}

func TestEngineResetsRecoveryAfterASuitableAnswer(t *testing.T) {
	_, engine, members := rescuePark(t)
	first := engine.planWave(engine.candidates(members), members, rcxWaveRescue)
	engine.probing = true
	engine.probeKind = rcxWaveRescue
	engine.applyProbeResult(rcxEvent{Gen: engine.probeGen, ConfigGen: engine.configGen, Results: []rcxProbeResult{{
		Node: first[0].Name, Role: rcxRoleOpen, Outcome: rcxProbeOK, DelayMs: 120,
	}}})

	if len(engine.rescueSeen) != 0 || engine.rescueExhausted {
		t.Fatal("a suitable answer must close the recovery episode")
	}
}

func TestEngineKeepsRescueOutsideTheHourlyCap(t *testing.T) {
	runtime, engine, members := rescuePark(t)
	wave := engine.planWave(engine.candidates(members), members, rcxWaveRescue)

	if len(wave) != rcxWaveWidth {
		t.Errorf("rescue wave = %d nodes, want a bounded batch", len(wave))
	}
	if got := engine.budget.Remaining(runtime.Now()); got != rcxProbeBudgetCap {
		t.Errorf("budget left = %d, want recovery outside the hourly cap", got)
	}
}

func TestRecoveryWaveUsesMemoryAndGreenOriginTiers(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = []rcxMember{
		{Name: "unknown", Provider: "p-unknown", Type: "Vless", Port: 443, SupportsUDP: true},
		{Name: "green-home", Provider: "p-home", Type: "Vless", Port: 443, SupportsUDP: true, HostMs: 50, HostAt: runtime.Now()},
		{Name: "green-away", Provider: "p-away", Type: "Vless", Port: 443, SupportsUDP: true, HostMs: 80, HostAt: runtime.Now()},
		{Name: "known", Provider: "p-known", Type: "Vless", Port: 443, SupportsUDP: true},
		{Name: "standby", Provider: "p-standby", Type: "Vless", Port: 443, SupportsUDP: true},
		{Name: "remembered", Provider: "p-memory", Type: "Vless", Port: 443, SupportsUDP: true},
	}
	runtime.countries = map[string]string{"green-away": "NL", "green-home": "RU"}
	engine := newTestEngine(runtime, "ru")
	engine.cfg.WaveWidth = len(runtime.members)
	engine.candidates(runtime.members)
	engine.snapshot.Picks[engine.envKey] = "remembered"
	engine.snapshot.Standbys[engine.envKey] = []string{"standby"}
	engine.ledger.NoteProbe("known", engine.envKey, rcxRoleOpen, rcxProbeOK, 120, runtime.Now())

	wave := engine.planWave(engine.candidates(runtime.members), runtime.members, rcxWaveHandoff)
	positions := map[string]int{}
	for i, node := range wave {
		positions[node.Name] = i
	}
	order := []string{"remembered", "standby", "known", "green-away", "green-home", "unknown"}
	for i := 1; i < len(order); i++ {
		if positions[order[i-1]] >= positions[order[i]] {
			t.Fatalf("wave = %v, want %q before %q", wave, order[i-1], order[i])
		}
	}
}

func TestHandoffWaveLeavesFreshHostTimeoutsOut(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = []rcxMember{
		{Name: "dead", Type: "Vless", Port: 443, SupportsUDP: true, HostDead: true, HostAt: runtime.Now()},
		{Name: "live", Type: "Vless", Port: 443, SupportsUDP: true, HostMs: 80, HostAt: runtime.Now()},
	}
	engine := newTestEngine(runtime, "ru")

	wave := engine.planWave(engine.candidates(runtime.members), runtime.members, rcxWaveHandoff)
	if len(wave) < 2 || wave[0].Name != "live" || wave[len(wave)-1].Name != "dead" {
		t.Fatalf("wave = %v, want live first and dead last", wave)
	}
}

func TestRecoveryWaveProbesInsideAProviderCircuit(t *testing.T) {
	runtime := newFakeRuntime()
	names := make([]string, 0, 30)
	for i := 0; i < 30; i++ {
		names = append(names, "n"+string(rune('a'+i)))
	}
	runtime.members = providerMembers("one", names...)
	engine := newTestEngine(runtime, "ru")
	engine.noteProviderNodeFailure(names[0], runtime.Now())
	engine.noteProviderNodeFailure(names[1], runtime.Now())

	if wave := engine.planWave(engine.candidates(runtime.members), runtime.members, rcxWaveRoutine); len(wave) != 0 {
		t.Fatalf("routine wave = %d nodes, want the open circuit held", len(wave))
	}
	wave := engine.planWave(engine.candidates(runtime.members), runtime.members, rcxWaveRescue)
	if len(wave) != rcxWaveWidth {
		t.Fatalf("recovery wave = %d nodes, want a bounded circuit probe", len(wave))
	}
}

func TestRecoveryReportsMeasuringUntilTheEpisodeIsExhausted(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("only")
	engine := newTestEngine(runtime, "ru")
	engine.incumbent = "only"
	engine.ledger.NoteProbe("only", engine.envKey, rcxRoleOpen, rcxProbeFail, 0, runtime.Now())

	engine.reconsider()
	status := runtime.lastStatus()
	if status.Reason != string(rcxReasonMeasuring) || !status.Searching {
		t.Fatalf("status = %+v, want measuring while recovery is active", status)
	}
	engine.supersedeProbe()
	engine.pendingGrant = false
	engine.startProbe(engine.candidates(runtime.members), runtime.members, rcxWaveRescue)
	if !engine.rescueExhausted {
		t.Fatalf("rescue did not exhaust its one-node park: %v", engine.rescueSeen)
	}
	engine.finishProbe()
	status = runtime.lastStatus()
	if status.Reason != string(rcxReasonStranded) || status.Searching {
		t.Fatalf("status = %+v, want final stranded after exhaustion", status)
	}
}

func TestEngineGivesBackTheBudgetSpentOnProbesThatNeverRan(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("a", "b", "c", "d")
	engine := newTestEngine(runtime, "ru")
	members := runtime.members

	wave := engine.planWave(engine.candidates(members), members, rcxWaveRoutine)
	if got := engine.budget.Remaining(runtime.Now()); got != rcxProbeBudgetCap-len(wave) {
		t.Fatalf("budget left = %d, want the whole wave charged up front", got)
	}

	results := make([]rcxProbeResult, 0, len(wave))
	for i, node := range wave {
		outcome := rcxProbeOverloaded
		if i == 0 {
			outcome = rcxProbeFail
		}
		results = append(results, rcxProbeResult{Node: node.Name, Role: rcxRoleOpen, Outcome: outcome})
	}
	engine.handle(rcxEvent{Kind: rcxEventProbeResults, Results: results})

	if got := engine.budget.Remaining(runtime.Now()); got != rcxProbeBudgetCap-1 {
		t.Errorf("budget left = %d, want a charge only for the probe that measured something", got)
	}
}

func TestEngineLetsWorkingTrafficStandInForAProbe(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("a", "b")
	engine := newTestEngine(runtime, "ru")
	engine.incumbent = "a"
	engine.since = runtime.Now().Add(-time.Hour)

	// Handshakes alone prove nothing anymore: a dial-alive, traffic-dead node
	// must arm the disproof wave.
	engine.ledger.NoteDialSuccess("a", "w:Home", 70*time.Millisecond, runtime.Now())
	engine.reconsider()
	if !engine.probing {
		t.Fatal("handshake evidence must not stand in for payload: the wave should be armed")
	}

	// Payload progress is the stand-in the engine actually trusts.
	engine.probing = false
	engine.ledger.NoteTrafficProgress("a", "w:Home", false, runtime.Now())
	engine.reconsider()
	if engine.probing {
		t.Error("the user's own payload already proved the node: paying for a probe is waste")
	}
}

func TestEngineHarvestsOnlyUnderTheAppYardstick(t *testing.T) {
	savedURL, savedDefault := currentTestURL(), C.DefaultTestURL
	t.Cleanup(func() {
		setTestURL(savedURL)
		C.DefaultTestURL = savedDefault
	})
	const yardstick = "https://yard.example/generate_204"
	setTestURL(yardstick)

	runtime := newFakeRuntime()
	runtime.members = foreignMembers("a")
	engine := newTestEngine(runtime, "ru")

	engine.NoteHarvestedProbe("https://provider.example/health", "a", 120)
	engine.NoteHarvestedProbe("https://provider.example/health", "a", 0)
	select {
	case event := <-engine.events:
		t.Fatalf("harvested %+v: a delay measured against another yardstick is not a fact about ours", event)
	default:
	}

	engine.NoteHarvestedProbe(yardstick, "a", 120)
	select {
	case event := <-engine.events:
		if event.Kind != rcxEventHarvested || event.Node != "a" || event.DelayMs != 120 {
			t.Errorf("event = %+v, want a 120ms harvest for a", event)
		}
	default:
		t.Fatal("the hand test under our own yardstick is the only park-wide measurement there is")
	}
}

func TestEngineIgnoresAHarvestAboutANodeItDoesNotOffer(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("a")
	engine := newTestEngine(runtime, "ru")

	engine.handle(rcxEvent{Kind: rcxEventHarvested, Node: "RCX-NODE", DelayMs: 120})

	if got := len(engine.ledger.envs["w:Home"]); got != 0 {
		t.Errorf("ledger rows = %d, want none: a group name is not a node to remember", got)
	}
}

func TestEngineCountsADialAnswerAsALinkAnswer(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("a", "b", "c")
	engine := newTestEngine(runtime, "ru")

	failDial(engine, runtime, "a")
	failDial(engine, runtime, "b")
	runtime.advance(rcxLinkDark)
	engine.NoteDial("c", false, 70*time.Millisecond, runtime.Now())
	engine.drainDials()

	for _, node := range []string{"a", "b"} {
		if got := engine.ledger.envState("w:Home", node).FailStreak; got != 0 {
			t.Errorf("%s fail streak = %d, want 0: an answer on any node exonerates the dark link", node, got)
		}
	}
}

func TestEngineProvesNoTransitThroughHandshakes(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("a", "b")
	engine := newTestEngine(runtime, "ru")

	for i := 0; i < 3; i++ {
		engine.NoteDial("a", false, 70*time.Millisecond, runtime.Now())
		engine.drainDials()
		runtime.advance(time.Second)
	}

	if got := engine.ledger.Facts("a", "w:Home", true, runtime.Now(), rcxLedgerProofTTL).Transit; got == rcxProofProven {
		t.Error("no number of handshakes buys the proven rank: an SNI block opens every one of them")
	}
}

func TestEngineHonoursAManualPickUntilTheNodeDies(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("chosen", "spare")
	engine := newTestEngine(runtime, "ru")
	engine.ledger.NoteProbe("chosen", "w:Home", rcxRoleOpen, rcxProbeOK, 900, runtime.Now())
	engine.ledger.NoteProbe("spare", "w:Home", rcxRoleOpen, rcxProbeOK, 60, runtime.Now())

	engine.handle(rcxEvent{Kind: rcxEventManualPick, Node: "chosen"})
	runtime.advance(6 * time.Hour)
	engine.reconsider()

	if got := engine.incumbent; got != "chosen" {
		t.Fatalf("incumbent = %q, want the pin to outlive any timer", got)
	}

	rcxChargeFailures(engine.ledger, "chosen", "w:Home", rcxTerrainNormal, runtime.Now(), 3)
	engine.reconsider()

	if got := runtime.selected; got != "spare" {
		t.Errorf("selected = %q, want a dead pinned node replaced by a working one", got)
	}
	if got := engine.pin(); got != "chosen" {
		t.Errorf("pin = %q, want the pin remembered while its node is unusable", got)
	}
	if got := runtime.lastStatus().Node; got != "spare" {
		t.Errorf("node = %q, want the successor: the pin must not hold the engine on a dead node", got)
	}
}

func TestEngineReleasingAPinReassertsTheNode(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("chosen", "spare")
	engine := newTestEngine(runtime, "ru")
	engine.ledger.NoteProbe("chosen", "w:Home", rcxRoleOpen, rcxProbeOK, 60, runtime.Now())
	engine.ledger.NoteProbe("spare", "w:Home", rcxRoleOpen, rcxProbeOK, 900, runtime.Now())

	engine.handle(rcxEvent{Kind: rcxEventManualPick, Node: "chosen"})
	// The host clears the selector before asking for the pin back.
	runtime.selected = ""
	engine.handle(rcxEvent{Kind: rcxEventManualAssert, Node: ""})

	if got := engine.pin(); got != "" {
		t.Errorf("pin = %q, want an empty pick to release it", got)
	}
	if got := runtime.selected; got != "chosen" {
		t.Errorf("selected = %q, want the incumbent re-asserted rather than an empty group", got)
	}
}

func TestEngineFallsBackToADomesticNodeOnlyUnderAShutdown(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("foreign", "domestic")
	runtime.countries = map[string]string{"foreign": "NL", "domestic": "RU"}
	engine := newTestEngine(runtime, "ru")
	engine.ledger.NoteProbe("foreign", "c:25001", rcxRoleOpen, rcxProbeFail, 0, runtime.Now())
	engine.ledger.NoteProbe("domestic", "c:25001", rcxRoleDomestic, rcxProbeOK, 40, runtime.Now())
	engine.envKey = "c:25001"

	engine.terrain.observe(rcxTerrainNormal, runtime.Now())
	engine.reconsider()
	if len(runtime.selects) != 0 {
		t.Fatalf("selects = %v, want none: a domestic node opens nothing on a healthy network", runtime.selects)
	}

	engine.terrain.observe(rcxTerrainWhitelist, runtime.Now())
	engine.reconsider()

	if got := runtime.selected; got != "domestic" {
		t.Errorf("selected = %q, want the domestic node so home services still work", got)
	}
}

func TestEngineForgetsProvisionalFailuresWhenTheNetworkRecovers(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("node")
	engine := newTestEngine(runtime, "ru")
	engine.envKey = "c:25001"
	engine.terrain.observe(rcxTerrainWhitelist, runtime.Now())

	rcxChargeFailures(engine.ledger, "node", "c:25001", rcxTerrainWhitelist, runtime.Now(), 4)
	if engine.ledger.CoolUntil("node", "c:25001", engine.runtime.Now()).IsZero() {
		t.Fatal("failures during a shutdown still cool the node while it lasts")
	}

	engine.reachF = rcxProbeOK
	engine.validated = true
	engine.classifyTerrain(true)

	if !engine.ledger.CoolUntil("node", "c:25001", engine.runtime.Now()).IsZero() {
		t.Error("one commute must not leave the whole park cooling on a healthy network")
	}
}

// NoteTracker runs on mihomo's per-connection notify goroutines while
// candidates() rebuilds memberSet on the loop goroutine: the -race run of
// this test failed before memberSet grew a lock.
func TestNoteTrackerAndCandidatesShareNoUnlockedMap(t *testing.T) {
	runtime := newFakeRuntime()
	engine := newTestEngine(runtime, "ru")

	members := []rcxMember{
		{Name: "node-a"}, {Name: "node-b"}, {Name: "node-c"},
	}
	tracker := newFakeTracker("conn-1", "node-a", "example.org")

	var wg sync.WaitGroup
	wg.Add(2)
	go func() {
		defer wg.Done()
		for i := 0; i < 2000; i++ {
			engine.candidates(members)
		}
	}()
	go func() {
		defer wg.Done()
		for i := 0; i < 2000; i++ {
			engine.NoteTracker(tracker)
		}
	}()
	wg.Wait()
}

// NoteTracker stamps openSeen on mihomo's notify goroutines while the loop
// consumes it in sampleTraffic: the unguarded write took the service down.
func TestNoteTrackerAndSampleTrafficShareNoUnlockedMap(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("node-a")
	engine := newTestEngine(runtime, "ru")
	tracker := newFakeTracker("conn-1", "node-a", "www.youtube.com")
	runtime.openConn("conn-1", "node-a", "www.youtube.com")

	var wg sync.WaitGroup
	wg.Add(2)
	go func() {
		defer wg.Done()
		for i := 0; i < 2000; i++ {
			engine.NoteTracker(tracker)
		}
	}()
	go func() {
		defer wg.Done()
		for i := 0; i < 2000; i++ {
			runtime.bumpConn("conn-1", 0, 1000)
			engine.sampleTraffic()
		}
	}()
	wg.Wait()
}

// The notify hook keeps the info pointer as its witness, so the same connection
// has to answer with the same struct every time it is read.
type fakeTracker struct {
	id   string
	info *statistic.TrackerInfo
}

func newFakeTracker(id, node, host string) *fakeTracker {
	return &fakeTracker{
		id: id,
		info: &statistic.TrackerInfo{
			Metadata: &C.Metadata{Host: host},
			Chain:    C.Chain{node},
		},
	}
}

func (f *fakeTracker) ID() string                    { return f.id }
func (f *fakeTracker) Close() error                  { return nil }
func (f *fakeTracker) Chains() C.Chain               { return nil }
func (f *fakeTracker) ProviderChains() C.Chain       { return nil }
func (f *fakeTracker) AppendToChains(C.ProxyAdapter) {}
func (f *fakeTracker) RemoteDestination() string     { return "" }
func (f *fakeTracker) Info() *statistic.TrackerInfo  { return f.info }

func TestEngineKeepsAFrontedNodeWhenItsProofExpires(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("fronted", "other")
	runtime.countries = map[string]string{"fronted": "RU", "other": "NL"}
	engine := newTestEngine(runtime, "ru")
	engine.incumbent = "fronted"
	runtime.selected = "fronted"
	engine.since = runtime.Now().Add(-time.Hour)

	engine.ledger.NoteProbe("fronted", "w:Home", rcxRoleOpen, rcxProbeOK, 90, runtime.Now())
	runtime.advance(engine.ledger.ProofTTL() + time.Minute)
	engine.reconsider()

	if len(runtime.selects) != 0 {
		t.Errorf("selects = %v, want none: an expired proof is no reason to trust mmdb again", runtime.selects)
	}
	if got := runtime.lastStatus().Reason; got != string(rcxReasonHold) {
		t.Errorf("reason = %q, want hold: the node stays a working foreign node", got)
	}
}

func TestEngineRenewsTheIncumbentProofBeforeItExpires(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("a", "b", "c", "d")
	engine := newTestEngine(runtime, "ru")
	engine.incumbent = "b"
	members := runtime.members

	for _, name := range []string{"d", "c", "b", "a"} {
		engine.ledger.NoteProbe(name, engine.envKey, rcxRoleOpen, rcxProbeOK, 90, runtime.Now())
		runtime.advance(time.Second)
	}
	if wave := engine.planWave(engine.candidates(members), members, rcxWaveMaintain); len(wave) != 0 {
		t.Fatalf("wave = %v, want none: every proof in the park is fresh", wave)
	}

	runtime.advance(engine.ledger.ProofTTL() / 2)
	wave := engine.planWave(engine.candidates(members), members, rcxWaveMaintain)

	if len(wave) != rcxMaintainWidth {
		t.Fatalf("wave = %d nodes, want the trickle width", len(wave))
	}
	if wave[0].Name != "b" {
		t.Errorf("wave = %v, want the incumbent first: its expiry is the one that costs a switch", wave)
	}
	if wave[1].Name != "d" {
		t.Errorf("wave = %v, want the park walked in staleness order behind it", wave)
	}
}

func TestEngineKeepsTheTrickleInsideAReserveForReactiveWaves(t *testing.T) {
	runtime := newFakeRuntime()
	names := make([]string, 0, 30)
	for i := 0; i < 30; i++ {
		names = append(names, "n"+string(rune('a'+i)))
	}
	runtime.members = foreignMembers(names...)
	engine := newTestEngine(runtime, "ru")
	members := runtime.members

	engine.budget.Take(rcxProbeBudgetCap-rcxProbeReserve-1, runtime.Now())
	if wave := engine.planWave(engine.candidates(members), members, rcxWaveMaintain); len(wave) != 0 {
		t.Fatalf("wave = %d nodes, want discovery's protected budget preserved", len(wave))
	}

	if wave := engine.planWave(engine.candidates(members), members, rcxWaveMaintain); len(wave) != 0 {
		t.Errorf("wave = %d nodes, want none: the reserve belongs to the waves that answer an event", len(wave))
	}
	if wave := engine.planWave(engine.candidates(members), members, rcxWaveRescue); len(wave) != rcxWaveWidth {
		t.Errorf("rescue wave = %d nodes, want a bounded reactive batch", len(wave))
	}
}

func TestEngineSchedulesNothingOnALinkTheCanariesCallDead(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("a", "b", "c")
	engine := newTestEngine(runtime, "ru")
	engine.terrain.observe(rcxTerrainOffline, runtime.Now())
	members := runtime.members
	candidates := engine.candidates(members)

	for _, kind := range []rcxWaveKind{rcxWaveRoutine, rcxWaveMaintain, rcxWaveGrant, rcxWaveRescue} {
		if wave := engine.planWave(candidates, members, kind); len(wave) != 0 {
			t.Errorf("wave %d = %d nodes, want none while both canary groups measure the link dead", kind, len(wave))
		}
	}
	if wave := engine.planWave(candidates, members, rcxWaveDeep); len(wave) != len(members) {
		t.Errorf("deep scan = %d nodes, want the whole park: the user asked for it", len(wave))
	}
}

func TestEngineBuysTheMaintenanceProbeOnAnIdleTick(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("a", "b")
	engine := newTestEngine(runtime, "ru")
	engine.incumbent = "a"
	runtime.selected = "a"
	engine.since = runtime.Now().Add(-time.Hour)
	engine.pendingGrant = false
	engine.ledger.NoteTrafficProgress("a", "w:Home", false, runtime.Now())

	engine.reconsider()
	if engine.probing {
		t.Fatalf("reconsider bought a probe: a trickle is a rate and belongs on the tick")
	}

	engine.maintain()

	if !engine.probing {
		t.Error("nothing measured the park: bytes moving prove transit, not that the proof still holds")
	}
}

func TestMaintenanceLeavesTheUnprovenTailCold(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("inc", "tail1", "tail2", "tail3")
	engine := newTestEngine(runtime, "ru")
	engine.incumbent = "inc"
	engine.ledger.NoteProbe("inc", engine.envKey, rcxRoleOpen, rcxProbeOK, 40, runtime.Now())

	runtime.advance(engine.ledger.ProofTTL()/2 + time.Minute)
	members := runtime.members
	wave := engine.planWave(engine.candidates(members), members, rcxWaveMaintain)

	if len(wave) != 1 || wave[0].Name != "inc" {
		t.Fatalf("wave = %v, want only the warm incumbent: the unproven tail is discovery's job, not the tick", wave)
	}
}

func TestWarmPoolDropsAFarProvenNodeBelowTheFastHandful(t *testing.T) {
	runtime := newFakeRuntime()
	names := make([]string, 0, rcxWarmPoolCap+1)
	for i := 0; i < rcxWarmPoolCap; i++ {
		names = append(names, "fast"+string(rune('a'+i)))
	}
	names = append(names, "far")
	runtime.members = foreignMembers(names...)
	for i := range runtime.members {
		runtime.members[i].HostAt = runtime.Now()
		if runtime.members[i].Name == "far" {
			runtime.members[i].HostMs = 900
		} else {
			runtime.members[i].HostMs = 40
		}
	}
	engine := newTestEngine(runtime, "ru")
	now := runtime.Now()
	for _, m := range runtime.members {
		engine.ledger.NoteProbe(m.Name, engine.envKey, rcxRoleOpen, rcxProbeOK, m.HostMs, now)
	}

	warm := engine.warmPool(engine.candidates(runtime.members), now)
	if _, ok := warm["far"]; ok {
		t.Fatalf("far proven node is warm; the tick would keep re-proving a 900ms node the fast pool makes redundant")
	}
	if _, ok := warm["fasta"]; !ok {
		t.Fatal("a fast proven node fell out of the warm pool")
	}
}

func renamedMember(name, id string) rcxMember {
	return rcxMember{Name: name, ID: id, Type: "Vless", Port: 443, SupportsUDP: true}
}

func TestEngineKeepsAProvenNodeThroughASubscriptionRename(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = []rcxMember{renamedMember("NL-1 | 42ms", "endpoint-nl-1")}
	engine := newTestEngine(runtime, "ru")

	engine.reconsider()
	engine.notePayload("NL-1 | 42ms", true, runtime.Now())

	runtime.members = []rcxMember{renamedMember("NL-1 | 190ms", "endpoint-nl-1")}
	facts := engine.candidates(runtime.Members())[0].Facts

	if facts.OpenWorld != rcxProofProven {
		t.Errorf("proof = %v after a rename, want proven: the endpoint did not move", facts.OpenWorld)
	}
	if !facts.OpenedOnce {
		t.Error("a refresh that rewrites every name emptied the ledger")
	}
	if got := engine.snapshot.Picks["w:Home"]; got != "endpoint-nl-1" {
		t.Errorf("pick = %q, want the endpoint: the name it was stored under is gone", got)
	}
}

func TestEngineRestoresAPickTheSubscriptionRenamed(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = []rcxMember{
		renamedMember("A", "endpoint-a"),
		renamedMember("NL-1 | 190ms", "endpoint-nl-1"),
	}
	engine := newTestEngine(runtime, "ru")
	engine.snapshot.Picks["w:Home"] = "endpoint-nl-1"
	engine.envKey = ""

	engine.handle(rcxEvent{Kind: rcxEventNetwork, Payload: rcxNetworkPayload{
		Transport: "wifi",
		SSID:      "Home",
		Validated: true,
	}})

	if got := engine.incumbent; got != "NL-1 | 190ms" {
		t.Errorf("incumbent = %q, want the renamed node the pick points at", got)
	}
}

func pinnedPark(t *testing.T) (*fakeRuntime, *rcxEngine) {
	t.Helper()
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("chosen", "spare")
	engine := newTestEngine(runtime, "ru")
	engine.ledger.NoteProbe("chosen", "w:Home", rcxRoleOpen, rcxProbeOK, 120, runtime.Now())
	engine.ledger.NoteProbe("spare", "w:Home", rcxRoleOpen, rcxProbeOK, 60, runtime.Now())
	engine.handle(rcxEvent{Kind: rcxEventManualPick, Node: "chosen"})

	rcxChargeFailures(engine.ledger, "chosen", "w:Home", rcxTerrainNormal, runtime.Now(), 3)
	engine.reconsider()
	if got := engine.incumbent; got != "spare" {
		t.Fatalf("incumbent = %q, want the engine to leave a node it cannot dial", got)
	}
	return runtime, engine
}

func TestEngineReturnsToThePinOnceItsNodeRecovers(t *testing.T) {
	runtime, engine := pinnedPark(t)

	runtime.advance(20 * time.Minute)
	engine.reconsider()

	if got := engine.incumbent; got != "spare" {
		t.Fatalf("incumbent = %q, want the engine to stay off the pin until something proves it", got)
	}
	if got := runtime.lastStatus().Reason; got != string(rcxReasonMeasuring) {
		t.Fatalf("reason = %q, want the pin's return held for a measurement", got)
	}

	engine.handle(rcxEvent{Kind: rcxEventProbeResults, Results: []rcxProbeResult{{
		Node: "chosen", Role: rcxRoleOpen, Outcome: rcxProbeOK, DelayMs: 120,
	}}})

	if got := engine.incumbent; got != "chosen" {
		t.Errorf("incumbent = %q, want the pin back: the user asked for it and it works again", got)
	}
	if got := runtime.lastStatus().Reason; got != string(rcxReasonPinReturn) {
		t.Errorf("reason = %q, want pin-return", got)
	}
}

func TestEngineBuysTheWaveThatSettlesAPinsReturn(t *testing.T) {
	runtime, engine := pinnedPark(t)
	engine.handle(rcxEvent{Kind: rcxEventProbeResults})
	if engine.probing {
		t.Fatal("want no wave in flight, or the gate cannot be the one that buys it")
	}

	runtime.advance(20 * time.Minute)
	engine.reconsider()

	if !engine.probing {
		t.Fatal("the pin's return waits on a measurement nobody else is going to buy")
	}
	if got := engine.incumbent; got != "spare" {
		t.Errorf("incumbent = %q, want the working node kept while the pin is measured", got)
	}
}

func TestEngineBuysOnePinWaveUntilTheFloorLapses(t *testing.T) {
	runtime, engine := pinnedPark(t)
	engine.handle(rcxEvent{Kind: rcxEventProbeResults})
	runtime.advance(20 * time.Minute)
	engine.reconsider()
	if !engine.probing {
		t.Fatal("want the first wave the pin's return waits on")
	}

	engine.handle(rcxEvent{Kind: rcxEventProbeResults})

	if engine.probing {
		t.Error("a pin nothing measured must not buy a wave per wave: the budget is the whole park's")
	}
	runtime.advance(rcxPinWaveRetry)
	engine.reconsider()

	if !engine.probing {
		t.Error("once the floor lapses the pin is owed another measurement")
	}
}

func TestEngineHoldsAPinsReturnWhenItCannotAffordTheProbe(t *testing.T) {
	runtime, engine := pinnedPark(t)
	engine.handle(rcxEvent{Kind: rcxEventProbeResults})

	runtime.advance(20 * time.Minute)
	engine.budget.Take(rcxProbeBudgetCap, runtime.Now())
	engine.reconsider()

	if got := engine.incumbent; got != "spare" {
		t.Errorf("incumbent = %q, want no blind return bought by a drained budget", got)
	}
	if got := runtime.lastStatus().Reason; got != string(rcxReasonHold) {
		t.Errorf("reason = %q, want hold: nothing is being measured", got)
	}
}

func TestEngineLeadsTheWaveWithThePinItOwesAProbe(t *testing.T) {
	runtime := newFakeRuntime()
	park := []string{"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m"}
	runtime.members = foreignMembers(append(park, "chosen")...)
	engine := newTestEngine(runtime, "ru")
	for _, node := range park {
		engine.ledger.NoteProbe(node, "w:Home", rcxRoleOpen, rcxProbeFail, 0, runtime.Now())
	}
	runtime.advance(time.Minute)
	engine.ledger.NoteProbe("chosen", "w:Home", rcxRoleOpen, rcxProbeFail, 0, runtime.Now())
	engine.incumbent = "a"
	engine.snapshot.Pins[engine.envKey] = "chosen"

	members := runtime.members
	wave := engine.planWave(engine.candidates(members), members, rcxWaveRoutine)

	if len(wave) == 0 || wave[0].Name != "chosen" {
		t.Errorf("wave = %v, want the pin measured first: its return is what the wave is for", wave)
	}
}

func TestEngineRestoresThePinAcrossARestart(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = []rcxMember{
		renamedMember("SLOW | 900ms", "endpoint-slow"),
		renamedMember("FAST | 40ms", "endpoint-fast"),
	}
	first := newTestEngine(runtime, "ru")
	first.ledger.NoteProbe("endpoint-slow", "w:Home", rcxRoleOpen, rcxProbeOK, 900, runtime.Now())
	first.ledger.NoteProbe("endpoint-fast", "w:Home", rcxRoleOpen, rcxProbeOK, 40, runtime.Now())
	first.handle(rcxEvent{Kind: rcxEventManualPick, Node: "SLOW | 900ms"})

	if got := first.snapshot.Pins["w:Home"]; got != "endpoint-slow" {
		t.Fatalf("stored pin = %q, want the endpoint so a rename cannot lose it", got)
	}
	if got := first.snapshot.Picks["w:Home"]; got != "endpoint-slow" {
		t.Errorf("stored pick = %q, want the endpoint here too", got)
	}

	second := newTestEngine(runtime, "ru")
	second.snapshot = first.snapshot
	second.ledger.Import(first.ledger.Export())
	second.envKey = ""
	second.handle(rcxEvent{Kind: rcxEventNetwork, Payload: rcxNetworkPayload{
		Transport: "wifi",
		SSID:      "Home",
		Validated: true,
	}})

	if got := second.incumbent; got != "SLOW | 900ms" {
		t.Errorf("incumbent = %q, want the pin, not the fastest node: a restart is not a release", got)
	}
	if got := runtime.lastStatus().Reason; got != string(rcxReasonManualHold) {
		t.Errorf("reason = %q, want the restored pin to hold against a latency gain", got)
	}
}

func TestEngineComingBackToANetworkPrefersThePinOverTheLastAutoChoice(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("chosen", "spare")
	engine := newTestEngine(runtime, "ru")
	engine.ledger.NoteProbe("chosen", "w:Home", rcxRoleOpen, rcxProbeOK, 900, runtime.Now())
	engine.ledger.NoteProbe("spare", "w:Home", rcxRoleOpen, rcxProbeOK, 40, runtime.Now())
	engine.handle(rcxEvent{Kind: rcxEventManualPick, Node: "chosen"})

	rcxChargeFailures(engine.ledger, "chosen", "w:Home", rcxTerrainNormal, runtime.Now(), 3)
	engine.reconsider()
	if got := engine.snapshot.Picks["w:Home"]; got != "spare" {
		t.Fatalf("last auto choice = %q, want the successor recorded", got)
	}

	away := rcxNetworkPayload{Transport: "wifi", SSID: "Cafe", Validated: true}
	engine.handle(rcxEvent{Kind: rcxEventNetwork, Payload: away})
	runtime.advance(20 * time.Minute)
	home := rcxNetworkPayload{Transport: "wifi", SSID: "Home", Validated: true}
	engine.handle(rcxEvent{Kind: rcxEventNetwork, Payload: home})

	if got := engine.incumbent; got != "chosen" {
		t.Errorf("incumbent = %q, want the pin this network was given", got)
	}
	if got := runtime.lastStatus().Reason; got != string(rcxReasonManualHold) {
		t.Errorf("reason = %q, want the pin restored outright, not re-reached through a switch", got)
	}
}

func TestEnginePreservesProviderOrderAcrossInstalls(t *testing.T) {
	park := foreignMembers("a", "b", "c", "d", "e", "f", "g", "h")
	pick := func(seed uint64) string {
		runtime := newFakeRuntime()
		runtime.members = park
		engine := newTestEngine(runtime, "ru")
		engine.snapshot.Seed = seed
		engine.reconsider()
		return engine.incumbent
	}

	first, second := pick(1), pick(2)
	if first == "" || second == "" {
		t.Fatalf("cold start chose nothing: %q, %q", first, second)
	}
	if first != "a" || second != "a" {
		t.Errorf("cold starts = %q, %q, want the provider's first member", first, second)
	}
	if again := pick(1); again != first {
		t.Errorf("same seed chose %q then %q: the order must be stable across restarts", first, again)
	}
}

func TestOrderPermutationIgnoresTheDisplayName(t *testing.T) {
	const key = "endpoint-nl-1"
	if renamed := rcxOrderOf(7, key); renamed != rcxOrderOf(7, key) {
		t.Error("the permutation is not a function of the key alone")
	}
	if rcxOrderOf(7, key) == rcxOrderOf(8, key) {
		t.Error("two installs landed on one order for the same node")
	}
	if rcxOrderOf(7, key) == rcxOrderOf(7, "endpoint-nl-2") {
		t.Error("two endpoints share an order under one seed")
	}
}

func TestEngineKeepsControlIntentsThroughAHarvestFlood(t *testing.T) {
	engine := newTestEngine(newFakeRuntime(), "ru")
	for len(engine.events) < cap(engine.events) {
		engine.send(rcxEvent{Kind: rcxEventHarvested, Node: "node", DelayMs: 40})
	}
	payload := rcxNetworkPayload{Transport: "wifi", SSID: "Cafe", Validated: true}

	engine.Network(payload)
	engine.drainControl()
	want, _ := rcxEnvKeys(payload)

	if got := engine.envKey; got != want {
		t.Errorf("envKey = %q, want %q after the handoff", got, want)
	}
}

func TestEngineActsOnTheNewestControlIntentOnly(t *testing.T) {
	engine := newTestEngine(newFakeRuntime(), "ru")
	cafe := rcxNetworkPayload{Transport: "wifi", SSID: "Cafe", Validated: true}
	office := rcxNetworkPayload{Transport: "wifi", SSID: "Office", Validated: true}

	engine.Network(cafe)
	engine.Network(office)
	engine.drainControl()
	want, _ := rcxEnvKeys(office)

	if got := engine.envKey; got != want {
		t.Errorf("envKey = %q, want %q for the newest handoff", got, want)
	}
}

func TestEngineLetsAWholeConfigSupersedeAPendingToggle(t *testing.T) {
	engine := newTestEngine(newFakeRuntime(), "ru")
	engine.SetEnabled(false)
	config := engine.cfg
	config.Enabled = true
	engine.Configure(config)
	engine.drainControl()

	if !engine.cfg.Enabled {
		t.Error("the toggle outlived the config that replaced it")
	}
}

func TestEngineLetsAToggleOutliveAnEarlierConfig(t *testing.T) {
	engine := newTestEngine(newFakeRuntime(), "ru")
	config := engine.cfg
	config.Enabled = true
	engine.Configure(config)
	engine.SetEnabled(false)
	engine.drainControl()

	if engine.cfg.Enabled {
		t.Error("the config outlived the toggle the user pressed after it")
	}
}

// The tap is the newest intent, so it has to be stored against the link the
// device is actually on: applied first, the environment it arrived under would
// load its own remembered pick over it and revert the user's choice.
func TestEngineStoresAPickUnderTheNetworkItArrivedWith(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("chosen", "spare")
	engine := newTestEngine(runtime, "ru")
	engine.reconsider()

	payload := rcxNetworkPayload{Transport: "wifi", SSID: "Cafe", Validated: true}
	engine.OnManualAsserted("chosen")
	engine.Network(payload)
	engine.drainControl()
	key, _ := rcxEnvKeys(payload)

	if got := engine.snapshot.Picks[key]; got == "" {
		t.Error("the pick landed under the network the device had already left")
	}
	if got := engine.incumbent; got != "chosen" {
		t.Errorf("incumbent = %q, want the tap to survive the handoff it raced", got)
	}
}

// The slots are useless if nothing wakes the loop for them: the ticker is thirty
// seconds away, and a handoff cannot wait that long to be noticed.
func TestEngineLoopWakesForAControlIntent(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("node")
	engine := newTestEngine(runtime, "ru")
	engine.quit = make(chan struct{})
	engine.done = make(chan struct{})
	go engine.loop()
	defer func() {
		close(engine.quit)
		<-engine.done
	}()

	payload := rcxNetworkPayload{Transport: "wifi", SSID: "Cafe", Validated: true}
	engine.Network(payload)
	want, _ := rcxEnvKeys(payload)

	deadline := time.Now().Add(2 * time.Second)
	for runtime.lastStatus().Env != want {
		if time.Now().After(deadline) {
			t.Fatalf("env = %q, want %q without waiting for a tick",
				runtime.lastStatus().Env, want)
		}
		time.Sleep(time.Millisecond)
	}
}

// A slot left full replays its intent on every wake: a scan that relaunches
// forever, or a link handoff re-applied long after the device changed networks.
func TestEngineForgetsAControlIntentOnceItIsTaken(t *testing.T) {
	engine := newTestEngine(newFakeRuntime(), "ru")
	engine.Configure(engine.cfg)
	engine.SetEnabled(true)
	engine.Network(rcxNetworkPayload{Transport: "wifi", SSID: "Cafe", Validated: true})
	engine.OnSuspend(true)
	engine.OnSuspend(false)
	engine.OnManualAsserted("node")
	engine.DeepScan()

	if got := len(engine.control.take()); got != 7 {
		t.Fatalf("take = %d intents, want every slot to report itself once", got)
	}
	if got := len(engine.control.take()); got != 0 {
		t.Errorf("take = %d intents on an empty control, want none to replay", got)
	}
}

// Both edges do work the other cannot: the first opens the window that discards
// what a frozen device measured, the second is what re-measures the link.
func TestEngineKeepsBothEdgesOfASuspension(t *testing.T) {
	runtime := newFakeRuntime()
	engine := newTestEngine(runtime, "ru")
	engine.quit = make(chan struct{})

	engine.OnSuspend(true)
	engine.OnSuspend(false)
	engine.drainControl()

	if engine.suspendAt.IsZero() {
		t.Error("the window never opened: samples a frozen radio wrote would still count")
	}
	if !engine.reaching {
		t.Error("the link was never re-measured: the terrain is whatever the device fell asleep on")
	}
}

// A round is one deadline for the whole group, so dialling in order let a dropped
// first address use it up and the second canary never left the device.
func TestCanaryGroupOutlivesABlackHoledAddress(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.hang = map[string]bool{"1.1.1.1:443": true}
	runtime.reach = map[string]rcxProbeOutcome{"9.9.9.9:443": rcxProbeOK}
	engine := newTestEngine(runtime, "ru")
	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer cancel()

	var rows []rcxCanaryReport
	got := engine.reachAny(ctx, []string{"1.1.1.1:443", "9.9.9.9:443"}, false, time.Second, &rows)

	if got != rcxProbeOK {
		t.Errorf("outcome = %s, want ok: a black hole must not spend the whole round",
			rcxOutcomeName(got))
	}
}

func TestCanaryGroupReportsMeasuredAddressesInOrder(t *testing.T) {
	engine := newTestEngine(newFakeRuntime(), "ru")

	var rows []rcxCanaryReport
	engine.reachAny(context.Background(), []string{"1.1.1.1:443", "9.9.9.9:443"}, false, time.Second, &rows)

	if len(rows) != 2 {
		t.Fatalf("rows = %d, want one per measured address", len(rows))
	}
	if rows[0].Addr != "1.1.1.1:443" || rows[1].Addr != "9.9.9.9:443" {
		t.Errorf("rows = %q,%q, want the configured order", rows[0].Addr, rows[1].Addr)
	}
}

// The app cannot redial through the new node while its socket still points at the
// buried one: a hung stream is exactly what the user reads as instability.
func TestEngineHangsUpOnTheNodeItBuried(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("dead", "alive")
	engine := newTestEngine(runtime, "ru")
	engine.incumbent = "dead"
	engine.since = runtime.Now().Add(-time.Hour)
	engine.ledger.NoteProbe("alive", "w:Home", rcxRoleOpen, rcxProbeOK, 90, runtime.Now())
	rcxChargeFailures(engine.ledger, "dead", "w:Home", rcxTerrainNormal, runtime.Now(), 3)

	engine.reconsider()

	if got := runtime.hungUpOn(); len(got) != 0 {
		t.Errorf("closed = %v, want no connection closed without tracker evidence", got)
	}
}

func TestEngineKeepsLiveConnectionsThroughAComfortSwitch(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("slow", "fast")
	engine := newTestEngine(runtime, "ru")
	engine.incumbent = "slow"
	engine.since = runtime.Now().Add(-time.Hour)
	engine.ledger.NoteProbe("slow", "w:Home", rcxRoleOpen, rcxProbeOK, 1800, runtime.Now())
	engine.ledger.NoteProbe("fast", "w:Home", rcxRoleOpen, rcxProbeOK, 40, runtime.Now())
	engine.envSince = runtime.Now().Add(-time.Hour)
	marker := rcxMarkerID(rcxRoleOpen, engine.cfg.OpenMarkers[0])
	engine.ledger.NoteQualitySample("slow", "w:Home", marker, engine.qualityEpoch(), 1800, runtime.Now())
	engine.ledger.NoteQualitySample("fast", "w:Home", marker, engine.qualityEpoch(), 40, runtime.Now())

	engine.reconsider()
	if got := runtime.lastStatus().Reason; got != string(rcxReasonQualityConfirming) {
		t.Fatalf("reason = %q, want quality-confirming", got)
	}
	engine.quality = rcxQualityCheck{From: engine.key("slow"), To: engine.key("fast"), Env: engine.envKey, Epoch: engine.envSince.UnixNano(), Config: engine.configGen, Rounds: 2, Last: runtime.Now()}
	engine.reconsider()

	if got := runtime.lastStatus().Reason; got != string(rcxReasonLatencyGain) {
		t.Fatalf("reason = %q, want latency-gain", got)
	}
	if got := runtime.hungUpOn(); len(got) != 0 {
		t.Errorf("closed = %v, want a comfort switch to leave live connections alone", got)
	}
}

// The main loop must queue the confirming duel, or a slow incumbent latches forever against a faster proven rival.
func TestReconsiderQueuesTheQualityDuelForAFasterRival(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("slow", "fast")
	engine := newTestEngine(runtime, "ru")
	engine.incumbent = "slow"
	engine.since = runtime.Now().Add(-time.Hour)
	engine.envSince = runtime.Now().Add(-time.Hour)
	engine.ledger.NoteProbe("slow", "w:Home", rcxRoleOpen, rcxProbeOK, 1800, runtime.Now())
	engine.ledger.NoteProbe("fast", "w:Home", rcxRoleOpen, rcxProbeOK, 40, runtime.Now())
	marker := rcxMarkerID(rcxRoleOpen, engine.cfg.OpenMarkers[0])
	engine.ledger.NoteQualitySample("slow", "w:Home", marker, engine.qualityEpoch(), 1800, runtime.Now())
	engine.ledger.NoteQualitySample("fast", "w:Home", marker, engine.qualityEpoch(), 40, runtime.Now())

	engine.reconsider()

	if got := runtime.lastStatus().Reason; got != string(rcxReasonQualityConfirming) {
		t.Fatalf("reason = %q, want quality-confirming", got)
	}
	if engine.quality.To != engine.key("fast") || engine.quality.From != engine.key("slow") {
		t.Fatalf("duel = %q->%q, want the faster rival queued so the upgrade can confirm", engine.quality.From, engine.quality.To)
	}
}

// A panicking dial took the process with it, and never freed its seat.
func TestCanaryRoundOutlivesAPanickingDial(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.panics = map[string]bool{"1.1.1.1:443": true}
	engine := newTestEngine(runtime, "ru")

	var rows []rcxCanaryReport
	got := engine.reachAny(context.Background(), []string{"1.1.1.1:443"}, false, time.Second, &rows)

	if got != rcxProbeOverloaded {
		t.Errorf("outcome = %s, want overloaded: a panicked dial measured nothing",
			rcxOutcomeName(got))
	}
	if len(rows) != 1 || rows[0].Addr != "1.1.1.1:443" {
		t.Errorf("rows = %v, want the address the round spent", rows)
	}
}

func TestEngineRefundsWhatADarkLinkChargedTheIncumbentAlone(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("carrying", "spare")
	engine := newTestEngine(runtime, "ru")
	engine.quit = make(chan struct{})
	engine.incumbent = "carrying"

	failDial(engine, runtime, "carrying")
	runtime.advance(rcxLinkDark)
	linkAnswers(engine, runtime)

	if got := engine.ledger.FailStreak("carrying", "w:Home"); got != 0 {
		t.Errorf("streak = %d, want it back: a dead uplink shows up on the one node carrying traffic", got)
	}
}

func TestEngineKeepsWhatADarkLinkChargedBesideTheIncumbent(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("carrying", "reached-for")
	engine := newTestEngine(runtime, "ru")
	engine.incumbent = "carrying"

	failDial(engine, runtime, "reached-for")
	runtime.advance(rcxLinkDark)
	linkAnswers(engine, runtime)

	if got := engine.ledger.FailStreak("reached-for", "w:Home"); got != 1 {
		t.Errorf("streak = %d, want the verdict kept: silence on a node nothing was routed through is the node", got)
	}
}

func TestEngineReportsOnlyTheTerrainItStillTrusts(t *testing.T) {
	runtime := newFakeRuntime()
	engine := newTestEngine(runtime, "ru")
	engine.lastReachAt = runtime.Now()
	engine.terrain.observe(rcxTerrainWhitelist, runtime.Now())

	engine.reconsider()
	if got := runtime.lastStatus().Terrain; got != rcxTerrainWhitelist.String() {
		t.Fatalf("terrain = %q, want what the canaries just measured", got)
	}

	runtime.advance(rcxTerrainMaxAge + time.Minute)
	engine.reconsider()

	if got := runtime.lastStatus().Terrain; got != rcxTerrainUnknown.String() {
		t.Errorf("terrain = %q, want unknown: the row must not claim a reading the ranking already discarded", got)
	}
}

func TestEngineDoesNotLearnFailuresFromAStaleTerrain(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("node")
	engine := newTestEngine(runtime, "ru")
	engine.lastReachAt = runtime.Now()

	failDial(engine, runtime, "node")
	if got := engine.ledger.FailStreak("node", "w:Home"); got != 1 {
		t.Fatalf("streak = %d, want one failure under a measured normal terrain", got)
	}

	runtime.advance(rcxTerrainMaxAge + time.Minute)
	failDial(engine, runtime, "node")

	if got := engine.ledger.FailStreak("node", "w:Home"); got != 1 {
		t.Errorf("streak = %d, want stale unknown terrain to add no failure", got)
	}
}

func TestEngineDoesNotLearnDialFailuresWithoutATrustedTerrain(t *testing.T) {
	for _, terrain := range []rcxTerrain{rcxTerrainUnknown, rcxTerrainPortal, rcxTerrainOffline} {
		t.Run(terrain.String(), func(t *testing.T) {
			runtime := newFakeRuntime()
			runtime.members = providerMembers("one", "node")
			engine := newTestEngine(runtime, "ru")
			engine.terrain.observe(terrain, runtime.Now())

			failDial(engine, runtime, "node")

			if got := engine.ledger.FailStreak("node", engine.envKey); got != 0 {
				t.Errorf("streak = %d, want no negative learning", got)
			}
			if len(engine.providerFails) != 0 || len(engine.charged) != 0 {
				t.Errorf("provider failures = %v, escrow = %v", engine.providerFails, engine.charged)
			}
		})
	}
}

func TestEngineDoesNotLearnProbeFailuresWithoutATrustedTerrain(t *testing.T) {
	for _, terrain := range []rcxTerrain{rcxTerrainUnknown, rcxTerrainPortal} {
		t.Run(terrain.String(), func(t *testing.T) {
			runtime := newFakeRuntime()
			runtime.members = providerMembers("one", "node")
			engine := newTestEngine(runtime, "ru")
			engine.terrain.observe(terrain, runtime.Now())
			engine.probing = true
			engine.probeScreenOff = true
			engine.probeScreenEpisode = engine.screenEpisode
			engine.probeIncumbent = "node"
			engine.applyProbeResult(rcxEvent{Gen: engine.probeGen, Results: []rcxProbeResult{{
				Node: "node", Role: rcxRoleOpen, Outcome: rcxProbeStatusMismatch,
			}}})
			engine.finishProbe()

			facts := engine.ledger.Facts("node", engine.envKey, true, runtime.Now(), rcxLedgerProofTTL)
			if facts.OpenWorld != rcxProofUnknown {
				t.Errorf("open proof = %v, want unknown", facts.OpenWorld)
			}
			if len(engine.providerFails) != 0 || len(engine.charged) != 0 || engine.screenDead != "" {
				t.Errorf("provider failures = %v, escrow = %v, screen dead = %q", engine.providerFails, engine.charged, engine.screenDead)
			}
		})
	}
}

func TestEngineDoesNotLearnMarkerFailuresWithoutATrustedTerrain(t *testing.T) {
	for _, terrain := range []rcxTerrain{rcxTerrainUnknown, rcxTerrainPortal} {
		t.Run(terrain.String(), func(t *testing.T) {
			runtime := newFakeRuntime()
			runtime.members = providerMembers("one", "node")
			engine := newTestEngine(runtime, "ru")
			markerID := rcxMarkerID(rcxRoleOpen, engine.cfg.OpenMarkers[0])
			engine.ledger.NoteProbe("node", engine.envKey, rcxRoleOpen, rcxProbeOK, 40, runtime.Now())
			engine.terrain.observe(terrain, runtime.Now())
			engine.probing = true
			engine.applyProbeResult(rcxEvent{Gen: engine.probeGen, Results: []rcxProbeResult{{
				Node: "node", Role: rcxRoleOpen, Outcome: rcxProbeStatusMismatch,
				Attempts: []rcxMarkerAttempt{{ID: markerID, Outcome: rcxProbeStatusMismatch}},
			}}})
			engine.finishProbe()

			state := engine.ledger.envState(engine.envKey, "node")
			if _, exists := state.Markers[markerID]; exists {
				t.Error("an untrusted marker failure was persisted")
			}
			if state.OpenWorld != rcxProofProven {
				t.Errorf("open proof = %v, want prior positive proof preserved", state.OpenWorld)
			}
			if len(engine.snapshot.Quarantines) != 0 || len(engine.providerFails) != 0 {
				t.Errorf("quarantines = %v, provider failures = %v", engine.snapshot.Quarantines, engine.providerFails)
			}
		})
	}
}

func TestEngineDoesNotLearnHarvestedOrFrozenFailuresWithoutATrustedTerrain(t *testing.T) {
	for _, terrain := range []rcxTerrain{rcxTerrainUnknown, rcxTerrainPortal} {
		t.Run(terrain.String(), func(t *testing.T) {
			runtime := newFakeRuntime()
			runtime.members = providerMembers("one", "node")
			engine := newTestEngine(runtime, "ru")
			engine.syncIdentity(runtime.members)
			engine.terrain.observe(terrain, runtime.Now())

			engine.handle(rcxEvent{Kind: rcxEventHarvested, Node: "node", DelayMs: 0})
			engine.trackFrozenPayload("node", runtime.Now())
			runtime.advance(time.Duration(engine.cfg.DegradeConfirmSeconds)*time.Second + time.Second)
			engine.trackFrozenPayload("node", runtime.Now())

			facts := engine.ledger.Facts("node", engine.envKey, true, runtime.Now(), rcxLedgerProofTTL)
			if facts.OpenWorld != rcxProofUnknown || engine.ledger.Stalled("node", engine.envKey) {
				t.Errorf("facts = %+v, stalled = %v", facts, engine.ledger.Stalled("node", engine.envKey))
			}
			if len(engine.downFrozen) != 0 || len(engine.charged) != 0 {
				t.Errorf("frozen = %v, escrow = %v", engine.downFrozen, engine.charged)
			}
		})
	}
}

func TestEngineAcceptsPositiveProbeWithoutATrustedTerrain(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = providerMembers("one", "node")
	engine := newTestEngine(runtime, "ru")
	engine.terrain.observe(rcxTerrainUnknown, runtime.Now())
	engine.probing = true
	engine.applyProbeResult(rcxEvent{Gen: engine.probeGen, Results: []rcxProbeResult{{
		Node: "node", Role: rcxRoleOpen, Outcome: rcxProbeOK, DelayMs: 40,
	}}})

	facts := engine.ledger.Facts("node", engine.envKey, true, runtime.Now(), rcxLedgerProofTTL)
	if facts.OpenWorld != rcxProofProven {
		t.Errorf("open proof = %v, want positive evidence retained", facts.OpenWorld)
	}
}

func TestEngineRequiresAValidTopologyAndRechecksAfterApply(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.topologyValid = false
	runtime.members = foreignMembers("node")
	engine := newRcxEngine(runtime)
	engine.snapshot = rcxEmptySnapshot()
	engine.applyConfigLocked(testConfig("ru"))

	if engine.Enabled() {
		t.Fatal("an invalid reserved topology activated RCX")
	}
	engine.reconsider()
	if len(runtime.selects) != 0 || runtime.lastStatus().Enabled {
		t.Fatalf("selects = %v, status = %+v", runtime.selects, runtime.lastStatus())
	}

	runtime.topologyValid = true
	engine.handle(rcxEvent{Kind: rcxEventConfigApplied})
	if !engine.Enabled() || !runtime.lastStatus().Enabled {
		t.Fatalf("enabled = %v, status = %+v: valid applied skeleton did not activate requested RCX", engine.Enabled(), runtime.lastStatus())
	}
}

func TestEngineWritesNoRegimeMemoryBeforeTheFirstNetwork(t *testing.T) {
	runtime := newFakeRuntime()
	engine := newRcxEngine(runtime)
	engine.snapshot = rcxEmptySnapshot()
	engine.applyConfigLocked(testConfig("ru"))
	engine.validated = true
	engine.reachF, engine.reachD = rcxProbeOK, rcxProbeOK

	engine.classifyTerrain(true)

	if got := engine.terrain.terrain; got != rcxTerrainNormal {
		t.Fatalf("terrain = %v, want normal: the classification itself must still run", got)
	}
	if _, ok := engine.snapshot.Regimes[""]; ok {
		t.Error("the empty key is no network: a row under it is remembered forever and read by nobody")
	}

	named := newRcxEngine(runtime)
	named.snapshot = rcxEmptySnapshot()
	named.applyConfigLocked(testConfig("ru"))
	payload := rcxNetworkPayload{
		Transport: "wifi",
		SSID:      "Home",
		Validated: true,
	}
	named.handle(rcxEvent{Kind: rcxEventNetwork, Payload: payload})
	named.reachF, named.reachD = rcxProbeOK, rcxProbeOK
	named.classifyTerrain(true)
	key, _ := rcxEnvKeys(payload)

	if _, ok := named.snapshot.Regimes[key]; !ok {
		t.Error("want the memory written once the network has a name")
	}
}

func TestEngineReleasesAnEscrowTheCanariesSettledOffline(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("node")
	engine := newTestEngine(runtime, "ru")
	engine.validated = true

	failDial(engine, runtime, "node")
	engine.reachF, engine.reachD = rcxProbeFail, rcxProbeFail
	engine.classifyTerrain(true)

	if got := engine.terrainCurrent(); got != rcxTerrainOffline {
		t.Fatalf("terrain = %v, want offline", got)
	}
	if got := engine.ledger.FailStreak("node", "w:Home"); got != 0 {
		t.Errorf("streak = %d, want it back: the escrow was waiting for an answer the dead link will never send", got)
	}
}

func TestEngineHoldsTheSecondSwitchOfAnOutageForTheLinkVerdict(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("first", "second", "third")
	engine := newTestEngine(runtime, "ru")
	engine.quit = make(chan struct{})
	engine.incumbent = "first"
	engine.since = runtime.Now().Add(-time.Hour)

	for _, node := range []string{"second", "third"} {
		engine.ledger.NoteProbe(node, "w:Home", rcxRoleOpen, rcxProbeOK, 90, runtime.Now())
	}
	rcxChargeFailures(engine.ledger, "first", "w:Home", rcxTerrainNormal, runtime.Now(), 3)

	engine.reconsider()
	moved := runtime.selected
	if moved == "first" || moved == "" {
		t.Fatalf("selected = %q, want the dead incumbent left", moved)
	}

	runtime.advance(2 * time.Second)
	engine.handle(rcxEvent{Kind: rcxEventProbeResults, Results: []rcxProbeResult{
		{Node: moved, Role: rcxRoleOpen, Outcome: rcxProbeFail},
	}})

	if got := runtime.selected; got != moved {
		t.Errorf("selected = %q, want %q held: the round in flight is what tells a dead node from a dead link", got, moved)
	}
	if got := runtime.lastStatus().Reason; got != string(rcxReasonMeasuring) {
		t.Errorf("reason = %q, want measuring", got)
	}

	runtime.advance(rcxSwitchProbation)
	engine.reconsider()

	if got := runtime.selected; got == moved {
		t.Errorf("selected = %q, want the hold to expire: a verdict that never came cannot pin traffic to a dead node", got)
	}
}

func TestScaledProofTTLBuysTheParkTimeToRenewAProof(t *testing.T) {
	base := 30 * time.Minute
	tests := []struct {
		park int
		want time.Duration
	}{
		{park: 0, want: base},
		{park: 10, want: base},
		{park: 250, want: 62*time.Minute + 30*time.Second},
		{park: 5000, want: rcxMaxProofTTL},
	}

	for _, tc := range tests {
		if got := rcxScaledProofTTL(base, tc.park); got != tc.want {
			t.Errorf("park %d: ttl = %v, want %v", tc.park, got, tc.want)
		}
	}
}

func TestConfigEditSupersedesProbeAndReachResults(t *testing.T) {
	runtime := newFakeRuntime()
	engine := newTestEngine(runtime, "ru")
	probeGen := engine.probeGen
	reachGen := engine.reachGen
	configGen := engine.configGen

	config := engine.cfg
	config.OpenMarkers = []rcxMarker{{URL: "https://api.telegram.org/", Statuses: []int{404}}}
	config.CanaryForeign = []string{"8.8.8.8:443"}
	engine.applyConfigLocked(config)
	engine.handle(rcxEvent{
		Kind:      rcxEventProbeResults,
		Gen:       probeGen,
		ConfigGen: configGen,
		Results: []rcxProbeResult{{
			Node: "node", Role: rcxRoleOpen, Outcome: rcxProbeOK, DelayMs: 90,
		}},
	})
	engine.handle(rcxEvent{
		Kind:      rcxEventTerrainReach,
		Gen:       reachGen,
		ConfigGen: configGen,
		Foreign:   rcxProbeOK,
		Domestic:  rcxProbeOK,
	})

	if got := engine.ledger.Facts("node", "w:Home", true, runtime.Now(), rcxLedgerProofTTL).OpenWorld; got != rcxProofUnknown {
		t.Fatalf("stale config probe became proof: %v", got)
	}
	if engine.reachF == rcxProbeOK || engine.reachD == rcxProbeOK {
		t.Fatal("stale canary result replaced the new terrain epoch")
	}
}

func TestConfigEditInvalidatesOnlyItsProofAndOriginDomains(t *testing.T) {
	runtime := newFakeRuntime()
	engine := newTestEngine(runtime, "ru")
	engine.ledger.NoteProbe("node", "w:Home", rcxRoleOpen, rcxProbeOK, 90, runtime.Now())
	engine.ledger.NoteProbe("node", "w:Home", rcxRoleDomestic, rcxProbeOK, 90, runtime.Now())
	engine.ledger.SetOrigin("node", "RU", rcxOriginDomestic)

	config := engine.cfg
	config.OpenMarkers = []rcxMarker{{URL: "https://api.telegram.org/", Statuses: []int{404}}}
	engine.applyConfigLocked(config)
	facts := engine.ledger.Facts("node", "w:Home", true, runtime.Now(), rcxLedgerProofTTL)
	if facts.OpenWorld != rcxProofUnknown || facts.Domestic != rcxProofProven || facts.Transit != rcxProofProven {
		t.Fatalf("open marker edit crossed proof domains: %+v", facts)
	}

	config.CensorCountries = []string{"IR"}
	engine.applyConfigLocked(config)
	if got := engine.ledger.Origin("node"); got != rcxOriginUnknown {
		t.Fatalf("origin = %v, want reevaluation after country edit", got)
	}
}

func TestEngineBarsAProvenNodeMeasuredEgressingAtHome(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("spb", "nl")
	engine := newTestEngine(runtime, "ru")
	engine.syncIdentity(runtime.members)
	engine.probing = true
	now := runtime.Now()

	for _, result := range []rcxProbeResult{
		{Node: "spb", Role: rcxRoleOpen, Outcome: rcxProbeOK, DelayMs: 59, ExitCountry: "RU"},
		{Node: "nl", Role: rcxRoleOpen, Outcome: rcxProbeOK, DelayMs: 120},
	} {
		engine.applyProbeResult(rcxEvent{
			Gen:     engine.probeGen,
			Lane:    engine.probeLane,
			Results: []rcxProbeResult{result},
		})
	}

	if engine.provesOpenRecovery("spb", now) {
		t.Error("a node whose packets never leave the country must not win the open race on latency")
	}
	if !engine.provesOpenRecovery("nl", now) {
		t.Error("an unmeasured egress must not bar a node that answered the open marker")
	}
	candidates := engine.candidates(runtime.Members())
	input := rcxDecisionInput{
		Terrain:    engine.terrainCurrent(),
		Candidates: candidates,
		Policy:     engine.cfg.policy(),
		Now:        now,
	}
	for _, report := range engine.candidateReports(rcxRank(input), input, now) {
		if report.Node != "spb" {
			continue
		}
		if report.Exit != "RU" || report.Block != string(rcxBlockLastResort) {
			t.Errorf("report = %+v, want the measured exit and the last-resort bar", report)
		}
	}
}

func TestEngineRidesTheEchoOnWhicheverProbeCarriesTheOpenRole(t *testing.T) {
	runtime := newFakeRuntime()
	engine := newTestEngine(runtime, "ru")
	engine.cfg.EgressEchoes = []string{"https://echo.example/"}
	engine.ledger.SetOrigin("home", "RU", rcxOriginDomestic)
	wave := []rcxProbeNode{{Name: "home", Key: "home"}}

	targets := engine.probeTargets(wave, rcxTerrainWhitelist, rcxWaveRoutine)
	for _, target := range targets {
		if (len(target.Echoes) > 0) != (target.Role == rcxRoleOpen) {
			t.Errorf("target %v carries the wrong echo set: %v", target.Role, target.Echoes)
		}
	}
}

func TestFastForeignWinnerIsNotSunkButVerifiedOnWin(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("Швеция")
	engine := newTestEngine(runtime, "ru")
	engine.cfg.CountryEchoes = []string{"https://api.country.is/"}
	now := runtime.Now()
	key := engine.key("Швеция")
	engine.ledger.SetOrigin(key, "US", rcxOriginForeign)

	// A fast foreign node is never pre-sunk on ping alone: it keeps competing.
	engine.assessTrust("Швеция", key, now)
	if trust, _ := engine.ledger.Trust(key); trust != rcxTrustUnknown {
		t.Fatalf("trust = %v, want unknown: a fast foreign node must not be sunk before it is measured", trust)
	}

	// But an unmeasured winner earns one quick country-service check before traffic.
	if !engine.wantsLocate("Швеция", now) {
		t.Fatal("an unverified winner should be verified on win, not trusted blind")
	}
	engine.ledger.SetExit(key, "SE", rcxOriginForeign, now)
	if engine.wantsLocate("Швеция", now) {
		t.Fatal("a node with a measured foreign egress needs no further check")
	}
}
