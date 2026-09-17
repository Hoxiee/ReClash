package main

import (
	"fmt"
	"testing"
	"time"
)

func TestDiscoveryPreservesProviderOrderAcrossBatches(t *testing.T) {
	runtime := newFakeRuntime()
	names := make([]string, 24)
	for i := range names {
		names[i] = fmt.Sprintf("n%02d", i)
	}
	runtime.members = foreignMembers(names...)
	engine := newTestEngine(runtime, "ru")
	engine.incumbent = names[0]
	runtime.selected = names[0]
	first := engine.discoveryNodes(runtime.members, 8)
	if len(first) != 8 {
		t.Fatalf("first=%d", len(first))
	}
	for i, node := range first {
		if node.Name != names[i] {
			t.Fatalf("first[%d]=%s", i, node.Name)
		}
		engine.markDiscoveryResult(rcxProbeResult{Node: node.Name, Key: node.Key, Outcome: rcxProbeOK}, runtime.Now())
	}
	second := engine.discoveryNodes(runtime.members, 8)
	for i, node := range second {
		if node.Name != names[i+8] {
			t.Fatalf("second[%d]=%s", i, node.Name)
		}
	}
}

func TestDiscoveryCapDoesNotDependOnWaveWidth(t *testing.T) {
	runtime := newFakeRuntime()
	names := make([]string, 80)
	for i := range names {
		names[i] = fmt.Sprintf("n%02d", i)
	}
	runtime.members = foreignMembers(names...)
	engine := newTestEngine(runtime, "ru")
	engine.incumbent = names[0]
	engine.cfg.WaveWidth = 4
	d := engine.discoveryState()
	for d.Attempts < rcxDiscoveryLimit {
		wave := engine.discoveryNodes(runtime.members, min(engine.cfg.WaveWidth, rcxDiscoveryLimit-d.Attempts))
		if len(wave) == 0 {
			t.Fatal("discovery stopped before cap")
		}
		d.Attempts += len(wave)
		for _, node := range wave {
			engine.markDiscoveryResult(rcxProbeResult{Node: node.Name, Key: node.Key, Outcome: rcxProbeOK}, runtime.Now())
		}
	}
	if d.Attempts != 48 {
		t.Fatalf("attempts=%d", d.Attempts)
	}
	if engine.discoveryWarm(d, runtime.Now()) {
		t.Fatal("episode remained warm past cap")
	}
}

func TestRecoverySuccessQueuesDiscoveryContinuation(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("dead", "fallback", "better")
	engine := newTestEngine(runtime, "ru")
	engine.pendingGrant = false
	engine.incumbent = "dead"
	runtime.selected = "dead"
	engine.probing = true
	engine.probeKind = rcxWaveIncident
	engine.probeStarted = map[string]struct{}{}
	engine.applyProbeResult(rcxEvent{Results: []rcxProbeResult{{Node: "dead", Role: rcxRoleOpen, Outcome: rcxProbeFail}}})
	engine.applyProbeResult(rcxEvent{Results: []rcxProbeResult{{Node: "fallback", Role: rcxRoleOpen, Outcome: rcxProbeOK, DelayMs: 90}}})
	if !engine.probeDecisionClosed {
		t.Fatal("recovery did not close")
	}
	engine.finishProbe()
	if !engine.probing || engine.probeKind != rcxWaveDiscover {
		t.Fatalf("kind=%v probing=%v", engine.probeKind, engine.probing)
	}
}

func TestInlineProtocolFailuresNeverOpenSharedCircuit(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("a", "b", "c")
	for i := range runtime.members {
		runtime.members[i].Provider = "inline:Vless"
		runtime.members[i].Ingress = fmt.Sprintf("%d.example", i)
	}
	engine := newTestEngine(runtime, "ru")
	engine.noteProviderNodeFailure("a", runtime.Now())
	engine.noteProviderNodeFailure("b", runtime.Now())
	if engine.providerCircuitOpen("inline:Vless", "c", runtime.Now()) {
		t.Fatal("synthetic provider became failure domain")
	}
}

func TestAliasesShareProbeIdentityButKeepPreferredName(t *testing.T) {
	nodes := []rcxProbeNode{{Name: "header", Key: "same"}, {Name: "real", Key: "same"}, {Name: "other", Key: "other"}}
	got := rcxUniqueProbeNodes(nodes, "real")
	if len(got) != 2 || got[0].Name != "real" {
		t.Fatalf("nodes=%v", got)
	}
}

func TestDiscoveryPausesWhenScreenOff(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("a", "b")
	engine := newTestEngine(runtime, "ru")
	engine.incumbent = "a"
	engine.screenOff = true
	if engine.startImprovement(false) {
		t.Fatal("discovery started off-screen")
	}
}

func reserveTestReceipt(t *testing.T, engine *rcxEngine, gen uint32, paid int, at time.Time, receipt rcxWaveReceipt) {
	t.Helper()
	if got := engine.budget.Take(paid, at); got != paid {
		t.Fatalf("budget take = %d, want %d", got, paid)
	}
	if engine.receipts == nil {
		engine.receipts = map[uint32]rcxWaveReceipt{}
	}
	receipt.Paid = paid
	receipt.ReservedAt = at
	engine.receipts[gen] = receipt
}

func TestWaveReceiptRefundsUndispatchedBudgetExactlyOnce(t *testing.T) {
	runtime := newFakeRuntime()
	engine := newTestEngine(runtime, "ru")
	reservedAt := runtime.Now()
	reserveTestReceipt(t, engine, 7, 4, reservedAt, rcxWaveReceipt{Environment: engine.envKey})

	engine.settleWaveReceipt(7, 1)
	engine.settleWaveReceipt(7, 1)

	if got := engine.budget.Remaining(runtime.Now()); got != rcxProbeBudgetCap-1 {
		t.Fatalf("remaining = %d, want one dispatched attempt charged", got)
	}
}

func TestSupersededReceiptRefundsOnlyItsOwnReservation(t *testing.T) {
	runtime := newFakeRuntime()
	engine := newTestEngine(runtime, "ru")
	oldAt := runtime.Now()
	reserveTestReceipt(t, engine, 11, 3, oldAt, rcxWaveReceipt{Environment: engine.envKey})
	runtime.advance(time.Second)
	newAt := runtime.Now()
	reserveTestReceipt(t, engine, 12, 2, newAt, rcxWaveReceipt{Environment: engine.envKey})

	engine.settleWaveReceipt(11, 1)

	if got := engine.budget.Remaining(runtime.Now()); got != rcxProbeBudgetCap-3 {
		t.Fatalf("remaining = %d, want old dispatched plus new reservation charged", got)
	}
	if _, ok := engine.receipts[12]; !ok {
		t.Fatal("old completion removed the new receipt")
	}
}

func TestDiscoveryAccountingCountsOnlyDispatchedNodes(t *testing.T) {
	runtime := newFakeRuntime()
	engine := newTestEngine(runtime, "ru")
	reservedAt := runtime.Now()
	reserveTestReceipt(t, engine, 3, 5, reservedAt, rcxWaveReceipt{
		Environment: engine.envKey,
		Discovery:   true,
	})

	engine.settleWaveReceipt(3, 2)

	d := engine.discoveryState()
	if d.Attempts != 2 || len(engine.discoverySpent) != 2 {
		t.Fatalf("attempts/spent = %d/%d, want 2/2", d.Attempts, len(engine.discoverySpent))
	}
	if got := engine.budget.Remaining(runtime.Now()); got != rcxProbeBudgetCap-2 {
		t.Fatalf("remaining = %d, want two dispatched attempts charged", got)
	}
}

func TestOldEnvironmentReceiptDoesNotAdvanceCurrentDiscovery(t *testing.T) {
	runtime := newFakeRuntime()
	engine := newTestEngine(runtime, "ru")
	reservedAt := runtime.Now()
	reserveTestReceipt(t, engine, 4, 2, reservedAt, rcxWaveReceipt{
		Environment: "w:Old",
		Discovery:   true,
	})

	engine.settleWaveReceipt(4, 1)

	if got := engine.discoveryState().Attempts; got != 0 {
		t.Fatalf("current discovery attempts = %d, want 0", got)
	}
	if len(engine.discoverySpent) != 0 {
		t.Fatalf("current discovery spent = %d, want 0", len(engine.discoverySpent))
	}
	if got := engine.budget.Remaining(runtime.Now()); got != rcxProbeBudgetCap-1 {
		t.Fatalf("remaining = %d, want old dispatched attempt charged", got)
	}
}

func TestQualityAccountingCountsOnlyDispatchedNodes(t *testing.T) {
	runtime := newFakeRuntime()
	engine := newTestEngine(runtime, "ru")
	reservedAt := runtime.Now()
	reserveTestReceipt(t, engine, 5, 2, reservedAt, rcxWaveReceipt{
		Environment: engine.envKey,
		Quality:     true,
	})

	engine.settleWaveReceipt(5, 1)

	if got := engine.discoveryState().Confirmations; got != 1 {
		t.Fatalf("confirmations = %d, want one dispatched node", got)
	}
}

func TestQualityConfirmationNeedsSeparatedRounds(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("slow", "fast")
	engine := newTestEngine(runtime, "ru")
	engine.incumbent = "slow"
	engine.envSince = runtime.Now().Add(-time.Hour)
	marker := rcxMarkerID(rcxRoleOpen, engine.cfg.OpenMarkers[0])
	engine.quality = rcxQualityCheck{From: "slow", To: "fast", Marker: marker, Env: engine.envKey, Epoch: engine.envSince.UnixNano(), Config: engine.configGen}
	engine.probeResults = []rcxProbeResult{{Key: "slow", Role: rcxRoleOpen, Fingerprint: marker, Outcome: rcxProbeOK, DelayMs: 249}, {Key: "fast", Role: rcxRoleOpen, Fingerprint: marker, Outcome: rcxProbeOK, DelayMs: 69}}
	engine.finishQuality(runtime.Now())
	if engine.quality.Rounds != 1 {
		t.Fatalf("rounds=%d", engine.quality.Rounds)
	}
	runtime.advance(5 * time.Second)
	engine.finishQuality(runtime.Now())
	if engine.quality.Rounds != 1 {
		t.Fatal("round counted before separation")
	}
	runtime.advance(5 * time.Second)
	engine.finishQuality(runtime.Now())
	if engine.quality.Rounds != 2 {
		t.Fatalf("rounds=%d", engine.quality.Rounds)
	}
}
