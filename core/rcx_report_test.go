package main

import (
	"testing"
	"time"
)

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
