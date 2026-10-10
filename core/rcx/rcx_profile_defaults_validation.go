package rcx

import (
	"fmt"
	"sort"
	"strings"

	yaml "go.yaml.in/yaml/v3"
)

func rcxLoadBuiltInProfile(data []byte) (rcxDecisionProfile, error) {
	profile, err := rcxDecisionProfileFromYAML(data)
	if err != nil {
		return profile, err
	}
	if profile.Schema != rcxProfileSchema {
		return profile, fmt.Errorf("built-in schema must be %d", rcxProfileSchema)
	}
	var fields map[string]yaml.Node
	if err := yaml.Unmarshal(data, &fields); err != nil {
		return profile, err
	}
	for _, key := range []string{"ladder", "strategies", "admission", "probe", "terrain", "settings"} {
		if _, ok := fields[key]; !ok {
			return profile, fmt.Errorf("built-in %s is missing", key)
		}
	}
	require := func(section string, keys []string) error {
		values := fields
		for _, part := range strings.Split(section, ".") {
			node, ok := values[part]
			if !ok {
				return fmt.Errorf("built-in %s is missing", section)
			}
			var child map[string]yaml.Node
			if err := node.Decode(&child); err != nil {
				return err
			}
			values = child
		}
		for _, key := range keys {
			if _, ok := values[key]; !ok {
				return fmt.Errorf("built-in %s.%s is missing", section, key)
			}
		}
		return nil
	}
	if err := require("probe", []string{"concurrency", "staggerMs", "budgetPerHour", "reserve"}); err != nil {
		return profile, err
	}
	settings := make([]string, 0, len(rcxSettingsFields))
	for name := range rcxSettingsFields {
		settings = append(settings, name)
	}
	sort.Strings(settings)
	if err := require("settings", settings); err != nil {
		return profile, err
	}
	if err := require("terrain", []string{"enabled", "checks", "rules", "states", "refreshSeconds", "urgentSeconds", "backoffSeconds", "maxAgeSeconds", "confirmationRounds", "timeoutMs", "warmupMs"}); err != nil {
		return profile, err
	}
	if !rcxValidLadder(profile.Ladder) || len(profile.Admission) == 0 {
		return profile, fmt.Errorf("built-in ladder/admission is invalid")
	}
	for _, name := range []string{rcxStrategyBalanced, rcxStrategyLatency, rcxStrategyStable, rcxStrategySaver} {
		if err := require("strategies."+name, []string{"bands", "switchAbsMs", "switchPct"}); err != nil {
			return profile, err
		}
		strategy, ok := profile.Strategies[name]
		if !ok || !rcxValidLatencyBands(strategy.LatencyBands) || strategy.SwitchAbsMs < 0 || strategy.SwitchAbsMs > rcxSwitchAbsMsMax || strategy.SwitchPct < 0 || strategy.SwitchPct > 100 {
			return profile, fmt.Errorf("built-in strategy %q is invalid", name)
		}
	}
	for _, probe := range []*rcxProbeSection{&profile.Probe, profile.Probe.Metered} {
		if probe == nil {
			continue
		}
		if probe.Concurrency < 1 || probe.Concurrency > rcxProbeConcurrencyMax || probe.StaggerMs < 0 || probe.StaggerMs > rcxProbeStaggerMsMax || probe.BudgetPerHour < rcxProbeBudgetFloor || probe.BudgetPerHour > rcxProbeBudgetCeil || probe.Reserve < rcxProbeReserveFloor || probe.Reserve > probe.BudgetPerHour/2 {
			return profile, fmt.Errorf("built-in probe bounds are invalid")
		}
	}
	c := profile.Settings.config()
	if c.DwellSeconds < 1 || c.DwellSeconds > 3600 || c.WaveWidth < 1 || c.WaveWidth > 64 || c.ProofTTLMinutes < 1 || c.ProofTTLMinutes > 1440 || c.DegradeConfirmSeconds < 1 || c.DegradeConfirmSeconds > 3600 || c.AbsCeilingMs < 1 || c.AbsCeilingMs > 5000 || c.ThrottleFloorKBps < 1 || c.ThrottleFloorKBps > 1024 {
		return profile, fmt.Errorf("built-in settings bounds are invalid")
	}
	if _, ok := profile.Strategies[c.Strategy]; !ok || c.SwitchImproveMs < 0 || c.SwitchImprovePct < 0 || c.LatencyStepMs < 0 {
		return profile, fmt.Errorf("built-in strategy settings are invalid")
	}
	for _, rung := range profile.Ladder {
		if rung.ID == rcxRungRecurrence && rung.RecurrenceFloor < 1 {
			return profile, fmt.Errorf("built-in recurrence floor is invalid")
		}
	}
	t := profile.Terrain
	if t.RefreshSeconds < 30 || t.RefreshSeconds > 3600 || t.UrgentSeconds < 5 || t.UrgentSeconds > 300 || t.BackoffSeconds < t.UrgentSeconds || t.BackoffSeconds > 3600 || t.MaxAgeSeconds < t.RefreshSeconds || t.MaxAgeSeconds > 7200 || t.ConfirmationRounds < 2 || t.ConfirmationRounds > 5 || t.TimeoutMs < 500 || t.TimeoutMs > 10000 || t.WarmupMs < t.TimeoutMs || t.WarmupMs > 15000 {
		return profile, fmt.Errorf("built-in terrain bounds are invalid")
	}
	for kind := rcxTerrainUnknown; kind <= rcxTerrainOffline; kind++ {
		if err := require("terrain.states."+kind.String(), []string{"kind"}); err != nil {
			return profile, err
		}
		if kind != rcxTerrainPortal && kind != rcxTerrainOffline {
			if err := require("terrain.states."+kind.String()+".admission", []string{"openWorldProven", "domesticProven", "breakerProven", "foreignPrior", "domesticPrior", "allowLastResort"}); err != nil {
				return profile, err
			}
		}
		state, ok := t.States[kind.String()]
		if !ok || state.Kind != kind || ((kind == rcxTerrainPortal || kind == rcxTerrainOffline) != (state.Admission == nil)) {
			return profile, fmt.Errorf("built-in terrain %s is invalid", kind)
		}
	}
	c.terrainProfile = profile.Terrain
	if err := profile.Contexts.validate(c); err != nil {
		return profile, err
	}
	return profile, nil
}
