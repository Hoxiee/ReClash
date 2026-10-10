package rcx

import (
	"fmt"
	"reflect"
	"strings"
	"testing"

	yaml "go.yaml.in/yaml/v3"
)

func TestBuiltInProfileKeepsLegacyValues(t *testing.T) {
	want := rcxConfig{
		Preset: "off", Strategy: "balanced", DefaultsVersion: rcxDefaultsVersion,
		AllowDomesticLastResort: true, RespectPick: true,
		DwellSeconds: 90, WaveWidth: 12, ProofTTLMinutes: 30,
		DegradeConfirmSeconds: 60, AbsCeilingMs: 300, ThrottleFloorKBps: 16,
	}
	if got := rcxDefaultConfig(); !reflect.DeepEqual(got, want) {
		t.Fatalf("settings = %+v, want %+v", got, want)
	}
	probe := rcxProbeSection{Concurrency: 2, StaggerMs: 250, BudgetPerHour: 240, Reserve: 40}
	if got := rcxDefaultProbeSection(); !reflect.DeepEqual(got, probe) {
		t.Fatalf("probe = %+v, want %+v", got, probe)
	}
	strategies := map[string]rcxStrategyProfile{
		"balanced":       {LatencyBands: []int{80, 120, 180, 320}, SwitchAbsMs: 30, SwitchPct: 20},
		"lowest-latency": {LatencyBands: []int{65, 90, 130, 220}, SwitchAbsMs: 15, SwitchPct: 10, DropRungs: []rcxRungID{rcxRungMisfit}},
		"stable":         {LatencyBands: []int{120, 200, 320, 550}, SwitchAbsMs: 50, SwitchPct: 30},
		"saver":          {LatencyBands: []int{150, 260, 420, 750}, SwitchAbsMs: 50, SwitchPct: 30},
	}
	if !reflect.DeepEqual(rcxStrategyProfiles, strategies) {
		t.Fatalf("strategies = %+v, want %+v", rcxStrategyProfiles, strategies)
	}
	rows := map[rcxTerrain]rcxAdmissionRow{
		rcxTerrainNormal:    {rcxVerdictPreferred, rcxVerdictLastResort, rcxVerdictViable, rcxVerdictViable, rcxVerdictLastResort, false},
		rcxTerrainWhitelist: {rcxVerdictPreferred, rcxVerdictViable, rcxVerdictPreferred, rcxVerdictViable, rcxVerdictLastResort, true},
		rcxTerrainUnknown:   {rcxVerdictPreferred, rcxVerdictLastResort, rcxVerdictViable, rcxVerdictViable, rcxVerdictLastResort, true},
	}
	if !reflect.DeepEqual(rcxAdmissionTable, rows) {
		t.Fatalf("admission rows = %+v, want %+v", rcxAdmissionTable, rows)
	}
	if rcxRecurrenceFloorDefault != 2 {
		t.Fatalf("recurrence floor = %d, want 2", rcxRecurrenceFloorDefault)
	}
	terrain := rcxDefaultTerrainSection()
	got := []int{terrain.RefreshSeconds, terrain.UrgentSeconds, terrain.BackoffSeconds, terrain.MaxAgeSeconds, terrain.ConfirmationRounds, terrain.TimeoutMs, terrain.WarmupMs}
	if want := []int{300, 30, 180, 600, 2, 3000, 5000}; !reflect.DeepEqual(got, want) {
		t.Fatalf("terrain cadence = %v, want %v", got, want)
	}
}

func editedBuiltIn(t *testing.T, path string, value any) []byte {
	t.Helper()
	var document yaml.Node
	if err := yaml.Unmarshal(rcxDefaultProfileYAML, &document); err != nil {
		t.Fatal(err)
	}
	node := document.Content[0]
	parts := strings.Split(path, ".")
	for depth, part := range parts {
		found := false
		for i := 0; i < len(node.Content); i += 2 {
			if node.Content[i].Value != part {
				continue
			}
			found = true
			if depth+1 < len(parts) {
				node = node.Content[i+1]
				break
			}
			if value == nil {
				node.Content = append(node.Content[:i], node.Content[i+2:]...)
			} else if err := node.Content[i+1].Encode(value); err != nil {
				t.Fatal(err)
			}
			break
		}
		if !found {
			t.Fatalf("missing test path %q", path)
		}
	}
	data, err := yaml.Marshal(&document)
	if err != nil {
		t.Fatal(err)
	}
	return data
}

func TestBuiltInProfileRejectsIncompleteOrInvalidDefaults(t *testing.T) {
	for _, tc := range []struct {
		path  string
		value any
	}{
		{"schema", 3}, {"probe", nil}, {"terrain", nil}, {"settings", nil},
		{"probe.concurrency", nil}, {"probe.staggerMs", nil}, {"probe.reserve", nil}, {"probe.budgetPerHour", nil},
		{"settings.dwellSeconds", nil}, {"settings.respectPick", nil}, {"terrain.refreshSeconds", nil},
		{"strategies.balanced.switchAbsMs", nil}, {"terrain.states.normal", nil},
		{"terrain.states.whitelist.admission.domesticProven", nil},
		{"probe.budgetPerHour", 0}, {"probe.reserve", 0}, {"settings.dwellSeconds", 0},
		{"settings.waveWidth", 65}, {"terrain.timeoutMs", 0}, {"terrain.confirmationRounds", 1},
		{"terrain.states.normal.kind", "whitelist"}, {"settings.strategy", "missing"},
	} {
		t.Run(fmt.Sprintf("%s=%v", tc.path, tc.value), func(t *testing.T) {
			_, err := rcxLoadBuiltInProfile(editedBuiltIn(t, tc.path, tc.value))
			if err == nil || strings.Contains(err.Error(), "<nil>") {
				t.Fatalf("invalid built-in error = %v", err)
			}
		})
	}
}

func TestBuiltInCustomModeCannotReplaceCanonicalAdmission(t *testing.T) {
	profile := rcxDefaultDecisionProfile()
	profile.Terrain.States["restricted"] = rcxTerrainMode{Kind: rcxTerrainNormal, Admission: &rcxAdmissionRow{}}
	if got := rcxBaselineAdmission(profile); !reflect.DeepEqual(got, rcxAdmissionTable) {
		t.Fatalf("custom state changed the safety baseline: %+v", got)
	}
}

func TestBuiltInContextAndMeteredPolicyUseTheCompiledPath(t *testing.T) {
	patch := compiledProfileConfig(t, `schema: 2
contexts:
  network:
    - id: metered
      when: [network.metered is true]
      set: {settings: {dwellSeconds: 45}}
`)
	saved := rcxBuiltInProfile
	t.Cleanup(func() { rcxBuiltInProfile = saved })
	rcxBuiltInProfile = rcxDefaultDecisionProfile()
	rcxBuiltInProfile.Contexts = patch.effectiveProfile().Contexts
	rcxBuiltInProfile.Probe.Metered = &rcxProbeSection{Concurrency: 1, StaggerMs: 500, BudgetPerHour: 60, Reserve: 20}
	for _, source := range []string{"", "schema: 2\n", "schema: 99\n", "invalid: [", "schema: 2\ncontexts: {region: [{id: invalid, when: [network.metered is true], set: {}}]}\n"} {
		t.Run(source, func(t *testing.T) {
			engine := newTestEngine(newFakeRuntime(), "ru")
			engine.screenOff = true
			config := testConfig("ru")
			config.ProfileYAML, config.WaveWidth, config.RespectPick = source, 17, false
			engine.applyConfigLocked(config)
			engine.applyNetwork(rcxNetworkPayload{Transport: "wifi", SSID: "Home", Metered: true, Validated: true})
			if engine.cfg.WaveWidth != 17 || engine.cfg.RespectPick || engine.cfg.DwellSeconds != 45 || engine.effectiveProbe().BudgetPerHour != 60 {
				t.Fatalf("host overlay or built-in context lost: width=%d respect=%v dwell=%d probe=%+v", engine.cfg.WaveWidth, engine.cfg.RespectPick, engine.cfg.DwellSeconds, engine.effectiveProbe())
			}
			if engine.snapshot.Config.ProfileYAML != source || engine.snapshot.Config.DwellSeconds != 90 {
				t.Fatal("persisted an active overlay instead of the source")
			}
			if engine.cfg.profileState.Present != (source != "") {
				t.Fatal("fallback lost the source profile status")
			}
		})
	}
	profile, err := rcxDecisionProfileFromYAML([]byte("schema: 2\nprobe: {concurrency: 4, metered: {reserve: 25}}\n"))
	if err != nil {
		t.Fatal(err)
	}
	if profile.Probe.Concurrency != 4 || profile.Probe.Metered.Concurrency != 1 || profile.Probe.Metered.BudgetPerHour != 60 || profile.Probe.Metered.Reserve != 25 {
		t.Fatalf("metered inheritance = %+v / %+v", profile.Probe, profile.Probe.Metered)
	}
	copy := rcxDefaultProbeSection()
	copy.Metered.Reserve = 29
	if rcxBuiltInProfile.Probe.Metered.Reserve != 20 {
		t.Fatal("default getter exposed a mutable metered section")
	}
}

func TestLegacyProfileKeepsStrategyNamesAndTerrainSwitch(t *testing.T) {
	for _, name := range []string{"Fast route", "CELLULAR", "Стабильный"} {
		source := fmt.Sprintf("schema: 1\nstrategies:\n  %q: {bands: [50,100], switchAbsMs: 10, switchPct: 5}\nterrain: {enabled: false}\n", name)
		config := rcxConfig{Strategy: name, ProfileYAML: source}.normalized()
		if !config.profileState.Valid || config.Strategy != name || !config.terrainDisabled {
			t.Fatalf("legacy profile changed: %+v", config.profileState)
		}
	}
	for _, field := range []string{"checks: [foreign]", "rules: []", "states: {}", "refreshSeconds: 60"} {
		if config := profileConfig(t, "schema: 1\nterrain: {"+field+"}\n"); config.profileState.Valid {
			t.Fatalf("schema 1 accepted %s", field)
		}
	}
	for _, checks := range []string{"[foreign, foreign]", "[foreign, domestic, sni, foreign]"} {
		if config := profileConfig(t, "schema: 2\nterrain: {checks: "+checks+"}\n"); config.profileState.Valid {
			t.Fatalf("accepted duplicated checks: %s", checks)
		}
	}
}
