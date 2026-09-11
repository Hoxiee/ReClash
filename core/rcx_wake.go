package main

import (
	"context"
	"time"
)

var rcxWakeSettleDelay = rcxWakeSettle

func (e *rcxEngine) startWakeProbe() {
	if !e.Enabled() || e.runtime.Mode() != "rule" || e.incumbent == "" ||
		e.screenFailedOver || e.wakePending {
		return
	}
	markers := e.activeMarkers(rcxRoleOpen, e.runtime.Now())
	standby := e.selectWakeStandby(e.runtime.Now())
	if len(markers) == 0 || standby == "" {
		return
	}
	e.supersedeWake()
	e.wakePending = true
	e.wakeEpisode = e.screenEpisode
	e.wakeIncumbent = e.incumbent
	e.wakeStandby = standby
	gen := e.wakeGen
	configGen := e.configGen
	episode := e.screenEpisode
	incumbent := e.incumbent
	quit := e.quit
	ctx, cancel := context.WithTimeout(context.Background(), rcxWakeDeadline)
	e.wakeCancel = cancel
	safeGoDetached("rcx wake probe", func() {
		defer cancel()
		if !rcxWait(ctx, rcxWakeSettleDelay) {
			return
		}
		results := make(chan rcxWakeResult, 2)
		for _, node := range []string{incumbent, standby} {
			node := node
			safeGoDetached("rcx wake node", func() {
				results <- e.testWakeNode(ctx, node, markers)
			})
		}
		pair := make([]rcxWakeResult, 0, 2)
		for len(pair) < 2 {
			select {
			case result := <-results:
				pair = append(pair, result)
			case <-ctx.Done():
				for len(pair) < 2 {
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

func (e *rcxEngine) applyWakeResults(event rcxEvent) {
	if !e.wakePending || event.Gen != e.wakeGen || event.ConfigGen != e.configGen ||
		event.Episode != e.wakeEpisode || e.screenOff || e.incumbent != e.wakeIncumbent {
		return
	}
	if e.wakeCancel != nil {
		e.wakeCancel()
	}
	incumbent := e.wakeIncumbent
	standby := e.wakeStandby
	e.wakePending = false
	e.wakeCancel = nil
	var current, alternative rcxWakeResult
	for _, result := range event.Wake {
		switch result.Node {
		case incumbent:
			current = result
		case standby:
			alternative = result
		}
		if result.Outcome == rcxProbeOK {
			e.ledger.NoteProbe(e.key(result.Node), e.envKey, rcxRoleOpen, rcxProbeOK, result.DelayMs, e.runtime.Now())
			e.noteProviderSuccess(result.Node)
			e.noteLinkAlive(e.runtime.Now())
		}
	}
	if (current.Outcome == rcxProbeFail || current.Outcome == rcxProbeStatusMismatch) &&
		alternative.Outcome == rcxProbeOK && !e.screenFailedOver &&
		e.screenTargetEligible(standby, incumbent, nil, e.runtime.Now()) {
		e.screenDead = incumbent
		if e.tryAutomaticMainSelect(standby, rcxReasonIncumbentDead, e.runtime.Now()) {
			e.screenFailedOver = true
		} else {
			e.screenDead = ""
			e.reassertIncumbent()
		}
	} else {
		e.reassertIncumbent()
	}
	e.wakeIncumbent = ""
	e.wakeStandby = ""
	e.persist(false)
}
