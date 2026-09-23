package doctor

import (
	"context"
	"time"
)

func (actor *doctorActor) handlePassive(evidence doctorEvidence) {
	if actor.snapshot.State == doctorExamining {
		return
	}
	listenerFailed := evidence.Code == "byeDpiListenerFailed" && evidence.Inbound == "byedpi"
	freshExam := actor.snapshot.ExamID != "" &&
		(actor.snapshot.State == doctorComplete || actor.snapshot.State == doctorInconclusive) &&
		actor.snapshot.FreshUntil > actor.now().UnixMilli()
	if freshExam && !listenerFailed {
		return
	}
	if actor.snapshot.State != doctorObserving {
		actor.resetObservation()
	}
	actor.snapshot.Scope = doctorScopeForEvidence(evidence)
	actor.appendEvidence(evidence)
	if doctorPassiveHealthEvidence(evidence, actor.pathContext()) {
		actor.snapshot.Health = doctorHealthy
		actor.snapshot.Confidence = doctorConfirmed
		actor.snapshot.CauseCode = ""
		actor.snapshot.Layer = ""
		actor.snapshot.FreshUntil = actor.now().Add(doctorEvidenceFreshFor).UnixMilli()
		actor.scheduleFreshnessExpiry()
	}
	if listenerFailed {
		actor.snapshot.Health = doctorBroken
		actor.snapshot.Confidence = doctorConfirmed
		actor.snapshot.CauseCode = evidence.Code
		actor.snapshot.Layer = evidence.Layer
		actor.snapshot.FreshUntil = actor.now().Add(doctorEvidenceFreshFor).UnixMilli()
		actor.scheduleFreshnessExpiry()
	}
	actor.snapshot.Severity = doctorSeverityFor(actor.snapshot.Health)
	actor.passiveDirty = true
	actor.schedulePassiveFlush()
}

func doctorPassiveHealthEvidence(evidence doctorEvidence, path doctorPathContext) bool {
	return (path.PathKind == doctorPathLocalProxy || path.PathKind == doctorPathDirect || path.PathKind == doctorPathByeDPI) &&
		evidence.Outcome == doctorOutcomeSucceeded && evidence.Confidence == doctorConfirmed && evidence.Layer == doctorLayerMarker
}

func (actor *doctorActor) resetObservation() {
	actor.ingressGate.reset()
	actor.snapshot.ExamID = ""
	actor.snapshot.Mode = ""
	actor.snapshot.State = doctorObserving
	actor.snapshot.Health = doctorUnknown
	actor.snapshot.Confidence = doctorInsufficient
	actor.snapshot.CauseCode = ""
	actor.snapshot.Layer = ""
	actor.snapshot.Scope = doctorScopeUnknown
	actor.snapshot.StartGenerations = doctorGenerations{}
	actor.snapshot.StartedAt = 0
	actor.snapshot.Progress = doctorProgress{}
	actor.snapshot.Severity = doctorSeverityInfo
	actor.snapshot.FreshUntil = 0
	actor.snapshot.EvidenceDropped = 0
	actor.snapshot.Evidence = []doctorEvidence{}
	actor.snapshot.Stages = doctorStages(nil, actor.pathContext(), false)
	actor.requireAppIngressProof = false
	actor.stopFreshnessTimer()
}

func (actor *doctorActor) stopFreshnessTimer() {
	actor.freshnessToken++
	if actor.freshnessTimer != nil {
		actor.freshnessTimer.Stop()
	}
}

func (actor *doctorActor) schedulePassiveFlush() {
	if actor.passiveFlushScheduled {
		return
	}
	actor.passiveFlushScheduled = true
	time.AfterFunc(doctorPassivePublishPeriod, func() {
		actor.sendCommand(context.Background(), doctorCommand{kind: doctorPassiveFlushCommand})
	})
}

func (actor *doctorActor) flushPassive() {
	if !actor.passiveDirty {
		return
	}
	actor.passiveDirty = false
	actor.changed()
}

func (actor *doctorActor) scheduleFreshnessExpiry() {
	actor.freshnessToken++
	token := actor.freshnessToken
	deadline := time.UnixMilli(actor.snapshot.FreshUntil)
	delay := deadline.Sub(actor.now())
	if delay < 0 {
		delay = 0
	}
	if actor.freshnessTimer == nil {
		actor.freshnessTimer = time.AfterFunc(delay, func() {
			actor.sendCommand(context.Background(), doctorCommand{kind: doctorFreshnessExpiredCommand, token: token})
		})
		return
	}
	actor.freshnessTimer.Stop()
	actor.freshnessTimer = time.AfterFunc(delay, func() {
		actor.sendCommand(context.Background(), doctorCommand{kind: doctorFreshnessExpiredCommand, token: token})
	})
}

func (actor *doctorActor) expireFreshness(token uint64) {
	if (token != 0 && token != actor.freshnessToken) || !actor.freshnessExpired() {
		return
	}
	actor.snapshot.Health = doctorUnknown
	actor.snapshot.Confidence = doctorInsufficient
	actor.snapshot.Severity = doctorSeverityInfo
	actor.snapshot.CauseCode = "staleEvidence"
	actor.snapshot.Layer = ""
	actor.snapshot.FreshUntil = 0
	actor.changed()
}

func (actor *doctorActor) applyPendingPlatformStatus() {
	if actor.pendingPlatform == nil {
		return
	}
	evidence := *actor.pendingPlatform
	actor.pendingPlatform = nil
	actor.handlePassive(evidence)
}
