package rcx

import (
	"errors"
	"slices"
	"strings"
	"testing"
	"time"
)

const routedScenario = `
title: Routed
routes:
  - name: Video
    match: [GEOSITE,youtube, "IP-CIDR,10.0.0.0/8,no-resolve"]
    profile: builtin/fastest
  - name: AI
    match: [DOMAIN-SUFFIX,openai.com]
  - name: Bank
    match: [DOMAIN-KEYWORD,bank]
    to: DIRECT
`

func TestRouteValidation(t *testing.T) {
	for doc, path := range map[string]string{
		"routes: [{ name: GLOBAL, match: [DOMAIN,a.b] }]\n":                          "routes.0.name",
		"routes: [{ name: A, match: [DOMAIN,a.b] }, { name: A, match: [DOMAIN,c] }]": "routes.1.name",
		"routes: [{ name: A, match: [DOMAIN,a.b, 'IP-CIDR,1.2.3.4'] }]\n":            "routes.0.match.2",
		"routes: [{ name: A, match: ['DOMAIN,a.b,no-resolve'] }]\n":                  "routes.0.match.0",
		"routes: [{ name: A, match: ['MATCH,x'] }]\n":                                "routes.0.match.0",
		"routes: [{ name: A, match: [] }]\n":                                         "routes.0.match",
		"routes: [{ name: 'A,B', match: [DOMAIN,a] }]\n":                             "routes.0.name",
		"routes: [{ name: A, match: [DOMAIN,a], to: B, profile: builtin/simple }]\n": "routes.0.to",
		"groups: { A: {} }\nroutes: [{ name: A, match: [DOMAIN,a] }]\n":              "routes.0.name",
	} {
		_, err := ParseScenario([]byte(doc))
		var at *PathError
		if !errors.As(err, &at) || pathString(at.Path) != path {
			t.Errorf("%q: %v at %v, want %s", doc, err, at, path)
		}
	}
	s, err := ParseScenario([]byte(routedScenario))
	if err != nil {
		t.Fatal(err)
	}
	want := []string{"GEOSITE,youtube", "IP-CIDR,10.0.0.0/8,no-resolve"}
	if !slices.Equal(s.Routes[0].Match, want) || s.Routes[0].Profile != "builtin/fastest" {
		t.Fatalf("route = %+v", s.Routes[0])
	}
	text, err := FormatScenario(s)
	if err != nil {
		t.Fatal(err)
	}
	again, err := ParseScenario([]byte(text))
	if err != nil || !slices.Equal(again.Routes[0].Match, want) {
		t.Fatalf("formatted routes do not read back: %v\n%s", err, text)
	}
}

func routedSim(t *testing.T, scenario string, applied []string) *sim {
	user := UserLayer{Scenario: "user/s", Scenarios: map[string]string{"s": scenario}}
	s := newScenarioSim(t, user)
	_, key := ScenarioRoutes(SubscriptionLayer{}, user)
	members := s.m.topology.Groups[0].Members
	for _, name := range applied {
		s.m.topology.Groups = append(s.m.topology.Groups, GroupTopology{Name: name, Now: "n2", Members: members})
	}
	s.m.topology.Routes = AppliedRoutes{Applied: true, Key: key, Groups: applied,
		Problems: map[string]Reason{"AI": {Code: "route.name-taken", Args: map[string]any{"route": "AI"}}}}
	s.m.rebuild(s.now)
	return s
}

func TestRouteGroupsRunTheirProgram(t *testing.T) {
	s := routedSim(t, routedScenario, []string{"Video"})
	s.run(time.Minute, 30*time.Second, s.useAll)
	video := s.m.groups["Video"]
	if video == nil || video.program != "Video" || video.policy.ID != "builtin/fastest" {
		t.Fatalf("route group = %+v", video)
	}
	if ai := s.m.groups["AI"]; ai != nil && ai.program != "" {
		t.Fatalf("the config's own AI group took the route's program")
	}
	status := s.m.status(s.now)
	if status.Reload || slices.ContainsFunc(status.Problems, func(r Reason) bool { return r.Code == "route.not-rule-mode" }) {
		t.Fatalf("status = reload %v, problems %v", status.Reload, status.Problems)
	}
	routes := status.Scenario.Routes
	if len(routes) != 3 || routes[2].To != "DIRECT" || routes[1].Problem == nil || routes[1].Problem.Code != "route.name-taken" || routes[0].Problem != nil {
		t.Fatalf("routes = %+v", routes)
	}
	for _, g := range status.Groups {
		if g.Route != (g.Name == "Video") {
			t.Errorf("group %s route = %v", g.Name, g.Route)
		}
	}

	s.m.userMode = "global"
	if status := s.m.status(s.now); !slices.ContainsFunc(status.Problems, func(r Reason) bool { return r.Code == "route.not-rule-mode" }) {
		t.Fatalf("problems in global mode = %v", status.Problems)
	}
}

func TestRouteReloadFollowsWhatTheConfigTakes(t *testing.T) {
	s := routedSim(t, routedScenario, []string{"Video"})
	edit := func(scenario string) bool {
		s.m.user.Scenarios = map[string]string{"s": scenario}
		s.m.rebuild(s.now)
		return s.m.status(s.now).Reload
	}
	if edit(strings.Replace(routedScenario, "builtin/fastest", "builtin/stable", 1)) {
		t.Fatal("a program change asked for a new config")
	}
	if s.m.groups["Video"].policy.ID != "builtin/stable" {
		t.Fatalf("the program change did not apply live: %s", s.m.groups["Video"].policy.ID)
	}
	if !edit(strings.Replace(routedScenario, "openai.com", "anthropic.com", 1)) {
		t.Fatal("a match change did not ask for a new config")
	}
	if !edit("title: Plain\n") {
		t.Fatal("dropping every route did not ask for a new config")
	}
	s.m.topology.Routes = AppliedRoutes{Applied: true}
	s.m.rebuild(s.now)
	if s.m.status(s.now).Reload {
		t.Fatal("reload after a config without routes")
	}
	s.m.topology.Routes = AppliedRoutes{}
	if edit(routedScenario) {
		t.Fatal("reload before any config was applied")
	}
}

func TestRouteOnLayerOverridesTheRouteProgram(t *testing.T) {
	scenario := routedScenario + `
network:
  kinds: [{ kind: home, when: network.transport = wifi }]
on:
  home: { groups: { Video: { profile: builtin/simple } } }
`
	s := routedSim(t, scenario, []string{"Video"})
	if s.m.scn.problem != nil {
		t.Fatal(s.m.scn.problem)
	}
	if got := s.m.groups["Video"].policy.ID; got != "builtin/fastest" {
		t.Fatalf("base: Video runs %s", got)
	}
	s.joinNetwork("wifi", false)
	s.run(10*time.Minute, 30*time.Second, s.useAll)
	if got := s.m.groups["Video"].policy.ID; s.m.scn.kind != "home" || got != "builtin/simple" {
		t.Fatalf("on %q: Video runs %s", s.m.scn.kind, got)
	}
}
