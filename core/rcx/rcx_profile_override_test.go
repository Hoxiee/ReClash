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

// A would-be-Preferred node under the shipped rules; a tightening profile may
// only reject it harder, never loosen a safety floor.
func preferredFacts() rcxFacts {
	return rcxFacts{OpenWorld: rcxProofProven, Exit: rcxOriginForeign, Trust: rcxTrusted}
}

func TestEmptyProfileKeepsShippedDefaults(t *testing.T) {
	p := rcxDefaultConfig().policy()
	if !reflect.DeepEqual(p.admissionRules(), rcxAdmitRulesDefault) {
		t.Fatal("empty profile did not keep the shipped admission rules")
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
	if !reflect.DeepEqual(p.admissionRules(), rcxDefaultAdmitRules()) {
		t.Fatal("default profile changed admission rules")
	}
	abs, pct := p.switchThresholds()
	if abs != 30 || pct != 20 {
		t.Fatalf("default profile switch = %d/%d, want 30/20", abs, pct)
	}
}

func TestProfileOverridesAdmission(t *testing.T) {
	facts := preferredFacts()
	base := rcxDefaultConfig().policy()
	if got := rcxAdmitWith(rcxTerrainNormal, facts, base.admissionRules()); got != rcxVerdictPreferred {
		t.Fatalf("default admits %v, want preferred", got)
	}
	rejectAll := "schema: 1\nadmission:\n  - verdict: reject\n"
	p := profileConfig(t, rejectAll).policy()
	if got := rcxAdmitWith(rcxTerrainNormal, facts, p.admissionRules()); got != rcxVerdictReject {
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
		if !reflect.DeepEqual(p.admissionRules(), rcxAdmitRulesDefault) {
			t.Fatalf("profile %q should fall back to shipped admission", yaml)
		}
		if abs, pct := p.switchThresholds(); abs != 30 || pct != 20 {
			t.Fatalf("profile %q should keep shipped switch, got %d/%d", yaml, abs, pct)
		}
	}
}
