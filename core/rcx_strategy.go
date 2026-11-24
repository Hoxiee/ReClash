package core

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"hash/fnv"
	"maps"
	"slices"
	"sort"
	"strings"
	"sync"
	"sync/atomic"
	"time"

	"core/rcx"

	"github.com/metacubex/mihomo/adapter"
	"github.com/metacubex/mihomo/adapter/outboundgroup"
	"github.com/metacubex/mihomo/adapter/provider"
	"github.com/metacubex/mihomo/common/callback"
	N "github.com/metacubex/mihomo/common/net"
	"github.com/metacubex/mihomo/config"
	C "github.com/metacubex/mihomo/constant"
	P "github.com/metacubex/mihomo/constant/provider"
	"github.com/metacubex/mihomo/tunnel"
)

var appliedRCXProfileScope string

var errStrategyEmpty = errors.New("strategy has no reachable candidate")

type scriptedGroup struct {
	outboundgroup.ProxyGroup
	state       atomic.Pointer[strategyRuntime]
	selectionMu sync.Mutex
	disableUDP  bool
}

type scriptedSelector struct {
	*scriptedGroup
	outboundgroup.SelectAble
}

type strategyRuntime struct {
	source string
	url    string
	policy *rcx.Strategy
	local  bool

	mu       sync.Mutex
	tcp      strategyHistory
	udp      strategyHistory
	snapshot atomic.Pointer[strategySnapshot]
	sequence atomic.Uint64
	pinned   atomic.Pointer[string]
}

type strategyHistory struct {
	level   int
	healthy []time.Time
	current string
	failed  map[C.Proxy]time.Time
}

type strategySnapshot struct {
	tcp, udp                 strategyPool
	eligibleTCP, eligibleUDP map[string]C.Proxy
}

type strategyCandidate struct {
	proxy C.Proxy
	delay uint16
}

type strategyPool struct {
	proxies []C.Proxy
	ends    []uint64
	kind    string
}

func (p strategyPool) pick(m *C.Metadata, touch bool, sequence *atomic.Uint64) C.Proxy {
	if len(p.proxies) == 0 {
		return nil
	}
	switch p.kind {
	case "round-robin":
		i := sequence.Load()
		if touch {
			i = sequence.Add(1) - 1
		}
		return p.proxies[i%uint64(len(p.proxies))]
	case "weighted", "sticky", "sticky-session":
		var key uint64
		switch p.kind {
		case "weighted":
			key = sequence.Load()
			if touch {
				key = sequence.Add(1) - 1
			}
		default:
			hash := fnv.New64a()
			if m != nil {
				if p.kind == "sticky-session" {
					_, _ = hash.Write([]byte(m.SrcIP.String()))
					_, _ = hash.Write([]byte{0})
				}
				_, _ = hash.Write([]byte(strings.ToLower(m.String())))
			}
			key = hash.Sum64()
		}
		key %= p.ends[len(p.ends)-1]
		return p.proxies[sort.Search(len(p.ends), func(i int) bool { return p.ends[i] > key })]
	default:
		return p.proxies[0]
	}
}

func (r *strategyRuntime) pick(metadata *C.Metadata, udp, touch bool) C.Proxy {
	snapshot := r.snapshot.Load()
	if snapshot == nil {
		return nil
	}
	if pin := r.pinned.Load(); pin != nil {
		eligible := snapshot.eligibleTCP
		if udp {
			eligible = snapshot.eligibleUDP
		}
		if p := eligible[*pin]; p != nil {
			return p
		}
	}
	if udp {
		return snapshot.udp.pick(metadata, touch, &r.sequence)
	}
	return snapshot.tcp.pick(metadata, touch, &r.sequence)
}

func (g *scriptedGroup) Unwrap(m *C.Metadata, touch bool) C.Proxy {
	if r := g.state.Load(); r != nil {
		return r.pick(m, m != nil && m.NetWork == C.UDP, false)
	}
	return g.ProxyGroup.Unwrap(m, touch)
}

func (g *scriptedGroup) IsL3Protocol(m *C.Metadata) bool {
	if r := g.state.Load(); r != nil {
		p := r.pick(m, m != nil && m.NetWork == C.UDP, false)
		return p != nil && p.IsL3Protocol(m)
	}
	return g.ProxyGroup.IsL3Protocol(m)
}

func (g *scriptedGroup) SupportUDP() bool {
	// An unavailable scripted group still owns its matched rule. Otherwise
	// mihomo may skip the rule and route the packet through DIRECT.
	return g.state.Load() != nil || g.ProxyGroup.SupportUDP()
}

func strategyMemberSupportsUDP(proxy C.Proxy) bool {
	if g := scriptedGroupOf(proxy); g != nil {
		if r := g.state.Load(); r != nil {
			snapshot := r.snapshot.Load()
			return !g.disableUDP && snapshot != nil && len(snapshot.udp.proxies) > 0
		}
	}
	return proxy.SupportUDP()
}

func (g *scriptedGroup) DialContext(ctx context.Context, m *C.Metadata) (C.Conn, error) {
	r := g.state.Load()
	if r == nil {
		return g.ProxyGroup.DialContext(ctx, m)
	}
	g.Touch()
	p := r.pick(m, false, true)
	if p == nil {
		return nil, errStrategyEmpty
	}
	conn, err := p.DialContext(ctx, m)
	if err != nil {
		g.noteFailure(r, p, err, &r.tcp)
		return conn, err
	}
	conn.AppendToChains(g)
	if N.NeedHandshake(conn) {
		return callback.NewFirstWriteCallBackConn(conn, func(err error) {
			g.noteFailure(r, p, err, &r.tcp)
		}), nil
	}
	g.noteFailure(r, p, nil, &r.tcp)
	return conn, nil
}

func (g *scriptedGroup) ListenPacketContext(ctx context.Context, m *C.Metadata) (C.PacketConn, error) {
	r := g.state.Load()
	if r == nil {
		return g.ProxyGroup.ListenPacketContext(ctx, m)
	}
	if g.disableUDP {
		return nil, errStrategyEmpty
	}
	g.Touch()
	p := r.pick(m, true, true)
	if p == nil {
		return nil, errStrategyEmpty
	}
	conn, err := p.ListenPacketContext(ctx, m)
	g.noteFailure(r, p, err, &r.udp)
	if err == nil {
		conn.AppendToChains(g)
	}
	return conn, err
}

func (g *scriptedGroup) noteFailure(r *strategyRuntime, p C.Proxy, err error, history *strategyHistory) {
	if r.note(p, err, history) {
		g.refreshRuntime(r)
	}
}

func (r *strategyRuntime) note(p C.Proxy, err error, history *strategyHistory) bool {
	if errors.Is(err, context.Canceled) {
		return false
	}
	r.mu.Lock()
	defer r.mu.Unlock()
	if err == nil {
		delete(history.failed, p)
		return false
	}
	if history.failed == nil {
		history.failed = make(map[C.Proxy]time.Time)
	}
	if len(history.failed) >= 4096 || !history.failed[p].IsZero() {
		return false
	}
	history.failed[p] = time.Now()
	return true
}

func (g *scriptedGroup) Now() string {
	if r := g.state.Load(); r != nil {
		return r.selected()
	}
	return g.ProxyGroup.Now()
}

func (r *strategyRuntime) selected() string {
	snapshot := r.snapshot.Load()
	if snapshot == nil {
		return ""
	}
	if pin := r.pinned.Load(); pin != nil && snapshot.eligibleTCP[*pin] != nil {
		return *pin
	}
	switch snapshot.tcp.kind {
	case "round-robin", "weighted", "sticky", "sticky-session":
		// The pick changes with every connection, so no single member is
		// the group's current server.
		return ""
	}
	if len(snapshot.tcp.proxies) > 0 {
		return snapshot.tcp.proxies[0].Name()
	}
	return ""
}

func (g *scriptedGroup) GetProxies(touch bool) []C.Proxy {
	if touch {
		g.Touch()
	}
	return g.Proxies()
}

func (g *scriptedGroup) runtimeGroup() *scriptedGroup { return g }

func (g *scriptedSelector) Set(name string) error {
	r := g.state.Load()
	if r != nil {
		snapshot := r.snapshot.Load()
		if snapshot == nil || snapshot.eligibleTCP[name] == nil && snapshot.eligibleUDP[name] == nil {
			return errors.New("server is outside the available strategy pool")
		}
	}
	g.selectionMu.Lock()
	err := g.SelectAble.Set(name)
	g.selectionMu.Unlock()
	if err != nil {
		return err
	}
	if r != nil {
		r.pinned.Store(&name)
	}
	g.refresh()
	return nil
}

func (g *scriptedSelector) ForceSet(name string) {
	g.selectionMu.Lock()
	g.SelectAble.ForceSet(name)
	g.selectionMu.Unlock()
	if r := g.state.Load(); r != nil {
		if name == "" {
			r.pinned.Store(nil)
		} else {
			// A remembered pick is the user's, so it pins a fresh runtime
			// the same way a tap does; the pick step ignores an ineligible
			// name, so a stale one cannot break the pool.
			r.pinned.Store(&name)
		}
	}
	g.refresh()
}

func (g *scriptedGroup) refresh() {
	if r := g.state.Load(); r != nil {
		g.refreshRuntime(r)
	}
}

func (g *scriptedGroup) refreshRuntime(r *strategyRuntime) {
	r.mu.Lock()
	defer r.mu.Unlock()

	now := time.Now()
	g.selectionMu.Lock()
	selected := g.ProxyGroup.Now()
	g.selectionMu.Unlock()
	for _, history := range []*strategyHistory{&r.tcp, &r.udp} {
		maps.DeleteFunc(history.failed, func(_ C.Proxy, at time.Time) bool { return now.Sub(at) >= 30*time.Second })
	}
	tcp := make([][]strategyCandidate, len(r.policy.Levels))
	udp := make([][]strategyCandidate, len(r.policy.Levels))
	eligibleTCP, eligibleUDP := make(map[string]C.Proxy), make(map[string]C.Proxy)
	for _, p := range g.Proxies() {
		name := p.Name()
		country := rcx.CountryOfName(name)
		if !r.policy.Exclude.Empty() && r.policy.Exclude.Matches(name, country) {
			continue
		}
		for index, level := range r.policy.Levels {
			if !strategyMemberAllowed(g.Name(), p, level) || !level.Match.Matches(name, country) {
				continue
			}
			manual := level.Pick == "manual"
			if !manual && !p.AliveForTestUrl(r.url) {
				continue
			}
			candidate := strategyCandidate{proxy: p, delay: p.LastDelayForTestUrl(r.url)}
			picked := !manual || selected == name
			if manual || r.tcp.failed[p].IsZero() {
				eligibleTCP[name] = p
				if picked {
					tcp[index] = append(tcp[index], candidate)
				}
			}
			if !g.disableUDP && strategyMemberSupportsUDP(p) && (manual || r.udp.failed[p].IsZero()) {
				eligibleUDP[name] = p
				if picked {
					udp[index] = append(udp[index], candidate)
				}
			}
		}
	}
	r.snapshot.Store(&strategySnapshot{
		tcp: r.tcp.resolve(now, r.policy.Levels, tcp), udp: r.udp.resolve(now, r.policy.Levels, udp), eligibleTCP: eligibleTCP, eligibleUDP: eligibleUDP,
	})
}

func (h *strategyHistory) resolve(now time.Time, levels []rcx.StrategyLevel, candidates [][]strategyCandidate) strategyPool {
	if len(h.healthy) != len(levels) {
		h.level, h.healthy = -1, make([]time.Time, len(levels))
	}
	for i, level := range candidates {
		if len(level) == 0 {
			h.healthy[i] = time.Time{}
		} else if h.healthy[i].IsZero() {
			h.healthy[i] = now
		}
	}
	for i, list := range candidates {
		if len(list) == 0 {
			continue
		}
		level := levels[i]
		if h.level >= 0 && i < h.level && len(candidates[h.level]) > 0 && now.Sub(h.healthy[i]) < level.ReturnAfter {
			continue
		}
		h.level = i
		pool := makeStrategyPool(level, list, h.current)
		h.current = pool.proxies[0].Name()
		return pool
	}
	h.level, h.current = -1, ""
	return strategyPool{}
}

func makeStrategyPool(level rcx.StrategyLevel, candidates []strategyCandidate, current string) strategyPool {
	best := 0
	previous := slices.IndexFunc(candidates, func(c strategyCandidate) bool { return c.proxy.Name() == current })
	switch level.Pick {
	case "hold", "latency":
		for i, c := range candidates {
			if c.delay < candidates[best].delay {
				best = i
			}
		}
		if previous >= 0 && (level.Pick == "hold" || int(candidates[previous].delay) <= int(candidates[best].delay)+level.Tolerance) {
			best = previous
		}
	case "weighted", "round-robin", "sticky", "sticky-session":
		if level.Pick == "sticky" || level.Pick == "sticky-session" {
			slices.SortFunc(candidates, func(a, b strategyCandidate) int { return strings.Compare(a.proxy.Name(), b.proxy.Name()) })
		}
		pool := strategyPool{kind: level.Pick, proxies: make([]C.Proxy, 0, len(candidates)), ends: make([]uint64, 0, len(candidates))}
		var total uint64
		for _, candidate := range candidates {
			total += uint64(max(1, level.Weights[candidate.proxy.Name()]))
			pool.proxies = append(pool.proxies, candidate.proxy)
			pool.ends = append(pool.ends, total)
		}
		return pool
	}
	return strategyPool{proxies: []C.Proxy{candidates[best].proxy}}
}

// strategyGroupList names every group whose selection a strategy owns, so
// the routing engine leaves their bindings alone.
func strategyGroupList(proxies map[string]C.Proxy) []string {
	var names []string
	for name, proxy := range proxies {
		if group := scriptedGroupOf(proxy); group != nil && group.state.Load() != nil {
			names = append(names, name)
		}
	}
	slices.Sort(names)
	return names
}

func scriptedGroupOf(p C.Proxy) *scriptedGroup {
	if wrapper, ok := adapterAs[interface{ runtimeGroup() *scriptedGroup }](p); ok {
		return wrapper.runtimeGroup()
	}
	return nil
}

func attachScriptedGroups(cfg *config.Config, disableUDP map[string]bool) {
	for _, p := range cfg.Proxies {
		outer, ok := p.(*adapter.Proxy)
		if !ok || !isProxyGroupType(p.Type()) {
			continue
		}
		base, ok := p.Adapter().(outboundgroup.ProxyGroup)
		if !ok {
			continue
		}
		wrapper := &scriptedGroup{ProxyGroup: base, disableUDP: disableUDP[p.Name()]}
		if selectable, ok := base.(outboundgroup.SelectAble); ok {
			outer.ProxyAdapter = &scriptedSelector{scriptedGroup: wrapper, SelectAble: selectable}
		} else {
			outer.ProxyAdapter = wrapper
		}
	}
}

func resolveGroupStrategies(proxies map[string]C.Proxy, provider map[string]string, user rcx.UserLayer, invalid map[string]rcx.StrategyReport) map[string]rcx.StrategyReport {
	report := make(map[string]rcx.StrategyReport)
	// The registry still belongs to the config being replaced, so a manual
	// pin survives the apply that recreates the group.
	previous := liveStrategyRegistry()
	applied := make(map[string]string)
	for name, source := range provider {
		applied[name] = source
	}
	maps.Copy(applied, user.Strategies)
	for name, proxy := range proxies {
		g := scriptedGroupOf(proxy)
		if g == nil {
			continue
		}
		source, ok := applied[name]
		delete(applied, name)
		_, local := user.Strategies[name]
		if _, blocked := invalid[name]; blocked {
			source, ok = provider[name]
			local = false
		}
		if !ok || source == "" {
			g.state.Store(nil)
			continue
		}
		if err := validateStrategyGroup(name); err != nil {
			g.state.Store(nil)
			report[name] = rcx.StrategyReport{Issue: err.Error()}
			continue
		}
		if prior := g.state.Load(); prior != nil && prior.source == source && prior.local == local {
			continue
		}
		policy, err := strategyForProxy(source, proxy)
		if err != nil {
			g.state.Store(nil)
			report[name] = rcx.StrategyReport{Issue: err.Error()}
			continue
		}
		url := C.DefaultTestURL
		if data, err := g.ProxyGroup.MarshalJSON(); err == nil {
			var base struct {
				TestURL string `json:"testUrl"`
			}
			if json.Unmarshal(data, &base) == nil && base.TestURL != "" {
				url = base.TestURL
			}
		}
		runtime := &strategyRuntime{source: source, policy: policy, local: local, url: url}
		if previous != nil {
			if prior := scriptedGroupOf(previous.proxies[name]); prior != nil {
				if old := prior.state.Load(); old != nil {
					runtime.pinned.Store(old.pinned.Load())
				}
			}
		}
		g.refreshRuntime(runtime)
		g.state.Store(runtime)
	}
	for name, source := range applied {
		if source != "" {
			report[name] = rcx.StrategyReport{Issue: "group is missing or unsupported"}
		}
	}
	return report
}

type strategyRegistry struct {
	anchor   P.ProxyProvider
	proxies  map[string]C.Proxy
	issues   map[string]rcx.StrategyReport
	provider map[string]string
	running  bool
}

var currentStrategyRegistry atomic.Pointer[strategyRegistry]
var strategyUpdateMu sync.Mutex
var strategyWorkerRunning bool

func useGroupStrategies(proxies map[string]C.Proxy, anchor P.ProxyProvider, subscription rcx.SubscriptionLayer, user rcx.UserLayer, localIssues map[string]rcx.StrategyReport) {
	issues := resolveGroupStrategies(proxies, subscription.Strategies, user, localIssues)
	maps.Copy(issues, subscription.StrategyIssues)
	maps.Copy(issues, localIssues)
	running := false
	for _, proxy := range proxies {
		if g := scriptedGroupOf(proxy); g != nil && g.state.Load() != nil {
			running = true
			break
		}
	}
	currentStrategyRegistry.Store(&strategyRegistry{
		anchor: anchor, proxies: proxies, issues: issues,
		provider: subscription.Strategies, running: running,
	})
	if !running {
		return
	}
	strategyUpdateMu.Lock()
	if !strategyWorkerRunning {
		strategyWorkerRunning = true
		safeGo("refreshGroupStrategies", refreshGroupStrategies)
	}
	strategyUpdateMu.Unlock()
}

func refreshGroupStrategies() {
	ticker := time.NewTicker(time.Second)
	defer ticker.Stop()
	for range ticker.C {
		strategyUpdateMu.Lock()
		registry := currentStrategyRegistry.Load()
		if registry == nil || !registry.running {
			strategyWorkerRunning = false
			strategyUpdateMu.Unlock()
			return
		}
		strategyUpdateMu.Unlock()
		if !isRunning.Load() {
			continue
		}
		if registry != liveStrategyRegistry() {
			// The installed config replaced this one; a later apply starts a
			// worker for its own registry.
			strategyUpdateMu.Lock()
			if currentStrategyRegistry.Load() == registry {
				currentStrategyRegistry.Store(nil)
			}
			strategyUpdateMu.Unlock()
			continue
		}
		changed := false
		for _, proxy := range registry.proxies {
			if group := scriptedGroupOf(proxy); group != nil {
				if r := group.state.Load(); r != nil {
					before := r.pick(nil, false, false) == nil
					selected := r.selected()
					group.refreshRuntime(r)
					changed = changed || before != (r.pick(nil, false, false) == nil) || selected != r.selected()
				}
			}
		}
		if changed && registry == liveStrategyRegistry() {
			if engine := rcxIfReady(); engine != nil {
				rcxHost{}.Publish(engine.Status())
			}
		}
	}
}

func liveStrategyRegistry() *strategyRegistry {
	registry := currentStrategyRegistry.Load()
	if registry != nil && registry.anchor != nil && tunnel.ProvidersSnapshot()[provider.ReservedName] == registry.anchor {
		return registry
	}
	return nil
}

func strategyReports(registry *strategyRegistry) map[string]rcx.StrategyReport {
	if registry == nil {
		return nil
	}
	reports := maps.Clone(registry.issues)
	for name := range registry.provider {
		report := reports[name]
		report.Offered = true
		reports[name] = report
	}
	for name, proxy := range registry.proxies {
		if g := scriptedGroupOf(proxy); g != nil {
			if r := g.state.Load(); r != nil {
				report := reports[name]
				if report.Issue == "" {
					report.Source = "provider"
				}
				if r.local && report.Issue == "" {
					report.Source = "user"
				}
				if snapshot := r.snapshot.Load(); snapshot != nil {
					report.Selected = r.selected()
					report.Empty = len(snapshot.tcp.proxies) == 0
				}
				reports[name] = report
			}
		}
	}
	return reports
}

func validateChangedStrategies(previous, layer rcx.UserLayer) error {
	if !maps.EqualFunc(previous.LocalGroups, layer.LocalGroups, sameLocalGroup) {
		return errors.New("changing local groups needs a full profile apply")
	}
	if maps.Equal(previous.Strategies, layer.Strategies) {
		return nil
	}
	registry := liveStrategyRegistry()
	if registry == nil {
		return errors.New("the applied configuration no longer supports connection strategies")
	}
	for name, source := range layer.Strategies {
		if source == "" || previous.Strategies[name] == source {
			continue
		}
		if err := validateStrategyGroup(name); err != nil {
			return err
		}
		proxy := registry.proxies[name]
		if scriptedGroupOf(proxy) == nil {
			return fmt.Errorf("group %q is missing or unsupported", name)
		}
		if _, err := strategyForProxy(source, proxy); err != nil {
			return fmt.Errorf("group %q: %w", name, err)
		}
	}
	return nil
}

func updateLiveGroupStrategies(layer rcx.UserLayer) {
	if currentConfig == nil {
		return
	}
	registry := liveStrategyRegistry()
	if registry == nil {
		return
	}
	localIssues := make(map[string]rcx.StrategyReport)
	for name := range layer.LocalGroups {
		if issue, exists := registry.issues[name]; exists {
			localIssues[name] = issue
		}
	}
	rcxMu.Lock()
	subscription := rcxSubscription
	rcxMu.Unlock()
	useGroupStrategies(registry.proxies, registry.anchor, subscription, layer, localIssues)
}

func withStrategyReports(status rcx.Status) rcx.Status {
	registry := liveStrategyRegistry()
	status.StrategySupport = registry != nil
	status.Strategies = strategyReports(registry)
	return status
}

func validateStrategyGroup(name string) error {
	if slices.Contains(builtinTargets, name) {
		return fmt.Errorf("%s cannot carry a strategy", name)
	}
	return nil
}

func validateLocalStrategyGroup(name string, spec rcx.LocalStrategyGroup) error {
	if len(name) == 0 || len(name) > 64 || strings.TrimSpace(name) != name ||
		strings.ContainsAny(name, ",\r\n\t\x00") || slices.Contains(builtinTargets, name) {
		return errors.New("invalid group name")
	}
	if !spec.IncludeAll && len(spec.Members)+len(spec.Providers) == 0 || len(spec.Members)+len(spec.Providers) > 1024 {
		return errors.New("a group needs between 1 and 1024 members or proxy providers")
	}
	if slices.Contains(spec.Members, name) {
		return errors.New("a group cannot contain itself")
	}
	return nil
}

func injectStrategyGroups(raw *config.RawConfig, user rcx.UserLayer) (*config.RawConfig, map[string]rcx.StrategyReport) {
	issues := make(map[string]rcx.StrategyReport)
	if len(user.LocalGroups) == 0 {
		return raw, issues
	}
	out := cloneRaw(raw)
	taken := make(map[string]bool)
	for _, mappings := range [][]map[string]any{raw.Proxy, raw.ProxyGroup} {
		for _, mapping := range mappings {
			if name, ok := mapping["name"].(string); ok {
				taken[name] = true
			}
		}
	}
	known := maps.Clone(taken)
	for _, name := range builtinTargets {
		known[name] = true
	}
	valid := make(map[string]rcx.LocalStrategyGroup)
	for i, name := range slices.Sorted(maps.Keys(user.LocalGroups)) {
		spec := user.LocalGroups[name]
		err := validateLocalStrategyGroup(name, spec)
		switch {
		case i >= rcx.MaxStrategies:
			err = errors.New("too many local groups")
		case taken[name]:
			err = errors.New("group name is already in use")
		}
		if err == nil {
			_, err = rcx.ParseStrategy(user.Strategies[name])
		}
		if err != nil {
			issues[name] = rcx.StrategyReport{Issue: err.Error()}
			continue
		}
		valid[name] = spec
		// Groups are parsed in this order, so a member may name only a group
		// that comes before it.
		known[name] = true
	}
	for _, name := range slices.Sorted(maps.Keys(valid)) {
		spec := valid[name]
		members := slices.DeleteFunc(slices.Clone(spec.Members), func(member string) bool {
			return !known[member]
		})
		providers := slices.DeleteFunc(slices.Clone(spec.Providers), func(name string) bool {
			_, exists := raw.ProxyProvider[name]
			return !exists
		})
		if !spec.IncludeAll && len(members)+len(providers) == 0 {
			members = []string{"COMPATIBLE"}
		}
		out.ProxyGroup = append(out.ProxyGroup, map[string]any{
			"name": name, "type": "select", "proxies": members, "use": providers, "include-all": spec.IncludeAll,
		})
	}
	return out, issues
}

func groupCanReach(proxy C.Proxy, target string, seen map[string]bool) bool {
	if proxy == nil || seen[proxy.Name()] {
		return false
	}
	if proxy.Name() == target {
		return true
	}
	seen[proxy.Name()] = true
	group, ok := proxyGroupOf(proxy)
	return ok && slices.ContainsFunc(group.Proxies(), func(member C.Proxy) bool {
		return groupCanReach(member, target, seen)
	})
}

func strategyStudio(req rcx.StudioRequest) rcx.StudioResult {
	failure := func(err error) rcx.StudioResult {
		return rcx.StudioResult{Errors: []rcx.Issue{{Message: err.Error()}}}
	}
	proxies := tunnel.AllProxies()
	if req.Op == "source" {
		if g := scriptedGroupOf(proxies[req.Group]); g != nil {
			if r := g.state.Load(); r != nil {
				return rcx.StudioResult{Text: r.source}
			}
		}
		return rcx.StudioResult{}
	}
	if req.Op != "lint" {
		return failure(errors.New("unknown strategy operation"))
	}
	if req.LocalGroup == nil {
		if err := validateStrategyGroup(req.Group); err != nil {
			return failure(err)
		}
	}
	strategy, err := rcx.ParseStrategy(req.Text)
	if err != nil {
		return failure(err)
	}
	var members []C.Proxy
	if spec := req.LocalGroup; spec != nil {
		if req.Create && proxies[req.Group] != nil {
			return failure(errors.New("group name is already in use"))
		}
		if err := validateLocalStrategyGroup(req.Group, *spec); err != nil {
			return failure(err)
		}
		for _, name := range spec.Members {
			proxy := proxies[name]
			if proxy == nil {
				return failure(fmt.Errorf("unknown member %q", name))
			}
			if groupCanReach(proxy, req.Group, make(map[string]bool)) {
				return failure(fmt.Errorf("member %q would form a group cycle", name))
			}
			members = append(members, proxy)
		}
		providers := tunnel.Providers()
		if spec.IncludeAll {
			for _, name := range slices.Sorted(maps.Keys(proxies)) {
				if proxy := proxies[name]; !isProxyGroupType(proxy.Type()) {
					members = append(members, proxy)
				}
			}
			for _, name := range slices.Sorted(maps.Keys(providers)) {
				pd := providers[name]
				if name != provider.ReservedName && pd.VehicleType() != P.Compatible {
					members = append(members, pd.Proxies()...)
				}
			}
		}
		for _, name := range spec.Providers {
			pd := providers[name]
			if pd == nil || pd.Name() == provider.ReservedName {
				return failure(fmt.Errorf("unknown proxy provider %q", name))
			}
			members = append(members, pd.Proxies()...)
		}
	} else if g := scriptedGroupOf(proxies[req.Group]); g != nil {
		if _, selectable := proxies[req.Group].Adapter().(outboundgroup.SelectAble); !selectable && needsManualPick(strategy) {
			return failure(errors.New("manual pick needs a selectable base group"))
		}
		members = g.Proxies()
	} else if req.Group != "" {
		return failure(errors.New("core does not support strategies on this group"))
	}
	levels := make([][]string, len(strategy.Levels))
	for i, level := range strategy.Levels {
		seen := make(map[string]bool)
		for _, member := range members {
			name := member.Name()
			if seen[name] || !strategyMemberAllowed(req.Group, member, level) {
				continue
			}
			country := rcx.CountryOfName(name)
			if (strategy.Exclude.Empty() || !strategy.Exclude.Matches(name, country)) && level.Match.Matches(name, country) {
				seen[name] = true
				levels[i] = append(levels[i], name)
			}
		}
	}
	return rcx.StudioResult{StrategyLevels: levels}
}

func strategyMemberAllowed(group string, proxy C.Proxy, level rcx.StrategyLevel) bool {
	name := proxy.Name()
	if name == "DNS" || name == "PASS-RULE" {
		return false
	}
	if proxy.Type() == C.Direct {
		return slices.Contains(level.Match.Members, name)
	}
	return name != group && !slices.Contains(builtinTargets, name)
}

func needsManualPick(policy *rcx.Strategy) bool {
	return slices.ContainsFunc(policy.Levels, func(level rcx.StrategyLevel) bool {
		return level.Pick == "manual"
	})
}

func sameLocalGroup(a, b rcx.LocalStrategyGroup) bool {
	return a.IncludeAll == b.IncludeAll && slices.Equal(a.Members, b.Members) && slices.Equal(a.Providers, b.Providers)
}

func strategyForProxy(source string, proxy C.Proxy) (*rcx.Strategy, error) {
	policy, err := rcx.ParseStrategy(source)
	if err != nil {
		return nil, err
	}
	if _, selectable := proxy.Adapter().(outboundgroup.SelectAble); !selectable && needsManualPick(policy) {
		return nil, errors.New("manual pick needs a selectable base group")
	}
	return policy, nil
}
