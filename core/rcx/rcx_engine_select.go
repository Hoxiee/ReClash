package rcx

import (
	"time"
)

// A pick pins across a death and earns its return with a measurement; off, it hints.
func (e *rcxEngine) applyManualPick(node string, withSelect bool) {
	if node == "" {
		delete(e.snapshot.Pins, e.envKey)
		// The host already cleared the selector, so a hold would keep member zero.
		if e.incumbent != "" {
			_ = e.runtime.Select(e.incumbent)
		}
		e.reconsider()
		return
	}
	if withSelect || e.runtime.Selected() != node {
		if err := e.runtime.Select(node); err != nil {
			return
		}
	}
	e.supersedeProbe()
	e.supersedeWake()
	e.resetRescue()
	e.quality = rcxQualityCheck{}
	e.wantPick = ""
	e.pinWaveAt = time.Time{}
	e.incumbent = node
	e.since = e.runtime.Now()
	e.syncIdentity(e.runtime.Members())
	e.manualPick = rcxManualPick{Key: e.key(node), Environment: e.envKey, At: e.since}
	e.snapshot.Picks[e.envKey] = e.key(node)
	if e.cfg.RespectPick {
		e.snapshot.Pins[e.envKey] = e.key(node)
	} else {
		delete(e.snapshot.Pins, e.envKey)
	}
	e.reconsider()
}

// The pick is an endpoint, the selector speaks names, and a refresh renames it.
func (e *rcxEngine) pin() string {
	if e.snapshot == nil {
		return ""
	}
	return e.nameOf(e.snapshot.Pins[e.envKey])
}

func (e *rcxEngine) resolvePick() {
	if e.wantPick == "" {
		return
	}
	name := e.nameOf(e.wantPick)
	e.wantPick = ""
	if name != "" {
		e.incumbent = name
	}
}

func (e *rcxEngine) screenTargetEligible(node, incumbent string, lane *rcxLaneState, now time.Time) bool {
	members := e.runtime.Members()
	candidates := e.candidatesFor(members, incumbent)
	if lane != nil {
		byName := make(map[string]rcxMember, len(members))
		for _, member := range members {
			byName[member.Name] = member
		}
		groups := e.laneGroupSets(lane.config)
		for i := range candidates {
			member, ok := byName[candidates[i].Name]
			candidates[i].InSkeleton = ok && rcxLaneMatches(lane.config, member, groups) &&
				rcxLaneRoleAdmits(lane.config.Role, candidates[i].Facts)
		}
	}
	policy := e.cfg.policy()
	if lane != nil {
		policy = e.lanePolicy(lane.config)
	}
	input := rcxDecisionInput{
		Terrain: e.terrainCurrent(), Incumbent: incumbent, Candidates: candidates,
		Policy: policy, Now: now,
	}
	for _, candidate := range candidates {
		if candidate.Name == node {
			return rcxEligible(candidate, input) && candidate.Facts.OpenWorld == rcxProofProven
		}
	}
	return false
}

func (e *rcxEngine) tryAutomaticMainSelect(to string, reason rcxReason, now time.Time) bool {
	from := e.incumbent
	if to == "" || to == from {
		return false
	}
	if e.screenOff {
		if e.screenFailedOver || e.screenDead != from || !rcxDeathSwitch(reason) ||
			!e.screenTargetEligible(to, from, nil, now) {
			return false
		}
	}
	if !e.automaticMainAllowed(to, reason, now) {
		return false
	}
	if err := e.runtime.Select(to); err != nil {
		return false
	}
	if rcxDeathSwitch(reason) {
		e.runtime.CloseConnections(e.drainIDs(from))
	}
	e.noteSwitch(from, to, reason, now)
	if e.screenOff {
		e.screenFailedOver = true
		e.sealProbeDecision()
	}
	return true
}

func (e *rcxEngine) tryAutomaticLaneSelect(lane *rcxLaneState, to string, reason rcxReason, now time.Time) bool {
	from := lane.incumbent
	if to == "" || to == from {
		return false
	}
	if e.screenOff {
		if lane.screenFailoverUsed || lane.screenConfirmedDead != from || !rcxDeathSwitch(reason) ||
			!e.screenTargetEligible(to, from, lane, now) {
			return false
		}
	} else if !e.screenTargetEligible(to, from, lane, now) {
		return false
	}
	if err := e.runtime.SelectIn(lane.config.Group, to); err != nil {
		return false
	}
	lane.incumbent = to
	lane.since = now
	lane.switchedAt = now
	if e.snapshot != nil {
		picks := e.snapshot.LanePicks[lane.config.ID]
		if picks == nil {
			picks = map[string]string{}
			e.snapshot.LanePicks[lane.config.ID] = picks
		}
		picks[e.envKey] = e.key(to)
		e.snapshot.Dirty = true
	}
	if e.screenOff {
		lane.screenFailoverUsed = true
	}
	e.sealProbeDecision()
	return true
}

func (e *rcxEngine) sealProbeDecision() {
	e.probeDecisionClosed = true
	if e.probeCancel != nil {
		e.probeCancel()
	}
}

func (e *rcxEngine) reconsider() {
	if !e.Enabled() {
		e.publish(rcxReasonHold, nil, rcxDecisionInput{})
		return
	}
	if mode := e.runtime.Mode(); mode != "rule" {
		e.publish(rcxReasonHold, nil, rcxDecisionInput{})
		return
	}

	members := e.runtime.Members()
	if len(members) == 0 {
		e.publish(rcxReasonNoCandidate, nil, rcxDecisionInput{})
		return
	}

	now := e.runtime.Now()
	if e.incumbent == "" {
		e.incumbent = e.runtime.Selected()
	}
	e.reconsiderLanes(members, now)

	terrain := e.terrainCurrent()
	e.applyDirectSplit()

	candidates := e.candidates(members)
	e.resolvePick()
	pin := e.pin()
	input := rcxDecisionInput{
		Terrain:        terrain,
		Incumbent:      e.incumbent,
		IncumbentSince: e.since,
		Pin:            pin,
		Candidates:     candidates,
		Policy:         e.cfg.policy(),
		Now:            now,
	}
	decision := rcxDecide(input)
	if e.holdsManualPick() && decision.Reason != rcxReasonManualHold {
		e.verifyManualPick(members, now)
		decision = rcxDecision{Reason: rcxReasonManualHold, Detail: e.incumbent}
	}
	e.odometer.NoteAutoDecision()

	if decision.Reason == rcxReasonIncumbentDead && e.ledger.Stalled(e.key(e.incumbent), e.envKey) {
		decision.Reason = rcxReasonDegraded
	}

	// The measurement that settles a suspicion must precede the switch it buys.
	if decision.Switch && e.awaitsMeasurement(input) {
		e.startProbe(candidates, members, rcxWaveRoutine)
		if e.probing {
			decision.Switch = false
			decision.Reason = rcxReasonMeasuring
		}
	}

	if decision.Switch && decision.Reason == rcxReasonPinReturn && !rcxPinProven(input) {
		if !e.probing && (e.pinWaveAt.IsZero() || now.Sub(e.pinWaveAt) >= rcxPinWaveRetry) {
			e.pinWaveAt = now
			e.startProbe(candidates, members, rcxWaveRoutine)
		}
		decision.Switch = false
		decision.To = ""
		decision.Reason = rcxReasonHold
		if e.probing {
			decision.Reason = rcxReasonMeasuring
		}
	}

	if decision.Reason == rcxReasonQualityConfirming {
		e.queueQuality(decision.Detail)
	}

	if decision.Switch && e.holdsForLink(decision.Reason, now) {
		decision.Switch = false
		decision.Reason = rcxReasonMeasuring
	}

	// Verify a suspect winner before moving traffic onto it; cold start launches at once.
	if decision.Switch && e.incumbent != "" && decision.To != e.incumbent && e.wantsLocate(decision.To, now) {
		if e.startLocate(decision.To, now) {
			decision.Switch = false
			decision.Reason = rcxReasonMeasuring
		}
	}

	if decision.Switch && decision.To != e.incumbent {
		if e.tryAutomaticMainSelect(decision.To, decision.Reason, now) {
			input.Incumbent = decision.To
			input.IncumbentSince = now
		} else {
			decision.Switch = false
			decision.To = ""
			decision.Reason = rcxReasonHold
		}
	} else if !decision.Switch && decision.To == "" && (decision.Reason == rcxReasonHold || decision.Reason == rcxReasonManualHold) {
		e.reassertIncumbent()
	}

	if e.pendingHandoff && !e.probing && !e.screenOff && !e.suspended {
		if !e.awaitsHostSweep(now) {
			e.pendingHandoff = false
			e.startProbe(candidates, members, rcxWaveHandoff)
		}
	} else if e.pendingGrant && !e.probing && !e.screenOff && !e.suspended {
		e.pendingGrant = false
		e.startProbe(candidates, members, rcxWaveGrant)
	} else if e.needsProbe(decision, candidates) {
		kind := rcxWaveRoutine
		if decision.Reason == rcxReasonStranded || decision.Reason == rcxReasonNoCandidate {
			kind = rcxWaveRescue
		}
		if e.screenOffProbeAllowed(decision.Reason, now) {
			e.startProbe(candidates, members, kind)
		}
	}
	if e.probing && (decision.Reason == rcxReasonStranded || decision.Reason == rcxReasonNoCandidate) {
		decision.Reason = rcxReasonMeasuring
	}
	if !e.probing {
		e.queueLaneRecovery()
	}

	ranked := rcxRank(input)
	e.rebuildStandbys(ranked)
	e.publish(decision.Reason, ranked, input)
}

// A domestic canary that answers proves the direct path lives, while a home
// service through a foreign egress breaks: they tunnel only when it dies.
func (e *rcxEngine) applyDirectSplit() {
	if !e.Enabled() || e.screenOff {
		return
	}
	want := "DIRECT"
	if e.reachD == rcxProbeFail {
		want = rcxGroupNode
	}
	got := e.runtime.SelectedIn(rcxGroupDirect)
	if got == want {
		e.setDirectState(want)
		return
	}
	if err := e.runtime.SelectIn(rcxGroupDirect, want); err == nil {
		e.setDirectState(want)
	}
}

func (e *rcxEngine) setDirectState(selected string) {
	if selected == rcxGroupNode {
		e.direct = "node"
	} else {
		e.direct = "direct"
	}
}

// Mihomo rebuilds a selector at index 0, so even a hold must re-assert it.
func (e *rcxEngine) reassertIncumbent() {
	if e.incumbent == "" {
		return
	}
	if e.runtime.Selected() != e.incumbent {
		_ = e.runtime.Select(e.incumbent)
	}
}

// Connections on a buried node are already hung: closing lets the app redial.
func rcxDeathSwitch(reason rcxReason) bool {
	return reason == rcxReasonIncumbentDead || reason == rcxReasonDegraded
}

func (e *rcxEngine) noteSwitch(from, to string, reason rcxReason, now time.Time) {
	standby := false
	for _, key := range e.snapshot.Standbys[e.envKey] {
		standby = standby || key == e.key(to)
	}
	if rcxDeathSwitch(reason) {
		e.recordFailover(now, standby)
	}
	e.odometer.NoteCountry(e.ledger.ExitCountry(e.key(to)))
	e.incumbent = to
	e.since = now
	e.switchedAt = now
	// The pin died with the node; its successor must not inherit it.
	e.snapshot.Picks[e.envKey] = e.key(to)
	e.snapshot.Dirty = true
	e.history = append(e.history, rcxSwitchReport{
		From:   from,
		To:     to,
		Reason: string(reason),
		At:     rcxMillis(now),
	})
	if len(e.history) > rcxHistoryDepth {
		e.history = e.history[len(e.history)-rcxHistoryDepth:]
	}
}

// Five switches in five seconds are one dark uplink misread five times: the round
// in flight tells a dead node from a dead link, so the second switch waits for it.
func (e *rcxEngine) holdsForLink(reason rcxReason, now time.Time) bool {
	if !e.reaching || e.since.IsZero() {
		return false
	}
	if reason == rcxReasonPinReturn || reason == rcxReasonColdStart {
		return false
	}
	return now.Sub(e.since) < rcxSwitchProbation
}

func (e *rcxEngine) awaitsMeasurement(in rcxDecisionInput) bool {
	if !e.suspected(in.Now) {
		return false
	}
	for _, candidate := range in.Candidates {
		if candidate.Name != e.incumbent {
			continue
		}
		return rcxEligible(candidate, in)
	}
	return false
}

// An incumbent is disproven by the traffic it carries; a pin carries none, so
// only a measurement tells a recovery from a cooldown that merely expired.
func rcxPinProven(in rcxDecisionInput) bool {
	for _, candidate := range in.Candidates {
		if candidate.Name == in.Pin {
			return candidate.Facts.Transit == rcxProofProven
		}
	}
	return false
}

func (e *rcxEngine) suspected(now time.Time) bool {
	return e.incumbent != "" &&
		(e.ledger.Stalled(e.key(e.incumbent), e.envKey) ||
			e.ledger.Degraded(e.key(e.incumbent), e.envKey, now))
}

// Probes are bought, never scheduled: a decision that had nothing to go on, or
// one that could not route at all, is the only thing worth paying for.
func (e *rcxEngine) needsProbe(decision rcxDecision, candidates []rcxCandidate) bool {
	if e.probing {
		return false
	}
	switch decision.Reason {
	case rcxReasonNoCandidate, rcxReasonStranded, rcxReasonIncumbentDead,
		rcxReasonColdStart, rcxReasonDegraded:
		return true
	}
	// Holding a frozen incumbent is only correct while its probe is on the way.
	if e.incumbent != "" && e.ledger.Stalled(e.key(e.incumbent), e.envKey) {
		return true
	}
	for _, candidate := range candidates {
		if candidate.Name == e.incumbent {
			return candidate.Evidence == rcxEvidenceNone
		}
	}
	return e.incumbent == ""
}

// Screen-off, a reconsider buys a wave only to answer the incumbent's own death;
// a routine re-verify or an enable grant waits for the narrow wake probe so a
// dark link is never woken for a comfort measurement.
func (e *rcxEngine) screenOffProbeAllowed(reason rcxReason, now time.Time) bool {
	if !e.screenOff {
		return true
	}
	return rcxDeathSwitch(reason) || reason == rcxReasonStranded ||
		reason == rcxReasonNoCandidate || e.suspected(now)
}

// Domestic bytes are not open-world proof, so under censorship a live-but-unproven
// node keeps earning routine probes instead of latching as dead weight.
func (e *rcxEngine) openUnverified(c rcxCandidate) bool {
	return len(e.cfg.CensorCountries) > 0 && c.Facts.OpenWorld != rcxProofProven
}
