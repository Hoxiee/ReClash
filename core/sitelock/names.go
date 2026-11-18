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

type GeoSiteLoader func(code string) ([]*router.Domain, error)

// Names collects what the enabled locks match by name; partial lists the locks
// with an entry outside both Names and Prefixes.
func (s *Set) Names(load GeoSiteLoader) (names Names, partial []string) {
	for _, lock := range s.enabledLocks() {
		covered := true
		for _, entry := range lock.Match {
			if !names.add(entry, load) {
				covered = false
			}
		}
		if !covered {
			partial = append(partial, lock.ID)
		}
	}
	for _, list := range []*[]string{&names.Full, &names.Suffix, &names.Keyword, &names.Regex} {
		if *list == nil {
			*list = []string{}
		}
		slices.Sort(*list)
		*list = slices.Compact(*list)
	}
	return names, partial
}

func (n *Names) add(entry string, load GeoSiteLoader) bool {
	tp, payload, _, _ := RC.ParseRulePayload(strings.TrimSpace(entry), false)
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
