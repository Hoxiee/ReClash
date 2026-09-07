package main

import (
	"context"
	"sync"
	"testing"
	"time"

	C "github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/tunnel/statistic"
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
	conns     map[string]rcxConnSample
	hang      map[string]bool
	panics    map[string]bool
	closed    []string
	published []rcxStatus
	link      rcxNetworkPayload
	linked    bool
	now       time.Time
	tested    []string

	groupSelected map[string]string
}

func newFakeRuntime() *fakeRuntime {
	return &fakeRuntime{
		mode:      "rule",
		countries: map[string]string{},
		results:   map[string]rcxProbeResult{},
		reach:     map[string]rcxProbeOutcome{},
		conns:     map[string]rcxConnSample{},
		hang:      map[string]bool{},
		panics:    map[string]bool{},
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
			Order:       uint16(i),
		})
	}
	return members
}

func providerMembers(provider string, names ...string) []rcxMember {
	members := foreignMembers(names...)
	for i := range members {
		members[i].Provider = provider
		members[i].Transport = "transport-" + names[i]
	}
	return members
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

	rcxChargeFailures(engine.ledger, "node", "w:Home", rcxTerrainNormal, runtime.Now(), 3)

	if engine.ledger.CoolUntil("node", "w:Home", engine.runtime.Now()).IsZero() {
		t.Fatal("three failed connections on one network must cool the node there")
	}
	if !engine.ledger.CoolUntil("node", "c:25001", engine.runtime.Now()).IsZero() {
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
	if !engine.probing {
		t.Error("a stale wave must not unlatch the live one")
	}
	if got := engine.budget.Remaining(runtime.Now()); got != left {
		t.Errorf("budget left = %d, want %d: a discarded wave refunds nothing", got, left)
	}
}

func TestEngineMeasuresAtOnceOnTheNetworkThatArrived(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("a", "b")
	engine := newTestEngine(runtime, "ru")
	members := runtime.members
	// The free cold-start wave first, so what the handoff buys is a paid one.
	engine.reconsider()
	before := engine.budget.Remaining(runtime.Now())

	cellularHandoff(engine)

	if !engine.probing {
		t.Fatal("the network that arrived is unmeasured: its own wave must go out at once")
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
	runtime.results = map[string]rcxProbeResult{
		"a": {Node: "a", Outcome: rcxProbeOK, DelayMs: 120},
	}
	engine := newTestEngine(runtime, "ru")
	engine.quit = make(chan struct{})

	cellularKey := cellularHandoff(engine)
	if !engine.probing {
		t.Fatal("want the new network's own wave in flight")
	}

	deadline := time.After(2 * time.Second)
	for engine.probing {
		select {
		case event := <-engine.events:
			engine.handle(event)
		case <-deadline:
			t.Fatal("the wave the new network bought never landed: its generation was not the live one")
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
	runtime.openConn("starved", node, "example.org")
	runtime.bumpConn("starved", 1000, 0)
	runtime.advance(rcxConnStallAge)
	engine.sampleTraffic()
	runtime.advance(time.Duration(engine.cfg.DegradeConfirmSeconds+1) * time.Second)
	runtime.bumpConn("starved", 3000, 0)
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
	runtime.bumpConn("req", 3000, 0)
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

	if got := runtime.selected; got != "spare" {
		t.Errorf("selected = %q, want the measurement to evict the node it disproved", got)
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
	if got := runtime.lastStatus().Reason; got != string(rcxReasonMeasuring) {
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

func TestEngineRepeatsAFailedRescueOnlyAfterAFloor(t *testing.T) {
	runtime, engine, members := rescuePark(t)

	first := engine.planWave(engine.candidates(members), members, rcxWaveRescue)
	if len(first) != len(members) {
		t.Fatalf("rescue wave = %d nodes, want the whole park on the first ask", len(first))
	}

	runtime.advance(rcxTickInterval)
	if got := engine.planWave(engine.candidates(members), members, rcxWaveRescue); got != nil {
		t.Errorf("second rescue = %d nodes, want none: a sweep that found nothing is not worth repeating per tick", len(got))
	}
	if got := engine.planWave(engine.candidates(members), members, rcxWaveDeep); len(got) != len(members) {
		t.Errorf("deep sweep = %d nodes, want the whole park: the user asked for this one", len(got))
	}

	runtime.advance(rcxRescueRepeat)
	if got := engine.planWave(engine.candidates(members), members, rcxWaveRescue); len(got) != len(members) {
		t.Errorf("third rescue = %d nodes, want the whole park: the floor is a delay, not a lock", len(got))
	}
}

func TestEngineRescuesAgainTheMomentSomethingChanged(t *testing.T) {
	runtime, engine, members := rescuePark(t)
	engine.planWave(engine.candidates(members), members, rcxWaveRescue)

	runtime.advance(rcxTickInterval)
	engine.terrain.observe(rcxTerrainWhitelist, runtime.Now())

	if got := engine.planWave(engine.candidates(members), members, rcxWaveRescue); len(got) != len(members) {
		t.Errorf("rescue = %d nodes, want the whole park: the canaries came back with something new", len(got))
	}
}

func TestEngineLiftsTheRescueFloorOnceAWaveAnswered(t *testing.T) {
	runtime, engine, members := rescuePark(t)
	if got := engine.planWave(engine.candidates(members), members, rcxWaveRescue); len(got) != len(members) {
		t.Fatalf("first rescue = %d nodes, want the whole park", len(got))
	}

	engine.handle(rcxEvent{Kind: rcxEventProbeResults, Results: []rcxProbeResult{{
		Node: members[0].Name, Role: rcxRoleOpen, Outcome: rcxProbeOK, DelayMs: 120,
	}}})
	runtime.advance(2 * time.Duration(rcxLiveWindowSeconds) * time.Second)

	if got := engine.planWave(engine.candidates(members), members, rcxWaveRescue); len(got) != len(members) {
		t.Errorf("rescue = %d nodes, want the whole park: a link that answered is worth asking again", len(got))
	}
}

func TestEngineSweepsTheWholeParkWhenNothingIsRoutable(t *testing.T) {
	runtime := newFakeRuntime()
	names := make([]string, 0, 30)
	for i := 0; i < 30; i++ {
		names = append(names, "n"+string(rune('a'+i)))
	}
	runtime.members = foreignMembers(names...)
	engine := newTestEngine(runtime, "ru")
	members := runtime.members

	wave := engine.planWave(engine.candidates(members), members, rcxWaveRescue)

	if len(wave) != len(names) {
		t.Errorf("rescue wave = %d nodes, want the whole park", len(wave))
	}
	if got := engine.budget.Remaining(runtime.Now()); got != rcxProbeBudgetCap {
		t.Errorf("budget left = %d, want a rescue to ride outside the hourly cap", got)
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
	if wave := engine.planWave(engine.candidates(members), members, rcxWaveMaintain); len(wave) != 1 {
		t.Fatalf("wave = %d nodes, want the one probe left above the reserve", len(wave))
	}

	if wave := engine.planWave(engine.candidates(members), members, rcxWaveMaintain); len(wave) != 0 {
		t.Errorf("wave = %d nodes, want none: the reserve belongs to the waves that answer an event", len(wave))
	}
	if wave := engine.planWave(engine.candidates(members), members, rcxWaveRescue); len(wave) != len(names) {
		t.Errorf("rescue wave = %d nodes, want the whole park: the reserve was kept for it", len(wave))
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

func TestEngineSpreadsColdStartsAcrossInstalls(t *testing.T) {
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
	if first == second {
		t.Errorf("both installs opened on %q: the declared index is the same list for everyone", first)
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
	got := engine.reachAny(ctx, []string{"1.1.1.1:443", "9.9.9.9:443"}, false, &rows)

	if got != rcxProbeOK {
		t.Errorf("outcome = %s, want ok: a black hole must not spend the whole round",
			rcxOutcomeName(got))
	}
}

func TestCanaryGroupReportsMeasuredAddressesInOrder(t *testing.T) {
	engine := newTestEngine(newFakeRuntime(), "ru")

	var rows []rcxCanaryReport
	engine.reachAny(context.Background(), []string{"1.1.1.1:443", "9.9.9.9:443"}, false, &rows)

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

	engine.reconsider()

	if got := runtime.lastStatus().Reason; got != string(rcxReasonLatencyGain) {
		t.Fatalf("reason = %q, want latency-gain", got)
	}
	if got := runtime.hungUpOn(); len(got) != 0 {
		t.Errorf("closed = %v, want a comfort switch to leave live connections alone", got)
	}
}

// A panicking dial took the process with it, and never freed its seat.
func TestCanaryRoundOutlivesAPanickingDial(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.panics = map[string]bool{"1.1.1.1:443": true}
	engine := newTestEngine(runtime, "ru")

	var rows []rcxCanaryReport
	got := engine.reachAny(context.Background(), []string{"1.1.1.1:443"}, false, &rows)

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

func TestEngineMarksFailuresOnAStaleTerrainProvisional(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("node")
	engine := newTestEngine(runtime, "ru")
	engine.lastReachAt = runtime.Now()

	failDial(engine, runtime, "node")
	if got := engine.ledger.envState("w:Home", "node").provisionalFails; got != 0 {
		t.Fatalf("provisional = %d, want 0: a fresh normal reading blames the node", got)
	}

	runtime.advance(rcxTerrainMaxAge + time.Minute)
	failDial(engine, runtime, "node")

	if got := engine.ledger.envState("w:Home", "node").provisionalFails; got != 1 {
		t.Errorf("provisional = %d, want 1: a reading the engine distrusts cannot condemn a node for good", got)
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
