package rcx

import (
	"slices"
	"strings"
	"testing"
	"time"
)

func TestLintPointsAtTheLine(t *testing.T) {
	s := newSim(t, "builtin/simple", 4)
	cases := map[string]int{
		"title: x\nprefer:\n  - { label: A, when: 'not dead' }\n  - { label: B, when: 'name ~ ' }\n": 4,
		"title: x\nswitch:\n  feel: wild\n":            3,
		"title: x\nchecks:\n  open: { tcp: nohost }\n": 3,
		"title: x\nbogus: 1\n":                         2,
		"title: x\nextends: builtin/nope\n":            0,
	}
	for text, line := range cases {
		out, _ := s.m.studio(StudioRequest{Op: "lint", Text: text}, s.now)
		if len(out.Errors) != 1 || out.Errors[0].Line != line {
			t.Errorf("%q: errors %+v, want one on line %d", text, out.Errors, line)
		}
	}
}

func TestLintSimulatesTheDraftOnTheGroup(t *testing.T) {
	s := newSim(t, "builtin/simple", 6)
	s.run(10*time.Minute, 30*time.Second, s.traffic)
	text := "title: Only n3\npool: { include: 'name = n3' }\ntags: { spare: 'name = n9' }\n" +
		"checks: { open: { tcp: 'example.org:443' } }\n" +
		"prefer:\n  - { label: Nine, when: 'tag(spare)' }\n  - { label: Any, when: 'not dead' }\n"
	out, _ := s.m.studio(StudioRequest{Op: "lint", Text: text, Group: "G"}, s.now)
	if len(out.Errors) > 0 || out.Candidate == nil || out.Current == nil {
		t.Fatalf("lint = %+v", out)
	}
	if best := bestOf(*out.Candidate); best != "n3" {
		t.Fatalf("draft would pick %q, want n3", best)
	}
	codes := map[string]bool{}
	for _, w := range out.Warnings {
		codes[w.Code] = true
	}
	for _, code := range []string{"check.unused", "tier.empty"} {
		if !codes[code] {
			t.Errorf("no %s warning in %+v", code, out.Warnings)
		}
	}
	if len(out.Endpoints) != 1 || !out.Endpoints[0].ThirdParty || out.Endpoints[0].Host != "example.org" {
		t.Errorf("endpoints = %+v", out.Endpoints)
	}
	if s.group().policy.ID != "builtin/simple" {
		t.Fatal("lint changed the group")
	}
}

func bestOf(d Decision) string {
	for _, row := range d.Ranking {
		if row.Excluded == nil {
			return row.Name
		}
	}
	return ""
}

func TestCondBuilderRoundTrips(t *testing.T) {
	profile := &Profile{Tags: map[string]string{"bypass": "name ~ /lte/"}, Checks: map[string]Check{"open": {TCP: "a:1"}}}
	for _, text := range []string{
		`not dead and exit.country != RU and tag(bypass)`,
		`name ~ /DE|NL/i or provider in [main, 'my sub'] or latency <= 120`,
		`passes(open) and not fails(open) and name = 'and'`,
		`name ~ /a\/b/`,
	} {
		out, _ := studioCond(StudioRequest{Text: text, Profile: profile})
		if out.Form == nil || !out.Form.Flat || out.Form.Error != "" {
			t.Fatalf("%s: form %+v", text, out.Form)
		}
		back, _ := studioCond(StudioRequest{Form: out.Form, Profile: profile})
		if back.Text != text {
			t.Errorf("round trip %q -> %q", text, back.Text)
		}
	}
	if out, _ := studioCond(StudioRequest{Text: `alive and (name = a or name = b)`}); out.Form.Flat {
		t.Error("a nested condition came out flat")
	}
	out, _ := studioCond(StudioRequest{Text: `home ok and network.portal`, Network: true, Profile: &Profile{Network: NetworkSpec{Diagnose: map[string]Diagnostic{"home": {TCP: []string{"a:1"}}}}}})
	if out.Form.Error != "" || len(out.Form.Clauses) != 2 || out.Form.Clauses[0].Field != "diag" {
		t.Fatalf("network form %+v", out.Form)
	}
	for _, f := range out.Fields {
		if !f.Network {
			t.Errorf("node field %s offered for a network condition", f.Name)
		}
	}
}

func TestMergeBringsOverUntouchedKeys(t *testing.T) {
	base := "title: Base\nchecks:\n  open: { tcp: 'a:1' }\n  home: { tcp: 'h:1' }\nenergy: balanced\nrank: { by: latency }\n"
	theirs := "title: Base 2\nchecks:\n  open: { tcp: 'a:2' }\n  home: { tcp: 'h:1' }\nenergy: eco\nstranded: hold\n"
	mine := "# mine\ntitle: Mine\nchecks:\n  open: { tcp: 'a:1' }\n  home: { tcp: 'h:9' }\nenergy: precise\nrank: { by: latency }\n"
	text, conflicts, err := MergeProfiles([]byte(base), []byte(theirs), []byte(mine))
	if err != nil {
		t.Fatal(err)
	}
	profile, err := ParseProfile([]byte(text))
	if err != nil {
		t.Fatal(err)
	}
	if profile.Title != "Mine" || profile.Checks["open"].TCP != "a:2" || profile.Checks["home"].TCP != "h:9" ||
		profile.Stranded != "hold" || profile.Rank.By != "" || profile.Energy != "precise" {
		t.Fatalf("merged %+v", profile)
	}
	if !slices.Equal(conflicts, []string{"title", "energy"}) {
		t.Fatalf("conflicts %v", conflicts)
	}
	if !strings.Contains(text, "# mine") {
		t.Error("the user's comment was lost")
	}
}

func TestProviderProfilesAskBeforeThirdPartyHosts(t *testing.T) {
	sub := SubscriptionLayer{Profiles: map[string]any{
		"own":   map[string]any{"extends": "builtin/bypass-ru", "checks": map[string]any{"open": map[string]any{"http": "https://check.example.com/"}}},
		"other": map[string]any{"checks": map[string]any{"x": map[string]any{"tls": "tracker.net:443"}}, "prefer": []any{map[string]any{"label": "X", "when": "passes(x)"}}},
	}}
	user := UserLayer{ProviderHosts: []string{"sub.example.com"}}
	lib := NewLibrary(sub, user)
	if _, err := lib.Compile("own", Binding{}); err != nil {
		t.Fatalf("own site: %v", err)
	}
	var consent *ConsentError
	if _, err := lib.Compile("other", Binding{}); err == nil || !asConsent(err, &consent) || !slices.Equal(consent.Hosts, []string{"tracker.net"}) {
		t.Fatalf("third party compiled: %v", err)
	}
	if info, _ := lib.Info("provider/other"); !slices.Equal(info.Consent, []string{"tracker.net"}) {
		t.Fatalf("info consent %v", info.Consent)
	}
	user.Trusted = []string{"tracker.net"}
	if _, err := NewLibrary(sub, user).Compile("other", Binding{}); err != nil {
		t.Fatalf("after consent: %v", err)
	}
	if _, err := NewLibrary(SubscriptionLayer{}, UserLayer{Profiles: map[string]string{"mine": "checks: { x: { tls: 'tracker.net:443' } }\n"}}).Compile("user/mine", Binding{}); err != nil {
		t.Fatalf("a user profile asked for consent: %v", err)
	}
}

func asConsent(err error, target **ConsentError) bool {
	c, ok := err.(*ConsentError)
	*target = c
	return ok
}

func TestConsentKeepsTheGroupWorking(t *testing.T) {
	s := newSim(t, "builtin/simple", 4)
	s.m.topology.Subscription.Profiles = map[string]any{"p": map[string]any{"title": "Provider", "checks": map[string]any{"x": map[string]any{"tcp": "tracker.net:443"}}}}
	s.m.topology.Subscription.Groups["G"] = Binding{Default: "p"}
	s.m.rebuild(s.now)
	g := s.group()
	if g.problem == nil || g.problem.Code != "profile.consent" || g.policy == nil || g.policy.ID != DefaultProfile {
		t.Fatalf("problem %+v, policy %v", g.problem, g.policy)
	}
	if status := s.m.status(s.now); status.Groups[0].ProfileTitle != "Provider" {
		t.Fatalf("status shows %q", status.Groups[0].ProfileTitle)
	}
}

func TestL10nMergesThroughExtends(t *testing.T) {
	lib := NewLibrary(SubscriptionLayer{}, UserLayer{Profiles: map[string]string{
		"mine": "extends: builtin/bypass-ru\ntitle: Mine\nl10n: { ru: { Mine: Мой }, de: { Mine: Meins } }\n",
	}})
	info, _ := lib.Info("user/mine")
	if info.L10n["ru"]["Mine"] != "Мой" || info.L10n["de"]["Mine"] != "Meins" {
		t.Fatalf("l10n %v", info.L10n)
	}
	for _, doc := range []string{"l10n: { RU: { a: b } }\n", "l10n: { ru: { a: '' } }\n", "l10n: { russian: { a: b } }\n"} {
		if _, err := ParseProfile([]byte(doc)); err == nil {
			t.Errorf("%q parsed", doc)
		}
	}
}

func TestFormatRoundTripsEveryBuiltin(t *testing.T) {
	files, _ := builtinFiles.ReadDir("builtin")
	for _, file := range files {
		if file.IsDir() {
			continue
		}
		data, _ := builtinFiles.ReadFile("builtin/" + file.Name())
		profile, err := ParseProfile(data)
		if err != nil {
			t.Fatal(err)
		}
		text, err := FormatProfile(profile)
		if err != nil {
			t.Fatal(err)
		}
		again, err := ParseProfile([]byte(text))
		if err != nil {
			t.Fatalf("%s: %v\n%s", file.Name(), err, text)
		}
		if a, b := mustFormat(t, again), text; a != b {
			t.Fatalf("%s is not stable:\n%s\n---\n%s", file.Name(), a, b)
		}
	}
}

func mustFormat(t *testing.T, p *Profile) string {
	text, err := FormatProfile(p)
	if err != nil {
		t.Fatal(err)
	}
	return text
}
