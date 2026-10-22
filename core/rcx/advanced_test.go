package rcx

import (
	"testing"
	"time"
)

func TestCondUnknownFactsStayUnknown(t *testing.T) {
	scope := condScope{tags: map[string]bool{}, checks: map[string]bool{"open": true}}
	subject := Subject{Name: "DE-1", Checks: map[string]tri{"open": triUnknown}, Net: &NetSubject{}}
	cases := map[string]tri{
		`exit.country != RU`:                      triUnknown,
		`passes(open)`:                            triUnknown,
		`not passes(open)`:                        triUnknown,
		`passes(open) or name ~ /DE/`:             triYes,
		`passes(open) and name = NL-1`:            triNo,
		`network.kind = whitelist`:                triUnknown,
		`not dead and exit.country in [DE, NL]`:   triUnknown,
		`metered or network.transport = cellular`: triUnknown,
	}
	for text, want := range cases {
		cond, err := parseCond(text, scope)
		if err != nil {
			t.Fatalf("%s: %v", text, err)
		}
		if got := cond.Test(&subject); got != want {
			t.Errorf("%s = %v, want %v", text, got, want)
		}
	}
	subject.Exit, subject.Checks["open"] = "de", triNeither
	if cond, _ := parseCond(`exit.country != RU and not fails(open)`, scope); cond.Test(&subject) != triYes {
		t.Error("a soft failure counted against the node")
	}
}

func TestNetworkConditionsReadOnlyTheNetwork(t *testing.T) {
	scope := condScope{diags: map[string]bool{"home": true, "foreign": true}}
	cond, err := parseCond(`home ok and foreign fail and not network.portal`, scope)
	if err != nil {
		t.Fatal(err)
	}
	net := &NetSubject{Diag: map[string]tri{"home": triYes, "foreign": triNo}}
	if cond.Test(&Subject{Net: net}) != triYes {
		t.Fatal("whitelist condition did not hold")
	}
	for _, text := range []string{`name = x`, `passes(open)`, `tag(x)`, `home maybe`, `alive`} {
		if _, err := parseCond(text, scope); err == nil {
			t.Errorf("%q parsed as a network condition", text)
		}
	}
	if _, err := parseCond(`passes(nope)`, condScope{tags: map[string]bool{}}); err == nil {
		t.Error("an undeclared check parsed")
	}
}

func TestExitCountryNeedsAgreement(t *testing.T) {
	cases := []struct {
		votes []ExitVote
		want  string
	}{
		{[]ExitVote{{"echo", "DE"}, {"mmdb", "de"}}, "DE"},
		{[]ExitVote{{"echo", "DE"}, {"echo", "DE"}}, ""},
		{[]ExitVote{{"echo", "DE"}, {"mmdb", "NL"}}, ""},
		{[]ExitVote{{"echo", "XX"}, {"echo2", "DE"}, {"mmdb", "DE"}}, "DE"},
		{[]ExitVote{{"echo", "Germany"}, {"mmdb", "DE"}}, ""},
	}
	for _, c := range cases {
		if got, _ := exitVerdict(c.votes, 2); got != c.want {
			t.Errorf("%v = %q, want %q", c.votes, got, c.want)
		}
	}
}

func TestCheckFailureNeedsConfirmation(t *testing.T) {
	f := &Facts{}
	f.noteCheck("open", t0, true, false)
	f.noteCheck("open", t0.Add(time.Minute), false, false)
	if v := f.Checks["open"].verdict(t0.Add(time.Minute)); v != triUnknown {
		t.Fatalf("one failure after a pass = %v, want unknown", v)
	}
	f.noteCheck("open", t0.Add(2*time.Minute), false, false)
	if v := f.Checks["open"].verdict(t0.Add(2 * time.Minute)); v != triNo {
		t.Fatalf("two failures = %v, want fail", v)
	}
	if v := f.Checks["open"].verdict(t0.Add(checkWindow + time.Hour)); v != triUnknown {
		t.Fatalf("an old failure = %v, want unknown", v)
	}
	f.noteCheck("home", t0, false, true)
	if v := f.Checks["home"].verdict(t0); v != triNeither {
		t.Fatalf("optional failure = %v, want neither", v)
	}
}

func TestBypassMovesToAVerifiedForeignExitThatOpensBlocked(t *testing.T) {
	s := newSim(t, "builtin/bypass-ru", 12)
	s.exits = map[string]string{"n0": "RU", "n1": "RU", "n2": "RU", "n3": "RU"}
	s.blocked = map[string]bool{"n4": true, "n5": true}
	s.run(4*time.Hour, 30*time.Second, s.traffic)
	g := s.group()
	if g.decision.Tier != "Opens blocked" {
		t.Fatalf("on %s in tier %q (%s)", g.now, g.decision.Tier, g.decision.Reason.Code)
	}
	if s.exits[g.now] == "RU" || s.blocked[g.now] {
		t.Fatalf("settled on %s, which exits home or fails the check", g.now)
	}
	if row, _ := rowOf(g.decision.Ranking, "n0"); row.Exit != "RU" || row.Tier != 2 {
		t.Fatalf("home exit row = %+v", row)
	}
}

func newWhitelistSim(t *testing.T) *sim {
	s := newSim(t, "builtin/whitelist-ru", 10)
	s.m.topology.Groups[0].Members[7].Name = "RU LTE 7"
	s.latency["RU LTE 7"] = 140
	s.m.rebuild(s.now)
	s.diag = map[string]bool{"tls 1.1.1.1:443": false, "tls 9.9.9.9:443": false}
	return s
}

func (s *sim) joinNetwork(transport string, portal bool) {
	s.m.onHints(Hints{Network: &NetworkHint{Transport: transport, ID: "carrier", Portal: portal}}, s.now)
}

func TestWhitelistNetworkPrefersBypassNodes(t *testing.T) {
	s := newWhitelistSim(t)
	s.joinNetwork("cellular", false)
	s.run(time.Hour, 30*time.Second, s.traffic)
	g := s.group()
	if g.kind != "whitelist" || g.now != "RU LTE 7" || g.decision.Tier != "Bypass node" {
		t.Fatalf("kind %q, on %s in %q", g.kind, g.now, g.decision.Tier)
	}
	if got := s.m.env(s.now).Kinds["builtin/whitelist-ru"]; got != "whitelist" {
		t.Fatalf("network memory = %q", got)
	}
}

func TestPortalPausesAfterConfirmation(t *testing.T) {
	s := newWhitelistSim(t)
	s.joinNetwork("wifi", false)
	s.run(10*time.Minute, 30*time.Second, s.traffic)
	if s.group().kind != "whitelist" {
		t.Fatalf("kind %q before the portal", s.group().kind)
	}
	s.joinNetwork("wifi", true)
	s.step()
	if g := s.group(); g.kind != "portal" || g.decision.Reason.Code != "hold.paused" {
		t.Fatalf("kind %q, reason %s", g.kind, g.decision.Reason.Code)
	}
	before := s.nodeJobs
	s.run(30*time.Minute, 30*time.Second, s.traffic)
	if s.nodeJobs != before {
		t.Fatalf("%d node checks behind a captive portal", s.nodeJobs-before)
	}
	s.joinNetwork("wifi", false)
	s.run(5*time.Minute, 30*time.Second, s.traffic)
	if s.group().kind != "whitelist" {
		t.Fatalf("kind %q after the portal", s.group().kind)
	}
}

func TestDirectSplitOnlyWhenTheUserTurnsItOn(t *testing.T) {
	s := newSim(t, "builtin/bypass-ru", 6)
	s.diag = map[string]bool{"tcp 77.88.8.8:443": false, "tcp 77.88.8.1:443": false}
	s.m.topology.Subscription.Groups["G"] = Binding{Default: "builtin/bypass-ru", DirectSplit: true}
	s.m.rebuild(s.now)
	s.joinNetwork("wifi", false)
	s.run(5*time.Minute, 30*time.Second, s.traffic)
	if state := s.m.splitState(s.group(), s.now); state != "off" || s.m.split != "" {
		t.Fatalf("a provider turned direct-split on: %s", state)
	}
	s.m.user = UserLayer{Groups: map[string]Binding{"G": {Profile: "builtin/bypass-ru", DirectSplit: true}}}
	s.m.rebuild(s.now)
	s.step()
	if s.m.split != "G" {
		t.Fatalf("split = %q with home sites lost", s.m.split)
	}
	s.diag = nil
	s.joinNetwork("ethernet", false)
	s.run(2*time.Minute, 30*time.Second, s.traffic)
	if s.m.split != "" {
		t.Fatalf("split stayed on %q with home sites back", s.m.split)
	}
}

func TestEnergyAdvancedProfilesStayWithinTarget(t *testing.T) {
	scenarios := map[string]func(s *sim) func(){
		"stable": func(s *sim) func() { return s.traffic },
		"roaming": func(s *sim) func() {
			flip := false
			return func() {
				if s.now.Sub(t0)%(10*time.Minute) == 0 {
					flip = !flip
					transport := "wifi"
					if flip {
						transport = "cellular"
					}
					s.joinNetwork(transport, false)
				}
				s.traffic()
			}
		},
	}
	for _, profile := range []string{"builtin/bypass-ru", "builtin/whitelist-ru"} {
		for name, scenario := range scenarios {
			s := newSim(t, profile, 250)
			s.exits = map[string]string{"n1": "RU", "n2": "RU"}
			s.blocked = map[string]bool{"n3": true}
			s.run(24*time.Hour, 30*time.Second, scenario(s))
			if most := s.maxPerHour(); most > 80 {
				t.Errorf("%s %s: %d requests in one hour, target is 80", profile, name, most)
			}
			if bytes := s.maxPerHour() * probeCostBytes; bytes > 1<<20 {
				t.Errorf("%s %s: %d bytes in one hour", profile, name, bytes)
			}
		}
	}
}

func TestAdvancedProfilesAreStrict(t *testing.T) {
	for _, doc := range []string{
		"checks: { open: {} }\n",
		"checks: { open: { http: 'ftp://x' } }\n",
		"checks: { open: { tcp: 'host' } }\n",
		"checks: { open: { tcp: 'h:1', expect: [200] } }\n",
		"network: { diagnose: { Home: { tcp: ['h:1'] } } }\n",
		"network: { diagnose: { home: {} } }\n",
		"egress-verify: { agree: 5 }\n",
		"on: { whitelist: { energy: turbo } }\n",
	} {
		if _, err := ParseProfile([]byte(doc)); err == nil {
			t.Errorf("%q parsed", doc)
		}
	}
	lib := NewLibrary(SubscriptionLayer{Profiles: map[string]any{
		"stray": map[string]any{"on": map[string]any{"whitelist": map[string]any{"stranded": "hold"}}},
		"diag":  map[string]any{"prefer": []any{map[string]any{"label": "x", "when": "home ok"}}},
	}}, UserLayer{})
	for _, id := range []string{"stray", "diag"} {
		if _, err := lib.Compile(id, Binding{}); err == nil {
			t.Errorf("%s compiled", id)
		}
	}
}
