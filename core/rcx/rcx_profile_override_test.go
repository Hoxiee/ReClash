package rcx

import (
	"reflect"
	"testing"
)

func profileConfig(t *testing.T, yaml string) rcxConfig {
	t.Helper()
	c := rcxConfig{Strategy: rcxStrategyBalanced, ProfileYAML: yaml}
	return c.normalized()
}

// A would-be-Preferred node under the shipped rules.
func preferredFacts() rcxFacts {
	return rcxFacts{OpenWorld: rcxProofProven, Exit: rcxOriginForeign, Trust: rcxTrusted}
}

func TestEmptyProfileKeepsShippedDefaults(t *testing.T) {
	p := rcxDefaultConfig().policy()
	if p.Admission != nil {
		t.Fatal("empty profile should carry no admission override")
	}
	abs, pct := p.switchThresholds()
	if abs != 30 || pct != 20 {
		t.Fatalf("empty profile switch thresholds = %d/%d, want 30/20", abs, pct)
	}
	if !reflect.DeepEqual(p.LatencyBands, []int{80, 120, 180, 320}) {
		t.Fatalf("empty profile bands = %v, want shipped balanced", p.LatencyBands)
	}
}

// Carrying the shipped profile verbatim must be byte-for-byte identical to carrying
// nothing: the YAML face cannot change what the engine ranks and admits.
func TestDefaultProfileCarriedIsNoOp(t *testing.T) {
	data, err := rcxDefaultDecisionProfile().marshalYAML()
	if err != nil {
		t.Fatalf("marshal default profile: %v", err)
	}
	p := profileConfig(t, string(data)).policy()
	if !reflect.DeepEqual(p.Admission, rcxDefaultAdmitRules()) {
		t.Fatal("default profile changed admission rules")
	}
	abs, pct := p.switchThresholds()
	if abs != 30 || pct != 20 {
		t.Fatalf("default profile switch = %d/%d, want 30/20", abs, pct)
	}
}

func TestProfileTightensAdmission(t *testing.T) {
	facts := preferredFacts()
	if got := rcxAdmitWith(rcxTerrainNormal, facts, nil); got != rcxVerdictPreferred {
		t.Fatalf("default admits %v, want preferred", got)
	}
	rejectAll := "schema: 1\nadmission:\n  - verdict: reject\n"
	rules := profileConfig(t, rejectAll).policy().Admission
	if got := rcxAdmitWith(rcxTerrainNormal, facts, rules); got != rcxVerdictReject {
		t.Fatalf("reject-all profile admits %v, want reject", got)
	}
}

func TestProfileOverridesStrategy(t *testing.T) {
	yaml := "schema: 1\nstrategies:\n  balanced:\n    bands: [10, 20, 30, 40]\n    switchAbsMs: 7\n    switchPct: 3\n"
	p := profileConfig(t, yaml).policy()
	if abs, pct := p.switchThresholds(); abs != 7 || pct != 3 {
		t.Fatalf("override switch = %d/%d, want 7/3", abs, pct)
	}
	if !reflect.DeepEqual(p.LatencyBands, []int{10, 20, 30, 40}) {
		t.Fatalf("override bands = %v, want [10 20 30 40]", p.LatencyBands)
	}
}

func TestUnknownSchemaAndGarbageFallBack(t *testing.T) {
	for _, yaml := range []string{
		"schema: 999\nadmission:\n  - verdict: reject\n",
		"this: is: not: valid: yaml\n",
		"schema: 1\nadmission:\n  - when: [transit is nope]\n    verdict: reject\n",
	} {
		p := profileConfig(t, yaml).policy()
		if p.Admission != nil {
			t.Fatalf("profile %q should carry no admission override", yaml)
		}
		if abs, pct := p.switchThresholds(); abs != 30 || pct != 20 {
			t.Fatalf("profile %q should keep shipped switch, got %d/%d", yaml, abs, pct)
		}
	}
}

// The B-layer monotonic clamp: a profile that tries to admit everything as
// Preferred can loosen nothing — every verdict stays pinned to the shipped ceiling
// over the whole fact space, which is also how the A-layer safety floor survives.
func TestLooseningProfileIsClampedToDefault(t *testing.T) {
	promoteAll := "schema: 1\nadmission:\n  - verdict: preferred\n"
	rules := profileConfig(t, promoteAll).policy().Admission
	if len(rules) == 0 {
		t.Fatal("promote-all profile parsed to no rules")
	}
	proofs := []rcxProof{rcxProofUnknown, rcxProofProven, rcxProofDisproven}
	origins := []rcxOrigin{rcxOriginUnknown, rcxOriginForeign, rcxOriginDomestic}
	trusts := []rcxTrust{rcxTrustUnknown, rcxTrustSuspect, rcxTrusted, rcxTrustBranded}
	bools := []bool{false, true}
	terrains := []rcxTerrain{rcxTerrainUnknown, rcxTerrainNormal, rcxTerrainWhitelist, rcxTerrainPortal, rcxTerrainOffline}
	for _, terrain := range terrains {
		for _, origin := range origins {
			for _, exit := range origins {
				for _, openWorld := range proofs {
					for _, domestic := range proofs {
						for _, transit := range proofs {
							for _, trust := range trusts {
								for _, breaker := range bools {
									for _, openedOnce := range bools {
										for _, openLapsed := range bools {
											for _, nameHome := range bools {
												f := rcxFacts{
													Origin: origin, Exit: exit, OpenedOnce: openedOnce,
													OpenWorld: openWorld, OpenLapsed: openLapsed, Domestic: domestic,
													Transit: transit, Breaker: breaker, Trust: trust, NameHome: nameHome,
												}
												if got, want := rcxAdmitWith(terrain, f, rules), rcxAdmit(terrain, f); got != want {
													t.Fatalf("clamp %v %+v: got %v want %v", terrain, f, got, want)
												}
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
}

// A profile may omit a safety-floor reject, but the clamp reinstates it: a branded
// node a promote-all profile would admit is still rejected.
func TestProfileCannotRemoveSafetyFloor(t *testing.T) {
	promoteAll := "schema: 1\nadmission:\n  - verdict: preferred\n"
	rules := profileConfig(t, promoteAll).policy().Admission
	branded := rcxFacts{Trust: rcxTrustBranded, OpenWorld: rcxProofProven, Exit: rcxOriginForeign}
	if got := rcxAdmitWith(rcxTerrainWhitelist, branded, rules); got != rcxVerdictReject {
		t.Fatalf("branded node admitted %v under promote-all, want reject", got)
	}
}

func TestDefaultProbeCadenceIsShipped(t *testing.T) {
	if got := rcxDefaultConfig().probe(); got != rcxDefaultProbeSection() {
		t.Fatalf("default config probe = %+v, want shipped %+v", got, rcxDefaultProbeSection())
	}
}

func TestProfileOverridesProbe(t *testing.T) {
	yaml := "schema: 1\nprobe:\n  concurrency: 5\n  staggerMs: 100\n"
	got := profileConfig(t, yaml).probe()
	if got != (rcxProbeSection{Concurrency: 5, StaggerMs: 100}) {
		t.Fatalf("probe override = %+v, want {5 100}", got)
	}
}

func TestProbeSectionOutOfRangeFallsBack(t *testing.T) {
	def := rcxDefaultProbeSection()
	cases := []struct {
		yaml string
		want rcxProbeSection
	}{
		{"schema: 1\nprobe:\n  concurrency: 0\n  staggerMs: 100\n", rcxProbeSection{def.Concurrency, 100}},
		{"schema: 1\nprobe:\n  concurrency: 999\n  staggerMs: 100\n", rcxProbeSection{def.Concurrency, 100}},
		{"schema: 1\nprobe:\n  concurrency: 5\n  staggerMs: -1\n", rcxProbeSection{5, def.StaggerMs}},
		{"schema: 1\nprobe:\n  concurrency: 5\n  staggerMs: 999999\n", rcxProbeSection{5, def.StaggerMs}},
	}
	for _, tc := range cases {
		if got := profileConfig(t, tc.yaml).probe(); got != tc.want {
			t.Fatalf("%q: got %+v want %+v", tc.yaml, got, tc.want)
		}
	}
}

func TestEffectiveProfileOfDefaultIsShipped(t *testing.T) {
	got := rcxDefaultConfig().normalized().effectiveProfile()
	if !reflect.DeepEqual(got, rcxDefaultDecisionProfile()) {
		t.Fatalf("default effective profile drifted:\n got: %+v\nwant: %+v", got, rcxDefaultDecisionProfile())
	}
}

func TestEffectiveProfileReflectsOverride(t *testing.T) {
	yaml := "schema: 1\nprobe:\n  concurrency: 5\n  staggerMs: 100\nadmission:\n  - verdict: reject\n"
	eff := profileConfig(t, yaml).effectiveProfile()
	if eff.Probe != (rcxProbeSection{Concurrency: 5, StaggerMs: 100}) {
		t.Fatalf("effective probe = %+v, want {5 100}", eff.Probe)
	}
	if len(eff.Admission) != 1 {
		t.Fatalf("effective admission = %d rules, want 1 override rule", len(eff.Admission))
	}
	data, err := eff.marshalYAML()
	if err != nil {
		t.Fatalf("marshal effective: %v", err)
	}
	back, err := rcxDecisionProfileFromYAML(data)
	if err != nil {
		t.Fatalf("reparse effective: %v", err)
	}
	if !reflect.DeepEqual(back, eff) {
		t.Fatal("effective profile does not round-trip")
	}
}

func TestEngineExportProfileRoundTrips(t *testing.T) {
	engine := newTestEngine(newFakeRuntime(), "ru")
	data := engine.ExportProfile()
	if len(data) == 0 {
		t.Fatal("ExportProfile returned nothing")
	}
	if _, err := rcxDecisionProfileFromYAML(data); err != nil {
		t.Fatalf("exported profile does not parse: %v", err)
	}
	data[0] = 'X'
	if engine.ExportProfile()[0] == 'X' {
		t.Fatal("ExportProfile handed out a mutable reference to engine state")
	}
}
