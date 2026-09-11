package main

import (
	"errors"
	"time"
)

type doctorPlatformStatus struct {
	State      string `json:"state"`
	Generation uint64 `json:"generation"`
	At         int64  `json:"at"`
}

func doctorEvidenceFromPlatformStatus(status doctorPlatformStatus) (doctorEvidence, error) {
	at := time.Now()
	if status.At > 0 {
		at = time.UnixMilli(status.At)
	}
	fact := doctorEvidence{
		Kind:       doctorEvidenceProbe,
		Layer:      doctorLayerCapture,
		Confidence: doctorInsufficient,
		Inbound:    "byedpi",
		at:         at,
	}
	switch status.State {
	case "stopped":
		fact.Outcome = doctorOutcomeNotApplicable
		fact.Code = "byeDpiStopped"
	case "starting":
		fact.Outcome = doctorOutcomeSeen
		fact.Code = "byeDpiStarting"
	case "healthy":
		fact.Outcome = doctorOutcomeSucceeded
		fact.Confidence = doctorConfirmed
		fact.Code = "byeDpiListenerHealthy"
	case "recovering":
		fact.Outcome = doctorOutcomeSeen
		fact.Code = "byeDpiRecovering"
	case "failed":
		fact.Outcome = doctorOutcomeFailed
		fact.Confidence = doctorConfirmed
		fact.Code = "byeDpiListenerFailed"
	default:
		return doctorEvidence{}, errors.New("unknown platform status")
	}
	return fact, nil
}

func (actor *doctorActor) handlePlatformStatus(status doctorPlatformStatus) error {
	if status.Generation == 0 {
		return errors.New("invalid platform generation")
	}
	if status.Generation <= actor.lastPlatformGeneration {
		return nil
	}
	evidence, err := doctorEvidenceFromPlatformStatus(status)
	if err != nil {
		return err
	}
	actor.lastPlatformGeneration = status.Generation
	if actor.snapshot.State == doctorExamining {
		actor.pendingPlatform = &evidence
		return nil
	}
	actor.handlePassive(evidence)
	return nil
}
