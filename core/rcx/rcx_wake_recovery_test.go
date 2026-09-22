package rcx

import (
	"testing"
	"time"
)

func TestWakeStartsWithoutFreshStandbyProof(t *testing.T) {
	for _, remembered := range []bool{false, true} {
		t.Run(map[bool]string{false: "no-standby", true: "expired-standby"}[remembered], func(t *testing.T) {
			runtime := newFakeRuntime()
			runtime.members = foreignMembers("current", "first", "last")
			engine := newTestEngine(runtime, "ru")
			engine.incumbent, runtime.selected = "current", "current"
			if remembered {
				armWakeStandby(engine, runtime, "current", "first")
				runtime.advance(7 * time.Hour)
			}
			engine.startWakeProbe()
			defer engine.supersedeWake()
			if !engine.wakePending || engine.wakeStandby != "first" {
				t.Fatalf("pending=%v standby=%q, want immediate ordered verification", engine.wakePending, engine.wakeStandby)
			}
		})
	}
}

func TestWakeMissingAlternativeIsNotSuccess(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("current", "standby")
	engine := newTestEngine(runtime, "ru")
	armWakeStandby(engine, runtime, "current", "standby")
	engine.startWakeProbe()
	defer engine.supersedeWake()
	defer engine.supersedeProbe()
	engine.applyWakeResults(rcxEvent{Gen: engine.wakeGen, ConfigGen: engine.configGen, Episode: engine.screenEpisode,
		Wake: []rcxWakeResult{{Node: "current", Outcome: rcxProbeFail}}})
	if runtime.selected != "current" {
		t.Fatal("missing standby result was treated as successful")
	}
}

func TestWakeTimeoutContinuesRecoveryImmediately(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("current", "standby", "next")
	engine := newTestEngine(runtime, "ru")
	armWakeStandby(engine, runtime, "current", "standby")
	engine.startWakeProbe()
	defer engine.supersedeWake()
	defer engine.supersedeProbe()
	engine.applyWakeResults(rcxEvent{Gen: engine.wakeGen, ConfigGen: engine.configGen, Episode: engine.screenEpisode,
		Wake: []rcxWakeResult{{Node: "current", Outcome: rcxProbeOverloaded}, {Node: "standby", Outcome: rcxProbeOverloaded}}})
	if runtime.selected != "current" || !engine.probing || !engine.recoveryWave() {
		t.Fatalf("selected=%q probing=%v kind=%v, want continued recovery without speculative switch", runtime.selected, engine.probing, engine.probeKind)
	}
}

func TestWakeVerifiedFailureCanReplacePinWithoutReturningToOldProof(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("current", "standby")
	engine := newTestEngine(runtime, "ru")
	armWakeStandby(engine, runtime, "current", "standby")
	engine.ledger.NoteProbe("current", engine.envKey, rcxRoleOpen, rcxProbeOK, 40, runtime.Now())
	engine.applyManualPick("current", true)
	runtime.advance(time.Minute)
	engine.startWakeProbe()
	defer engine.supersedeWake()
	defer engine.supersedeProbe()
	engine.applyWakeResults(rcxEvent{Gen: engine.wakeGen, ConfigGen: engine.configGen, Episode: engine.screenEpisode,
		Wake: []rcxWakeResult{{Node: "current", Outcome: rcxProbeFail}, {Node: "standby", Outcome: rcxProbeOK, DelayMs: 30}}})
	engine.reconsider()
	if runtime.selected != "standby" || engine.pin() != "current" {
		t.Fatalf("selected=%q pin=%q, want fallback with remembered pin", runtime.selected, engine.pin())
	}
}

func TestWakeLateFailureCannotOverrideLiveProgress(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("current", "standby")
	engine := newTestEngine(runtime, "ru")
	armWakeStandby(engine, runtime, "current", "standby")
	engine.startWakeProbe()
	defer engine.supersedeWake()
	defer engine.supersedeProbe()
	runtime.advance(time.Second)
	engine.ledger.NoteTrafficProgress("current", engine.envKey, true, runtime.Now())
	engine.applyWakeResults(rcxEvent{Gen: engine.wakeGen, ConfigGen: engine.configGen, Episode: engine.screenEpisode,
		Wake: []rcxWakeResult{{Node: "current", Outcome: rcxProbeFail}, {Node: "standby", Outcome: rcxProbeOK, DelayMs: 30}}})
	if runtime.selected != "current" {
		t.Fatal("late wake failure overruled live progress")
	}
}

func TestWakeVerifiesCurrentAfterBackgroundFailover(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("current")
	engine := newTestEngine(runtime, "ru")
	engine.incumbent, runtime.selected = "current", "current"
	engine.screenOff, engine.screenFailedOver = true, true
	engine.screenDead = "previous"
	engine.applyScreenOff(false)
	defer engine.supersedeWake()
	defer engine.supersedeReach()
	if !engine.wakePending || engine.wakeIncumbent != "current" {
		t.Fatal("background failover prevented wake verification of the new route")
	}
}

func TestWakeRejectsRefreshedRouteResults(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("current", "standby")
	engine := newTestEngine(runtime, "ru")
	armWakeStandby(engine, runtime, "current", "standby")
	engine.startWakeProbe()
	defer engine.supersedeWake()
	defer engine.supersedeProbe()
	gen := engine.wakeGen
	runtime.members[1].ID = "replacement"
	engine.applyWakeResults(rcxEvent{Gen: gen, ConfigGen: engine.configGen, Episode: engine.screenEpisode,
		Wake: []rcxWakeResult{{Node: "current", Outcome: rcxProbeFail}, {Node: "standby", Outcome: rcxProbeOK, DelayMs: 30}}})
	if runtime.selected != "current" || !engine.ledger.ProbeGoodAt("replacement", engine.envKey).IsZero() {
		t.Fatal("old route result selected or proved its replacement")
	}
}

func TestSuspendInvalidatesInFlightProbeAndWake(t *testing.T) {
	runtime := newFakeRuntime()
	engine := newTestEngine(runtime, "ru")
	engine.probing, engine.probeGen = true, 7
	engine.wakePending, engine.wakeGen = true, 9
	engine.applySuspend(true)
	if engine.probing || engine.wakePending || engine.probeGen == 7 || engine.wakeGen == 9 {
		t.Fatal("pre-suspend work can still deliver evidence after resume")
	}
}
