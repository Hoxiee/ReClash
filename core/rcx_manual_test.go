package main

import (
	"testing"
	"time"
)

func TestManualAssertReassertsTheActualSelector(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("old", "chosen")
	engine := newTestEngine(runtime, "ru")
	for _, node := range []string{"old", "chosen"} {
		engine.ledger.NoteProbe(node, engine.envKey, rcxRoleOpen, rcxProbeOK, 40, runtime.Now())
	}
	engine.incumbent, runtime.selected = "old", "chosen"
	engine.OnManualAsserted("chosen")
	engine.reconsider()
	engine.drainControl()
	defer engine.supersedeProbe()
	if engine.incumbent != "chosen" || runtime.selected != "chosen" || engine.pin() != "chosen" {
		t.Fatalf("incumbent=%q selector=%q pin=%q", engine.incumbent, runtime.selected, engine.pin())
	}
}

func TestManualPickRejectsEarlierWaveAndWake(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("chosen", "spare")
	engine := newTestEngine(runtime, "ru")
	engine.probeGen, engine.probing = 7, true
	engine.wakeGen, engine.wakePending = 9, true
	engine.wakeIncumbent, engine.wakeStandby = "chosen", "spare"
	engine.applyManualPick("chosen", true)
	defer engine.supersedeProbe()
	defer engine.supersedeWake()
	engine.handle(rcxEvent{Kind: rcxEventProbeResult, Gen: 7, Results: []rcxProbeResult{{Node: "chosen", Role: rcxRoleOpen, Outcome: rcxProbeFail}}})
	engine.handle(rcxEvent{Kind: rcxEventWakeResults, Gen: 9, ConfigGen: engine.configGen, Wake: []rcxWakeResult{{Node: "chosen", Outcome: rcxProbeFail}, {Node: "spare", Outcome: rcxProbeOK, DelayMs: 30}}})
	if engine.probeGen == 7 || engine.wakeGen == 9 || engine.ledger.FailStreak("chosen", engine.envKey) != 0 || runtime.selected != "chosen" {
		t.Fatalf("old work survived: probe=%d wake=%d fails=%d selected=%q", engine.probeGen, engine.wakeGen, engine.ledger.FailStreak("chosen", engine.envKey), runtime.selected)
	}
}

func TestManualPickRechecksOldFailureBeforeReplacingIt(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("chosen", "spare")
	engine := newTestEngine(runtime, "ru")
	rcxChargeFailures(engine.ledger, "chosen", engine.envKey, rcxTerrainNormal, runtime.Now(), 3)
	engine.ledger.NoteProbe("spare", engine.envKey, rcxRoleOpen, rcxProbeOK, 40, runtime.Now())
	runtime.advance(time.Minute)
	engine.applyManualPick("chosen", true)
	defer engine.supersedeProbe()
	if runtime.selected != "chosen" || !engine.probing {
		t.Fatalf("selected=%q probing=%v, want the explicit choice under verification", runtime.selected, engine.probing)
	}
	if engine.ledger.FailStreak("chosen", engine.envKey) == 0 || engine.ledger.Recurrence("chosen", engine.envKey, runtime.Now()) == 0 {
		t.Fatal("manual intent erased failure history")
	}
	if !engine.ledger.ProbeGoodAt("chosen", engine.envKey).IsZero() || !engine.ledger.TrafficAt("chosen", engine.envKey).IsZero() {
		t.Fatal("manual intent fabricated positive evidence")
	}
}

func TestManualPickUsesRefreshedIdentity(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("chosen", "spare")
	engine := newTestEngine(runtime, "ru")
	engine.syncIdentity(runtime.members)
	runtime.members[0].ID = "new-route"
	engine.applyManualPick("chosen", true)
	defer engine.supersedeProbe()
	if engine.pin() != "chosen" || engine.snapshot.Pins[engine.envKey] != "new-route" {
		t.Fatalf("pin=%q stored=%q", engine.pin(), engine.snapshot.Pins[engine.envKey])
	}
}

func TestOldHostFailureDoesNotOverrideNewOpenProof(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("current", "spare")
	runtime.members[0].HostDead, runtime.members[0].HostAt = true, runtime.Now()
	engine := newTestEngine(runtime, "ru")
	engine.incumbent, runtime.selected = "current", "current"
	engine.syncIdentity(runtime.members)
	engine.snapshot.Pins[engine.envKey] = "current"
	runtime.advance(time.Second)
	engine.ledger.NoteProbe("current", engine.envKey, rcxRoleOpen, rcxProbeOK, 40, runtime.Now())
	engine.ledger.NoteProbe("spare", engine.envKey, rcxRoleOpen, rcxProbeOK, 30, runtime.Now())
	engine.reconsider()
	defer engine.supersedeProbe()
	if runtime.selected != "current" {
		t.Fatal("old host failure overrode a newer successful route check")
	}
}

func TestRecoveryUsesAnAlreadyAnsweredAlternativeWhenCurrentFails(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("current", "spare")
	engine := newTestEngine(runtime, "ru")
	engine.incumbent, runtime.selected = "current", "current"
	engine.probeKind, engine.probing = rcxWaveIncident, true
	engine.ledger.NoteProbe("current", engine.envKey, rcxRoleOpen, rcxProbeOK, 40, runtime.Now())
	engine.applyProbeResult(rcxEvent{Results: []rcxProbeResult{{Node: "spare", Role: rcxRoleOpen, Outcome: rcxProbeOK, DelayMs: 30}}})
	if runtime.selected != "current" {
		t.Fatal("alternative success alone replaced the incumbent")
	}
	engine.applyProbeResult(rcxEvent{Results: []rcxProbeResult{{Node: "current", Role: rcxRoleOpen, Outcome: rcxProbeFail}}})
	if runtime.selected != "spare" || !engine.probeDecisionClosed {
		t.Fatalf("selected=%q closed=%v, waited for the rest of the wave despite a verified alternative", runtime.selected, engine.probeDecisionClosed)
	}
}

func TestRecoveryCanReplaceTrafficThatStoppedBeforeTheWave(t *testing.T) {
	runtime := newFakeRuntime()
	engine := newTestEngine(runtime, "ru")
	engine.incumbent = "current"
	engine.ledger.NoteTrafficProgress("current", engine.envKey, true, runtime.Now())
	runtime.advance(time.Second)
	engine.probeLaunchedAt = runtime.Now()
	engine.probeKind = rcxWaveIncident
	engine.probeResults = []rcxProbeResult{{Node: "current", Role: rcxRoleOpen, Outcome: rcxProbeFail}}
	if !engine.recoveryCanReplace(runtime.Now()) {
		t.Fatal("traffic predating the failed check prevented recovery")
	}
}

func TestRecoveryKeepsIncumbentWithFreshLiveProgress(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("current", "spare")
	engine := newTestEngine(runtime, "ru")
	engine.incumbent, runtime.selected = "current", "current"
	engine.probeKind = rcxWaveIncident
	engine.probeResults = []rcxProbeResult{{Node: "current", Role: rcxRoleOpen, Outcome: rcxProbeFail}}
	engine.ledger.NoteTrafficProgress("current", engine.envKey, true, runtime.Now())
	if engine.recoveryCanReplace(runtime.Now()) {
		t.Fatal("a synthetic failure overruled fresh live traffic")
	}
}
