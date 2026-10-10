package rcx

import (
	"fmt"
	"strconv"
	"strings"
	"unicode"

	yaml "go.yaml.in/yaml/v3"
)

type rcxProfileContext struct {
	Region      string `json:"region"`
	Terrain     string `json:"terrain"`
	TerrainKind string `json:"terrainKind"`
	Transport   string `json:"transport"`
	Metered     bool   `json:"metered"`
	Carrier     string `json:"carrier,omitempty"`
	SSID        string `json:"ssid,omitempty"`
	Validated   bool   `json:"validated"`
	Portal      bool   `json:"portal"`
}

type rcxSignals struct {
	context rcxProfileContext
	terrain rcxTerrainFacts
}

type rcxSignalSpec struct {
	read   func(rcxSignals) string
	values []string
}

func rcxBoolToken(value bool) string {
	if value {
		return "true"
	}
	return "false"
}

var rcxSignalSpecs = map[string]rcxSignalSpec{
	"region":                {read: func(s rcxSignals) string { return s.context.Region }},
	"terrain":               {read: func(s rcxSignals) string { return s.context.Terrain }},
	"terrain.kind":          {read: func(s rcxSignals) string { return s.context.TerrainKind }, values: []string{"unknown", "normal", "whitelist", "portal", "offline"}},
	"network.transport":     {read: func(s rcxSignals) string { return s.context.Transport }, values: []string{"unknown", "wifi", "cellular", "ethernet", "other"}},
	"network.metered":       {read: func(s rcxSignals) string { return rcxBoolToken(s.context.Metered) }, values: []string{"false", "true"}},
	"network.carrier":       {read: func(s rcxSignals) string { return s.context.Carrier }},
	"network.ssid":          {read: func(s rcxSignals) string { return s.context.SSID }},
	"network.validated":     {read: func(s rcxSignals) string { return rcxBoolToken(s.terrain.Validated) }, values: []string{"false", "true"}},
	"network.portal":        {read: func(s rcxSignals) string { return rcxBoolToken(s.terrain.CaptivePortal) }, values: []string{"false", "true"}},
	"check.foreign":         {read: func(s rcxSignals) string { return rcxOutcomeName(s.terrain.ForeignReach) }, values: []string{"unknown", "ok", "fail", "mismatch"}},
	"check.domestic":        {read: func(s rcxSignals) string { return rcxOutcomeName(s.terrain.DomesticReach) }, values: []string{"unknown", "ok", "fail", "mismatch"}},
	"check.sni":             {read: func(s rcxSignals) string { return rcxOutcomeName(s.terrain.SNIReach) }, values: []string{"unknown", "ok", "fail", "mismatch"}},
	"check.portal":          {read: func(s rcxSignals) string { return rcxBoolToken(s.terrain.PortalMarker) }, values: []string{"false", "true"}},
	"network.unvalidatedMs": {},
}

type rcxSignalCond struct {
	field   string
	op      string
	literal string
	number  int64
}

func rcxTriplet(raw string) (field, op, literal string, err error) {
	remaining := strings.TrimSpace(raw)
	at := strings.IndexFunc(remaining, unicode.IsSpace)
	if at < 1 {
		return "", "", "", fmt.Errorf("rcx: invalid condition %q", raw)
	}
	field, remaining = remaining[:at], strings.TrimSpace(remaining[at:])
	at = strings.IndexFunc(remaining, unicode.IsSpace)
	if at < 1 {
		return "", "", "", fmt.Errorf("rcx: invalid condition %q", raw)
	}
	op, literal = remaining[:at], strings.TrimSpace(remaining[at:])
	if strings.HasPrefix(literal, "\"") {
		literal, err = strconv.Unquote(literal)
		if err != nil {
			return "", "", "", fmt.Errorf("rcx: invalid quoted literal")
		}
	}
	if len(literal) == 0 || len(literal) > 1024 {
		return "", "", "", fmt.Errorf("rcx: invalid condition literal")
	}
	return field, op, literal, nil
}

func (c *rcxSignalCond) UnmarshalYAML(node *yaml.Node) error {
	var raw string
	if err := node.Decode(&raw); err != nil {
		return err
	}
	field, op, value, err := rcxTriplet(raw)
	if err != nil {
		return err
	}
	spec, ok := rcxSignalSpecs[field]
	if !ok {
		return fmt.Errorf("rcx: unknown signal %q", field)
	}
	cond := rcxSignalCond{field: field, op: op, literal: value}
	if field == "network.unvalidatedMs" {
		switch op {
		case "is", "isNot", "lt", "lte", "gt", "gte":
		default:
			return fmt.Errorf("rcx: unknown numeric operator %q", op)
		}
		cond.number, err = strconv.ParseInt(value, 10, 64)
		if err != nil || cond.number < 0 || cond.number > 3600000 {
			return fmt.Errorf("rcx: invalid unvalidated duration %q", value)
		}
	} else {
		if op != "is" && op != "isNot" {
			return fmt.Errorf("rcx: signal %q needs is/isNot", field)
		}
		if len(spec.values) > 0 {
			found := false
			for _, token := range spec.values {
				found = found || token == value
			}
			if !found {
				return fmt.Errorf("rcx: invalid value %q for %s", value, field)
			}
		}
	}
	if field == "region" {
		cond.literal = strings.ToUpper(value)
	}
	*c = cond
	return nil
}

func (c rcxSignalCond) MarshalYAML() (any, error) {
	literal := c.literal
	if strings.ContainsAny(literal, " \t\n\r\"\\") {
		literal = strconv.Quote(literal)
	}
	return c.field + " " + c.op + " " + literal, nil
}

func (c rcxSignalCond) holds(s rcxSignals) bool {
	if c.field == "network.unvalidatedMs" {
		got := s.terrain.UnvalidatedFor.Milliseconds()
		switch c.op {
		case "is":
			return got == c.number
		case "isNot":
			return got != c.number
		case "lt":
			return got < c.number
		case "lte":
			return got <= c.number
		case "gt":
			return got > c.number
		case "gte":
			return got >= c.number
		}
		return false
	}
	spec, ok := rcxSignalSpecs[c.field]
	if !ok || spec.read == nil {
		return false
	}
	matches := spec.read(s) == c.literal
	if c.op == "isNot" {
		return !matches
	}
	return c.op == "is" && matches
}

func rcxSignalStack(conditions []rcxSignalCond, signals rcxSignals) bool {
	for _, condition := range conditions {
		if !condition.holds(signals) {
			return false
		}
	}
	return true
}
