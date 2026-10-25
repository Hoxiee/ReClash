package rcx

import (
	"fmt"
	"maps"
	"slices"
	"testing"
	"time"
)

func newScenarioSim(t *testing.T, user UserLayer) *sim {
	s := &sim{t: t, rt: &simRuntime{}, now: t0, latency: map[string]int{}, linkUp: true, probes: map[int]int{}}
	s.m = newMachine(s.rt)
	var members []Node
	for i := range 6 {
		name := fmt.Sprintf("n%d", i)
		if i == 4 {
			name = "RU LTE 4"
		}
		members = append(members, Node{Name: name, Type: "Vless", Server: name, Strong: name})
		s.latency[name] = 60 + i
	}
	s.m.topology = Topology{
		Groups: []GroupTopology{
			{Name: "Proxy", Now: "n0", Members: members},
			{Name: "AI", Now: "n1", Members: members},
			{Name: GlobalTarget, Now: "n0", Members: members},
		},
		Main: "Proxy",
	}
	s.m.user = user
	s.m.userMode = "rule"
	s.m.running = true
	s.m.rebuild(s.now)
	return s
}

func (s *sim) useAll() {
	for _, g := range s.m.groups {
		if g.now != "" && !s.m.idle(g) {
			s.m.onTraffic(map[string]int{g.now: 1}, s.now)
		}
	}
}

func TestScenarioHoldsModeAndGroupsPerNetwork(t *testing.T) {
	s := newScenarioSim(t, UserLayer{Scenario: "builtin/whitelist-ru"})
	s.joinNetwork("wifi", false)
	s.run(10*time.Minute, 30*time.Second, s.useAll)
	if s.m.scn.kind != "open" || s.m.tunnelMode() != "rule" || len(s.rt.modes) != 0 {
		t.Fatalf("open network: kind %q, mode %q, applied %v", s.m.scn.kind, s.m.tunnelMode(), s.rt.modes)
	}
	proxy := s.m.groups["Proxy"]
	if proxy == nil || proxy.program != MainTarget || proxy.policy.ID != "builtin/bypass-ru" || proxy.now == "RU LTE 4" {
		t.Fatalf("main group = %+v", proxy)
	}
	if _, named := s.m.groups[GlobalTarget]; named {
		t.Fatal("GLOBAL is driven on an open network")
	}

	s.diag = map[string]bool{"tls 1.1.1.1:443": false, "tls 9.9.9.9:443": false}
	s.joinNetwork("cellular", false)
	s.run(10*time.Minute, 30*time.Second, s.useAll)
	global := s.m.groups[GlobalTarget]
	if s.m.scn.kind != "whitelist" || s.m.tunnelMode() != "global" || !slices.Equal(s.rt.modes, []string{"global"}) {
		t.Fatalf("whitelist: kind %q, mode %q, applied %v", s.m.scn.kind, s.m.tunnelMode(), s.rt.modes)
	}
	if global == nil || global.now != "RU LTE 4" || !s.m.idle(s.m.groups["Proxy"]) {
		t.Fatalf("GLOBAL = %+v", global)
	}

	s.m.user.ManualMode = true
	s.m.rebuild(s.now)
	s.step()
	if s.m.tunnelMode() != "rule" || s.rt.modes[len(s.rt.modes)-1] != "" {
		t.Fatalf("a manual mode did not win: %q, applied %v", s.m.tunnelMode(), s.rt.modes)
	}
}

func TestScenarioTargetsAndFixedMembers(t *testing.T) {
	scenario := `
groups:
  '*': {}
  $main: { profile: builtin/fastest }
  AI: { to: n3 }
`
	s := newScenarioSim(t, UserLayer{Scenario: "user/s", Scenarios: map[string]string{"s": scenario}})
	s.run(time.Minute, 30*time.Second, s.useAll)
	if s.m.scn.problem != nil {
		t.Fatal(s.m.scn.problem)
	}
	got := map[string]string{}
	for name, g := range s.m.groups {
		got[name] = g.program
	}
	if want := map[string]string{"Proxy": MainTarget, "AI": "AI"}; !maps.Equal(got, want) {
		t.Fatalf("programs = %v", got)
	}
	if s.m.groups["Proxy"].policy.ID != "builtin/fastest" {
		t.Fatalf("main runs %s", s.m.groups["Proxy"].policy.ID)
	}
	ai := s.m.groups["AI"]
	if ai.now != "n3" || ai.decision.Reason.Code != "hold.fixed" {
		t.Fatalf("AI on %s: %v", ai.now, ai.decision.Reason)
	}
	s.m.controls["AI"].Control = Control{Mode: PinnedMode, PinName: "n2", Pin: ai.members[ai.byName["n2"]].Key}
	s.step()
	if ai.now != "n2" {
		t.Fatalf("a pin did not beat the fixed member: on %s", ai.now)
	}
}

func TestScenarioValidation(t *testing.T) {
	for _, doc := range []string{
		"mode: tunnel\n",
		"groups: { A: { to: x, profile: builtin/simple } }\n",
		"on: { WiFi: { mode: rule } }\n",
		"groups: { A: { to: x, prefer: [{ label: L, when: alive }] } }\n",
		"groups: { A: { rank: {} } }\n",
	} {
		if _, err := ParseScenario([]byte(doc)); err == nil {
			t.Errorf("%q parsed", doc)
		}
	}
	lib := NewLibrary(SubscriptionLayer{}, UserLayer{Scenarios: map[string]string{
		"missing": "groups: { A: { profile: builtin/nope } }\n",
		"kind":    "on: { whitelist: { mode: global } }\n",
		"pool":    "groups: { A: { profile: builtin/simple, pool: { include: tag(nope) } } }\n",
	}})
	for _, id := range []string{"user/missing", "user/kind", "user/pool"} {
		if _, err := lib.CompileScenario(id); err == nil {
			t.Errorf("%s compiled", id)
		}
	}
}
