package main

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
	for _, node := range []string{"a", "b", "c"} {
		engine.ledger.NoteProbe(node, engine.envKey, rcxRoleOpen, rcxProbeOK, 40, runtime.Now())
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
		{Name: "a", ID: "a-id", Provider: "provider-a", Transport: "ws", Port: 443},
		{Name: "b", ID: "b-id", Provider: "provider-a", Transport: "grpc", Port: 443},
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
