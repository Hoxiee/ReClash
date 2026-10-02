package rcx

import (
	"testing"
	"time"
)

func hostCheckEngine(t *testing.T) (*rcxEngine, *fakeRuntime) {
	t.Helper()
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("current", "standby")
	runtime.results["current"] = rcxProbeResult{Outcome: rcxProbeOK, DelayMs: 50}
	runtime.results["standby"] = rcxProbeResult{Outcome: rcxProbeOK, DelayMs: 500}
	engine := newTestEngine(runtime, "ru")
	t.Cleanup(engine.supersedeProbe)
	t.Cleanup(engine.supersedeReach)
	t.Cleanup(engine.supersedeWake)
	engine.incumbent, runtime.selected = "current", "current"
	engine.pendingGrant, engine.pendingHandoff = false, false
	engine.since = runtime.Now().Add(-time.Hour)
	engine.syncIdentity(runtime.members)
	engine.ledger.NoteProbe("current", engine.envKey, rcxRoleOpen, rcxProbeOK, 50, runtime.Now())
	engine.ledger.NoteProbe("standby", engine.envKey, rcxRoleOpen, rcxProbeOK, 500, runtime.Now())
	runtime.advance(10 * time.Second)
	runtime.members[0].HostDead, runtime.members[0].HostAt = true, runtime.Now()
	return engine, runtime
}

func finishHostCheck(t *testing.T, engine *rcxEngine) {
	t.Helper()
	gen := engine.probeGen
	timer := time.NewTimer(time.Second)
	defer timer.Stop()
	for {
		select {
		case event := <-engine.events:
			engine.handle(event)
			if event.Kind == rcxEventProbeResults && event.Gen == gen {
				return
			}
		case <-timer.C:
			t.Fatal("host confirmation did not finish")
		}
	}
}

func TestHostMissVerifiesBeforeReplacingAProvenIncumbent(t *testing.T) {
	engine, runtime := hostCheckEngine(t)
	engine.rescueSeen["current"] = struct{}{}
	engine.rescueExhausted, engine.rescueAt = true, runtime.Now()
	engine.handle(rcxEvent{Kind: rcxEventHarvested, Node: "current", DelayMs: 0})
	engine.reconsider()

	if runtime.selected != "current" || len(runtime.selects) != 0 || !engine.probing || engine.probeKind != rcxWaveConfirm {
		t.Fatalf("selected = %q, switches = %v, probing = %v, kind = %v", runtime.selected, runtime.selects, engine.probing, engine.probeKind)
	}
	if engine.candidates(runtime.members)[0].HostDead || engine.ledger.FailStreak("current", engine.envKey) != 0 {
		t.Fatal("one host miss overrode a fresh route proof")
	}
	if runtime.lastStatus().Reason != string(rcxReasonMeasuring) {
		t.Fatalf("reason = %q, want measuring", runtime.lastStatus().Reason)
	}
	gen, retryAt := engine.probeGen, engine.hostCheck.retryAt
	runtime.advance(time.Second)
	runtime.members[0].HostAt = runtime.Now()
	engine.reconsider()
	if engine.probeGen != gen || engine.hostCheck.retryAt != retryAt {
		t.Fatal("another host miss restarted an in-flight confirmation")
	}
}

func TestHostConfirmationKeepsSuccessAndReplacesConfirmedFailure(t *testing.T) {
	for _, outcome := range []rcxProbeOutcome{rcxProbeOK, rcxProbeFail} {
		t.Run(map[rcxProbeOutcome]string{rcxProbeOK: "success", rcxProbeFail: "confirmed failure"}[outcome], func(t *testing.T) {
			engine, runtime := hostCheckEngine(t)
			runtime.results["current"] = rcxProbeResult{Outcome: outcome, DelayMs: 50}
			engine.reconsider()
			runtime.advance(time.Second)
			finishHostCheck(t, engine)

			if outcome == rcxProbeOK {
				if runtime.selected != "current" || len(runtime.selects) != 0 || engine.hostCheck.pending {
					t.Fatalf("selected = %q, switches = %v, pending = %v", runtime.selected, runtime.selects, engine.hostCheck.pending)
				}
				return
			}
			if runtime.selected != "standby" || len(runtime.selects) != 1 {
				t.Fatalf("selected = %q, switches = %v, want one confirmed failover", runtime.selected, runtime.selects)
			}
			if len(engine.history) != 1 || engine.history[0].Reason != string(rcxReasonIncumbentDead) {
				t.Fatalf("history = %+v, want confirmed incumbent-dead", engine.history)
			}
		})
	}
}

func TestConfirmedHostFailureDoesNotHideBehindOldDomesticProof(t *testing.T) {
	engine, runtime := hostCheckEngine(t)
	engine.terrain.observe(rcxTerrainWhitelist, runtime.Now())
	engine.ledger.NoteProbe("current", engine.envKey, rcxRoleDomestic, rcxProbeOK, 40, runtime.Now().Add(-time.Second))
	engine.reconsider()
	runtime.advance(time.Second)
	engine.handle(rcxEvent{Kind: rcxEventProbeResult, Gen: engine.probeGen, ConfigGen: engine.configGen,
		Results: []rcxProbeResult{{Node: "current", Key: "current", Role: rcxRoleOpen, Outcome: rcxProbeFail,
			Attempts: []rcxMarkerAttempt{{ID: engine.markerIDs(rcxRoleOpen, runtime.Now())[0], Outcome: rcxProbeFail}}}}})
	if engine.hostCheck.pending || !engine.hostCheck.confirmed || !engine.candidates(runtime.members)[0].HostDead {
		t.Fatalf("host check = %+v: a confirmed host failure must not remain masked by old domestic proof", engine.hostCheck)
	}
	engine.reconsider()
	if runtime.selected != "standby" {
		t.Fatal("old domestic proof kept a twice-failed route selected")
	}
}

func TestHostMissDoesNotBecomeDeathWhenPayloadGoesIdle(t *testing.T) {
	engine, runtime := hostCheckEngine(t)
	engine.ledger.NoteTrafficProgress("current", engine.envKey, true, runtime.Now().Add(-time.Second))
	engine.reconsider()
	if runtime.selected != "current" || engine.probing {
		t.Fatal("a host miss disturbed recent working traffic")
	}
	at := runtime.members[0].HostAt
	runtime.advance(time.Minute)
	engine.reconsider()
	if runtime.selected != "current" || !engine.probing || engine.probeKind != rcxWaveConfirm || runtime.members[0].HostAt != at {
		t.Fatalf("selected = %q, probing = %v, kind = %v: an old miss must be verified, not revived as death", runtime.selected, engine.probing, engine.probeKind)
	}
}

func TestLaterPositiveEvidencePermanentlySupersedesAHostMiss(t *testing.T) {
	for _, payload := range []bool{false, true} {
		t.Run(map[bool]string{false: "probe", true: "payload"}[payload], func(t *testing.T) {
			engine, runtime := hostCheckEngine(t)
			runtime.advance(time.Second)
			if payload {
				engine.ledger.NoteTrafficProgress("current", engine.envKey, false, runtime.Now())
			} else {
				engine.ledger.NoteProbe("current", engine.envKey, rcxRoleOpen, rcxProbeOK, 50, runtime.Now())
			}
			runtime.advance(engine.ledger.ProofTTL() + time.Minute)
			if engine.candidates(runtime.members)[0].HostDead {
				t.Fatal("a later positive stopped superseding the same old host failure after its freshness expired")
			}
		})
	}
}

func TestInconclusiveHostCheckWaitsBeforeRetrying(t *testing.T) {
	engine, runtime := hostCheckEngine(t)
	runtime.testRelease = make(chan struct{})
	engine.reconsider()
	cancel := engine.probeCancel
	defer cancel()
	gen := engine.probeGen
	engine.handle(rcxEvent{Kind: rcxEventProbeResult, Gen: gen, ConfigGen: engine.configGen,
		Results: []rcxProbeResult{{Node: "current", Key: "current", Role: rcxRoleOpen, Outcome: rcxProbeOverloaded}}})
	engine.handle(rcxEvent{Kind: rcxEventProbeResults, Gen: gen, ConfigGen: engine.configGen})
	if runtime.selected != "current" || engine.probing || !engine.hostCheck.pending || engine.probeGen != gen {
		t.Fatalf("selected = %q, probing = %v, pending = %v: inconclusive confirmation must hold without a rescue cascade", runtime.selected, engine.probing, engine.hostCheck.pending)
	}
	runtime.advance(rcxTickInterval - time.Second)
	engine.watchIncumbent()
	if engine.probing {
		t.Fatal("the same miss bypassed the retry interval")
	}
	runtime.advance(time.Second)
	engine.watchIncumbent()
	if !engine.probing || engine.probeKind != rcxWaveConfirm || engine.probeGen == gen {
		t.Fatal("an inconclusive suspicion never retried after its bounded wait")
	}
}

func TestHostConfirmationRespectsPowerTerrainAndBudget(t *testing.T) {
	for _, gate := range []string{"screen off", "suspended", "offline", "budget"} {
		t.Run(gate, func(t *testing.T) {
			engine, runtime := hostCheckEngine(t)
			switch gate {
			case "screen off":
				engine.screenOff = true
			case "suspended":
				engine.suspended = true
			case "offline":
				engine.terrain.observe(rcxTerrainOffline, runtime.Now())
			case "budget":
				engine.budget.Take(rcxProbeBudgetCap, runtime.Now())
			}
			engine.reconsider()
			if engine.probing || len(runtime.selects) != 0 {
				t.Fatalf("probing = %v, switches = %v through %s", engine.probing, runtime.selects, gate)
			}
		})
	}
}

func TestScreenOffInvalidatesInFlightHostConfirmation(t *testing.T) {
	engine, runtime := hostCheckEngine(t)
	engine.reconsider()
	gen := engine.probeGen
	engine.applyScreenOff(true)
	engine.handle(rcxEvent{Kind: rcxEventProbeResult, Gen: gen, ConfigGen: engine.configGen,
		Results: []rcxProbeResult{{Node: "current", Role: rcxRoleOpen, Outcome: rcxProbeFail}}})
	if engine.probing || runtime.selected != "current" || !engine.freshlyOpenProven("current", runtime.Now()) {
		t.Fatal("a pre-screen-off host confirmation still refuted the incumbent")
	}
}
