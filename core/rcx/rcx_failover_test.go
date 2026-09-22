package rcx

import (
	"testing"
	"time"
)

func TestMarkerQuarantineNeedsIndependentPreviouslyWorkingNodes(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = []rcxMember{
		{Name: "a", Provider: "one", Transport: "ws", Type: "Vless", Port: 443},
		{Name: "b", Provider: "one", Transport: "grpc", Type: "Vless", Port: 443},
		{Name: "c", Provider: "two", Transport: "tcp", Type: "Shadowsocks", Port: 8388},
		{Name: "new", Provider: "three", Transport: "ws", Type: "Vless", Port: 443},
	}
	engine := newTestEngine(runtime, "ru")
	markerID := rcxMarkerID(rcxRoleOpen, engine.cfg.OpenMarkers[0])
	// Only a proven-foreign node can testify the foreign marker is down.
	for _, node := range []string{"a", "b", "c"} {
		engine.ledger.NoteProbe(node, engine.envKey, rcxRoleOpen, rcxProbeOK, 40, runtime.Now())
		engine.ledger.SetExit(node, "US", rcxOriginForeign, runtime.Now())
	}

	for _, node := range []string{"a", "a", "new", "b"} {
		engine.noteMarkerFailure(markerID, node, runtime.Now())
	}
	if engine.markerQuarantined(markerID, runtime.Now()) {
		t.Fatal("duplicate and unproven failures reached the independent-node quorum")
	}

	engine.noteMarkerFailure(markerID, "c", runtime.Now())
	if !engine.markerQuarantined(markerID, runtime.Now()) {
		t.Fatal("three independent previously working nodes did not quarantine the marker")
	}
	if engine.snapshot.Metrics.MarkerIncidents != 1 {
		t.Fatalf("marker incidents = %d, want one quarantine transition", engine.snapshot.Metrics.MarkerIncidents)
	}
}

func TestDomesticEgressNodesNeverQuarantineTheOpenMarker(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = []rcxMember{
		{Name: "a", Provider: "one", Transport: "ws", Type: "Vless", Port: 443},
		{Name: "b", Provider: "one", Transport: "grpc", Type: "Vless", Port: 443},
		{Name: "c", Provider: "two", Transport: "tcp", Type: "Shadowsocks", Port: 8388},
	}
	engine := newTestEngine(runtime, "ru")
	markerID := rcxMarkerID(rcxRoleOpen, engine.cfg.OpenMarkers[0])
	for _, node := range []string{"a", "b", "c"} {
		engine.ledger.NoteProbe(node, engine.envKey, rcxRoleOpen, rcxProbeOK, 40, runtime.Now())
		engine.ledger.SetExit(node, "RU", rcxOriginDomestic, runtime.Now())
	}

	for _, node := range []string{"a", "b", "c"} {
		engine.noteMarkerFailure(markerID, node, runtime.Now())
	}
	if engine.markerQuarantined(markerID, runtime.Now()) {
		t.Fatal("home-country nodes failing the foreign marker quarantined it")
	}
}

func TestMarkerQuarantineExpiresAndRestoresTheConfiguredOrder(t *testing.T) {
	runtime := newFakeRuntime()
	engine := newTestEngine(runtime, "ru")
	second := rcxMarker{URL: "https://fallback.example/", Statuses: []int{200}}
	engine.cfg.OpenMarkers = append(engine.cfg.OpenMarkers, second)
	firstID := rcxMarkerID(rcxRoleOpen, engine.cfg.OpenMarkers[0])
	engine.snapshot.Quarantines[firstID] = rcxMarkerQuarantine{
		Until: runtime.Now().Add(rcxMarkerQuarantineTTL),
	}

	active := engine.activeMarkers(rcxRoleOpen, runtime.Now())
	if len(active) != 1 || active[0].URL != second.URL {
		t.Fatalf("active = %v, want only the fallback while quarantined", active)
	}

	runtime.advance(rcxMarkerQuarantineTTL + time.Second)
	active = engine.activeMarkers(rcxRoleOpen, runtime.Now())
	if len(active) != 2 || active[0].URL != engine.cfg.OpenMarkers[0].URL {
		t.Fatalf("active = %v, want the configured order after expiry", active)
	}
	if _, exists := engine.snapshot.Quarantines[firstID]; exists {
		t.Fatal("expired quarantine was retained")
	}
}

func TestProviderIncidentCountsOnlyWhenTheCircuitOpens(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = []rcxMember{
		{Name: "a", ID: "a-id", Provider: "provider-a", Transport: "ws", Port: 443, Ingress: "a.example", ExternalProvider: true},
		{Name: "b", ID: "b-id", Provider: "provider-a", Transport: "grpc", Port: 443, Ingress: "b.example", ExternalProvider: true},
	}
	engine := newTestEngine(runtime, "ru")

	engine.noteProviderNodeFailure("a", runtime.Now())
	engine.noteProviderNodeFailure("a", runtime.Now())
	if engine.snapshot.Metrics.ProviderIncidents != 0 {
		t.Fatal("one failure bucket opened a provider incident")
	}
	engine.noteProviderNodeFailure("b", runtime.Now())
	if engine.snapshot.Metrics.ProviderIncidents != 1 {
		t.Fatalf("provider incidents = %d, want one circuit transition", engine.snapshot.Metrics.ProviderIncidents)
	}
}

func TestStandbysPreferIndependentBucketsAndFallBackWithinOne(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = []rcxMember{
		{Name: "current", ID: "current-id", Provider: "zero", Transport: "ws", Type: "Vless", Port: 443, SupportsUDP: true},
		{Name: "a", ID: "a-id", Provider: "one", Transport: "ws", Type: "Vless", Port: 443, SupportsUDP: true},
		{Name: "b", ID: "b-id", Provider: "one", Transport: "ws", Type: "Vless", Port: 443, SupportsUDP: true},
		{Name: "c", ID: "c-id", Provider: "two", Transport: "grpc", Type: "Vless", Port: 443, SupportsUDP: true},
		{Name: "d", ID: "d-id", Provider: "three", Transport: "tcp", Type: "Shadowsocks", Port: 8388, SupportsUDP: true},
	}
	engine := newTestEngine(runtime, "ru")
	engine.incumbent = "current"
	for _, member := range runtime.members {
		engine.ledger.NoteProbe(member.key(), engine.envKey, rcxRoleOpen, rcxProbeOK, 40, runtime.Now())
	}
	candidates := engine.candidates(runtime.members)
	input := rcxDecisionInput{Terrain: rcxTerrainNormal, Incumbent: "current", Candidates: candidates, Policy: engine.cfg.policy(), Now: runtime.Now()}

	engine.rebuildStandbys(rcxRank(input))

	got := engine.snapshot.Standbys[engine.envKey]
	if len(got) != rcxStandbyCount {
		t.Fatalf("standbys = %v, want %d", got, rcxStandbyCount)
	}
	buckets := map[string]struct{}{}
	for _, key := range got {
		for _, member := range runtime.members {
			if member.key() == key {
				buckets[member.Provider+"|"+member.Transport] = struct{}{}
			}
		}
	}
	if len(buckets) != rcxStandbyCount {
		t.Fatalf("standbys = %v, want three independent buckets", got)
	}

	for i := range runtime.members {
		if runtime.members[i].Name != "current" {
			runtime.members[i].Provider = "one"
			runtime.members[i].Transport = "ws"
		}
	}
	candidates = engine.candidates(runtime.members)
	input.Candidates = candidates
	engine.rebuildStandbys(rcxRank(input))
	if got := engine.snapshot.Standbys[engine.envKey]; len(got) != rcxStandbyCount {
		t.Fatalf("standbys = %v, want fallback nodes from the shared bucket", got)
	}
}

func TestStandbyNamesDropsStaleMembersAndTheIncumbent(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = []rcxMember{
		{Name: "current", ID: "current-id"},
		{Name: "warm", ID: "warm-id"},
	}
	engine := newTestEngine(runtime, "ru")
	engine.incumbent = "current"
	engine.candidates(runtime.members)
	engine.snapshot.Standbys[engine.envKey] = []string{"gone-id", "current-id", "warm-id"}

	names := engine.standbyNames()
	if len(names) != 1 || names[0] != "warm" {
		t.Fatalf("names = %v, want only the live non-incumbent standby", names)
	}
}

func TestWatchdogStartsAnIncidentWaveForAFrozenIncumbent(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("current", "warm")
	runtime.results["current"] = rcxProbeResult{Outcome: rcxProbeFail}
	runtime.results["warm"] = rcxProbeResult{Outcome: rcxProbeOK, DelayMs: 40}
	engine := newTestEngine(runtime, "ru")
	engine.incumbent = "current"
	engine.since = runtime.Now().Add(-time.Hour)
	engine.ledger.NoteTrafficProgress("current", engine.envKey, false, runtime.Now())
	freezePayload(engine, runtime, "current")

	engine.watchIncumbent()
	defer func() {
		if engine.probeCancel != nil {
			engine.probeCancel()
		}
	}()

	if !engine.probing || engine.probeKind != rcxWaveIncident {
		t.Fatalf("probing = %v, kind = %d, want an incident wave", engine.probing, engine.probeKind)
	}
}

func TestDeathSwitchDrainsOnlyStalledTrackerIDs(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("dead", "alive")
	engine := newTestEngine(runtime, "ru")
	engine.incumbent = "dead"
	engine.since = runtime.Now().Add(-time.Hour)
	runtime.selected = "dead"
	runtime.openConn("stalled", "dead", "api.example")
	runtime.openConn("moving", "dead", "cdn.example")
	runtime.bumpConn("stalled", 1000, 0)
	runtime.bumpConn("moving", 1000, 500)
	runtime.advance(rcxConnStallAge)
	engine.sampleTraffic()
	engine.ledger.NoteProbe("alive", engine.envKey, rcxRoleOpen, rcxProbeOK, 40, runtime.Now())
	rcxChargeFailures(engine.ledger, "dead", engine.envKey, rcxTerrainNormal, runtime.Now(), 3)

	engine.reconsider()

	if got := runtime.hungUpOn(); len(got) != 1 || got[0] != "stalled" {
		t.Fatalf("closed = %v, want only the no-progress tracker", got)
	}
}

func TestFailedWaveStillCountsIndependentProviderFailures(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = providerMembers("one", "a", "b")
	engine := newTestEngine(runtime, "ru")
	engine.syncIdentity(runtime.members)
	engine.probeResults = []rcxProbeResult{
		{Node: "a", Key: "a", Outcome: rcxProbeFail, chargeNegative: true},
		{Node: "b", Key: "b", Outcome: rcxProbeStatusMismatch, chargeNegative: true},
	}

	engine.finishProbe()

	if !engine.providerCircuitOpen("one", "other", runtime.Now()) {
		t.Fatal("fully failed wave did not open the provider circuit")
	}
}

func TestSupersededPaidWaveCannotRefundTheNextGeneration(t *testing.T) {
	runtime := newFakeRuntime()
	engine := newTestEngine(runtime, "ru")
	if got := engine.budget.Take(3, runtime.Now()); got != 3 {
		t.Fatalf("budget take = %d, want 3", got)
	}
	engine.paidWave = 3
	engine.paidWaveGen = engine.probeGen
	engine.supersedeProbe()

	engine.probeResults = nil
	engine.finishProbe()

	if got := engine.budget.Remaining(runtime.Now()); got != rcxProbeBudgetCap-3 {
		t.Fatalf("remaining = %d, want superseded charge retained", got)
	}
}

func TestIncidentResultSwitchesEarlyAndCompletionRefundsUnstartedTargets(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("dead", "warm", "later")
	engine := newTestEngine(runtime, "ru")
	engine.incumbent = "dead"
	engine.since = runtime.Now().Add(-time.Hour)
	runtime.selected = "dead"
	engine.candidates(runtime.members)
	engine.ledger.NoteProbe("warm", engine.envKey, rcxRoleOpen, rcxProbeOK, 40, runtime.Now())
	engine.probing = true
	engine.probeKind = rcxWaveIncident
	engine.paidWave = 3
	engine.probeResults = nil
	engine.probeStarted = map[string]struct{}{}
	cancelled := false
	engine.probeCancel = func() { cancelled = true }

	engine.applyProbeResult(rcxEvent{Gen: engine.probeGen, ConfigGen: engine.configGen, Results: []rcxProbeResult{
		{Node: "dead", Role: rcxRoleOpen, Outcome: rcxProbeFail},
	}})
	engine.applyProbeResult(rcxEvent{Gen: engine.probeGen, ConfigGen: engine.configGen, Results: []rcxProbeResult{
		{Node: "warm", Role: rcxRoleOpen, Outcome: rcxProbeOK, DelayMs: 40},
	}})

	if runtime.selected != "warm" || !cancelled {
		t.Fatalf("selected = %q, cancelled = %v, want an early incident handoff", runtime.selected, cancelled)
	}
	engine.mu.Lock()
	engine.enabled = false
	engine.mu.Unlock()
	engine.finishProbe()
	if engine.probing || engine.paidWave != 0 {
		t.Fatalf("probing = %v, paid = %d, want a closed wave", engine.probing, engine.paidWave)
	}
	if got := engine.budget.Remaining(runtime.Now()); got != rcxProbeBudgetCap {
		t.Fatalf("remaining = %d, want unstarted targets refunded", got)
	}
}

func TestDomesticProofDoesNotEndOpenRecovery(t *testing.T) {
	for name, kind := range map[string]rcxWaveKind{
		"handoff":  rcxWaveHandoff,
		"incident": rcxWaveIncident,
		"rescue":   rcxWaveRescue,
	} {
		t.Run(name, func(t *testing.T) {
			runtime := newFakeRuntime()
			runtime.members = foreignMembers("dead", "home", "open")
			runtime.countries = map[string]string{"dead": "NL", "home": "RU", "open": "NL"}
			engine := newTestEngine(runtime, "ru")
			engine.incumbent = "dead"
			runtime.selected = "dead"
			engine.terrain.observe(rcxTerrainWhitelist, runtime.Now())
			engine.candidates(runtime.members)
			engine.probing = true
			engine.probeKind = kind
			engine.probeStarted = map[string]struct{}{}
			cancelled := false
			engine.probeCancel = func() { cancelled = true }

			engine.applyProbeResult(rcxEvent{Gen: engine.probeGen, ConfigGen: engine.configGen, Results: []rcxProbeResult{{
				Node: "home", Role: rcxRoleDomestic, Outcome: rcxProbeOK, DelayMs: 20,
			}}})

			if engine.probeRecovered || cancelled {
				t.Fatalf("recovered = %v, cancelled = %v, domestic proof ended open recovery", engine.probeRecovered, cancelled)
			}
			if runtime.selected != "dead" {
				t.Fatalf("selected = %q, want recovery to keep searching", runtime.selected)
			}
			facts := engine.ledger.Facts("home", engine.envKey, true, runtime.Now(), rcxLedgerProofTTL)
			if facts.Domestic != rcxProofProven || facts.OpenWorld == rcxProofProven {
				t.Fatalf("facts = %+v, want domestic proof without open proof", facts)
			}
		})
	}
}

func TestOpenProofEndsRecoveryAfterDomesticProof(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("dead", "home", "open")
	runtime.countries = map[string]string{"dead": "NL", "home": "RU", "open": "NL"}
	engine := newTestEngine(runtime, "ru")
	engine.incumbent = "dead"
	runtime.selected = "dead"
	engine.terrain.observe(rcxTerrainWhitelist, runtime.Now())
	engine.candidates(runtime.members)
	engine.probing = true
	engine.probeKind = rcxWaveIncident
	engine.probeStarted = map[string]struct{}{}
	cancelled := false
	engine.probeCancel = func() { cancelled = true }

	engine.applyProbeResult(rcxEvent{Gen: engine.probeGen, ConfigGen: engine.configGen, Results: []rcxProbeResult{{
		Node: "dead", Role: rcxRoleOpen, Outcome: rcxProbeFail,
	}}})
	engine.applyProbeResult(rcxEvent{Gen: engine.probeGen, ConfigGen: engine.configGen, Results: []rcxProbeResult{{
		Node: "home", Role: rcxRoleDomestic, Outcome: rcxProbeOK, DelayMs: 20,
	}}})
	engine.applyProbeResult(rcxEvent{Gen: engine.probeGen, ConfigGen: engine.configGen, Results: []rcxProbeResult{{
		Node: "open", Role: rcxRoleOpen, Outcome: rcxProbeOK, DelayMs: 80,
	}}})

	if !engine.probeRecovered || !cancelled {
		t.Fatalf("recovered = %v, cancelled = %v, open proof did not end recovery", engine.probeRecovered, cancelled)
	}
	if runtime.selected != "open" {
		t.Fatalf("selected = %q, want the open-world node", runtime.selected)
	}
}

func TestHandoffResultSwitchesEarly(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("dead", "remembered", "later")
	engine := newTestEngine(runtime, "ru")
	engine.incumbent = "dead"
	runtime.selected = "dead"
	engine.candidates(runtime.members)
	engine.probing = true
	engine.probeKind = rcxWaveHandoff
	engine.probeStarted = map[string]struct{}{}
	cancelled := false
	engine.probeCancel = func() { cancelled = true }

	engine.applyProbeResult(rcxEvent{Gen: engine.probeGen, ConfigGen: engine.configGen, Results: []rcxProbeResult{{
		Node: "remembered", Role: rcxRoleOpen, Outcome: rcxProbeOK, DelayMs: 40,
	}}})

	if runtime.selected != "remembered" || !cancelled {
		t.Fatalf("selected = %q, cancelled = %v, want an early handoff", runtime.selected, cancelled)
	}
}

func TestOpenMissKeepsProvenIncumbentUnlessReactive(t *testing.T) {
	setup := func(kind rcxWaveKind) *rcxEngine {
		runtime := newFakeRuntime()
		runtime.members = foreignMembers("current", "rival")
		engine := newTestEngine(runtime, "ru")
		engine.incumbent = "current"
		engine.since = runtime.Now().Add(-time.Hour)
		runtime.selected = "current"
		engine.ledger.NoteProbe("current", engine.envKey, rcxRoleOpen, rcxProbeOK, 40, runtime.Now())
		engine.probing = true
		engine.probeKind = kind
		engine.probeResults = nil
		engine.probeStarted = map[string]struct{}{}
		return engine
	}

	now := newFakeRuntime().Now()
	ttl := rcxScaledProofTTL(rcxProofTTLMinutes*time.Minute, 2)

	spared := map[string]rcxWaveKind{
		"routine": rcxWaveRoutine, "maintain": rcxWaveMaintain,
		"discover": rcxWaveDiscover, "quality": rcxWaveQuality, "deep": rcxWaveDeep,
	}
	for name, kind := range spared {
		engine := setup(kind)
		if !engine.ledger.OpenProven("current", engine.envKey, now, ttl) {
			t.Fatalf("%s: incumbent should start proven", name)
		}
		engine.applyProbeResult(rcxEvent{Gen: engine.probeGen, ConfigGen: engine.configGen, Results: []rcxProbeResult{
			{Node: "current", Role: rcxRoleOpen, Outcome: rcxProbeFail},
		}})
		if !engine.ledger.OpenProven("current", engine.envKey, now, ttl) {
			t.Fatalf("%s: a lone open miss disproved the working incumbent", name)
		}
	}

	reactive := map[string]rcxWaveKind{
		"incident": rcxWaveIncident, "rescue": rcxWaveRescue, "handoff": rcxWaveHandoff,
	}
	for name, kind := range reactive {
		engine := setup(kind)
		engine.applyProbeResult(rcxEvent{Gen: engine.probeGen, ConfigGen: engine.configGen, Results: []rcxProbeResult{
			{Node: "current", Role: rcxRoleOpen, Outcome: rcxProbeFail},
		}})
		if engine.ledger.OpenProven("current", engine.envKey, now, ttl) {
			t.Fatalf("%s: a reactive wave must still refute a proof no freeze protects", name)
		}
	}
}

func TestStalledIncumbentSurvivesOneIncidentMissThenDies(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("current", "rival")
	engine := newTestEngine(runtime, "ru")
	engine.incumbent, runtime.selected = "current", "current"
	engine.since = runtime.Now().Add(-time.Hour)
	engine.probing, engine.probeKind = true, rcxWaveIncident
	engine.probeStarted = map[string]struct{}{}
	engine.ledger.NoteProbe("current", engine.envKey, rcxRoleOpen, rcxProbeOK, 40, runtime.Now())
	engine.ledger.NoteIncumbentStalled("current", engine.envKey, runtime.Now())

	now := runtime.Now()
	ttl := rcxScaledProofTTL(rcxProofTTLMinutes*time.Minute, 2)
	if engine.ledger.OpenProven("current", engine.envKey, now, ttl) {
		t.Fatal("a stall should already have cleared the open proof")
	}
	miss := func() {
		engine.applyProbeResult(rcxEvent{Gen: engine.probeGen, ConfigGen: engine.configGen, Results: []rcxProbeResult{
			{Node: "current", Role: rcxRoleOpen, Outcome: rcxProbeFail},
		}})
	}
	miss()
	if engine.ledger.Facts("current", engine.envKey, false, now, ttl).OpenWorld == rcxProofDisproven {
		t.Fatal("a stalled server was refuted on its very first incident miss")
	}
	miss()
	if engine.ledger.Facts("current", engine.envKey, false, now, ttl).OpenWorld != rcxProofDisproven {
		t.Fatal("a second consecutive incident miss must refute the stalled server")
	}
}

func TestHarvestMissKeepsAnyFreshlyProvenNode(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("current", "rival")
	engine := newTestEngine(runtime, "ru")
	engine.incumbent = "current"
	engine.since = runtime.Now().Add(-time.Hour)
	runtime.selected = "current"
	now := runtime.Now()
	ttl := rcxScaledProofTTL(rcxProofTTLMinutes*time.Minute, 2)
	engine.ledger.NoteProbe("current", engine.envKey, rcxRoleOpen, rcxProbeOK, 40, now)

	engine.handle(rcxEvent{Kind: rcxEventHarvested, Node: "current", DelayMs: 0})
	if !engine.ledger.OpenProven("current", engine.envKey, now, ttl) {
		t.Fatal("a lone health-check miss disproved the working incumbent")
	}

	// A freshly proven non-incumbent (yesterday's abandoned Sweden) must survive a
	// lone health-check miss too: only a reactive wave or the traffic detector kills.
	engine.ledger.NoteProbe("rival", engine.envKey, rcxRoleOpen, rcxProbeOK, 40, now)
	engine.incumbent = "current"
	engine.handle(rcxEvent{Kind: rcxEventHarvested, Node: "rival", DelayMs: 0})
	if !engine.ledger.OpenProven("rival", engine.envKey, now, ttl) {
		t.Fatal("a lone health-check miss disproved a freshly proven challenger")
	}
}

func TestQuarantineSweepSparesTheProvenIncumbent(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("current", "rival")
	engine := newTestEngine(runtime, "ru")
	engine.incumbent = "current"
	runtime.selected = "current"
	now := runtime.Now()
	ttl := rcxScaledProofTTL(rcxProofTTLMinutes*time.Minute, 2)

	// Both are open only by live traffic, so a marker sweep finds no evidence.
	engine.ledger.NoteTrafficProgress("current", engine.envKey, true, now)
	engine.ledger.NoteTrafficProgress("rival", engine.envKey, true, now)
	engine.snapshot.Global, engine.snapshot.Envs = engine.ledger.Export()

	markerID := rcxMarkerID(rcxRoleOpen, engine.cfg.OpenMarkers[0])
	engine.recomputeMarkerRole(markerID, now)

	if !engine.ledger.OpenProven("current", engine.envKey, now, ttl) {
		t.Fatal("a quarantine sweep stripped the proven incumbent's open proof")
	}
	if engine.ledger.OpenProven("rival", engine.envKey, now, ttl) {
		t.Fatal("a non-incumbent with no marker evidence should be recomputed to unknown")
	}
}

func TestLiveTrafficWithoutOpenProofStillProbesUnderCensorship(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("carrier", "proven")
	engine := newTestEngine(runtime, "ru")
	now := runtime.Now()
	// Both carry live traffic; only "proven" has demonstrated it opens the marker.
	engine.ledger.NoteTrafficProgress("carrier", engine.envKey, false, now)
	engine.ledger.NoteTrafficProgress("proven", engine.envKey, true, now)

	inPool := func(wave []rcxProbeNode, name string) bool {
		for _, node := range wave {
			if node.Name == name {
				return true
			}
		}
		return false
	}
	wave := engine.planWave(engine.candidates(runtime.members), runtime.members, rcxWaveRoutine)
	if !inPool(wave, "carrier") {
		t.Fatal("a live node that never opened the censored world skipped its probe")
	}
	if inPool(wave, "proven") {
		t.Fatal("a proven-open live node still paid for a routine probe")
	}
}

func TestStallHoldsAnIncumbentThatStillAnswers(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("current", "rival")
	engine := newTestEngine(runtime, "ru")
	engine.incumbent, runtime.selected = "current", "current"
	engine.since = runtime.Now().Add(-time.Hour)
	engine.candidates(runtime.members)
	engine.ledger.NoteProbe("rival", engine.envKey, rcxRoleOpen, rcxProbeOK, 40, runtime.Now())
	engine.ledger.NoteIncumbentStalled("current", engine.envKey, runtime.Now())
	engine.probing, engine.probeKind = true, rcxWaveIncident
	engine.probeStarted = map[string]struct{}{}
	engine.probeResults = nil

	engine.applyProbeResult(rcxEvent{Gen: engine.probeGen, ConfigGen: engine.configGen, Results: []rcxProbeResult{
		{Node: "rival", Role: rcxRoleOpen, Outcome: rcxProbeOK, DelayMs: 40},
	}})

	if runtime.selected != "current" {
		t.Fatalf("selected = %q, want a stalled-but-unrefuted incumbent held, not walked off on an idle pause", runtime.selected)
	}
}
