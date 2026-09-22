package rcx

import (
	"testing"
	"time"
)

func TestQualityLatencyThresholds(t *testing.T) {
	for _, tc := range []struct {
		name       string
		strategy   string
		incumbent  int
		challenger int
		want       bool
	}{
		{"249 to 69", rcxStrategyBalanced, 249, 69, true},
		{"inside a band", rcxStrategyBalanced, 140, 100, true},
		{"minor improvement", rcxStrategyBalanced, 70, 65, false},
		{"absolute threshold", rcxStrategyBalanced, 100, 70, true},
		{"below absolute", rcxStrategyBalanced, 100, 71, false},
		{"relative threshold", rcxStrategyLatency, 200, 160, true},
		{"below relative", rcxStrategyLatency, 200, 161, false},
		{"stable escape", rcxStrategyStable, 249, 69, true},
		{"stable absolute", rcxStrategyStable, 150, 100, true},
		{"stable below absolute", rcxStrategyStable, 150, 101, false},
		{"saver relative", rcxStrategySaver, 200, 140, true},
		{"saver below relative", rcxStrategySaver, 200, 141, false},
		{"unknown incumbent", rcxStrategyBalanced, 0, 50, false},
		{"unknown challenger", rcxStrategyBalanced, 100, 0, false},
		{"negative challenger", rcxStrategyBalanced, 100, -1, false},
		{"equal", rcxStrategyBalanced, 100, 100, false},
		{"slower", rcxStrategyBalanced, 100, 200, false},
		{"fractional threshold", rcxStrategyBalanced, 201, 161, false},
	} {
		t.Run(tc.name, func(t *testing.T) {
			if got := rcxLatencyImproves(tc.strategy, tc.incumbent, tc.challenger); got != tc.want {
				t.Fatalf("latency improvement = %v, want %v", got, tc.want)
			}
		})
	}
}

func TestQualityDecisionRequiresConfirmation(t *testing.T) {
	for _, strategy := range []string{rcxStrategyBalanced, rcxStrategyLatency, rcxStrategyStable, rcxStrategySaver} {
		t.Run(strategy, func(t *testing.T) {
			current := rcxNode("current", foreignProven())
			current.MedianMs, current.Evidence = 249, rcxEvidenceLiveTraffic
			better := rcxNode("better", foreignProven())
			better.MedianMs = 69
			policy := rcxTestPolicy()
			policy.Strategy = strategy
			input := rcxDecisionInput{
				Terrain: rcxTerrainNormal, Incumbent: current.Name,
				Candidates: []rcxCandidate{current, better}, Policy: policy,
			}
			if got := rcxDecideAt(input); got.Switch || got.Reason != rcxReasonQualityConfirming || got.Detail != better.Name {
				t.Fatalf("unconfirmed decision = %+v", got)
			}
			input.Candidates[1].QualityConfirmed = true
			if got := rcxDecideAt(input); !got.Switch || got.To != better.Name || got.Reason != rcxReasonLatencyGain {
				t.Fatalf("confirmed decision = %+v", got)
			}
		})
	}
}

func TestQualityDecisionUsesMillisecondsNotBands(t *testing.T) {
	for _, tc := range []struct {
		name string
		from int
		to   int
		want bool
	}{
		{"adjacent bands", 249, 69, true},
		{"same band", 140, 100, true},
		{"noise", 70, 65, false},
		{"band crossing noise", 151, 149, false},
	} {
		t.Run(tc.name, func(t *testing.T) {
			current := rcxNode("current", foreignProven())
			current.MedianMs = tc.from
			better := rcxNode("better", foreignProven())
			better.MedianMs, better.QualityConfirmed = tc.to, true
			got := rcxDecideAt(rcxDecisionInput{
				Terrain: rcxTerrainNormal, Incumbent: current.Name,
				Candidates: []rcxCandidate{current, better},
			})
			if got.Switch != tc.want {
				t.Fatalf("decision = %+v, want switch %v", got, tc.want)
			}
		})
	}
}

func TestQualityReliabilityNeedsRepeatedFailureAndConfirmation(t *testing.T) {
	for _, tc := range []struct {
		name       string
		recurrence int
		degraded   bool
		confirmed  bool
		want       rcxReason
	}{
		{"one episode", 1, false, true, rcxReasonHold},
		{"recurrence unconfirmed", 2, false, false, rcxReasonQualityConfirming},
		{"recurrence confirmed", 2, false, true, rcxReasonReliabilityGain},
		{"degraded unconfirmed", 0, true, false, rcxReasonQualityConfirming},
		{"degraded confirmed", 0, true, true, rcxReasonReliabilityGain},
	} {
		t.Run(tc.name, func(t *testing.T) {
			current := rcxNode("current", foreignProven())
			current.MedianMs, current.Recurrence, current.Degraded = 70, tc.recurrence, tc.degraded
			better := rcxNode("better", foreignProven())
			better.MedianMs, better.QualityConfirmed = 150, tc.confirmed
			input := rcxDecisionInput{
				Terrain: rcxTerrainNormal, Incumbent: current.Name,
				Candidates: []rcxCandidate{current, better},
			}
			got := rcxDecideAt(input)
			if got.Reason != tc.want || got.Switch != (tc.want == rcxReasonReliabilityGain) {
				t.Fatalf("decision = %+v, want %s", got, tc.want)
			}
			if tc.want != rcxReasonReliabilityGain {
				return
			}
			input.Now = time.Unix(1_700_000_000, 0)
			input.IncumbentSince = input.Now
			if got := rcxDecideAt(input); got.Switch || got.Reason != rcxReasonDwellHold {
				t.Fatalf("young incumbent decision = %+v", got)
			}
			input.IncumbentSince = time.Time{}
			input.Pin = current.Name
			if got := rcxDecideAt(input); got.Switch || got.Reason != rcxReasonManualHold {
				t.Fatalf("pinned decision = %+v", got)
			}
		})
	}
}

func TestQualityPinSurvivesVerdictGain(t *testing.T) {
	current := rcxNode("current", foreignUntested())
	better := rcxNode("better", foreignProven())
	better.QualityConfirmed = true
	got := rcxDecideAt(rcxDecisionInput{
		Terrain: rcxTerrainNormal, Incumbent: current.Name, Pin: current.Name,
		Candidates: []rcxCandidate{current, better},
	})
	if got.Switch || got.Reason != rcxReasonManualHold {
		t.Fatalf("pinned verdict decision = %+v", got)
	}
}

func TestQualityRankingKeepsOriginsButEqualizesSufficientEvidence(t *testing.T) {
	live := rcxNode("live", foreignProven())
	live.Evidence = rcxEvidenceLiveTraffic
	fresh := rcxNode("fresh", foreignProven())
	input := rcxDecisionInput{Terrain: rcxTerrainNormal, Candidates: []rcxCandidate{live, fresh}}
	ranked := rcxRank(input)
	if rcxCompare(ranked[0].Key, ranked[1].Key) != 0 {
		t.Fatal("equal current proofs must have equal evidence rank")
	}
	if ranked[0].Candidate.Evidence.String() != "live" || ranked[1].Candidate.Evidence.String() != "fresh" {
		t.Fatal("ranking lost evidence origins")
	}
}

func TestQualityDiscoveryUsesHostFallbackAndUnknownIsNotFastest(t *testing.T) {
	unknown := rcxNode("unknown", foreignProven())
	unknown.MedianMs, unknown.Order = 0, 0
	host := rcxNode("host", foreignProven())
	host.MedianMs, host.HostMs, host.Order = 0, 69, 70_000
	own := rcxNode("own", foreignProven())
	own.MedianMs, own.HostMs, own.Order = 249, 20, 1
	input := rcxDecisionInput{Terrain: rcxTerrainNormal, Candidates: []rcxCandidate{unknown, own, host}}
	ranked := rcxRank(input)
	// A measured median outranks a lower unmeasured entry-ping; among the unmeasured
	// host-ping is only a fallback, and a signal-less node is never fastest.
	if ranked[0].Candidate.Name != own.Name || ranked[1].Candidate.Name != host.Name || ranked[2].Candidate.Name != unknown.Name {
		t.Fatalf("unexpected shortlist: %+v", ranked)
	}
	input.Incumbent = unknown.Name
	if got := rcxDecideAt(input); got.Switch {
		t.Fatalf("an unmeasured host-ping edge must not move traffic without a measured median: %+v", got)
	}
}

func TestQualitySourceOrderDoesNotOverflowOrPromoteAlone(t *testing.T) {
	first := rcxNode("first", foreignProven())
	first.Order = 65_535
	last := rcxNode("last", foreignProven())
	last.Order = 65_536
	input := rcxDecisionInput{Terrain: rcxTerrainNormal, Candidates: []rcxCandidate{last, first}}
	if got := rcxDecideAt(input); got.To != first.Name {
		t.Fatalf("source order decision = %+v", got)
	}
	input.Incumbent = last.Name
	if got := rcxDecideAt(input); got.Switch {
		t.Fatalf("source order promoted alone: %+v", got)
	}
}
