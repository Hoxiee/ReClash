// Package sitelock holds destinations to the exits the user allows: a locked
// connection leaves through one of them or is refused, whatever the mode or rules.
package sitelock

import (
	"fmt"
	"net"
	"net/netip"
	"slices"
	"strconv"
	"strings"
	"unicode/utf8"

	C "github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/rules"
	RC "github.com/metacubex/mihomo/rules/common"
	"golang.org/x/net/idna"
)

const (
	maxLocks   = 32
	maxEntries = 128
	maxExits   = 16
	maxID      = 64
	maxName    = 64
	// Proxy names come from subscriptions and run longer than lock names.
	maxExitName = 512
	maxRoute    = 128
)

// Lock entries are mihomo rules without a target.
type Lock struct {
	ID      string   `json:"id"`
	Name    string   `json:"name"`
	Enabled bool     `json:"enabled"`
	Match   []string `json:"match"`
	Except  []string `json:"except,omitempty"`
	Exits   []Exit   `json:"exits"`
}

// Exit names a server by its definition without the name (Route), which
// survives renames. Providers that serve many exits from one address tell
// them apart only by credentials, so the address alone is no identity; Name
// takes over once a refresh rotates those credentials.
type Exit struct {
	Type   string `json:"type"`
	Server string `json:"server"`
	Port   int    `json:"port"`
	Route  string `json:"route,omitempty"`
	Name   string `json:"name,omitempty"`
}

type Problem struct {
	ID      string `json:"id"`
	Field   string `json:"field"`
	Message string `json:"message"`
}

const (
	StatusReady    = "ready"
	StatusDisabled = "disabled"
	// No server of the config is an exit, so connections are refused.
	StatusNoExit = "no-exit"
	// Every exit failed its last check; connections still try the first.
	StatusExitsDown = "exits-down"
)

// WarningSnifferOff: without sniffing, a connection whose name the core did
// not resolve (browser DoH, a cached answer) arrives as a bare IP and slips
// past every domain entry.
const WarningSnifferOff = "sniffer-off"

// WarningCoreOnly: entries the OS firewall cannot mirror, so only the running
// core holds them to their exits.
const WarningCoreOnly = "core-only"

type Warning struct {
	Code  string   `json:"code"`
	Locks []string `json:"locks"`
}

type State struct {
	ID     string `json:"id"`
	Status string `json:"status"`
	Exit   string `json:"exit,omitempty"`
}

type Env struct {
	Proxies func() map[string]C.Proxy
	Alive   func(C.Proxy) bool
	Refuse  func() C.Proxy
}

type compiled struct {
	lock   Lock
	match  []C.Rule
	except []C.Rule
}

type Set struct {
	enabled []*compiled
	all     []Lock
}

// Compile builds the locks without problems; a caller that must not drop one checks them.
func Compile(locks []Lock) (*Set, []Problem) {
	var problems []Problem
	if len(locks) > maxLocks {
		problems = append(problems, Problem{Message: fmt.Sprintf("at most %d locks", maxLocks)})
		locks = locks[:maxLocks]
	}
	set := &Set{}
	seen := map[string]bool{}
	for _, lock := range locks {
		built, lockProblems := compile(lock, seen)
		seen[lock.ID] = true
		if len(lockProblems) > 0 {
			problems = append(problems, lockProblems...)
			continue
		}
		set.all = append(set.all, lock)
		if lock.Enabled {
			set.enabled = append(set.enabled, built)
		}
	}
	return set, problems
}

func compile(lock Lock, seen map[string]bool) (*compiled, []Problem) {
	var problems []Problem
	fail := func(field, format string, args ...any) {
		problems = append(problems, Problem{ID: lock.ID, Field: field, Message: fmt.Sprintf(format, args...)})
	}
	switch {
	case lock.ID == "":
		fail("id", "missing")
	case len(lock.ID) > maxID:
		fail("id", "longer than %d bytes", maxID)
	case seen[lock.ID]:
		fail("id", "used by another lock")
	}
	if len(lock.Name) > maxName || !utf8.ValidString(lock.Name) {
		fail("name", "not valid UTF-8 of at most %d bytes", maxName)
	}
	if len(lock.Match) == 0 {
		fail("match", "missing")
	}
	if len(lock.Exits) == 0 {
		fail("exits", "missing")
	}
	if len(lock.Exits) > maxExits {
		fail("exits", "at most %d", maxExits)
	}
	for i, exit := range lock.Exits {
		if strings.TrimSpace(exit.Type) == "" || strings.TrimSpace(exit.Server) == "" || exit.Port < 1 || exit.Port > 65535 {
			fail("exits."+strconv.Itoa(i), "needs a type, a server and a port")
		}
		if len(exit.Route) > maxRoute || len(exit.Name) > maxExitName || !utf8.ValidString(exit.Name) {
			fail("exits."+strconv.Itoa(i), "route or name too long")
		}
	}
	built := &compiled{lock: lock}
	parseAll := func(field string, entries []string) []C.Rule {
		if len(entries) > maxEntries {
			fail(field, "at most %d entries", maxEntries)
			return nil
		}
		parsed := make([]C.Rule, 0, len(entries))
		for i, entry := range entries {
			rule, err := parseEntry(entry, lock.ID)
			if err != nil {
				fail(field+"."+strconv.Itoa(i), "%v", err)
				continue
			}
			parsed = append(parsed, rule)
		}
		return parsed
	}
	built.match = parseAll("match", lock.Match)
	built.except = parseAll("except", lock.Except)
	return built, problems
}

// unboundTypes need the profile's providers or rule tree, which a lock outlives.
var unboundTypes = map[string]bool{"RULE-SET": true, "SUB-RULE": true, "MATCH": true}

func parseEntry(entry, target string) (C.Rule, error) {
	entry = strings.TrimSpace(entry)
	if entry == "" {
		return nil, fmt.Errorf("empty entry")
	}
	for _, kind := range ruleTypes(entry) {
		if unboundTypes[kind] {
			return nil, fmt.Errorf("%s depends on the profile and cannot be locked", kind)
		}
	}
	tp, payload, _, params := RC.ParseRulePayload(entry, false)
	return rules.ParseRule(tp, asciiDomain(tp, payload), target, params, nil)
}

// Connections carry names in their ASCII (punycode) form, as DNS does.
func asciiDomain(tp, payload string) string {
	switch strings.ToUpper(tp) {
	case "DOMAIN", "DOMAIN-SUFFIX", "DOMAIN-KEYWORD", "DOMAIN-WILDCARD":
	default:
		return payload
	}
	labels := strings.Split(payload, ".")
	for i, label := range labels {
		if isASCII(label) {
			continue
		}
		if ascii, err := idna.Lookup.ToASCII(label); err == nil {
			labels[i] = ascii
		} else if ascii, err := idna.Punycode.ToASCII(label); err == nil {
			labels[i] = ascii
		}
	}
	return strings.Join(labels, ".")
}

func isASCII(s string) bool {
	for i := 0; i < len(s); i++ {
		if s[i] >= 0x80 {
			return false
		}
	}
	return true
}

func ruleTypes(entry string) []string {
	var kinds []string
	start, typed := 0, true
	for i := 0; i <= len(entry); i++ {
		if i < len(entry) && entry[i] != ',' && entry[i] != '(' && entry[i] != ')' {
			continue
		}
		if typed {
			if kind := strings.ToUpper(strings.TrimSpace(entry[start:i])); kind != "" {
				kinds = append(kinds, kind)
			}
		}
		typed = i < len(entry) && entry[i] == '('
		start = i + 1
	}
	return kinds
}

// Claim gives the first live exit, else the first exit, else a refusal; nil leaves it to the rules.
func (s *Set) Claim(metadata *C.Metadata, helper C.RuleMatchHelper, env Env) (C.Proxy, C.Rule, string) {
	if s == nil {
		return nil, nil, ""
	}
	for _, lock := range s.enabled {
		rule := firstMatch(lock.match, metadata, helper)
		if rule == nil || firstMatch(lock.except, metadata, helper) != nil {
			continue
		}
		if proxy, _ := lock.pick(env, metadata.NetWork == C.UDP); proxy != nil {
			return proxy, rule, lock.lock.ID
		}
		return env.Refuse(), rule, lock.lock.ID
	}
	return nil, nil, ""
}

func firstMatch(entries []C.Rule, metadata *C.Metadata, helper C.RuleMatchHelper) C.Rule {
	for _, rule := range entries {
		if matched, _ := rule.Match(metadata, helper); matched {
			return rule
		}
	}
	return nil
}

func (c *compiled) pick(env Env, udp bool) (C.Proxy, bool) {
	all := env.Proxies()
	var fallback C.Proxy
	for _, exit := range c.lock.Exits {
		for _, proxy := range candidates(all, exit) {
			if udp && !proxy.SupportUDP() {
				continue
			}
			if env.Alive(proxy) {
				return proxy, true
			}
			if fallback == nil {
				fallback = proxy
			}
		}
	}
	return fallback, false
}

// Groups and built-ins never qualify: they could lead back to DIRECT.
func candidates(all map[string]C.Proxy, exit Exit) []C.Proxy {
	kind := normalType(exit.Type)
	var byRoute, byName []C.Proxy
	for name, proxy := range all {
		if proxy.Type() < C.Shadowsocks || normalType(proxy.Type().String()) != kind {
			continue
		}
		switch {
		case exit.Route == "":
			if atAddress(proxy, exit) {
				byRoute = append(byRoute, proxy)
			}
		case routeOf(proxy) == exit.Route:
			byRoute = append(byRoute, proxy)
		case exit.Name != "" && name == exit.Name:
			byName = append(byName, proxy)
		}
	}
	found := byRoute
	if len(found) == 0 {
		found = byName
	}
	slices.SortFunc(found, func(a, b C.Proxy) int { return strings.Compare(a.Name(), b.Name()) })
	return found
}

func atAddress(proxy C.Proxy, exit Exit) bool {
	host, port, err := net.SplitHostPort(proxy.Addr())
	return err == nil && port == strconv.Itoa(exit.Port) && strings.EqualFold(host, exit.Server)
}

func routeOf(proxy C.Proxy) string {
	if parsed, ok := proxy.(interface{ RouteFingerprint() string }); ok {
		return parsed.RouteFingerprint()
	}
	return ""
}

// normalType folds config types ("ss", "gost-relay") and adapter types to one spelling.
func normalType(kind string) string {
	kind = strings.ReplaceAll(strings.ToLower(strings.TrimSpace(kind)), "-", "")
	switch kind {
	case "ss":
		return "shadowsocks"
	case "ssr":
		return "shadowsocksr"
	}
	return kind
}

var namedTypes = map[string]bool{
	"DOMAIN": true, "DOMAIN-SUFFIX": true, "DOMAIN-KEYWORD": true,
	"DOMAIN-REGEX": true, "DOMAIN-WILDCARD": true, "GEOSITE": true,
}

func (s *Set) Named() []string {
	var ids []string
	if s == nil {
		return ids
	}
	for _, lock := range s.enabled {
		if slices.ContainsFunc(lock.lock.Match, func(entry string) bool {
			return slices.ContainsFunc(ruleTypes(entry), func(kind string) bool { return namedTypes[kind] })
		}) {
			ids = append(ids, lock.lock.ID)
		}
	}
	return ids
}

// Prefixes are the enabled locks' own IP-CIDR entries; nested ones are left
// out, since NOT would invert them.
func (s *Set) Prefixes() []netip.Prefix {
	var prefixes []netip.Prefix
	for _, lock := range s.enabledLocks() {
		for _, entry := range lock.Match {
			tp, payload, _, _ := RC.ParseRulePayload(strings.TrimSpace(entry), false)
			if tp = strings.ToUpper(tp); tp != "IP-CIDR" && tp != "IP-CIDR6" {
				continue
			}
			if prefix, err := netip.ParsePrefix(payload); err == nil {
				prefixes = append(prefixes, prefix.Masked())
			}
		}
	}
	return prefixes
}

// Locks are the locks the set was compiled from, disabled ones included.
func (s *Set) Locks() []Lock {
	if s == nil {
		return nil
	}
	return s.all
}

func (s *Set) enabledLocks() []Lock {
	if s == nil {
		return nil
	}
	locks := make([]Lock, 0, len(s.enabled))
	for _, lock := range s.enabled {
		locks = append(locks, lock.lock)
	}
	return locks
}

func (s *Set) States(env Env) []State {
	if s == nil {
		return []State{}
	}
	states := make([]State, 0, len(s.all))
	for _, lock := range s.all {
		state := State{ID: lock.ID, Status: StatusDisabled}
		if lock.Enabled {
			proxy, alive := (&compiled{lock: lock}).pick(env, false)
			switch {
			case proxy == nil:
				state.Status = StatusNoExit
			case alive:
				state.Status, state.Exit = StatusReady, proxy.Name()
			default:
				state.Status, state.Exit = StatusExitsDown, proxy.Name()
			}
		}
		states = append(states, state)
	}
	return states
}
