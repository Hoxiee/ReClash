package main

import "time"

func (e *rcxEngine) applyProbeResult(event rcxEvent) {
	if event.Gen != e.probeGen || event.Lane != e.probeLane ||
		(event.ConfigGen != 0 && event.ConfigGen != e.configGen) || len(event.Results) == 0 {
		return
	}
	result := event.Results[0]
	currentKey := ""
	for _, member := range e.runtime.Members() {
		if member.Name == result.Node {
			currentKey = member.key()
			break
		}
	}
	if currentKey == "" || result.Key != "" && result.Key != currentKey {
		return
	}
	now := e.runtime.Now()
	key := currentKey
	negative := result.Outcome == rcxProbeFail || result.Outcome == rcxProbeStatusMismatch
	charge := !negative || e.chargesNegative(now)
	if result.ExitCountry != "" {
		e.ledger.SetExit(key, result.ExitCountry, e.sideOf(result.ExitCountry), now)
	}
	e.probeResults = append(e.probeResults, rcxProbeResult{
		Node: result.Node, Key: result.Key, Role: result.Role, Fingerprint: result.Fingerprint,
		Outcome: result.Outcome, DelayMs: result.DelayMs, Attempts: result.Attempts,
		ExitCountry: result.ExitCountry, chargeNegative: charge,
	})
	e.probeStarted[result.Node] = struct{}{}
	attempts := result.Attempts
	if len(attempts) == 0 {
		if charge {
			e.ledger.NoteProbe(key, e.envKey, result.Role, result.Outcome, result.DelayMs, now)
		}
	} else {
		applied := false
		for _, attempt := range attempts {
			attemptNegative := attempt.Outcome == rcxProbeFail || attempt.Outcome == rcxProbeStatusMismatch
			if attemptNegative && !e.chargesNegative(now) {
				continue
			}
			wasGood := e.ledger.PreviouslyGood(key, e.envKey)
			e.ledger.NoteMarkerProbe(key, e.envKey, result.Role, attempt.ID, attempt.Outcome, attempt.DelayMs, now)
			applied = true
			if attemptNegative && wasGood {
				e.noteMarkerFailure(attempt.ID, result.Node, now)
			}
		}
		if applied {
			e.ledger.RecomputeRole(key, e.envKey, result.Role, e.markerIDs(result.Role, now), now)
		}
	}
	if negative && charge {
		e.escrowNegative(result.Node, 0, now)
		e.recordProbeDeath(result)
	}
	if result.Outcome == rcxProbeOK {
		e.witnessWhitelist(result.Role)
		e.noteProviderSuccess(result.Node)
		e.noteLinkAlive(now)
		if event.Lane != "" {
			lane := e.lanes[event.Lane]
			if !e.probeDecisionClosed && lane != nil && result.Role == rcxRoleOpen &&
				e.laneProbeReplacement(lane, result.Node, now) {
				reason := rcxReasonIncumbentDead
				if e.tryAutomaticLaneSelect(lane, result.Node, reason, now) {
					delete(e.laneProbeSeen, event.Lane)
					e.probeRecovered = true
				}
			}
			return
		}
		recovered := e.provesOpenRecovery(result.Node, now)
		if !e.probeDecisionClosed && e.recoveryWave() && recovered {
			if result.Node == e.incumbent {
				e.probeRecovered = true
				e.resetRescue()
				if e.probeKind == rcxWaveIncident {
					e.closeIncident(now, true)
				}
				e.sealProbeDecision()
				return
			}
			if e.screenOff && e.screenDead != e.incumbent {
				return
			}
			if e.tryAutomaticMainSelect(result.Node, rcxReasonIncumbentDead, now) {
				e.probeRecovered = true
				e.resetRescue()
				e.sealProbeDecision()
			}
		}
	}
}

func (e *rcxEngine) recordProbeDeath(result rcxProbeResult) {
	if !e.probeScreenOff || e.probeScreenEpisode != e.screenEpisode || e.probeDecisionClosed ||
		result.Node != e.probeIncumbent || result.Role != rcxRoleOpen ||
		(result.Outcome != rcxProbeFail && result.Outcome != rcxProbeStatusMismatch) {
		return
	}
	if e.probeLane == "" {
		e.screenDead = result.Node
		return
	}
	if lane := e.lanes[e.probeLane]; lane != nil {
		lane.screenConfirmedDead = result.Node
	}
}

func (e *rcxEngine) provesOpenRecovery(node string, now time.Time) bool {
	candidates := e.candidates(e.runtime.Members())
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
	measured := map[string]struct{}{}
	for _, result := range e.probeResults {
		if result.Outcome != rcxProbeOverloaded {
			measured[result.Node] = struct{}{}
		}
	}
	if e.paidWaveGen == e.probeGen {
		e.budget.Refund(e.paidWave - len(measured))
	}
	e.paidWave = 0
	e.paidWaveGen = e.probeGen
	for _, result := range e.probeResults {
		if result.chargeNegative &&
			(result.Outcome == rcxProbeFail || result.Outcome == rcxProbeStatusMismatch) {
			e.noteProviderNodeFailure(result.Node, now)
		}
	}
	lane := e.probeLane
	recovery := e.recoveryWave()
	continueRecovery := lane == "" && recovery && !e.probeRecovered && !e.probeDecisionClosed && !e.rescueExhausted
	continueLane := lane != "" && !e.probeRecovered && !e.probeDecisionClosed
	if recovery && !e.probeRecovered && e.rescueExhausted {
		e.rescueAt = now
	}
	decisionClosed := e.probeDecisionClosed
	e.probing = false
	e.deep = false
	e.probeCancel = nil
	e.probeResults = nil
	e.probeStarted = map[string]struct{}{}
	e.probeRecovered = false
	e.probeDecisionClosed = false
	e.probeLane = ""
	if continueRecovery {
		members := e.runtime.Members()
		if len(members) > 0 {
			e.startProbe(e.candidates(members), members, rcxWaveRescue)
		}
	} else if continueLane {
		if state := e.lanes[lane]; state != nil {
			members := e.runtime.Members()
			if len(members) > 0 && !e.startLaneProbe(state, members) {
				e.queueLaneRecovery()
			}
		}
	}
	if !decisionClosed {
		e.reconsider()
	}
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
