package core

import (
	"context"
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"slices"
	"strings"
	"testing"
	"time"

	"github.com/metacubex/mihomo/adapter"
	"github.com/metacubex/mihomo/component/process"
	C "github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/tunnel"
	"github.com/metacubex/mihomo/tunnel/statistic"
)

const policyProfile = `
proxies:
  - {name: allowed, type: socks5, server: 127.0.0.1, port: 1080}
  - {name: denied, type: socks5, server: 127.0.0.2, port: 1080}
proxy-groups:
  - {name: safe-group, type: select, proxies: [allowed]}
  - {name: mixed-group, type: select, proxies: [allowed, denied]}
  - {name: GLOBAL, type: select, proxies: [allowed, safe-group, DIRECT]}
rules: ['MATCH,GLOBAL']
`

func withProviderPolicy(t *testing.T, policy *providerPolicy, global bool) {
	t.Helper()
	previous, mode := activeProviderPolicy.Load(), providerGlobalMode.Load()
	activeProviderPolicy.Store(policy)
	providerGlobalMode.Store(global)
	t.Cleanup(func() {
		activeProviderPolicy.Store(previous)
		providerGlobalMode.Store(mode)
	})
}

func policyGlobal(t *testing.T, proxies, groups string) (*providerPolicy, error) {
	t.Helper()
	return parseProviderPolicy([]byte("proxies:\n"+proxies+"proxy-groups:\n"+groups), true, false)
}

const policyNodes = `  - {name: a, type: socks5, server: 127.0.0.1, port: 1080}
  - {name: b, type: socks5, server: 127.0.0.2, port: 1080}
  - {name: c, type: socks5, server: 127.0.0.3, port: 1080}
`

func TestProviderPolicyFollowsTheGlobalGroup(t *testing.T) {
	valid, err := parseProviderPolicy([]byte(policyProfile), true, false)
	if err != nil || !valid.Restricted || len(valid.Allowed) != 1 || !valid.allowsGlobal() {
		t.Fatalf("valid policy = %+v, %v", valid, err)
	}
	plain, err := parseProviderPolicy([]byte(policyProfile), false, false)
	if err != nil || plain.enforced() {
		t.Fatalf("no lock = %+v, %v", plain, err)
	}
	cases := map[string]struct {
		groups string
		want   int
	}{
		"nested groups":              {"  - {name: GLOBAL, type: select, proxies: [inner]}\n  - {name: inner, type: select, proxies: [a, deeper]}\n  - {name: deeper, type: select, proxies: [b]}\n", 2},
		"cycle":                      {"  - {name: GLOBAL, type: select, proxies: [x, a]}\n  - {name: x, type: select, proxies: [GLOBAL, y]}\n  - {name: y, type: select, proxies: [x, b]}\n", 2},
		"remote and builtin members": {"  - {name: GLOBAL, type: select, proxies: [DIRECT, REJECT, provider-node, a]}\n", 1},
		"unlisted group member":      {"  - {name: GLOBAL, type: select, proxies: [a]}\n  - {name: other, type: select, proxies: [b, c]}\n", 1},
		"empty GLOBAL":               {"  - {name: GLOBAL, type: select, proxies: []}\n", 0},
		"only remote":                {"  - {name: GLOBAL, type: select, use: [sub], proxies: [DIRECT]}\n", 0},
		"absent GLOBAL":              {"  - {name: other, type: select, proxies: [a]}\n", 0},
		"duplicate members":          {"  - {name: GLOBAL, type: select, proxies: [a, a, g2]}\n  - {name: g2, type: select, proxies: [a]}\n", 1},
	}
	for name, c := range cases {
		t.Run(name, func(t *testing.T) {
			policy, err := policyGlobal(t, policyNodes, c.groups)
			if err != nil || !policy.Restricted || len(policy.Allowed) != c.want {
				t.Fatalf("policy = %+v, %v", policy, err)
			}
			if policy.allowsGlobal() != (c.want != 0) {
				t.Fatalf("allowsGlobal = %v with %d nodes", policy.allowsGlobal(), c.want)
			}
		})
	}
}

func TestProviderPolicyGlobalDepthIsCapped(t *testing.T) {
	groups := "  - {name: GLOBAL, type: select, proxies: [g1]}\n"
	for i := 1; i < 40; i++ {
		groups += fmt.Sprintf("  - {name: g%d, type: select, proxies: [g%d]}\n", i, i+1)
	}
	groups += "  - {name: g40, type: select, proxies: [a]}\n"
	policy, err := policyGlobal(t, policyNodes, groups)
	if err != nil || len(policy.Allowed) != 0 {
		t.Fatalf("a chain deeper than the cap granted %+v, %v", policy, err)
	}
}

func TestProviderPolicyAppsComeFromTunExcludePackage(t *testing.T) {
	policy, err := parseProviderPolicy([]byte("tun: {exclude-package: [com.example.bank, com.example.bank, com.example.pay]}\nproxies: []\n"), false, true)
	if err != nil || policy.Restricted || !slices.Equal(policy.Apps, []string{"com.example.bank", "com.example.pay"}) {
		t.Fatalf("policy = %+v, %v", policy, err)
	}
	if none, err := parseProviderPolicy([]byte("proxies: []"), false, true); err != nil || none.enforced() {
		t.Fatalf("no exclusions = %+v, %v", none, err)
	}
	if ignored, err := parseProviderPolicy([]byte("tun: {exclude-package: [com.example.bank]}"), false, false); err != nil || ignored.enforced() {
		t.Fatalf("exclusions without lockapps = %+v, %v", ignored, err)
	}
	if _, err := parseProviderPolicy([]byte("tun: {exclude-package: ['*']}"), false, true); err == nil {
		t.Fatal("invalid package accepted")
	}
}

func TestProviderGlobalGuardBindsDefinitionsNotLabels(t *testing.T) {
	policy, err := parseProviderPolicy([]byte(policyProfile), true, false)
	if err != nil {
		t.Fatal(err)
	}
	policy.Epoch = 11
	withProviderPolicy(t, policy, true)
	cfg, err := loadConfig(writeBaseProfile(t, policyProfile))
	if err != nil {
		t.Fatal(err)
	}
	metadata := &C.Metadata{Type: C.TUN, PolicyGlobal: true, PolicyGeneration: 11}
	allowed := cfg.Proxies["allowed"].(*adapter.Proxy)
	denied := cfg.Proxies["denied"].(*adapter.Proxy)
	if err := providerPolicyDial(allowed, metadata); err != nil {
		t.Fatal(err)
	}
	if err := providerPolicyDial(denied, metadata); err == nil {
		t.Fatal("denied node admitted")
	}
	alias, err := adapter.ParseProxy(map[string]any{"name": "renamed", "type": "socks5", "server": "127.0.0.1", "port": 1080})
	if err != nil {
		t.Fatal(err)
	}
	if err := providerPolicyDial(alias.(*adapter.Proxy), metadata); err != nil {
		t.Fatalf("rename lost original permission: %v", err)
	}
	spoof, err := adapter.ParseProxy(map[string]any{"name": "allowed", "type": "socks5", "server": "127.0.0.3", "port": 1080})
	if err != nil {
		t.Fatal(err)
	}
	if err := providerPolicyDial(spoof.(*adapter.Proxy), metadata); err == nil {
		t.Fatal("copied node name granted a different server")
	}
	for _, kind := range []C.Type{C.TUN, C.SOCKS5, C.INNER} {
		meta := &C.Metadata{Type: kind, PolicyGeneration: 11}
		ctx, cancel := context.WithCancel(context.Background())
		cancel()
		if _, err := denied.DialContext(ctx, meta); err == nil || !strings.Contains(err.Error(), "not allowed in GLOBAL") {
			t.Fatalf("TCP %v did not fail at policy: %v", kind, err)
		}
		if _, err := denied.ListenPacketContext(ctx, meta); err == nil || !strings.Contains(err.Error(), "not allowed in GLOBAL") {
			t.Fatalf("UDP %v did not fail at policy: %v", kind, err)
		}
	}
	providerGlobalMode.Store(false)
	if err := providerPolicyDial(denied, metadata); err == nil {
		t.Fatal("mode transition broadened an in-flight GLOBAL route")
	}
	if err := providerPolicyDial(denied, &C.Metadata{Type: C.TUN, PolicyGeneration: 11}); err != nil {
		t.Fatalf("rule traffic was unnecessarily restricted: %v", err)
	}
}

func TestProviderPolicyFiltersGlobalGroups(t *testing.T) {
	policy, err := parseProviderPolicy([]byte(policyProfile), true, false)
	if err != nil {
		t.Fatal(err)
	}
	withProviderPolicy(t, policy, true)
	cfg, err := loadConfig(writeBaseProfile(t, policyProfile))
	if err != nil {
		t.Fatal(err)
	}
	if !providerGlobalCandidate(cfg.Proxies["safe-group"]) {
		t.Fatal("allowed nested group was rejected")
	}
	if providerGlobalCandidate(cfg.Proxies["mixed-group"]) {
		t.Fatal("nested group admitted a denied fallback")
	}
	topology, _ := rcxTopologyOf(cfg.Proxies, []string{"GLOBAL"}, map[string]bool{"GLOBAL": true}, nil)
	var names []string
	for _, member := range topology.Groups[0].Members {
		names = append(names, member.Name)
	}
	slices.Sort(names)
	if !slices.Equal(names, []string{"allowed", "safe-group"}) {
		t.Fatalf("GLOBAL candidates = %v", names)
	}
}

func TestProviderPolicySurvivesReloadAndNativeStartup(t *testing.T) {
	home := t.TempDir()
	previous := C.Path.HomeDir()
	C.SetHomeDir(home)
	t.Cleanup(func() { C.SetHomeDir(previous) })
	withProviderPolicy(t, nil, false)
	source := filepath.Join(home, "subscription.yaml")
	if err := os.WriteFile(source, []byte(policyProfile), 0o600); err != nil {
		t.Fatal(err)
	}
	noGlobal, lockGlobal := false, true
	policy, err := loadProviderPolicy(&SetupParams{PolicyPath: &source, NoGlobal: &noGlobal, LockGlobal: &lockGlobal})
	if err != nil {
		t.Fatal(err)
	}
	if err := installProviderPolicy(policy); err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(runningConfigPath(), []byte("proxies: []"), 0o600); err != nil {
		t.Fatal(err)
	}
	activeProviderPolicy.Store(nil)
	restored, err := loadProviderPolicy(defaultSetupParams())
	if err != nil || !restored.Restricted || !slices.Equal(restored.Allowed, policy.Allowed) {
		t.Fatalf("restored = %+v, %v", restored, err)
	}
	empty := ""
	cleared, err := loadProviderPolicy(&SetupParams{PolicyPath: &empty, NoGlobal: &noGlobal})
	if err != nil || cleared.enforced() {
		t.Fatalf("explicit profile switch = %+v, %v", cleared, err)
	}
	if err := os.WriteFile(providerPolicyPath(), []byte("broken"), 0o600); err != nil {
		t.Fatal(err)
	}
	if _, err := loadProviderPolicy(defaultSetupParams()); err == nil {
		t.Fatal("corrupt authority was treated as an unrestricted profile")
	}
}

func TestProviderAppsRequireAppliedAndroidOptions(t *testing.T) {
	source := writeBaseProfile(t, "tun: {exclude-package: [com.example.bank]}\nproxies: []\n")
	lockApps := true
	previous := providerPolicyAndroid
	providerPolicyAndroid = true
	t.Cleanup(func() { providerPolicyAndroid = previous })
	vpn := true
	if _, err := loadProviderPolicy(&SetupParams{PolicyPath: &source, LockApps: &lockApps, VPNEnabled: &vpn}); err == nil {
		t.Fatal("missing native exclusions accepted")
	}
	params := &SetupParams{PolicyPath: &source, LockApps: &lockApps, VPNEnabled: &vpn, ExcludedApps: []string{"com.example.bank"}}
	policy, err := loadProviderPolicy(params)
	if err != nil {
		t.Fatal(err)
	}
	policy.Epoch = 7
	withProviderPolicy(t, policy, false)
	oldResolver := process.DefaultPackageNameResolver
	process.DefaultPackageNameResolver = func(*C.Metadata) (string, error) { return "com.example.bank", nil }
	t.Cleanup(func() { process.DefaultPackageNameResolver = oldResolver })
	if err := providerPolicyMetadata(&C.Metadata{Type: C.TUN}); err == nil {
		t.Fatal("newly installed required app reached the tunnel")
	}
	process.DefaultPackageNameResolver = func(*C.Metadata) (string, error) { return "", nil }
	if err := providerPolicyMetadata(&C.Metadata{Type: C.TUN}); err == nil {
		t.Fatal("unknown app was assumed safe")
	}
	if err := providerPolicyMetadata(&C.Metadata{Type: C.TUN, Process: "com.example.browser"}); err != nil {
		t.Fatal(err)
	}
	if err := providerPolicyMetadata(&C.Metadata{Type: C.SOCKS5, Process: "com.example.browser"}); err == nil {
		t.Fatal("local proxy bypassed native exclusions")
	}
	noVPN := false
	if _, err := loadProviderPolicy(&SetupParams{PolicyPath: &source, LockApps: &lockApps, VPNEnabled: &noVPN, ExcludedApps: params.ExcludedApps}); err == nil {
		t.Fatal("Android without VPN mode connected under required apps")
	}
	providerPolicyAndroid = false
	desktop, err := loadProviderPolicy(&SetupParams{PolicyPath: &source, LockApps: &lockApps, VPNEnabled: &noVPN})
	if err != nil || len(desktop.Apps) != 0 || desktop.enforced() {
		t.Fatalf("desktop enforced required apps: %+v, %v", desktop, err)
	}
}

func TestProviderModeChangeInvalidatesInFlightRoutes(t *testing.T) {
	withProviderPolicy(t, &providerPolicy{Version: 1, NoGlobal: true, Epoch: providerPolicyEpoch.Add(1)}, false)
	metadata := &C.Metadata{Type: C.TUN}
	if err := providerPolicyMetadata(metadata); err != nil {
		t.Fatal(err)
	}
	providerPolicyModeChanged(tunnel.Global)
	if activeProviderPolicy.Load().allowsGlobal() {
		t.Fatal("noglobal was weakened")
	}
	if err := checkProviderPolicyMetadata(activeProviderPolicy.Load(), metadata); err == nil {
		t.Fatal("in-flight route survived the mode change")
	}
}

func TestProviderPolicyChecksCachedDialerDependencies(t *testing.T) {
	source := strings.Replace(policyProfile, "name: allowed,", "name: allowed, dialer-proxy: denied,", 1)
	policy, err := parseProviderPolicy([]byte(source), true, false)
	if err != nil {
		t.Fatal(err)
	}
	cfg, err := loadConfig(writeBaseProfile(t, source))
	if err != nil {
		t.Fatal(err)
	}
	lookup := func(name string) C.Proxy { return cfg.Proxies[name] }
	if providerPolicyCandidate(policy, cfg.Proxies["allowed"], lookup) {
		t.Fatal("an allowed node admitted its unapproved cached dialer")
	}
	all, err := parseProviderPolicy([]byte(strings.Replace(source, "proxies: [allowed, safe-group, DIRECT]", "proxies: [allowed, denied, safe-group, DIRECT]", 1)), true, false)
	if err != nil {
		t.Fatal(err)
	}
	if !providerPolicyCandidate(all, cfg.Proxies["allowed"], lookup) {
		t.Fatal("fully permitted chain was rejected")
	}
}

func TestProviderPolicySurvivesProfileBaseExport(t *testing.T) {
	source := writeBaseProfile(t, policyProfile)
	base, err := handleGetProfileBase(source)
	if err != nil {
		t.Fatal(err)
	}
	output := filepath.Join(t.TempDir(), "config.yaml")
	if _, err := loadConfigWithBase(&SetupBase{Path: source, Overlay: overlayOf(t, base, nil, nil)}, output); err != nil {
		t.Fatal(err)
	}
	data, err := os.ReadFile(output)
	if err != nil {
		t.Fatal(err)
	}
	policy, err := parseProviderPolicy(data, true, false)
	if err != nil || !policy.Restricted || len(policy.Allowed) != 1 {
		t.Fatalf("export lost policy: %+v %v", policy, err)
	}
}

type policyTracker struct {
	C.Connection
	metadata *C.Metadata
	closed   bool
}

func (*policyTracker) ID() string { return "provider-policy-admission-test" }
func (c *policyTracker) Info() *statistic.TrackerInfo {
	return &statistic.TrackerInfo{Metadata: c.metadata}
}
func (c *policyTracker) Close() error {
	c.closed = true
	statistic.DefaultManager.Leave(c)
	return nil
}

func TestProviderPolicyAdmissionHasNoUnregisteredWindow(t *testing.T) {
	withProviderPolicy(t, &providerPolicy{Version: 1, NoGlobal: true, Epoch: providerPolicyEpoch.Add(1)}, false)
	metadata := &C.Metadata{Type: C.TUN}
	if err := providerPolicyMetadata(metadata); err != nil {
		t.Fatal(err)
	}
	conn := &policyTracker{metadata: metadata}
	oldAdmission := statistic.DefaultConnectionAdmission
	statistic.DefaultConnectionAdmission = func(c statistic.Tracker) bool {
		found := false
		statistic.DefaultManager.Range(func(stored statistic.Tracker) bool { found = found || stored.ID() == c.ID(); return true })
		if !found {
			t.Fatal("admission ran before connection registration")
		}
		providerPolicyModeChanged(tunnel.Global)
		return providerPolicyAdmit(c)
	}
	t.Cleanup(func() { statistic.DefaultConnectionAdmission = oldAdmission; statistic.DefaultManager.Leave(conn) })
	statistic.DefaultManager.Join(conn)
	if !conn.closed {
		t.Fatal("policy swap did not close the connection being admitted")
	}
	statistic.DefaultManager.Range(func(c statistic.Tracker) bool {
		if c.ID() == conn.ID() {
			t.Error("rejected connection was left in the registry")
		}
		return true
	})
}

const policyFilterNodes = `  - {name: DE LTE, type: socks5, server: 127.0.1.1, port: 1080}
  - {name: NL lte 2, type: socks5, server: 127.0.1.2, port: 1080}
  - {name: FR LTE Streaming, type: socks5, server: 127.0.1.3, port: 1080}
  - {name: Malte, type: socks5, server: 127.0.1.4, port: 1080}
  - {name: МегаLTE, type: socks5, server: 127.0.1.5, port: 1080}
  - {name: Wifi, type: ss, server: 127.0.1.6, port: 1080, cipher: aes-128-gcm, password: x}
`

func policyFingerprints(t *testing.T, proxies string, names []string) []string {
	t.Helper()
	raw, err := policyRawConfig([]byte("proxies:\n" + proxies))
	if err != nil {
		t.Fatal(err)
	}
	fingerprints := []string{}
	for _, node := range raw.Proxy {
		if slices.Contains(names, node["name"].(string)) {
			fingerprints = append(fingerprints, adapter.RouteFingerprintOf(node))
		}
	}
	if len(fingerprints) != len(names) {
		t.Fatalf("unknown node in %v", names)
	}
	slices.Sort(fingerprints)
	return fingerprints
}

func mihomoGlobalFingerprints(t *testing.T, source string) []string {
	t.Helper()
	cfg, err := loadConfig(writeBaseProfile(t, source))
	if err != nil {
		t.Fatal(err)
	}
	fingerprints := []string{}
	var walk func(proxy C.Proxy)
	walk = func(proxy C.Proxy) {
		if group, ok := adapterAs[interface{ Proxies() []C.Proxy }](proxy); ok {
			for _, member := range group.Proxies() {
				walk(member)
			}
			return
		}
		if node, ok := proxy.(*adapter.Proxy); ok && node.Type() >= C.Shadowsocks {
			fingerprints = append(fingerprints, node.RouteFingerprint())
		}
	}
	walk(cfg.Proxies["GLOBAL"])
	slices.Sort(fingerprints)
	return slices.Compact(fingerprints)
}

func TestProviderPolicyAllowlistEqualsMihomoGroups(t *testing.T) {
	const lte = `(?i)\bLTE\b`
	cases := map[string]struct {
		groups string
		want   []string
	}{
		"filter": {
			"  - {name: GLOBAL, type: select, include-all-proxies: true, filter: '" + lte + "'}\n",
			[]string{"DE LTE", "NL lte 2", "FR LTE Streaming"},
		},
		"substring filter also takes Malte": {
			"  - {name: GLOBAL, type: select, include-all-proxies: true, filter: '(?i)lte'}\n",
			[]string{"DE LTE", "NL lte 2", "FR LTE Streaming", "Malte", "МегаLTE"},
		},
		"backtick alternatives": {
			"  - {name: GLOBAL, type: select, include-all-proxies: true, filter: '^DE`^Wifi$'}\n",
			[]string{"DE LTE", "Wifi"},
		},
		"nested group with filter": {
			"  - {name: GLOBAL, type: select, proxies: [pool]}\n  - {name: pool, type: select, include-all-proxies: true, filter: '^NL'}\n",
			[]string{"NL lte 2"},
		},
		"include-all": {
			"  - {name: GLOBAL, type: select, include-all: true}\n",
			[]string{"DE LTE", "NL lte 2", "FR LTE Streaming", "Malte", "МегаLTE", "Wifi"},
		},
		"include-all with filter": {
			"  - {name: GLOBAL, type: select, include-all: true, filter: '^Wifi$'}\n",
			[]string{"Wifi"},
		},
		"explicit members bypass filter": {
			"  - {name: GLOBAL, type: select, proxies: [Wifi], include-all-proxies: true, filter: '^DE'}\n",
			[]string{"Wifi", "DE LTE"},
		},
		"filter without include-all narrows nothing": {
			"  - {name: GLOBAL, type: select, proxies: [Wifi, Malte], filter: '^DE'}\n",
			[]string{"Wifi", "Malte"},
		},
		"exclude-filter": {
			"  - {name: GLOBAL, type: select, include-all-proxies: true, filter: '" + lte + "', exclude-filter: Streaming}\n",
			[]string{"DE LTE", "NL lte 2"},
		},
		"exclude-filter on explicit members": {
			"  - {name: GLOBAL, type: select, proxies: [Wifi, Malte], exclude-filter: Malte}\n",
			[]string{"Wifi"},
		},
		"lookahead exclusion": {
			"  - {name: GLOBAL, type: select, include-all-proxies: true, filter: '^(?!.*Streaming).*\\bLTE\\b'}\n",
			[]string{"DE LTE"},
		},
		"exclude-type": {
			"  - {name: GLOBAL, type: select, include-all-proxies: true, exclude-type: Socks5}\n",
			[]string{"Wifi"},
		},
		"exclude-type drops a nested group": {
			"  - {name: GLOBAL, type: select, proxies: [Wifi, pool], exclude-type: Selector}\n  - {name: pool, type: select, proxies: [Malte]}\n",
			[]string{"Wifi"},
		},
		"no match": {
			"  - {name: GLOBAL, type: select, include-all-proxies: true, filter: nothing-at-all}\n",
			[]string{},
		},
		"empty-fallback node": {
			"  - {name: GLOBAL, type: select, include-all-proxies: true, filter: nothing-at-all, empty-fallback: Wifi}\n",
			[]string{"Wifi"},
		},
		"excluded down to empty-fallback": {
			"  - {name: GLOBAL, type: select, proxies: [Malte], exclude-filter: Malte, empty-fallback: Wifi}\n",
			[]string{"Wifi"},
		},
	}
	for name, test := range cases {
		t.Run(name, func(t *testing.T) {
			policy, err := policyGlobal(t, policyFilterNodes, test.groups)
			if err != nil {
				t.Fatal(err)
			}
			want := policyFingerprints(t, policyFilterNodes, test.want)
			if !slices.Equal(policy.Allowed, want) {
				t.Errorf("allowed %v, want %v", policy.Allowed, want)
			}
			source := "proxies:\n" + policyFilterNodes + "proxy-groups:\n" + test.groups
			if actual := mihomoGlobalFingerprints(t, source); !slices.Equal(policy.Allowed, actual) {
				t.Errorf("allowed %v, mihomo resolves %v", policy.Allowed, actual)
			}
			if policy.allowsGlobal() != (len(test.want) != 0) {
				t.Errorf("allowsGlobal = %v for %v", policy.allowsGlobal(), test.want)
			}
		})
	}
}

func TestProviderPolicyFilterFollowsTheRouteNotTheName(t *testing.T) {
	groups := "  - {name: GLOBAL, type: select, include-all-proxies: true, filter: '(?i)\\bLTE\\b'}\n"
	before, err := policyGlobal(t, policyFilterNodes, groups)
	if err != nil {
		t.Fatal(err)
	}
	renamed, err := policyGlobal(t, strings.Replace(policyFilterNodes, "name: DE LTE", "name: Germany LTE", 1), groups)
	if err != nil || !slices.Equal(before.Allowed, renamed.Allowed) {
		t.Fatalf("renamed within the filter: %v, %v", renamed.Allowed, err)
	}
	dropped, err := policyGlobal(t, strings.Replace(policyFilterNodes, "name: DE LTE", "name: Germany", 1), groups)
	if err != nil || len(dropped.Allowed) != len(before.Allowed)-1 {
		t.Fatalf("renamed out of the filter: %v, %v", dropped.Allowed, err)
	}
}

func TestProviderPolicyDeniesProviderNodesAFilterMatches(t *testing.T) {
	source := `
proxies:
  - {name: DE LTE, type: socks5, server: 127.0.1.1, port: 1080}
proxy-providers:
  remote:
    type: inline
    payload:
      - {name: Remote LTE, type: socks5, server: 127.0.2.1, port: 1080}
proxy-groups:
  - {name: GLOBAL, type: select, include-all: true, filter: LTE}
`
	policy, err := parseProviderPolicy([]byte(source), true, false)
	if err != nil {
		t.Fatal(err)
	}
	cfg, err := loadConfig(writeBaseProfile(t, source))
	if err != nil {
		t.Fatal(err)
	}
	if len(policy.Allowed) != 1 || !providerPolicyCandidate(policy, cfg.Proxies["DE LTE"], func(string) C.Proxy { return nil }) {
		t.Fatalf("inline node lost: %+v", policy)
	}
	members := []string{}
	group, _ := adapterAs[interface{ Proxies() []C.Proxy }](cfg.Proxies["GLOBAL"])
	for _, member := range group.Proxies() {
		members = append(members, member.Name())
		if member.Name() == "Remote LTE" && providerPolicyCandidate(policy, member, func(string) C.Proxy { return nil }) {
			t.Fatal("a provider node was allowed through the filter")
		}
	}
	if !slices.Contains(members, "Remote LTE") {
		t.Fatalf("mihomo did not list the provider node: %v", members)
	}
}

func TestProviderPolicyBadFilterFailsClosedWithoutPanic(t *testing.T) {
	for name, groups := range map[string]string{
		"filter":             "  - {name: GLOBAL, type: select, include-all-proxies: true, filter: '('}\n",
		"filter unused":      "  - {name: GLOBAL, type: select, proxies: [a], filter: '('}\n",
		"exclude-filter":     "  - {name: GLOBAL, type: select, proxies: [a], exclude-filter: '('}\n",
		"second alternative": "  - {name: GLOBAL, type: select, include-all-proxies: true, filter: 'a`('}\n",
		"nested":             "  - {name: GLOBAL, type: select, proxies: [pool]}\n  - {name: pool, type: select, include-all-proxies: true, filter: '('}\n",
		"too long":           "  - {name: GLOBAL, type: select, include-all-proxies: true, filter: '" + strings.Repeat("a", maxGroupFilterLength+1) + "'}\n",
	} {
		t.Run(name, func(t *testing.T) {
			if policy, err := policyGlobal(t, policyNodes, groups); err == nil {
				t.Fatalf("policy accepted the pattern: %+v", policy)
			}
			path := writeBaseProfile(t, "proxies:\n"+policyNodes+"proxy-groups:\n"+groups)
			if _, err := handleGetProviderGlobalNodes(path); err == nil {
				t.Fatal("the app was given a count for a bad pattern")
			}
			if err := handleValidateConfig(path); err == nil {
				t.Fatal("validation accepted the pattern")
			}
			if _, err := loadConfig(path); err == nil {
				t.Fatal("config load accepted the pattern")
			}
		})
	}
}

func TestBadFilterOutsideGlobalFailsTheLoadNotThePolicy(t *testing.T) {
	groups := "  - {name: GLOBAL, type: select, proxies: [a]}\n  - {name: other, type: select, proxies: [b], filter: '('}\n"
	if _, err := policyGlobal(t, policyNodes, groups); err != nil {
		t.Fatal(err)
	}
	if _, err := loadConfig(writeBaseProfile(t, "proxies:\n"+policyNodes+"proxy-groups:\n"+groups)); err == nil {
		t.Fatal("mihomo's panic was not turned into an error")
	}
}

func TestSlowFilterIsBoundedAndFailsClosed(t *testing.T) {
	nodes := ""
	for i := range 64 {
		nodes += fmt.Sprintf("  - {name: %s%d, type: socks5, server: 127.0.3.%d, port: 1080}\n", strings.Repeat("x", 64), i, i+1)
	}
	groups := "  - {name: GLOBAL, type: select, include-all-proxies: true, filter: '(x+x+)+y'}\n"
	started := time.Now()
	if policy, err := policyGlobal(t, nodes, groups); err == nil {
		t.Fatalf("policy accepted the slow pattern: %+v", policy)
	}
	if _, err := loadConfig(writeBaseProfile(t, "proxies:\n"+nodes+"proxy-groups:\n"+groups)); err == nil {
		t.Fatal("config load accepted the slow pattern")
	}
	if elapsed := time.Since(started); elapsed > 2*groupFilterBudget {
		t.Fatalf("slow pattern took %v", elapsed)
	}
}

func TestProviderGlobalNodesCountsRoutes(t *testing.T) {
	duplicate := policyNodes + "  - {name: a again, type: socks5, server: 127.0.0.1, port: 1080}\n"
	for name, test := range map[string]struct {
		proxies, groups string
		want            providerGlobalNodes
	}{
		"filter":      {policyNodes, "  - {name: GLOBAL, type: select, include-all-proxies: true, filter: '^a$'}\n", providerGlobalNodes{1, 3}},
		"everything":  {policyNodes, "  - {name: GLOBAL, type: select, include-all-proxies: true}\n", providerGlobalNodes{3, 3}},
		"no match":    {policyNodes, "  - {name: GLOBAL, type: select, include-all-proxies: true, filter: z}\n", providerGlobalNodes{0, 3}},
		"no GLOBAL":   {policyNodes, "  - {name: Proxy, type: select, proxies: [a]}\n", providerGlobalNodes{0, 3}},
		"same server": {duplicate, "  - {name: GLOBAL, type: select, proxies: [a, b, c]}\n", providerGlobalNodes{3, 3}},
	} {
		t.Run(name, func(t *testing.T) {
			got, err := handleGetProviderGlobalNodes(writeBaseProfile(t, "proxies:\n"+test.proxies+"proxy-groups:\n"+test.groups))
			if err != nil || got != test.want {
				t.Fatalf("got %+v, %v; want %+v", got, err, test.want)
			}
		})
	}
	wire, err := json.Marshal(providerGlobalNodes{Allowed: 1, Inline: 3})
	if err != nil || string(wire) != `{"allowed":1,"inline":3}` {
		t.Fatalf("wire form %s, %v", wire, err)
	}
}
