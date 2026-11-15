package core

import (
	"encoding/json"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"reflect"
	"slices"
	"strings"
	"testing"
	"time"

	"github.com/metacubex/mihomo/adapter/provider"
	"github.com/metacubex/mihomo/config"
	"github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/tunnel"
	"go.yaml.in/yaml/v3"
)

const chainProfile = `proxies:
  - {name: entry, type: vless, server: 10.0.0.1, port: 443, uuid: 2a70e3a9-b4ce-4f20-908d-e99950a0a611, udp: true}
  - {name: hk1, type: ss, server: 10.0.1.1, port: 8388, cipher: aes-128-gcm, password: p, udp: true}
  - {name: hk2, type: ss, server: 10.0.1.2, port: 8388, cipher: aes-128-gcm, password: p}
  - {name: hy, type: hysteria2, server: 10.0.2.1, port: 443, password: p}
  - {name: web, type: http, server: 10.0.3.1, port: 8080}
  - {name: relayed, type: ss, server: 10.0.1.3, port: 8388, cipher: aes-128-gcm, password: p, dialer-proxy: hk2}
  - {name: out, type: direct}
proxy-groups:
  - {name: main, type: select, proxies: [entry, hk1, auto]}
  - {name: auto, type: url-test, url: "https://cp.test/204", interval: 300, tolerance: 50, proxies: [hk1, nested]}
  - {name: nested, type: select, proxies: [hk2, DIRECT]}
  - {name: wrap, type: select, proxies: [main]}
  - {name: empty, type: select, proxies: [DIRECT]}
rules:
  - MATCH,main
`

const chainProviderProfile = `proxies:
  - {name: entry, type: vless, server: 10.0.0.1, port: 443, uuid: 2a70e3a9-b4ce-4f20-908d-e99950a0a611, udp: true}
  - {name: hk1, type: ss, server: 10.0.1.1, port: 8388, cipher: aes-128-gcm, password: p, udp: true}
proxy-providers:
  sub:
    type: http
    url: https://sub.test/list
    interval: 3600
    exclude-filter: expired
    health-check: {enable: true, url: "https://cp.test/204", interval: 300}
  local:
    type: file
    path: ./local.yaml
proxy-groups:
  - {name: main, type: select, include-all: true, filter: "hk|HK"}
  - {name: hk, type: url-test, use: [sub], filter: HK, url: "https://cp.test/204"}
  - {name: both, type: select, proxies: [hk1], use: [sub, local], exclude-type: http}
rules:
  - MATCH,main
`

func useChainHome(t *testing.T) string {
	t.Helper()
	home := t.TempDir()
	previous := constant.Path.HomeDir()
	constant.SetHomeDir(home)
	t.Cleanup(func() { constant.SetHomeDir(previous) })
	return home
}

func chainSpec(name string, hops ...string) ChainSpec {
	return ChainSpec{ID: 1, Name: name, Hops: hops, Offered: true}
}

type materialized struct {
	reports   []ChainReport
	proxies   map[string]map[string]any
	groups    map[string]map[string]any
	providers map[string]map[string]any
	cfg       *config.Config
}

// Every materialized document goes through mihomo's own parse.
func materializeTest(t *testing.T, profile, hint string, served map[string][]chainLeaf, chains ...ChainSpec) materialized {
	t.Helper()
	useChainHome(t)
	return materializeInHome(t, profile, hint, served, chains...)
}

func materializeInHome(t *testing.T, profile, hint string, served map[string][]chainLeaf, chains ...ChainSpec) materialized {
	t.Helper()
	var document yaml.Node
	if err := yaml.Unmarshal([]byte(profile), &document); err != nil {
		t.Fatalf("unmarshal profile: %v", err)
	}
	root, err := documentMapping(&document)
	if err != nil {
		t.Fatalf("documentMapping = %v", err)
	}
	reports, _ := materializeChainsWith(root, chains, hint, served)
	out, err := yaml.Marshal(&document)
	if err != nil {
		t.Fatalf("marshal materialized: %v", err)
	}
	raw, err := config.UnmarshalRawConfig(out)
	if err != nil {
		t.Fatalf("unmarshal materialized: %v\n%s", err, out)
	}
	cfg, err := parseRawConfig(raw)
	if err != nil {
		t.Fatalf("parse materialized: %v\n%s", err, out)
	}
	result := materialized{
		reports:   reports,
		proxies:   map[string]map[string]any{},
		groups:    map[string]map[string]any{},
		providers: raw.ProxyProvider,
		cfg:       cfg,
	}
	for _, proxy := range raw.Proxy {
		result.proxies[proxy["name"].(string)] = proxy
	}
	for _, group := range raw.ProxyGroup {
		result.groups[group["name"].(string)] = group
	}
	return result
}

func stringList(value any) []string {
	var names []string
	items, _ := value.([]any)
	for _, item := range items {
		names = append(names, fmt.Sprint(item))
	}
	return names
}

func issueCodes(issues []ChainIssue) []string {
	codes := []string{}
	for _, issue := range issues {
		codes = append(codes, fmt.Sprintf("%d:%s", issue.Hop, issue.Code))
	}
	return codes
}

func TestMaterializeChainsReportsEachIssue(t *testing.T) {
	automatic := "auto"
	missing := "nope"
	notOffered := chainSpec("c", "wrap", "hk2")
	notOffered.Offered = false
	withTarget := func(spec ChainSpec, target *string) ChainSpec {
		spec.TargetGroup = target
		return spec
	}
	tests := []struct {
		name   string
		spec   ChainSpec
		status string
		codes  []string
	}{
		{"node exit", chainSpec("c", "entry", "hk1"), chainStatusOK, []string{}},
		{"group exit", chainSpec("c", "entry", "auto"), chainStatusOK, []string{}},
		{"missing hop", chainSpec("c", "entry", "gone"), chainStatusBroken, []string{"1:missingHop"}},
		{"builtin entry", chainSpec("c", "DIRECT", "hk1"), chainStatusBroken, []string{"0:unchainableHop"}},
		{"direct exit", chainSpec("c", "entry", "out"), chainStatusBroken, []string{"1:unchainableHop"}},
		{"empty exit", chainSpec("c", "entry", "empty"), chainStatusBroken, []string{"1:emptyExit"}},
		{"no exit", chainSpec("c", "entry"), chainStatusBroken, []string{"-1:emptyExit"}},
		{"entry is the target", chainSpec("c", "main", "hk2"), chainStatusBroken, []string{"0:loop"}},
		{"entry holds the target", chainSpec("c", "wrap", "hk2"), chainStatusBroken, []string{"0:loop"}},
		{"middle holds the target", chainSpec("c", "entry", "wrap", "hk2"), chainStatusBroken, []string{"1:loop"}},
		{"no loop when not offered", notOffered, chainStatusOK, []string{}},
		{"name of a proxy", chainSpec("hk1", "entry", "hk2"), chainStatusBroken, []string{"-1:nameClash"}},
		{"name of a group", chainSpec("auto", "entry", "hk2"), chainStatusBroken, []string{"-1:nameClash"}},
		{"UDP transport", chainSpec("c", "web", "hy"), chainStatusBroken, []string{"1:udpTransportMissing"}},
		{"UDP lost", chainSpec("c", "web", "hk1"), chainStatusDegraded, []string{"1:udpLost"}},
		{"dialer replaced", chainSpec("c", "entry", "relayed"), chainStatusDegraded, []string{"1:dialerReplaced"}},
		{"missing target", withTarget(chainSpec("c", "entry", "hk1"), &missing), chainStatusDegraded, []string{"-1:missingTarget"}},
		{"automatic target", withTarget(chainSpec("c", "entry", "hk1"), &automatic), chainStatusDegraded, []string{"-1:mainGroupAutomatic"}},
	}
	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			result := materializeTest(t, chainProfile, "", nil, test.spec)

			report := result.reports[0]
			if report.Status != test.status || !reflect.DeepEqual(issueCodes(report.Issues), test.codes) {
				t.Errorf("report = %s %v, want %s %v", report.Status, issueCodes(report.Issues), test.status, test.codes)
			}
		})
	}
}

func TestMaterializeChainsClonesANodeExitAndOffersItLast(t *testing.T) {
	result := materializeTest(t, chainProfile, "", nil, chainSpec("c", "entry", "hk1"))

	clone := result.proxies["c ⟶ hk1"]
	if clone == nil || clone["dialer-proxy"] != "entry" || clone["server"] != "10.0.1.1" {
		t.Fatalf("clone = %v, want hk1 dialing through entry", clone)
	}
	group := result.groups["c"]
	if group["type"] != "select" || group["hidden"] != true || !reflect.DeepEqual(stringList(group["proxies"]), []string{"c ⟶ hk1"}) {
		t.Errorf("chain group = %v", group)
	}
	if got := stringList(result.groups["main"]["proxies"]); !reflect.DeepEqual(got, []string{"entry", "hk1", "auto", "c"}) {
		t.Errorf("main = %v, want the chain after the static members", got)
	}
	report := result.reports[0]
	if report.Target == nil || *report.Target != "main" || report.UDP != chainUDPCarried {
		t.Errorf("report = %+v", report)
	}
	if want := (ChainMember{Leaf: "hk1", Server: "10.0.1.1", Port: 8388}); report.Members["c ⟶ hk1"] != want {
		t.Errorf("members = %v", report.Members)
	}
	if result.cfg.Proxies["c"] == nil {
		t.Error("the chain group is not in the parsed config")
	}
}

func TestMaterializeChainsExpandsNestedGroupsAndKeepsTheExitType(t *testing.T) {
	result := materializeTest(t, chainProfile, "", nil, chainSpec("c", "entry", "auto"))

	group := result.groups["c"]
	if got := stringList(group["proxies"]); !reflect.DeepEqual(got, []string{"c ⟶ hk1", "c ⟶ hk2"}) {
		t.Errorf("members = %v, want both leaves and no DIRECT", got)
	}
	if group["type"] != "url-test" || group["url"] != "https://cp.test/204" || group["tolerance"] != 50 {
		t.Errorf("chain group = %v, want the exit's url-test settings", group)
	}
}

func TestMaterializeChainsBuildsAMiddleHop(t *testing.T) {
	result := materializeTest(t, chainProfile, "", nil, chainSpec("c", "entry", "hk2", "hk1"))

	middle := result.groups["c ⟶ hk2"]
	if middle == nil || middle["hidden"] != true {
		t.Fatalf("middle group = %v", middle)
	}
	members := stringList(middle["proxies"])
	if len(members) != 1 || result.proxies[members[0]]["dialer-proxy"] != "entry" {
		t.Errorf("middle members = %v, want one clone dialing entry", members)
	}
	if exit := result.proxies["c ⟶ hk1"]; exit["dialer-proxy"] != "c ⟶ hk2" {
		t.Errorf("exit clone = %v, want it dialing the middle group", exit)
	}
	if _, listed := result.reports[0].Members[members[0]]; listed {
		t.Error("members lists a middle clone")
	}
	if hidden := result.reports[0].Hidden; !reflect.DeepEqual(hidden, []string{"c ⟶ hk2", members[0]}) {
		t.Errorf("hidden = %v, want the middle group and its clone", hidden)
	}
}

func TestMaterializeChainsLeavesABrokenStubWhereTheChainWasOffered(t *testing.T) {
	spec := chainSpec("c", "entry", "gone")
	spec.Fingerprints = []*ChainFingerprint{nil, {Type: "ss", Server: "10.0.1.1", Port: 8388}}

	result := materializeTest(t, chainProfile, "", nil, spec)

	stub := result.groups["c"]
	if stub["type"] != "select" || !reflect.DeepEqual(stringList(stub["proxies"]), []string{"REJECT"}) {
		t.Errorf("stub = %v, want a select group of REJECT", stub)
	}
	if !slices.Contains(stringList(result.groups["main"]["proxies"]), "c") {
		t.Error("the broken chain left the main group")
	}
	issue := result.reports[0].Issues[0]
	if issue.Fingerprint == nil || !reflect.DeepEqual(issue.Suggest, []string{"hk1"}) {
		t.Errorf("issue = %+v, want the fingerprint and hk1 suggested", issue)
	}
}

func TestMaterializeChainsSkipsAClashingName(t *testing.T) {
	result := materializeTest(t, chainProfile, "", nil, chainSpec("c", "entry", "hk1"), chainSpec("c", "entry", "hk2"))

	if result.reports[0].Status != chainStatusOK || result.reports[1].Status != chainStatusBroken {
		t.Fatalf("reports = %+v", result.reports)
	}
	if got := stringList(result.groups["main"]["proxies"]); slices.Index(got, "c") != len(got)-1 || len(got) != 4 {
		t.Errorf("main = %v, want the first chain once", got)
	}
	if _, cloned := result.proxies["c ⟶ hk2"]; cloned {
		t.Error("the clashing chain was built")
	}
}

func TestMaterializeChainsResolvesTheMainGroup(t *testing.T) {
	profile := func(groups string) string {
		return "proxies:\n" +
			"  - {name: a, type: ss, server: 10.0.0.1, port: 1, cipher: aes-128-gcm, password: p}\n" +
			"  - {name: b, type: ss, server: 10.0.0.2, port: 1, cipher: aes-128-gcm, password: p}\n" +
			"proxy-groups:\n" + groups
	}
	tests := []struct {
		name, groups, hint, target string
		codes                      []string
		suggest                    []string
	}{
		{"select", "  - {name: s, type: select, proxies: [a, b]}\n", "", "s", []string{}, nil},
		{"url-test", "  - {name: u, type: url-test, proxies: [a, b]}\n  - {name: s, type: select, proxies: [u]}\n", "", "", []string{"-1:mainGroupAutomatic"}, []string{"s"}},
		{"fallback", "  - {name: f, type: fallback, proxies: [a, b]}\n", "", "", []string{"-1:mainGroupAutomatic"}, nil},
		{"load-balance", "  - {name: l, type: load-balance, proxies: [a, b]}\n  - {name: s, type: select, proxies: [l]}\n", "", "", []string{"-1:mainGroupAutomatic"}, []string{"s"}},
		{"hint", "  - {name: s, type: select, proxies: [a, b]}\n  - {name: Servers, type: select, proxies: [a, b]}\n", "servers", "Servers", []string{}, nil},
		{"hidden first", "  - {name: h, type: select, hidden: true, proxies: [a, b]}\n  - {name: s, type: select, proxies: [h]}\n", "", "s", []string{}, nil},
		{"no group", "", "", "", []string{"-1:missingTarget"}, nil},
	}
	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			result := materializeTest(t, profile(test.groups), test.hint, nil, chainSpec("c", "a", "b"))

			report := result.reports[0]
			target := ""
			if report.Target != nil {
				target = *report.Target
			}
			if target != test.target || !reflect.DeepEqual(issueCodes(report.Issues), test.codes) {
				t.Fatalf("target = %q issues = %v, want %q %v", target, issueCodes(report.Issues), test.target, test.codes)
			}
			if len(report.Issues) > 0 && !reflect.DeepEqual(report.Issues[0].Suggest, test.suggest) {
				t.Errorf("suggest = %v, want %v", report.Issues[0].Suggest, test.suggest)
			}
		})
	}
}

func TestMaterializeChainsReportsUDP(t *testing.T) {
	tests := []struct {
		entry, exit, udp string
		codes            []string
		cloneUDP         any
	}{
		{"entry", "hk1", chainUDPCarried, []string{}, true},
		{"entry", "hk2", chainUDPNone, []string{}, nil},
		{"entry", "hy", chainUDPCarried, []string{}, nil},
		{"web", "hk1", chainUDPLostState, []string{"1:udpLost"}, false},
		{"web", "hy", chainUDPNone, []string{"1:udpTransportMissing"}, nil},
		{"hk2", "web", chainUDPNone, []string{}, nil},
	}
	for _, test := range tests {
		t.Run(test.entry+"-"+test.exit, func(t *testing.T) {
			result := materializeTest(t, chainProfile, "", nil, chainSpec("c", test.entry, test.exit))

			report := result.reports[0]
			if report.UDP != test.udp && report.Status != chainStatusBroken || !reflect.DeepEqual(issueCodes(report.Issues), test.codes) {
				t.Fatalf("udp = %s issues = %v, want %s %v", report.UDP, issueCodes(report.Issues), test.udp, test.codes)
			}
			if clone := result.proxies["c ⟶ "+test.exit]; clone != nil && clone["udp"] != test.cloneUDP {
				t.Errorf("clone udp = %v, want %v", clone["udp"], test.cloneUDP)
			}
		})
	}
}

func TestMaterializeChainsKeepsTheChainsDialerOverTheLeafsOwn(t *testing.T) {
	result := materializeTest(t, chainProfile, "", nil, chainSpec("c", "entry", "relayed"))

	if clone := result.proxies["c ⟶ relayed"]; clone["dialer-proxy"] != "entry" {
		t.Errorf("clone = %v, want the chain's entry as its dialer", clone)
	}
	if result.proxies["relayed"]["dialer-proxy"] != "hk2" {
		t.Error("the original leaf lost its own dialer")
	}
}

func TestMaterializeChainsGivesAProviderExitASiblingProvider(t *testing.T) {
	result := materializeTest(t, chainProviderProfile, "", nil, chainSpec("c", "entry", "hk"))

	sibling := result.providers["c/sub"]
	wantPath := constant.Path.GetPathByHash("proxies", "https://sub.test/list")
	if sibling["type"] != "file" || sibling["path"] != wantPath || sibling["dialer-proxy"] != "entry" {
		t.Fatalf("sibling = %v, want the parent's file dialing entry", sibling)
	}
	if _, polled := sibling["interval"]; polled || sibling["exclude-filter"] != "expired" || sibling["health-check"] == nil {
		t.Errorf("sibling = %v, want the parent's own options without its interval", sibling)
	}
	group := result.groups["c"]
	if !reflect.DeepEqual(stringList(group["use"]), []string{"c/sub"}) || group["filter"] != "HK" || group["type"] != "url-test" {
		t.Errorf("chain group = %v, want the sibling under the exit's filter", group)
	}
}

func TestMaterializeChainsMovesExcludesOntoSiblingsBesideClones(t *testing.T) {
	result := materializeTest(t, chainProviderProfile, "", nil, chainSpec("c", "entry", "both"))

	group := result.groups["c"]
	if !reflect.DeepEqual(stringList(group["use"]), []string{"c/sub", "c/local"}) || group["exclude-type"] != nil {
		t.Fatalf("chain group = %v", group)
	}
	if got := result.providers["c/local"]; got["exclude-type"] != "http" || got["path"] != "./local.yaml" {
		t.Errorf("local sibling = %v", got)
	}
	if got := result.providers["c/sub"]; got["exclude-filter"] != "expired" || got["exclude-type"] != "http" {
		t.Errorf("sub sibling = %v", got)
	}
}

func TestMaterializeChainsFreezesIncludeAllGroups(t *testing.T) {
	result := materializeTest(t, chainProviderProfile, "", nil, chainSpec("c", "entry", "hk1"), chainSpec("d", "entry", "hk"))

	main := result.groups["main"]
	if got := stringList(main["proxies"]); !reflect.DeepEqual(got, []string{"hk1", "c", "d"}) {
		t.Errorf("main proxies = %v, want the filtered inline nodes and the chains", got)
	}
	if got := stringList(main["use"]); !reflect.DeepEqual(got, []string{"local", "sub"}) {
		t.Errorf("main use = %v, want the original providers only", got)
	}
	if main["include-all"] != false {
		t.Errorf("main = %v, want include-all switched off", main)
	}
}

func TestMaterializeChainsChainsAProviderServedNode(t *testing.T) {
	served := map[string][]chainLeaf{"sub": {{name: "JP 1", kind: "vless", udp: true}}}

	result := materializeTest(t, chainProviderProfile, "", served, chainSpec("c", "entry", "JP 1"))

	if result.reports[0].Status != chainStatusOK {
		t.Fatalf("report = %+v", result.reports[0])
	}
	group := result.groups["c"]
	if !reflect.DeepEqual(stringList(group["use"]), []string{"c/sub"}) || group["filter"] != `^JP\ 1$` {
		t.Errorf("chain group = %v, want the sibling narrowed to the node", group)
	}
}

func TestMaterializeChainsWithoutChainsLeavesTheDocumentAlone(t *testing.T) {
	var document yaml.Node
	if err := yaml.Unmarshal([]byte(chainProviderProfile), &document); err != nil {
		t.Fatal(err)
	}
	before, _ := yaml.Marshal(&document)

	reports := materializeChains(document.Content[0], nil, "")

	after, _ := yaml.Marshal(&document)
	if len(reports) != 0 || string(before) != string(after) {
		t.Errorf("reports = %v, document changed = %v", reports, string(before) != string(after))
	}
}

func TestLoadSetupConfigMaterializesChainsIntoThePlainConfig(t *testing.T) {
	home := useChainHome(t)
	configPath := filepath.Join(home, "config.yaml")
	if err := os.WriteFile(configPath, []byte(chainProfile), 0o600); err != nil {
		t.Fatal(err)
	}
	params := defaultSetupParams()
	params.Chains = []ChainSpec{chainSpec("c", "entry", "hk1")}

	load, err := loadSetupConfig(params)

	if err != nil || load.cfg.Proxies["c"] == nil {
		t.Fatalf("loadSetupConfig = %v, chain group = %v", err, load.cfg.Proxies["c"])
	}
	written, _ := os.ReadFile(configPath)
	if !strings.Contains(string(written), "c ⟶ hk1") {
		t.Error("config.yaml does not carry the chain")
	}
	if reports := handleGetChainReport(); len(reports) != 1 || reports[0].Status != chainStatusOK {
		t.Errorf("getChainReport = %+v", reports)
	}

	inspection, err := handleInspectChain(InspectChainParams{Hops: []string{"entry", "hk1"}})
	if err != nil || len(inspection.Issues) != 0 || !reflect.DeepEqual(inspection.Leaves, []string{"hk1"}) {
		t.Errorf("inspectChain = %+v, %v, want the generated names ignored", inspection, err)
	}

	if err := os.WriteFile(configPath, []byte(chainProfile), 0o600); err != nil {
		t.Fatal(err)
	}
	if _, err := loadSetupConfig(defaultSetupParams()); err != nil {
		t.Fatalf("loadSetupConfig without chains = %v", err)
	}
	if written, _ := os.ReadFile(configPath); string(written) != chainProfile {
		t.Error("an apply without chains rewrote config.yaml")
	}
	if reports := handleGetChainReport(); reports == nil || len(reports) != 0 {
		t.Errorf("getChainReport = %v, want an empty list", reports)
	}
}

func TestLoadSetupConfigMaterializesChainsIntoABase(t *testing.T) {
	useChainHome(t)
	path := writeBaseProfile(t, baseProfile)
	base, err := handleGetProfileBase(path)
	if err != nil {
		t.Fatal(err)
	}
	params := defaultSetupParams()
	params.Base = &SetupBase{Path: path, Overlay: overlayOf(t, base, nil, nil)}
	params.Chains = []ChainSpec{chainSpec("c", "a", "b")}

	load, err := loadSetupConfig(params)

	if err != nil || load.cfg.Proxies["c"] == nil || load.cfg.Proxies["c ⟶ b"] == nil {
		t.Fatalf("loadSetupConfig = %v", err)
	}
	recordChains(nil, nil)
}

func TestInspectChainBlocksTheCandidatesThatBreakTheSlot(t *testing.T) {
	ix := func() *chainIndex {
		var document yaml.Node
		if err := yaml.Unmarshal([]byte(chainProfile), &document); err != nil {
			t.Fatal(err)
		}
		return newChainIndex(document.Content[0], nil, nil)
	}
	slot := 0

	entry := ix().inspect(InspectChainParams{Hops: []string{"entry", "hy"}, Slot: &slot})

	want := map[string]string{
		"main": chainLoop, "wrap": chainLoop, "web": chainUDPTransportMissing, "hk2": chainUDPTransportMissing,
		"relayed": chainUDPTransportMissing, "auto": chainUDPTransportMissing, "nested": chainUDPTransportMissing,
		"out": chainUnchainableHop,
	}
	for _, name := range chainBuiltins {
		want[name] = chainUnchainableHop
	}
	if !reflect.DeepEqual(entry.Blocked, want) {
		t.Errorf("blocked = %v, want %v", entry.Blocked, want)
	}
	if !reflect.DeepEqual(entry.UDP, []bool{true, true}) || !reflect.DeepEqual(entry.Leaves, []string{"hy"}) {
		t.Errorf("inspection = %+v", entry)
	}

	first := ix().inspect(InspectChainParams{Hops: []string{}, Slot: &slot})
	if first.Blocked["main"] != chainLoop || first.Blocked["wrap"] != chainLoop {
		t.Errorf("an entry picked first is not checked for a loop: %v", first.Blocked)
	}

	slot = 1
	exit := ix().inspect(InspectChainParams{Hops: []string{"web", "hk1"}, Slot: &slot})

	for _, name := range []string{"hy", "empty", "out"} {
		if exit.Blocked[name] == "" {
			t.Errorf("exit candidate %s is not blocked: %v", name, exit.Blocked)
		}
	}
	if _, blocked := exit.Blocked["hk2"]; blocked {
		t.Error("an exit that only loses UDP is blocked")
	}
}

func TestChainReportWireNames(t *testing.T) {
	target := "main"
	data, err := json.Marshal(ChainReport{
		ID: 1, Group: "c", Status: chainStatusOK, Issues: []ChainIssue{{Hop: -1, Code: chainMissingTarget}},
		Members: map[string]ChainMember{"c ⟶ a": {Leaf: "a", Server: "s", Port: 1}}, UDP: chainUDPNone, Target: &target,
	})
	if err != nil {
		t.Fatal(err)
	}
	want := `{"id":1,"group":"c","status":"ok","issues":[{"hop":-1,"code":"missingTarget"}],` +
		`"members":{"c ⟶ a":{"leaf":"a","server":"s","port":1}},"udp":"none","target":"main"}`
	if string(data) != want {
		t.Errorf("json = %s\nwant %s", data, want)
	}
}

func waitForProxies(t *testing.T, count func() int, want int) {
	t.Helper()
	deadline := time.Now().Add(5 * time.Second)
	for count() != want {
		if time.Now().After(deadline) {
			t.Fatalf("provider serves %d nodes, want %d", count(), want)
		}
		time.Sleep(20 * time.Millisecond)
	}
}

func providerList(names ...string) []byte {
	var body strings.Builder
	body.WriteString("proxies:\n")
	for i, name := range names {
		fmt.Fprintf(&body, "  - {name: %s, type: ss, server: 10.0.9.%d, port: 1, cipher: aes-128-gcm, password: p}\n", name, i+1)
	}
	return []byte(body.String())
}

// The gate for sibling providers: a sibling of a provider that has not
// downloaded yet must not fail, and must follow both ways the parent's file
// is replaced (mihomo's safeWrite truncates in place, a host write renames).
func TestChainSiblingProviderFollowsTheParentsFile(t *testing.T) {
	home := useChainHome(t)
	dir := filepath.Join(home, "proxies")
	if err := os.MkdirAll(dir, 0o755); err != nil {
		t.Fatal(err)
	}
	parent := filepath.Join(dir, "parent")
	sibling, err := provider.ParseProxyProvider("c/sub", map[string]any{
		"type": "file", "path": parent, "dialer-proxy": "entry",
	}, tunnel.Tunnel)
	if err != nil {
		t.Fatalf("ParseProxyProvider = %v", err)
	}
	t.Cleanup(func() { _ = sibling.(io.Closer).Close() })
	count := func() int { return len(sibling.Proxies()) }

	if err := sibling.Initial(); err == nil {
		t.Fatal("Initial succeeded without the parent's file")
	}

	if err := os.WriteFile(parent, providerList("a", "b"), 0o644); err != nil {
		t.Fatal(err)
	}
	waitForProxies(t, count, 2)
	if dialer := sibling.Proxies()[0].ProxyInfo().DialerProxy; dialer != "entry" {
		t.Errorf("dialer-proxy = %q, want entry", dialer)
	}

	temporary := filepath.Join(dir, ".parent.tmp")
	if err := os.WriteFile(temporary, providerList("a", "b", "c"), 0o644); err != nil {
		t.Fatal(err)
	}
	if err := os.Rename(temporary, parent); err != nil {
		t.Fatal(err)
	}
	waitForProxies(t, count, 3)

	if err := os.WriteFile(parent, providerList("d"), 0o644); err != nil {
		t.Fatal(err)
	}
	waitForProxies(t, count, 1)
}

const coldStartProfile = `proxies:
  - {name: hk1, type: ss, server: 10.0.1.1, port: 8388, cipher: aes-128-gcm, password: p, udp: true}
proxy-providers:
  sub:
    type: http
    url: https://sub.test/cold
    exclude-filter: "^skip"
    override: {additional-prefix: "[S] "}
proxy-groups:
  - {name: main, type: select, proxies: [hk1], use: [sub]}
rules:
  - MATCH,main
`

func TestMaterializeChainsReadsAProviderFileOnColdStart(t *testing.T) {
	useChainHome(t)
	path := constant.Path.GetPathByHash("proxies", "https://sub.test/cold")
	if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(path, providerList("entry", "exit", "skip"), 0o644); err != nil {
		t.Fatal(err)
	}

	result := materializeInHome(t, coldStartProfile, "", nil, chainSpec("c", "[S] entry", "[S] exit"))

	if report := result.reports[0]; report.Status != chainStatusOK {
		t.Fatalf("report = %+v, want the nodes read from the provider's file", report)
	}
	wrapper := result.groups["c ⟶ [S] entry"]
	if wrapper == nil || !reflect.DeepEqual(stringList(wrapper["use"]), []string{"sub"}) {
		t.Fatalf("entry group = %v, want the provider narrowed to the entry", wrapper)
	}
	if got := result.providers["c/sub"]["dialer-proxy"]; got != "c ⟶ [S] entry" {
		t.Errorf("sibling dialer = %v, want the entry group", got)
	}
	if result.groups["c"]["filter"] != `^\[S\]\ exit$` {
		t.Errorf("chain group = %v", result.groups["c"])
	}
	excluded := materializeInHome(t, coldStartProfile, "", nil, chainSpec("d", "hk1", "[S] skip"))
	if codes := issueCodes(excluded.reports[0].Issues); !reflect.DeepEqual(codes, []string{"1:missingHop"}) {
		t.Errorf("issues = %v, want the provider's exclude-filter applied", codes)
	}
}

func TestMaterializeChainsWaitsForAProviderThatHasNotDownloaded(t *testing.T) {
	useChainHome(t)
	spec := chainSpec("c", "hk1", "[S] exit")

	result := materializeInHome(t, coldStartProfile, "", nil, spec)

	report := result.reports[0]
	if report.Status != chainStatusDegraded || !reflect.DeepEqual(issueCodes(report.Issues), []string{"1:providerPending"}) {
		t.Fatalf("report = %+v, want a pending chain rather than a broken one", report)
	}
	group := result.groups["c"]
	if group["type"] != "select" || !reflect.DeepEqual(stringList(group["use"]), []string{"c/sub"}) {
		t.Fatalf("chain group = %v, want the sibling instead of a REJECT stub", group)
	}
	path := constant.Path.GetPathByHash("proxies", "https://sub.test/cold")
	if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
		t.Fatal(err)
	}
	sibling, err := provider.ParseProxyProvider("c/sub", result.providers["c/sub"], tunnel.Tunnel)
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() { _ = sibling.(io.Closer).Close() })
	if err := sibling.Initial(); err == nil {
		t.Fatal("Initial succeeded without the provider's file")
	}

	if err := os.WriteFile(path, providerList("exit"), 0o644); err != nil {
		t.Fatal(err)
	}
	waitForProxies(t, func() int { return len(sibling.Proxies()) }, 1)
	if name := sibling.Proxies()[0].Name(); name != "[S] exit" {
		t.Errorf("sibling serves %q", name)
	}

	if again := materializeInHome(t, coldStartProfile, "", nil, spec); again.reports[0].Status != chainStatusOK {
		t.Errorf("report after the download = %+v", again.reports[0])
	}
}
