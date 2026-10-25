package core

import (
	"os"
	"path/filepath"
	"slices"
	"testing"

	"core/rcx"

	"github.com/metacubex/mihomo/adapter/outboundgroup"
	"github.com/metacubex/mihomo/constant"
)

const routedProfile = `
proxies:
  - { name: a, type: socks5, server: 127.0.0.1, port: 1080 }
  - { name: b, type: socks5, server: 127.0.0.2, port: 1080 }
proxy-groups:
  - { name: g, type: select, proxies: [a, b] }
rules:
  - MATCH,g
rcx-scenario: routed
rcx-scenarios:
  routed:
    title: Routed
    routes:
      - name: Video
        match: [DOMAIN-SUFFIX,youtube.com, "IP-CIDR,10.0.0.0/8,no-resolve"]
      - name: Broken
        match: ["DOMAIN-REGEX,(unclosed"]
      - name: g
        match: [DOMAIN,taken.example]
      - name: Away
        match: [DOMAIN,away.example]
        to: nowhere
      - name: Bank
        match: [DOMAIN-KEYWORD,bank]
        to: DIRECT
`

func setupHome(t *testing.T, profile string) {
	t.Helper()
	home := t.TempDir()
	previous := constant.Path.HomeDir()
	constant.SetHomeDir(home)
	t.Cleanup(func() { constant.SetHomeDir(previous) })
	if err := os.WriteFile(filepath.Join(home, "config.yaml"), []byte(profile), 0o600); err != nil {
		t.Fatalf("write config: %v", err)
	}
}

func TestRoutesBuildIntoTheConfigAndABrokenOneStaysOut(t *testing.T) {
	setupHome(t, routedProfile)
	params := defaultSetupParams()
	params.Rcx = &rcx.UserLayer{}
	load, err := loadSetupConfig(params)
	if err != nil {
		t.Fatalf("loadSetupConfig = %v", err)
	}
	video := load.cfg.Proxies["Video"]
	if video == nil || video.Type() != constant.Selector {
		t.Fatalf("route group Video = %v", video)
	}
	selector, _ := adapterAs[*outboundgroup.Selector](video)
	var members []string
	for _, member := range selector.GetProxies(false) {
		members = append(members, member.Name())
	}
	if !slices.Equal(members, []string{"a", "b"}) {
		t.Errorf("route group members = %v, want every server", members)
	}
	if load.cfg.Proxies["a"] == nil || load.cfg.Proxies["g"] == nil {
		t.Fatal("the config fell back instead of dropping the broken route")
	}
	want := []string{
		"DomainSuffix,youtube.com,Video",
		"IPCIDR,10.0.0.0/8,Video",
		"DomainKeyword,bank,DIRECT",
		"Match,,g",
	}
	if got := ruleStrings(load.cfg); !slices.Equal(got, want) {
		t.Errorf("rules = %v, want %v", got, want)
	}
	routes := load.routes
	if !routes.Applied || routes.Key == "" || !slices.Equal(routes.Groups, []string{"Video"}) {
		t.Errorf("applied = %+v", routes)
	}
	codes := map[string]string{}
	for name, problem := range routes.Problems {
		codes[name] = problem.Code
	}
	wantCodes := map[string]string{"Broken": "route.invalid", "g": "route.name-taken", "Away": "route.to-missing"}
	if len(codes) != len(wantCodes) {
		t.Errorf("problems = %v, want %v", codes, wantCodes)
	}
	for name, code := range wantCodes {
		if codes[name] != code {
			t.Errorf("problem of %s = %q, want %q", name, codes[name], code)
		}
	}
	if _, key := rcx.ScenarioRoutes(load.subscription, *params.Rcx); key != routes.Key {
		t.Errorf("applied key %q, the engine wants %q", routes.Key, key)
	}
}

func TestRoutesStayOutWhenTheScenarioIsOff(t *testing.T) {
	setupHome(t, routedProfile)
	params := defaultSetupParams()
	params.Rcx = &rcx.UserLayer{ScenarioOff: true}
	load, err := loadSetupConfig(params)
	if err != nil {
		t.Fatalf("loadSetupConfig = %v", err)
	}
	if load.cfg.Proxies["Video"] != nil || load.routes.Key != "" || len(load.routes.Groups) != 0 {
		t.Fatalf("routes applied with the scenario off: %+v", load.routes)
	}
}

func TestSubscriptionScenarioSurvivesTheBaseMerge(t *testing.T) {
	path := writeBaseProfile(t, routedProfile)
	base, err := handleGetProfileBase(path)
	if err != nil {
		t.Fatalf("handleGetProfileBase = %v", err)
	}
	configPath := filepath.Join(t.TempDir(), "config.yaml")
	if _, err := loadConfigWithBase(&SetupBase{Path: path, Overlay: overlayOf(t, base, []string{"MATCH,g"}, nil)}, configPath); err != nil {
		t.Fatalf("loadConfigWithBase = %v", err)
	}
	layer := rcxReadSubscription(configPath)
	if _, ok := layer.Scenarios["routed"]; !ok || layer.Scenario != "routed" {
		t.Fatalf("scenario lost in the merge: %+v", layer)
	}
}
