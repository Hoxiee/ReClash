package rcx

import (
	"fmt"
	"reflect"
	"strings"
	"testing"
	"time"
)

func compiledProfileConfig(t *testing.T, source string) rcxConfig {
	t.Helper()
	config := testConfig("ru")
	config.ProfileYAML = source
	config = config.normalized()
	if !config.profileState.Valid || config.compiled == nil {
		t.Fatalf("profile did not compile: %+v", config.profileState)
	}
	return config
}

func composeProfile(t *testing.T, config rcxConfig, context rcxProfileContext) rcxConfig {
	t.Helper()
	return config.compiled.compose(context, config.compiled.selection(context))
}

func TestProfileV2RegionLayerComposesThroughEngineApply(t *testing.T) {
	runtime := newFakeRuntime()
	engine := newTestEngine(runtime, "ru")
	config := testConfig("ru")
	config.ProfileYAML = `schema: 2
settings:
  dwellSeconds: 90
contexts:
  region:
    - id: region-ru
      when: [region is RU]
      set:
        settings:
          dwellSeconds: 55
          censorCountries: [IR]
`
	engine.applyConfigLocked(config)
	if engine.cfg.DwellSeconds != 55 {
		t.Fatalf("region layer did not compose through the apply path: dwell=%d", engine.cfg.DwellSeconds)
	}
	if !engine.cfg.censors("RU") || !engine.cfg.censors("IR") {
		t.Fatalf("region layer dropped the safety floor: %v", engine.cfg.CensorCountries)
	}
	if len(engine.cfg.profileState.Applied) != 1 || engine.cfg.profileState.Applied[0] != "region-ru" {
		t.Fatalf("applied region rules = %v", engine.cfg.profileState.Applied)
	}
	if engine.snapshot.Config.DwellSeconds != 90 {
		t.Fatal("the region patch leaked into the persisted base")
	}
}

func TestProfileV2RegionLayerSkipsAForeignRegion(t *testing.T) {
	runtime := newFakeRuntime()
	engine := newTestEngine(runtime, "us")
	config := testConfig("us")
	config.ProfileYAML = `schema: 2
settings:
  dwellSeconds: 90
contexts:
  region:
    - id: region-ru
      when: [region is RU]
      set:
        settings:
          dwellSeconds: 55
`
	engine.applyConfigLocked(config)
	if engine.cfg.DwellSeconds != 90 || len(engine.cfg.profileState.Applied) != 0 {
		t.Fatalf("a non-RU region matched the RU rule: dwell=%d applied=%v", engine.cfg.DwellSeconds, engine.cfg.profileState.Applied)
	}
}

func TestProfileV2SettingsPreserveFalseZeroAndEmpty(t *testing.T) {
	config := compiledProfileConfig(t, `schema: 2
settings:
  respectPick: false
  requireUDP: false
  switchImproveMs: 0
  nodeRules: []
  canaryForeign: []
  censorCountries: []
probe:
  staggerMs: 0
`)
	if config.RespectPick || config.RequireUDP || config.SwitchImproveMs != 0 || config.probe().StaggerMs != 0 || len(config.CanaryForeign) != 0 {
		t.Fatalf("explicit values were lost: %+v, %+v", config, config.probe())
	}
	if !reflect.DeepEqual(config.CensorCountries, []string{"RU"}) {
		t.Fatalf("region safety floor lost: %v", config.CensorCountries)
	}
	if config.DwellSeconds != rcxDwellSeconds || config.probe().BudgetPerHour != rcxProbeBudgetCap {
		t.Fatal("omitted fields did not inherit defaults")
	}
	data, err := config.effectiveProfile().marshalYAML()
	if err != nil {
		t.Fatal(err)
	}
	loaded := compiledProfileConfig(t, string(data))
	if !reflect.DeepEqual(config.profileValues(), loaded.profileValues()) {
		t.Fatal("export changed the effective base configuration")
	}
}

const rcxContextTestProfile = `schema: 2
settings:
  dwellSeconds: 90
contexts:
  region:
    - id: region-ru
      when: [region is RU]
      set:
        settings:
          dwellSeconds: 70
          censorCountries: [IR]
  terrain:
    - id: restricted
      when: [terrain.kind is whitelist]
      set:
        settings:
          dwellSeconds: 50
  network:
    - id: cellular
      when: [network.transport is cellular]
      set:
        settings:
          strategy: saver
          dwellSeconds: 30
          censorCountries: []
        probe:
          concurrency: 1
          budgetPerHour: 80
          reserve: 20
    - id: expensive
      when: [network.metered is true]
      set:
        settings:
          strategy: stable
        probe:
          budgetPerHour: 60
          reserve: 20
`

func TestProfileV2CompositionOrderAndRestoration(t *testing.T) {
	base := compiledProfileConfig(t, rcxContextTestProfile)
	cellular := composeProfile(t, base, rcxProfileContext{Region: "RU", Terrain: "whitelist", TerrainKind: "whitelist", Transport: "cellular", Metered: true})
	if cellular.DwellSeconds != 30 || cellular.Strategy != rcxStrategySaver || cellular.probe().BudgetPerHour != 80 {
		t.Fatalf("composition/first-match failed: dwell=%d strategy=%s probe=%+v", cellular.DwellSeconds, cellular.Strategy, cellular.probe())
	}
	if !reflect.DeepEqual(cellular.profileState.Applied, []string{"region-ru", "restricted", "cellular"}) {
		t.Fatalf("applied context rules = %v", cellular.profileState.Applied)
	}
	if !cellular.censors("RU") || !cellular.censors("IR") {
		t.Fatalf("a later layer erased the safety floor: %v", cellular.CensorCountries)
	}
	wifi := composeProfile(t, cellular, rcxProfileContext{Region: "US", Terrain: "normal", TerrainKind: "normal", Transport: "wifi"})
	if wifi.DwellSeconds != 90 || wifi.Strategy != rcxStrategyBalanced || wifi.probe().BudgetPerHour != rcxProbeBudgetCap || wifi.censors("IR") {
		t.Fatal("the previous network's patch leaked into the new context")
	}
	if base.DwellSeconds != 90 || base.Strategy != rcxStrategyBalanced || base.censors("IR") {
		t.Fatal("composition mutated the immutable base")
	}
}

func TestProfileV2ExportRetainsInactiveBranches(t *testing.T) {
	base := compiledProfileConfig(t, rcxContextTestProfile)
	active := composeProfile(t, base, rcxProfileContext{Transport: "cellular", Terrain: "normal", TerrainKind: "normal"})
	data, err := active.effectiveProfile().marshalYAML()
	if err != nil {
		t.Fatal(err)
	}
	loaded := compiledProfileConfig(t, string(data))
	for _, context := range []rcxProfileContext{
		{Region: "RU", Transport: "cellular", Terrain: "whitelist", TerrainKind: "whitelist"},
		{Region: "US", Transport: "wifi", Terrain: "normal", TerrainKind: "normal", Metered: true},
		{Region: "RU", Transport: "wifi", Terrain: "unknown", TerrainKind: "unknown"},
	} {
		want, got := composeProfile(t, base, context), composeProfile(t, loaded, context)
		if !reflect.DeepEqual(want.profileValues(), got.profileValues()) {
			t.Fatalf("round-trip changed context %+v", context)
		}
	}
}

func TestProfileV2EmptyAdmissionRejectsAll(t *testing.T) {
	config := compiledProfileConfig(t, "schema: 2\nadmission: []\n")
	if config.admitRules == nil {
		t.Fatal("empty admission was treated as absent")
	}
	if verdict := rcxAdmitWith(rcxTerrainNormal, preferredFacts(), config.admitRules); verdict != rcxVerdictReject {
		t.Fatalf("empty admission = %v", verdict)
	}
	data, err := config.effectiveProfile().marshalYAML()
	if err != nil {
		t.Fatal(err)
	}
	loaded := compiledProfileConfig(t, string(data))
	if loaded.admitRules == nil || len(loaded.admitRules) != 0 {
		t.Fatal("empty admission lost on export")
	}
}

func TestProfileV2RejectsFeedbackAndUnknownFields(t *testing.T) {
	cases := []string{
		"schema: 2\nsettings:\n  enabled: true\n",
		"schema: 2\nsettings:\n  nodeRules: [{action: prefer, typo: true}]\n",
		"schema: 2\nprobe: {concurency: 8}\n",
		"schema: 2\ncontexts:\n  network:\n    - id: feedback\n      when: [terrain is whitelist]\n      set: {probe: {budgetPerHour: 80}}\n",
		"schema: 2\ncontexts:\n  region:\n    - id: feedback\n      when: [network.metered is true]\n      set: {}\n",
		"schema: 2\ncontexts:\n  terrain:\n    - id: feedback\n      when: [terrain is whitelist]\n      set: {terrain: {enabled: false}}\n",
		"schema: 2\ncontexts:\n  terrain:\n    - id: feedback\n      set: {settings: {canaryForeign: []}}\n",
		"schema: 2\nterrain:\n  rules: [{when: [terrain is normal], state: whitelist}]\n",
		"schema: 2\nterrain: {checks: [made-up-prober]}\n",
		"schema: 2\n---\nschema: 2\n",
		"schema: 2\nsettings: &x {respectPick: false}\ncontexts: {network: [{id: bad, set: {settings: *x}}]}\n",
		"schema: 2\nprobe: {metered: {metered: {concurrency: 1}}}\n",
		"schema: 1\nsettings: {respectPick: false}\n",
	}
	for _, source := range cases {
		config := profileConfig(t, source)
		if config.profileState.Valid {
			t.Fatalf("accepted invalid profile:\n%s", source)
		}
		if !config.profileState.Present || config.profileState.Reason == "" {
			t.Fatal("fallback was invisible")
		}
	}
	if config := profileConfig(t, strings.Repeat(" ", rcxProfileMaxBytes)+"schema: 2"); config.profileState.Valid {
		t.Fatal("accepted an oversized profile")
	}
}

func TestProfileV2NetworkChangesKeepDebtAndSource(t *testing.T) {
	runtime := newFakeRuntime()
	engine := newTestEngine(runtime, "ru")
	engine.screenOff = true
	config := testConfig("ru")
	config.ProfileYAML = rcxContextTestProfile
	engine.applyConfigLocked(config)
	engine.pendingGrant = false
	engine.budget.Take(100, runtime.Now())
	engine.applyNetwork(rcxNetworkPayload{Transport: "cellular", Carrier: "test", Metered: true, Validated: true})
	if engine.cfg.Strategy != rcxStrategySaver || engine.budget.Remaining(runtime.Now()) != 0 || engine.pendingGrant {
		t.Fatalf("network patch reset debt/grants or missed strategy: %s/%d/%v", engine.cfg.Strategy, engine.budget.Remaining(runtime.Now()), engine.pendingGrant)
	}
	if engine.snapshot.Config.Strategy != rcxStrategyBalanced {
		t.Fatal("persisted the active network as the base")
	}
	engine.applyNetwork(rcxNetworkPayload{Transport: "wifi", SSID: "Home", Validated: true})
	if engine.cfg.Strategy != rcxStrategyBalanced || engine.budget.Remaining(runtime.Now()) != 140 {
		t.Fatal("Wi-Fi did not restore base budget without refilling it")
	}
	engine.applyNetwork(rcxNetworkPayload{Transport: "wifi", SSID: "Home", Metered: true, Validated: true})
	if engine.cfg.Strategy != rcxStrategyStable || engine.budget.Remaining(runtime.Now()) != 0 {
		t.Fatal("same-network metered change did not compose")
	}
	engine.handle(rcxEvent{Kind: rcxEventSetEnabled, Flag: false})
	if engine.snapshot.Config.Strategy != rcxStrategyBalanced || engine.snapshot.Config.Enabled {
		t.Fatal("enable control promoted an active patch into the source")
	}
}

func TestProfileV2StableContextHasNoAllocationOrEpochReset(t *testing.T) {
	runtime := newFakeRuntime()
	engine := newTestEngine(runtime, "ru")
	config := testConfig("ru")
	config.ProfileYAML = rcxContextTestProfile
	engine.applyConfigLocked(config)
	engine.refreshProfileContext()
	generation := engine.configGen
	if got := testing.AllocsPerRun(100, func() { engine.refreshProfileContext() }); got != 0 {
		t.Fatalf("stable profile context allocated %g times", got)
	}
	if generation != engine.configGen {
		t.Fatal("unchanged context reset the epoch")
	}
}

func TestProfileV2PolicyChangePreservesCompatibleCanary(t *testing.T) {
	runtime := newFakeRuntime()
	engine := newTestEngine(runtime, "ru")
	engine.screenOff = true
	engine.reaching = true
	reachGen, configGen := engine.reachGen, engine.configGen
	config := testConfig("ru")
	config.ProfileYAML = "schema: 2\nadmission: [{verdict: reject}]\n"
	engine.applyConfigLocked(config)
	if engine.configGen == configGen || engine.reachGen != reachGen || !engine.reaching {
		t.Fatal("policy and measurement epochs were conflated")
	}
	engine.handle(rcxEvent{Kind: rcxEventTerrainReach, Gen: reachGen, ConfigGen: configGen, Foreign: rcxProbeOK, Domestic: rcxProbeFail, SNI: rcxProbeOverloaded})
	if engine.reachF != rcxProbeOK || engine.reaching {
		t.Fatal("discarded a compatible canary after a policy change")
	}
	config.ProfileYAML = "schema: 2\nterrain: {checks: [domestic]}\n"
	engine.reaching = true
	engine.applyConfigLocked(config)
	if engine.reachGen == reachGen || engine.reaching || engine.reachF != rcxProbeOverloaded {
		t.Fatal("kept measurements from a changed detector")
	}
}

func TestProfileV2CadenceEditIsNotADetectorChange(t *testing.T) {
	runtime := newFakeRuntime()
	engine := newTestEngine(runtime, "ru")
	engine.screenOff = true
	engine.reaching = true
	engine.reachF = rcxProbeOK
	engine.terrain.observe(rcxTerrainWhitelist, runtime.Now())
	reachGen := engine.reachGen
	config := testConfig("ru")
	config.ProfileYAML = "schema: 2\nterrain: {refreshSeconds: 120}\n"
	engine.applyConfigLocked(config)
	if engine.reachGen != reachGen || !engine.reaching || engine.reachF != rcxProbeOK {
		t.Fatal("a cadence-only edit discarded the terrain verdict and canary")
	}
	if engine.terrain.terrain != rcxTerrainWhitelist {
		t.Fatal("a cadence-only edit reset the confirmed terrain")
	}
	if engine.cfg.terrainRules().RefreshSeconds != 120 {
		t.Fatalf("the retuned cadence did not take effect: %ds", engine.cfg.terrainRules().RefreshSeconds)
	}
}

func TestProfileV2StateAdmissionEditIsPolicyNotDetector(t *testing.T) {
	runtime := newFakeRuntime()
	engine := newTestEngine(runtime, "ru")
	engine.screenOff = true
	engine.reaching = true
	engine.reachF = rcxProbeOK
	reachGen, configGen := engine.reachGen, engine.configGen
	config := testConfig("ru")
	config.ProfileYAML = "schema: 2\nterrain:\n  states:\n    normal: {kind: normal, admission: {openWorldProven: viable, domesticProven: last-resort, breakerProven: viable, foreignPrior: viable, domesticPrior: last-resort, allowLastResort: false}}\n"
	engine.applyConfigLocked(config)
	if engine.configGen == configGen {
		t.Fatal("a terrain admission edit must advance the policy epoch")
	}
	if engine.reachGen != reachGen || !engine.reaching || engine.reachF != rcxProbeOK {
		t.Fatal("a terrain admission edit was misread as a detector change")
	}
}

func TestProfileV2StaleReachRecomposesToUnknownRow(t *testing.T) {
	runtime := newFakeRuntime()
	engine := newTestEngine(runtime, "ru")
	config := testConfig("ru")
	config.ProfileYAML = "schema: 2\n"
	engine.applyConfigLocked(config)
	engine.lastReachAt = runtime.Now()
	engine.terrain.observe(rcxTerrainWhitelist, runtime.Now())
	engine.refreshProfileContext()
	whitelistRow := engine.cfg.terrainAdmission
	runtime.advance(time.Duration(engine.cfg.terrainRules().MaxAgeSeconds+1) * time.Second)
	engine.refreshProfileContext()
	if engine.terrainCurrent() != rcxTerrainUnknown {
		t.Fatal("stale reach did not fall back to unknown terrain")
	}
	if engine.cfg.terrainAdmission == whitelistRow {
		t.Fatal("stale reach kept the prior terrain admission row")
	}
}

func TestProfileV2DomesticOnlyTerrainCheckRuns(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.reach["77.88.8.8:443"] = rcxProbeOK
	engine := newTestEngine(runtime, "ru")
	engine.quit = make(chan struct{})
	defer close(engine.quit)
	config := testConfig("ru")
	config.ProfileYAML = "schema: 2\nsettings: {canaryForeign: []}\nterrain: {checks: [domestic]}\n"
	engine.applyConfigLocked(config)
	engine.startReach()
	if !engine.reaching {
		t.Fatal("domestic-only detection was gated by foreign targets")
	}
	select {
	case event := <-engine.events:
		if event.Foreign != rcxProbeOverloaded || event.Domestic != rcxProbeOK || len(event.Canaries) != 1 {
			t.Fatalf("unexpected canary result: %+v", event)
		}
	case <-time.After(time.Second):
		t.Fatal("terrain round did not finish")
	}
}

func TestProfileV2NamedTerrainUsesConfiguredAdmission(t *testing.T) {
	config := compiledProfileConfig(t, `schema: 2
terrain:
  states:
    cellular-filtered:
      kind: whitelist
      admission:
        openWorldProven: preferred
        domesticProven: viable
        breakerProven: preferred
        foreignPrior: reject
        domesticPrior: reject
        allowLastResort: false
  rules:
    - when: [network.transport is cellular, check.domestic is ok, check.foreign isNot ok]
      state: cellular-filtered
    - state: normal
`)
	context := rcxProfileContext{Transport: "cellular", Validated: true}
	name, kind := config.terrainRules().classify(rcxSignals{context: context, terrain: rcxTerrainFacts{Validated: true, ForeignReach: rcxProbeFail, DomesticReach: rcxProbeOK}})
	if name != "cellular-filtered" || kind != rcxTerrainWhitelist {
		t.Fatalf("classification = %s/%s", name, kind)
	}
	context.Terrain, context.TerrainKind = name, kind.String()
	active := composeProfile(t, config, context)
	if got := rcxCandidateVerdict(rcxCandidate{Facts: rcxFacts{}}, kind, active.admitRules, active.terrainAdmission); got != rcxVerdictReject {
		t.Fatalf("custom row verdict = %s", got)
	}
	if rcxAllowsLastResort(kind, true, active.terrainAdmission) {
		t.Fatal("custom last-resort restriction was ignored")
	}
	for _, terrain := range []rcxTerrain{rcxTerrainUnknown, rcxTerrainNormal, rcxTerrainWhitelist, rcxTerrainPortal, rcxTerrainOffline} {
		row := rcxAdmissionRow{rcxVerdictPreferred, rcxVerdictPreferred, rcxVerdictPreferred, rcxVerdictPreferred, rcxVerdictPreferred, true}
		for _, facts := range []rcxFacts{{}, preferredFacts(), {Trust: rcxTrustBranded}, {Transit: rcxProofDisproven}, {NameHome: true}, {Origin: rcxOriginDomestic}} {
			if got, max := rcxAdmitWith(terrain, facts, nil, &row), rcxAdmit(terrain, facts); got > max {
				t.Fatalf("terrain row weakened admission for %s/%+v", terrain, facts)
			}
		}
	}
}

func TestProfileV2PortalCannotBeHiddenByDisabledDetector(t *testing.T) {
	config := compiledProfileConfig(t, "schema: 2\nterrain: {enabled: false}\n")
	for _, facts := range []rcxTerrainFacts{{CaptivePortal: true}, {PortalMarker: true}} {
		_, kind := config.terrainRules().classify(rcxSignals{terrain: facts})
		if kind != rcxTerrainPortal {
			t.Fatal("disabled detection erased a captive portal")
		}
	}
}

func TestProfileV2LimitsContextCount(t *testing.T) {
	var source strings.Builder
	source.WriteString("schema: 2\ncontexts:\n  network:\n")
	for i := 0; i < 33; i++ {
		fmt.Fprintf(&source, "    - id: rule-%d\n      set: {}\n", i)
	}
	if config := profileConfig(t, source.String()); config.profileState.Valid {
		t.Fatal("unbounded context count")
	}
}

func TestProfileV2QuotedNetworkLiteralsRoundTrip(t *testing.T) {
	base := compiledProfileConfig(t, `schema: 2
contexts:
  network:
    - id: home
      when: ['network.ssid is "Home  WiFi"']
      set: {settings: {strategy: saver}}
`)
	context := rcxProfileContext{SSID: "Home  WiFi"}
	if active := composeProfile(t, base, context); active.Strategy != rcxStrategySaver {
		t.Fatal("SSID whitespace was changed")
	}
	data, err := base.effectiveProfile().marshalYAML()
	if err != nil {
		t.Fatal(err)
	}
	loaded := compiledProfileConfig(t, string(data))
	if active := composeProfile(t, loaded, context); active.Strategy != rcxStrategySaver {
		t.Fatal("literal changed on export")
	}
}

func TestProfileV2BoundsCanaryFanoutAndRejectsNull(t *testing.T) {
	var source strings.Builder
	source.WriteString("schema: 2\nsettings:\n  canaryForeign:\n")
	for i := 0; i < 33; i++ {
		fmt.Fprintf(&source, "    - 192.0.2.%d:443\n", i+1)
	}
	if config := profileConfig(t, source.String()); config.profileState.Valid {
		t.Fatal("accepted an oversized canary group")
	}
	if config := profileConfig(t, "schema: 2\nprobe: null\n"); config.profileState.Valid {
		t.Fatal("null ambiguously inherited a policy section")
	}
}

func FuzzProfileCompiler(f *testing.F) {
	for _, source := range []string{string(rcxDefaultProfileYAML), rcxContextTestProfile, "schema: 1\n", "schema: 2\nprobe: {metered: {reserve: 10}}\n"} {
		f.Add(source)
	}
	f.Fuzz(func(t *testing.T, source string) {
		if len(source) > rcxProfileMaxBytes {
			return
		}
		config := profileConfig(t, source)
		probe := config.probe()
		if probe.BudgetPerHour < rcxProbeBudgetFloor || probe.Reserve < rcxProbeReserveFloor || probe.Reserve > probe.BudgetPerHour/2 {
			t.Fatalf("invalid bounds: %+v", probe)
		}
		if config.profileState.Valid {
			data, err := config.effectiveProfile().marshalYAML()
			if err != nil {
				t.Fatal(err)
			}
			if _, err := rcxDecisionProfileFromYAML(data); err != nil {
				t.Fatalf("cannot read own export: %v", err)
			}
		}
	})
}
