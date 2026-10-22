package rcx

import (
	"strings"
	"testing"
)

func TestCondEvaluatesFieldsAndOperators(t *testing.T) {
	tags := map[string]bool{"bypass": true}
	subject := Subject{Name: "DE-2 LTE", Provider: "main", Type: "Vless", UDP: true, Measured: true, Latency: 80, Tags: map[string]bool{"bypass": true}}
	cases := map[string]bool{
		`name ~ /(?i)\blte\b/`:                true,
		`name ~ /de-\d/i and udp`:             true,
		`type = vless`:                        true,
		`provider in [other, 'main']`:         true,
		`provider != main`:                    false,
		`latency < 100ms and not dead`:        true,
		`latency >= 100`:                      false,
		`tag(bypass) and (alive or measured)`: true,
		`not (name ~ /NL/ or type = trojan)`:  true,
		`current`:                             false,
	}
	for text, want := range cases {
		cond, err := ParseCond(text, tags)
		if err != nil {
			t.Fatalf("%s: %v", text, err)
		}
		if got := cond.Eval(&subject); got != want {
			t.Errorf("%s = %v, want %v", text, got, want)
		}
	}
}

func TestCondUnmeasuredLatencyMatchesNoBound(t *testing.T) {
	cond, _ := ParseCond("latency < 1000 or latency >= 1000", nil)
	if cond.Eval(&Subject{}) {
		t.Fatal("an unmeasured node satisfied a latency bound")
	}
}

func TestCondRejectsMalformedInput(t *testing.T) {
	for _, text := range []string{
		"nmae = x", "name", "latency ~ /1/", "alive = true", "tag(x)", "name ~ /a/g",
		"(name = a", "name = a and", "! alive", "name in [a b]", strings.Repeat("(", 40) + "alive" + strings.Repeat(")", 40),
	} {
		if _, err := ParseCond(text, map[string]bool{}); err == nil {
			t.Errorf("%q parsed", text)
		}
	}
	if _, err := ParseCond("tag(bypass)", nil); err == nil {
		t.Error("tag() allowed inside a tag definition")
	}
}

func TestBuiltinsCompile(t *testing.T) {
	lib := NewLibrary(SubscriptionLayer{}, UserLayer{})
	for _, info := range lib.Infos() {
		if info.Error != "" {
			t.Fatalf("%s: %s", info.ID, info.Error)
		}
		if info.Kind == "scenario" {
			if _, err := lib.CompileScenario(info.ID); err != nil {
				t.Fatalf("%s: %v", info.ID, err)
			}
			continue
		}
		if _, err := lib.Compile(info.ID, Binding{}); err != nil {
			t.Fatalf("%s: %v", info.ID, err)
		}
	}
	fastest, _ := lib.Compile("builtin/fastest", Binding{})
	simple, _ := lib.Compile("builtin/simple", Binding{})
	if !fastest.Improve || simple.Improve {
		t.Fatal("fastest must improve its choice and simple must not")
	}
}

func TestLayersOnlyNarrowThePool(t *testing.T) {
	lib := NewLibrary(SubscriptionLayer{Profiles: map[string]any{
		"de": map[string]any{"extends": "builtin/fastest", "pool": map[string]any{"include": "name ~ /DE/", "exclude": "name ~ /old/"}},
	}}, UserLayer{})
	policy, err := lib.Compile("de", Binding{Pool: Pool{Include: "udp", Exclude: "name ~ /slow/"}})
	if err != nil {
		t.Fatal(err)
	}
	check := func(s Subject) bool {
		return policy.Include.Eval(&s) && !policy.Exclude.Eval(&s)
	}
	if !check(Subject{Name: "DE-1", UDP: true}) {
		t.Fatal("a node every layer admits was dropped")
	}
	for _, s := range []Subject{{Name: "NL-1", UDP: true}, {Name: "DE-1"}, {Name: "DE-old", UDP: true}, {Name: "DE-slow", UDP: true}} {
		if check(s) {
			t.Fatalf("%+v passed a layer that excludes it", s)
		}
	}
	if !policy.Improve || policy.Title != "" && policy.Title != "Fastest" {
		t.Fatalf("extends lost the base: %+v", policy)
	}
}

func TestProfileParsingIsStrict(t *testing.T) {
	for _, doc := range []string{
		"rcx: 1\nprefre: []\n",
		"rcx: 9\n",
		"switch: { feel: wild }\n",
		"energy: turbo\n",
		"stranded: nowhere\n",
		"switch: { dwell: -5m }\n",
	} {
		if _, err := ParseProfile([]byte(doc)); err == nil {
			t.Errorf("%q parsed", doc)
		}
	}
	lib := NewLibrary(SubscriptionLayer{Profiles: map[string]any{
		"a": map[string]any{"extends": "b"},
		"b": map[string]any{"extends": "a"},
	}}, UserLayer{})
	if _, err := lib.Compile("a", Binding{}); err == nil {
		t.Fatal("an extends cycle compiled")
	}
}

func TestSliderChoicesOverrideTheProfile(t *testing.T) {
	lib := NewLibrary(SubscriptionLayer{}, UserLayer{})
	policy, err := lib.Compile("builtin/fastest", Binding{Feel: "eager", Energy: "eco"})
	if err != nil {
		t.Fatal(err)
	}
	if policy.MaxPerHour != feels["eager"].maxPerHour || policy.Energy != "eco" || !policy.Improve {
		t.Fatalf("binding sliders not applied: %+v", policy)
	}
}
