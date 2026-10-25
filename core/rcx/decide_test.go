package rcx

import (
	"slices"
	"testing"
	"time"
)

var t0 = time.Date(2026, 10, 22, 12, 0, 0, 0, time.UTC)

func compiled(t *testing.T, id string, b Binding) *Policy {
	t.Helper()
	policy, err := NewLibrary(SubscriptionLayer{}, UserLayer{}).Compile(id, b)
	if err != nil {
		t.Fatal(err)
	}
	return policy
}

func measuredFacts(at time.Time, ms ...int) *Facts {
	f := &Facts{}
	for i, v := range ms {
		f.noteSample(at.Add(time.Duration(i-len(ms))*time.Minute), v, ProbeSource)
	}
	return f
}

func deadFacts(at time.Time) *Facts {
	f := &Facts{}
	f.markDead(at)
	return f
}

func members(facts map[string]*Facts, names ...string) []Member {
	out := make([]Member, len(names))
	for i, name := range names {
		out[i] = Member{Node: Node{Name: name, Type: "Vless"}, Key: "k-" + name, Facts: facts[name]}
	}
	return out
}

func input(policy *Policy, now string, ms []Member) DecideInput {
	return DecideInput{Policy: policy, Members: ms, Now: now, Control: Control{Mode: AutoMode}, Freshness: baseFreshness, At: t0, LastSwitch: t0.Add(-time.Hour)}
}

func TestSimpleHoldsAWorkingNodeEvenWhenOthersAreFaster(t *testing.T) {
	facts := map[string]*Facts{"A": measuredFacts(t0, 300, 300), "B": measuredFacts(t0, 40, 40, 40)}
	d := Decide(input(compiled(t, "builtin/simple", Binding{}), "A", members(facts, "A", "B")))
	if d.Action != HoldAction || d.Target != "A" || d.Reason.Code != "hold.working" {
		t.Fatalf("simple moved off a working node: %+v", d)
	}
}

func TestFailoverPicksTheBestKnownStandby(t *testing.T) {
	facts := map[string]*Facts{"A": deadFacts(t0), "B": measuredFacts(t0, 200), "C": measuredFacts(t0, 90)}
	d := Decide(input(compiled(t, "builtin/simple", Binding{}), "A", members(facts, "A", "B", "C", "D")))
	if d.Action != SwitchAction || d.Target != "C" || d.Reason.Code != "switch.failover" {
		t.Fatalf("failover went wrong: %+v", d)
	}
	if d.Ranking[len(d.Ranking)-1].Name != "A" || d.Ranking[len(d.Ranking)-1].Excluded.Code != "dead" {
		t.Fatalf("dead node not ranked last with its reason: %+v", d.Ranking)
	}
}

func TestFastestNeedsGainDwellAndConfirmation(t *testing.T) {
	policy := compiled(t, "builtin/fastest", Binding{})
	facts := map[string]*Facts{"A": measuredFacts(t0, 200, 200), "B": measuredFacts(t0, 100)}
	in := input(policy, "A", members(facts, "A", "B"))
	in.Freshness = 3 * time.Hour

	d := Decide(in)
	if d.Action != HoldAction || d.Reason.Code != "hold.confirming" || len(d.Needs) != 1 || d.Needs[0] != "B" {
		t.Fatalf("one sample switched or asked nothing: %+v", d)
	}
	facts["B"] = measuredFacts(t0, 100, 100)
	in.Members = members(facts, "A", "B")
	if d = Decide(in); d.Action != SwitchAction || d.Reason.Code != "switch.faster" {
		t.Fatalf("a confirmed gain did not switch: %+v", d)
	}
	in.LastSwitch = t0.Add(-time.Minute)
	if d = Decide(in); d.Reason.Code != "hold.dwell" || d.Until == nil {
		t.Fatalf("dwell ignored: %+v", d)
	}
	in.LastSwitch = t0.Add(-time.Hour)
	in.SwitchesHour = policy.MaxPerHour
	if d = Decide(in); d.Reason.Code != "hold.flap-limit" {
		t.Fatalf("flap limit ignored: %+v", d)
	}
	in.SwitchesHour = 0
	facts["B"] = measuredFacts(t0, 185, 185)
	in.Members = members(facts, "A", "B")
	if d = Decide(in); d.Action != HoldAction || d.Reason.Code != "hold.best" {
		t.Fatalf("a gain within the threshold switched: %+v", d)
	}
}

func TestIncumbentWinsWithinTolerance(t *testing.T) {
	facts := map[string]*Facts{"A": measuredFacts(t0, 110), "B": measuredFacts(t0, 100)}
	d := Decide(input(compiled(t, "builtin/fastest", Binding{}), "A", members(facts, "A", "B")))
	if d.Ranking[0].Name != "A" || d.Reason.Code != "hold.best" {
		t.Fatalf("a 10 ms difference reordered the incumbent: %+v", d)
	}
}

func TestPinHoldsUntilTheNodeDies(t *testing.T) {
	policy := compiled(t, "builtin/fastest", Binding{})
	facts := map[string]*Facts{"A": measuredFacts(t0, 400), "B": measuredFacts(t0, 50, 50, 50)}
	in := input(policy, "A", members(facts, "A", "B"))
	in.Control = Control{Mode: PinnedMode, PinName: "A"}
	if d := Decide(in); d.Action != HoldAction || d.Reason.Code != "hold.pinned" {
		t.Fatalf("pinned node left while alive: %+v", d)
	}
	facts["A"] = deadFacts(t0)
	in.Members = members(facts, "A", "B")
	d := Decide(in)
	if d.Target != "B" || d.Reason.Code != "switch.failover" || d.Reason.Args["pin"] != "A" || len(d.Needs) == 0 {
		t.Fatalf("pinned failure handled wrong: %+v", d)
	}
	in.Now = "B"
	facts["A"] = measuredFacts(t0, 300)
	in.Members = members(facts, "A", "B")
	if d := Decide(in); d.Target != "A" || d.Reason.Code != "switch.pinned" {
		t.Fatalf("did not return to the recovered pin: %+v", d)
	}
}

func TestChangeServerExcludesTheCurrentNode(t *testing.T) {
	facts := map[string]*Facts{"A": measuredFacts(t0, 50), "B": measuredFacts(t0, 90)}
	in := input(compiled(t, "builtin/simple", Binding{}), "A", members(facts, "A", "B"))
	in.ForceSwitch = true
	in.Excluded = map[string]time.Time{"k-A": t0.Add(ChangeCooldown)}
	d := Decide(in)
	if d.Target != "B" || d.Reason.Code != "switch.change-server" {
		t.Fatalf("change server did not move: %+v", d)
	}
	in.Members = members(facts, "A")
	if d := Decide(in); d.Action != HoldAction || d.Reason.Code != "hold.no-alternative" {
		t.Fatalf("change server with no alternative: %+v", d)
	}
}

func TestPoolFilterGivesReasons(t *testing.T) {
	policy := compiled(t, "builtin/from-list", Binding{Pool: Pool{Include: "name ~ /DE/"}})
	d := Decide(input(policy, "NL-1", members(nil, "NL-1", "DE-1", "REJECT")))
	if d.Target != "DE-1" || d.Reason.Code != "switch.out-of-pool" {
		t.Fatalf("out-of-pool current kept: %+v", d)
	}
	for _, row := range d.Ranking {
		if row.Name == "NL-1" && (row.Excluded == nil || row.Excluded.Code != "pool.no-match") {
			t.Fatalf("missing pool reason: %+v", row)
		}
	}
}

func TestStrandedHoldsOrFallsBack(t *testing.T) {
	facts := map[string]*Facts{"A": deadFacts(t0), "B": deadFacts(t0)}
	d := Decide(input(compiled(t, "builtin/simple", Binding{}), "A", members(facts, "A", "B")))
	if d.Action != StrandedAction || d.Target != "A" {
		t.Fatalf("stranded group moved: %+v", d)
	}
}

func TestManualModeNeverActs(t *testing.T) {
	facts := map[string]*Facts{"A": deadFacts(t0), "B": measuredFacts(t0, 20)}
	in := input(compiled(t, "builtin/simple", Binding{}), "A", members(facts, "A", "B"))
	in.Control.Mode = ManualMode
	if d := Decide(in); d.Action != ManualAction || d.Target != "A" {
		t.Fatalf("manual group acted: %+v", d)
	}
}

func TestDecideIsDeterministic(t *testing.T) {
	facts := map[string]*Facts{"A": measuredFacts(t0, 80), "B": measuredFacts(t0, 80), "C": measuredFacts(t0, 80)}
	in := input(compiled(t, "builtin/fastest", Binding{}), "X", members(facts, "C", "A", "B", "X"))
	first := Decide(in)
	for range 20 {
		if d := Decide(in); d.Target != first.Target || d.Ranking[0].Name != first.Ranking[0].Name {
			t.Fatal("decision depends on iteration order")
		}
	}
}

func ladderMembers(facts map[string]*Facts, countries map[string]string) []Member {
	ms := members(facts, "A", "B", "C", "D")
	for i := range ms {
		ms[i].NameCountry = countries[ms[i].Name]
	}
	return ms
}

func TestLadderFallsThroughStepsWhoseServersAreDown(t *testing.T) {
	ladder := []TierSpec{
		{Label: "Germany", When: "country = DE"},
		{Label: "Nearby", When: "country in [NL, PL]"},
		{Label: "Any", When: "not dead", LastResort: true},
	}
	countries := map[string]string{"A": "US", "B": "DE", "C": "NL", "D": ""}
	for _, tc := range []struct {
		name  string
		dead  []string
		first string
		tier  string
	}{
		{"first step wins over a faster server", nil, "B", "Germany"},
		{"a dead step falls through", []string{"B"}, "C", "Nearby"},
		{"every step down reaches the last resort", []string{"B", "C"}, "A", "Any"},
		{"nothing alive", []string{"A", "B", "C", "D"}, "", ""},
	} {
		facts := map[string]*Facts{"A": measuredFacts(t0, 40, 40), "B": measuredFacts(t0, 300, 300), "C": measuredFacts(t0, 90, 90), "D": measuredFacts(t0, 60, 60)}
		for _, name := range tc.dead {
			facts[name] = deadFacts(t0)
		}
		d := Decide(input(compiled(t, "builtin/fastest", Binding{Prefer: ladder}), "", ladderMembers(facts, countries)))
		top := d.Ranking[0]
		if tc.first == "" {
			if top.Excluded == nil {
				t.Errorf("%s: %s ranked usable", tc.name, top.Name)
			}
			continue
		}
		if top.Name != tc.first || top.TierLabel != tc.tier || top.Excluded != nil {
			t.Errorf("%s: first %s in %q (%v), want %s in %q", tc.name, top.Name, top.TierLabel, top.Excluded, tc.first, tc.tier)
		}
		for _, row := range d.Ranking {
			if slices.Contains(tc.dead, row.Name) && (row.Excluded == nil || row.Excluded.Code != "dead") {
				t.Errorf("%s: dead %s ranked %+v", tc.name, row.Name, row)
			}
		}
	}
}

func TestCountryNeverWaitsForACheck(t *testing.T) {
	ladder := []TierSpec{{Label: "Germany", When: "country = DE"}}
	facts := map[string]*Facts{"A": measuredFacts(t0, 40), "B": measuredFacts(t0, 90), "C": measuredFacts(t0, 90), "D": measuredFacts(t0, 90)}
	ms := ladderMembers(facts, map[string]string{"B": "DE", "C": "US"})
	ms[2].Exit = &ExitFact{Country: "DE", At: t0}
	ms[1].Exit = &ExitFact{Country: "FR", At: t0}
	d := Decide(input(compiled(t, "builtin/fastest", Binding{Prefer: ladder}), "", ms))
	byName := map[string]Ranked{}
	for _, row := range d.Ranking {
		byName[row.Name] = row
	}
	if row := byName["C"]; row.Excluded != nil || row.TierLabel != "Germany" {
		t.Errorf("a verified exit did not beat the name: %+v", row)
	}
	if row := byName["B"]; row.Excluded == nil || row.Excluded.Code != "no-tier" {
		t.Errorf("the name beat a verified exit: %+v", row)
	}
	if row := byName["D"]; row.Excluded == nil || row.Excluded.Code != "no-tier" || len(d.Needs) != 0 {
		t.Errorf("a server with no country waits for a check: %+v, needs %v", row, d.Needs)
	}
}

func TestServerOrderPrecedence(t *testing.T) {
	own := []TierSpec{{Label: "Own", When: "country = US"}}
	program := []TierSpec{{Label: "Program", When: "country = DE"}}
	for _, tc := range []struct {
		name string
		b    Binding
		want string
	}{
		{"profile", Binding{}, "Working"},
		{"binding over profile", Binding{Prefer: own}, "Own"},
		{"program over binding", Binding{Prefer: own, prefer: program}, "Program"},
	} {
		policy := compiled(t, "builtin/fastest", tc.b)
		if got := policy.Tiers[0].Label; got != tc.want {
			t.Errorf("%s: first step %q, want %q", tc.name, got, tc.want)
		}
	}
	if _, err := NewLibrary(SubscriptionLayer{}, UserLayer{}).Compile("builtin/fastest", Binding{Prefer: []TierSpec{{When: "country ="}}}); err == nil {
		t.Error("a broken step compiled")
	}
}

func TestLastResortYieldsToStepsBelowIt(t *testing.T) {
	profile, err := ParseProfile([]byte(`rcx: 1
title: T
prefer:
  - { label: Spare, when: 'name ~ /spare/', last-resort: true }
  - { label: Main, when: 'not dead' }
`))
	if err != nil {
		t.Fatal(err)
	}
	policy, err := compileProfile("user/t", profile)
	if err != nil {
		t.Fatal(err)
	}
	if got := []string{policy.Tiers[0].Label, policy.Tiers[1].Label}; got[0] != "Main" || got[1] != "Spare" {
		t.Fatalf("tiers = %v, want the last-resort step after Main", got)
	}
	if policy.Tiers[1].Source != 0 {
		t.Fatalf("source = %d, want 0", policy.Tiers[1].Source)
	}
}
