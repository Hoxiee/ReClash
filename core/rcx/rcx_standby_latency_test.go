package rcx

import (
	"reflect"
	"testing"
	"time"
)

func standbyLatencyEngine(t *testing.T) (*rcxEngine, *fakeRuntime) {
	t.Helper()
	runtime := newFakeRuntime()
	runtime.members = []rcxMember{
		{Name: "current", Provider: "current", Transport: "ws", SupportsUDP: true},
		{Name: "fast-a", Provider: "near", Transport: "ws", SupportsUDP: true},
		{Name: "fast-b", Provider: "near", Transport: "ws", SupportsUDP: true},
		{Name: "fast-c", Provider: "near", Transport: "ws", SupportsUDP: true},
		{Name: "slow-a", Provider: "far-a", Transport: "grpc", SupportsUDP: true},
		{Name: "slow-b", Provider: "far-b", Transport: "tcp", SupportsUDP: true},
	}
	engine := newTestEngine(runtime, "ru")
	engine.incumbent, runtime.selected = "current", "current"
	engine.pendingGrant = false
	marker := rcxMarkerID(rcxRoleOpen, engine.cfg.OpenMarkers[0])
	for index, delay := range []int{50, 70, 72, 74, 320, 350} {
		key := runtime.members[index].key()
		engine.ledger.SetOrigin(key, "NL", rcxOriginForeign)
		engine.ledger.NoteProbe(key, engine.envKey, rcxRoleOpen, rcxProbeOK, delay, runtime.Now())
		engine.ledger.NoteQualitySample(key, engine.envKey, marker, engine.qualityEpoch(), delay, runtime.Now())
		if got := engine.comparableMedian(key, runtime.Now(), engine.ledger.ProofTTL()); got != delay {
			t.Fatalf("%s median = %d, want %d", key, got, delay)
		}
	}
	return engine, runtime
}

func TestStandbyDiversityDoesNotReplaceFastPeersWithSlowProviders(t *testing.T) {
	engine, runtime := standbyLatencyEngine(t)
	input := rcxDecisionInput{
		Terrain: rcxTerrainNormal, Incumbent: engine.incumbent,
		Candidates: engine.candidates(runtime.members), Policy: engine.cfg.policy(), Now: runtime.Now(),
	}
	engine.rebuildStandbys(rcxRank(input))
	if got, want := engine.snapshot.Standbys[engine.envKey], []string{"fast-a", "fast-b", "fast-c"}; !reflect.DeepEqual(got, want) {
		t.Fatalf("standbys = %v, want %v instead of 320ms/350ms diversity", got, want)
	}
}

func TestWakeStandbyFindsAFasterProvenNodeOutsideOldMemory(t *testing.T) {
	engine, runtime := standbyLatencyEngine(t)
	engine.candidates(runtime.members)
	engine.snapshot.Standbys[engine.envKey] = []string{"slow-a", "slow-b"}
	if got := engine.selectWakeStandby(runtime.Now()); got != "fast-a" {
		t.Fatalf("standby = %q, want the current best proven peer rather than a stale remembered pool", got)
	}
}

func TestRecoveryWaveDoesNotPutSlowMemoryBeforeFastProof(t *testing.T) {
	for _, rememberFast := range []bool{false, true} {
		t.Run(map[bool]string{false: "outside memory", true: "behind slow memory"}[rememberFast], func(t *testing.T) {
			engine, runtime := standbyLatencyEngine(t)
			engine.cfg.WaveWidth = 2
			engine.snapshot.Standbys[engine.envKey] = []string{"slow-a"}
			if rememberFast {
				engine.snapshot.Standbys[engine.envKey] = append(engine.snapshot.Standbys[engine.envKey], "fast-a")
			}
			runtime.members[4].HostMs, runtime.members[4].HostAt = 320, runtime.Now()
			wave := engine.planWave(engine.candidates(runtime.members), runtime.members, rcxWaveIncident)
			if len(wave) != 2 || wave[0].Name != "current" || wave[1].Name != "fast-a" {
				t.Fatalf("wave = %v, want incumbent verification followed by the 70ms peer", wave)
			}
		})
	}
}

func TestRecoveryWaveRetainsIncumbentAndPinPriority(t *testing.T) {
	engine, runtime := standbyLatencyEngine(t)
	engine.cfg.WaveWidth = 3
	engine.snapshot.Pins[engine.envKey] = "slow-a"
	wave := engine.planWave(engine.candidates(runtime.members), runtime.members, rcxWaveIncident)
	if len(wave) != 3 || wave[0].Name != "current" || wave[1].Name != "slow-a" || wave[2].Name != "fast-a" {
		t.Fatalf("wave = %v, want incumbent, explicit pin, then the fastest proven peer", wave)
	}
}

func TestRecoveryWaveDoesNotConfuseEntryPingWithProvenLatency(t *testing.T) {
	engine, runtime := standbyLatencyEngine(t)
	runtime.members = append(runtime.members, rcxMember{
		Name: "entry-only", Provider: "entry", HostMs: 10, HostAt: runtime.Now(), SupportsUDP: true,
	})
	engine.cfg.WaveWidth = 2
	engine.snapshot.Standbys[engine.envKey] = []string{"entry-only"}
	wave := engine.planWave(engine.candidates(runtime.members), runtime.members, rcxWaveIncident)
	if len(wave) != 2 || wave[0].Name != "current" || wave[1].Name != "fast-a" {
		t.Fatalf("wave = %v, want the proven route before an unverified 10ms entry", wave)
	}
}

func TestStandbyDiversityKeepsMeasuredPeersAheadOfUnknownDelays(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = []rcxMember{
		{Name: "current", Provider: "current", SupportsUDP: true},
		{Name: "known-a", Provider: "near", Transport: "ws", SupportsUDP: true},
		{Name: "known-b", Provider: "near", Transport: "ws", SupportsUDP: true},
		{Name: "known-c", Provider: "near", Transport: "ws", SupportsUDP: true},
		{Name: "unknown-a", Provider: "other-a", Transport: "grpc", SupportsUDP: true},
		{Name: "unknown-b", Provider: "other-b", Transport: "tcp", SupportsUDP: true},
	}
	engine := newTestEngine(runtime, "ru")
	engine.incumbent, runtime.selected = "current", "current"
	marker := rcxMarkerID(rcxRoleOpen, engine.cfg.OpenMarkers[0])
	for index, member := range runtime.members {
		engine.ledger.SetOrigin(member.key(), "NL", rcxOriginForeign)
		engine.ledger.NoteProbe(member.key(), engine.envKey, rcxRoleOpen, rcxProbeOK, 50, runtime.Now())
		if index < 4 {
			engine.ledger.NoteQualitySample(member.key(), engine.envKey, marker, engine.qualityEpoch(), 149+index, runtime.Now())
		}
	}
	input := rcxDecisionInput{
		Terrain: rcxTerrainNormal, Incumbent: engine.incumbent,
		Candidates: engine.candidates(runtime.members), Policy: engine.cfg.policy(), Now: runtime.Now(),
	}
	got := engine.pickStandbys(rcxRank(input), engine.incumbent, nil)
	if want := []string{"known-a", "known-b", "known-c"}; !reflect.DeepEqual(got, want) {
		t.Fatalf("standbys = %v, want measured 150/151/152ms peers instead of unknown latency diversity", got)
	}
}

func TestStandbyDiversityStillBreaksTiesWithinTheSameQualityBand(t *testing.T) {
	engine, runtime := standbyLatencyEngine(t)
	marker := rcxMarkerID(rcxRoleOpen, engine.cfg.OpenMarkers[0])
	for _, name := range []string{"fast-a", "fast-b", "fast-c", "slow-a", "slow-b"} {
		for _, elapsed := range []time.Duration{time.Second, 2 * time.Second} {
			at := runtime.Now().Add(elapsed)
			engine.ledger.NoteProbe(name, engine.envKey, rcxRoleOpen, rcxProbeOK, 70, at)
			engine.ledger.NoteQualitySample(name, engine.envKey, marker, engine.qualityEpoch(), 70, at)
		}
	}
	runtime.advance(2 * time.Second)
	input := rcxDecisionInput{
		Terrain: rcxTerrainNormal, Incumbent: engine.incumbent,
		Candidates: engine.candidates(runtime.members), Policy: engine.cfg.policy(), Now: runtime.Now(),
	}
	got := engine.pickStandbys(rcxRank(input), engine.incumbent, nil)
	providers := map[string]bool{}
	for _, key := range got {
		for _, member := range runtime.members {
			if member.key() == key {
				providers[member.Provider] = true
			}
		}
	}
	if len(got) != rcxStandbyCount || len(providers) != rcxStandbyCount {
		t.Fatalf("standbys = %v, providers = %v, want equal-quality diversity retained", got, providers)
	}
}
