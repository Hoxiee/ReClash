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
	actor.applyPassiveDialVerdict(evidence)
	actor.snapshot.Severity = doctorSeverityFor(actor.snapshot.Health)
	actor.passiveDirty = true
	actor.schedulePassiveFlush()
}

func doctorPassiveHealthEvidence(evidence doctorEvidence, path doctorPathContext) bool {
	return (path.PathKind == doctorPathLocalProxy || path.PathKind == doctorPathDirect || path.PathKind == doctorPathByeDPI) &&
		evidence.Outcome == doctorOutcomeSucceeded && evidence.Confidence == doctorConfirmed && evidence.Layer == doctorLayerMarker
}

// applyPassiveDialVerdict reads the free dial-result stream the witness already
// sees and turns a run of failed outer dials into a verdict, so the main screen
// shows a dead node without the user starting an exam. A succeeding dial or
// moving bytes clears the run (study §3.3: growing download lifts the blame).
// Confidence stays probable: nothing here proves the egress or rules out a
// leak the way the exam's marker does. The cause carries the triggering dial
// error class, already answered by the shared table. Scoped to VPN/TUN; other
// paths keep the marker-only health above.
func (actor *doctorActor) applyPassiveDialVerdict(evidence doctorEvidence) {
	path := actor.pathContext()
	if path.PathKind != doctorPathVPN && path.PathKind != doctorPathTun {
		return
	}
	switch {
	case passiveDialRecovered(evidence):
		cleared := actor.passiveDialFailures > 0
		actor.passiveDialFailures = 0
		if cleared && actor.passiveDialVerdictOwnsHealth() {
			actor.clearPassiveDialVerdict()
		}
	case passiveDialFailed(evidence):
		actor.passiveDialFailures++
		cause := evidence.Code
		if cause == "" {
			cause = "outerDialOther"
		}
		switch {
		case actor.passiveDialFailures >= doctorPassiveDialBrokenRun:
			actor.setPassiveDialVerdict(doctorBroken, cause)
		case actor.passiveDialFailures >= doctorPassiveDialDegradedRun:
			actor.setPassiveDialVerdict(doctorDegraded, cause)
		}
	}
}

// Only TCP dials condemn the link. QUIC/UDP dials fail benignly whenever a node
// or route carries TCP only; the app falls back to TCP and traffic flows, so a
// run of UDP failures must never read as a broken connection.
func passiveDialFailed(evidence doctorEvidence) bool {
	return evidence.Layer == doctorLayerDial && evidence.Network == "tcp" &&
		evidence.Outcome == doctorOutcomeFailed && evidence.Confidence == doctorConfirmed
}

func passiveDialRecovered(evidence doctorEvidence) bool {
	return evidence.Outcome == doctorOutcomeSucceeded && evidence.Confidence == doctorConfirmed &&
		(evidence.Code == "outerDialSucceeded" || evidence.Code == "trafficProgress")
}

// passiveDialVerdictOwnsHealth guards recovery so it only wipes a verdict the
// passive dial run itself raised, never a byeDPI listener fault or stray state.
func (actor *doctorActor) passiveDialVerdictOwnsHealth() bool {
	return actor.snapshot.Layer == doctorLayerDial &&
		(actor.snapshot.Health == doctorBroken || actor.snapshot.Health == doctorDegraded)
}

func (actor *doctorActor) setPassiveDialVerdict(health doctorHealth, cause string) {
	actor.snapshot.Health = health
	actor.snapshot.Confidence = doctorProbable
	actor.snapshot.CauseCode = cause
	actor.snapshot.Layer = doctorLayerDial
	actor.snapshot.FreshUntil = actor.now().Add(doctorEvidenceFreshFor).UnixMilli()
	actor.scheduleFreshnessExpiry()
}

func (actor *doctorActor) clearPassiveDialVerdict() {
	actor.snapshot.Health = doctorUnknown
	actor.snapshot.Confidence = doctorInsufficient
	actor.snapshot.CauseCode = ""
	actor.snapshot.Layer = ""
	actor.snapshot.FreshUntil = 0
	actor.stopFreshnessTimer()
}

func (actor *doctorActor) resetObservation() {
	actor.ingressGate.reset()
	actor.passiveDialFailures = 0
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
	doctorBlankStaleVerdict(&actor.snapshot)
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
