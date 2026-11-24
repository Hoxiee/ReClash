package core

import (
	"context"
	"errors"
	"fmt"
	"reflect"
	"slices"
	"sync/atomic"
	"testing"
	"time"

	"core/rcx"

	"github.com/metacubex/mihomo/adapter/outboundgroup"
	"github.com/metacubex/mihomo/adapter/provider"
	C "github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/tunnel"
)

const heldStrategy = "version: 1\nlevels:\n- pick: hold\n"

func TestScriptedProviderStrategyAndExplicitNativeOverride(t *testing.T) {
	setupHome(t, routedProfile, `
routing:
  strategies:
    g:
      version: 1
      levels:
        - match: {members: [b]}
          pick: first
`)
	params := defaultSetupParams()
	params.Rcx = &rcx.UserLayer{}
	load, err := loadSetupConfig(params)
	if err != nil {
		t.Fatal(err)
	}
	proxies := load.cfg.Proxies
	attachScriptedGroups(load.cfg, nil)
	if issues := resolveGroupStrategies(proxies, load.subscription.Strategies, *params.Rcx, nil); len(issues) != 0 {
		t.Fatal(issues)
	}
	group := scriptedGroupOf(proxies["g"])
	if got := group.Unwrap(&C.Metadata{}, false).Name(); got != "b" {
		t.Fatalf("provider selected %q, want b", got)
	}
	if got := group.Now(); got != "b" {
		t.Fatalf("group reports %q as its current server, want b", got)
	}
	resolveGroupStrategies(proxies, load.subscription.Strategies, rcx.UserLayer{Strategies: map[string]string{"g": ""}}, nil)
	if _, ok := adapterAs[*outboundgroup.Selector](proxies["g"]); !ok {
		t.Fatal("legacy selector is unavailable when the strategy is disabled")
	}
	if got := group.Unwrap(&C.Metadata{}, false).Name(); got != "a" {
		t.Fatalf("native selector chose %q, want a", got)
	}
}

func TestScriptedLocalGroupBecomesAScenarioTarget(t *testing.T) {
	setupHome(t, routedProfile, `
routing:
  scenarios:
    standard:
      title: Standard
      routes:
        - name: Video
          match: [DOMAIN-SUFFIX,youtube.test]
          to: Local
`)
	params := defaultSetupParams()
	params.Rcx = &rcx.UserLayer{
		Scenario:    "provider/standard",
		Strategies:  map[string]string{"Local": heldStrategy},
		LocalGroups: map[string]rcx.LocalStrategyGroup{"Local": {Members: []string{"a", "b"}}},
	}
	load, err := loadSetupConfig(params)
	if err != nil {
		t.Fatal(err)
	}
	if got := ruleStrings(load.cfg); !slices.Equal(got, []string{"DomainSuffix,youtube.test,Local", "Match,,g"}) {
		t.Fatalf("rules %v", got)
	}
	if load.cfg.Proxies["Local"] == nil || len(load.strategyIssues) != 0 {
		t.Fatalf("group not applied: %v", load.strategyIssues)
	}
}

func TestScriptedLocalGroupCollisionDoesNotOverrideProvider(t *testing.T) {
	setupHome(t, routedProfile, "")
	params := defaultSetupParams()
	params.Rcx = &rcx.UserLayer{
		Strategies:  map[string]string{"g": heldStrategy},
		LocalGroups: map[string]rcx.LocalStrategyGroup{"g": {Members: []string{"a"}}},
	}
	load, err := loadSetupConfig(params)
	if err != nil {
		t.Fatal(err)
	}
	attachScriptedGroups(load.cfg, nil)
	resolveGroupStrategies(load.cfg.Proxies, nil, *params.Rcx, load.strategyIssues)
	if load.strategyIssues["g"].Issue == "" || scriptedGroupOf(load.cfg.Proxies["g"]).state.Load() != nil {
		t.Fatal("the local group shadowed a provider group")
	}
}

func TestScriptedWeightedReturnAndStickyPreview(t *testing.T) {
	setupHome(t, nestedProfile, "")
	load, err := loadSetupConfig(defaultSetupParams())
	if err != nil {
		t.Fatal(err)
	}
	a, b, c := load.cfg.Proxies["a"], load.cfg.Proxies["b"], load.cfg.Proxies["c"]
	pool := []strategyCandidate{{proxy: a}, {proxy: b}, {proxy: c}}
	levels := []rcx.StrategyLevel{
		{Pick: "weighted", Weights: map[string]int{"a": 2}, ReturnAfter: 2 * time.Minute},
		{Pick: "first"},
	}
	history := strategyHistory{}
	now := time.Unix(1000, 0)
	active := history.resolve(now, levels, [][]strategyCandidate{pool, {{proxy: b}}})
	var sequence atomic.Uint64
	metadata := &C.Metadata{Host: "test.example"}
	if active.pick(metadata, false, &sequence).Name() != "a" || sequence.Load() != 0 {
		t.Fatal("inspection advanced the weighted sequence")
	}
	got := make([]string, 0, 8)
	for range 8 {
		got = append(got, active.pick(metadata, true, &sequence).Name())
	}
	if !reflect.DeepEqual(got, []string{"a", "a", "b", "c", "a", "a", "b", "c"}) {
		t.Fatalf("weighted order = %v", got)
	}
	levelsAt := func(time time.Time, primary []strategyCandidate) string {
		return history.resolve(time, levels, [][]strategyCandidate{primary, {{proxy: b}}}).proxies[0].Name()
	}
	if levelsAt(now.Add(time.Second), nil) != "b" ||
		levelsAt(now.Add(2*time.Second), pool) != "b" ||
		levelsAt(now.Add(time.Minute+2*time.Second), pool) != "b" ||
		levelsAt(now.Add(2*time.Minute+2*time.Second), pool) != "a" {
		t.Fatal("reserve was not held for the configured recovery interval")
	}
	sticky := makeStrategyPool(rcx.StrategyLevel{Pick: "sticky"}, pool, "")
	first := sticky.pick(metadata, true, &sequence)
	for range 5 {
		if sticky.pick(metadata, true, &sequence) != first {
			t.Fatal("a stable destination moved to a different member")
		}
	}
}

func TestScriptedEmptyStrategyNeverFallsThroughToDirect(t *testing.T) {
	setupHome(t, routedProfile, "")
	load, err := loadSetupConfig(defaultSetupParams())
	if err != nil {
		t.Fatal(err)
	}
	attachScriptedGroups(load.cfg, nil)
	resolveGroupStrategies(load.cfg.Proxies, map[string]string{
		"g": "version: 1\nlevels:\n- match: {countries: [RU]}\n  pick: hold\n",
	}, rcx.UserLayer{}, nil)
	group := scriptedGroupOf(load.cfg.Proxies["g"])
	if group.Unwrap(&C.Metadata{}, false) != nil {
		t.Fatal("empty strategy resolved a candidate")
	}
	if _, err := group.DialContext(context.Background(), &C.Metadata{}); err != errStrategyEmpty {
		t.Fatalf("empty dial error = %v", err)
	}
	if _, err := group.ListenPacketContext(context.Background(), &C.Metadata{NetWork: C.UDP}); err != errStrategyEmpty {
		t.Fatalf("empty packet error = %v", err)
	}
}

func TestScriptedManualStrategyKeepsTheRestoredPick(t *testing.T) {
	setupHome(t, routedProfile, "")
	load, err := loadSetupConfig(defaultSetupParams())
	if err != nil {
		t.Fatal(err)
	}
	attachScriptedGroups(load.cfg, nil)
	oldProxies, oldProviders := tunnel.Proxies(), tunnel.ProvidersSnapshot()
	t.Cleanup(func() { tunnel.UpdateProxies(oldProxies, oldProviders) })
	tunnel.UpdateProxies(load.cfg.Proxies, load.cfg.Providers)
	resolveGroupStrategies(load.cfg.Proxies, map[string]string{
		"g": "version: 1\nlevels:\n- pick: manual\n",
	}, rcx.UserLayer{}, nil)
	group := scriptedGroupOf(load.cfg.Proxies["g"])
	if got := group.Unwrap(&C.Metadata{}, false).Name(); got != "a" {
		t.Fatalf("manual strategy started on %q, want the selector's pick a", got)
	}
	patchSelectGroup(map[string]string{"g": "b"})
	if got := group.Unwrap(&C.Metadata{}, false).Name(); got != "b" {
		t.Fatalf("manual strategy ignored the restored pick: %q", got)
	}
}

func TestScriptedPinSurvivesAnApply(t *testing.T) {
	setupHome(t, routedProfile, "")
	load, err := loadSetupConfig(defaultSetupParams())
	if err != nil {
		t.Fatal(err)
	}
	attachScriptedGroups(load.cfg, nil)
	oldRegistry, oldProxies, oldProviders := currentStrategyRegistry.Load(), tunnel.Proxies(), tunnel.ProvidersSnapshot()
	t.Cleanup(func() {
		currentStrategyRegistry.Store(oldRegistry)
		tunnel.UpdateProxies(oldProxies, oldProviders)
	})
	tunnel.UpdateProxies(load.cfg.Proxies, load.cfg.Providers)
	user := rcx.UserLayer{Strategies: map[string]string{"g": heldStrategy}}
	useGroupStrategies(load.cfg.Proxies, load.cfg.Providers[provider.ReservedName], rcx.SubscriptionLayer{}, user, nil)
	selector, err := selectableGroup("g")
	if err != nil {
		t.Fatal(err)
	}
	if err := selector.Set("b"); err != nil {
		t.Fatal(err)
	}
	next, err := loadSetupConfig(defaultSetupParams())
	if err != nil {
		t.Fatal(err)
	}
	attachScriptedGroups(next.cfg, nil)
	useGroupStrategies(next.cfg.Proxies, next.cfg.Providers[provider.ReservedName], rcx.SubscriptionLayer{}, user, nil)
	if got := scriptedGroupOf(next.cfg.Proxies["g"]).Now(); got != "b" {
		t.Fatalf("apply forgot the pinned server: %q", got)
	}
}

func TestScriptedStudioLintsAgainstTheInstalledConfig(t *testing.T) {
	setupHome(t, routedProfile, "")
	load, err := loadSetupConfig(defaultSetupParams())
	if err != nil {
		t.Fatal(err)
	}
	attachScriptedGroups(load.cfg, nil)
	oldProxies, oldProviders := tunnel.Proxies(), tunnel.ProvidersSnapshot()
	t.Cleanup(func() { tunnel.UpdateProxies(oldProxies, oldProviders) })
	tunnel.UpdateProxies(load.cfg.Proxies, load.cfg.Providers)
	result := strategyStudio(rcx.StudioRequest{Op: "lint", Kind: "strategy", Group: "g", Text: heldStrategy})
	if len(result.Errors) != 0 || len(result.StrategyLevels) != 1 || !slices.Contains(result.StrategyLevels[0], "a") {
		t.Fatalf("standalone lint: %+v", result)
	}
	global := strategyStudio(rcx.StudioRequest{Op: "lint", Kind: "strategy", Group: globalProxyName, Text: heldStrategy})
	if len(global.Errors) == 0 {
		t.Fatal("GLOBAL accepted a strategy")
	}
}

func TestScriptedRememberedPickPinsAFreshRuntime(t *testing.T) {
	setupHome(t, routedProfile, "")
	load, err := loadSetupConfig(defaultSetupParams())
	if err != nil {
		t.Fatal(err)
	}
	attachScriptedGroups(load.cfg, nil)
	oldProxies, oldProviders := tunnel.Proxies(), tunnel.ProvidersSnapshot()
	t.Cleanup(func() { tunnel.UpdateProxies(oldProxies, oldProviders) })
	tunnel.UpdateProxies(load.cfg.Proxies, load.cfg.Providers)
	resolveGroupStrategies(load.cfg.Proxies, map[string]string{"g": heldStrategy}, rcx.UserLayer{}, nil)
	patchSelectGroup(map[string]string{"g": "b"})
	if got := scriptedGroupOf(load.cfg.Proxies["g"]).Now(); got != "b" {
		t.Fatalf("remembered pick did not pin a fresh strategy: %q", got)
	}
}

type strategyDialRecorder struct {
	C.Proxy
	err error
}

func (p strategyDialRecorder) DialContext(context.Context, *C.Metadata) (C.Conn, error) {
	return nil, p.err
}

func (p strategyDialRecorder) ListenPacketContext(context.Context, *C.Metadata) (C.PacketConn, error) {
	return nil, p.err
}

func TestScriptedConnectionAndSessionUseTheirOwnEligiblePool(t *testing.T) {
	setupHome(t, routedProfile, "")
	load, err := loadSetupConfig(defaultSetupParams())
	if err != nil {
		t.Fatal(err)
	}
	attachScriptedGroups(load.cfg, nil)
	group := scriptedGroupOf(load.cfg.Proxies["g"])
	tcp := errors.New("tcp member")
	udp := errors.New("udp member")
	policy, err := rcx.ParseStrategy(heldStrategy)
	if err != nil {
		t.Fatal(err)
	}
	runtime := &strategyRuntime{policy: policy}
	pools := &strategySnapshot{
		tcp: strategyPool{proxies: []C.Proxy{strategyDialRecorder{load.cfg.Proxies["a"], tcp}}},
		udp: strategyPool{proxies: []C.Proxy{strategyDialRecorder{load.cfg.Proxies["b"], udp}}},
	}
	runtime.snapshot.Store(pools)
	group.state.Store(runtime)
	if _, err := group.DialContext(context.Background(), &C.Metadata{}); err != tcp {
		t.Fatalf("TCP dial returned %v", err)
	}
	runtime.snapshot.Store(pools)
	metadata := &C.Metadata{NetWork: C.UDP}
	if _, err := group.ListenPacketContext(context.Background(), metadata); err != udp {
		t.Fatalf("UDP session returned %v", err)
	}
	group.disableUDP = true
	if strategyMemberSupportsUDP(load.cfg.Proxies["g"]) {
		t.Fatal("strategy made a UDP-disabled group eligible as a member")
	}
	if _, err := group.ListenPacketContext(context.Background(), metadata); err != errStrategyEmpty {
		t.Fatalf("UDP disabled by config returned %v", err)
	}
}

func TestScriptedEmptyUDPRouteIsNotSkipped(t *testing.T) {
	setupHome(t, routedProfile+"  - MATCH,DIRECT\n", "")
	load, err := loadSetupConfig(defaultSetupParams())
	if err != nil {
		t.Fatal(err)
	}
	attachScriptedGroups(load.cfg, nil)
	resolveGroupStrategies(load.cfg.Proxies, map[string]string{
		"g": "version: 1\nlevels:\n- match: {members: [missing]}\n  pick: first\n",
	}, rcx.UserLayer{}, nil)
	oldMode, oldProxies, oldProviders := tunnel.Mode(), tunnel.Proxies(), tunnel.ProvidersSnapshot()
	oldRules, oldRuleProviders := tunnel.Rules(), tunnel.RuleProvidersSnapshot()
	tunnel.SetMode(tunnel.Rule)
	tunnel.UpdateProxies(load.cfg.Proxies, load.cfg.Providers)
	tunnel.UpdateRules(load.cfg.Rules, load.cfg.SubRules, load.cfg.RuleProviders)
	t.Cleanup(func() {
		tunnel.UpdateRules(oldRules, nil, oldRuleProviders)
		tunnel.UpdateProxies(oldProxies, oldProviders)
		tunnel.SetMode(oldMode)
	})
	metadata := &C.Metadata{NetWork: C.UDP, Type: C.HTTP, Host: "example.test", DstPort: 443}
	proxy, err := tunnel.ResolveRoute(metadata)
	if err != nil {
		t.Fatal(err)
	}
	if proxy.Name() != "g" {
		t.Fatalf("UDP resolved to %q, want the original matching group", proxy.Name())
	}
	if _, err := proxy.ListenPacketContext(context.Background(), metadata); !errors.Is(err, errStrategyEmpty) {
		t.Fatalf("empty UDP pool returned %v", err)
	}
}

type scriptedEarlyFailureConn struct {
	C.Conn
}

func (scriptedEarlyFailureConn) NeedHandshake() bool           { return true }
func (scriptedEarlyFailureConn) AppendToChains(C.ProxyAdapter) {}
func (scriptedEarlyFailureConn) Write([]byte) (int, error) {
	return 0, errors.New("early write rejected")
}

type scriptedEarlyFailureProxy struct{ C.Proxy }

func (scriptedEarlyFailureProxy) DialContext(context.Context, *C.Metadata) (C.Conn, error) {
	return scriptedEarlyFailureConn{}, nil
}

type scriptedFixtureGroup struct {
	outboundgroup.ProxyGroup
	members []C.Proxy
}

func (g scriptedFixtureGroup) Proxies() []C.Proxy { return g.members }

func TestScriptedFirstWriteFailureIsRecorded(t *testing.T) {
	setupHome(t, routedProfile, "")
	load, err := loadSetupConfig(defaultSetupParams())
	if err != nil {
		t.Fatal(err)
	}
	attachScriptedGroups(load.cfg, nil)
	resolveGroupStrategies(load.cfg.Proxies, map[string]string{"g": heldStrategy}, rcx.UserLayer{}, nil)
	group := scriptedGroupOf(load.cfg.Proxies["g"])
	runtime := group.state.Load()
	member := scriptedEarlyFailureProxy{runtime.pick(nil, false, false)}
	backup := load.cfg.Proxies["b"]
	group.ProxyGroup = scriptedFixtureGroup{group.ProxyGroup, []C.Proxy{member, backup}}
	group.refresh()
	conn, err := group.DialContext(context.Background(), &C.Metadata{})
	if err != nil {
		t.Fatal(err)
	}
	if _, err := conn.Write([]byte{0}); err == nil {
		t.Fatal("expected the deferred handshake to fail")
	}
	if got := runtime.pick(nil, false, false); got != backup {
		t.Fatalf("next connection selected %v instead of the backup", got)
	}
	if got := group.Now(); got != backup.Name() {
		t.Fatalf("group reports %q as its current server, want %s", got, backup.Name())
	}
}

func TestScriptedUDPFailureDoesNotRemoveTCPMember(t *testing.T) {
	setupHome(t, routedProfile, "")
	load, err := loadSetupConfig(defaultSetupParams())
	if err != nil {
		t.Fatal(err)
	}
	attachScriptedGroups(load.cfg, nil)
	resolveGroupStrategies(load.cfg.Proxies, map[string]string{"g": heldStrategy}, rcx.UserLayer{}, nil)
	group := scriptedGroupOf(load.cfg.Proxies["g"])
	runtime := group.state.Load()
	member := runtime.pick(nil, false, false)
	if member == nil {
		t.Fatal("expected a TCP member")
	}
	runtime.note(member, errors.New("UDP failed"), &runtime.udp)
	group.refresh()
	if actual := runtime.pick(nil, false, false); actual != member {
		t.Fatalf("UDP failure changed TCP pick from %v to %v", member, actual)
	}
	runtime.note(member, errors.New("TCP failed"), &runtime.tcp)
	group.refresh()
	if actual := runtime.pick(nil, false, false); actual == member {
		t.Fatal("TCP failure did not trigger failover")
	}
}

func TestScriptedRemovedMemberKeepsTheGroupAndItsRules(t *testing.T) {
	setupHome(t, routedProfile, "")
	params := defaultSetupParams()
	params.Rcx = &rcx.UserLayer{
		Strategies:  map[string]string{"Local": heldStrategy},
		LocalGroups: map[string]rcx.LocalStrategyGroup{"Local": {Members: []string{"removed"}}},
	}
	load, err := loadSetupConfig(params)
	if err != nil {
		t.Fatal(err)
	}
	attachScriptedGroups(load.cfg, nil)
	resolveGroupStrategies(load.cfg.Proxies, nil, *params.Rcx, load.strategyIssues)
	group := scriptedGroupOf(load.cfg.Proxies["Local"])
	if group == nil || group.Unwrap(&C.Metadata{}, false) != nil {
		t.Fatal("removed member must leave an empty group")
	}
}

func TestScriptedReportsFollowTheInstalledConfiguration(t *testing.T) {
	setupHome(t, routedProfile, "")
	load, err := loadSetupConfig(defaultSetupParams())
	if err != nil {
		t.Fatal(err)
	}
	replacement, err := loadSetupConfig(defaultSetupParams())
	if err != nil {
		t.Fatal(err)
	}
	oldRegistry := currentStrategyRegistry.Load()
	oldProxies, oldProviders := tunnel.Proxies(), tunnel.ProvidersSnapshot()
	t.Cleanup(func() {
		currentStrategyRegistry.Store(oldRegistry)
		tunnel.UpdateProxies(oldProxies, oldProviders)
	})
	attachScriptedGroups(load.cfg, nil)
	tunnel.UpdateProxies(load.cfg.Proxies, load.cfg.Providers)
	useGroupStrategies(load.cfg.Proxies, load.cfg.Providers[provider.ReservedName], rcx.SubscriptionLayer{}, rcx.UserLayer{}, nil)
	if liveStrategyRegistry() == nil {
		t.Fatal("expected strategies support for the attached configuration")
	}
	tunnel.UpdateProxies(replacement.cfg.Proxies, replacement.cfg.Providers)
	if status := withStrategyReports(rcx.Status{}); status.StrategySupport || len(status.Strategies) > 0 {
		t.Fatal("an external reload left the old strategy support and reports visible")
	}
}

func TestScriptedOlderSetupKeepsTheNewerPolicyForTheSameProfile(t *testing.T) {
	previous, sequence, scope := rcxCurrentUser(), latestRCXPolicyCall, appliedRCXProfileScope
	t.Cleanup(func() {
		rcxMu.Lock()
		rcxUser = previous
		rcxMu.Unlock()
		latestRCXPolicyCall, appliedRCXProfileScope = sequence, scope
	})
	rcxMu.Lock()
	rcxUser = rcx.UserLayer{ProfileScope: "a", Strategies: map[string]string{"g": heldStrategy}}
	rcxMu.Unlock()
	latestRCXPolicyCall, appliedRCXProfileScope = 2, "a"

	params := &SetupParams{Rcx: &rcx.UserLayer{ProfileScope: "a"}, callSequence: 1}
	if got := withLatestRoutingPolicy(params); got.Rcx.Strategies["g"] != heldStrategy {
		t.Fatal("an older setup discarded the live strategy")
	}
	params.Rcx.LocalGroups = map[string]rcx.LocalStrategyGroup{"New": {Members: []string{"a"}}}
	params.Rcx.Strategies = map[string]string{"New": heldStrategy}
	merged := withLatestRoutingPolicy(params).Rcx
	if merged.Strategies["g"] != heldStrategy || merged.Strategies["New"] != heldStrategy || len(merged.LocalGroups) != 1 {
		t.Fatal("merging a live edit discarded a queued group creation")
	}
	if err := validateChangedStrategies(rcxCurrentUser(), *params.Rcx); err == nil {
		t.Fatal("a live update accepted an uninstalled local group")
	}
	params.Rcx.ProfileScope = "b"
	if got := withLatestRoutingPolicy(params); got != params {
		t.Fatal("setup reused policies across profiles")
	}
}

func BenchmarkScriptedPick500(b *testing.B) {
	ends := make([]uint64, 500)
	for i := range ends {
		ends[i] = uint64(i + 1)
	}
	pool := strategyPool{proxies: make([]C.Proxy, 500), ends: ends, kind: "sticky"}
	var sequence atomic.Uint64
	metadata := &C.Metadata{Host: "test.example"}
	for i := 0; b.Loop(); i++ {
		metadata.Host = fmt.Sprintf("server%d.example", i%100)
		pool.pick(metadata, true, &sequence)
	}
}
