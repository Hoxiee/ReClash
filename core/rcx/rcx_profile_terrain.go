package rcx

import (
	"fmt"
	"strings"

	yaml "go.yaml.in/yaml/v3"
)

type rcxTerrainRule struct {
	When  []rcxSignalCond `yaml:"when,omitempty"`
	State string          `yaml:"state"`
}

type rcxTerrainMode struct {
	Kind      rcxTerrain       `yaml:"kind"`
	Admission *rcxAdmissionRow `yaml:"admission,omitempty"`
}

type rcxTerrainSection struct {
	Enabled            bool                      `yaml:"enabled"`
	Checks             []string                  `yaml:"checks"`
	Rules              []rcxTerrainRule          `yaml:"rules"`
	States             map[string]rcxTerrainMode `yaml:"states"`
	RefreshSeconds     int                       `yaml:"refreshSeconds"`
	UrgentSeconds      int                       `yaml:"urgentSeconds"`
	BackoffSeconds     int                       `yaml:"backoffSeconds"`
	MaxAgeSeconds      int                       `yaml:"maxAgeSeconds"`
	ConfirmationRounds int                       `yaml:"confirmationRounds"`
	TimeoutMs          int                       `yaml:"timeoutMs"`
	WarmupMs           int                       `yaml:"warmupMs"`
}

func rcxDefaultTerrainSection() *rcxTerrainSection {
	if rcxBuiltInProfile.Terrain == nil {
		return &rcxTerrainSection{Enabled: true}
	}
	return rcxBuiltInProfile.Terrain.copy()
}

func (s *rcxTerrainSection) copy() *rcxTerrainSection {
	if s == nil {
		return nil
	}
	out := *s
	out.Checks = append([]string(nil), s.Checks...)
	out.Rules = append([]rcxTerrainRule(nil), s.Rules...)
	for i := range out.Rules {
		out.Rules[i].When = append([]rcxSignalCond(nil), s.Rules[i].When...)
	}
	out.States = make(map[string]rcxTerrainMode, len(s.States))
	for name, mode := range s.States {
		if mode.Admission != nil {
			row := *mode.Admission
			mode.Admission = &row
		}
		out.States[name] = mode
	}
	return &out
}

func (s *rcxTerrainSection) UnmarshalYAML(node *yaml.Node) error {
	type plain rcxTerrainSection
	value := plain(*rcxDefaultTerrainSection())
	if err := rcxDecodeNode(node, &value); err != nil {
		return err
	}
	*s = rcxTerrainSection(value)
	return s.validate()
}

func (s *rcxTerrainSection) validate() error {
	if len(s.States) == 0 || len(s.States) > 32 || len(s.Rules) > 64 {
		return fmt.Errorf("rcx: terrain needs 1..32 states and at most 64 rules")
	}
	if len(s.Checks) > 3 {
		return fmt.Errorf("rcx: at most three terrain checks are supported")
	}
	seen := map[string]bool{}
	for _, name := range s.Checks {
		if seen[name] {
			return fmt.Errorf("rcx: duplicate terrain check %q", name)
		}
		seen[name] = true
		switch name {
		case "foreign", "domestic", "sni":
		default:
			return fmt.Errorf("rcx: unknown terrain check %q", name)
		}
	}
	for name, state := range s.States {
		if !rcxValidLaneID(name) {
			return fmt.Errorf("rcx: invalid terrain state %q", name)
		}
		if kind, known := rcxTerrainByToken(name); known && state.Kind != kind {
			return fmt.Errorf("rcx: built-in terrain %q cannot change kind", name)
		}
	}
	for _, rule := range s.Rules {
		if _, ok := s.States[rule.State]; !ok {
			return fmt.Errorf("rcx: unknown terrain state %q", rule.State)
		}
		if len(rule.When) > 16 {
			return fmt.Errorf("rcx: too many terrain conditions")
		}
		for _, condition := range rule.When {
			if condition.field == "terrain" || condition.field == "terrain.kind" {
				return fmt.Errorf("rcx: a terrain detector cannot read its own output")
			}
		}
	}
	return nil
}

func (s *rcxTerrainSection) bounded() *rcxTerrainSection {
	out := s.copy()
	def := rcxDefaultTerrainSection()
	bound := func(value, fallback, low, high int) int {
		if value == 0 {
			return fallback
		}
		if value < low {
			return low
		}
		if value > high {
			return high
		}
		return value
	}
	out.RefreshSeconds = bound(out.RefreshSeconds, def.RefreshSeconds, 30, 3600)
	out.UrgentSeconds = bound(out.UrgentSeconds, def.UrgentSeconds, 5, 300)
	out.BackoffSeconds = bound(out.BackoffSeconds, def.BackoffSeconds, out.UrgentSeconds, 3600)
	out.MaxAgeSeconds = bound(out.MaxAgeSeconds, def.MaxAgeSeconds, out.RefreshSeconds, 7200)
	out.ConfirmationRounds = bound(out.ConfirmationRounds, def.ConfirmationRounds, 2, 5)
	out.TimeoutMs = bound(out.TimeoutMs, def.TimeoutMs, 500, 10000)
	out.WarmupMs = bound(out.WarmupMs, def.WarmupMs, out.TimeoutMs, 15000)
	for name, state := range out.States {
		if state.Admission != nil {
			row := rcxClampAdmissionRow(*state.Admission, rcxAdmissionTable[state.Kind])
			state.Admission = &row
			out.States[name] = state
		}
	}
	return out
}

func (s *rcxTerrainSection) checks(name string) bool {
	if !s.Enabled {
		return false
	}
	for _, check := range s.Checks {
		if check == name {
			return true
		}
	}
	return false
}

func (s *rcxTerrainSection) classify(signals rcxSignals) (string, rcxTerrain) {
	if signals.terrain.CaptivePortal || signals.terrain.PortalMarker {
		return "portal", rcxTerrainPortal
	}
	if !s.Enabled {
		return "normal", rcxTerrainNormal
	}
	for _, rule := range s.Rules {
		if rcxSignalStack(rule.When, signals) {
			return rule.State, s.States[rule.State].Kind
		}
	}
	return "unknown", rcxTerrainUnknown
}

func rcxTerrainByToken(token string) (rcxTerrain, bool) {
	for terrain := rcxTerrainUnknown; terrain <= rcxTerrainOffline; terrain++ {
		if terrain.String() == token {
			return terrain, true
		}
	}
	return rcxTerrainUnknown, false
}

func (t rcxTerrain) MarshalYAML() (any, error) { return t.String(), nil }

func (t *rcxTerrain) UnmarshalYAML(node *yaml.Node) error {
	parsed, ok := rcxTerrainByToken(node.Value)
	if !ok {
		return fmt.Errorf("rcx: unknown terrain kind %q", node.Value)
	}
	*t = parsed
	return nil
}

func (v rcxVerdict) MarshalYAML() (any, error) { return v.String(), nil }

func (v *rcxVerdict) UnmarshalYAML(node *yaml.Node) error {
	parsed, ok := rcxVerdictByToken(node.Value)
	if !ok {
		return fmt.Errorf("rcx: unknown verdict %q", node.Value)
	}
	*v = parsed
	return nil
}

type rcxAdmissionRowWire struct {
	OpenWorldProven rcxVerdict `yaml:"openWorldProven"`
	DomesticProven  rcxVerdict `yaml:"domesticProven"`
	BreakerProven   rcxVerdict `yaml:"breakerProven"`
	ForeignPrior    rcxVerdict `yaml:"foreignPrior"`
	DomesticPrior   rcxVerdict `yaml:"domesticPrior"`
	AllowLastResort bool       `yaml:"allowLastResort"`
}

func (r rcxAdmissionRow) MarshalYAML() (any, error) {
	return rcxAdmissionRowWire{r.openWorldProven, r.domesticProven, r.breakerProven, r.foreignPrior, r.domesticPrior, r.allowLastResort}, nil
}

func (r *rcxAdmissionRow) UnmarshalYAML(node *yaml.Node) error {
	var wire rcxAdmissionRowWire
	if err := rcxDecodeNode(node, &wire); err != nil {
		return err
	}
	*r = rcxAdmissionRow{wire.OpenWorldProven, wire.DomesticProven, wire.BreakerProven, wire.ForeignPrior, wire.DomesticPrior, wire.AllowLastResort}
	return nil
}

func rcxClampAdmissionRow(value, floor rcxAdmissionRow) rcxAdmissionRow {
	cap := func(v, max rcxVerdict) rcxVerdict {
		if v > max {
			return max
		}
		return v
	}
	return rcxAdmissionRow{
		openWorldProven: cap(value.openWorldProven, floor.openWorldProven),
		domesticProven:  cap(value.domesticProven, floor.domesticProven),
		breakerProven:   cap(value.breakerProven, floor.breakerProven),
		foreignPrior:    cap(value.foreignPrior, floor.foreignPrior),
		domesticPrior:   cap(value.domesticPrior, floor.domesticPrior),
		allowLastResort: value.allowLastResort && floor.allowLastResort,
	}
}

func (c rcxConfig) terrainRules() *rcxTerrainSection {
	if c.terrainProfile != nil {
		return c.terrainProfile
	}
	return rcxBuiltInProfile.Terrain
}

func rcxRegion(c rcxConfig) string {
	if c.Region != "" {
		return strings.ToUpper(strings.TrimSpace(c.Region))
	}
	if len(c.Preset) == 2 {
		return strings.ToUpper(c.Preset)
	}
	return ""
}
