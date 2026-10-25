package core

import (
	"maps"
	"regexp"
	"slices"
	"strconv"

	"core/rcx"

	"github.com/metacubex/mihomo/config"
)

// builtinTargets are the proxies mihomo adds to every config.
var builtinTargets = []string{"DIRECT", "REJECT", "REJECT-DROP", "PASS", "COMPATIBLE", "GLOBAL"}

var injectedRuleError = regexp.MustCompile(`^rules\[(\d+)\]`)
var injectedGroupError = regexp.MustCompile(`^proxy group\[(\d+)\]`)

// routedConfig is one parse attempt: the raw config with the routes that
// are still in, and which route owns each injected rule and group.
type routedConfig struct {
	raw        *config.RawConfig
	ruleOwners []string
	groups     []string
}

// parseRouted parses the config with the scenario's routes in front of its
// rules. A route mihomo rejects is dropped with the reason and the parse
// retried; a config that fails for its own reasons fails as it would
// without routes.
func parseRouted(raw *config.RawConfig, routes []rcx.Route, key string) (*config.Config, rcx.AppliedRoutes, error) {
	applied := rcx.AppliedRoutes{Applied: true, Key: key, Problems: map[string]rcx.Reason{}}
	dropped := map[string]bool{}
	for {
		trial := injectRoutes(raw, routes, dropped, applied.Problems)
		cfg, err := config.ParseRawConfig(trial.raw)
		if err == nil {
			applied.Groups = trial.groups
			return withPlatformLimits(cfg), applied, nil
		}
		owner := trial.owner(err.Error())
		if owner == "" {
			if len(trial.groups) == 0 && len(trial.ruleOwners) == 0 {
				return nil, applied, err
			}
			for _, route := range routes {
				if _, known := applied.Problems[route.Name]; !known {
					applied.Problems[route.Name] = routeInvalid(route.Name, err.Error())
				}
			}
			cfg, plainErr := config.ParseRawConfig(cloneRaw(raw))
			if plainErr != nil {
				return nil, applied, plainErr
			}
			return withPlatformLimits(cfg), applied, nil
		}
		dropped[owner] = true
		applied.Problems[owner] = routeInvalid(owner, err.Error())
	}
}

func routeInvalid(route, message string) rcx.Reason {
	return rcx.Reason{Code: "route.invalid", Args: map[string]any{"route": route, "error": message}}
}

func (t routedConfig) owner(message string) string {
	if match := injectedRuleError.FindStringSubmatch(message); match != nil {
		if i, _ := strconv.Atoi(match[1]); i < len(t.ruleOwners) {
			return t.ruleOwners[i]
		}
	}
	if match := injectedGroupError.FindStringSubmatch(message); match != nil {
		i, _ := strconv.Atoi(match[1])
		if i < len(t.raw.ProxyGroup) {
			name, _ := t.raw.ProxyGroup[i]["name"].(string)
			if slices.Contains(t.groups, name) {
				return name
			}
		}
	}
	return ""
}

// cloneRaw copies what a parse reorders in place, so every attempt starts
// from the config as read.
func cloneRaw(raw *config.RawConfig) *config.RawConfig {
	out := *raw
	out.ProxyGroup = slices.Clone(raw.ProxyGroup)
	out.Rule = slices.Clone(raw.Rule)
	return &out
}

func injectRoutes(raw *config.RawConfig, routes []rcx.Route, dropped map[string]bool, problems map[string]rcx.Reason) routedConfig {
	out := routedConfig{raw: cloneRaw(raw)}
	if len(routes) == 0 {
		return out
	}
	taken := map[string]bool{}
	for _, name := range builtinTargets {
		taken[name] = true
	}
	for _, mappings := range [][]map[string]any{raw.Proxy, raw.ProxyGroup} {
		for _, mapping := range mappings {
			if name, ok := mapping["name"].(string); ok {
				taken[name] = true
			}
		}
	}
	targets := maps.Clone(taken)
	for _, route := range routes {
		if route.To == "" && !dropped[route.Name] && !taken[route.Name] {
			targets[route.Name] = true
		}
	}
	var rules []string
	for _, route := range routes {
		if dropped[route.Name] {
			continue
		}
		target := route.To
		switch {
		case target == "" && taken[route.Name]:
			problems[route.Name] = rcx.Reason{Code: "route.name-taken", Args: map[string]any{"route": route.Name}}
			continue
		case target != "" && !targets[target]:
			problems[route.Name] = rcx.Reason{Code: "route.to-missing", Args: map[string]any{"route": route.Name, "to": target}}
			continue
		}
		matches, missing := routeMatches(route, raw.RuleProvider)
		if missing != "" {
			problems[route.Name] = routeInvalid(route.Name, "rule set "+missing+" is not in the config")
			continue
		}
		if target == "" {
			target = route.Name
			out.groups = append(out.groups, route.Name)
			out.raw.ProxyGroup = append(out.raw.ProxyGroup, map[string]any{"name": route.Name, "type": "select", "include-all": true})
		}
		for _, match := range matches {
			rules = append(rules, match.Rule(target))
			out.ruleOwners = append(out.ruleOwners, route.Name)
		}
	}
	out.raw.Rule = append(rules, raw.Rule...)
	return out
}

func routeMatches(route rcx.Route, providers map[string]map[string]any) ([]rcx.RouteMatch, string) {
	matches := make([]rcx.RouteMatch, 0, len(route.Match))
	for _, entry := range route.Match {
		match, err := rcx.ParseRouteMatch(entry)
		if err != nil {
			continue
		}
		if _, ok := providers[match.Payload]; match.Type == "RULE-SET" && !ok {
			return nil, match.Payload
		}
		matches = append(matches, match)
	}
	return matches, ""
}
