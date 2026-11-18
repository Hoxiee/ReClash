package sitelock

import (
	"regexp"
	"slices"
	"strings"

	RC "github.com/metacubex/mihomo/rules/common"

	"github.com/metacubex/mihomo/component/geodata/router"
)

// Names are the locked domain names a DNS filter answers for, in the four
// forms a GEOSITE list uses. Regex entries are RE2, matched case-insensitively.
type Names struct {
	Full    []string `json:"full"`
	Suffix  []string `json:"suffix"`
	Keyword []string `json:"keyword"`
	Regex   []string `json:"regex"`
}

func (n Names) Empty() bool {
	return len(n.Full)+len(n.Suffix)+len(n.Keyword)+len(n.Regex) == 0
}

// GuardedNames are the names of one lock with exceptions: a query matching
// Except is free even when Names matches it.
type GuardedNames struct {
	Names  Names `json:"names"`
	Except Names `json:"except"`
}

type GeoSiteLoader func(code string) ([]*router.Domain, error)

// Names collects what the enabled locks match by name: locks without name
// exceptions merge into names, the rest stay apart in guarded. An exception the
// filter cannot mirror keeps the name locked, the safer side. partial lists the
// locks with an entry outside both Names and Prefixes. Without patterns the host
// matches only full names and suffixes, so keywords and regexes stay with the core.
func (s *Set) Names(load GeoSiteLoader, patterns bool) (names Names, guarded []GuardedNames, partial []string) {
	for _, lock := range s.enabledLocks() {
		var own Names
		covered := true
		for _, entry := range lock.Match {
			if !own.add(entry, load) {
				covered = false
			}
		}
		if !patterns && own.dropPatterns() {
			covered = false
		}
		if !covered {
			partial = append(partial, lock.ID)
		}
		var except Names
		for _, entry := range lock.Except {
			except.add(entry, load)
		}
		if !patterns {
			except.dropPatterns()
		}
		if own.Empty() {
			continue
		}
		if except.Empty() {
			names.merge(own)
			continue
		}
		guarded = append(guarded, GuardedNames{Names: own.sorted(), Except: except.sorted()})
	}
	if guarded == nil {
		guarded = []GuardedNames{}
	}
	return names.sorted(), guarded, partial
}

func (n *Names) merge(other Names) {
	n.Full = append(n.Full, other.Full...)
	n.Suffix = append(n.Suffix, other.Suffix...)
	n.Keyword = append(n.Keyword, other.Keyword...)
	n.Regex = append(n.Regex, other.Regex...)
}

// dropPatterns reports whether there were keywords or regexes to drop.
func (n *Names) dropPatterns() bool {
	had := len(n.Keyword)+len(n.Regex) > 0
	n.Keyword, n.Regex = nil, nil
	return had
}

func (n Names) sorted() Names {
	for _, list := range []*[]string{&n.Full, &n.Suffix, &n.Keyword, &n.Regex} {
		if *list == nil {
			*list = []string{}
		}
		slices.Sort(*list)
		*list = slices.Compact(*list)
	}
	return n
}

func (n *Names) add(entry string, load GeoSiteLoader) bool {
	tp, payload, _, _ := RC.ParseRulePayload(strings.TrimSpace(entry), false)
	payload = asciiDomain(tp, payload)
	switch strings.ToUpper(tp) {
	case "IP-CIDR", "IP-CIDR6":
		return true
	case "DOMAIN":
		n.Full = append(n.Full, strings.ToLower(payload))
	case "DOMAIN-SUFFIX":
		n.Suffix = append(n.Suffix, strings.ToLower(strings.TrimPrefix(payload, ".")))
	case "DOMAIN-KEYWORD":
		n.Keyword = append(n.Keyword, strings.ToLower(payload))
	case "DOMAIN-REGEX":
		return n.addRegex(payload)
	case "DOMAIN-WILDCARD":
		n.Regex = append(n.Regex, wildcardRegex(strings.ToLower(payload)))
	case "GEOSITE":
		return n.addGeoSite(payload, load)
	default:
		return false
	}
	return true
}

// The core matches DOMAIN-REGEX with a backtracking engine; a pattern RE2
// cannot express stays with the core.
func (n *Names) addRegex(pattern string) bool {
	pattern = "(?i)" + pattern
	if _, err := regexp.Compile(pattern); err != nil {
		return false
	}
	n.Regex = append(n.Regex, pattern)
	return true
}

func wildcardRegex(pattern string) string {
	var out strings.Builder
	out.WriteString("^")
	for _, r := range pattern {
		switch r {
		case '*':
			out.WriteString(".*")
		case '?':
			out.WriteString(".")
		default:
			out.WriteString(regexp.QuoteMeta(string(r)))
		}
	}
	out.WriteString("$")
	return out.String()
}

// A negated list matches nearly everything, which the filter must not cut off.
func (n *Names) addGeoSite(code string, load GeoSiteLoader) bool {
	code = strings.ToLower(strings.TrimSpace(code))
	if load == nil || code == "" || code[0] == '!' {
		return false
	}
	parts := strings.Split(code, "@")
	domains, err := load(strings.TrimSpace(parts[0]))
	if err != nil {
		return false
	}
	covered := true
	for _, domain := range domains {
		if !hasAttributes(domain, parts[1:]) {
			continue
		}
		value := strings.ToLower(domain.GetValue())
		switch domain.GetType() {
		case router.Domain_Full:
			n.Full = append(n.Full, value)
		case router.Domain_Domain:
			n.Suffix = append(n.Suffix, value)
		case router.Domain_Plain:
			n.Keyword = append(n.Keyword, value)
		case router.Domain_Regex:
			covered = n.addRegex(domain.GetValue()) && covered
		}
	}
	return covered
}

func hasAttributes(domain *router.Domain, attrs []string) bool {
	for _, attr := range attrs {
		if attr = strings.TrimSpace(attr); attr == "" {
			continue
		}
		if !slices.ContainsFunc(domain.GetAttribute(), func(have *router.Domain_Attribute) bool {
			return strings.EqualFold(have.GetKey(), attr)
		}) {
			return false
		}
	}
	return true
}
