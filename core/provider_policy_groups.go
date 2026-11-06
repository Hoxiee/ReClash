package core

import (
	"errors"
	"fmt"
	"slices"
	"strings"
	"time"

	"github.com/dlclark/regexp2"
	"github.com/metacubex/mihomo/adapter"
	"github.com/metacubex/mihomo/adapter/outboundgroup"
	"github.com/metacubex/mihomo/common/structure"
	"github.com/metacubex/mihomo/config"
	C "github.com/metacubex/mihomo/constant"
)

const (
	groupFilterMatchTimeout = time.Second
	groupFilterBudget       = 3 * time.Second
	maxGroupFilterLength    = 4096
)

// Mihomo reads a regexp2 timeout as "no match", so this bounds every pattern a
// profile can bring, including group filters over remote provider names.
func init() {
	regexp2.DefaultMatchTimeout = groupFilterMatchTimeout
}

var groupAdapterTypes = map[string]C.AdapterType{
	"select":       C.Selector,
	"url-test":     C.URLTest,
	"fallback":     C.Fallback,
	"load-balance": C.LoadBalance,
}

// groupResolver answers which members mihomo gives a proxy group from the
// body alone. The order follows ParseProxyGroup and GroupBase.GetProxies:
// `filter` only narrows include-all-proxies, while the exclude options apply
// to every member and an emptied group falls back to `empty-fallback`.
type groupResolver struct {
	decoder          *structure.Decoder
	groups           map[string]map[string]any
	nodes            map[string]map[string]any
	inline           []string
	patterns         map[string][]*regexp2.Regexp
	deadline         time.Time
	bodyHasProviders bool
}

func newGroupResolver(raw *config.RawConfig) *groupResolver {
	resolver := &groupResolver{
		decoder:          structure.NewDecoder(structure.Option{TagName: "group", WeaklyTypedInput: true}),
		groups:           make(map[string]map[string]any, len(raw.ProxyGroup)),
		nodes:            make(map[string]map[string]any, len(raw.Proxy)),
		patterns:         map[string][]*regexp2.Regexp{},
		deadline:         time.Now().Add(groupFilterBudget),
		bodyHasProviders: len(raw.ProxyProvider) != 0,
	}
	for _, group := range raw.ProxyGroup {
		if name, ok := group["name"].(string); ok {
			if _, dup := resolver.groups[name]; !dup {
				resolver.groups[name] = group
			}
		}
	}
	names := structure.NewDecoder(structure.Option{TagName: "proxy", WeaklyTypedInput: true})
	for _, node := range raw.Proxy {
		var named struct {
			Name string `proxy:"name,omitempty"`
		}
		if names.Decode(node, &named) != nil || named.Name == "" {
			continue
		}
		if _, dup := resolver.nodes[named.Name]; !dup {
			resolver.nodes[named.Name] = node
			resolver.inline = append(resolver.inline, named.Name)
		}
	}
	slices.Sort(resolver.inline)
	return resolver
}

func (r *groupResolver) compile(filter string) ([]*regexp2.Regexp, error) {
	if compiled, ok := r.patterns[filter]; ok {
		return compiled, nil
	}
	if len(filter) > maxGroupFilterLength {
		return nil, errors.New("pattern is too long")
	}
	var compiled []*regexp2.Regexp
	for _, part := range strings.Split(filter, "`") {
		pattern, err := regexp2.Compile(part, regexp2.None)
		if err != nil {
			return nil, err
		}
		compiled = append(compiled, pattern)
	}
	r.patterns[filter] = compiled
	return compiled, nil
}

// Unlike mihomo, a timeout is an error here: "no match" would silently change
// what the group contains.
func (r *groupResolver) matches(patterns []*regexp2.Regexp, name string) (bool, error) {
	if time.Now().After(r.deadline) {
		return false, errors.New("pattern is too slow")
	}
	for _, pattern := range patterns {
		matched, err := pattern.MatchString(name)
		if err != nil {
			return false, errors.New("pattern is too slow")
		}
		if matched {
			return true, nil
		}
	}
	return false, nil
}

func (r *groupResolver) filtered(group map[string]any) ([]string, outboundgroup.GroupCommonOption, error) {
	option := outboundgroup.GroupCommonOption{}
	if err := r.decoder.Decode(group, &option); err != nil {
		return nil, option, err
	}
	// Mihomo compiles both options for every group, even where `filter` has
	// nothing to narrow.
	include, err := r.compile(option.Filter)
	if err != nil {
		return nil, option, fmt.Errorf("invalid filter: %w", err)
	}
	exclude, err := r.compile(option.ExcludeFilter)
	if err != nil {
		return nil, option, fmt.Errorf("invalid exclude-filter: %w", err)
	}
	members := slices.Clone(option.Proxies)
	if option.IncludeAll || option.IncludeAllProxies {
		for _, name := range r.inline {
			matched := option.Filter == ""
			if !matched {
				if matched, err = r.matches(include, name); err != nil {
					return nil, option, fmt.Errorf("invalid filter: %w", err)
				}
			}
			if matched {
				members = append(members, name)
			}
		}
	}
	if option.ExcludeFilter == "" {
		return members, option, nil
	}
	kept := members[:0]
	for _, name := range members {
		matched, err := r.matches(exclude, name)
		if err != nil {
			return nil, option, fmt.Errorf("invalid exclude-filter: %w", err)
		}
		if !matched {
			kept = append(kept, name)
		}
	}
	return kept, option, nil
}

func (r *groupResolver) memberType(name string) (string, error) {
	if group, ok := r.groups[name]; ok {
		kind, _ := group["type"].(string)
		return groupAdapterTypes[kind].String(), nil
	}
	if node, ok := r.nodes[name]; ok {
		proxy, err := adapter.ParseProxy(node)
		if err != nil {
			return "", err
		}
		return proxy.Type().String(), nil
	}
	return "", nil
}

func (r *groupResolver) members(name string) ([]string, error) {
	members, option, err := r.filtered(r.groups[name])
	if err != nil {
		return nil, fmt.Errorf("proxy group %q: %w", name, err)
	}
	if option.ExcludeType != "" {
		excluded := strings.Split(option.ExcludeType, "|")
		kept := members[:0]
		for _, member := range members {
			kind, err := r.memberType(member)
			if err != nil {
				return nil, fmt.Errorf("proxy group %q: %w", name, err)
			}
			if !slices.ContainsFunc(excluded, func(text string) bool { return strings.EqualFold(text, kind) }) {
				kept = append(kept, member)
			}
		}
		members = kept
	}
	// With a provider in the group, the fallback depends on what it serves at
	// runtime, which the body cannot say, so the node stays denied.
	providers := len(option.Use) != 0 ||
		(option.IncludeAll || option.IncludeAllProviders) && r.bodyHasProviders
	if len(members) == 0 && !providers && option.EmptyFallback != "" {
		members = []string{option.EmptyFallback}
	}
	return members, nil
}

// checkGroupFilters refuses what mihomo would panic on or spend minutes in:
// GroupBase compiles with regexp2.MustCompile, and a per-match timeout alone
// still allows one timeout per node.
func checkGroupFilters(raw *config.RawConfig) error {
	var resolver *groupResolver
	for _, group := range raw.ProxyGroup {
		_, hasFilter := group["filter"]
		_, hasExclude := group["exclude-filter"]
		name, named := group["name"].(string)
		if !named || !hasFilter && !hasExclude {
			continue
		}
		if resolver == nil {
			resolver = newGroupResolver(raw)
		}
		if _, _, err := resolver.filtered(group); err != nil {
			return fmt.Errorf("proxy group %q: %w", name, err)
		}
	}
	return nil
}

func parseRawConfig(raw *config.RawConfig) (*config.Config, error) {
	if err := checkGroupFilters(raw); err != nil {
		return nil, err
	}
	return config.ParseRawConfig(raw)
}
