package core

import (
	"encoding/json"
	"errors"
	"maps"
	"strings"
	"sync"

	"core/extensions"

	"github.com/metacubex/mihomo/adapter"
	"github.com/metacubex/mihomo/adapter/outboundgroup"
	"github.com/metacubex/mihomo/adapter/provider"
	"github.com/metacubex/mihomo/common/convert"
	"github.com/metacubex/mihomo/config"
	"github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/log"
	"github.com/metacubex/mihomo/tunnel"
)

const globalProxyName = "GLOBAL"

var (
	// Selection writes need the mutual exclusion mihomo's Selector.Set lacks.
	// The lock order is configMu -> selectMu.
	selectMu sync.Mutex

	errGroupNotFound    = errors.New("Not found group")
	errGroupInvalidType = errors.New("Group has invalid proxy type")
	errGroupNotSelect   = errors.New("Group is not selectable")
)

type pickableGroup interface {
	outboundgroup.ProxyGroup
	outboundgroup.SelectAble
}

func lookupProxy(name string) constant.Proxy {
	return tunnel.AllProxies()[name]
}

func adapterAs[T any](proxy constant.Proxy) (group T, ok bool) {
	outbound, ok := proxy.(*adapter.Proxy)
	if !ok {
		return group, false
	}
	group, ok = outbound.ProxyAdapter.(T)
	if !ok {
		if wrapper, wrapped := outbound.ProxyAdapter.(interface{ runtimeGroup() *scriptedGroup }); wrapped {
			base := wrapper.runtimeGroup()
			if base.state.Load() == nil {
				group, ok = base.ProxyGroup.(T)
			}
		}
	}
	return group, ok
}

// proxyGroupOf unwraps a group for checks that must see its members, strategy or not.
func proxyGroupOf(proxy constant.Proxy) (outboundgroup.ProxyGroup, bool) {
	outbound, ok := proxy.(*adapter.Proxy)
	if !ok {
		return nil, false
	}
	if group, ok := outbound.ProxyAdapter.(outboundgroup.ProxyGroup); ok {
		return group, true
	}
	if wrapper, ok := outbound.ProxyAdapter.(interface{ runtimeGroup() *scriptedGroup }); ok && wrapper.runtimeGroup() != nil {
		return wrapper.runtimeGroup().ProxyGroup, true
	}
	return nil, false
}

func isProxyGroupType(adapterType constant.AdapterType) bool {
	switch adapterType {
	case constant.Selector, constant.URLTest, constant.Fallback, constant.Relay, constant.LoadBalance:
		return true
	default:
		return false
	}
}

func proxyGroupNames(
	nameList []string,
	typeOf func(name string) (constant.AdapterType, bool),
) []string {
	isGroup := func(name string) bool {
		adapterType, ok := typeOf(name)
		return ok && isProxyGroupType(adapterType)
	}

	hasGlobal := false
	names := make([]string, 0, len(nameList)+1)
	for _, name := range nameList {
		if name == globalProxyName {
			hasGlobal = true
		}
		if isGroup(name) {
			names = append(names, name)
		}
	}
	if !hasGlobal && isGroup(globalProxyName) {
		names = append([]string{globalProxyName}, names...)
	}
	return names
}

func handleGetProxies() ProxiesData {
	proxies := tunnel.AllProxies()

	names := proxyGroupNames(config.GetProxyNameList(), func(name string) (constant.AdapterType, bool) {
		p, ok := proxies[name]
		if !ok || p == nil {
			return 0, false
		}
		return p.Type(), true
	})

	views := make(map[string]any, len(proxies))
	for name, proxy := range proxies {
		views[name] = proxyView(proxy)
	}
	return ProxiesData{All: names, Proxies: views}
}

type annotated interface {
	Annotations() (desc string, favorite bool)
}

// Proxy.MarshalJSON encodes each node twice, with history the host never reads.
func proxyView(proxy constant.Proxy) any {
	node := nodeView{
		Name:         proxy.Name(),
		Type:         proxy.Type().String(),
		ProviderName: proxy.ProxyInfo().ProviderName,
		Extension:    extensions.IDOf(proxy),
	}
	if marked, ok := proxy.(annotated); ok {
		node.Desc, node.Favorite = marked.Annotations()
	}
	if !isProxyGroupType(proxy.Type()) {
		return node
	}
	data, err := proxy.Adapter().MarshalJSON()
	view := map[string]any{}
	if err == nil {
		err = json.Unmarshal(data, &view)
	}
	if err != nil {
		log.Warnln("[APP] encode group %s: %v", node.Name, err)
		return node
	}
	view["name"] = node.Name
	if group := scriptedGroupOf(proxy); group != nil && group.state.Load() != nil {
		view["now"] = group.Now()
		delete(view, "fixed")
	}
	if isBuiltInGlobal(proxy) {
		view["hidden"] = true
	}
	return view
}

// mihomo builds its own GLOBAL over the reserved provider, which no configured
// group can use; a GLOBAL group from the config takes its place.
func isBuiltInGlobal(proxy constant.Proxy) bool {
	group, ok := proxy.Adapter().(outboundgroup.ProxyGroup)
	if !ok || proxy.Name() != globalProxyName {
		return false
	}
	for _, pd := range group.Providers() {
		if pd.Name() == provider.ReservedName {
			return true
		}
	}
	return false
}

func selectableGroup(groupName string) (pickableGroup, error) {
	group := lookupProxy(groupName)
	if group == nil {
		return nil, errGroupNotFound
	}
	adapterProxy, ok := group.(*adapter.Proxy)
	if !ok {
		return nil, errGroupInvalidType
	}
	selector, ok := adapterProxy.ProxyAdapter.(pickableGroup)
	if !ok {
		return nil, errGroupNotSelect
	}
	return selector, nil
}

// A pick the user makes in a smart group pins it; the engine is told after
// selectMu is released, since it takes that lock itself when it selects.
func handleChangeProxy(params *ChangeProxyParams) *ChangeProxyResult {
	result := changeProxy(params)
	if result.Message == "" {
		if e := rcxIfReady(); e != nil {
			if params.ProxyName != "" {
				e.NoteManualPick(rcxPickOf(params.GroupName, params.ProxyName))
			}
			// The engine never notices a strategy group's pick, so publish it here.
			if group := scriptedGroupOf(lookupProxy(params.GroupName)); group != nil && group.state.Load() != nil {
				rcxHost{}.Publish(e.Status())
			}
		}
	}
	return result
}

func changeProxy(params *ChangeProxyParams) *ChangeProxyResult {
	selectMu.Lock()
	defer selectMu.Unlock()

	selector, err := selectableGroup(params.GroupName)
	if err != nil {
		return &ChangeProxyResult{Message: err.Error()}
	}
	if params.GroupName == globalProxyName && params.ProxyName != "" &&
		!providerGlobalCandidate(lookupProxy(params.ProxyName)) {
		return &ChangeProxyResult{Message: "provider policy: this node is not allowed in GLOBAL"}
	}
	before := selector.Now()
	if params.ProxyName == "" {
		selector.ForceSet(params.ProxyName)
	} else if err := selector.Set(params.ProxyName); err != nil {
		return &ChangeProxyResult{Message: err.Error()}
	}
	changed := selector.Now() != before
	refreshRouteLocked(routeUnchanged)
	return &ChangeProxyResult{Changed: changed}
}

func patchSelectGroup(mapping map[string]string) {
	selectMu.Lock()
	defer selectMu.Unlock()
	proxies := tunnel.AllProxies()
	for name, selected := range mapping {
		if forceSetGroup(proxies[name], selected) {
			continue
		}
	}
}

func forceSetGroup(proxy constant.Proxy, name string) bool {
	outbound, ok := proxy.(*adapter.Proxy)
	if !ok {
		return false
	}
	selector, ok := outbound.ProxyAdapter.(interface{ ForceSet(string) })
	if !ok {
		return false
	}
	selector.ForceSet(name)
	return true
}

// Tailscale and EasyTier register a DNS client under the proxy name when built
// and drop that name's entry on Close, so a probe under the real name would
// take the resolver from a running proxy of the same name.
const validationNameSuffix = "\x00validate"

// The per-proxy parser the config load runs; checks across proxies, such as
// duplicate names, are left to the load itself.
func handleValidateProxies(mappings []map[string]any) []string {
	results := make([]string, len(mappings))
	for i, mapping := range mappings {
		name, _ := mapping["name"].(string)
		probe := mapping
		switch mapping["type"] {
		case "tailscale", "easytier":
			probe = maps.Clone(mapping)
			probe["name"] = name + validationNameSuffix
		}
		proxy, err := adapter.ParseProxy(probe)
		if err != nil {
			results[i] = strings.ReplaceAll(err.Error(), validationNameSuffix, "")
			continue
		}
		_ = proxy.Close()
	}
	return results
}

// The share-link list a proxy provider also accepts, plain or base64.
func handleConvertProxies(path string) ([]map[string]any, error) {
	buf, err := readCoreFile(path)
	if err != nil {
		return nil, err
	}
	return convert.ConvertsV2Ray(buf)
}
