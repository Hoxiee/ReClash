package rcx

import (
	"reflect"
	"strings"
	"testing"
)

func TestConfigFingerprintsSeparateIndependentDomains(t *testing.T) {
	base := testConfig("ru")
	fingerprints := base.fingerprints()

	open := base
	open.OpenMarkers = []rcxMarker{{URL: "https://api.telegram.org/", Statuses: []int{404, 200}}}
	if got := open.fingerprints(); got.Open == fingerprints.Open || got.Domestic != fingerprints.Domestic || got.Canaries != fingerprints.Canaries || got.Countries != fingerprints.Countries || got.Lanes != fingerprints.Lanes {
		t.Fatalf("open edit changed unrelated domains: before=%+v after=%+v", fingerprints, got)
	}

	countries := base
	countries.CensorCountries = []string{"IR"}
	if got := countries.fingerprints(); got.Countries == fingerprints.Countries || got.Open != fingerprints.Open || got.Lanes != fingerprints.Lanes {
		t.Fatalf("country edit did not stay isolated: before=%+v after=%+v", fingerprints, got)
	}

	lanes := base
	lanes.Lanes = []rcxLaneConfig{{ID: "gemini-access", Group: "RCX-CAP-GEMINI_ACCESS"}}
	if got := lanes.normalized().fingerprints(); got.Lanes == fingerprints.Lanes || got.Open != fingerprints.Open || got.Domestic != fingerprints.Domestic || got.Canaries != fingerprints.Canaries || got.Countries != fingerprints.Countries {
		t.Fatalf("lane edit did not stay isolated: before=%+v after=%+v", fingerprints, got)
	}
}

func TestMarkerFingerprintKeepsUserPriorityButNormalizesStatuses(t *testing.T) {
	first := []rcxMarker{
		{URL: "https://a.example/", Statuses: []int{404, 200}},
		{URL: "https://b.example/", Statuses: []int{204}},
	}
	statusesReordered := []rcxMarker{
		{URL: "https://a.example/", Statuses: []int{200, 404}},
		{URL: "https://b.example/", Statuses: []int{204}},
	}
	markersReordered := []rcxMarker{first[1], first[0]}

	if rcxMarkersFingerprint(first) != rcxMarkersFingerprint(statusesReordered) {
		t.Error("status order changed marker semantics")
	}
	if rcxMarkersFingerprint(first) == rcxMarkersFingerprint(markersReordered) {
		t.Error("marker priority order disappeared from the fingerprint")
	}
}

func TestLaneNormalizationValidatesAndDeduplicates(t *testing.T) {
	config := rcxConfig{Lanes: []rcxLaneConfig{
		{
			ID:       " gemini-access ",
			Group:    " RCX-CAP-GEMINI_ACCESS ",
			Fallback: " reject ",
			Selectors: []rcxLaneSelector{
				{Provider: " premium ", NameContains: " star "},
				{Provider: "premium", NameContains: "star"},
				{Provider: " ", NameContains: " "},
				{Provider: "backup"},
			},
		},
		{ID: "gemini-access", Group: "RCX-CAP-IGNORED", Fallback: "reject"},
		{ID: "duplicate-group", Group: "RCX-CAP-GEMINI_ACCESS", Fallback: "reject"},
		{ID: "YouTube", Group: "RCX-CAP-YOUTUBE"},
		{ID: "youtube-adfree", Group: "MAIN"},
		{ID: "future.cap-2", Group: "RCX-CAP-FUTURE_2", Fallback: "unknown"},
	}}

	want := []rcxLaneConfig{
		{
			ID:       "gemini-access",
			Group:    "RCX-CAP-GEMINI_ACCESS",
			Fallback: "reject",
			Selectors: []rcxLaneSelector{
				{Provider: "premium", NameContains: "star"},
				{Provider: "backup"},
			},
		},
		{ID: "future.cap-2", Group: "RCX-CAP-FUTURE_2", Fallback: "main", Selectors: []rcxLaneSelector{}},
	}
	if got := config.normalized().Lanes; !reflect.DeepEqual(got, want) {
		t.Fatalf("normalized lanes mismatch:\nwant=%#v\n got=%#v", want, got)
	}
}

func TestLaneNormalizationRejectsInvalidSyntax(t *testing.T) {
	invalidIDs := []string{"", "-cap", ".cap", "upper-C", "under_score", "two words", strings.Repeat("a", 65)}
	for _, id := range invalidIDs {
		if rcxValidLaneID(id) {
			t.Errorf("accepted invalid lane ID %q", id)
		}
	}
	invalidGroups := []string{"", "RCX-CAP-", "rcx-cap-GOOD", "RCX-CAP-lower", "RCX-CAP-HAS-DASH", " RCX-CAP-GOOD"}
	for _, group := range invalidGroups {
		if rcxValidLaneGroup(group) {
			t.Errorf("accepted invalid lane group %q", group)
		}
	}
}

func TestLaneNormalizationCanonicalizesUnicodeBeforeDeduplication(t *testing.T) {
	config := rcxConfig{Lanes: []rcxLaneConfig{{
		ID: "accented", Group: "RCX-CAP-ACCENTED", Selectors: []rcxLaneSelector{
			{Provider: "prémium", NameContains: "é"},
			{Provider: "prémium", NameContains: "é"},
		},
	}}}

	selectors := config.normalized().Lanes[0].Selectors
	if len(selectors) != 1 || selectors[0].Provider != "prémium" || selectors[0].NameContains != "é" {
		t.Fatalf("selectors = %#v, want one NFC-normalized selector", selectors)
	}
}

func TestLaneFingerprintIsStableAndSemantic(t *testing.T) {
	base := rcxConfig{Lanes: []rcxLaneConfig{{
		ID:       "gemini-access",
		Group:    "RCX-CAP-GEMINI_ACCESS",
		Fallback: "reject",
		Selectors: []rcxLaneSelector{
			{Provider: "premium", NameContains: "star"},
			{Provider: "backup"},
		},
	}}}.normalized()
	duplicateAndWhitespace := rcxConfig{Lanes: []rcxLaneConfig{{
		ID:       " gemini-access ",
		Group:    " RCX-CAP-GEMINI_ACCESS ",
		Fallback: " reject ",
		Selectors: []rcxLaneSelector{
			{Provider: " premium ", NameContains: " star "},
			{Provider: "premium", NameContains: "star"},
			{Provider: "backup"},
		},
	}}}.normalized()
	if base.fingerprints().Lanes != duplicateAndWhitespace.fingerprints().Lanes {
		t.Error("equivalent normalized lanes produced different fingerprints")
	}

	fingerprint := base.fingerprints().Lanes
	fallback := cloneLaneConfig(base)
	fallback.Lanes[0].Fallback = "main"
	selector := cloneLaneConfig(base)
	selector.Lanes[0].Selectors[0].NameContains = "spark"
	selectorOrder := cloneLaneConfig(base)
	selectorOrder.Lanes[0].Selectors = []rcxLaneSelector{base.Lanes[0].Selectors[1], base.Lanes[0].Selectors[0]}
	laneOrder := cloneLaneConfig(base)
	laneOrder.Lanes = append(laneOrder.Lanes, rcxLaneConfig{ID: "youtube-adfree", Group: "RCX-CAP-YOUTUBE_ADFREE", Fallback: "main"})
	reorderedLanes := cloneLaneConfig(laneOrder)
	reorderedLanes.Lanes = []rcxLaneConfig{laneOrder.Lanes[1], laneOrder.Lanes[0]}

	for name, changed := range map[string]rcxConfig{
		"fallback":       fallback,
		"selector":       selector,
		"selector order": selectorOrder,
		"lane order":     reorderedLanes,
	} {
		if changed.fingerprints().Lanes == fingerprint {
			t.Errorf("%s edit did not change lane fingerprint", name)
		}
	}
}

func cloneLaneConfig(config rcxConfig) rcxConfig {
	config.Lanes = append([]rcxLaneConfig(nil), config.Lanes...)
	for i := range config.Lanes {
		config.Lanes[i].Selectors = append([]rcxLaneSelector(nil), config.Lanes[i].Selectors...)
	}
	return config
}

func TestNodeRulesAndAvoidCountries(t *testing.T) {
	cfg := rcxConfig{
		NodeRules: []rcxNodeRule{
			{Provider: "cheapo", Action: rcxRuleIgnore},
			{NameContains: "lte", Action: rcxRuleLastResort},
			{Country: "RU", Action: rcxRulePrefer},
		},
		AvoidCountries: []string{"UA"},
	}
	if got := cfg.ruleFor("cheapo", "Node 1", "", ""); got != rcxRuleIgnore {
		t.Errorf("provider rule = %q, want ignore", got)
	}
	if got := cfg.ruleFor("x", "Fast LTE Berlin", "", ""); got != rcxRuleLastResort {
		t.Errorf("name rule = %q, want last-resort", got)
	}
	if got := cfg.ruleFor("x", "berlin", "", "ru"); got != rcxRulePrefer {
		t.Errorf("country rule = %q, want prefer (case-insensitive)", got)
	}
	if got := cfg.ruleFor("x", "berlin", "", ""); got != "" {
		t.Errorf("unmeasured country must not fire a country rule, got %q", got)
	}
	if !cfg.avoidsCountry("ua") || cfg.avoidsCountry("") || cfg.avoidsCountry("DE") {
		t.Error("avoidsCountry mismatch")
	}
	if (rcxNodeRule{Action: rcxRuleIgnore}).matches("p", "n", "g", "c") {
		t.Error("an all-empty rule must match nothing")
	}
}

func TestCensorsMatchesCountryCodeCaseInsensitively(t *testing.T) {
	cfg := rcxConfig{CensorCountries: []string{"RU"}}
	for _, code := range []string{"RU", "ru", "Ru"} {
		if !cfg.censors(code) {
			t.Errorf("censors(%q) = false, want true: mmdb case must not break the domestic side", code)
		}
	}
	if cfg.censors("DE") {
		t.Error("censors(\"DE\") = true, want false")
	}
}

func TestLadderValidationAndFallback(t *testing.T) {
	cases := []struct {
		name  string
		in    []rcxRungSpec
		valid bool
	}{
		{"empty falls back", nil, false},
		{"missing latency", []rcxRungSpec{{ID: rcxRungVerdict, Enabled: true}}, false},
		{"missing verdict", []rcxRungSpec{{ID: rcxRungLatency, Enabled: true}}, false},
		{"unknown rung", []rcxRungSpec{{ID: rcxRungVerdict}, {ID: rcxRungLatency}, {ID: rcxRungInvalid}}, false},
		{"duplicate rung", []rcxRungSpec{{ID: rcxRungVerdict}, {ID: rcxRungLatency}, {ID: rcxRungVerdict}}, false},
		{"minimal valid", []rcxRungSpec{{ID: rcxRungVerdict}, {ID: rcxRungLatency}}, true},
		{"default valid", rcxDefaultLadder(), true},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			if got := rcxValidLadder(tc.in); got != tc.valid {
				t.Fatalf("rcxValidLadder = %v, want %v", got, tc.valid)
			}
			ladder := rcxConfig{Ladder: tc.in}.ladder()
			if !tc.valid && !reflect.DeepEqual(ladder, rcxDefaultLadder()) {
				t.Fatalf("invalid ladder should fall back to default, got %+v", ladder)
			}
		})
	}
}

func TestNormalizedClampsLadderAndTriggers(t *testing.T) {
	c := rcxConfig{
		Strategy:         rcxStrategyBalanced,
		SwitchImproveMs:  -5,
		SwitchImprovePct: -1,
		LatencyStepMs:    -30,
		Ladder: []rcxRungSpec{
			{ID: rcxRungVerdict, Enabled: true},
			{ID: rcxRungRecurrence, Enabled: true, RecurrenceFloor: -3},
			{ID: rcxRungLatency, Enabled: true, LatencyToleranceMs: -10},
		},
	}.normalized()
	if c.SwitchImproveMs != 0 || c.SwitchImprovePct != 0 || c.LatencyStepMs != 0 {
		t.Fatalf("negative triggers not clamped: %+v", c)
	}
	if c.Ladder[1].RecurrenceFloor != 0 || c.Ladder[2].LatencyToleranceMs != 0 {
		t.Fatalf("negative thresholds not clamped: %+v", c.Ladder)
	}
	bad := rcxConfig{Strategy: rcxStrategyBalanced, Ladder: []rcxRungSpec{{ID: rcxRungVerdict}}}.normalized()
	if bad.Ladder != nil {
		t.Fatalf("invalid ladder should normalize to nil, got %+v", bad.Ladder)
	}
}

func TestPolicyCarriesLadderAndTriggers(t *testing.T) {
	c := rcxConfig{
		Strategy:         rcxStrategyBalanced,
		SwitchImproveMs:  40,
		SwitchImprovePct: 25,
		LatencyStepMs:    45,
	}.normalized()
	p := c.policy()
	if p.SwitchImproveMs != 40 || p.SwitchImprovePct != 25 || p.LatencyStepMs != 45 {
		t.Fatalf("policy dropped trigger fields: %+v", p)
	}
	if !reflect.DeepEqual(p.Ladder, rcxDefaultLadder()) {
		t.Fatalf("policy ladder = %+v, want default", p.Ladder)
	}
}
