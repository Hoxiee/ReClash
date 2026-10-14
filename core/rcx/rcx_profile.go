package rcx

import (
	"bytes"
	_ "embed"
	"fmt"
	"io"

	yaml "go.yaml.in/yaml/v3"
)

//go:embed rcx_profile_default.yaml
var rcxDefaultProfileYAML []byte

type rcxDecisionProfile struct {
	Schema     int                           `yaml:"schema"`
	Ladder     []rcxRungSpec                 `yaml:"ladder"`
	Strategies map[string]rcxStrategyProfile `yaml:"strategies"`
	Admission  []rcxAdmitRule                `yaml:"admission"`
	Probe      rcxProbeSection               `yaml:"probe"`
	Terrain    *rcxTerrainSection            `yaml:"terrain,omitempty"`
	Settings   *rcxSettingsPatch             `yaml:"settings,omitempty"`
	Contexts   rcxProfileContexts            `yaml:"contexts,omitempty"`
}

type rcxProbeSection struct {
	Concurrency   int `yaml:"concurrency"`
	StaggerMs     int `yaml:"staggerMs"`
	BudgetPerHour int `yaml:"budgetPerHour"`
	Reserve       int `yaml:"reserve"`
	// A sized URL the clamp probe pulls through a standby to read its throughput
	// shape. Empty keeps the shape probe dormant: no endpoint is contacted and no
	// clamp verdict is produced.
	ShapeTarget string           `yaml:"shapeTarget,omitempty"`
	Metered     *rcxProbeSection `yaml:"metered,omitempty"`
}

func rcxDefaultProbeSection() rcxProbeSection {
	return rcxCopyProbe(rcxBuiltInProfile.Probe)
}

func rcxCopyProbe(value rcxProbeSection) rcxProbeSection {
	if value.Metered != nil {
		child := *value.Metered
		child.Metered = nil
		value.Metered = &child
	}
	return value
}

func (s rcxProbeSection) bounded() rcxProbeSection {
	def := rcxDefaultProbeSection()
	if s.Concurrency < 1 || s.Concurrency > rcxProbeConcurrencyMax {
		s.Concurrency = def.Concurrency
	}
	if s.StaggerMs < 0 || s.StaggerMs > rcxProbeStaggerMsMax {
		s.StaggerMs = def.StaggerMs
	}
	if s.BudgetPerHour < rcxProbeBudgetFloor || s.BudgetPerHour > rcxProbeBudgetCeil {
		s.BudgetPerHour = def.BudgetPerHour
	}
	// An unset reserve takes the shipped default; an explicit one is clamped to the
	// floor and to half the budget.
	if s.Reserve == 0 {
		s.Reserve = def.Reserve
	}
	if s.Reserve < rcxProbeReserveFloor {
		s.Reserve = rcxProbeReserveFloor
	}
	if s.Reserve > s.BudgetPerHour/2 {
		s.Reserve = s.BudgetPerHour / 2
	}
	if s.Metered != nil {
		m := *s.Metered
		m.Metered = nil
		m = m.bounded()
		s.Metered = &m
	}
	return s
}

func rcxDefaultDecisionProfile() rcxDecisionProfile {
	p := rcxBuiltInProfile
	p.Ladder = rcxDefaultLadder()
	p.Strategies = rcxCopyStrategies(p.Strategies)
	p.Admission = rcxDefaultAdmitRules()
	p.Terrain = rcxDefaultTerrainSection()
	p.Probe = rcxDefaultProbeSection()
	p.Settings = rcxAllSettings(rcxDefaultConfig())
	return p
}

func rcxCopyStrategies(in map[string]rcxStrategyProfile) map[string]rcxStrategyProfile {
	out := make(map[string]rcxStrategyProfile, len(in))
	for name, strategy := range in {
		strategy.LatencyBands = append([]int(nil), strategy.LatencyBands...)
		strategy.DropRungs = append([]rcxRungID(nil), strategy.DropRungs...)
		out[name] = strategy
	}
	return out
}

func (p *rcxProbeSection) UnmarshalYAML(node *yaml.Node) error {
	var patch rcxProbePatch
	if err := rcxDecodeNode(node, &patch); err != nil {
		return err
	}
	if patch.Metered != nil && patch.Metered.Metered != nil {
		return fmt.Errorf("rcx: nested metered probe variants are not supported")
	}
	base := rcxDefaultProbeSection()
	metered := patch.Metered
	patch.Metered = nil
	value := patch.apply(base)
	if metered != nil {
		child := base
		if base.Metered != nil {
			child = *base.Metered
		}
		child.Metered = nil
		child = metered.apply(child)
		value.Metered = &child
	}
	*p = value
	return nil
}

func (p rcxDecisionProfile) marshalYAML() ([]byte, error) {
	return yaml.Marshal(p)
}

func (c rcxConfig) effectiveProfile() rcxDecisionProfile {
	if c.compiled != nil {
		return c.compiled.export
	}
	return c.profileValues()
}

func (c rcxConfig) profileValues() rcxDecisionProfile {
	admission := c.admitRules
	if admission == nil {
		admission = rcxDefaultAdmitRules()
	}
	return rcxDecisionProfile{
		Schema:     rcxProfileSchema,
		Ladder:     c.ladder(),
		Strategies: c.resolvedStrategies(),
		Admission:  admission,
		Probe:      c.probe(),
		Terrain:    c.terrainRules(),
		Settings:   rcxAllSettings(c),
	}
}

const rcxProfileMaxBytes = 256 * 1024

func rcxDecisionProfileFromYAML(data []byte) (rcxDecisionProfile, error) {
	var p rcxDecisionProfile
	if len(data) > rcxProfileMaxBytes {
		return p, fmt.Errorf("rcx: profile exceeds %d bytes", rcxProfileMaxBytes)
	}
	var node yaml.Node
	decoder := yaml.NewDecoder(bytes.NewReader(data))
	if err := decoder.Decode(&node); err != nil {
		return p, err
	}
	var extra yaml.Node
	if err := decoder.Decode(&extra); err != io.EOF {
		return p, fmt.Errorf("rcx: expected one YAML document")
	}
	if err := rcxProfileTree(&node, 0); err != nil {
		return p, err
	}
	p.Probe = rcxDefaultProbeSection()
	if err := rcxDecodeNode(&node, &p); err != nil {
		return p, err
	}
	if p.Schema == 1 {
		root := &node
		if root.Kind == yaml.DocumentNode {
			root = root.Content[0]
		}
		for i := 0; i < len(root.Content); i += 2 {
			if root.Content[i].Value != "terrain" {
				continue
			}
			terrain := root.Content[i+1]
			for j := 0; j < len(terrain.Content); j += 2 {
				if terrain.Content[j].Value != "enabled" {
					return p, fmt.Errorf("rcx: terrain.%s requires schema 2", terrain.Content[j].Value)
				}
			}
		}
	}
	if p.Schema == rcxProfileSchema {
		root := &node
		if root.Kind == yaml.DocumentNode {
			root = root.Content[0]
		}
		contextsPresent := false
		for i := 0; i < len(root.Content); i += 2 {
			contextsPresent = contextsPresent || root.Content[i].Value == "contexts"
		}
		if !contextsPresent {
			p.Contexts = rcxBuiltInProfile.Contexts
		}
	}
	return p, p.validateSize()
}

func rcxProfileTree(node *yaml.Node, depth int) error {
	if depth > 24 || node.Kind == yaml.AliasNode || node.Tag == "!!null" {
		return fmt.Errorf("rcx: profile nesting or alias is not supported")
	}
	for _, child := range node.Content {
		if err := rcxProfileTree(child, depth+1); err != nil {
			return err
		}
	}
	return nil
}

// Token vocabularies. These are the stable wire contract; an index is the enum's
// own uint8 value, so a value token round-trips through the same ordering the
// comparators and admission readers use.

func (id rcxRungID) MarshalYAML() (any, error) {
	token := id.String()
	if token == "" {
		return nil, fmt.Errorf("rcx: unmarshalable rung id %d", uint8(id))
	}
	return token, nil
}

func (id *rcxRungID) UnmarshalYAML(value *yaml.Node) error {
	var token string
	if err := value.Decode(&token); err != nil {
		return err
	}
	parsed, _ := rcxRungByToken(token)
	*id = parsed
	return nil
}

var rcxFactFieldTokens = map[rcxFactField]string{
	rcxFactTransit:    "transit",
	rcxFactTrust:      "trust",
	rcxFactOpenWorld:  "openWorld",
	rcxFactDomestic:   "domestic",
	rcxFactExit:       "exit",
	rcxFactOrigin:     "origin",
	rcxFactBreaker:    "breaker",
	rcxFactOpenedOnce: "openedOnce",
	rcxFactOpenLapsed: "openLapsed",
}

// Per-field value tokens, index == the field's enum uint8 value.
var rcxFactValueTokens = map[rcxFactField][]string{
	rcxFactTransit:    {"unknown", "proven", "disproven"},
	rcxFactOpenWorld:  {"unknown", "proven", "disproven"},
	rcxFactDomestic:   {"unknown", "proven", "disproven"},
	rcxFactTrust:      {"unknown", "suspect", "trusted", "branded"},
	rcxFactExit:       {"unknown", "foreign", "domestic"},
	rcxFactOrigin:     {"unknown", "foreign", "domestic"},
	rcxFactBreaker:    {"false", "true"},
	rcxFactOpenedOnce: {"false", "true"},
	rcxFactOpenLapsed: {"false", "true"},
}

var rcxFactOpTokens = map[rcxFactOp]string{rcxOpIs: "is", rcxOpIsNot: "isNot"}

var rcxAdmitColumnTokens = map[rcxAdmitColumn]string{
	rcxColOpenWorldProven: "openWorldProven",
	rcxColDomesticProven:  "domesticProven",
	rcxColBreakerProven:   "breakerProven",
	rcxColForeignPrior:    "foreignPrior",
	rcxColDomesticPrior:   "domesticPrior",
}

func rcxFieldByToken(token string) (rcxFactField, bool) {
	for field, name := range rcxFactFieldTokens {
		if name == token {
			return field, true
		}
	}
	return 0, false
}

func rcxOpByToken(token string) (rcxFactOp, bool) {
	for op, name := range rcxFactOpTokens {
		if name == token {
			return op, true
		}
	}
	return 0, false
}

func rcxColumnByToken(token string) (rcxAdmitColumn, bool) {
	for column, name := range rcxAdmitColumnTokens {
		if name == token {
			return column, true
		}
	}
	return 0, false
}

func rcxFactValueToken(field rcxFactField, value uint8) (string, bool) {
	tokens, ok := rcxFactValueTokens[field]
	if !ok || int(value) >= len(tokens) {
		return "", false
	}
	return tokens[value], true
}

func rcxFactValueByToken(field rcxFactField, token string) (uint8, bool) {
	for value, name := range rcxFactValueTokens[field] {
		if name == token {
			return uint8(value), true
		}
	}
	return 0, false
}

// A condition serializes to one readable triplet string, "<field> <op> <value>",
// so a reviewer reads "transit is disproven" rather than three integers.
func (c rcxAdmitCond) MarshalYAML() (any, error) {
	field, okField := rcxFactFieldTokens[c.Field]
	op, okOp := rcxFactOpTokens[c.Op]
	value, okValue := rcxFactValueToken(c.Field, c.Value)
	if !okField || !okOp || !okValue {
		return nil, fmt.Errorf("rcx: unserializable condition %+v", c)
	}
	return field + " " + op + " " + value, nil
}

func (c *rcxAdmitCond) UnmarshalYAML(value *yaml.Node) error {
	var raw string
	if err := value.Decode(&raw); err != nil {
		return err
	}
	fieldToken, opToken, valueToken, err := rcxTriplet(raw)
	if err != nil {
		return err
	}
	field, okField := rcxFieldByToken(fieldToken)
	op, okOp := rcxOpByToken(opToken)
	if !okField || !okOp {
		return fmt.Errorf("rcx: unknown field or op in %q", raw)
	}
	lit, okValue := rcxFactValueByToken(field, valueToken)
	if !okValue {
		return fmt.Errorf("rcx: unknown value %q for field %q", valueToken, fieldToken)
	}
	*c = rcxAdmitCond{Field: field, Op: op, Value: lit}
	return nil
}

// A rule carries its conjunction and exactly one outcome: a fixed verdict or a
// terrain-row tier.
type rcxAdmitRuleWire struct {
	When    []rcxAdmitCond `yaml:"when,omitempty"`
	Verdict string         `yaml:"verdict,omitempty"`
	Tier    string         `yaml:"tier,omitempty"`
}

func (r rcxAdmitRule) MarshalYAML() (any, error) {
	wire := rcxAdmitRuleWire{When: r.When}
	if r.Outcome.FromColumn {
		token, ok := rcxAdmitColumnTokens[r.Outcome.Column]
		if !ok {
			return nil, fmt.Errorf("rcx: unserializable tier %d", uint8(r.Outcome.Column))
		}
		wire.Tier = token
	} else {
		wire.Verdict = r.Outcome.Verdict.String()
	}
	return wire, nil
}

func (r *rcxAdmitRule) UnmarshalYAML(value *yaml.Node) error {
	var wire rcxAdmitRuleWire
	if err := rcxDecodeNode(value, &wire); err != nil {
		return err
	}
	if (wire.Verdict == "") == (wire.Tier == "") {
		return fmt.Errorf("rcx: rule needs exactly one of verdict/tier")
	}
	outcome := rcxAdmitOutcome{}
	if wire.Tier != "" {
		column, ok := rcxColumnByToken(wire.Tier)
		if !ok {
			return fmt.Errorf("rcx: unknown tier %q", wire.Tier)
		}
		outcome = rcxAdmitFromColumn(column)
	} else {
		verdict, ok := rcxVerdictByToken(wire.Verdict)
		if !ok {
			return fmt.Errorf("rcx: unknown verdict %q", wire.Verdict)
		}
		outcome = rcxAdmitVerdict(verdict)
	}
	*r = rcxAdmitRule{When: wire.When, Outcome: outcome}
	return nil
}

func rcxVerdictByToken(token string) (rcxVerdict, bool) {
	for verdict := rcxVerdictReject; verdict <= rcxVerdictPreferred; verdict++ {
		if verdict.String() == token {
			return verdict, true
		}
	}
	return rcxVerdictReject, false
}
