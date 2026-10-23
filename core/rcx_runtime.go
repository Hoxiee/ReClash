package core

import (
	"bytes"
	"cmp"
	"context"
	"encoding/json"
	"errors"
	"maps"
	"net/netip"
	"os"
	"path/filepath"
	"slices"
	"strings"
	"sync"
	"sync/atomic"

	"core/rcx"

	"github.com/metacubex/mihomo/adapter"
	"github.com/metacubex/mihomo/adapter/outboundgroup"
	"github.com/metacubex/mihomo/adapter/provider"
	"github.com/metacubex/mihomo/config"
	"github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/tunnel"
	"github.com/metacubex/mihomo/tunnel/statistic"
	"go.yaml.in/yaml/v3"
)

const rcxStateFile = "rcx-state.json"

const rcxBundleLimit = 256 << 10

var (
	rcxMu           sync.Mutex
	rcxEngine       *rcx.Engine
	rcxCurrent      atomic.Pointer[rcx.Engine]
	rcxSubscription rcx.SubscriptionLayer
	// Persisted, so a headless restart of the Android service keeps it.
	rcxUser rcx.UserLayer
	// Hints the Android service sends before the core is initialized.
	rcxPendingHints []rcx.Hints
	// Flattened nested selector → its smart group; replaced whole, never mutated.
	rcxFlatOwner = map[string]string{}
	// The mode a scenario holds over the user's own; nil leaves the user's.
	rcxModeWish atomic.Pointer[tunnel.TunnelMode]
	rcxUserMode atomic.Pointer[tunnel.TunnelMode]
)

const (
	maxPendingHints = 16
	maxFlattenDepth = 4
)

func rcxReady() *rcx.Engine {
	rcxMu.Lock()
	defer rcxMu.Unlock()
	if rcxEngine == nil && isInit.Load() {
		rcxEngine = rcx.NewEngine(rcxRuntime{}, rcxProber{}, rcxFileStore{rcxStateFile}, rcxHost{})
		rcxEngine.SetRunning(isRunning.Load())
		rcxCurrent.Store(rcxEngine)
		if data, err := (rcxFileStore{rcxUserFile}).Load(); err == nil && len(data) > 0 {
			_ = json.Unmarshal(data, &rcxUser)
		}
		rcxEngine.SetUserLayer(rcxUser)
		if mode := rcxUserMode.Load(); mode != nil {
			rcxEngine.SetUserMode(mode.String())
		}
		for _, hints := range rcxPendingHints {
			rcxEngine.SetHints(hints)
		}
		rcxPendingHints = nil
		rcxWatchPower()
	}
	return rcxEngine
}

// rcxIfReady never creates the engine: hooks on the dial path must not pay
// for a first construction or take its lock.
func rcxIfReady() *rcx.Engine {
	return rcxCurrent.Load()
}

func rcxDefer(hints rcx.Hints) bool {
	rcxMu.Lock()
	defer rcxMu.Unlock()
	if rcxEngine != nil || isInit.Load() {
		return false
	}
	if len(rcxPendingHints) < maxPendingHints {
		rcxPendingHints = append(rcxPendingHints, hints)
	}
	return true
}

type rcxRuntime struct{}

// Innermost first, so the group never routes through a stale nested selector.
func (rcxRuntime) Select(group string, via []string, node string) error {
	selectMu.Lock()
	defer selectMu.Unlock()
	chain := append(append([]string{group}, via...), node)
	for i := len(chain) - 2; i >= 0; i-- {
		selector, err := selectableGroup(chain[i])
		if err == nil {
			err = selector.Set(chain[i+1])
		}
		if err != nil {
			requestRcxTopologyRefresh()
			return err
		}
	}
	refreshRouteLocked(false)
	return nil
}

func (rcxRuntime) CloseConnections(group, node string) {
	statistic.DefaultManager.Range(func(c statistic.Tracker) bool {
		chain := c.Info().Chain
		if slices.Contains(chain, group) && slices.Contains(chain, node) {
			_ = c.Close()
		}
		return true
	})
}

func (rcxRuntime) SuppressHealthChecks(providers []string) {
	provider.SetAutoHealthCheckSuppressed(providers)
}

// ApplyMode runs under the engine's lock, so the route epoch moves on its
// own goroutine.
func (rcxRuntime) ApplyMode(mode string) {
	if mode == "" {
		rcxModeWish.Store(nil)
	} else {
		var wish tunnel.TunnelMode
		if wish.UnmarshalText([]byte(mode)) != nil {
			return
		}
		rcxModeWish.Store(&wish)
	}
	user := tunnel.Rule
	if mode := rcxUserMode.Load(); mode != nil {
		user = *mode
	}
	if target := rcxEffectiveMode(user); tunnel.Mode() != target {
		tunnel.SetMode(target)
		safeGo("bumpRouteEpoch", bumpRouteEpoch)
	}
}

func rcxEffectiveMode(user tunnel.TunnelMode) tunnel.TunnelMode {
	if wish := rcxModeWish.Load(); wish != nil {
		return *wish
	}
	return user
}

// rcxSetUserMode records the mode the user set and returns the one to
// apply: a scenario's mode stays in force over it.
func rcxSetUserMode(mode tunnel.TunnelMode) tunnel.TunnelMode {
	rcxUserMode.Store(&mode)
	if e := rcxIfReady(); e != nil {
		name := mode.String()
		safeGo("rcxSetUserMode", func() { e.SetUserMode(name) })
	}
	return rcxEffectiveMode(mode)
}

type rcxProber struct{}

func (rcxProber) Probe(ctx context.Context, node string) (int, error) {
	proxy := lookupProxy(node)
	if proxy == nil {
		return 0, errors.New("proxy not found")
	}
	rcxOwnProbes.begin(proxy.Name())
	defer rcxOwnProbes.end(proxy.Name())
	delay, err := proxy.URLTest(ctx, currentTestURL(), anyDelayTestStatus)
	return int(delay), err
}

// URLTest also calls adapter.UrlTestHook; the engine must not count its own probes twice.
var rcxOwnProbes = nodeProbes{running: map[string]int{}}

type nodeProbes struct {
	mu      sync.Mutex
	running map[string]int
}

func (p *nodeProbes) begin(node string) {
	p.mu.Lock()
	p.running[node]++
	p.mu.Unlock()
}

func (p *nodeProbes) end(node string) {
	p.mu.Lock()
	if p.running[node]--; p.running[node] <= 0 {
		delete(p.running, node)
	}
	p.mu.Unlock()
}

func (p *nodeProbes) owns(node string) bool {
	p.mu.Lock()
	defer p.mu.Unlock()
	return p.running[node] > 0
}

type rcxHost struct{}

func (rcxHost) Publish(status rcx.Status) {
	sendMessage(RcxStatusMessage, status)
}

type rcxFileStore struct{ name string }

const rcxUserFile = "rcx-user.json"

func (s rcxFileStore) path() string {
	return filepath.Join(constant.Path.HomeDir(), s.name)
}

func (s rcxFileStore) Load() ([]byte, error) {
	return os.ReadFile(s.path())
}

func (s rcxFileStore) Save(data []byte) error {
	tmp := s.path() + ".tmp"
	if err := os.WriteFile(tmp, data, 0o600); err != nil {
		return err
	}
	return os.Rename(tmp, s.path())
}

type coalescedRun struct {
	pending, running atomic.Bool
}

func (c *coalescedRun) request(name string, run func()) {
	c.pending.Store(true)
	if c.running.CompareAndSwap(false, true) {
		safeGo(name, func() { c.loop(name, run) })
	}
}

func (c *coalescedRun) loop(name string, run func()) {
	defer func() {
		c.running.Store(false)
		if c.pending.Load() {
			c.request(name, run)
		}
	}()
	for c.pending.Swap(false) {
		run()
	}
}

var rcxTopologyRefresh coalescedRun

// Run asynchronously: callers may hold selectMu, which the engine takes when it selects.
func requestRcxTopologyRefresh() {
	rcxTopologyRefresh.request("rcxRefreshTopology", rcxRefreshTopology)
}

func rcxRefreshTopology() {
	e := rcxReady()
	if e == nil {
		return
	}
	proxies := tunnel.AllProxies()
	rcxMu.Lock()
	subscription := rcxSubscription
	smart := map[string]bool{}
	for name := range rcxSubscription.Groups {
		smart[name] = true
	}
	for name := range rcxUser.Groups {
		smart[name] = true
	}
	rcxMu.Unlock()
	names := proxyGroupNames(config.GetProxyNameList(), func(name string) (constant.AdapterType, bool) {
		p, ok := proxies[name]
		if !ok || p == nil {
			return 0, false
		}
		return p.Type(), true
	})
	rules := tunnel.Rules()
	main := rcxMainGroup(proxies, rules)
	configMu.Lock()
	if currentConfig != nil {
		for _, sub := range currentConfig.SubRules {
			rules = append(slices.Clip(rules), sub...)
		}
	}
	configMu.Unlock()
	// A scenario's groups are smart too, and a member it holds a group on
	// stays whole.
	targets, fixed := e.Targets(rcxSelectors(proxies, names), main)
	for _, name := range append(targets, fixed...) {
		smart[name] = true
	}
	topology, flat := rcxTopologyOf(proxies, names, smart, rcxReferences(proxies, names, rules))
	topology.Subscription, topology.Main = subscription, main
	geo := rcxGeo()
	for i := range topology.Groups {
		for j := range topology.Groups[i].Members {
			member := &topology.Groups[i].Members[j]
			if ip, err := netip.ParseAddr(member.Server); err == nil {
				member.Entry = geo(ip)
			}
		}
	}
	rcxMu.Lock()
	rcxFlatOwner = flat
	rcxMu.Unlock()
	e.SetTopology(topology)
	// The scenario was read from the library before this topology rebuilt
	// it; a new subscription may name other groups.
	if again, fixedAgain := e.Targets(rcxSelectors(proxies, names), main); !slices.Equal(again, targets) || !slices.Equal(fixedAgain, fixed) {
		requestRcxTopologyRefresh()
	}
}

func rcxTopologyOf(proxies map[string]constant.Proxy, names []string, smart map[string]bool, refs map[string]int) (rcx.Topology, map[string]string) {
	topology := rcx.Topology{Providers: map[string][]string{}}
	flat := map[string]string{}
	for _, name := range names {
		selector, ok := adapterAs[*outboundgroup.Selector](proxies[name])
		if !ok || name == globalProxyName && !smart[name] {
			continue
		}
		group := rcx.GroupTopology{Name: name}
		seen := map[string]int{}
		var walk func(selector *outboundgroup.Selector, via []string)
		walk = func(selector *outboundgroup.Selector, via []string) {
			for _, member := range selector.Proxies() {
				inner, nested := adapterAs[*outboundgroup.Selector](member)
				if nested && smart[name] && name != globalProxyName && len(via) < maxFlattenDepth && rcxFlattens(member.Name(), refs, smart, flat) {
					flat[member.Name()] = name
					walk(inner, append(slices.Clip(via), member.Name()))
					continue
				}
				node := rcxNode(member)
				node.Via = via
				// A server reached both directly and nested keeps the shortest path.
				if i, dup := seen[node.Name]; dup {
					if len(via) < len(group.Members[i].Via) {
						group.Members[i] = node
					}
					continue
				}
				seen[node.Name] = len(group.Members)
				group.Members = append(group.Members, node)
			}
			for _, pd := range selector.Providers() {
				for _, member := range pd.Proxies() {
					if pd.Name() != selector.Name() {
						topology.Providers[member.Name()] = appendUnique(topology.Providers[member.Name()], pd.Name())
					}
				}
			}
		}
		walk(selector, nil)
		group.Now = rcxLeaf(proxies, flat, selector.Now())
		topology.Groups = append(topology.Groups, group)
	}
	return topology, flat
}

// rcxMainGroup is the select group the final MATCH rule routes to.
func rcxMainGroup(proxies map[string]constant.Proxy, rules []constant.Rule) string {
	if len(rules) == 0 || rules[len(rules)-1].RuleType() != constant.MATCH {
		return ""
	}
	name := rules[len(rules)-1].Adapter()
	if _, ok := adapterAs[*outboundgroup.Selector](proxies[name]); !ok {
		return ""
	}
	return name
}

func rcxSelectors(proxies map[string]constant.Proxy, names []string) []string {
	var out []string
	for _, name := range names {
		if _, ok := adapterAs[*outboundgroup.Selector](proxies[name]); ok {
			out = append(out, name)
		}
	}
	return out
}

// Only a nested selector the smart group alone uses is flattened; one another
// group or rule routes through stays the user's, as one opaque candidate.
func rcxFlattens(name string, refs map[string]int, smart map[string]bool, flat map[string]string) bool {
	_, done := flat[name]
	return refs[name] == 1 && !smart[name] && !done
}

func rcxReferences(proxies map[string]constant.Proxy, groups []string, rules []constant.Rule) map[string]int {
	refs := map[string]int{}
	for _, name := range groups {
		if name == globalProxyName {
			continue
		}
		if group, ok := adapterAs[interface{ GetProxies(bool) []constant.Proxy }](proxies[name]); ok {
			for _, member := range group.GetProxies(false) {
				refs[member.Name()]++
			}
		}
	}
	for _, rule := range rules {
		refs[rule.Adapter()]++
	}
	return refs
}

func rcxLeaf(proxies map[string]constant.Proxy, flat map[string]string, name string) string {
	for range maxFlattenDepth + 1 {
		if _, ok := flat[name]; !ok {
			return name
		}
		selector, ok := adapterAs[*outboundgroup.Selector](proxies[name])
		if !ok {
			return name
		}
		name = selector.Now()
	}
	return name
}

// A pick of a flattened selector, or inside one, picks its leaf in the owner.
func rcxPickOf(group, name string) (string, string) {
	rcxMu.Lock()
	flat := rcxFlatOwner
	rcxMu.Unlock()
	if owner, ok := flat[group]; ok {
		group = owner
	}
	return group, rcxLeaf(tunnel.AllProxies(), flat, name)
}

// rcxDirectSplit keeps local destinations local: private, CGNAT, link-local
// and ULA addresses, and names that only resolve on the LAN.
func rcxDirectSplit(metadata *constant.Metadata) string {
	e := rcxIfReady()
	if e == nil {
		return ""
	}
	target := e.SplitTarget()
	if target == "" || rcxLocal(metadata) {
		return ""
	}
	return target
}

var rcxCGNAT = netip.MustParsePrefix("100.64.0.0/10")

func rcxLocal(metadata *constant.Metadata) bool {
	if ip := metadata.DstIP.Unmap(); ip.IsValid() {
		if ip.IsPrivate() || ip.IsLoopback() || ip.IsLinkLocalUnicast() || ip.IsLinkLocalMulticast() ||
			ip.IsMulticast() || ip.IsUnspecified() || rcxCGNAT.Contains(ip) {
			return true
		}
	}
	host := strings.TrimSuffix(strings.ToLower(metadata.Host), ".")
	if host == "" {
		return false
	}
	if !strings.Contains(host, ".") {
		return true
	}
	for _, suffix := range []string{".local", ".lan", ".home.arpa", ".internal", ".localdomain", ".localhost"} {
		if strings.HasSuffix(host, suffix) {
			return true
		}
	}
	return false
}

func appendUnique(list []string, value string) []string {
	if slices.Contains(list, value) {
		return list
	}
	return append(list, value)
}

func rcxNode(proxy constant.Proxy) rcx.Node {
	node := rcx.Node{Name: proxy.Name(), Type: proxy.Type().String(), UDP: proxy.SupportUDP()}
	if outbound, ok := proxy.(*adapter.Proxy); ok {
		node.Provider = outbound.ProxyInfo().ProviderName
		node.Strong = outbound.RouteFingerprint()
		node.Endpoint = outbound.EndpointFingerprint()
	}
	if host, _, found := strings.Cut(proxy.Addr(), ":"); found {
		node.Server = host
	} else {
		node.Server = proxy.Addr()
	}
	return node
}

// mihomo ignores a group's rcx key and the top-level rcx-profiles, so the
// applied config file is read once more for them.
func rcxReadSubscription(path string) rcx.SubscriptionLayer {
	var raw struct {
		ProxyGroups []struct {
			Name string       `yaml:"name"`
			Rcx  *rcx.Binding `yaml:"rcx"`
		} `yaml:"proxy-groups"`
		Profiles  map[string]any `yaml:"rcx-profiles"`
		Scenarios map[string]any `yaml:"rcx-scenarios"`
		Scenario  string         `yaml:"rcx-scenario"`
	}
	layer := rcxReadBundle(rcxBundlePath(path))
	buf, err := readCoreFile(path)
	if err != nil || !bytes.Contains(buf, []byte("rcx")) || yaml.Unmarshal(buf, &raw) != nil {
		return layer
	}
	for _, group := range raw.ProxyGroups {
		if group.Rcx != nil && group.Name != "" {
			layer.Groups[group.Name] = *group.Rcx
		}
	}
	maps.Copy(layer.Profiles, raw.Profiles)
	maps.Copy(layer.Scenarios, raw.Scenarios)
	layer.Scenario = cmp.Or(raw.Scenario, layer.Scenario)
	return layer
}

// rcxBundlePath is where the host keeps the routing bundle a provider serves
// beside a universal subscription (header reclash-routing).
func rcxBundlePath(path string) string {
	return strings.TrimSuffix(path, filepath.Ext(path)) + ".routing.yaml"
}

// rcxReadBundle reads a routing bundle: profiles and bindings to groups by
// name. What the subscription itself declares wins over it.
func rcxReadBundle(path string) rcx.SubscriptionLayer {
	var bundle struct {
		Profiles  map[string]any         `yaml:"profiles"`
		Groups    map[string]rcx.Binding `yaml:"groups"`
		Scenarios map[string]any         `yaml:"scenarios"`
		Scenario  string                 `yaml:"scenario"`
	}
	layer := rcx.SubscriptionLayer{Groups: map[string]rcx.Binding{}, Profiles: map[string]any{}, Scenarios: map[string]any{}}
	buf, err := readCoreFile(path)
	if err != nil || len(buf) > rcxBundleLimit || yaml.Unmarshal(buf, &bundle) != nil {
		return layer
	}
	maps.Copy(layer.Groups, bundle.Groups)
	maps.Copy(layer.Profiles, bundle.Profiles)
	maps.Copy(layer.Scenarios, bundle.Scenarios)
	layer.Scenario = bundle.Scenario
	return layer
}

func rcxApplySubscription(layer rcx.SubscriptionLayer) {
	rcxMu.Lock()
	rcxSubscription = layer
	rcxMu.Unlock()
	requestRcxTopologyRefresh()
}

func rcxSetUser(layer rcx.UserLayer) {
	rcxMu.Lock()
	rcxUser = layer
	rcxMu.Unlock()
	if data, err := json.Marshal(layer); err == nil {
		_ = rcxFileStore{rcxUserFile}.Save(data)
	}
	if e := rcxReady(); e != nil {
		e.SetUserLayer(layer)
	}
	// Which nested selectors flatten depends on which groups are smart.
	requestRcxTopologyRefresh()
}
