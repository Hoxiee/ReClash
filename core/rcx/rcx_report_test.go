package rcx

import (
	"fmt"
	"testing"
	"time"
)

func BenchmarkEngineReconsiderUnchanged(b *testing.B) {
	for _, size := range []int{100, 250} {
		b.Run(fmt.Sprintf("park-%d", size), func(b *testing.B) {
			runtime := newFakeRuntime()
			runtime.members = make([]rcxMember, size)
			for i := range runtime.members {
				runtime.members[i] = rcxMember{Name: fmt.Sprintf("node-%d", i), SupportsUDP: true}
			}
			engine := newTestEngine(runtime, "ru-home")
			engine.handle(rcxEvent{Kind: rcxEventProvidersLoaded})
			b.ResetTimer()
			for i := 0; i < b.N; i++ {
				engine.reconsider()
			}
		})
	}
}

func TestConfigWithoutAMarkerIsNotOperable(t *testing.T) {
	config := rcxDefaultConfig()
	config.Enabled = true

	if config.operable() {
		t.Error("with nothing to measure against no node can earn a verdict")
	}

	config.OpenMarkers = []rcxMarker{{URL: "https://example.invalid/", Statuses: []int{204}}}
	if !config.operable() {
		t.Error("a marker is the only thing the engine needs to start working")
	}
}

func TestConfigFromAnOlderHostStillRoutes(t *testing.T) {
	config := rcxConfig{Enabled: true, Preset: "ru-mobile"}.normalized()

	if config.DwellSeconds != rcxDwellSeconds || config.WaveWidth != rcxWaveWidth {
		t.Errorf("tuning = (%d, %d), want shipped values rather than zero",
			config.DwellSeconds, config.WaveWidth)
	}
}

func TestRankExplainsWhyANodeIsNotEligible(t *testing.T) {
	now := time.Unix(1_700_000_000, 0)
	input := rcxDecisionInput{
		Terrain: rcxTerrainNormal,
		Policy:  rcxDefaultConfig().policy(),
		Now:     now,
		Candidates: []rcxCandidate{
			{
				Name:       "cooling",
				InSkeleton: true,
				CoolUntil:  now.Add(time.Minute),
				Facts:      rcxFacts{OpenWorld: rcxProofProven},
			},
			{
				Name:       "blocked",
				Order:      1,
				InSkeleton: true,
				Facts:      rcxFacts{OpenWorld: rcxProofDisproven},
			},
			{
				Name:       "domestic",
				Order:      2,
				InSkeleton: true,
				Facts:      rcxFacts{Origin: rcxOriginDomestic},
			},
			{
				Name:       "good",
				Order:      3,
				InSkeleton: true,
				Facts:      rcxFacts{OpenWorld: rcxProofProven},
				Evidence:   rcxEvidenceLiveTraffic,
			},
			{
				Name:       "circuit",
				Order:      4,
				InSkeleton: true,
				Circuit:    true,
				Facts:      rcxFacts{Origin: rcxOriginForeign},
			},
		},
	}

	ranked := rcxRank(input)

	if ranked[0].Candidate.Name != "good" {
		t.Fatalf("first row = %q, want the only eligible node on top", ranked[0].Candidate.Name)
	}
	blocks := map[string]rcxBlock{}
	for _, row := range ranked {
		blocks[row.Candidate.Name] = row.Block
	}
	want := map[string]rcxBlock{
		"good":     rcxBlockNone,
		"cooling":  rcxBlockCooling,
		"blocked":  rcxBlockDisproven,
		"domestic": rcxBlockLastResort,
		"circuit":  rcxBlockProviderCircuit,
	}
	for node, expected := range want {
		if blocks[node] != expected {
			t.Errorf("block(%s) = %q, want %q", node, blocks[node], expected)
		}
	}
}

func TestReportCarriesTheReasoningBehindTheChoice(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("chosen", "cold")
	runtime.countries = map[string]string{"chosen": "NL"}
	engine := newTestEngine(runtime, "ru-home")
	engine.ledger.NoteProbe("chosen", "w:Home", rcxRoleOpen, rcxProbeOK, 120, runtime.Now())

	engine.reconsider()
	report := engine.Report()

	if len(report.Candidates) != 2 {
		t.Fatalf("candidates = %d, want every member explained", len(report.Candidates))
	}
	top := report.Candidates[0]
	if top.Node != "chosen" || !top.Current {
		t.Errorf("top row = %+v, want the selected node first", top)
	}
	if top.Verdict != "preferred" || top.Country != "NL" {
		t.Errorf("top row verdict/country = %q/%q, want the evidence shown", top.Verdict, top.Country)
	}
	if len(report.History) != 1 || report.History[0].To != "chosen" {
		t.Errorf("history = %+v, want the switch recorded with its reason", report.History)
	}
	if report.Status.Eligible != 2 || report.Bands == nil {
		t.Errorf("status = %+v, want eligible counts and the bands behind them", report.Status)
	}
	if report.Link.Foreign == "" || report.ProbeCap != rcxProbeBudgetCap {
		t.Errorf("link/budget = %+v/%d, want the network facts too", report.Link, report.ProbeCap)
	}
}

func TestReportBuildsCandidateDetailsOnlyWhenRead(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("chosen", "cold")
	engine := newTestEngine(runtime, "ru-home")
	engine.reconsider()

	if engine.report.Candidates != nil {
		t.Fatal("publish built candidate details before the report was requested")
	}
	first := engine.Report()
	if len(first.Candidates) != 2 {
		t.Fatalf("candidates = %d, want the current park", len(first.Candidates))
	}
	cached := engine.report.Candidates
	engine.Report()
	if len(cached) > 0 && &engine.report.Candidates[0] != &cached[0] {
		t.Fatal("an unchanged report poll rebuilt candidate details")
	}
}

func TestReportIncludesLocalRecoveryMetricsAndActiveIncidents(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = []rcxMember{
		{Name: "dead", ID: "dead-id", Provider: "provider-a", Transport: "ws", Type: "Vless", Port: 443, SupportsUDP: true},
		{Name: "warm", ID: "warm-id", Provider: "provider-b", Transport: "grpc", Type: "Vless", Port: 443, SupportsUDP: true},
	}
	engine := newTestEngine(runtime, "ru-home")
	engine.incumbent = "dead"
	engine.candidates(runtime.members)
	engine.snapshot.Standbys[engine.envKey] = []string{"warm-id"}
	engine.accountedAt = runtime.Now()
	runtime.advance(10 * time.Second)
	engine.startIncident(runtime.Now())
	runtime.advance(2 * time.Second)
	engine.noteSwitch("dead", "warm", rcxReasonDegraded, runtime.Now())
	engine.snapshot.Circuits[rcxCircuitKey(engine.envKey, "provider-a")] = rcxProviderCircuit{Until: runtime.Now().Add(time.Minute)}
	marker := engine.cfg.OpenMarkers[0]
	engine.snapshot.Quarantines[rcxMarkerID(rcxRoleOpen, marker)] = rcxMarkerQuarantine{Until: runtime.Now().Add(time.Minute)}

	engine.reconsider()
	report := engine.Report()

	if report.Metrics.Availability != 83 || report.Metrics.Incidents != 1 || report.Metrics.StandbyHits != 1 {
		t.Errorf("metrics = %+v, want 10s available of 12s and one standby recovery", report.Metrics)
	}
	if report.Metrics.LastFailover != 2_000 || report.Metrics.AverageOutage != 2_000 {
		t.Errorf("recovery durations = %+v, want the two-second incident", report.Metrics)
	}
	if len(report.Metrics.ActiveCircuits) != 1 || report.Metrics.ActiveCircuits[0] != "provider-a" {
		t.Errorf("circuits = %v, want the active provider named", report.Metrics.ActiveCircuits)
	}
	if len(report.Metrics.ActiveMarkers) != 1 || report.Metrics.ActiveMarkers[0] != marker.URL {
		t.Errorf("markers = %v, want the quarantined marker URL named", report.Metrics.ActiveMarkers)
	}
}

func TestMetricsSkipSuspendGapsAndCloseRecoveredIncidents(t *testing.T) {
	runtime := newFakeRuntime()
	engine := newTestEngine(runtime, "ru-home")
	engine.accountedAt = runtime.Now()
	runtime.advance(5 * time.Second)
	engine.startIncident(runtime.Now())
	runtime.advance(3 * time.Second)
	engine.applySuspend(true)
	runtime.advance(time.Hour)
	engine.applySuspend(false)
	runtime.advance(4 * time.Second)
	engine.publish(rcxReasonHold, nil, rcxDecisionInput{})

	metrics := engine.Report().Metrics
	if metrics.EnabledMillis != 12_000 || metrics.AvailableMillis != 9_000 {
		t.Errorf("metrics = %+v, want the suspend hour excluded", metrics)
	}
	if metrics.LastOutage != 0 {
		t.Errorf("last outage = %d, want a suspended episode abandoned rather than reported as recovery", metrics.LastOutage)
	}
}

func TestDeepScanSweepsWiderThanABoughtWave(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("a", "b", "c", "d", "e", "f", "g", "h")
	engine := newTestEngine(runtime, "ru-mobile")
	engine.metered = true
	engine.budget = newRcxProbeBudget(0, rcxProbeBudgetWin)

	engine.handle(rcxEvent{Kind: rcxEventDeepScan})

	if !engine.probing || !engine.deep {
		t.Fatal("a hand-asked sweep must run even with the hourly budget spent")
	}
	if !engine.Status().Deep {
		t.Error("the host cannot tell a deep scan from a background wave without the flag")
	}
}

func TestDeepScanStaysQuietWhenThereIsNothingToScan(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.mode = "global"
	runtime.members = foreignMembers("a")
	engine := newTestEngine(runtime, "ru-home")

	engine.handle(rcxEvent{Kind: rcxEventDeepScan})

	if engine.probing || engine.deep {
		t.Error("outside rule mode the engine owns nothing to measure")
	}
}
