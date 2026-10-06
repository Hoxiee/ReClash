package rcx

import (
	_ "embed"
	"fmt"
	"strings"

	yaml "go.yaml.in/yaml/v3"
)

// rcxDefaultProfileYAML is the shipped built-in decision profile as YAML, embedded
// into the binary. It is the artifact export emits and the UI/community catalog
// seed from; a bijection test locks it to the Go-literal defaults it mirrors, so
// the human-readable face and the compile-safe source can never silently diverge.
//
//go:embed rcx_profile_default.yaml
var rcxDefaultProfileYAML []byte

// rcxDecisionProfile is the shipped decision data expressed as one serializable,
// human-editable document: the ranking ladder, the per-strategy flavors, and the
// admission rules. It is the YAML face of the Go-literal defaults, built from them
// so it cannot drift, and the foundation for import/export and the UI editor.
type rcxDecisionProfile struct {
	Schema     int                           `yaml:"schema"`
	Ladder     []rcxRungSpec                 `yaml:"ladder"`
	Strategies map[string]rcxStrategyProfile `yaml:"strategies"`
	Admission  []rcxAdmitRule                `yaml:"admission"`
	Probe      rcxProbeSection               `yaml:"probe"`
	Terrain    *rcxTerrainSection            `yaml:"terrain,omitempty"`
}

// rcxTerrainSection makes terrain handling an explicit, optional block. Censorship
// terrain detection matters in some regions and is a rudiment in fully open ones, so
// a profile can switch it off outright rather than leaving it implied by whether any
// canary happens to be configured. Absent section keeps it on (the shipped default).
type rcxTerrainSection struct {
	Enabled bool `yaml:"enabled"`
}

// rcxProbeSection is the steady probe spend as data: wave parallelism, stagger, and
// the share of the hourly budget a wave may burn. Metered is an optional tighter
// variant swapped in on a data-capped link; budget and reserve are floored by
// absolute constants so a profile lowers spend but never strips the recovery reserve.
type rcxProbeSection struct {
	Concurrency   int              `yaml:"concurrency"`
	StaggerMs     int              `yaml:"staggerMs"`
	BudgetPerHour int              `yaml:"budgetPerHour"`
	Reserve       int              `yaml:"reserve"`
	Metered       *rcxProbeSection `yaml:"metered,omitempty"`
}

func rcxDefaultProbeSection() rcxProbeSection {
	return rcxProbeSection{
		Concurrency:   rcxProbeConcurrency,
		StaggerMs:     rcxProbeStaggerMs,
		BudgetPerHour: rcxProbeBudgetCap,
		Reserve:       rcxProbeReserve,
	}
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
		m := s.Metered.bounded()
		m.Metered = nil
		s.Metered = &m
	}
	return s
}

func rcxDefaultDecisionProfile() rcxDecisionProfile {
	return rcxDecisionProfile{
		Schema:     rcxProfileSchema,
		Ladder:     rcxDefaultLadder(),
		Strategies: rcxStrategyProfiles,
		Admission:  rcxDefaultAdmitRules(),
		Probe:      rcxDefaultProbeSection(),
		Terrain:    &rcxTerrainSection{Enabled: true},
	}
}

func (p rcxDecisionProfile) marshalYAML() ([]byte, error) {
	return yaml.Marshal(p)
}

// effectiveProfile is the decision profile the engine is actually running after
// override resolution: the config's ladder, strategy table, admission rules, and
// probe cadence. It is the export counterpart to the ProfileYAML import, and for a
// config carrying no profile it equals the shipped default.
func (c rcxConfig) effectiveProfile() rcxDecisionProfile {
	admission := c.admitRules
	if len(admission) == 0 {
		admission = rcxDefaultAdmitRules()
	}
	return rcxDecisionProfile{
		Schema:     rcxProfileSchema,
		Ladder:     c.ladder(),
		Strategies: c.resolvedStrategies(),
		Admission:  admission,
		Probe:      c.probe(),
		Terrain:    &rcxTerrainSection{Enabled: !c.terrainDisabled},
	}
}

func rcxDecisionProfileFromYAML(data []byte) (rcxDecisionProfile, error) {
	var p rcxDecisionProfile
	err := yaml.Unmarshal(data, &p)
	return p, err
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
	parts := strings.Fields(raw)
	if len(parts) != 3 {
		return fmt.Errorf("rcx: condition %q is not <field> <op> <value>", raw)
	}
	field, okField := rcxFieldByToken(parts[0])
	op, okOp := rcxOpByToken(parts[1])
	if !okField || !okOp {
		return fmt.Errorf("rcx: unknown field or op in %q", raw)
	}
	lit, okValue := rcxFactValueByToken(field, parts[2])
	if !okValue {
		return fmt.Errorf("rcx: unknown value %q for field %q", parts[2], parts[0])
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
	if err := value.Decode(&wire); err != nil {
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
