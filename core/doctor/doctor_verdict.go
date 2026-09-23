package doctor

import (
	"slices"
	"strings"
)

func (actor *doctorActor) updateExamVerdict() {
	verdict := reduceDoctorEvidence(actor.snapshot.Evidence, false, actor.pathContext(), actor.requiresAppIngressProof())
	actor.snapshot.Health = verdict.Health
	actor.snapshot.Confidence = verdict.Confidence
	actor.snapshot.CauseCode = verdict.CauseCode
	actor.snapshot.Layer = verdict.Layer
	actor.snapshot.Severity = doctorSeverityFor(verdict.Health)
	actor.snapshot.Progress.Completed = doctorCompletedProbeCount(actor.snapshot.Evidence, actor.requireAppIngressProof)
	if verdict.Layer != "" {
		markDoctorConsequences(actor.snapshot.Evidence, verdict.Layer)
	}
	actor.snapshot.Stages = doctorStages(actor.snapshot.Evidence, actor.pathContext(), false)
}

func doctorCompletedProbeCount(evidence []doctorEvidence, requireAppIngressProof bool) int {
	completed := 0
	if slices.ContainsFunc(evidence, func(fact doctorEvidence) bool {
		return fact.Code == "coreResolverSucceeded" || strings.HasPrefix(fact.Code, "coreResolver")
	}) {
		completed++
	}
	if slices.ContainsFunc(evidence, func(fact doctorEvidence) bool {
		return fact.Code == "systemResolverSucceeded" || strings.HasPrefix(fact.Code, "systemResolver")
	}) {
		completed++
	}
	if requireAppIngressProof && slices.ContainsFunc(evidence, func(fact doctorEvidence) bool {
		return (fact.Layer == doctorLayerIngress && fact.Kind == doctorEvidenceProbe) || fact.Code == "appIngressMatched"
	}) {
		completed++
	}
	if slices.ContainsFunc(evidence, func(fact doctorEvidence) bool {
		return fact.Layer == doctorLayerMarker && strings.HasPrefix(fact.Code, "applicationProbe")
	}) {
		completed++
	}
	return completed
}

func (actor *doctorActor) appIngressProofAvailable() bool {
	if !actor.snapshot.Capabilities.TunIngressProof {
		return false
	}
	provider, ok := actor.runtime.(interface{ DoctorAppIngressAvailable() bool })
	return ok && provider.DoctorAppIngressAvailable()
}

func (actor *doctorActor) requiresAppIngressProof() bool {
	return actor.requireAppIngressProof
}

func (actor *doctorActor) applyVerdict(terminal bool) {
	verdict := reduceDoctorEvidence(actor.snapshot.Evidence, terminal, actor.pathContext(), actor.requiresAppIngressProof())
	actor.snapshot.State = verdict.State
	actor.snapshot.Health = verdict.Health
	actor.snapshot.Confidence = verdict.Confidence
	actor.snapshot.CauseCode = verdict.CauseCode
	actor.snapshot.Layer = verdict.Layer
	actor.snapshot.Severity = doctorSeverityFor(verdict.Health)
	if verdict.Layer != "" {
		markDoctorConsequences(actor.snapshot.Evidence, verdict.Layer)
	}
	actor.snapshot.Stages = doctorStages(actor.snapshot.Evidence, actor.pathContext(), terminal)
	if terminal {
		actor.snapshot.Progress.Phase = "complete"
		actor.snapshot.Progress.Completed = actor.snapshot.Progress.Total
		actor.snapshot.FreshUntil = actor.now().Add(doctorEvidenceFreshFor).UnixMilli()
		actor.scheduleFreshnessExpiry()
	}
}
