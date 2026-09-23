package doctor

import "testing"

func TestReduceDoctorEvidenceChoosesTheLowestConfirmedFault(t *testing.T) {
	facts := []doctorEvidence{
		{Layer: doctorLayerDial, Outcome: doctorOutcomeFailed, Confidence: doctorConfirmed, Code: "dialTimeout"},
		{Layer: doctorLayerIngress, Outcome: doctorOutcomeFailed, Confidence: doctorConfirmed, Code: "captureMissed"},
	}

	verdict := reduceDoctorEvidence(facts, true, doctorPathContext{PathKind: doctorPathLocalProxy, CaptureState: doctorCaptureNotApplicable}, false)

	if verdict.Layer != doctorLayerIngress || verdict.CauseCode != "captureMissed" || verdict.Health != doctorBroken {
		t.Fatalf("verdict = %+v, want confirmed ingress failure", verdict)
	}
}

func TestReduceDoctorEvidenceDoesNotTurnAMissIntoAFault(t *testing.T) {
	verdict := reduceDoctorEvidence([]doctorEvidence{{
		Layer:      doctorLayerIngress,
		Outcome:    doctorOutcomeSeen,
		Confidence: doctorInsufficient,
		Code:       "noMatchedIngress",
	}}, true, doctorPathContext{PathKind: doctorPathLocalProxy, CaptureState: doctorCaptureNotApplicable}, false)

	if verdict.State != doctorInconclusive || verdict.Health != doctorUnknown || verdict.Confidence != doctorInsufficient {
		t.Fatalf("verdict = %+v, want inconclusive unknown", verdict)
	}
}

func TestReduceDoctorEvidenceAcceptsConfirmedApplicationProof(t *testing.T) {
	verdict := reduceDoctorEvidence([]doctorEvidence{{
		Layer:      doctorLayerMarker,
		Outcome:    doctorOutcomeSucceeded,
		Confidence: doctorConfirmed,
	}}, true, doctorPathContext{PathKind: doctorPathLocalProxy, CaptureState: doctorCaptureNotApplicable}, false)

	if verdict.State != doctorComplete || verdict.Health != doctorHealthy || verdict.Confidence != doctorConfirmed {
		t.Fatalf("verdict = %+v, want confirmed healthy", verdict)
	}
}

func TestMarkDoctorConsequencesOnlyMarksHigherFailures(t *testing.T) {
	facts := []doctorEvidence{
		{Layer: doctorLayerIngress, Outcome: doctorOutcomeFailed},
		{Layer: doctorLayerDial, Outcome: doctorOutcomeFailed},
		{Layer: doctorLayerTransport, Outcome: doctorOutcomeSucceeded},
	}

	markDoctorConsequences(facts, doctorLayerIngress)

	if facts[0].Consequence || !facts[1].Consequence || facts[2].Consequence {
		t.Fatalf("consequences = %+v", facts)
	}
}

func TestReduceDoctorEvidenceRequiresMatchedAppIngressWhenAvailable(t *testing.T) {
	facts := []doctorEvidence{{
		Layer: doctorLayerMarker, Outcome: doctorOutcomeSucceeded, Confidence: doctorConfirmed,
	}}
	verdict := reduceDoctorEvidence(facts, true, doctorPathContext{PathKind: doctorPathVPN, CaptureState: doctorCaptureActive}, true)
	if verdict.State != doctorInconclusive || verdict.Health != doctorUnknown || verdict.Confidence != doctorInsufficient {
		t.Fatalf("verdict = %+v, want inconclusive without app ingress", verdict)
	}
	facts = append(facts, doctorEvidence{
		Layer: doctorLayerIngress, Outcome: doctorOutcomeSucceeded,
		Confidence: doctorConfirmed, Code: "appIngressMatched",
	})
	verdict = reduceDoctorEvidence(facts, true, doctorPathContext{PathKind: doctorPathVPN, CaptureState: doctorCaptureActive}, true)
	if verdict.State != doctorComplete || verdict.Health != doctorHealthy || verdict.Confidence != doctorConfirmed {
		t.Fatalf("verdict = %+v, want confirmed healthy", verdict)
	}
}

func TestReduceDoctorEvidenceDoesNotRequireUnavailableAppIngressProof(t *testing.T) {
	facts := []doctorEvidence{{
		Layer: doctorLayerMarker, Outcome: doctorOutcomeSucceeded,
		Confidence: doctorConfirmed, Code: "applicationProbeSucceeded",
	}}
	verdict := reduceDoctorEvidence(facts, true, doctorPathContext{
		PathKind: doctorPathTun, CaptureState: doctorCaptureActive,
	}, false)

	if verdict.State != doctorComplete || verdict.Health != doctorHealthy || verdict.Confidence != doctorConfirmed {
		t.Fatalf("verdict = %+v, want confirmed healthy without unavailable ingress proof", verdict)
	}
}

func TestReduceDoctorEvidencePathMatrix(t *testing.T) {
	marker := []doctorEvidence{{Layer: doctorLayerMarker, Outcome: doctorOutcomeSucceeded, Confidence: doctorConfirmed, Code: "applicationProbeSucceeded"}}
	for _, test := range []struct {
		name     string
		path     doctorPathContext
		evidence []doctorEvidence
		health   doctorHealth
		cause    string
	}{
		{name: "inactive vpn", path: doctorPathContext{PathKind: doctorPathVPN, CaptureState: doctorCaptureInactive}, evidence: marker, health: doctorBroken, cause: "vpnNotActive"},
		{name: "active vpn requires ingress", path: doctorPathContext{PathKind: doctorPathVPN, CaptureState: doctorCaptureActive}, evidence: marker, health: doctorUnknown, cause: "insufficientEvidence"},
		{name: "active vpn matched", path: doctorPathContext{PathKind: doctorPathVPN, CaptureState: doctorCaptureActive}, evidence: append(marker, doctorEvidence{Layer: doctorLayerIngress, Outcome: doctorOutcomeSucceeded, Confidence: doctorConfirmed, Code: "appIngressMatched"}), health: doctorHealthy},
		{name: "local proxy", path: doctorPathContext{PathKind: doctorPathLocalProxy, CaptureState: doctorCaptureNotApplicable}, evidence: marker, health: doctorHealthy},
		{name: "unknown", path: doctorPathContext{PathKind: doctorPathUnknown, CaptureState: doctorCaptureUnknown}, evidence: marker, health: doctorUnknown, cause: "insufficientEvidence"},
	} {
		t.Run(test.name, func(t *testing.T) {
			verdict := reduceDoctorEvidence(test.evidence, true, test.path, test.path.PathKind == doctorPathVPN || test.path.PathKind == doctorPathTun)
			if verdict.Health != test.health || verdict.CauseCode != test.cause {
				t.Fatalf("verdict = %+v", verdict)
			}
		})
	}
}

func TestDoctorStagesKeepOnlyCurrentStageChecking(t *testing.T) {
	stages := doctorStages([]doctorEvidence{{Layer: doctorLayerDNS, Outcome: doctorOutcomeSucceeded, Confidence: doctorConfirmed, Code: "coreResolverSucceeded"}}, doctorPathContext{PathKind: doctorPathVPN, CaptureState: doctorCaptureActive}, false)
	checking := 0
	for _, stage := range stages {
		if stage.State == doctorStageChecking {
			checking++
		}
	}
	if checking != 1 || stages[0].State != doctorStagePassed || stages[2].State != doctorStagePassed {
		t.Fatalf("stages = %+v", stages)
	}
}

func TestDoctorStagesPreserveFaultAndConsequences(t *testing.T) {
	facts := []doctorEvidence{
		{Layer: doctorLayerCapture, Outcome: doctorOutcomeFailed, Confidence: doctorConfirmed, Code: "noPhysicalNetwork"},
		{Layer: doctorLayerMarker, Outcome: doctorOutcomeFailed, Confidence: doctorProbable, Code: "applicationProbeFailed"},
	}
	markDoctorConsequences(facts, doctorLayerCapture)
	stages := doctorStages(facts, doctorPathContext{PathKind: doctorPathVPN, CaptureState: doctorCaptureActive}, true)
	if stages[0].State != doctorStageFailed || stages[4].State != doctorStageConsequence {
		t.Fatalf("stages = %+v", stages)
	}
}
