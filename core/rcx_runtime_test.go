package core

import (
	"net/netip"
	"os"
	"path/filepath"
	"slices"
	"sync/atomic"
	"testing"
	"time"

	"core/rcx"

	"github.com/metacubex/mihomo/constant"
)

const smartProfile = `
proxies:
  - { name: a, type: socks5, server: 127.0.0.1, port: 1080 }
  - { name: b, type: socks5, server: 127.0.0.2, port: 1080 }
proxy-groups:
  - name: g
    type: select
    proxies: [a, b]
    rcx:
      profiles: [builtin/simple, mobile]
      default: mobile
rcx-profiles:
  mobile:
    title: Mobile
    extends: builtin/fastest
    pool: { include: 'name ~ /a|b/' }
rules:
  - MATCH,g
`

// A subscription that carries routing profiles must still load in any mihomo,
// and the engine must find both keys after the base merge.
func TestSmartSubscriptionLoadsAndKeepsItsRoutingKeys(t *testing.T) {
	path := writeBaseProfile(t, smartProfile)
	base, err := handleGetProfileBase(path)
	if err != nil {
		t.Fatalf("handleGetProfileBase = %v", err)
	}
	configPath := filepath.Join(t.TempDir(), "config.yaml")
	cfg, err := loadConfigWithBase(&SetupBase{Path: path, Overlay: overlayOf(t, base, nil, nil)}, configPath)
	if err != nil {
		t.Fatalf("loadConfigWithBase = %v", err)
	}
	if cfg.Proxies["g"] == nil {
		t.Fatal("the smart group did not load")
	}
	layer := rcxReadSubscription(configPath)
	binding, ok := layer.Groups["g"]
	if !ok || binding.Default != "mobile" || len(binding.Profiles) != 2 {
		t.Fatalf("group binding = %+v", layer.Groups)
	}
	if _, ok := layer.Profiles["mobile"]; !ok {
		t.Fatalf("rcx-profiles lost in the merge: %v", layer.Profiles)
	}
	if _, err := loadConfig(configPath); err != nil {
		t.Fatalf("the written config does not load alone: %v", err)
	}
}

func TestPlainSubscriptionHasNoRoutingLayer(t *testing.T) {
	path := writeBaseProfile(t, baseProfile)
	if layer := rcxReadSubscription(path); len(layer.Groups) != 0 || len(layer.Profiles) != 0 {
		t.Fatalf("layer = %+v", layer)
	}
}

const nestedProfile = `
proxies:
  - { name: a, type: socks5, server: 127.0.0.1, port: 1080 }
  - { name: b, type: socks5, server: 127.0.0.2, port: 1080 }
  - { name: c, type: socks5, server: 127.0.0.3, port: 1080 }
proxy-groups:
  - { name: g, type: select, proxies: [de, shared, a] }
  - { name: de, type: select, proxies: [a, b] }
  - { name: shared, type: select, proxies: [c] }
  - { name: video, type: select, proxies: [shared] }
rules:
  - MATCH,g
`

// Only a nested selector the smart group alone routes through is opened up;
// one another group uses stays a single candidate, and a duplicate server
// keeps its direct path.
func TestNestedSelectorsFlattenOnlyWhenOwned(t *testing.T) {
	cfg, err := loadConfig(writeBaseProfile(t, nestedProfile))
	if err != nil {
		t.Fatal(err)
	}
	names := []string{"g", "de", "shared", "video"}
	smart := map[string]bool{"g": true}
	topology, flat := rcxTopologyOf(cfg.Proxies, names, smart, rcxReferences(cfg.Proxies, names, cfg.Rules))
	var g rcx.GroupTopology
	for _, group := range topology.Groups {
		if group.Name == "g" {
			g = group
		}
	}
	got := map[string][]string{}
	for _, member := range g.Members {
		got[member.Name] = member.Via
	}
	if len(got) != 3 || len(got["a"]) != 0 || !slices.Equal(got["b"], []string{"de"}) {
		t.Fatalf("members = %v", got)
	}
	if _, ok := got["shared"]; !ok {
		t.Fatalf("a shared selector was flattened: %v", got)
	}
	if flat["de"] != "g" || len(flat) != 1 {
		t.Fatalf("flat = %v", flat)
	}
	if g.Now != "a" {
		t.Fatalf("now = %q, want the leaf behind de", g.Now)
	}
}

func TestDirectSplitKeepsLocalDestinations(t *testing.T) {
	local := []*constant.Metadata{
		{DstIP: netip.MustParseAddr("192.168.1.1")},
		{DstIP: netip.MustParseAddr("100.100.1.1")},
		{DstIP: netip.MustParseAddr("fd00::1")},
		{DstIP: netip.MustParseAddr("fe80::1")},
		{Host: "printer.local"},
		{Host: "router"},
		{Host: "nas.home.arpa."},
	}
	for _, m := range local {
		if !rcxLocal(m) {
			t.Errorf("%v %q would leave through the tunnel", m.DstIP, m.Host)
		}
	}
	for _, m := range []*constant.Metadata{{Host: "gosuslugi.ru"}, {DstIP: netip.MustParseAddr("77.88.8.8")}} {
		if rcxLocal(m) {
			t.Errorf("%v %q kept local", m.DstIP, m.Host)
		}
	}
}

func TestEchoFormatsYieldAddressAndCountry(t *testing.T) {
	cases := map[string][2]string{
		"fl=1\nip=203.0.113.7\nts=1\nloc=DE\n":           {"203.0.113.7", "DE"},
		`{"ip":"203.0.113.7","country":"NL","city":"x"}`: {"203.0.113.7", "NL"},
		`{"query":"203.0.113.7","countryCode":"FI"}`:     {"203.0.113.7", "FI"},
		"203.0.113.7\n": {"203.0.113.7", ""},
	}
	for body, want := range cases {
		ip, country := rcxParseEcho([]byte(body))
		if ip.String() != want[0] || country != want[1] {
			t.Errorf("%q = %v %q, want %v", body, ip, country, want)
		}
	}
	if !rcxVotesSettled([]rcx.ExitVote{{Source: "a", Country: "DE"}, {Source: "b", Country: "NL"}}, 2) {
		t.Error("disagreeing votes asked for more echoes")
	}
	if rcxVotesSettled([]rcx.ExitVote{{Source: "a", Country: "DE"}}, 2) {
		t.Error("one vote settled an agreement of two")
	}
}

func TestRoutingBundleYieldsToTheSubscription(t *testing.T) {
	dir := t.TempDir()
	config := filepath.Join(dir, "p1.yaml")
	writeFile := func(path, text string) {
		if err := os.WriteFile(path, []byte(text), 0o600); err != nil {
			t.Fatal(err)
		}
	}
	writeFile(config, "proxy-groups:\n  - { name: A, type: select, rcx: { default: inline } }\nrcx-profiles:\n  inline: { title: Inline }\n  shared: { title: From subscription }\n")
	writeFile(rcxBundlePath(config), "rcx: 1\nprofiles:\n  shared: { title: From bundle }\n  extra: { title: Extra }\ngroups:\n  A: { default: extra }\n  B: { default: extra }\n")
	layer := rcxReadSubscription(config)
	if layer.Groups["A"].Default != "inline" || layer.Groups["B"].Default != "extra" {
		t.Fatalf("groups %+v", layer.Groups)
	}
	if title := layer.Profiles["shared"].(map[string]any)["title"]; title != "From subscription" || layer.Profiles["extra"] == nil {
		t.Fatalf("profiles %+v", layer.Profiles)
	}
}

func TestSubscriptionScenarioAndMainGroup(t *testing.T) {
	dir := t.TempDir()
	config := filepath.Join(dir, "p2.yaml")
	if err := os.WriteFile(config, []byte("rcx-scenario: mobile\nrcx-scenarios:\n  mobile: { mode: rule }\n"), 0o600); err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(rcxBundlePath(config), []byte("rcx: 1\nscenario: other\nscenarios:\n  other: { mode: global }\n"), 0o600); err != nil {
		t.Fatal(err)
	}
	layer := rcxReadSubscription(config)
	if layer.Scenario != "mobile" || layer.Scenarios["mobile"] == nil || layer.Scenarios["other"] == nil {
		t.Fatalf("layer %+v", layer)
	}
	cfg, err := loadConfig(writeBaseProfile(t, nestedProfile))
	if err != nil {
		t.Fatal(err)
	}
	if main := rcxMainGroup(cfg.Proxies, cfg.Rules); main != "g" {
		t.Fatalf("main = %q", main)
	}
}

func TestCoalescedRunCoversABurstWithOneMoreRun(t *testing.T) {
	var c coalescedRun
	var runs atomic.Int32
	entered, release := make(chan struct{}), make(chan struct{})
	run := func() {
		if runs.Add(1) == 1 {
			close(entered)
			<-release
		}
	}

	c.request("test", run)
	<-entered
	for range 100 {
		c.request("test", run)
	}
	close(release)
	deadline := time.Now().Add(2 * time.Second)
	for c.running.Load() || c.pending.Load() {
		if time.Now().After(deadline) {
			t.Fatal("the coalesced run never finished")
		}
		time.Sleep(time.Millisecond)
	}
	if got := runs.Load(); got != 2 {
		t.Fatalf("a burst during one run took %d runs, want 2", got)
	}
}

func TestEngineProbesStayOwnedUntilTheLastOneEnds(t *testing.T) {
	probes := nodeProbes{running: map[string]int{}}
	probes.begin("a")
	probes.begin("a")
	probes.end("a")
	if !probes.owns("a") {
		t.Fatal("a node still probed by the engine was released by the other probe")
	}
	probes.end("a")
	if probes.owns("a") || len(probes.running) != 0 {
		t.Fatal("a node kept its mark after every probe ended")
	}
}
