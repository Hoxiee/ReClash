package main

import (
	"context"
	"sync"
	"testing"
	"time"
)

type fakeRuntime struct {
	mu        sync.Mutex
	members   []rcxMember
	selected  string
	selects   []string
	selectErr error
	mode      string
	countries map[string]string
	results   map[string]rcxProbeResult
	reach     map[string]rcxProbeOutcome
	traffic   map[string]rcxTrafficSample
	published []rcxStatus
	now       time.Time
	tested    []string
}

func newFakeRuntime() *fakeRuntime {
	return &fakeRuntime{
		mode:      "rule",
		countries: map[string]string{},
		results:   map[string]rcxProbeResult{},
		reach:     map[string]rcxProbeOutcome{},
		traffic:   map[string]rcxTrafficSample{},
		now:       time.Unix(1_700_000_000, 0),
	}
}

func (r *fakeRuntime) Members() []rcxMember {
	r.mu.Lock()
	defer r.mu.Unlock()
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

func (r *fakeRuntime) Mode() string { return r.mode }

func (r *fakeRuntime) Country(node string) string { return r.countries[node] }

func (r *fakeRuntime) Test(_ context.Context, node string, _ rcxMarker) (int, bool, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	r.tested = append(r.tested, node)
	result, ok := r.results[node]
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

func (r *fakeRuntime) Reach(_ context.Context, addr string) rcxProbeOutcome {
	if outcome, ok := r.reach[addr]; ok {
		return outcome
	}
	return rcxProbeFail
}

func (r *fakeRuntime) Traffic() map[string]rcxTrafficSample {
	r.mu.Lock()
	defer r.mu.Unlock()
	out := map[string]rcxTrafficSample{}
	for node, sample := range r.traffic {
		out[node] = sample
	}
	return out
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
	engine.terrain.observe(rcxTerrainNormal, runtime.Now())
	return engine
}

func foreignMembers(names ...string) []rcxMember {
	members := make([]rcxMember, 0, len(names))
	for i, name := range names {
		members = append(members, rcxMember{
			Name:        name,
			Type:        "Vless",
			Port:        443,
			SupportsUDP: true,
			Order:       uint16(i),
		})
	}
	return members
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
	for i := 0; i < 3; i++ {
		engine.ledger.NoteDialFailure("dead", "10.0.0.1:"+string(rune('a'+i)), "w:Home", rcxTerrainNormal, runtime.Now())
	}

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
	if got := runtime.lastStatus().Reason; got != string(rcxReasonStranded) {
		t.Errorf("reason = %q, want stranded", got)
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

	for i := 0; i < 3; i++ {
		engine.ledger.NoteDialFailure("node", "10.0.0.1:"+string(rune('a'+i)), "w:Home", rcxTerrainNormal, runtime.Now())
	}

	if engine.ledger.CoolUntil("node", "w:Home").IsZero() {
		t.Fatal("three failed connections on one network must cool the node there")
	}
	if !engine.ledger.CoolUntil("node", "c:25001").IsZero() {
		t.Error("a whitelist episode on wifi must not condemn the node on LTE")
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

	if engine.envKey != "w:Home" {
		t.Fatalf("env key = %q, want the SSID once it is readable", engine.envKey)
	}
	if got := engine.snapshot.Picks["w:Home"]; got != "node" {
		t.Errorf("pick = %q, want the record migrated, not orphaned", got)
	}
	if engine.ledger.Facts("node", "w:Home", true, runtime.Now()).OpenWorld != rcxProofProven {
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
			engine.NoteDial("node", "10.0.0.1:1234", true, time.Millisecond, runtime.Now())
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
	engine.handle(<-engine.events)

	engine.NoteDial("node", "10.0.0.1:1234", true, time.Millisecond, runtime.Now())

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
		engine.NoteDial("DIRECT", "10.0.0.1:"+string(rune('a'+i)), true, time.Millisecond, runtime.Now())
	}
	engine.drainDials()

	if !engine.ledger.CoolUntil("DIRECT", "w:Home").IsZero() {
		t.Error("a DIRECT dial is not evidence about a node in the skeleton")
	}
}

func TestEngineStopsCollectingEvidenceOutsideRuleMode(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("node")
	engine := newTestEngine(runtime, "ru")
	engine.reconsider()
	runtime.mode = "global"

	for i := 0; i < 3; i++ {
		engine.NoteDial("node", "10.0.0.1:"+string(rune('a'+i)), true, time.Millisecond, runtime.Now())
	}
	engine.drainDials()

	if !engine.ledger.CoolUntil("node", "w:Home").IsZero() {
		t.Error("in Global every request goes to one proxy: its failures say nothing about the park")
	}
}

func TestEngineReadsThrottlingFromTrafficDeltas(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("node")
	engine := newTestEngine(runtime, "ru")

	runtime.traffic = map[string]rcxTrafficSample{"node": {Up: 1000, Down: 500}}
	engine.sampleTraffic()
	runtime.traffic = map[string]rcxTrafficSample{"node": {Up: 4000, Down: 500}}
	engine.sampleTraffic()

	if !engine.ledger.Degraded("node", "w:Home", runtime.Now()) {
		t.Fatal("upload growing while nothing returns is throttling, which no dial verdict shows")
	}

	runtime.traffic = map[string]rcxTrafficSample{"node": {Up: 5000, Down: 9000}}
	engine.sampleTraffic()

	if engine.ledger.Degraded("node", "w:Home", runtime.Now()) {
		t.Error("bytes coming back must clear the verdict")
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

func TestEngineNarrowsTheWaveOnAMeteredLink(t *testing.T) {
	wide := newFakeRuntime()
	wide.members = foreignMembers("a", "b", "c", "d", "e", "f", "g", "h")
	home := newTestEngine(wide, "ru")
	home.reconsider()
	spentOnWifi := rcxProbeBudgetCap - home.budget.Remaining(wide.Now())

	metered := newFakeRuntime()
	metered.members = wide.members
	mobile := newTestEngine(metered, "ru")
	mobile.metered = true
	mobile.reconsider()
	spentOnLte := rcxProbeBudgetCap - mobile.budget.Remaining(metered.Now())

	if spentOnLte >= spentOnWifi {
		t.Errorf("spent %d probes on LTE vs %d on wifi: a metered wave must be narrower", spentOnLte, spentOnWifi)
	}
	if spentOnLte > 3 {
		t.Errorf("spent %d probes on a metered link, want at most 3", spentOnLte)
	}
}

func TestEngineLetsWorkingTrafficStandInForAProbe(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("a", "b")
	engine := newTestEngine(runtime, "ru")
	engine.incumbent = "a"
	engine.since = runtime.Now().Add(-time.Hour)
	engine.ledger.NoteDialSuccess("a", "10.0.0.1:1234", "w:Home", 70*time.Millisecond, runtime.Now())

	engine.reconsider()

	if engine.probing {
		t.Error("the user's own connection already proved the node: paying for a probe is waste")
	}
}

func TestEngineHonoursAManualPickUntilItStopsWorking(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("chosen", "faster")
	engine := newTestEngine(runtime, "ru")
	engine.ledger.NoteProbe("chosen", "w:Home", rcxRoleOpen, rcxProbeOK, 900, runtime.Now())
	engine.ledger.NoteProbe("faster", "w:Home", rcxRoleOpen, rcxProbeOK, 60, runtime.Now())

	engine.handle(rcxEvent{Kind: rcxEventManualPick, Node: "chosen"})
	runtime.advance(10 * time.Minute)
	engine.reconsider()

	if got := engine.incumbent; got != "chosen" {
		t.Fatalf("incumbent = %q, want the manual pick to survive a latency gain", got)
	}

	runtime.advance(time.Duration(engine.cfg.ManualHoldMinutes) * time.Minute)
	engine.reconsider()

	if got := engine.incumbent; got != "faster" {
		t.Errorf("incumbent = %q, want the hold to expire rather than pin forever", got)
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

	for i := 0; i < 4; i++ {
		engine.ledger.NoteDialFailure("node", "10.0.0.1:"+string(rune('a'+i)), "c:25001", rcxTerrainWhitelist, runtime.Now())
	}
	if engine.ledger.CoolUntil("node", "c:25001").IsZero() {
		t.Fatal("failures during a shutdown still cool the node while it lasts")
	}

	engine.reachF = rcxProbeOK
	engine.validated = true
	engine.classifyTerrain()

	if !engine.ledger.CoolUntil("node", "c:25001").IsZero() {
		t.Error("one commute must not leave the whole park cooling on a healthy network")
	}
}
