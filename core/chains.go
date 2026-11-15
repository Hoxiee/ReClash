package core

import (
	"fmt"
	"io"
	"maps"
	"net"
	"path/filepath"
	"slices"
	"strconv"
	"strings"
	"sync"

	"github.com/dlclark/regexp2"
	"github.com/metacubex/mihomo/adapter/outboundgroup"
	"github.com/metacubex/mihomo/adapter/provider"
	"github.com/metacubex/mihomo/common/convert"
	"github.com/metacubex/mihomo/component/age"
	"github.com/metacubex/mihomo/config"
	C "github.com/metacubex/mihomo/constant"
	P "github.com/metacubex/mihomo/constant/provider"
	"github.com/metacubex/mihomo/tunnel"
	"go.yaml.in/yaml/v3"
)

const (
	chainMissingHop           = "missingHop"
	chainUnchainableHop       = "unchainableHop"
	chainLoop                 = "loop"
	chainEmptyExit            = "emptyExit"
	chainProviderPending      = "providerPending"
	chainUDPTransportMissing  = "udpTransportMissing"
	chainNameClash            = "nameClash"
	chainDialerReplaced       = "dialerReplaced"
	chainUDPLost              = "udpLost"
	chainMainGroupAutomatic   = "mainGroupAutomatic"
	chainMissingTarget        = "missingTarget"
	chainStatusOK             = "ok"
	chainStatusDegraded       = "degraded"
	chainStatusBroken         = "broken"
	chainUDPCarried           = "carried"
	chainUDPLostState         = "lost"
	chainUDPNone              = "none"
	chainCloneSeparator       = " ⟶ "
	chainSiblingSeparator     = "/"
	chainSelectType           = "select"
	chainProviderPathCategory = "proxies"
)

var chainErrorCodes = map[string]bool{
	chainMissingHop:          true,
	chainUnchainableHop:      true,
	chainLoop:                true,
	chainEmptyExit:           true,
	chainUDPTransportMissing: true,
	chainNameClash:           true,
}

var chainBlockingCodes = map[string]bool{
	chainLoop:                true,
	chainUDPTransportMissing: true,
	chainEmptyExit:           true,
	chainProviderPending:     true,
	chainUnchainableHop:      true,
}

var chainBuiltins = []string{"DIRECT", "REJECT", "REJECT-DROP", "PASS", "PASS-RULE", "COMPATIBLE", "GLOBAL"}

var chainUnchainableTypes = map[string]bool{
	"direct": true, "reject": true, "rejectdrop": true, "dns": true, "rematch": true,
	"pass": true, "passrule": true, "compatible": true,
}

var chainGroupSettings = []string{
	"url", "interval", "tolerance", "lazy", "timeout", "max-failed-times", "expected-status", "strategy",
}

var chainSiblingSettings = []string{
	"override", "age-secret-key", "health-check", "payload",
}

type chainLeaf struct {
	name     string
	node     *yaml.Node // nil for a node a running provider serves
	kind     string
	server   string
	port     int
	dialer   string
	udp      bool
	needsUDP bool
}

type chainFilters struct {
	filter, excludeFilter, excludeType string
}

type chainUse struct {
	provider string
	filters  chainFilters
}

type chainHop struct {
	name      string
	group     string
	groupType string
	code      string
	entryOnly bool
	pending   bool
	leaves    []chainLeaf
	uses      []chainUse
	contains  map[string]struct{}
}

type chainIndex struct {
	proxies       map[string]*yaml.Node
	proxyMaps     map[string]map[string]any
	proxyOrder    []string
	groups        map[string]*yaml.Node
	groupMaps     map[string]map[string]any
	groupOrder    []string
	providers     map[string]*yaml.Node
	providerMaps  map[string]map[string]any
	providerOrder []string
	served        map[string][]chainLeaf
	pending       map[string]bool
	resolver      *groupResolver
	hops          map[string]*chainHop
	taken         map[string]struct{}
}

func newChainIndex(root *yaml.Node, served map[string][]chainLeaf, ignored map[string]struct{}) *chainIndex {
	ix := &chainIndex{
		proxies:      map[string]*yaml.Node{},
		proxyMaps:    map[string]map[string]any{},
		groups:       map[string]*yaml.Node{},
		groupMaps:    map[string]map[string]any{},
		providers:    map[string]*yaml.Node{},
		providerMaps: map[string]map[string]any{},
		served:       map[string][]chainLeaf{},
		pending:      map[string]bool{},
		hops:         map[string]*chainHop{},
		taken:        map[string]struct{}{},
	}
	skip := func(name string) bool {
		_, generated := ignored[name]
		return name == "" || generated
	}
	raw := &config.RawConfig{ProxyProvider: map[string]map[string]any{}}
	for _, node := range sequenceItems(mappingValue(root, "proxies")) {
		mapping, name := decodeNamedMapping(node)
		if _, dup := ix.proxyMaps[name]; skip(name) || dup {
			continue
		}
		ix.proxies[name], ix.proxyMaps[name] = node, mapping
		ix.proxyOrder = append(ix.proxyOrder, name)
		raw.Proxy = append(raw.Proxy, mapping)
	}
	for _, node := range sequenceItems(mappingValue(root, "proxy-groups")) {
		mapping, name := decodeNamedMapping(node)
		if _, dup := ix.groupMaps[name]; skip(name) || dup {
			continue
		}
		if len(ignored) > 0 {
			for _, key := range []string{"proxies", "use"} {
				if members, ok := mapping[key].([]any); ok {
					mapping[key] = slices.DeleteFunc(members, func(member any) bool {
						text, _ := member.(string)
						return skip(text)
					})
				}
			}
		}
		ix.groups[name], ix.groupMaps[name] = node, mapping
		ix.groupOrder = append(ix.groupOrder, name)
		raw.ProxyGroup = append(raw.ProxyGroup, mapping)
	}
	if providers := resolveAlias(mappingValue(root, "proxy-providers")); providers != nil && providers.Kind == yaml.MappingNode {
		for i := 0; i+1 < len(providers.Content); i += 2 {
			name, value := providers.Content[i].Value, resolveAlias(providers.Content[i+1])
			var mapping map[string]any
			if _, dup := ix.providerMaps[name]; skip(name) || dup || value.Decode(&mapping) != nil || mapping == nil {
				continue
			}
			ix.providers[name], ix.providerMaps[name] = value, mapping
			ix.providerOrder = append(ix.providerOrder, name)
			raw.ProxyProvider[name] = mapping
			if leaves, read := diskChainLeaves(name, mapping); read {
				ix.served[name] = leaves
			} else if leaves, running := served[name]; running {
				ix.served[name] = leaves
			} else {
				ix.pending[name] = true
			}
		}
	}
	// mihomo hands include-all-providers its provider names sorted.
	slices.Sort(ix.providerOrder)
	ix.resolver = newGroupResolver(raw)
	for _, names := range [][]string{chainBuiltins, ix.proxyOrder, ix.groupOrder, ix.providerOrder} {
		for _, name := range names {
			ix.taken[name] = struct{}{}
		}
	}
	return ix
}

func sequenceItems(node *yaml.Node) []*yaml.Node {
	node = resolveAlias(node)
	if node == nil || node.Kind != yaml.SequenceNode {
		return nil
	}
	items := make([]*yaml.Node, 0, len(node.Content))
	for _, item := range node.Content {
		if item = resolveAlias(item); item.Kind == yaml.MappingNode {
			items = append(items, item)
		}
	}
	return items
}

func decodeNamedMapping(node *yaml.Node) (map[string]any, string) {
	var mapping map[string]any
	if node.Decode(&mapping) != nil {
		return nil, ""
	}
	name, _ := mapping["name"].(string)
	return mapping, name
}

func stringField(mapping map[string]any, key string) string {
	switch value := mapping[key].(type) {
	case string:
		return value
	case nil:
		return ""
	default:
		return fmt.Sprint(value)
	}
}

func boolField(mapping map[string]any, key string) bool {
	switch value := mapping[key].(type) {
	case bool:
		return value
	case string:
		parsed, _ := strconv.ParseBool(value)
		return parsed
	}
	return false
}

func intField(mapping map[string]any, key string) int {
	switch value := mapping[key].(type) {
	case int:
		return value
	case float64:
		return int(value)
	case string:
		parsed, _ := strconv.Atoi(value)
		return parsed
	}
	return 0
}

func (ix *chainIndex) leaf(name string) chainLeaf {
	mapping := ix.proxyMaps[name]
	kind := strings.ToLower(stringField(mapping, "type"))
	leaf := chainLeaf{
		name:     name,
		node:     ix.proxies[name],
		kind:     kind,
		server:   stringField(mapping, "server"),
		port:     intField(mapping, "port"),
		dialer:   stringField(mapping, "dialer-proxy"),
		needsUDP: needsUDPTransport(kind, mapping),
	}
	switch kind {
	case "hysteria", "hysteria2", "tuic", "shadowquic", "sudoku", "openvpn":
		leaf.udp = true
	case "http", "ssh":
	default:
		leaf.udp = boolField(mapping, "udp")
	}
	return leaf
}

// needsUDPTransport is whether the node reaches its own server over UDP, so
// every hop before it has to carry UDP for the chain to connect at all.
func needsUDPTransport(kind string, mapping map[string]any) bool {
	switch kind {
	case "hysteria", "hysteria2", "tuic", "wireguard", "shadowquic", "zerotier":
		return true
	case "masque":
		return !strings.HasPrefix(stringField(mapping, "network"), "h2")
	case "openvpn":
		return strings.HasPrefix(strings.ToLower(stringField(mapping, "proto")), "udp")
	case "mieru":
		return strings.EqualFold(stringField(mapping, "transport"), "udp")
	}
	alpn, _ := mapping["alpn"].([]any)
	return stringField(mapping, "network") == "xhttp" && len(alpn) > 0 && alpn[0] == "h3"
}

func servedChainLeaves() map[string][]chainLeaf {
	served := map[string][]chainLeaf{}
	for name, pd := range tunnel.ProvidersSnapshot() {
		if pd == nil || pd.VehicleType() == P.Compatible {
			continue
		}
		for _, proxy := range pd.Proxies() {
			served[name] = append(served[name], servedLeaf(proxy))
		}
	}
	return served
}

func servedLeaf(proxy C.Proxy) chainLeaf {
	kind := strings.ToLower(proxy.Type().String())
	leaf := chainLeaf{name: proxy.Name(), kind: kind, udp: proxy.SupportUDP(), needsUDP: needsUDPTransport(kind, nil)}
	if host, port, err := net.SplitHostPort(proxy.Addr()); err == nil {
		leaf.server = host
		leaf.port, _ = strconv.Atoi(port)
	}
	return leaf
}

func (ix *chainIndex) hop(name string) *chainHop {
	if hop, ok := ix.hops[name]; ok {
		return hop
	}
	hop := &chainHop{name: name, contains: map[string]struct{}{}}
	ix.hops[name] = hop
	switch {
	case slices.Contains(chainBuiltins, name):
		hop.code = chainUnchainableHop
	case ix.proxyMaps[name] != nil:
		leaf := ix.leaf(name)
		if chainUnchainableTypes[leaf.kind] {
			hop.code = chainUnchainableHop
		} else {
			hop.leaves = []chainLeaf{leaf}
		}
	case ix.groupMaps[name] != nil:
		hop.group = name
		hop.groupType = strings.ToLower(stringField(ix.groupMaps[name], "type"))
		if _, ok := groupAdapterTypes[hop.groupType]; !ok {
			hop.entryOnly = true
			break
		}
		if err := ix.expand(name, hop, map[string]bool{}, map[string]bool{}); err != nil {
			hop.code = chainUnchainableHop
		}
	default:
		ix.servedHop(hop)
	}
	return hop
}

// A node a provider serves is chained through a sibling of that provider
// narrowed to its name.
func (ix *chainIndex) servedHop(hop *chainHop) {
	exact := chainFilters{filter: "^" + regexp2.Escape(hop.name) + "$"}
	for _, provider := range ix.providerOrder {
		for _, leaf := range ix.served[provider] {
			if leaf.name != hop.name {
				continue
			}
			hop.code = ""
			if chainUnchainableTypes[leaf.kind] {
				hop.code = chainUnchainableHop
			}
			hop.leaves = []chainLeaf{leaf}
			hop.uses = []chainUse{{provider: provider, filters: exact}}
			return
		}
	}
	// A provider that has not downloaded yet may serve the node, so the chain
	// waits on it instead of failing the first start.
	for _, provider := range ix.providerOrder {
		if ix.pending[provider] {
			hop.uses = append(hop.uses, chainUse{provider: provider, filters: exact})
		}
	}
	hop.pending = len(hop.uses) > 0
	if !hop.pending {
		hop.code = chainMissingHop
	}
}

func chainProviderPath(mapping map[string]any) string {
	kind := strings.ToLower(stringField(mapping, "type"))
	path := stringField(mapping, "path")
	if path == "" && kind == "http" {
		path = C.Path.GetPathByHash(chainProviderPathCategory, stringField(mapping, "url"))
	}
	if kind != "file" && kind != "http" {
		return ""
	}
	return path
}

// diskChainLeaves reads what the provider would serve from its file, through
// mihomo's own parser, so filters and name overrides apply as they will once
// the provider loads.
func diskChainLeaves(name string, mapping map[string]any) ([]chainLeaf, bool) {
	inline := maps.Clone(mapping)
	if strings.ToLower(stringField(mapping, "type")) != "inline" {
		path := chainProviderPath(mapping)
		if path == "" {
			return nil, false
		}
		buf, err := readCoreFile(C.Path.Resolve(path))
		if err != nil {
			return nil, false
		}
		if buf, err = age.DecryptBytes(buf, stringField(mapping, "age-secret-key")); err != nil {
			return nil, false
		}
		schema := provider.ProxySchema{}
		if yaml.Unmarshal(buf, &schema) != nil {
			if schema.Proxies, err = convert.ConvertsV2Ray(buf); err != nil {
				return nil, false
			}
		}
		if schema.Proxies == nil {
			return nil, false
		}
		for _, key := range []string{"path", "url", "interval", "age-secret-key"} {
			delete(inline, key)
		}
		inline["type"], inline["payload"] = "inline", schema.Proxies
	}
	delete(inline, "dialer-proxy")
	delete(inline, "health-check")
	pd, err := provider.ParseProxyProvider(name, inline, tunnel.Tunnel)
	if err != nil {
		return nil, false
	}
	defer func() {
		if closer, ok := pd.(io.Closer); ok {
			_ = closer.Close()
		}
	}()
	leaves := []chainLeaf{}
	for _, proxy := range pd.Proxies() {
		leaves = append(leaves, servedLeaf(proxy))
	}
	return leaves, true
}

func (ix *chainIndex) groupOption(name string) (outboundgroup.GroupCommonOption, error) {
	option := outboundgroup.GroupCommonOption{}
	err := ix.resolver.decoder.Decode(ix.groupMaps[name], &option)
	return option, err
}

func (ix *chainIndex) expand(group string, hop *chainHop, visiting, seen map[string]bool) error {
	if visiting[group] {
		return nil
	}
	visiting[group] = true
	members, err := ix.resolver.members(group)
	if err != nil {
		return err
	}
	for _, member := range members {
		switch {
		case ix.groupMaps[member] != nil:
			hop.contains[member] = struct{}{}
			if _, ok := groupAdapterTypes[strings.ToLower(stringField(ix.groupMaps[member], "type"))]; ok {
				if err := ix.expand(member, hop, visiting, seen); err != nil {
					return err
				}
			}
		case ix.proxyMaps[member] != nil && !seen[member]:
			if leaf := ix.leaf(member); !chainUnchainableTypes[leaf.kind] {
				seen[member] = true
				hop.leaves = append(hop.leaves, leaf)
			}
		}
	}
	option, err := ix.groupOption(group)
	if err != nil {
		return err
	}
	uses := option.Use
	if option.IncludeAll || option.IncludeAllProviders {
		uses = ix.providerOrder
	}
	filters := chainFilters{option.Filter, option.ExcludeFilter, option.ExcludeType}
	for _, provider := range uses {
		use := chainUse{provider: provider, filters: filters}
		if ix.providerMaps[provider] == nil || slices.Contains(hop.uses, use) {
			continue
		}
		hop.uses = append(hop.uses, use)
		for _, leaf := range ix.servedLeaves(use) {
			if !seen[leaf.name] {
				seen[leaf.name] = true
				hop.leaves = append(hop.leaves, leaf)
			}
		}
	}
	return nil
}

func (ix *chainIndex) servedLeaves(use chainUse) []chainLeaf {
	include, includeErr := ix.resolver.compile(use.filters.filter)
	exclude, excludeErr := ix.resolver.compile(use.filters.excludeFilter)
	if includeErr != nil || excludeErr != nil {
		return nil
	}
	var excludedTypes []string
	if use.filters.excludeType != "" {
		excludedTypes = strings.Split(use.filters.excludeType, "|")
	}
	var leaves []chainLeaf
	for _, leaf := range ix.served[use.provider] {
		if use.filters.filter != "" && !matchesAny(include, leaf.name) ||
			use.filters.excludeFilter != "" && matchesAny(exclude, leaf.name) ||
			slices.ContainsFunc(excludedTypes, func(kind string) bool { return strings.EqualFold(kind, leaf.kind) }) {
			continue
		}
		leaves = append(leaves, leaf)
	}
	return leaves
}

func matchesAny(patterns []*regexp2.Regexp, name string) bool {
	for _, pattern := range patterns {
		if matched, _ := pattern.MatchString(name); matched {
			return true
		}
	}
	return false
}

// carriesUDP answers for the leaves the hop is known to have; a hop whose
// nodes are not known yet is not held against the chain.
func (hop *chainHop) carriesUDP() bool {
	for _, leaf := range hop.leaves {
		if !leaf.udp {
			return false
		}
	}
	return true
}

func (ix *chainIndex) shownGroups() []string {
	var shown []string
	for _, name := range ix.groupOrder {
		if name != "GLOBAL" && !boolField(ix.groupMaps[name], "hidden") {
			shown = append(shown, name)
		}
	}
	return shown
}

// mainGroup mirrors pickMainGroup in lib/providers/state/proxies.dart.
func (ix *chainIndex) mainGroup(hint string) string {
	shown := ix.shownGroups()
	if hint != "" {
		for _, name := range shown {
			if strings.EqualFold(name, hint) {
				return name
			}
		}
	}
	if len(shown) == 0 {
		return ""
	}
	return shown[0]
}

func (ix *chainIndex) groupType(name string) string {
	return strings.ToLower(stringField(ix.groupMaps[name], "type"))
}

func (ix *chainIndex) suggest(fingerprint ChainFingerprint) []string {
	matches := func(leaf chainLeaf) bool {
		return strings.EqualFold(leaf.kind, fingerprint.Type) &&
			strings.EqualFold(leaf.server, fingerprint.Server) && leaf.port == fingerprint.Port
	}
	var names []string
	for _, name := range ix.proxyOrder {
		if matches(ix.leaf(name)) {
			names = append(names, name)
		}
	}
	for _, provider := range ix.providerOrder {
		for _, leaf := range ix.served[provider] {
			if matches(leaf) && !slices.Contains(names, leaf.name) {
				names = append(names, leaf.name)
			}
		}
	}
	return names
}

type chainAnalysis struct {
	hops   []*chainHop
	issues []ChainIssue
	target string
	carry  []bool
	lossy  []bool
	udp    string
}

func (a *chainAnalysis) add(hop int, code string) *ChainIssue {
	for i := range a.issues {
		if a.issues[i].Hop == hop && a.issues[i].Code == code {
			return &a.issues[i]
		}
	}
	a.issues = append(a.issues, ChainIssue{Hop: hop, Code: code, cause: hop})
	return &a.issues[len(a.issues)-1]
}

func (ix *chainIndex) analyze(spec ChainSpec, hint string) chainAnalysis {
	a := chainAnalysis{issues: []ChainIssue{}, udp: chainUDPNone}
	if len(spec.Hops) < 2 {
		a.add(-1, chainEmptyExit)
	}
	for i, name := range spec.Hops {
		hop := ix.hop(name)
		a.hops = append(a.hops, hop)
		switch {
		case hop.code == chainMissingHop:
			issue := a.add(i, hop.code)
			if i < len(spec.Fingerprints) && spec.Fingerprints[i] != nil {
				issue.Fingerprint = spec.Fingerprints[i]
				issue.Suggest = ix.suggest(*spec.Fingerprints[i])
			}
		case hop.code != "":
			a.add(i, hop.code)
		case i > 0 && hop.entryOnly:
			a.add(i, chainUnchainableHop)
		case hop.pending:
			a.add(i, chainProviderPending)
		case i > 0 && len(hop.leaves) == 0 && len(hop.uses) == 0:
			a.add(i, chainEmptyExit)
		}
	}
	if spec.Offered {
		ix.resolveTarget(&a, spec.TargetGroup, hint)
	}
	// An entry picked before its exit is still an entry, so it is checked too.
	for i := 0; a.target != "" && i < max(len(a.hops)-1, 1) && i < len(a.hops); i++ {
		if _, contained := a.hops[i].contains[a.target]; a.hops[i].name == a.target || contained {
			a.add(i, chainLoop)
		}
	}
	ix.analyzeUDP(&a)
	return a
}

func (ix *chainIndex) resolveTarget(a *chainAnalysis, targetGroup *string, hint string) {
	target := ""
	if targetGroup != nil && *targetGroup != "" {
		if ix.groupMaps[*targetGroup] != nil {
			target = *targetGroup
		}
	} else {
		target = ix.mainGroup(hint)
	}
	if target == "" {
		a.add(-1, chainMissingTarget)
		return
	}
	if ix.groupType(target) == chainSelectType {
		a.target = target
		return
	}
	issue := a.add(-1, chainMainGroupAutomatic)
	for _, name := range ix.shownGroups() {
		if ix.groupType(name) == chainSelectType {
			issue.Suggest = []string{name}
			break
		}
	}
}

func (ix *chainIndex) analyzeUDP(a *chainAnalysis) {
	a.carry = make([]bool, len(a.hops))
	a.lossy = make([]bool, len(a.hops))
	for i, hop := range a.hops {
		a.carry[i] = hop.carriesUDP()
	}
	lacking := -1
	for i := 1; i < len(a.hops); i++ {
		if lacking < 0 && !a.carry[i-1] {
			lacking = i - 1
		}
		hop := a.hops[i]
		if hop.code != "" {
			continue
		}
		a.lossy[i] = lacking >= 0
		needs, carries, loses := false, false, false
		for _, leaf := range hop.leaves {
			needs = needs || leaf.needsUDP
			carries = carries || leaf.udp
			loses = loses || leaf.udp && !leaf.needsUDP
			if leaf.dialer != "" {
				a.add(i, chainDialerReplaced)
			}
		}
		for _, use := range hop.uses {
			if stringField(ix.providerMaps[use.provider], "dialer-proxy") != "" {
				a.add(i, chainDialerReplaced)
			}
		}
		if needs && lacking >= 0 {
			a.add(i, chainUDPTransportMissing).cause = lacking
		}
		if i < len(a.hops)-1 || !carries {
			continue
		}
		a.udp = chainUDPCarried
		if lacking >= 0 {
			a.udp = chainUDPLostState
			if loses {
				a.add(i, chainUDPLost)
			}
		}
	}
}

func chainStatus(issues []ChainIssue) string {
	switch {
	case slices.ContainsFunc(issues, func(issue ChainIssue) bool { return chainErrorCodes[issue.Code] }):
		return chainStatusBroken
	case len(issues) > 0:
		return chainStatusDegraded
	}
	return chainStatusOK
}

type chainBuild struct {
	ix         *chainIndex
	hint       string
	proxies    []*yaml.Node
	groups     []*yaml.Node
	providers  []*yaml.Node
	injected   map[string][]string
	targets    []string
	generated  map[string]struct{}
	owned      []string
	siblingDir []string
}

func materializeChains(root *yaml.Node, chains []ChainSpec, mainGroupHint string) []ChainReport {
	reports, _ := materializeChainsWith(root, chains, mainGroupHint, servedChainLeaves())
	return reports
}

func materializeChainsWith(
	root *yaml.Node,
	chains []ChainSpec,
	mainGroupHint string,
	served map[string][]chainLeaf,
) ([]ChainReport, *chainBuild) {
	b := &chainBuild{
		ix:        newChainIndex(root, served, nil),
		hint:      mainGroupHint,
		injected:  map[string][]string{},
		generated: map[string]struct{}{},
	}
	reports := make([]ChainReport, 0, len(chains))
	for _, spec := range chains {
		reports = append(reports, b.chain(spec))
	}
	b.apply(root)
	return reports, b
}

func (b *chainBuild) unique(name string) string {
	candidate := name
	for n := 2; ; n++ {
		if _, taken := b.ix.taken[candidate]; !taken {
			break
		}
		candidate = fmt.Sprintf("%s %d", name, n)
	}
	b.ix.taken[candidate] = struct{}{}
	b.generated[candidate] = struct{}{}
	b.owned = append(b.owned, candidate)
	return candidate
}

func (b *chainBuild) chain(spec ChainSpec) ChainReport {
	a := b.ix.analyze(spec, b.hint)
	_, clash := b.ix.taken[spec.Name]
	if clash || strings.TrimSpace(spec.Name) == "" {
		a.add(-1, chainNameClash)
	}
	report := ChainReport{
		ID:      spec.ID,
		Group:   spec.Name,
		Status:  chainStatus(a.issues),
		Issues:  a.issues,
		Members: map[string]ChainMember{},
		UDP:     a.udp,
	}
	if slices.ContainsFunc(a.issues, func(issue ChainIssue) bool { return issue.Code == chainNameClash }) {
		return report
	}
	b.owned = nil
	b.unique(spec.Name)
	if report.Status == chainStatusBroken {
		b.groups = append(b.groups, chainMapping(
			"name", scalarNode(spec.Name),
			"type", scalarNode(chainSelectType),
			"proxies", sequenceNode([]string{"REJECT"}),
			"hidden", boolNode(true),
		))
	} else {
		b.build(spec.Name, a, &report)
	}
	for _, name := range b.owned[1:] {
		if _, member := report.Members[name]; !member {
			report.Hidden = append(report.Hidden, name)
		}
	}
	if a.target != "" {
		if _, known := b.injected[a.target]; !known {
			b.targets = append(b.targets, a.target)
		}
		b.injected[a.target] = append(b.injected[a.target], spec.Name)
		report.Target = &a.target
	}
	return report
}

func (b *chainBuild) build(name string, a chainAnalysis, report *ChainReport) {
	dialer := a.hops[0].name
	if entry := a.hops[0]; entry.group == "" && len(entry.uses) > 0 {
		dialer = b.providerEntry(name, entry)
	}
	last := len(a.hops) - 1
	for i := 1; i <= last; i++ {
		hop := a.hops[i]
		group := name
		if i < last {
			group = b.unique(name + chainCloneSeparator + hop.name)
		}
		var members []string
		for _, leaf := range hop.leaves {
			if leaf.node == nil {
				continue
			}
			clone := b.unique(name + chainCloneSeparator + leaf.name)
			b.proxies = append(b.proxies, cloneChainProxy(leaf.node, clone, dialer, a.lossy[i] && leaf.udp))
			members = append(members, clone)
			if i == last {
				report.Members[clone] = ChainMember{Leaf: leaf.name, Server: leaf.server, Port: leaf.port}
			}
		}
		shared, onGroup := sharedChainFilters(hop.uses, len(members) > 0)
		var siblings []string
		for _, use := range hop.uses {
			filters := use.filters
			if shared {
				filters = chainFilters{}
			}
			if sibling := b.sibling(name, use.provider, filters, dialer); sibling != "" {
				siblings = append(siblings, sibling)
			}
		}
		node := chainMapping("name", scalarNode(group), "type", scalarNode(chainGroupTypeOf(hop)))
		if hop.group != "" && hop.groupType != chainSelectType {
			for _, key := range chainGroupSettings {
				if value := mappingValue(b.ix.groups[hop.group], key); value != nil {
					setMappingValue(node, key, cloneYAML(value))
				}
			}
		}
		if len(members) > 0 {
			setMappingValue(node, "proxies", sequenceNode(members))
		}
		if len(siblings) > 0 {
			setMappingValue(node, "use", sequenceNode(siblings))
		}
		if shared {
			for key, value := range map[string]string{
				"filter": onGroup.filter, "exclude-filter": onGroup.excludeFilter, "exclude-type": onGroup.excludeType,
			} {
				if value != "" {
					setMappingValue(node, key, scalarNode(value))
				}
			}
		}
		setMappingValue(node, "hidden", boolNode(true))
		b.groups = append(b.groups, node)
		dialer = group
	}
}

func chainGroupTypeOf(hop *chainHop) string {
	if _, ok := groupAdapterTypes[hop.groupType]; ok && hop.group != "" {
		return hop.groupType
	}
	return chainSelectType
}

// A group's own filters stay on the chain's group when every provider shares
// them, which keeps mihomo matching them after the provider's name override.
// Excludes would also reach the clones, which come from other groups, so
// then they move onto each sibling instead.
func sharedChainFilters(uses []chainUse, clones bool) (bool, chainFilters) {
	if len(uses) == 0 {
		return false, chainFilters{}
	}
	first := uses[0].filters
	for _, use := range uses[1:] {
		if use.filters != first {
			return false, chainFilters{}
		}
	}
	if clones && (first.excludeFilter != "" || first.excludeType != "") {
		return false, chainFilters{}
	}
	return true, first
}

// mihomo resolves dialer-proxy only among inline proxies and groups, so an
// entry a provider serves is reached through a hidden group of that provider.
func (b *chainBuild) providerEntry(chain string, entry *chainHop) string {
	name := b.unique(chain + chainCloneSeparator + entry.name)
	var providers []string
	for _, use := range entry.uses {
		providers = append(providers, use.provider)
	}
	b.groups = append(b.groups, chainMapping(
		"name", scalarNode(name),
		"type", scalarNode(chainSelectType),
		"use", sequenceNode(providers),
		"filter", scalarNode(entry.uses[0].filters.filter),
		"hidden", boolNode(true),
	))
	return name
}

// sibling reads the provider's own file, so it follows every update the
// provider downloads without fetching anything itself.
func (b *chainBuild) sibling(chain, provider string, filters chainFilters, dialer string) string {
	parent := b.ix.providers[provider]
	mapping := b.ix.providerMaps[provider]
	node := chainMapping()
	switch kind := strings.ToLower(stringField(mapping, "type")); kind {
	case "inline":
		setMappingValue(node, "type", scalarNode(kind))
	case "file", "http":
		path := chainProviderPath(mapping)
		if path == "" {
			return ""
		}
		setMappingValue(node, "type", scalarNode("file"))
		setMappingValue(node, "path", scalarNode(path))
		b.siblingDir = append(b.siblingDir, filepath.Dir(C.Path.Resolve(path)))
	default:
		return ""
	}
	for _, key := range chainSiblingSettings {
		if value := mappingValue(parent, key); value != nil {
			setMappingValue(node, key, cloneYAML(value))
		}
	}
	own := chainFilters{
		stringField(mapping, "filter"), stringField(mapping, "exclude-filter"), stringField(mapping, "exclude-type"),
	}
	for key, value := range map[string]string{
		"filter":         andChainFilters(own.filter, filters.filter),
		"exclude-filter": joinNonEmpty("`", own.excludeFilter, filters.excludeFilter),
		"exclude-type":   joinNonEmpty("|", own.excludeType, filters.excludeType),
	} {
		if value != "" {
			setMappingValue(node, key, scalarNode(value))
		}
	}
	setMappingValue(node, "dialer-proxy", scalarNode(dialer))
	name := b.unique(chain + chainSiblingSeparator + provider)
	b.providers = append(b.providers, scalarNode(name), node)
	return name
}

// A provider filter keeps a name any of its backtick-separated patterns
// matches, so two filters meet through one lookahead per side.
func andChainFilters(first, second string) string {
	if first == "" || second == "" {
		return first + second
	}
	side := func(filter string) string {
		return `(?=[\s\S]*?(?:` + strings.Join(strings.Split(filter, "`"), "|") + `))`
	}
	return "^" + side(first) + side(second)
}

func joinNonEmpty(separator string, parts ...string) string {
	return strings.Join(slices.DeleteFunc(parts, func(part string) bool { return part == "" }), separator)
}

func (b *chainBuild) apply(root *yaml.Node) {
	b.freezeIncludeAll()
	for _, target := range b.targets {
		names := make([]*yaml.Node, 0, len(b.injected[target]))
		for _, name := range b.injected[target] {
			names = append(names, scalarNode(name))
		}
		appendChainSequence(b.ix.groups[target], "proxies", names)
	}
	appendChainSequence(root, "proxies", b.proxies)
	appendChainSequence(root, "proxy-groups", b.groups)
	if len(b.providers) == 0 {
		return
	}
	providers := chainMapping()
	if existing := resolveAlias(mappingValue(root, "proxy-providers")); existing != nil && existing.Kind == yaml.MappingNode {
		providers.Content = slices.Clone(existing.Content)
	}
	providers.Content = append(providers.Content, b.providers...)
	setMappingValue(root, "proxy-providers", providers)
}

// The clones and siblings would join every include-all group, so those groups
// get the members mihomo would have given them as explicit lists.
func (b *chainBuild) freezeIncludeAll() {
	ix := b.ix
	clones, siblings := len(b.proxies) > 0, len(b.providers) > 0
	if !clones && !siblings {
		return
	}
	for _, name := range ix.groupOrder {
		option, err := ix.groupOption(name)
		if err != nil {
			continue
		}
		withProxies := option.IncludeAll || option.IncludeAllProxies
		withProviders := option.IncludeAll || option.IncludeAllProviders
		if !(withProxies && clones || withProviders && siblings) {
			continue
		}
		node := ix.groups[name]
		for _, key := range []string{"include-all", "include-all-proxies", "include-all-providers"} {
			if _, present := ix.groupMaps[name][key]; present {
				setMappingValue(node, key, boolNode(false))
			}
		}
		use := option.Use
		if withProviders {
			use = ix.providerOrder
			if siblings {
				setMappingValue(node, "use", sequenceNode(use))
			} else {
				setMappingValue(node, "include-all-providers", boolNode(true))
			}
		}
		if !withProxies {
			continue
		}
		if !clones {
			setMappingValue(node, "include-all-proxies", boolNode(true))
			continue
		}
		members := slices.Clone(option.Proxies)
		include, _ := ix.resolver.compile(option.Filter)
		for _, proxy := range ix.resolver.inline {
			if option.Filter == "" {
				members = append(members, proxy)
				continue
			}
			// mihomo appends a node once per pattern it matches.
			for _, pattern := range include {
				if matched, _ := pattern.MatchString(proxy); matched {
					members = append(members, proxy)
				}
			}
		}
		if len(members) == 0 && len(use) == 0 {
			fallback := option.EmptyFallback
			if fallback == "" {
				fallback = "COMPATIBLE"
			}
			members = []string{fallback}
		}
		setMappingValue(node, "proxies", sequenceNode(members))
	}
}

func appendChainSequence(mapping *yaml.Node, key string, items []*yaml.Node) {
	if len(items) == 0 || mapping == nil {
		return
	}
	sequence := &yaml.Node{Kind: yaml.SequenceNode, Tag: "!!seq"}
	if existing := resolveAlias(mappingValue(mapping, key)); existing != nil && existing.Kind == yaml.SequenceNode {
		sequence.Content = slices.Clone(existing.Content)
	}
	sequence.Content = append(sequence.Content, items...)
	setMappingValue(mapping, key, sequence)
}

func cloneChainProxy(node *yaml.Node, name, dialer string, udpOff bool) *yaml.Node {
	clone := cloneYAML(node)
	setMappingValue(clone, "name", scalarNode(name))
	setMappingValue(clone, "dialer-proxy", scalarNode(dialer))
	if udpOff {
		setMappingValue(clone, "udp", boolNode(false))
	}
	return clone
}

func cloneYAML(node *yaml.Node) *yaml.Node {
	if node == nil {
		return nil
	}
	clone := *node
	clone.Anchor = ""
	if node.Kind == yaml.AliasNode {
		return &clone
	}
	clone.Content = make([]*yaml.Node, len(node.Content))
	for i, child := range node.Content {
		clone.Content[i] = cloneYAML(child)
	}
	return &clone
}

func chainMapping(pairs ...any) *yaml.Node {
	node := &yaml.Node{Kind: yaml.MappingNode, Tag: "!!map"}
	for i := 0; i+1 < len(pairs); i += 2 {
		setMappingValue(node, pairs[i].(string), pairs[i+1].(*yaml.Node))
	}
	return node
}

func scalarNode(value string) *yaml.Node {
	return &yaml.Node{Kind: yaml.ScalarNode, Tag: "!!str", Value: value}
}

func boolNode(value bool) *yaml.Node {
	return &yaml.Node{Kind: yaml.ScalarNode, Tag: "!!bool", Value: strconv.FormatBool(value)}
}

func sequenceNode(values []string) *yaml.Node {
	node := &yaml.Node{Kind: yaml.SequenceNode, Tag: "!!seq"}
	for _, value := range values {
		node.Content = append(node.Content, scalarNode(value))
	}
	return node
}

var chainState struct {
	sync.Mutex
	reports   []ChainReport
	generated map[string]struct{}
}

func recordChains(reports []ChainReport, generated map[string]struct{}) {
	chainState.Lock()
	defer chainState.Unlock()
	chainState.reports, chainState.generated = reports, generated
}

// applyChains never fails the profile: a chain that cannot be built is left
// as its broken stub, and a fault here leaves the document as it was.
func applyChains(root *yaml.Node, chains []ChainSpec, mainGroupHint string) {
	var reports []ChainReport
	var b *chainBuild
	func() {
		defer func() {
			if r := recover(); r != nil {
				logError("proxy chains were not applied: %v\n%s", r, stackTrace())
				reports, b = nil, nil
			}
		}()
		reports, b = materializeChainsWith(root, chains, mainGroupHint, servedChainLeaves())
	}()
	if b == nil {
		recordChains(nil, nil)
		return
	}
	for _, dir := range b.siblingDir {
		_ = makeCoreDirectory(dir, 0o755)
	}
	recordChains(reports, b.generated)
}

func handleGetChainReport() []ChainReport {
	chainState.Lock()
	defer chainState.Unlock()
	if chainState.reports == nil {
		return []ChainReport{}
	}
	return slices.Clone(chainState.reports)
}

func generatedChainNames() map[string]struct{} {
	chainState.Lock()
	defer chainState.Unlock()
	return chainState.generated
}

func handleInspectChain(params InspectChainParams) (*ChainInspection, error) {
	defer scheduleLoadMemoryRelease()
	root, err := readConfigMapping(runningConfigPath())
	if err != nil {
		return nil, err
	}
	return newChainIndex(root, servedChainLeaves(), generatedChainNames()).inspect(params), nil
}

func (ix *chainIndex) inspect(params InspectChainParams) *ChainInspection {
	spec := ChainSpec{Hops: params.Hops, Offered: true, TargetGroup: params.TargetGroup}
	a := ix.analyze(spec, params.MainGroupHint)
	inspection := &ChainInspection{Issues: a.issues, Leaves: []string{}, UDP: a.carry, Blocked: map[string]string{}}
	if inspection.UDP == nil {
		inspection.UDP = []bool{}
	}
	if len(a.hops) > 1 {
		for _, leaf := range a.hops[len(a.hops)-1].leaves {
			inspection.Leaves = append(inspection.Leaves, leaf.name)
		}
	}
	if params.Slot == nil || *params.Slot < 0 || *params.Slot > len(params.Hops) {
		return inspection
	}
	slot := *params.Slot
	for _, candidate := range ix.candidates() {
		spec.Hops = slices.Clone(params.Hops)
		if slot < len(spec.Hops) {
			spec.Hops[slot] = candidate
		} else {
			spec.Hops = append(spec.Hops, candidate)
		}
		for _, issue := range ix.analyze(spec, params.MainGroupHint).issues {
			if chainBlockingCodes[issue.Code] && (issue.Hop == slot || issue.cause == slot) {
				inspection.Blocked[candidate] = issue.Code
				break
			}
		}
	}
	return inspection
}

func (ix *chainIndex) candidates() []string {
	names := slices.Concat(chainBuiltins, ix.proxyOrder, ix.groupOrder)
	seen := map[string]struct{}{}
	for _, name := range names {
		seen[name] = struct{}{}
	}
	for _, provider := range ix.providerOrder {
		for _, leaf := range ix.served[provider] {
			if _, dup := seen[leaf.name]; !dup {
				seen[leaf.name] = struct{}{}
				names = append(names, leaf.name)
			}
		}
	}
	return names
}
