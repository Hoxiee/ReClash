package rcx

import (
	"bytes"
	"reflect"
	"testing"
)

func TestDefaultProfileMatchesGoldenFixture(t *testing.T) {
	got, err := rcxDefaultDecisionProfile().marshalYAML()
	if err != nil {
		t.Fatalf("marshal default profile: %v", err)
	}
	if !bytes.Equal(bytes.TrimSpace(got), bytes.TrimSpace(rcxDefaultProfileYAML)) {
		t.Fatalf("default profile drifted from the embedded YAML:\n got:\n%s\nwant:\n%s", got, rcxDefaultProfileYAML)
	}
}

// The embedded YAML must parse back to the live Go defaults, so the shipped artifact
// and the compile-safe source are a bijection rather than two copies that can drift.
func TestEmbeddedProfileParsesToLiveDefaults(t *testing.T) {
	got, err := rcxDecisionProfileFromYAML(rcxDefaultProfileYAML)
	if err != nil {
		t.Fatalf("parse embedded profile: %v", err)
	}
	if !reflect.DeepEqual(got, rcxDefaultDecisionProfile()) {
		t.Fatalf("embedded YAML does not parse to the live defaults:\n got: %+v\nwant: %+v", got, rcxDefaultDecisionProfile())
	}
}

func TestDecisionProfileYAMLRoundTrip(t *testing.T) {
	want := rcxDefaultDecisionProfile()
	data, err := want.marshalYAML()
	if err != nil {
		t.Fatalf("marshal: %v", err)
	}
	got, err := rcxDecisionProfileFromYAML(data)
	if err != nil {
		t.Fatalf("unmarshal: %v", err)
	}
	if !reflect.DeepEqual(got, want) {
		t.Fatalf("round-trip changed the profile:\n got: %+v\nwant: %+v", got, want)
	}
	again, err := got.marshalYAML()
	if err != nil {
		t.Fatalf("remarshal: %v", err)
	}
	if !bytes.Equal(data, again) {
		t.Fatalf("re-marshal is not stable:\n first:\n%s\nsecond:\n%s", data, again)
	}
}

// The profile must be the live defaults, not a hand-kept copy, so the YAML face
// cannot drift from what the engine actually ranks and admits.
func TestDefaultProfileIsLiveDefaults(t *testing.T) {
	p := rcxDefaultDecisionProfile()
	if p.Schema != rcxProfileSchema {
		t.Fatalf("schema %d, want %d", p.Schema, rcxProfileSchema)
	}
	if !reflect.DeepEqual(p.Ladder, rcxDefaultLadder()) {
		t.Fatal("profile ladder is not rcxDefaultLadder()")
	}
	if !reflect.DeepEqual(p.Strategies, rcxStrategyProfiles) {
		t.Fatal("profile strategies are not rcxStrategyProfiles")
	}
	if !reflect.DeepEqual(p.Admission, rcxDefaultAdmitRules()) {
		t.Fatal("profile admission is not rcxDefaultAdmitRules()")
	}
	if p.Probe != rcxDefaultProbeSection() {
		t.Fatal("profile probe is not rcxDefaultProbeSection()")
	}
}

func TestDecisionProfileRejectsUnknownTokens(t *testing.T) {
	cases := []string{
		"schema: 1\nadmission:\n  - when: [transit is nope]\n    verdict: reject\n",
		"schema: 1\nadmission:\n  - when: [nope is proven]\n    verdict: reject\n",
		"schema: 1\nadmission:\n  - when: [transit is disproven]\n    verdict: nope\n",
		"schema: 1\nadmission:\n  - when: [transit is disproven]\n    verdict: reject\n    tier: foreignPrior\n",
	}
	for _, raw := range cases {
		if _, err := rcxDecisionProfileFromYAML([]byte(raw)); err == nil {
			t.Fatalf("expected error for %q", raw)
		}
	}
}
