package main

import (
	"math/rand"
	"testing"
	"time"
)

var rcxTestBands = []int{150, 300, 600, 1200}

func rcxTestPolicy() rcxPolicy {
	return rcxPolicy{
		LatencyBands:        rcxTestBands,
		AllowDomesticLast:   true,
		DwellSeconds:        90,
		DegradedBandPenalty: 2,
	}
}

func rcxNode(name string, facts rcxFacts) rcxCandidate {
	return rcxCandidate{
		Name:       name,
		Facts:      facts,
		Evidence:   rcxEvidenceFreshProbe,
		MedianMs:   200,
		InSkeleton: true,
	}
}

func foreignProven() rcxFacts {
	return rcxFacts{
		Origin:      rcxOriginForeign,
		OpenWorld:   rcxProofProven,
		Transit:     rcxProofProven,
		SupportsUDP: true,
	}
}

func foreignUntested() rcxFacts {
	return rcxFacts{Origin: rcxOriginForeign, SupportsUDP: true}
}

func domesticUntested() rcxFacts {
	return rcxFacts{Origin: rcxOriginDomestic, SupportsUDP: true}
}

func TestProviderCircuitBarsOnlyAnUnprovenCandidate(t *testing.T) {
	blocked := rcxNode("blocked", foreignUntested())
	blocked.Circuit = true
	proven := rcxNode("proven", foreignProven())
	proven.Circuit = true

	input := rcxDecisionInput{
		Terrain:    rcxTerrainNormal,
		Candidates: []rcxCandidate{blocked, proven},
		Policy:     rcxTestPolicy(),
	}
	got := rcxDecideAt(input)
	if got.To != "proven" {
		t.Errorf("picked %q, want the proven node to survive its provider circuit", got.To)
	}
	if block := rcxBlockOf(blocked, input); block != rcxBlockProviderCircuit {
		t.Errorf("block = %q, want %q", block, rcxBlockProviderCircuit)
	}
}

func TestAdmitTableEncodesTheDomesticAsymmetry(t *testing.T) {
	domestic := domesticUntested()

	normal := rcxAdmit(rcxTerrainNormal, domestic)
	whitelist := rcxAdmit(rcxTerrainWhitelist, domestic)

	if normal != rcxVerdictLastResort || whitelist != rcxVerdictLastResort {
		t.Fatalf("domestic verdicts = %v/%v, want last-resort in both rows", normal, whitelist)
	}
	if rcxAllowsLastResort(rcxTerrainNormal, true) {
		t.Error("a domestic node must not be selectable on a healthy network: it opens nothing")
	}
	if !rcxAllowsLastResort(rcxTerrainWhitelist, true) {
		t.Error("a domestic node must be selectable under a whitelist shutdown so domestic services still work")
	}
}

func TestAdmitDoesNotCarryADomesticProofOutOfAWhitelist(t *testing.T) {
	// The only way to earn this proof is a whitelist episode, and it outlives the
	// episode: an unmeasured network must not inherit it as viability.
	proven := rcxFacts{
		Origin:      rcxOriginDomestic,
		Domestic:    rcxProofProven,
		Transit:     rcxProofProven,
		SupportsUDP: true,
	}

	if got := rcxAdmit(rcxTerrainWhitelist, proven); got != rcxVerdictViable {
		t.Errorf("whitelist verdict = %v, want viable: domestic services are the point there", got)
	}
	if got := rcxAdmit(rcxTerrainUnknown, proven); got != rcxVerdictLastResort {
		t.Errorf("unknown verdict = %v, want last-resort: it opens nothing on a healthy link", got)
	}
	if got := rcxAdmit(rcxTerrainNormal, proven); got != rcxVerdictLastResort {
		t.Errorf("normal verdict = %v, want last-resort", got)
	}
}

func TestAdmitLetsThePresetDeleteTheLastResortRow(t *testing.T) {
	if rcxAllowsLastResort(rcxTerrainWhitelist, false) {
		t.Error("allowDomesticLastResort=false must remove the row for regions where it makes no sense")
	}
}

func TestAdmitNeverRejectsOnGeographyAlone(t *testing.T) {
	// A CDN-fronted node reports a domestic address while still opening the world.
	fronted := rcxFacts{
		Origin:      rcxOriginDomestic,
		OpenWorld:   rcxProofProven,
		Transit:     rcxProofProven,
		SupportsUDP: true,
	}

	if got := rcxAdmit(rcxTerrainNormal, fronted); got != rcxVerdictPreferred {
		t.Errorf("verdict = %v, want preferred: measured behaviour must outrank the geo prior", got)
	}
}

func TestAdmitRejectsOnlyOnMeasuredFailure(t *testing.T) {
	tests := []struct {
		name  string
		facts rcxFacts
		want  rcxVerdict
	}{
		{
			name:  "dial failed",
			facts: rcxFacts{Origin: rcxOriginForeign, Transit: rcxProofDisproven},
			want:  rcxVerdictReject,
		},
		{
			name:  "opens nothing and carries no domestic traffic",
			facts: rcxFacts{Origin: rcxOriginForeign, OpenWorld: rcxProofDisproven},
			want:  rcxVerdictReject,
		},
		{
			name: "opens nothing but domestic works",
			facts: rcxFacts{
				Origin:    rcxOriginForeign,
				OpenWorld: rcxProofDisproven,
				Domestic:  rcxProofProven,
			},
			want: rcxVerdictViable,
		},
		{
			name:  "never probed",
			facts: foreignUntested(),
			want:  rcxVerdictViable,
		},
	}

	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			if got := rcxAdmit(rcxTerrainWhitelist, tc.facts); got != tc.want {
				t.Errorf("verdict = %v, want %v", got, tc.want)
			}
		})
	}
}

func TestAdmitRejectsEveryNodeOnAPortalOrOfflineTerrain(t *testing.T) {
	for _, terrain := range []rcxTerrain{rcxTerrainPortal, rcxTerrainOffline} {
		if got := rcxAdmit(terrain, foreignProven()); got != rcxVerdictReject {
			t.Errorf("%s verdict = %v, want reject so the engine can hand traffic to DIRECT", terrain, got)
		}
	}
}

func TestLatBucketPlacesUnknownLatencyMidTable(t *testing.T) {
	tests := []struct {
		ms   int
		want uint8
	}{
		{ms: 1, want: 0},
		{ms: 150, want: 0},
		{ms: 151, want: 1},
		{ms: 1200, want: 3},
		{ms: 1201, want: 4},
		{ms: 0, want: 2},
		{ms: -1, want: 2},
	}

	for _, tc := range tests {
		if got := rcxLatBucket(tc.ms, rcxTestBands); got != tc.want {
			t.Errorf("rcxLatBucket(%d) = %d, want %d", tc.ms, got, tc.want)
		}
	}
}

func TestCompareIsAStrictWeakOrdering(t *testing.T) {
	random := rand.New(rand.NewSource(1))
	keys := make([]rcxKey, 0, 64)
	for i := 0; i < 64; i++ {
		keys = append(keys, rcxKey{
			verdict:    rcxVerdict(random.Intn(4)),
			evidence:   rcxEvidence(random.Intn(4)),
			latBucket:  uint8(random.Intn(5)),
			challenger: random.Intn(2) == 1,
			order:      uint16(random.Intn(4)),
		})
	}

	for _, a := range keys {
		if rcxCompare(a, a) != 0 {
			t.Fatalf("compare(%v, %v) != 0: the order must be irreflexive", a, a)
		}
		for _, b := range keys {
			if rcxCompare(a, b) != -rcxCompare(b, a) {
				t.Fatalf("compare is not antisymmetric for %v vs %v", a, b)
			}
			for _, c := range keys {
				if rcxCompare(a, b) < 0 && rcxCompare(b, c) < 0 && rcxCompare(a, c) >= 0 {
					t.Fatalf("compare is not transitive for %v < %v < %v", a, b, c)
				}
			}
		}
	}
}

func TestCompareRanksVerdictAboveLatency(t *testing.T) {
	slowButOpen := rcxKey{verdict: rcxVerdictPreferred, latBucket: 3}
	fastButUnproven := rcxKey{verdict: rcxVerdictViable, latBucket: 0}

	if rcxCompare(slowButOpen, fastButUnproven) >= 0 {
		t.Error("a proven-open node must beat a faster unproven one: reachability is not tradeable for latency")
	}
}

func TestCompareRanksLiveTrafficAboveAFasterProbe(t *testing.T) {
	provenByTraffic := rcxKey{verdict: rcxVerdictViable, evidence: rcxEvidenceLiveTraffic, latBucket: 2}
	provenByProbe := rcxKey{verdict: rcxVerdictViable, evidence: rcxEvidenceFreshProbe, latBucket: 0}

	if rcxCompare(provenByTraffic, provenByProbe) >= 0 {
		t.Error("evidence outranks latency: a censor can answer a marker but not the user's own connection")
	}
}

func rcxDecideAt(in rcxDecisionInput) rcxDecision {
	if in.Policy.LatencyBands == nil {
		in.Policy = rcxTestPolicy()
	}
	if in.Now.IsZero() {
		in.Now = time.Unix(1_700_000_000, 0)
	}
	return rcxDecide(in)
}

func TestDecideHoldsAHealthyIncumbent(t *testing.T) {
	got := rcxDecideAt(rcxDecisionInput{
		Terrain:    rcxTerrainNormal,
		Incumbent:  "nl-1",
		Candidates: []rcxCandidate{rcxNode("nl-1", foreignProven()), rcxNode("de-1", foreignProven())},
	})

	if got.Switch {
		t.Errorf("switched to %s with reason %s, want a hold on the incumbent", got.To, got.Reason)
	}
	if got.Reason != rcxReasonHold {
		t.Errorf("reason = %s, want %s", got.Reason, rcxReasonHold)
	}
}

func TestDecideReplacesADeadIncumbentImmediately(t *testing.T) {
	dead := rcxNode("nl-1", foreignProven())
	dead.Facts.Transit = rcxProofDisproven

	got := rcxDecideAt(rcxDecisionInput{
		Terrain:        rcxTerrainNormal,
		Incumbent:      "nl-1",
		IncumbentSince: time.Unix(1_700_000_000, 0),
		Candidates:     []rcxCandidate{dead, rcxNode("de-1", foreignProven())},
	})

	if !got.Switch || got.To != "de-1" {
		t.Fatalf("decision = %+v, want an immediate switch to de-1", got)
	}
	if got.Reason != rcxReasonIncumbentDead {
		t.Errorf("reason = %s, want %s", got.Reason, rcxReasonIncumbentDead)
	}
}

func TestDecideIgnoresDwellForAVerdictGain(t *testing.T) {
	now := time.Unix(1_700_000_000, 0)
	unproven := rcxNode("nl-1", foreignUntested())
	proven := rcxNode("de-1", foreignProven())

	got := rcxDecideAt(rcxDecisionInput{
		Terrain:        rcxTerrainNormal,
		Incumbent:      "nl-1",
		IncumbentSince: now,
		Candidates:     []rcxCandidate{unproven, proven},
		Now:            now.Add(time.Second),
	})

	if !got.Switch || got.Reason != rcxReasonVerdictGain {
		t.Errorf("decision = %+v, want a verdict-gain switch that does not wait out dwell", got)
	}
}

func TestDecideMakesALatencyGainWaitOutDwell(t *testing.T) {
	now := time.Unix(1_700_000_000, 0)
	slow := rcxNode("nl-1", foreignProven())
	slow.MedianMs = 900
	fast := rcxNode("de-1", foreignProven())
	fast.MedianMs = 90

	input := rcxDecisionInput{
		Terrain:        rcxTerrainNormal,
		Incumbent:      "nl-1",
		IncumbentSince: now,
		Candidates:     []rcxCandidate{slow, fast},
		Now:            now.Add(10 * time.Second),
	}

	if got := rcxDecideAt(input); got.Switch || got.Reason != rcxReasonDwellHold {
		t.Errorf("decision = %+v, want a dwell hold while the incumbent is young", got)
	}

	input.Now = now.Add(2 * time.Minute)
	if got := rcxDecideAt(input); !got.Switch || got.Reason != rcxReasonLatencyGain {
		t.Errorf("decision = %+v, want a latency-gain switch once dwell elapsed", got)
	}
}

func TestDecideRespectsAManualPinForLatencyOnly(t *testing.T) {
	now := time.Unix(1_700_000_000, 0)
	slow := rcxNode("nl-1", foreignProven())
	slow.MedianMs = 900
	fast := rcxNode("de-1", foreignProven())
	fast.MedianMs = 90

	got := rcxDecideAt(rcxDecisionInput{
		Terrain:        rcxTerrainNormal,
		Incumbent:      "nl-1",
		IncumbentSince: now.Add(-time.Hour),
		Pin:            "nl-1",
		Candidates:     []rcxCandidate{slow, fast},
		Now:            now,
	})

	if got.Switch || got.Reason != rcxReasonManualHold {
		t.Errorf("decision = %+v, want the manual pin to survive a mere latency gain", got)
	}
}

func TestDecideOverridesAManualPinWhenTheNodeDies(t *testing.T) {
	dead := rcxNode("nl-1", foreignProven())
	dead.Facts.Transit = rcxProofDisproven

	got := rcxDecideAt(rcxDecisionInput{
		Terrain:    rcxTerrainWhitelist,
		Incumbent:  "nl-1",
		Pin:        "nl-1",
		Candidates: []rcxCandidate{dead, rcxNode("de-1", foreignProven())},
	})

	if !got.Switch || got.Reason != rcxReasonIncumbentDead {
		t.Errorf("decision = %+v, want a dead pinned node to be replaced anyway", got)
	}
}

func TestDecideGatesCoolingNodesOutEntirely(t *testing.T) {
	now := time.Unix(1_700_000_000, 0)
	cooling := rcxNode("de-1", foreignProven())
	cooling.MedianMs = 40
	cooling.CoolUntil = now.Add(time.Hour)

	got := rcxDecideAt(rcxDecisionInput{
		Terrain:        rcxTerrainNormal,
		Incumbent:      "nl-1",
		IncumbentSince: now.Add(-time.Hour),
		Candidates:     []rcxCandidate{rcxNode("nl-1", foreignProven()), cooling},
		Now:            now,
	})

	if got.Switch {
		t.Errorf("switched to %s: a cooling node must not be a candidate at all", got.To)
	}
}

func TestDecideFallsBackToADomesticNodeOnlyUnderAWhitelist(t *testing.T) {
	deadForeign := rcxNode("nl-1", foreignProven())
	deadForeign.Facts.Transit = rcxProofDisproven
	domestic := rcxNode("ru-1", domesticUntested())

	whitelist := rcxDecideAt(rcxDecisionInput{
		Terrain:    rcxTerrainWhitelist,
		Incumbent:  "nl-1",
		Candidates: []rcxCandidate{deadForeign, domestic},
	})
	if !whitelist.Switch || whitelist.To != "ru-1" {
		t.Fatalf("decision = %+v, want the domestic node as a last resort under a shutdown", whitelist)
	}

	normal := rcxDecideAt(rcxDecisionInput{
		Terrain:    rcxTerrainNormal,
		Incumbent:  "nl-1",
		Candidates: []rcxCandidate{deadForeign, domestic},
	})
	if normal.Switch {
		t.Errorf("switched to %s on a healthy network: a domestic node opens nothing there", normal.To)
	}
	if normal.Reason != rcxReasonStranded {
		t.Errorf("reason = %s, want %s so the engine keeps serving rather than exposing traffic", normal.Reason, rcxReasonStranded)
	}
}

func TestDecideKeepsTheIncumbentWhenNothingIsAdmissible(t *testing.T) {
	dead := rcxNode("nl-1", foreignProven())
	dead.Facts.Transit = rcxProofDisproven

	got := rcxDecideAt(rcxDecisionInput{
		Terrain:    rcxTerrainNormal,
		Incumbent:  "nl-1",
		Candidates: []rcxCandidate{dead},
	})

	if got.Switch {
		t.Errorf("decision = %+v, want the incumbent kept: DIRECT would put real SNI on the wire", got)
	}
	if got.Reason != rcxReasonStranded {
		t.Errorf("reason = %s, want %s", got.Reason, rcxReasonStranded)
	}
}

func TestDecideReportsNoCandidateOnAColdStartWithNothingUsable(t *testing.T) {
	dead := rcxNode("nl-1", foreignProven())
	dead.Facts.Transit = rcxProofDisproven

	got := rcxDecideAt(rcxDecisionInput{Terrain: rcxTerrainNormal, Candidates: []rcxCandidate{dead}})

	if got.Reason != rcxReasonNoCandidate {
		t.Errorf("reason = %s, want %s when there is no incumbent to keep", got.Reason, rcxReasonNoCandidate)
	}
}

func TestDecidePicksFromThePriorWithoutProbesOnColdStart(t *testing.T) {
	remembered := rcxNode("nl-1", foreignUntested())
	remembered.Evidence = rcxEvidenceStaleProbe
	remembered.MedianMs = 120
	unknown := rcxNode("de-1", foreignUntested())
	unknown.Evidence = rcxEvidenceNone
	unknown.MedianMs = 0

	got := rcxDecideAt(rcxDecisionInput{
		Terrain:    rcxTerrainNormal,
		Candidates: []rcxCandidate{unknown, remembered},
	})

	if !got.Switch || got.To != "nl-1" {
		t.Fatalf("decision = %+v, want the remembered node chosen with no probe", got)
	}
	if got.Reason != rcxReasonColdStart {
		t.Errorf("reason = %s, want %s", got.Reason, rcxReasonColdStart)
	}
}

func TestDecideDemotesAThrottledNodeWithoutEvictingIt(t *testing.T) {
	now := time.Unix(1_700_000_000, 0)
	throttled := rcxNode("nl-1", foreignProven())
	throttled.MedianMs = 90
	throttled.Degraded = true
	healthy := rcxNode("de-1", foreignProven())
	healthy.MedianMs = 280

	got := rcxDecideAt(rcxDecisionInput{
		Terrain:        rcxTerrainNormal,
		Incumbent:      "nl-1",
		IncumbentSince: now.Add(-time.Hour),
		Candidates:     []rcxCandidate{throttled, healthy},
		Now:            now,
	})

	if !got.Switch || got.To != "de-1" {
		t.Errorf("decision = %+v, want the throttled incumbent outranked by a slower healthy node", got)
	}
	if got.Reason != rcxReasonLatencyGain {
		t.Errorf("reason = %s, want %s", got.Reason, rcxReasonLatencyGain)
	}
}

func TestDecideRejectsANodeTheCurrentHostSweepTimedOut(t *testing.T) {
	dead := rcxNode("dead", foreignUntested())
	dead.HostDead = true
	live := rcxNode("live", foreignUntested())
	live.HostMs = 120

	got := rcxDecideAt(rcxDecisionInput{
		Terrain: rcxTerrainNormal, Candidates: []rcxCandidate{dead, live},
	})

	if !got.Switch || got.To != "live" {
		t.Fatalf("decision = %+v, want the node with a live host reading", got)
	}
	if block := rcxBlockOf(dead, rcxDecisionInput{Terrain: rcxTerrainNormal}); block != rcxBlockDisproven {
		t.Errorf("block = %q, want %q", block, rcxBlockDisproven)
	}
}

func TestDecideSkipsNodesMissingFromTheSkeleton(t *testing.T) {
	absent := rcxNode("de-1", foreignProven())
	absent.MedianMs = 40
	absent.InSkeleton = false

	got := rcxDecideAt(rcxDecisionInput{
		Terrain:        rcxTerrainNormal,
		Incumbent:      "nl-1",
		IncumbentSince: time.Unix(1_700_000_000, 0).Add(-time.Hour),
		Candidates:     []rcxCandidate{rcxNode("nl-1", foreignProven()), absent},
	})

	if got.Switch {
		t.Errorf("switched to %s, want it skipped: Selector.Set would fail on a non-member", got.To)
	}
}

func TestDecideRequiresUDPWhenThePolicyDoes(t *testing.T) {
	tcpOnly := rcxNode("de-1", foreignProven())
	tcpOnly.Facts.SupportsUDP = false
	tcpOnly.MedianMs = 40
	policy := rcxTestPolicy()
	policy.RequireUDP = true

	got := rcxDecideAt(rcxDecisionInput{
		Terrain:        rcxTerrainNormal,
		Incumbent:      "nl-1",
		IncumbentSince: time.Unix(1_700_000_000, 0).Add(-time.Hour),
		Candidates:     []rcxCandidate{rcxNode("nl-1", foreignProven()), tcpOnly},
		Policy:         policy,
	})

	if got.Switch {
		t.Errorf("switched to %s: a TCP-only pick makes match() skip the group and leak UDP", got.To)
	}
}

func TestDecideIsDeterministicAcrossCandidateOrder(t *testing.T) {
	a := rcxNode("a", foreignProven())
	a.Order = 1
	b := rcxNode("b", foreignProven())
	b.Order = 2

	forward := rcxDecideAt(rcxDecisionInput{Terrain: rcxTerrainNormal, Candidates: []rcxCandidate{a, b}})
	reverse := rcxDecideAt(rcxDecisionInput{Terrain: rcxTerrainNormal, Candidates: []rcxCandidate{b, a}})

	if forward.To != reverse.To {
		t.Errorf("picked %s then %s: the declared order must break ties so traces reproduce", forward.To, reverse.To)
	}
}

func TestSpecialistNodesSinkOnAnOpenNetworkAndRiseUnderAWhitelist(t *testing.T) {
	specialist := rcxCandidate{
		Name:       "LTE обход",
		Order:      1,
		Facts:      rcxFacts{Origin: rcxOriginForeign, SupportsUDP: true, Breaker: true},
		Evidence:   rcxEvidenceFreshProbe,
		MedianMs:   90,
		InSkeleton: true,
	}
	ordinary := rcxCandidate{
		Name:       "Amsterdam",
		Order:      2,
		Facts:      rcxFacts{Origin: rcxOriginForeign, SupportsUDP: true},
		Evidence:   rcxEvidenceFreshProbe,
		MedianMs:   90,
		InSkeleton: true,
	}
	input := rcxDecisionInput{
		Candidates: []rcxCandidate{specialist, ordinary},
		Policy:     rcxPolicy{LatencyBands: []int{150, 300}, DwellSeconds: 90},
		Now:        time.Unix(1_700_000_000, 0),
	}

	input.Terrain = rcxTerrainNormal
	if got := rcxDecide(input); got.To != "Amsterdam" {
		t.Errorf("open network picked %q, want the ordinary node: a specialist is quota spent for nothing", got.To)
	}

	input.Terrain = rcxTerrainWhitelist
	if got := rcxDecide(input); got.To != "LTE обход" {
		t.Errorf("whitelist picked %q, want the specialist", got.To)
	}
}

func TestASpecialistIsStillPickedWhenItIsAllThereIs(t *testing.T) {
	input := rcxDecisionInput{
		Terrain: rcxTerrainNormal,
		Candidates: []rcxCandidate{{
			Name:       "LTE обход",
			Facts:      rcxFacts{Origin: rcxOriginForeign, SupportsUDP: true, Breaker: true},
			Evidence:   rcxEvidenceFreshProbe,
			MedianMs:   90,
			InSkeleton: true,
		}},
		Policy: rcxPolicy{LatencyBands: []int{150, 300}, DwellSeconds: 90},
		Now:    time.Unix(1_700_000_000, 0),
	}

	if got := rcxDecide(input); !got.Switch {
		t.Errorf("decision = %+v, want the specialist: sinking it must never mean barring it", got)
	}
}

func TestAdmitLetsAMeasurementOutliveTheGeographyItContradicted(t *testing.T) {
	// mmdb reads the entry address, so a fronted foreign egress reads domestic.
	fronted := rcxFacts{
		Origin:      rcxOriginDomestic,
		OpenedOnce:  true,
		Transit:     rcxProofProven,
		SupportsUDP: true,
	}

	if got := rcxAdmit(rcxTerrainNormal, fronted); got != rcxVerdictViable {
		t.Errorf("verdict = %v, want viable: this node was measured opening the world", got)
	}
	blind := fronted
	blind.OpenedOnce = false
	if got := rcxAdmit(rcxTerrainNormal, blind); got != rcxVerdictLastResort {
		t.Errorf("unmeasured verdict = %v, want last-resort: only geography speaks for it", got)
	}
}

func TestLatencyBucketOrdersTheUnmeasuredCrowdByTheHostDelayTest(t *testing.T) {
	tests := []struct {
		name string
		node rcxCandidate
		want uint8
	}{
		{name: "own median wins", node: rcxCandidate{MedianMs: 100, HostMs: 900}, want: 0},
		{name: "host delay orders the never-probed", node: rcxCandidate{HostMs: 60}, want: 0},
		{name: "a slow host delay is still an order", node: rcxCandidate{HostMs: 700}, want: 3},
		{name: "the host found it dead", node: rcxCandidate{HostDead: true}, want: 4},
		{name: "nobody measured anything", node: rcxCandidate{}, want: 2},
	}

	for _, tc := range tests {
		if got := rcxLatencyBucket(tc.node, rcxTestBands); got != tc.want {
			t.Errorf("%s: bucket = %d, want %d", tc.name, got, tc.want)
		}
	}
}

func TestCompareLatencyKeepsReliabilityAboveLatency(t *testing.T) {
	fastAndNew := rcxKey{latBucket: 0, evidence: rcxEvidenceNone, unproven: true}
	slowAndKnown := rcxKey{latBucket: 1, evidence: rcxEvidenceFreshProbe}

	if rcxCompare(fastAndNew, slowAndKnown) <= 0 {
		t.Error("a measured working node must beat a faster stranger")
	}
	if rcxCompareLatency(fastAndNew, slowAndKnown) <= 0 {
		t.Error("lowest-latency must not trade reachability evidence for milliseconds")
	}
}

func TestCompareRanksAProvenNodeAboveANeverSeenOneInTheSameBand(t *testing.T) {
	proven := rcxKey{latBucket: 2, order: 60_000}
	stranger := rcxKey{latBucket: 2, unproven: true, order: 1}

	if rcxCompare(proven, stranger) >= 0 {
		t.Error("inside one band the node that carried traffic here beats a hash winner: order is the last word, not the first")
	}
	if rcxCompareLatency(proven, stranger) >= 0 {
		t.Error("the latency strategy must break a band tie on history too")
	}
}

func TestAdmitBarsANodeMeasuredEgressingInsideTheCountry(t *testing.T) {
	// The open marker answered because the home network leaves that host alone.
	fronted := rcxFacts{
		Origin:      rcxOriginForeign,
		Exit:        rcxOriginDomestic,
		OpenWorld:   rcxProofProven,
		Transit:     rcxProofProven,
		SupportsUDP: true,
	}

	if got := rcxAdmit(rcxTerrainNormal, fronted); got != rcxVerdictLastResort {
		t.Errorf("normal verdict = %v, want last-resort: the traffic never leaves the country", got)
	}
	if got := rcxAdmit(rcxTerrainWhitelist, fronted); got != rcxVerdictLastResort {
		t.Errorf("whitelist verdict = %v, want last-resort until a domestic marker answers", got)
	}
	fronted.Domestic = rcxProofProven
	if got := rcxAdmit(rcxTerrainWhitelist, fronted); got != rcxVerdictViable {
		t.Errorf("whitelist verdict = %v, want viable: domestic services are the point there", got)
	}
}

func TestAdmitLetsAMeasuredForeignEgressVoidTheDomesticPrior(t *testing.T) {
	relayed := rcxFacts{
		Origin:      rcxOriginDomestic,
		Exit:        rcxOriginForeign,
		SupportsUDP: true,
	}

	if got := rcxAdmit(rcxTerrainNormal, relayed); got != rcxVerdictViable {
		t.Errorf("verdict = %v, want viable: the endpoint prior lost to a measurement", got)
	}
}

func TestCompareStableKeepsTheIncumbentAcrossLatencyBands(t *testing.T) {
	incumbent := rcxKey{latBucket: 2}
	fasterRival := rcxKey{latBucket: 0, challenger: true}

	if rcxCompareStable(incumbent, fasterRival) >= 0 {
		t.Error("stable must not swap a working server for a faster band")
	}
	if rcxCompare(incumbent, fasterRival) <= 0 {
		t.Error("balanced still reads the band before it reads who is in use")
	}

	betterEvidence := rcxKey{latBucket: 2, evidence: rcxEvidenceNone, challenger: true}
	if rcxCompareStable(betterEvidence, incumbent) <= 0 {
		t.Error("stable must still be moved by evidence the incumbent lacks")
	}
}

func TestCompareForNamesOneComparatorPerStrategy(t *testing.T) {
	sticky := rcxKey{latBucket: 2}
	quick := rcxKey{latBucket: 0, challenger: true}

	for _, tc := range []struct {
		strategy string
		holds    bool
	}{
		{rcxStrategyBalanced, false},
		{rcxStrategyLatency, false},
		{rcxStrategyStable, true},
		{rcxStrategySaver, true},
		{"", false},
	} {
		if holds := rcxCompareFor(tc.strategy)(sticky, quick) < 0; holds != tc.holds {
			t.Errorf("%q: holds incumbent = %v, want %v", tc.strategy, holds, tc.holds)
		}
	}
}

func TestNormalizedKeepsEveryShippedStrategy(t *testing.T) {
	for _, name := range []string{rcxStrategyBalanced, rcxStrategyLatency, rcxStrategyStable, rcxStrategySaver} {
		if got := (rcxConfig{Strategy: name}).normalized().Strategy; got != name {
			t.Errorf("%q normalized to %q", name, got)
		}
	}
	if got := (rcxConfig{Strategy: "invented"}).normalized().Strategy; got != rcxStrategyBalanced {
		t.Errorf("an unknown strategy degraded to %q", got)
	}
}
