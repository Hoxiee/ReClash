package rcx

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
		AbsCeilingMs:        500,
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
			latencyMs:  random.Intn(1000),
			recurrence: random.Intn(7),
			degraded:   random.Intn(2) == 1,
			misfit:     uint8(random.Intn(2)),
			unproven:   random.Intn(2) == 1,
			challenger: random.Intn(2) == 1,
			order:      random.Intn(100_000),
		})
	}

	for _, compare := range []func(rcxKey, rcxKey) int{rcxCompare, rcxCompareLatency, rcxCompareStable} {
		for _, a := range keys {
			if compare(a, a) != 0 {
				t.Fatalf("compare(%v, %v) != 0: the order must be irreflexive", a, a)
			}
			for _, b := range keys {
				if compare(a, b) != -compare(b, a) {
					t.Fatalf("compare is not antisymmetric for %v vs %v", a, b)
				}
				for _, c := range keys {
					if compare(a, b) < 0 && compare(b, c) < 0 && compare(a, c) >= 0 {
						t.Fatalf("compare is not transitive for %v < %v < %v", a, b, c)
					}
				}
			}
		}
	}
}

func TestCompareRanksVerdictAboveLatency(t *testing.T) {
	slowButOpen := rcxKey{verdict: rcxVerdictPreferred, latencyMs: 3}
	fastButUnproven := rcxKey{verdict: rcxVerdictViable, latencyMs: 0}

	if rcxCompare(slowButOpen, fastButUnproven) >= 0 {
		t.Error("a proven-open node must beat a faster unproven one: reachability is not tradeable for latency")
	}
}

func TestCompareRanksAFasterProbeAlongsideLiveTraffic(t *testing.T) {
	live := rcxNode("live", foreignProven())
	live.Evidence, live.MedianMs = rcxEvidenceLiveTraffic, 249
	fresh := rcxNode("fresh", foreignProven())
	fresh.MedianMs = 69
	in := rcxDecisionInput{Terrain: rcxTerrainNormal, Policy: rcxTestPolicy()}
	if rcxCompare(rcxKeyOf(live, in), rcxKeyOf(fresh, in)) <= 0 {
		t.Error("a fresh proven challenger must not be locked out by live traffic")
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
	fast.QualityConfirmed = true

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

func TestDecideHoldsAHealthyIncumbentAgainstAFasterHostPing(t *testing.T) {
	now := time.Unix(1_700_000_000, 0)
	slow := rcxNode("uk-1", foreignProven())
	slow.MedianMs, slow.HostMs = 0, 130
	sweden := rcxNode("se-1", foreignProven())
	sweden.MedianMs, sweden.HostMs = 0, 45

	input := rcxDecisionInput{
		Terrain:        rcxTerrainNormal,
		Incumbent:      "uk-1",
		IncumbentSince: now.Add(-time.Hour),
		Candidates:     []rcxCandidate{slow, sweden},
		Now:            now,
	}

	if got := rcxDecideAt(input); got.Switch || got.Reason != rcxReasonHold {
		t.Errorf("decision = %+v, want a hold: a healthy incumbent is not traded for a faster host-ping", got)
	}
}

func TestDecideRespectsAManualPinForLatencyOnly(t *testing.T) {
	now := time.Unix(1_700_000_000, 0)
	slow := rcxNode("nl-1", foreignProven())
	slow.MedianMs = 900
	fast := rcxNode("de-1", foreignProven())
	fast.MedianMs = 90
	fast.QualityConfirmed = true

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

func TestDecideDoesNotLatchAFasterDomesticNodeOnACensoredColdStart(t *testing.T) {
	home := rcxNode("moscow", domesticUntested())
	home.Evidence, home.MedianMs, home.HostMs = rcxEvidenceNone, 0, 38
	abroad := rcxNode("nl-1", foreignUntested())
	abroad.Evidence, abroad.MedianMs, abroad.HostMs = rcxEvidenceNone, 0, 120

	policy := rcxTestPolicy()
	policy.Censoring = true
	got := rcxDecideAt(rcxDecisionInput{
		Terrain:    rcxTerrainNormal,
		Candidates: []rcxCandidate{home, abroad},
		Policy:     policy,
	})

	if !got.Switch || got.To != "nl-1" {
		t.Fatalf("decision = %+v, want the foreign node, not the closer home ping", got)
	}
}

// A CDN-fronted home node reads foreign in the mmdb (Origin=foreign) yet its
// name tripped the cheap check to Suspect. Without the trust penalty its foreign
// origin would leave homeRisk at 1, tying a real foreign node, and its nearer
// host-ping would then latch it on a censored cold start.
func TestDecideSinksASuspectFrontedNodeUnderARealForeignNode(t *testing.T) {
	suspect := rcxNode("ru-fronted", foreignUntested())
	suspect.Facts.Trust = rcxTrustSuspect
	suspect.Evidence, suspect.MedianMs, suspect.HostMs = rcxEvidenceNone, 0, 30
	abroad := rcxNode("nl-1", foreignUntested())
	abroad.Evidence, abroad.MedianMs, abroad.HostMs = rcxEvidenceNone, 0, 140

	policy := rcxTestPolicy()
	policy.Censoring = true
	got := rcxDecideAt(rcxDecisionInput{
		Terrain:    rcxTerrainNormal,
		Candidates: []rcxCandidate{suspect, abroad},
		Policy:     policy,
	})

	if !got.Switch || got.To != "nl-1" {
		t.Fatalf("decision = %+v, want the foreign node over a nearer suspect", got)
	}
}

func TestDecideSinksAHomeEgressNodeThatOpenedTheWorld(t *testing.T) {
	// mmdb-foreign and it proved it reaches the open world, yet the egress echo
	// placed it in-country: the open proof must not buy it foreign parity.
	home := rcxNode("ru-fronted", foreignProven())
	home.Facts.HomeEgress = true
	home.MedianMs, home.HostMs = 0, 30
	abroad := rcxNode("nl-1", foreignProven())
	abroad.MedianMs, abroad.HostMs = 0, 140

	policy := rcxTestPolicy()
	policy.Censoring = true
	got := rcxDecideAt(rcxDecisionInput{
		Terrain:    rcxTerrainNormal,
		Candidates: []rcxCandidate{home, abroad},
		Policy:     policy,
	})

	if !got.Switch || got.To != "nl-1" {
		t.Fatalf("decision = %+v, want the real foreign exit over a home-egress node that merely opened", got)
	}
}

func TestDecideIgnoreAndAvoidBarANode(t *testing.T) {
	ignored := rcxNode("ignored", foreignProven())
	ignored.Ignore = true
	avoided := rcxNode("avoided", foreignProven())
	avoided.AvoidExit = true
	ok := rcxNode("ok", foreignProven())
	input := rcxDecisionInput{
		Terrain:    rcxTerrainNormal,
		Candidates: []rcxCandidate{ignored, avoided, ok},
		Policy:     rcxTestPolicy(),
	}
	if got := rcxDecideAt(input); got.To != "ok" {
		t.Fatalf("picked %q, want the only un-barred node", got.To)
	}
	if rcxEligible(ignored, input) || rcxEligible(avoided, input) {
		t.Fatal("a barred node stayed eligible")
	}
	if b := rcxBlockOf(ignored, input); b != rcxBlockIgnored {
		t.Fatalf("ignored block = %q", b)
	}
	if b := rcxBlockOf(avoided, input); b != rcxBlockAvoidExit {
		t.Fatalf("avoided block = %q", b)
	}
}

func TestDecideLastResortRuleCapsAPreferredNode(t *testing.T) {
	capped := rcxNode("capped", foreignProven())
	capped.RuleLastResort = true
	input := rcxDecisionInput{
		Terrain:    rcxTerrainNormal,
		Candidates: []rcxCandidate{capped},
		Policy:     rcxTestPolicy(),
	}
	if got := rcxDecideAt(input); got.Switch {
		t.Fatalf("decision = %+v, want no pick: normal terrain bars a last-resort-capped node", got)
	}
}

func TestDecidePreferBreaksATie(t *testing.T) {
	plain := rcxNode("plain", foreignProven())
	plain.Order = 1
	favoured := rcxNode("favoured", foreignProven())
	favoured.Order = 2
	favoured.Prefer = true
	input := rcxDecisionInput{
		Terrain:    rcxTerrainNormal,
		Candidates: []rcxCandidate{plain, favoured},
		Policy:     rcxTestPolicy(),
	}
	if got := rcxDecideAt(input); got.To != "favoured" {
		t.Fatalf("picked %q, want the preferred node to take the tie despite a higher order", got.To)
	}
}

// Two unmeasured foreign-origin nodes tie on homeRisk, so before the fix the
// nearer host-ping decided and a fronted home node (small ping) beat a real
// exit. On a censored network an unmeasured node must not rank by host-ping;
// the deterministic order breaks the tie until a probe measures either.
func TestDecideDoesNotRankUnmeasuredForeignNodesByHostPingWhenCensored(t *testing.T) {
	near := rcxNode("near", foreignUntested())
	near.Evidence, near.MedianMs, near.HostMs = rcxEvidenceNone, 0, 25
	near.Order = 5
	far := rcxNode("far", foreignUntested())
	far.Evidence, far.MedianMs, far.HostMs = rcxEvidenceNone, 0, 300
	far.Order = 1

	policy := rcxTestPolicy()
	policy.Censoring = true
	got := rcxDecideAt(rcxDecisionInput{
		Terrain:    rcxTerrainNormal,
		Candidates: []rcxCandidate{near, far},
		Policy:     policy,
	})

	if !got.Switch || got.To != "far" {
		t.Fatalf("decision = %+v, want the lower hash order, not the nearer host-ping", got)
	}
}

// The host-ping order still applies off a censored network, where a small ping
// is a genuine proximity signal and no censor sits between the node and a site.
func TestDecideStillOrdersUnmeasuredNodesByHostPingWhenNotCensored(t *testing.T) {
	near := rcxNode("near", foreignUntested())
	near.Evidence, near.MedianMs, near.HostMs = rcxEvidenceNone, 0, 25
	near.Order = 5
	far := rcxNode("far", foreignUntested())
	far.Evidence, far.MedianMs, far.HostMs = rcxEvidenceNone, 0, 300
	far.Order = 1

	got := rcxDecideAt(rcxDecisionInput{
		Terrain:    rcxTerrainNormal,
		Candidates: []rcxCandidate{near, far},
		Policy:     rcxTestPolicy(),
	})

	if !got.Switch || got.To != "near" {
		t.Fatalf("decision = %+v, want the nearer host-ping when no censor is present", got)
	}
}

func TestDecideDemotesAThrottledNodeWithoutEvictingIt(t *testing.T) {
	now := time.Unix(1_700_000_000, 0)
	throttled := rcxNode("nl-1", foreignProven())
	throttled.MedianMs = 90
	throttled.Degraded = true
	healthy := rcxNode("de-1", foreignProven())
	healthy.MedianMs = 280
	healthy.QualityConfirmed = true

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
	if got.Reason != rcxReasonReliabilityGain {
		t.Errorf("reason = %s, want %s", got.Reason, rcxReasonReliabilityGain)
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

func TestAgedForeignProofStillBeatsAFreshSlowRival(t *testing.T) {
	// Aged-to-Unknown proof (OpenedOnce) must tie a fresh proof at Preferred so latency decides.
	sweden := rcxFacts{Origin: rcxOriginForeign, OpenedOnce: true, Transit: rcxProofProven, SupportsUDP: true}
	if got := rcxAdmit(rcxTerrainNormal, sweden); got != rcxVerdictPreferred {
		t.Fatalf("aged-but-opened foreign verdict = %v, want preferred", got)
	}
	if got := rcxAdmit(rcxTerrainNormal, foreignProven()); got != rcxVerdictPreferred {
		t.Fatalf("freshly proven verdict = %v, want preferred", got)
	}

	fast := rcxNode("sweden", sweden)
	fast.MedianMs = 50
	slow := rcxNode("peru", foreignProven())
	slow.MedianMs = 435
	got := rcxDecideAt(rcxDecisionInput{
		Terrain:    rcxTerrainNormal,
		Candidates: []rcxCandidate{slow, fast},
	})
	if got.To != "sweden" {
		t.Fatalf("cold pick = %q, want sweden(50ms) over peru(435ms) once verdict ties", got.To)
	}
}

func TestSlowIncumbentYieldsWithinDwellToAFastNode(t *testing.T) {
	now := time.Unix(1_700_000_000, 0)
	slow := rcxNode("slow", foreignProven())
	slow.MedianMs = 1800 // past the top band (1200)
	fast := rcxNode("fast", foreignProven())
	fast.MedianMs, fast.QualityConfirmed = 50, true

	got := rcxDecideAt(rcxDecisionInput{
		Terrain: rcxTerrainNormal, Incumbent: "slow",
		IncumbentSince: now.Add(-10 * time.Second), // still inside dwell
		Candidates:     []rcxCandidate{slow, fast}, Now: now,
	})
	if !got.Switch || got.To != "fast" {
		t.Fatalf("decision = %+v, want an eager escape from a slow incumbent", got)
	}

	// A challenger also past the ceiling does not trigger the eager escape.
	other := rcxNode("other", foreignProven())
	other.MedianMs, other.QualityConfirmed = 1300, true
	held := rcxDecideAt(rcxDecisionInput{
		Terrain: rcxTerrainNormal, Incumbent: "slow",
		IncumbentSince: now.Add(-10 * time.Second),
		Candidates:     []rcxCandidate{slow, other}, Now: now,
	})
	if held.Switch {
		t.Fatalf("decision = %+v, want dwell-hold when no rival is inside the bands", held)
	}
}

func TestBreakerNodeStaysSecondTierBehindAWorkingNormalNode(t *testing.T) {
	normal := rcxNode("normal", rcxFacts{Origin: rcxOriginForeign, OpenedOnce: true, Transit: rcxProofProven, SupportsUDP: true})
	normal.MedianMs = 200
	lte := rcxNode("lte", foreignProven())
	lte.Facts.Breaker = true
	lte.MedianMs = 40
	got := rcxDecideAt(rcxDecisionInput{Terrain: rcxTerrainNormal, Candidates: []rcxCandidate{lte, normal}})
	if got.To != "normal" {
		t.Fatalf("cold pick = %q, want the normal node over a faster breaker: LTE is the second step", got.To)
	}
}

func TestUpgradeReturnsFromASlowProvenIncumbentToAFastRival(t *testing.T) {
	peru := rcxNode("peru", foreignProven())
	peru.MedianMs = 700
	sweden := rcxNode("sweden", rcxFacts{Origin: rcxOriginForeign, OpenedOnce: true, Transit: rcxProofProven, SupportsUDP: true})
	sweden.MedianMs = 50
	sweden.QualityConfirmed = true
	got := rcxDecideAt(rcxDecisionInput{
		Terrain:        rcxTerrainNormal,
		Incumbent:      "peru",
		IncumbentSince: time.Unix(1_700_000_000, 0).Add(-time.Hour),
		Candidates:     []rcxCandidate{peru, sweden},
	})
	if !got.Switch || got.To != "sweden" {
		t.Fatalf("decision = %+v, want an upgrade back to the fast sweden node", got)
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
	// An unmeasured stranger carries the maxint sentinel rcxKeyOf stamps on it, so
	// it still loses to any measured node without evidence needing to outrank speed.
	stranger := rcxKey{latencyMs: int(^uint(0) >> 1), evidence: rcxEvidenceNone, unproven: true}
	measured := rcxKey{latencyMs: 90, evidence: rcxEvidenceFreshProbe}

	if rcxCompare(stranger, measured) <= 0 {
		t.Error("a measured working node must beat an unmeasured stranger")
	}
	if rcxCompareLatency(stranger, measured) <= 0 {
		t.Error("lowest-latency must not pick an unmeasured stranger over a measured node")
	}
}

func TestCompareFastIdleBeatsSlowBusyInTier(t *testing.T) {
	fastIdle := rcxKey{latencyMs: 50, evidence: rcxEvidenceNone}
	slowBusy := rcxKey{latencyMs: 200, evidence: rcxEvidenceLiveTraffic}

	if rcxCompare(fastIdle, slowBusy) >= 0 {
		t.Error("inside one tier the faster node must beat a slower one merely carrying bytes")
	}
}

func TestCompareRanksAProvenNodeAboveANeverSeenOne(t *testing.T) {
	proven := rcxKey{latencyMs: 2, order: 60_000}
	stranger := rcxKey{latencyMs: 2, unproven: true, order: 1}

	if rcxCompare(proven, stranger) >= 0 {
		t.Error("a proven node must outrank an unproven node regardless of source position")
	}
	if rcxCompareLatency(proven, stranger) >= 0 {
		t.Error("the latency strategy must rank proof before latency too")
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

func TestCompareStableRanksLatencyBeforeIncumbency(t *testing.T) {
	incumbent := rcxKey{latencyMs: 2}
	fasterRival := rcxKey{latencyMs: 0, challenger: true}

	if rcxCompareStable(incumbent, fasterRival) <= 0 {
		t.Error("stable must shortlist a faster challenger before applying promotion gates")
	}
	if rcxCompare(incumbent, fasterRival) <= 0 {
		t.Error("balanced must also rank latency before incumbency")
	}

	betterEvidence := rcxKey{latencyMs: 2, evidence: rcxEvidenceNone, challenger: true}
	if rcxCompareStable(betterEvidence, incumbent) <= 0 {
		t.Error("stable must still be moved by evidence the incumbent lacks")
	}
}

func TestCompareForNamesOneComparatorPerStrategy(t *testing.T) {
	sticky := rcxKey{latencyMs: 2}
	quick := rcxKey{latencyMs: 0, challenger: true}

	for _, tc := range []struct {
		strategy string
		holds    bool
	}{
		{rcxStrategyBalanced, false},
		{rcxStrategyLatency, false},
		{rcxStrategyStable, false},
		{rcxStrategySaver, false},
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

func TestDecideDoesNotRushAVerdictGainForAStillOpenIncumbent(t *testing.T) {
	now := time.Unix(1_700_000_000, 0)
	// A proven-open specialist ranks Viable in Normal while a proven-open sibling
	// ranks Preferred; the tier gap must not evict a node that still reaches out.
	breaker := rcxNode("br-1", foreignProven())
	breaker.Facts.Breaker = true
	rival := rcxNode("de-1", foreignProven())

	got := rcxDecideAt(rcxDecisionInput{
		Terrain:        rcxTerrainNormal,
		Incumbent:      "br-1",
		IncumbentSince: now,
		Candidates:     []rcxCandidate{breaker, rival},
		Now:            now.Add(time.Second),
	})
	if got.Switch {
		t.Fatalf("decision = %+v, want no rush: a still-open incumbent that only lost tier waits out dwell", got)
	}
}

func TestLapsedDisproofDoesNotLatchBackToPreferred(t *testing.T) {
	// A foreign node opens once, then fails; when the disproof ages to Unknown it
	// must not ride the OpenedOnce latch back to Preferred without a fresh probe.
	ledger, now := rcxTestLedger()
	ledger.NoteProbe("node", "env", rcxRoleOpen, rcxProbeOK, 50, now)
	ledger.NoteProbe("node", "env", rcxRoleOpen, rcxProbeFail, 0, now.Add(time.Minute))

	fresh := ledger.Facts("node", "env", true, now.Add(time.Minute), rcxLedgerProofTTL)
	if fresh.OpenWorld != rcxProofDisproven {
		t.Fatalf("fresh disproof = %v, want disproven", fresh.OpenWorld)
	}

	lapsed := ledger.Facts("node", "env", true, now.Add(rcxLedgerProofTTL*4), rcxLedgerProofTTL)
	if lapsed.OpenWorld != rcxProofUnknown {
		t.Fatalf("aged disproof OpenWorld = %v, want unknown", lapsed.OpenWorld)
	}
	if !lapsed.OpenLapsed {
		t.Fatalf("aged disproof should set OpenLapsed")
	}
	if !lapsed.OpenedOnce {
		t.Fatalf("OpenedOnce latch should survive the disproof")
	}
	lapsed.Origin = rcxOriginForeign
	if got := rcxAdmit(rcxTerrainNormal, lapsed); got == rcxVerdictPreferred {
		t.Fatalf("lapsed-disproof node latched back to Preferred, want a lower tier")
	}

	ledger.NoteProbe("node", "env", rcxRoleOpen, rcxProbeOK, 50, now.Add(rcxLedgerProofTTL*4))
	reproven := ledger.Facts("node", "env", true, now.Add(rcxLedgerProofTTL*4), rcxLedgerProofTTL)
	reproven.Origin = rcxOriginForeign
	if got := rcxAdmit(rcxTerrainNormal, reproven); got != rcxVerdictPreferred {
		t.Fatalf("a fresh open probe must restore Preferred, got %v", got)
	}
}

func TestDecideOrdersUnmeasuredProvenByThirtyMsSteps(t *testing.T) {
	near := rcxNode("near", foreignProven())
	near.MedianMs, near.HostMs = 0, 50
	twin := rcxNode("twin", foreignProven())
	twin.MedianMs, twin.HostMs = 0, 55
	far := rcxNode("far", foreignProven())
	far.MedianMs, far.HostMs = 0, 140
	policy := rcxTestPolicy()
	policy.Censoring = true
	input := rcxDecisionInput{Terrain: rcxTerrainNormal, Policy: policy}

	kNear, kTwin, kFar := rcxKeyOf(near, input), rcxKeyOf(twin, input), rcxKeyOf(far, input)
	if kNear.latencyMs != kTwin.latencyMs {
		t.Fatalf("50 and 55 fall in one 30ms step, want a tie: %d vs %d", kNear.latencyMs, kTwin.latencyMs)
	}
	if kNear.latencyMs >= kFar.latencyMs {
		t.Fatalf("50 must rank ahead of 140: %d vs %d", kNear.latencyMs, kFar.latencyMs)
	}
}
