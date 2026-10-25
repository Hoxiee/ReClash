package rcx

import (
	"cmp"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"net/netip"
	"strconv"
	"strings"
	"unicode"
)

const (
	maxRoutes        = 32
	maxRouteMatches  = 128
	maxRouteName     = 64
	maxRouteDescribe = 240
)

// Route sends the traffic its match selects ahead of the config's own rules:
// to a group of its own holding every server, driven by the route's
// program, or to a fixed target.
type Route struct {
	Name        string   `yaml:"name" json:"name"`
	Description string   `yaml:"description,omitempty" json:"description,omitempty"`
	Match       []string `yaml:"match" json:"match"`
	Program     `yaml:",inline"`
}

// routeTypes are the rule types a route matches by; true marks the ones
// that take no-resolve.
var routeTypes = map[string]bool{
	"DOMAIN": false, "DOMAIN-SUFFIX": false, "DOMAIN-KEYWORD": false, "DOMAIN-WILDCARD": false,
	"DOMAIN-REGEX": false, "GEOSITE": false, "GEOIP": true, "IP-CIDR": true, "IP-CIDR6": true,
	"IP-ASN": true, "SRC-IP-CIDR": false, "DST-PORT": false, "PROCESS-NAME": false,
	"PROCESS-PATH": false, "RULE-SET": true,
}

// reservedRouteNames are targets mihomo or the scenario already gives a
// meaning; a route group of that name could not be told apart.
var reservedRouteNames = map[string]bool{
	MainTarget: true, AllTarget: true, GlobalTarget: true, "DIRECT": true, "REJECT": true,
	"REJECT-DROP": true, "PASS": true, "COMPATIBLE": true,
}

// RouteMatch is one parsed match entry.
type RouteMatch struct {
	Type      string
	Payload   string
	NoResolve bool
}

func (m RouteMatch) String() string {
	out := m.Type + "," + m.Payload
	if m.NoResolve {
		out += ",no-resolve"
	}
	return out
}

// Rule is the mihomo rule sending this match to target.
func (m RouteMatch) Rule(target string) string {
	out := m.Type + "," + m.Payload + "," + target
	if m.NoResolve {
		out += ",no-resolve"
	}
	return out
}

func ParseRouteMatch(entry string) (RouteMatch, error) {
	kind, rest, _ := strings.Cut(entry, ",")
	m := RouteMatch{Type: strings.ToUpper(strings.TrimSpace(kind))}
	takesNoResolve, known := routeTypes[m.Type]
	if !known {
		return m, fmt.Errorf("%q is not a match type a route can use", strings.TrimSpace(kind))
	}
	if m.Type == "DOMAIN-REGEX" {
		m.Payload = strings.TrimSpace(rest)
	} else {
		parts := strings.Split(rest, ",")
		m.Payload = strings.TrimSpace(parts[0])
		for _, param := range parts[1:] {
			if strings.TrimSpace(param) != "no-resolve" || !takesNoResolve {
				return m, fmt.Errorf("%s takes no option %q", m.Type, strings.TrimSpace(param))
			}
			m.NoResolve = true
		}
	}
	if m.Payload == "" {
		return m, fmt.Errorf("%s needs a value", m.Type)
	}
	switch m.Type {
	case "IP-CIDR", "IP-CIDR6", "SRC-IP-CIDR":
		if _, err := netip.ParsePrefix(m.Payload); err != nil {
			return m, fmt.Errorf("%s %q is not an address range like 10.0.0.0/8", m.Type, m.Payload)
		}
	case "IP-ASN":
		if _, err := strconv.ParseUint(m.Payload, 10, 32); err != nil {
			return m, fmt.Errorf("IP-ASN %q is not a number", m.Payload)
		}
	case "DST-PORT":
		if !validPorts(m.Payload) {
			return m, fmt.Errorf("DST-PORT %q is not a port or range like 443 or 8000-8100", m.Payload)
		}
	}
	return m, nil
}

func validPorts(spec string) bool {
	for _, part := range strings.Split(spec, "/") {
		low, high, isRange := strings.Cut(part, "-")
		if !isRange {
			high = low
		}
		for _, port := range []string{low, high} {
			if _, err := strconv.ParseUint(port, 10, 16); err != nil {
				return false
			}
		}
	}
	return true
}

// normalizeMatch accepts each entry as "TYPE,value" and also the split form
// a flow sequence [GEOSITE,youtube] decodes to.
func normalizeMatch(items []string) ([]string, error) {
	var out []string
	for i := 0; i < len(items); i++ {
		at := i
		entry := strings.TrimSpace(items[i])
		if _, isType := routeTypes[strings.ToUpper(entry)]; isType && i+1 < len(items) {
			i++
			entry += "," + strings.TrimSpace(items[i])
			if i+1 < len(items) && strings.TrimSpace(items[i+1]) == "no-resolve" {
				i++
				entry += ",no-resolve"
			}
		}
		m, err := ParseRouteMatch(entry)
		if err != nil {
			return nil, atPath(err, at)
		}
		out = append(out, m.String())
	}
	return out, nil
}

func (r *Route) validate() error {
	if r.Name != strings.TrimSpace(r.Name) || r.Name == "" || len(r.Name) > maxRouteName {
		return atPath(fmt.Errorf("route %q needs a name of 1 to %d bytes", r.Name, maxRouteName), "name")
	}
	if strings.ContainsFunc(r.Name, func(c rune) bool { return c == ',' || unicode.IsControl(c) }) {
		return atPath(fmt.Errorf("route name %q holds a comma", r.Name), "name")
	}
	if reservedRouteNames[r.Name] {
		return atPath(fmt.Errorf("route name %s is reserved", r.Name), "name")
	}
	if len(r.Description) > maxRouteDescribe {
		return atPath(fmt.Errorf("route %s description longer than %d bytes", r.Name, maxRouteDescribe), "description")
	}
	if len(r.Match) == 0 || len(r.Match) > maxRouteMatches {
		return atPath(fmt.Errorf("route %s needs 1 to %d match entries", r.Name, maxRouteMatches), "match")
	}
	match, err := normalizeMatch(r.Match)
	if err != nil {
		return atPath(fmt.Errorf("route %s: %w", r.Name, err), "match")
	}
	if len(match) > maxRouteMatches {
		return atPath(fmt.Errorf("route %s needs 1 to %d match entries", r.Name, maxRouteMatches), "match")
	}
	r.Match = match
	return r.Program.validate()
}

func validateRoutes(routes []Route, groups map[string]Program) error {
	if len(routes) > maxRoutes {
		return fmt.Errorf("more than %d routes", maxRoutes)
	}
	seen := map[string]bool{}
	for i := range routes {
		route := &routes[i]
		if err := route.validate(); err != nil {
			return atPath(err, i)
		}
		if seen[route.Name] {
			return atPath(fmt.Errorf("two routes are named %s", route.Name), i, "name")
		}
		seen[route.Name] = true
		if _, ok := groups[route.Name]; ok {
			return atPath(fmt.Errorf("route %s takes its program on the route, not under groups", route.Name), i, "name")
		}
	}
	return nil
}

// routesKey identifies what the routes put into the config; a program
// change applies live and needs no new config.
func routesKey(routes []Route) string {
	if len(routes) == 0 {
		return ""
	}
	type shape struct {
		Name  string   `json:"n"`
		Match []string `json:"m"`
		To    string   `json:"t,omitempty"`
	}
	shapes := make([]shape, len(routes))
	for i, r := range routes {
		shapes[i] = shape{r.Name, r.Match, r.To}
	}
	data, _ := json.Marshal(shapes)
	sum := sha256.Sum256(data)
	return hex.EncodeToString(sum[:8])
}

// AppliedRoutes is what the running config was built with: the key of the
// routes it was given, the groups that made it in, and why a route was
// left out.
type AppliedRoutes struct {
	Applied  bool
	Key      string
	Groups   []string
	Problems map[string]Reason
}

// ScenarioRoutes are the routes of the scenario that runs for these layers,
// with the key the engine later compares the running config against.
func ScenarioRoutes(sub SubscriptionLayer, user UserLayer) ([]Route, string) {
	id := activeScenario(sub, user)
	if id == "" {
		return nil, ""
	}
	c, err := NewLibrary(sub, user).CompileScenario(id)
	if err != nil {
		return nil, ""
	}
	return c.routes, c.routesKey
}

func activeScenario(sub SubscriptionLayer, user UserLayer) string {
	if user.ScenarioOff {
		return ""
	}
	return cmp.Or(CanonicalID(user.Scenario), CanonicalID(sub.Scenario))
}
