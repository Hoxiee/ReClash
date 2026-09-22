package rcx

import (
	"context"
	"time"
)

var rcxWakeSettleDelay = rcxWakeSettle

func (e *rcxEngine) startWakeProbe() {
	if !e.Enabled() || e.runtime.Mode() != "rule" || e.incumbent == "" ||
		e.screenOff || e.suspended || e.screenFailedOver || e.wakePending {
		return
	}
	now := e.runtime.Now()
	markers := e.activeMarkers(rcxRoleOpen, now)
	standby := e.wakeProbeCandidate(now)
	if len(markers) == 0 {
		return
	}
	e.supersedeProbe()
	e.supersedeWake()
	e.wakePending = true
	e.wakeStartedAt = now
	e.wakeIncumbentKey = e.key(e.incumbent)
	e.wakeStandbyKey = e.key(standby)
	e.wakeEpisode = e.screenEpisode
	e.wakeIncumbent = e.incumbent
	e.wakeStandby = standby
	gen := e.wakeGen
	configGen := e.configGen
	episode := e.screenEpisode
	incumbent := e.incumbent
	quit := e.quit
	settleDelay := rcxWakeSettleDelay
	ctx, cancel := context.WithTimeout(context.Background(), rcxWakeDeadline)
	e.wakeCancel = cancel
	safeGoDetached("rcx wake probe", func() {
		defer cancel()
		if !rcxWait(ctx, settleDelay) {
			return
		}
		nodes := []string{incumbent}
		if standby != "" {
			nodes = append(nodes, standby)
		}
		results := make(chan rcxWakeResult, len(nodes))
		for _, node := range nodes {
			node := node
			safeGoDetached("rcx wake node", func() {
				results <- e.testWakeNode(ctx, node, markers)
			})
		}
		pair := make([]rcxWakeResult, 0, len(nodes))
		for len(pair) < len(nodes) {
			select {
			case result := <-results:
				pair = append(pair, result)
			case <-ctx.Done():
				for len(pair) < len(nodes) {
					pair = append(pair, rcxWakeResult{Outcome: rcxProbeOverloaded})
				}
			}
		}
		e.sendResult(rcxEvent{Kind: rcxEventWakeResults, Gen: gen, ConfigGen: configGen, Wake: pair, Episode: episode}, quit)
	})
}

func rcxWait(ctx context.Context, delay time.Duration) bool {
	timer := time.NewTimer(delay)
	defer timer.Stop()
	select {
	case <-timer.C:
		return true
	case <-ctx.Done():
		return false
	}
}

func (e *rcxEngine) testWakeNode(parent context.Context, node string, markers []rcxMarker) rcxWakeResult {
	ctx, cancel := context.WithTimeout(parent, rcxWakeTimeout)
	defer cancel()
	type answer struct {
		delay     int
		satisfied bool
		err       error
	}
	answers := make(chan answer, len(markers))
	for _, marker := range markers {
		marker := marker
		safeGoDetached("rcx wake marker", func() {
			delay, satisfied, err := e.runtime.Test(ctx, node, marker)
			answers <- answer{delay: delay, satisfied: satisfied, err: err}
		})
	}
	outcome := rcxProbeStatusMismatch
	for range markers {
		select {
		case answer := <-answers:
			if answer.err == nil && answer.satisfied {
				return rcxWakeResult{Node: node, Outcome: rcxProbeOK, DelayMs: answer.delay}
			}
			if answer.err != nil {
				outcome = rcxProbeFail
			}
		case <-ctx.Done():
			return rcxWakeResult{Node: node, Outcome: rcxProbeOverloaded}
		}
	}
	return rcxWakeResult{Node: node, Outcome: outcome}
}

func (e *rcxEngine) wakeProbeCandidate(now time.Time) string {
	if standby := e.selectWakeStandby(now); standby != "" {
		return standby
	}
	members := e.runtime.Members()
	eligible := make(map[string]bool, len(members))
	first := ""
	for _, member := range members {
		if member.key() == e.key(e.incumbent) || (e.cfg.policy().RequireUDP && !member.SupportsUDP) {
			continue
		}
		eligible[member.Name] = true
		if first == "" {
			first = member.Name
		}
	}
	for _, name := range e.standbyNames() {
		if eligible[name] {
			return name
		}
	}
	return first
}

func (e *rcxEngine) applyWakeResults(event rcxEvent) {
	if !e.wakePending || event.Gen != e.wakeGen || event.ConfigGen != e.configGen ||
		event.Episode != e.wakeEpisode || e.screenOff || e.suspended || e.incumbent != e.wakeIncumbent {
		return
	}
	e.syncIdentity(e.runtime.Members())
	if e.key(e.wakeIncumbent) != e.wakeIncumbentKey || e.key(e.wakeStandby) != e.wakeStandbyKey {
		e.supersedeWake()
		e.startWakeProbe()
		return
	}
	if e.wakeCancel != nil {
		e.wakeCancel()
	}
	incumbent, standby := e.wakeIncumbent, e.wakeStandby
	now := e.runtime.Now()
	e.wakePending = false
	e.wakeCancel = nil
	current := rcxWakeResult{Node: incumbent, Outcome: rcxProbeOverloaded}
	alternative := rcxWakeResult{Node: standby, Outcome: rcxProbeOverloaded}
	for _, result := range event.Wake {
		if result.Node == "" || (result.Node != incumbent && result.Node != standby) {
			continue
		}
		if result.Node == incumbent {
			current = result
		} else {
			alternative = result
		}
		if result.Outcome == rcxProbeOK {
			e.ledger.NoteProbe(e.key(result.Node), e.envKey, rcxRoleOpen, rcxProbeOK, result.DelayMs, now)
			e.noteProviderSuccess(result.Node)
			e.noteLinkAlive(now)
		}
	}
	alive := current.Outcome == rcxProbeOK || e.trafficSince(e.key(incumbent), e.wakeStartedAt, now)
	switched := false
	if !alive && (current.Outcome == rcxProbeFail || current.Outcome == rcxProbeStatusMismatch) &&
		alternative.Outcome == rcxProbeOK && !e.screenFailedOver &&
		e.screenTargetEligible(standby, incumbent, nil, now) {
		e.screenDead = incumbent
		switched = e.tryAutomaticMainSelect(standby, rcxReasonIncumbentDead, now)
		if switched {
			e.ledger.NoteProbe(e.key(incumbent), e.envKey, rcxRoleOpen, current.Outcome, 0, now)
		}
		e.screenDead = ""
	}
	e.reassertIncumbent()
	e.wakeIncumbent, e.wakeStandby = "", ""
	if !alive && !switched {
		e.resetRescue()
		members := e.runtime.Members()
		e.startProbe(e.candidates(members), members, rcxWaveIncident)
	}
	if switched {
		e.reconsider()
		if !e.probing {
			e.startImprovement(false)
		}
	}
	e.persist(false)
}
