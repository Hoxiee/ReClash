package rcx

import "time"

func (e *rcxEngine) profileContext(config rcxConfig) rcxProfileContext {
	kind := e.terrainCurrent()
	name := e.terrain.name
	if name == "" || kind != e.terrain.terrain {
		name = kind.String()
	}
	context := rcxProfileContext{
		Region: rcxRegion(config), Terrain: name, TerrainKind: kind.String(),
		Transport: e.transport, Metered: e.metered, Validated: e.validated, Portal: e.portal,
	}
	if context.Transport == "" {
		context.Transport = "unknown"
	}
	if e.networkFacts != nil {
		context.Carrier, context.SSID = e.networkFacts.Carrier, e.networkFacts.SSID
	}
	return context
}

func (e *rcxEngine) refreshProfileContext() {
	compiled := e.cfg.compiled
	if compiled == nil {
		return
	}
	context := e.profileContext(compiled.base)
	selected := compiled.selection(context)
	if selected == e.cfg.activeLayers && context.Terrain == e.cfg.activeContext.Terrain {
		e.cfg.activeContext = context
		return
	}
	config := compiled.compose(context, selected)
	e.applyEffectiveConfig(config, false)
}

func (e *rcxEngine) updateEffectiveProfileReport() {
	if !e.cfg.profileState.Present {
		return
	}
	profile := e.cfg.profileValues()
	profile.Probe = e.effectiveProbe()
	profile.Probe.Metered = nil
	if data, err := profile.marshalYAML(); err == nil {
		e.cfg.profileState.Effective = string(data)
	}
}

func rcxDetectorFingerprint(section *rcxTerrainSection) string {
	if section == nil {
		return ""
	}
	detector := section.copy()
	detector.RefreshSeconds, detector.UrgentSeconds, detector.BackoffSeconds = 0, 0, 0
	detector.MaxAgeSeconds, detector.ConfirmationRounds = 0, 0
	detector.TimeoutMs, detector.WarmupMs = 0, 0
	for name, mode := range detector.States {
		mode.Admission = nil
		detector.States[name] = mode
	}
	data, err := (rcxDecisionProfile{Terrain: detector}).marshalYAML()
	if err != nil {
		return ""
	}
	return rcxFingerprint([]string{string(data)})
}

func (e *rcxEngine) terrainProbation() time.Duration {
	terrain := e.cfg.terrainRules()
	window := time.Duration(terrain.WarmupMs+terrain.TimeoutMs)*time.Millisecond + 2*time.Second
	if window < rcxSwitchProbation {
		return rcxSwitchProbation
	}
	return window
}
