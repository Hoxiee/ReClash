package doctor

import "slices"

var doctorLayerOrder = []doctorLayer{
	doctorLayerCapture,
	doctorLayerIngress,
	doctorLayerDNS,
	doctorLayerRoute,
	doctorLayerDial,
	doctorLayerTransport,
	doctorLayerMarker,
}

type doctorPathContext struct {
	PathKind     doctorPathKind
	CaptureState doctorCaptureState
}

type doctorVerdict struct {
	State      doctorExamState
	Health     doctorHealth
	Confidence doctorConfidence
	CauseCode  string
	Layer      doctorLayer
}

func reduceDoctorEvidence(facts []doctorEvidence, terminal bool, path doctorPathContext, requireAppIngressProof bool) doctorVerdict {
	if (path.PathKind == doctorPathVPN || path.PathKind == doctorPathTun) && path.CaptureState == doctorCaptureInactive {
		return doctorVerdict{State: doctorComplete, Health: doctorBroken, Confidence: doctorConfirmed, CauseCode: doctorInactiveCaptureCode(path.PathKind), Layer: doctorLayerCapture}
	}
	for _, layer := range doctorLayerOrder {
		for _, fact := range facts {
			if fact.Layer == layer && fact.Outcome == doctorOutcomeFailed && fact.Confidence == doctorConfirmed {
				return doctorVerdict{State: doctorComplete, Health: doctorBroken, Confidence: doctorConfirmed, CauseCode: fact.Code, Layer: layer}
			}
		}
	}
	for _, layer := range doctorLayerOrder {
		for _, fact := range facts {
			if fact.Layer == layer && fact.Outcome == doctorOutcomeFailed && fact.Confidence == doctorProbable {
				return doctorVerdict{State: doctorComplete, Health: doctorDegraded, Confidence: doctorProbable, CauseCode: fact.Code, Layer: layer}
			}
		}
	}
	hasEndToEndProof := slices.ContainsFunc(facts, func(fact doctorEvidence) bool {
		return fact.Layer == doctorLayerMarker && fact.Outcome == doctorOutcomeSucceeded && fact.Confidence == doctorConfirmed
	})
	hasAppIngressProof := slices.ContainsFunc(facts, func(fact doctorEvidence) bool {
		return fact.Layer == doctorLayerIngress && fact.Outcome == doctorOutcomeSucceeded &&
			fact.Confidence == doctorConfirmed && fact.Code == "appIngressMatched"
	})
	requiresIngress := requireAppIngressProof && (path.PathKind == doctorPathVPN || path.PathKind == doctorPathTun)
	if hasEndToEndProof && (!requiresIngress || (path.CaptureState == doctorCaptureActive && hasAppIngressProof)) &&
		path.PathKind != doctorPathUnknown {
		return doctorVerdict{State: doctorComplete, Health: doctorHealthy, Confidence: doctorConfirmed}
	}
	if terminal {
		return doctorVerdict{State: doctorInconclusive, Health: doctorUnknown, Confidence: doctorInsufficient, CauseCode: "insufficientEvidence"}
	}
	return doctorVerdict{State: doctorExamining, Health: doctorUnknown, Confidence: doctorInsufficient}
}

func doctorInactiveCaptureCode(path doctorPathKind) string {
	if path == doctorPathTun {
		return "tunNotActive"
	}
	return "vpnNotActive"
}

func doctorStages(facts []doctorEvidence, path doctorPathContext, terminal bool) []doctorStage {
	stages := []doctorStage{
		{ID: "app", State: doctorStageUnknown},
		{ID: "ingress", State: doctorStageUnknown},
		{ID: "route", State: doctorStageUnknown},
		{ID: "internet", State: doctorStageUnknown},
		{ID: "response", State: doctorStageUnknown},
	}
	switch path.PathKind {
	case doctorPathLocalProxy, doctorPathDirect, doctorPathByeDPI:
		stages[0].State = doctorStageNotApplicable
		stages[1].State = doctorStageNotApplicable
	case doctorPathVPN, doctorPathTun:
		if path.CaptureState == doctorCaptureInactive {
			stages[0] = doctorStage{ID: "app", State: doctorStageFailed, Layer: doctorLayerCapture, Code: doctorInactiveCaptureCode(path.PathKind)}
		} else if path.CaptureState == doctorCaptureActive {
			stages[0] = doctorStage{ID: "app", State: doctorStagePassed, Layer: doctorLayerCapture, Code: "captureActive"}
		}
	}
	for _, fact := range facts {
		index := doctorStageIndex(fact.Layer)
		if index < 0 || fact.Outcome == doctorOutcomeSeen || fact.Outcome == doctorOutcomeNotApplicable {
			continue
		}
		if fact.Consequence && fact.Outcome == doctorOutcomeFailed {
			stages[index] = doctorStage{ID: stages[index].ID, State: doctorStageConsequence, Layer: fact.Layer, Code: fact.Code}
			continue
		}
		if fact.Outcome == doctorOutcomeFailed {
			stages[index] = doctorStage{ID: stages[index].ID, State: doctorStageFailed, Layer: fact.Layer, Code: fact.Code}
			continue
		}
		if fact.Outcome == doctorOutcomeSucceeded && fact.Confidence == doctorConfirmed && doctorStageProves(fact, index) {
			stages[index] = doctorStage{ID: stages[index].ID, State: doctorStagePassed, Layer: fact.Layer, Code: fact.Code}
		}
	}
	if !terminal {
		for index := range stages {
			if stages[index].State == doctorStageUnknown {
				stages[index].State = doctorStageChecking
				break
			}
		}
	}
	return stages
}

func doctorStageIndex(layer doctorLayer) int {
	switch layer {
	case doctorLayerCapture:
		return 0
	case doctorLayerIngress:
		return 1
	case doctorLayerDNS, doctorLayerRoute:
		return 2
	case doctorLayerDial:
		return 3
	case doctorLayerTransport, doctorLayerMarker:
		return 4
	default:
		return -1
	}
}

func doctorStageProves(fact doctorEvidence, index int) bool {
	switch index {
	case 1:
		return fact.Code == "appIngressMatched"
	case 2:
		return fact.Code == "coreResolverSucceeded" || fact.Code == "routeResolved"
	case 3:
		return fact.Code == "outerDialSucceeded"
	case 4:
		return fact.Layer == doctorLayerMarker && fact.Code == "applicationProbeSucceeded"
	default:
		return false
	}
}

func markDoctorConsequences(facts []doctorEvidence, fault doctorLayer) {
	faultIndex := slices.Index(doctorLayerOrder, fault)
	for index := range facts {
		layerIndex := slices.Index(doctorLayerOrder, facts[index].Layer)
		facts[index].Consequence = faultIndex >= 0 && layerIndex > faultIndex && facts[index].Outcome == doctorOutcomeFailed
	}
}

func doctorSeverityFor(health doctorHealth) doctorSeverity {
	switch health {
	case doctorBroken:
		return doctorSeverityCritical
	case doctorDegraded:
		return doctorSeverityWarning
	default:
		return doctorSeverityInfo
	}
}
