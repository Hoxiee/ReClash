package rcx

import (
	"fmt"
	"strings"
)

func (p rcxDecisionProfile) validateSize() error {
	if err := rcxPolicyDataSize(p.Ladder, p.Strategies, p.Admission, p.Settings); err != nil {
		return err
	}
	for _, layer := range p.Contexts.layers() {
		for _, rule := range layer {
			var ladder []rcxRungSpec
			var admission []rcxAdmitRule
			if rule.Set.Ladder != nil {
				ladder = *rule.Set.Ladder
			}
			if rule.Set.Admission != nil {
				admission = *rule.Set.Admission
			}
			if err := rcxPolicyDataSize(ladder, rule.Set.Strategies, admission, rule.Set.Settings); err != nil {
				return err
			}
		}
	}
	return nil
}

func rcxPolicyDataSize(ladder []rcxRungSpec, strategies map[string]rcxStrategyProfile, rules []rcxAdmitRule, settings *rcxSettingsPatch) error {
	if len(ladder) > int(rcxRungCount) || len(strategies) > 64 || len(rules) > 256 {
		return fmt.Errorf("rcx: too many ladder, strategy, or admission entries")
	}
	for name, strategy := range strategies {
		if strings.TrimSpace(name) == "" || len(name) > 128 || len(strategy.LatencyBands) > 32 || len(strategy.DropRungs) > int(rcxRungCount) {
			return fmt.Errorf("rcx: invalid strategy size or name %q", name)
		}
	}
	for _, rule := range rules {
		if len(rule.When) > 16 {
			return fmt.Errorf("rcx: at most 16 conditions per admission rule")
		}
	}
	if settings == nil {
		return nil
	}
	c := settings.value
	for name, count := range map[string]int{
		"canaryForeign": len(c.CanaryForeign), "canaryDomestic": len(c.CanaryDomestic),
		"censorSNI": len(c.CensorSNI), "openMarkers": len(c.OpenMarkers),
		"domesticMarkers": len(c.DomesticMarkers), "localMarkers": len(c.LocalMarkers),
		"egressEchoes": len(c.EgressEchoes), "countryEchoes": len(c.CountryEchoes),
	} {
		if count > 32 {
			return fmt.Errorf("rcx: %s exceeds 32 targets", name)
		}
	}
	if len(c.Lanes) > 32 || len(c.NodeRules) > 256 || len(c.LatencyBands) > 32 || len(c.NameHints) > 256 || len(c.BreakerPatterns) > 256 || len(c.CensorCountries) > 256 || len(c.AvoidCountries) > 256 {
		return fmt.Errorf("rcx: too many settings entries")
	}
	for _, lane := range c.Lanes {
		if len(lane.Selectors) > 64 {
			return fmt.Errorf("rcx: lane %q exceeds 64 selectors", lane.ID)
		}
	}
	return nil
}
