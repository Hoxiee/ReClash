package main

import "time"

const rcxReasonHandoff rcxReason = "handoff-recovery"

func (e *rcxEngine) recoveryReason() rcxReason {
	if e.probeKind == rcxWaveHandoff {
		return rcxReasonHandoff
	}
	return rcxReasonIncumbentDead
}

func (e *rcxEngine) trafficSince(key string, since, now time.Time) bool {
	traffic := e.ledger.TrafficAt(key, e.envKey)
	return !traffic.IsZero() && !traffic.Before(e.envSince) && !traffic.Before(since) && now.Sub(traffic) <= time.Minute
}

func (e *rcxEngine) probeRefutesIncumbent(now time.Time) bool {
	if e.trafficSince(e.key(e.incumbent), e.probeLaunchedAt, now) {
		return false
	}
	for _, r := range e.probeResults {
		if r.Node == e.incumbent && r.Role == rcxRoleOpen && (r.Outcome == rcxProbeFail || r.Outcome == rcxProbeStatusMismatch) {
			return true
		}
	}
	return false
}

func (e *rcxEngine) recoveryCanReplace(now time.Time) bool {
	if e.incumbent == "" {
		return true
	}
	key := e.key(e.incumbent)
	if e.trafficSince(key, e.probeLaunchedAt, now) {
		return false
	}
	if e.probeRefutesIncumbent(now) {
		return true
	}
	proof := e.ledger.ProbeGoodAt(key, e.envKey)
	if !proof.IsZero() && !proof.Before(e.envSince) && now.Sub(proof) <= time.Minute {
		return false
	}
	if e.probeKind == rcxWaveHandoff {
		return true
	}
	return e.suspected(now) || e.ledger.Facts(key, e.envKey, false, now, e.ledger.ProofTTL()).Transit == rcxProofDisproven
}

func (e *rcxEngine) automaticMainAllowed(to string, reason rcxReason, now time.Time) bool {
	wakeDeath := e.screenDead == e.incumbent && rcxDeathSwitch(reason)
	if e.wakePending && !wakeDeath {
		return false
	}
	if to != e.incumbent && e.holdsManualPick() && !wakeDeath && !e.probeRefutesIncumbent(now) {
		return false
	}
	input := rcxDecisionInput{Terrain: e.terrainCurrent(), Incumbent: e.incumbent, Pin: e.pin(), Policy: e.cfg.policy(), Now: now}
	target := false
	for _, c := range e.candidates(e.runtime.Members()) {
		if c.Name == to {
			target = rcxEligible(c, input)
		}
		if c.Name == input.Pin && c.Name == input.Incumbent && c.Name != to && rcxEligible(c, input) {
			if !wakeDeath && (!e.recoveryWave() || !e.recoveryCanReplace(now)) {
				return false
			}
		}
	}
	if !target {
		return false
	}
	if reason != rcxReasonHandoff && e.holdsForLink(reason, now) {
		return false
	}
	return true
}
