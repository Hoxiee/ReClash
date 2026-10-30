package core

import (
	"context"
	"os"
	"path/filepath"
	"slices"
	"strings"
	"testing"

	"github.com/metacubex/mihomo/adapter"
	"github.com/metacubex/mihomo/component/process"
	C "github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/tunnel"
	"github.com/metacubex/mihomo/tunnel/statistic"
)

const policyProfile = `
reclash-policy:
  version: 1
  global: {allow: [safe]}
proxies:
  - {name: allowed, reclash-id: safe, type: socks5, server: 127.0.0.1, port: 1080}
  - {name: denied, reclash-id: other, type: socks5, server: 127.0.0.2, port: 1080}
proxy-groups:
  - {name: safe-group, type: select, proxies: [allowed]}
  - {name: mixed-group, type: select, proxies: [allowed, denied]}
  - {name: GLOBAL, type: select, proxies: [allowed, denied, safe-group, mixed-group, DIRECT]}
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

func TestProviderPolicyStrictParsing(t *testing.T) {
	valid, err := parseProviderPolicy([]byte(policyProfile))
	if err != nil || !valid.Restricted || len(valid.Allowed) != 1 {
		t.Fatalf("valid policy = %+v, %v", valid, err)
	}
	legacy, err := parseProviderPolicy([]byte("proxies: []"))
	if err != nil || legacy.enforced() {
		t.Fatalf("legacy = %+v, %v", legacy, err)
	}
	for name, input := range map[string]string{
		"version":              strings.Replace(policyProfile, "version: 1", "version: 2", 1),
		"unknown field":        strings.Replace(policyProfile, "global: {allow: [safe]}", "global: {allow: [safe], fallback: direct}", 1),
		"unknown node":         strings.Replace(policyProfile, "allow: [safe]", "allow: [missing]", 1),
		"duplicate node":       strings.Replace(policyProfile, "reclash-id: other", "reclash-id: safe", 1),
		"duplicate permission": strings.Replace(policyProfile, "allow: [safe]", "allow: [safe, safe]", 1),
		"null":                 "reclash-policy: null",
		"missing allow":        "reclash-policy: {version: 1, global: {}}",
		"bad package":          "reclash-policy: {version: 1, apps: {android: {exclude: ['*']}}}",
		"unsupported platform": "reclash-policy: {version: 1, apps: {linux: {exclude: []}}}",
	} {
		t.Run(name, func(t *testing.T) {
			if _, err := parseProviderPolicy([]byte(input)); err == nil {
				t.Fatal("invalid policy was ignored")
			}
		})
	}
}

func TestProviderGlobalGuardBindsDefinitionsNotLabels(t *testing.T) {
	policy, err := parseProviderPolicy([]byte(policyProfile))
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
	alias, err := adapter.ParseProxy(map[string]any{"name": "renamed", "reclash-id": "changed", "type": "socks5", "server": "127.0.0.1", "port": 1080})
	if err != nil {
		t.Fatal(err)
	}
	if err := providerPolicyDial(alias.(*adapter.Proxy), metadata); err != nil {
		t.Fatalf("rename lost original permission: %v", err)
	}
	spoof, err := adapter.ParseProxy(map[string]any{"name": "allowed", "reclash-id": "safe", "type": "socks5", "server": "127.0.0.3", "port": 1080})
	if err != nil {
		t.Fatal(err)
	}
	if err := providerPolicyDial(spoof.(*adapter.Proxy), metadata); err == nil {
		t.Fatal("copied node ID granted a different server")
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
	policy, err := parseProviderPolicy([]byte(policyProfile))
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
	noGlobal := false
	policy, err := loadProviderPolicy(&SetupParams{PolicyPath: &source, NoGlobal: &noGlobal})
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
	source := writeBaseProfile(t, "reclash-policy: {version: 1, apps: {android: {exclude: [com.example.bank]}}}\nproxies: []\n")
	previous := providerPolicyAndroid
	providerPolicyAndroid = true
	t.Cleanup(func() { providerPolicyAndroid = previous })
	vpn := true
	if _, err := loadProviderPolicy(&SetupParams{PolicyPath: &source, VPNEnabled: &vpn}); err == nil {
		t.Fatal("missing native exclusions accepted")
	}
	params := &SetupParams{PolicyPath: &source, VPNEnabled: &vpn, ExcludedApps: []string{"com.example.bank"}}
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
	providerPolicyAndroid = false
	if _, err := loadProviderPolicy(params); err == nil {
		t.Fatal("unsupported platform pretended to enforce app exclusions")
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
	source := strings.Replace(policyProfile, "reclash-id: safe,", "reclash-id: safe, dialer-proxy: denied,", 1)
	policy, err := parseProviderPolicy([]byte(source))
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
	all, err := parseProviderPolicy([]byte(strings.Replace(source, "allow: [safe]", "allow: [safe, other]", 1)))
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
	policy, err := parseProviderPolicy(data)
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
