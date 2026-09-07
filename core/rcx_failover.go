package main

import "time"

func (e *rcxEngine) applyProbeResult(event rcxEvent) {
	if event.Gen != e.probeGen || (event.ConfigGen != 0 && event.ConfigGen != e.configGen) || len(event.Results) == 0 {
		return
	}
	result := event.Results[0]
	now := e.runtime.Now()
	key := e.key(result.Node)
	e.probeResults = append(e.probeResults, result)
	e.probeStarted[result.Node] = struct{}{}
	attempts := result.Attempts
	if len(attempts) == 0 {
		e.ledger.NoteProbe(key, e.envKey, result.Role, result.Outcome, result.DelayMs, now)
	} else {
		for _, attempt := range attempts {
			negative := attempt.Outcome == rcxProbeFail || attempt.Outcome == rcxProbeStatusMismatch
			if negative && !e.chargesNegative(now) {
				continue
			}
			wasGood := e.ledger.PreviouslyGood(key, e.envKey)
			e.ledger.NoteMarkerProbe(key, e.envKey, result.Role, attempt.ID, attempt.Outcome, attempt.DelayMs, now)
			if negative && wasGood {
				e.noteMarkerFailure(attempt.ID, result.Node, now)
			}
		}
		e.ledger.RecomputeRole(key, e.envKey, result.Role, e.markerIDs(result.Role, now), now)
	}
	if result.Outcome == rcxProbeFail || result.Outcome == rcxProbeStatusMismatch {
		e.escrowNegative(result.Node, 0, now)
	}
	if result.Outcome == rcxProbeOK {
		e.noteProviderSuccess(result.Node)
		e.noteLinkAlive(now)
		e.rescueAt = time.Time{}
		if e.probeKind == rcxWaveIncident && result.Node == e.incumbent {
			e.closeIncident(now, true)
		}
		if e.probeKind == rcxWaveIncident && result.Node != e.incumbent && e.probeReplacement(result.Node, now) {
			e.reconsider()
			if e.probeCancel != nil {
				e.probeCancel()
			}
		}
	}
}

func (e *rcxEngine) probeReplacement(node string, now time.Time) bool {
	members := e.runtime.Members()
	candidates := e.candidates(members)
	input := rcxDecisionInput{
		Terrain:        e.terrainCurrent(),
		Incumbent:      e.incumbent,
		IncumbentSince: e.since,
		Pin:            e.pin(),
		Candidates:     candidates,
		Policy:         e.cfg.policy(),
		Now:            now,
	}
	for _, candidate := range candidates {
		if candidate.Name == node {
			return rcxEligible(candidate, input) && candidate.Facts.OpenWorld == rcxProofProven
		}
	}
	return false
}

func (e *rcxEngine) finishProbe() {
	now := e.runtime.Now()
	answered := false
	measured := map[string]struct{}{}
	for _, result := range e.probeResults {
		if result.Outcome != rcxProbeOverloaded {
			measured[result.Node] = struct{}{}
		}
		answered = answered || result.Outcome == rcxProbeOK
	}
	e.budget.Refund(e.paidWave - len(measured))
	e.paidWave = 0
	if answered {
		for _, result := range e.probeResults {
			if result.Outcome == rcxProbeFail {
				e.noteProviderNodeFailure(result.Node, now)
			}
		}
	}
	e.probing = false
	e.deep = false
	e.probeCancel = nil
	e.probeResults = nil
	e.probeStarted = map[string]struct{}{}
	e.reconsider()
	e.persist(false)
}

func (e *rcxEngine) watchIncumbent() {
	if !e.Enabled() || e.runtime.Mode() != "rule" || e.incumbent == "" {
		return
	}
	e.sampleTraffic()
	if !e.suspected(e.runtime.Now()) || e.probing {
		return
	}
	members := e.runtime.Members()
	if len(members) == 0 {
		return
	}
	e.startIncident(e.runtime.Now())
	e.startProbe(e.candidates(members), members, rcxWaveIncident)
}

func (e *rcxEngine) drainIDs(node string) []string {
	ids := make([]string, 0, len(e.incidentConns))
	for _, conn := range e.runtime.Connections() {
		if conn.Node != node {
			continue
		}
		if _, stalled := e.incidentConns[conn.Key]; stalled {
			ids = append(ids, conn.Key)
		}
	}
	e.incidentConns = map[string]struct{}{}
	return ids
}
