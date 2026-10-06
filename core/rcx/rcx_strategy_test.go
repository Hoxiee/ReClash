package rcx

import (
	"reflect"
	"testing"
)

// legacyBandsFor and legacySwitchFor reproduce the pre-table hardcoded strategy
// flavor; the data-driven profile must match them for every strategy.
func legacyBandsFor(strategy string) []int {
	switch strategy {
	case rcxStrategyStable:
		return []int{120, 200, 320, 550}
	case rcxStrategyLatency:
		return []int{65, 90, 130, 220}
	case rcxStrategySaver:
		return []int{150, 260, 420, 750}
	default:
		return []int{80, 120, 180, 320}
	}
}

func legacySwitchFor(strategy string) (int, int) {
	switch strategy {
	case rcxStrategyLatency:
		return 15, 10
	case rcxStrategyStable, rcxStrategySaver:
		return 50, 30
	}
	return 30, 20
}

func legacyLadderForStrategy(ladder []rcxRungSpec, strategy string) []rcxRungSpec {
	if strategy != rcxStrategyLatency {
		return ladder
	}
	out := make([]rcxRungSpec, 0, len(ladder))
	for _, spec := range ladder {
		if spec.ID == rcxRungMisfit {
			continue
		}
		out = append(out, spec)
	}
	return out
}

func TestStrategyProfileMatchesLegacyFlavor(t *testing.T) {
	strategies := []string{
		rcxStrategyBalanced, rcxStrategyStable, rcxStrategyLatency, rcxStrategySaver, "unknown",
	}
	for _, strategy := range strategies {
		if got, want := rcxDefaultLatencyBandsFor(strategy), legacyBandsFor(strategy); !reflect.DeepEqual(got, want) {
			t.Fatalf("%s bands: got %v want %v", strategy, got, want)
		}
		absWant, pctWant := legacySwitchFor(strategy)
		absGot, pctGot := rcxPolicy{Strategy: strategy}.switchThresholds()
		if absGot != absWant || pctGot != pctWant {
			t.Fatalf("%s switch: got %d/%d want %d/%d", strategy, absGot, pctGot, absWant, pctWant)
		}
		base := rcxDefaultLadder()
		if got, want := rcxLadderForStrategy(base, strategy), legacyLadderForStrategy(base, strategy); !reflect.DeepEqual(got, want) {
			t.Fatalf("%s ladder: got %v want %v", strategy, got, want)
		}
	}
}

// A literal guard so a reordered or retuned strategy record cannot slip through
// unnoticed; these are the shipped, safety-reviewed per-strategy flavors.
func TestDefaultStrategyProfilesHistoricalValues(t *testing.T) {
	want := map[string]rcxStrategyProfile{
		rcxStrategyBalanced: {LatencyBands: []int{80, 120, 180, 320}, SwitchAbsMs: 30, SwitchPct: 20},
		rcxStrategyStable:   {LatencyBands: []int{120, 200, 320, 550}, SwitchAbsMs: 50, SwitchPct: 30},
		rcxStrategyLatency:  {DropRungs: []rcxRungID{rcxRungMisfit}, LatencyBands: []int{65, 90, 130, 220}, SwitchAbsMs: 15, SwitchPct: 10},
		rcxStrategySaver:    {LatencyBands: []int{150, 260, 420, 750}, SwitchAbsMs: 50, SwitchPct: 30},
	}
	if !reflect.DeepEqual(rcxStrategyProfiles, want) {
		t.Fatalf("strategy profiles drifted:\n got: %+v\nwant: %+v", rcxStrategyProfiles, want)
	}
}

// A literal guard on the terrain admission rows: the domestic-node asymmetry and
// the last-resort gate per terrain are the safety-reviewed shipped defaults.
func TestDefaultAdmissionHistoricalRows(t *testing.T) {
	want := map[rcxTerrain]rcxAdmissionRow{
		rcxTerrainNormal: {
			openWorldProven: rcxVerdictPreferred,
			domesticProven:  rcxVerdictLastResort,
			breakerProven:   rcxVerdictViable,
			foreignPrior:    rcxVerdictViable,
			domesticPrior:   rcxVerdictLastResort,
			allowLastResort: false,
		},
		rcxTerrainWhitelist: {
			openWorldProven: rcxVerdictPreferred,
			domesticProven:  rcxVerdictViable,
			breakerProven:   rcxVerdictPreferred,
			foreignPrior:    rcxVerdictViable,
			domesticPrior:   rcxVerdictLastResort,
			allowLastResort: true,
		},
		rcxTerrainUnknown: {
			openWorldProven: rcxVerdictPreferred,
			domesticProven:  rcxVerdictLastResort,
			breakerProven:   rcxVerdictViable,
			foreignPrior:    rcxVerdictViable,
			domesticPrior:   rcxVerdictLastResort,
			allowLastResort: true,
		},
	}
	if !reflect.DeepEqual(rcxAdmissionTable, want) {
		t.Fatalf("admission table drifted:\n got: %+v\nwant: %+v", rcxAdmissionTable, want)
	}
}
