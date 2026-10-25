package rcx

import (
	"reflect"
	"strings"
	"testing"
	"time"
)

func bundleLibrary() *Library {
	return NewLibrary(SubscriptionLayer{}, UserLayer{
		Profiles: map[string]string{
			"base": "title: Base Fast\nextends: builtin/simple\npool: { include: 'name ~ fast' }\n",
			"mine": "title: Mine\n# keeps the base\nextends: user/base\ntags: { spare: 'name = n9' }\nprefer:\n  - { label: Spare, when: 'tag(spare)' }\n  - { label: Any, when: 'not dead' }\n",
		},
		Scenarios: map[string]string{
			"trip":  "title: Trip\nnetwork:\n  kinds:\n    - { kind: mobile, when: network.portal }\n    - { kind: open, when: network.portal }\ngroups:\n  G: { profile: user/mine }\non:\n  mobile:\n    groups:\n      G: { profile: user/base }\n",
			"plain": "title: Plain\ngroups:\n  G: { profile: builtin/simple }\n",
		},
	})
}

func TestExportKeepsABuiltinOnlyDocumentPlain(t *testing.T) {
	lib := bundleLibrary()
	for id, kind := range map[string]string{"user/plain": "scenario", "user/base": ""} {
		want, _ := lib.ScenarioSource(id)
		if kind == "" {
			want, _ = lib.Source(id)
		}
		got, err := lib.Export(id, kind)
		if err != nil || got != string(want) {
			t.Errorf("%s: %q, %v", id, got, err)
		}
	}
}

func TestBundleRoundTripKeepsThePolicy(t *testing.T) {
	lib := bundleLibrary()
	text, err := lib.Export("user/trip", "scenario")
	if err != nil || !strings.Contains(text, "kind: bundle") || !strings.Contains(text, "# keeps the base") {
		t.Fatalf("export = %q, %v", text, err)
	}
	items, err := Unpack([]byte(text), []string{"mine", "base", "trip"})
	if err != nil || len(items) != 3 || items[2].Kind != "scenario" {
		t.Fatalf("items = %+v, %v", items, err)
	}
	user := UserLayer{Profiles: map[string]string{}, Scenarios: map[string]string{}}
	for _, item := range items {
		if item.Name == "mine" || item.Name == "base" || item.Name == "trip" {
			t.Errorf("%s was not renamed", item.Name)
		}
		if item.Kind == "scenario" {
			user.Scenarios[item.Name] = item.Text
		} else {
			user.Profiles[item.Name] = item.Text
		}
	}
	fresh := NewLibrary(SubscriptionLayer{}, user)
	want, err := lib.CompileScenario("user/trip")
	if err != nil {
		t.Fatal(err)
	}
	got, err := fresh.CompileScenario("user/" + items[2].Name)
	if err != nil {
		t.Fatal(err)
	}
	for _, kind := range []string{"", "mobile"} {
		a, b := want.programs(kind), got.programs(kind)
		for group, program := range a {
			wantPolicy, _ := lib.Resolve(program.Profile)
			gotPolicy, err := fresh.Resolve(b[group].Profile)
			if err != nil || !reflect.DeepEqual(wantPolicy, gotPolicy) {
				t.Errorf("%s/%s: %+v vs %+v (%v)", kind, group, wantPolicy, gotPolicy, err)
			}
		}
	}
}

func TestUnpackNamesAPlainDocument(t *testing.T) {
	items, err := Unpack([]byte("title: My Fast Pick\nextends: builtin/simple\n"), []string{"my-fast-pick"})
	if err != nil || len(items) != 1 || items[0].Name != "my-fast-pick-2" || items[0].Kind != "profile" {
		t.Fatalf("items = %+v, %v", items, err)
	}
	items, _ = Unpack([]byte("title: S\ngroups:\n  G: { profile: builtin/simple }\n"), nil)
	if len(items) != 1 || items[0].Kind != "scenario" {
		t.Fatalf("items = %+v", items)
	}
}

func TestLintReportsABundleItemByPath(t *testing.T) {
	s := newSim(t, "builtin/simple", 4)
	text := "rcx: 1\nkind: bundle\ntitle: T\nprofiles:\n  ok: { title: Ok, extends: builtin/simple }\n  bad:\n    title: Bad\n    switch:\n      feel: wild\n"
	out, _ := s.m.studio(StudioRequest{Op: "lint", Text: text}, time.Time{})
	if len(out.Errors) != 1 || out.Errors[0].Path != "profiles.bad.switch.feel" || out.Errors[0].Line != 9 {
		t.Fatalf("errors = %+v", out.Errors)
	}
}
