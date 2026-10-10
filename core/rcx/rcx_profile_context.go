package rcx

import (
	"fmt"
	"reflect"
	"strings"

	yaml "go.yaml.in/yaml/v3"
)

type rcxProbePatch struct {
	Concurrency   *int           `yaml:"concurrency,omitempty"`
	StaggerMs     *int           `yaml:"staggerMs,omitempty"`
	BudgetPerHour *int           `yaml:"budgetPerHour,omitempty"`
	Reserve       *int           `yaml:"reserve,omitempty"`
	Metered       *rcxProbePatch `yaml:"metered,omitempty"`
}

func (p *rcxProbePatch) apply(value rcxProbeSection) rcxProbeSection {
	if p == nil {
		return value
	}
	if p.Concurrency != nil {
		value.Concurrency = *p.Concurrency
	}
	if p.StaggerMs != nil {
		value.StaggerMs = *p.StaggerMs
	}
	if p.BudgetPerHour != nil {
		value.BudgetPerHour = *p.BudgetPerHour
	}
	if p.Reserve != nil {
		value.Reserve = *p.Reserve
	}
	if p.Metered != nil {
		metered := value
		if value.Metered != nil {
			metered = *value.Metered
		}
		metered.Metered = nil
		metered = p.Metered.apply(metered)
		value.Metered = &metered
	}
	return value
}

type rcxTerrainPatch struct {
	Enabled            *bool                     `yaml:"enabled,omitempty"`
	Checks             *[]string                 `yaml:"checks,omitempty"`
	Rules              *[]rcxTerrainRule         `yaml:"rules,omitempty"`
	States             map[string]rcxTerrainMode `yaml:"states,omitempty"`
	RefreshSeconds     *int                      `yaml:"refreshSeconds,omitempty"`
	UrgentSeconds      *int                      `yaml:"urgentSeconds,omitempty"`
	BackoffSeconds     *int                      `yaml:"backoffSeconds,omitempty"`
	MaxAgeSeconds      *int                      `yaml:"maxAgeSeconds,omitempty"`
	ConfirmationRounds *int                      `yaml:"confirmationRounds,omitempty"`
	TimeoutMs          *int                      `yaml:"timeoutMs,omitempty"`
	WarmupMs           *int                      `yaml:"warmupMs,omitempty"`
}

func (p *rcxTerrainPatch) apply(base *rcxTerrainSection) *rcxTerrainSection {
	if p == nil {
		return base
	}
	out := base.copy()
	if p.Enabled != nil {
		out.Enabled = *p.Enabled
	}
	if p.Checks != nil {
		out.Checks = append([]string(nil), (*p.Checks)...)
	}
	if p.Rules != nil {
		out.Rules = append([]rcxTerrainRule(nil), (*p.Rules)...)
	}
	for name, mode := range p.States {
		out.States[name] = mode
	}
	pairs := []struct {
		from *int
		to   *int
	}{
		{p.RefreshSeconds, &out.RefreshSeconds}, {p.UrgentSeconds, &out.UrgentSeconds},
		{p.BackoffSeconds, &out.BackoffSeconds}, {p.MaxAgeSeconds, &out.MaxAgeSeconds},
		{p.ConfirmationRounds, &out.ConfirmationRounds}, {p.TimeoutMs, &out.TimeoutMs},
		{p.WarmupMs, &out.WarmupMs},
	}
	for _, pair := range pairs {
		if pair.from != nil {
			*pair.to = *pair.from
		}
	}
	return out
}

type rcxProfilePatch struct {
	Settings   *rcxSettingsPatch             `yaml:"settings,omitempty"`
	Ladder     *[]rcxRungSpec                `yaml:"ladder,omitempty"`
	Strategies map[string]rcxStrategyProfile `yaml:"strategies,omitempty"`
	Admission  *[]rcxAdmitRule               `yaml:"admission,omitempty"`
	Probe      *rcxProbePatch                `yaml:"probe,omitempty"`
	Terrain    *rcxTerrainPatch              `yaml:"terrain,omitempty"`
}

type rcxContextRule struct {
	ID   string          `yaml:"id"`
	When []rcxSignalCond `yaml:"when,omitempty"`
	Set  rcxProfilePatch `yaml:"set"`
}

type rcxProfileContexts struct {
	Region  []rcxContextRule `yaml:"region,omitempty"`
	Terrain []rcxContextRule `yaml:"terrain,omitempty"`
	Network []rcxContextRule `yaml:"network,omitempty"`
}

func (p rcxProfileContexts) layers() [3][]rcxContextRule {
	return [3][]rcxContextRule{p.Region, p.Terrain, p.Network}
}

func (p rcxProfileContexts) validate(base rcxConfig) error {
	total := 0
	for layer, rules := range p.layers() {
		total += len(rules)
		ids := map[string]bool{}
		for _, rule := range rules {
			if !rcxValidLaneID(rule.ID) || ids[rule.ID] || len(rule.When) > 16 {
				return fmt.Errorf("rcx: invalid context rule %q", rule.ID)
			}
			ids[rule.ID] = true
			for _, condition := range rule.When {
				field := condition.field
				allowed := field == "region"
				if layer != 0 {
					allowed = allowed || (strings.HasPrefix(field, "network.") && field != "network.unvalidatedMs")
				}
				if layer == 1 {
					allowed = allowed || field == "terrain" || field == "terrain.kind"
				}
				if !allowed {
					return fmt.Errorf("rcx: context %q cannot read %q", rule.ID, field)
				}
			}
			if rule.Set.Probe != nil && rule.Set.Probe.Metered != nil && rule.Set.Probe.Metered.Metered != nil {
				return fmt.Errorf("rcx: nested metered variants in %q", rule.ID)
			}
			if layer == 1 {
				if rule.Set.Terrain != nil || rule.Set.Settings.changes("canaryForeign") || rule.Set.Settings.changes("canaryDomestic") || rule.Set.Settings.changes("censorSNI") {
					return fmt.Errorf("rcx: terrain context %q cannot change its detector", rule.ID)
				}
			}
			if rule.Set.Terrain != nil {
				if err := rule.Set.Terrain.apply(base.terrainRules()).validate(); err != nil {
					return fmt.Errorf("rcx: context %q: %w", rule.ID, err)
				}
			}
		}
	}
	if total > 32 {
		return fmt.Errorf("rcx: at most 32 context rules are supported")
	}
	return nil
}

func (p rcxProfilePatch) apply(c rcxConfig) rcxConfig {
	c = p.Settings.apply(c)
	if p.Ladder != nil {
		c.Ladder = append([]rcxRungSpec(nil), (*p.Ladder)...)
	}
	if len(p.Strategies) > 0 {
		strategies := rcxCopyStrategies(c.resolvedStrategies())
		for name, strategy := range p.Strategies {
			strategies[name] = strategy
		}
		c.strategyProfiles = strategies
	}
	if p.Admission != nil {
		c.admitRules = append([]rcxAdmitRule{}, (*p.Admission)...)
	}
	c.probePacing = p.Probe.apply(c.probe())
	c.terrainProfile = p.Terrain.apply(c.terrainRules())
	return c
}

type rcxCompiledProfile struct {
	base   rcxConfig
	export rcxDecisionProfile
}

func (p *rcxCompiledProfile) selection(context rcxProfileContext) [3]int {
	selected := [3]int{-1, -1, -1}
	signals := rcxSignals{context: context, terrain: rcxTerrainFacts{Validated: context.Validated, CaptivePortal: context.Portal}}
	for layer, rules := range p.export.Contexts.layers() {
		for index, rule := range rules {
			if rcxSignalStack(rule.When, signals) {
				selected[layer] = index
				break
			}
		}
	}
	return selected
}

func (p *rcxCompiledProfile) compose(context rcxProfileContext, selected [3]int) rcxConfig {
	c := p.base
	floor := c.CensorCountries
	c.profileState.Applied = nil
	c.profileState.Clamped = append([]string(nil), c.profileState.Clamped...)
	for layer, rules := range p.export.Contexts.layers() {
		if selected[layer] >= 0 {
			rule := rules[selected[layer]]
			c = rule.Set.apply(c)
			floor = rcxCountryFloor(c.CensorCountries, floor)
			c.profileState.Applied = append(c.profileState.Applied, rule.ID)
		}
	}
	if !reflect.DeepEqual(c.CensorCountries, floor) {
		c.profileState.Clamped = append(c.profileState.Clamped, "settings.censorCountries")
	}
	c.CensorCountries = floor
	c = c.boundResolvedProfile()
	c.activeContext, c.activeLayers, c.compiled = context, selected, p
	if mode, ok := c.terrainRules().States[context.Terrain]; ok {
		c.terrainAdmission = mode.Admission
	}
	c.updateProfileFingerprint()
	return c
}

func (c *rcxConfig) updateProfileFingerprint() {
	profile := c.profileValues()
	data, err := profile.marshalYAML()
	if err != nil {
		return
	}
	c.profileFingerprint = rcxFingerprint([]string{string(data)})
}

func (c rcxConfig) sourceConfig() rcxConfig {
	if c.compiled != nil {
		return c.compiled.base
	}
	return c
}

func (p *rcxProfilePatch) UnmarshalYAML(node *yaml.Node) error {
	type plain rcxProfilePatch
	var value plain
	if err := rcxDecodeNode(node, &value); err != nil {
		return err
	}
	*p = rcxProfilePatch(value)
	return nil
}
