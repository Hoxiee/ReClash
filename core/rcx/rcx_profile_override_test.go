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
	def := rcxDefaultProbeSection()
	got := profileConfig(t, yaml).probe()
	want := rcxProbeSection{Concurrency: 5, StaggerMs: 100, BudgetPerHour: def.BudgetPerHour, Reserve: def.Reserve}
	if got != want {
		t.Fatalf("probe override = %+v, want %+v", got, want)
	}
}

func TestProbeSectionOutOfRangeFallsBack(t *testing.T) {
	def := rcxDefaultProbeSection()
	cases := []struct {
		yaml string
		want rcxProbeSection
	}{
		{"schema: 1\nprobe:\n  concurrency: 0\n  staggerMs: 100\n", rcxProbeSection{Concurrency: def.Concurrency, StaggerMs: 100, BudgetPerHour: def.BudgetPerHour, Reserve: def.Reserve}},
		{"schema: 1\nprobe:\n  concurrency: 999\n  staggerMs: 100\n", rcxProbeSection{Concurrency: def.Concurrency, StaggerMs: 100, BudgetPerHour: def.BudgetPerHour, Reserve: def.Reserve}},
		{"schema: 1\nprobe:\n  concurrency: 5\n  staggerMs: -1\n", rcxProbeSection{Concurrency: 5, StaggerMs: def.StaggerMs, BudgetPerHour: def.BudgetPerHour, Reserve: def.Reserve}},
		{"schema: 1\nprobe:\n  concurrency: 5\n  staggerMs: 999999\n", rcxProbeSection{Concurrency: 5, StaggerMs: def.StaggerMs, BudgetPerHour: def.BudgetPerHour, Reserve: def.Reserve}},
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
	def := rcxDefaultProbeSection()
	eff := profileConfig(t, yaml).effectiveProfile()
	wantProbe := rcxProbeSection{Concurrency: 5, StaggerMs: 100, BudgetPerHour: def.BudgetPerHour, Reserve: def.Reserve}
	if eff.Probe != wantProbe {
		t.Fatalf("effective probe = %+v, want %+v", eff.Probe, wantProbe)
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

func TestProfileStateReportsFate(t *testing.T) {
	cases := []struct {
		name string
		yaml string
		want rcxProfileState
	}{
		{"absent", "", rcxProfileState{}},
		{"valid", "schema: 1\nprobe:\n  concurrency: 3\n  staggerMs: 50\n", rcxProfileState{Present: true, Valid: true, Schema: 1, Overrides: []string{"probe"}}},
		{"future-schema", "schema: 99\n", rcxProfileState{Present: true, Schema: 99, Reason: rcxProfileReasonSchema}},
		{"garbage", "this: is: not: valid: yaml\n", rcxProfileState{Present: true, Reason: rcxProfileReasonInvalid}},
	}
	for _, tc := range cases {
		got := profileConfig(t, tc.yaml).profileState
		if !reflect.DeepEqual(got, tc.want) {
			t.Fatalf("%s: profile state = %+v, want %+v", tc.name, got, tc.want)
		}
	}
}

func TestProfileDefinedStrategyIsSelectable(t *testing.T) {
	yaml := "schema: 1\nstrategies:\n  aggressive:\n    bands: [40, 70, 110, 180]\n    switchAbsMs: 10\n    switchPct: 5\n"
	c := rcxConfig{Strategy: "aggressive", ProfileYAML: yaml}.normalized()
	if c.Strategy != "aggressive" {
		t.Fatalf("Strategy reset to %q, want aggressive", c.Strategy)
	}
	p := c.policy()
	if abs, pct := p.switchThresholds(); abs != 10 || pct != 5 {
		t.Fatalf("switch = %d/%d, want 10/5", abs, pct)
	}
	if !reflect.DeepEqual(p.LatencyBands, []int{40, 70, 110, 180}) {
		t.Fatalf("bands = %v, want [40 70 110 180]", p.LatencyBands)
	}
	found := false
	for _, n := range c.strategyNames() {
		if n == "aggressive" {
			found = true
		}
	}
	if !found {
		t.Fatalf("strategyNames %v missing the profile strategy", c.strategyNames())
	}
}

func TestUnknownStrategyStillResets(t *testing.T) {
	c := rcxConfig{Strategy: "nonexistent"}.normalized()
	if c.Strategy != rcxStrategyBalanced {
		t.Fatalf("unknown strategy = %q, want balanced", c.Strategy)
	}
}

func TestLatencyBandsFollowStrategy(t *testing.T) {
	c := rcxConfig{Strategy: rcxStrategyBalanced}.normalized()
	if !reflect.DeepEqual(c.latencyBandsFor(rcxStrategyLatency), rcxDefaultLatencyBandsFor(rcxStrategyLatency)) {
		t.Fatal("latencyBandsFor did not resolve the lowest-latency edges")
	}
	if reflect.DeepEqual(c.latencyBandsFor(rcxStrategyLatency), c.latencyBandsFor(rcxStrategyStable)) {
		t.Fatal("two strategies resolved to the same bands")
	}
}

func TestLanePolicyMovesBandsWithStrategy(t *testing.T) {
	engine := newTestEngine(newFakeRuntime(), "ru")
	p := engine.lanePolicy(rcxLaneConfig{Strategy: rcxStrategyLatency})
	if p.Strategy != rcxStrategyLatency {
		t.Fatalf("lane strategy = %q, want lowest-latency", p.Strategy)
	}
	if !reflect.DeepEqual(p.LatencyBands, engine.cfg.latencyBandsFor(rcxStrategyLatency)) {
		t.Fatalf("lane bands %v did not follow the lane strategy", p.LatencyBands)
	}
}

func TestProfileLadderIsAdopted(t *testing.T) {
	yaml := "schema: 1\nladder:\n  - rung: verdict\n    enabled: true\n  - rung: latency\n    enabled: true\n"
	c := rcxConfig{Strategy: rcxStrategyBalanced, ProfileYAML: yaml}.normalized()
	got := c.ladder()
	if len(got) != 2 || got[0].ID != rcxRungVerdict || got[1].ID != rcxRungLatency {
		t.Fatalf("profile ladder not adopted: %+v", got)
	}
}

func TestDirectLadderWinsOverProfileLadder(t *testing.T) {
	yaml := "schema: 1\nladder:\n  - rung: verdict\n    enabled: true\n  - rung: latency\n    enabled: true\n"
	direct := []rcxRungSpec{
		{ID: rcxRungVerdict, Enabled: true},
		{ID: rcxRungHomeRisk, Enabled: true},
		{ID: rcxRungLatency, Enabled: true},
	}
	c := rcxConfig{Strategy: rcxStrategyBalanced, ProfileYAML: yaml, Ladder: direct}.normalized()
	if len(c.ladder()) != 3 {
		t.Fatalf("direct ladder should win over profile ladder, got %+v", c.ladder())
	}
}

func TestProfileInvalidStrategyFieldsFenced(t *testing.T) {
	yaml := "schema: 1\nstrategies:\n  stable:\n    bands: [300, 100]\n    switchAbsMs: 50\n    switchPct: 30\n  wild:\n    bands: [-5, 0]\n    switchAbsMs: -1\n    switchPct: 999\n"
	c := rcxConfig{Strategy: "wild", ProfileYAML: yaml}.normalized()
	stable := rcxStrategyProfileFrom(c.resolvedStrategies(), rcxStrategyStable)
	if !reflect.DeepEqual(stable.LatencyBands, rcxStrategyProfiles[rcxStrategyStable].LatencyBands) {
		t.Fatalf("stable bands not fenced to shipped: %v", stable.LatencyBands)
	}
	bal := rcxStrategyProfiles[rcxStrategyBalanced]
	wild := rcxStrategyProfileFrom(c.resolvedStrategies(), "wild")
	if !reflect.DeepEqual(wild.LatencyBands, bal.LatencyBands) {
		t.Fatalf("new strategy bands not fenced to balanced: %v", wild.LatencyBands)
	}
	if wild.SwitchAbsMs != bal.SwitchAbsMs || wild.SwitchPct != bal.SwitchPct {
		t.Fatalf("new strategy switch not fenced: %+v", wild)
	}
}

func TestProfileOverridesAreListed(t *testing.T) {
	yaml := "schema: 1\nladder:\n  - rung: verdict\n    enabled: true\n  - rung: latency\n    enabled: true\nadmission:\n  - verdict: reject\nprobe:\n  concurrency: 6\n  staggerMs: 20\n"
	st := profileConfig(t, yaml).profileState
	if !reflect.DeepEqual(st.Overrides, []string{"ladder", "admission", "probe"}) {
		t.Fatalf("overrides = %v, want [ladder admission probe]", st.Overrides)
	}
}

func TestProbeBudgetAndReserveFloored(t *testing.T) {
	def := rcxDefaultProbeSection()
	cases := []struct {
		name string
		yaml string
		want rcxProbeSection
	}{
		{
			"budget below floor falls back",
			"schema: 1\nprobe:\n  concurrency: 2\n  staggerMs: 250\n  budgetPerHour: 10\n  reserve: 40\n",
			rcxProbeSection{Concurrency: 2, StaggerMs: 250, BudgetPerHour: def.BudgetPerHour, Reserve: 40},
		},
		{
			"budget above ceil falls back",
			"schema: 1\nprobe:\n  concurrency: 2\n  staggerMs: 250\n  budgetPerHour: 99999\n  reserve: 40\n",
			rcxProbeSection{Concurrency: 2, StaggerMs: 250, BudgetPerHour: def.BudgetPerHour, Reserve: 40},
		},
		{
			"reserve below floor is clamped up",
			"schema: 1\nprobe:\n  concurrency: 2\n  staggerMs: 250\n  budgetPerHour: 240\n  reserve: 1\n",
			rcxProbeSection{Concurrency: 2, StaggerMs: 250, BudgetPerHour: 240, Reserve: rcxProbeReserveFloor},
		},
		{
			"reserve cannot exceed half the budget",
			"schema: 1\nprobe:\n  concurrency: 2\n  staggerMs: 250\n  budgetPerHour: 100\n  reserve: 90\n",
			rcxProbeSection{Concurrency: 2, StaggerMs: 250, BudgetPerHour: 100, Reserve: 50},
		},
	}
	for _, tc := range cases {
		if got := profileConfig(t, tc.yaml).probe(); got != tc.want {
			t.Fatalf("%s: got %+v want %+v", tc.name, got, tc.want)
		}
	}
}

func TestMeteredProbeVariantSwapsInAndResizesBudget(t *testing.T) {
	yaml := "schema: 1\nprobe:\n  concurrency: 4\n  staggerMs: 250\n  budgetPerHour: 240\n  reserve: 40\n" +
		"  metered:\n    concurrency: 1\n    staggerMs: 1000\n    budgetPerHour: 60\n    reserve: 40\n"
	runtime := newFakeRuntime()
	engine := newTestEngine(runtime, "")
	config := testConfig("")
	config.ProfileYAML = yaml
	engine.applyConfigLocked(config)

	if got := engine.budget.Remaining(runtime.Now()); got != 240 {
		t.Fatalf("unmetered budget = %d, want 240", got)
	}
	if eff := engine.effectiveProbe(); eff.Concurrency != 4 {
		t.Fatalf("unmetered concurrency = %d, want 4", eff.Concurrency)
	}

	engine.applyNetwork(rcxNetworkPayload{Transport: "cellular", Carrier: "TestCarrier", Metered: true, Validated: true})
	eff := engine.effectiveProbe()
	if eff.Concurrency != 1 || eff.BudgetPerHour != 60 || eff.Reserve != 30 {
		t.Fatalf("metered probe = %+v, want {1 1000 60 30}", eff)
	}
	if got := engine.budget.Remaining(runtime.Now()); got != 60 {
		t.Fatalf("metered budget = %d, want 60", got)
	}
}

func TestTerrainDefaultsOnAndSectionDisables(t *testing.T) {
	if profileConfig(t, "schema: 1\nadmission:\n  - verdict: reject\n").terrainDisabled {
		t.Fatal("a profile without a terrain section must keep terrain on")
	}
	off := profileConfig(t, "schema: 1\nterrain:\n  enabled: false\n")
	if !off.terrainDisabled {
		t.Fatal("terrain: {enabled: false} must disable terrain")
	}
	if !containsString(off.profileState.Overrides, "terrain") {
		t.Fatalf("overrides %v should list terrain", off.profileState.Overrides)
	}
	on := profileConfig(t, "schema: 1\nterrain:\n  enabled: true\n")
	if on.terrainDisabled {
		t.Fatal("terrain: {enabled: true} must keep terrain on")
	}
}

func TestDisabledTerrainPinsNormalAndSkipsReach(t *testing.T) {
	runtime := newFakeRuntime()
	engine := newTestEngine(runtime, "")
	config := testConfig("")
	config.ProfileYAML = "schema: 1\nterrain:\n  enabled: false\n"
	config.CanaryForeign = []string{"1.1.1.1:443"}
	engine.applyConfigLocked(config)
	engine.terrain.observe(rcxTerrainWhitelist, runtime.Now())

	if got := engine.terrainCurrent(); got != rcxTerrainNormal {
		t.Fatalf("disabled terrain = %v, want normal", got)
	}
	engine.startReach()
	if engine.reaching || !engine.lastReachAt.IsZero() {
		t.Fatal("disabled terrain must not start a reach round")
	}
}
