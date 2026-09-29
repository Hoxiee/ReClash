package rcx

import (
	"testing"
	"time"
)

func TestWhitelistReprobeBackoffCurve(t *testing.T) {
	runtime := newFakeRuntime()
	engine := newTestEngine(runtime, "ru")
	engine.terrain.observe(rcxTerrainWhitelist, runtime.Now())

	cases := []struct {
		rounds int
		want   time.Duration
	}{
		{0, rcxReachUrgent},
		{rcxReachSteady - 1, rcxReachUrgent},
		{rcxReachSteady, 2 * rcxReachUrgent},
		{rcxReachSteady + 1, 3 * rcxReachUrgent},
		{rcxReachSteadyCap, rcxReachBackoffCap},
	}
	for _, tc := range cases {
		engine.reachStableRounds = tc.rounds
		if got := engine.reachInterval(); got != tc.want {
			t.Errorf("rounds=%d interval=%v, want %v", tc.rounds, got, tc.want)
		}
	}
	if engine.reachInterval() > rcxReachBackoffCap {
		t.Errorf("interval %v climbed past the cap", engine.reachInterval())
	}
}

func TestWhitelistReprobeRelaxesOnlyWhileStable(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("current")
	runtime.selected = "current"
	engine := newTestEngine(runtime, "ru")
	engine.incumbent = "current"
	engine.validated = true
	engine.ledger.NoteProbe(
		engine.key("current"), engine.envKey, rcxRoleOpen, rcxProbeOK, 40, runtime.Now(),
	)

	// Transit reaches the anycast IP but the censored SNI is cut: an SNI-DPI net.
	engine.reachF, engine.reachD, engine.reachS = rcxProbeOK, rcxProbeOK, rcxProbeFail
	for i := 0; i < rcxReachSteadyCap+4; i++ {
		engine.classifyTerrain(true)
	}
	if engine.terrain.terrain != rcxTerrainWhitelist {
		t.Fatalf("terrain = %v, want a confirmed whitelist", engine.terrain.terrain)
	}
	if engine.reachStableRounds != rcxReachSteadyCap {
		t.Errorf("streak = %d, want it pinned at the cap %d", engine.reachStableRounds, rcxReachSteadyCap)
	}
	if got := engine.reachInterval(); got != rcxReachBackoffCap {
		t.Errorf("interval = %v, want the relaxed cap after a long stable run", got)
	}

	// An inconclusive round is not a re-confirmation: it drops back to urgent.
	engine.classifyTerrain(false)
	if engine.reachStableRounds != 0 {
		t.Errorf("streak = %d after a blind round, want it reset", engine.reachStableRounds)
	}

	// Re-confirm the whitelist, then flip to Normal: a measured non-whitelist
	// round zeroes the streak so the urgent cadence returns immediately.
	for i := 0; i < rcxReachSteady+2; i++ {
		engine.classifyTerrain(true)
	}
	if engine.reachStableRounds < rcxReachSteady {
		t.Fatalf("streak = %d, want it rebuilt above the grace", engine.reachStableRounds)
	}
	engine.reachS = rcxProbeOK
	engine.classifyTerrain(true)
	if engine.reachStableRounds != 0 {
		t.Errorf("streak = %d after leaving the whitelist, want it reset", engine.reachStableRounds)
	}
}

func TestWhitelistReprobeStaysUrgentWithoutAProvenIncumbent(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("current")
	runtime.selected = "current"
	engine := newTestEngine(runtime, "ru")
	engine.incumbent = "current"
	engine.validated = true

	engine.reachF, engine.reachD, engine.reachS = rcxProbeOK, rcxProbeOK, rcxProbeFail
	for i := 0; i < rcxReachSteadyCap+4; i++ {
		engine.classifyTerrain(true)
	}
	if engine.terrain.terrain != rcxTerrainWhitelist {
		t.Fatalf("terrain = %v, want a confirmed whitelist", engine.terrain.terrain)
	}
	if engine.reachStableRounds != 0 {
		t.Errorf("streak = %d, want no backoff while the incumbent is unproven", engine.reachStableRounds)
	}
	if got := engine.reachInterval(); got != rcxReachUrgent {
		t.Errorf("interval = %v, want the urgent cadence without a proven incumbent", got)
	}
}
