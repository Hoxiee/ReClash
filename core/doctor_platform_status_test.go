package main

import (
	"testing"
	"time"
)

func TestDoctorPlatformStatusEvidence(t *testing.T) {
	tests := []struct {
		state      string
		outcome    doctorEvidenceOutcome
		confidence doctorConfidence
		code       string
	}{
		{state: "stopped", outcome: doctorOutcomeNotApplicable, confidence: doctorInsufficient, code: "byeDpiStopped"},
		{state: "starting", outcome: doctorOutcomeSeen, confidence: doctorInsufficient, code: "byeDpiStarting"},
		{state: "healthy", outcome: doctorOutcomeSucceeded, confidence: doctorConfirmed, code: "byeDpiListenerHealthy"},
		{state: "recovering", outcome: doctorOutcomeSeen, confidence: doctorInsufficient, code: "byeDpiRecovering"},
		{state: "failed", outcome: doctorOutcomeFailed, confidence: doctorConfirmed, code: "byeDpiListenerFailed"},
	}
	for _, test := range tests {
		fact, err := doctorEvidenceFromPlatformStatus(doctorPlatformStatus{State: test.state, Generation: 1, At: 1})
		if err != nil {
			t.Fatalf("state %q: %v", test.state, err)
		}
		if fact.Layer != doctorLayerCapture || fact.Inbound != "byedpi" || fact.Outcome != test.outcome || fact.Confidence != test.confidence || fact.Code != test.code {
			t.Errorf("state %q produced %+v", test.state, fact)
		}
	}
}

func TestDoctorPlatformStatusRejectsUnknownState(t *testing.T) {
	if _, err := doctorEvidenceFromPlatformStatus(doctorPlatformStatus{State: "unknown"}); err == nil {
		t.Fatal("unknown platform status was accepted")
	}
}

func TestDoctorPlatformStartingDoesNotBecomeConnectivityHealth(t *testing.T) {
	fact, err := doctorEvidenceFromPlatformStatus(doctorPlatformStatus{State: "starting"})
	if err != nil {
		t.Fatal(err)
	}
	actor := newDoctorActor(&fakeDoctorRuntime{}, nil)
	actor.Passive(fact)
	deadline := time.Now().Add(time.Second)
	for time.Now().Before(deadline) {
		snapshot := actor.Snapshot()
		if len(snapshot.Evidence) == 1 {
			if snapshot.Health != doctorUnknown || snapshot.Confidence != doctorInsufficient {
				t.Fatalf("snapshot = %+v", snapshot)
			}
			return
		}
		time.Sleep(time.Millisecond)
	}
	t.Fatal("platform status was not observed")
}

func TestDoctorPlatformStatusGenerationIsMonotonicAndIdempotent(t *testing.T) {
	actor := newDoctorActor(&fakeDoctorRuntime{}, nil)
	_, err := actor.request(doctorCommand{
		kind:     doctorPlatformStatusCommand,
		platform: doctorPlatformStatus{State: "healthy", Generation: 2, At: 1},
	})
	if err != nil {
		t.Fatal(err)
	}
	deadline := time.Now().Add(time.Second)
	for actor.Snapshot().Revision == 1 && time.Now().Before(deadline) {
		time.Sleep(time.Millisecond)
	}
	first := actor.Snapshot()
	for _, status := range []doctorPlatformStatus{
		{State: "failed", Generation: 1, At: 2},
		{State: "failed", Generation: 2, At: 3},
	} {
		if _, err := actor.request(doctorCommand{kind: doctorPlatformStatusCommand, platform: status}); err != nil {
			t.Fatal(err)
		}
	}
	current := actor.Snapshot()
	if current.Revision != first.Revision || current.Health != first.Health || len(current.Evidence) != len(first.Evidence) {
		t.Fatalf("first = %+v, current = %+v", first, current)
	}
}

func TestDoctorPlatformStatusRequiresGeneration(t *testing.T) {
	actor := newDoctorActor(&fakeDoctorRuntime{}, nil)
	if _, err := actor.request(doctorCommand{
		kind:     doctorPlatformStatusCommand,
		platform: doctorPlatformStatus{State: "healthy"},
	}); err == nil {
		t.Fatal("generation zero was accepted")
	}
}

func TestDoctorPlatformStatusDuringExamIsAppliedAfterCompletion(t *testing.T) {
	runtime := &fakeDoctorRuntime{release: make(chan struct{})}
	actor := newDoctorActor(runtime, nil)
	snapshot, err := actor.request(doctorCommand{kind: doctorStartCommand, start: doctorStartParams{Mode: doctorStandard}})
	if err != nil {
		t.Fatal(err)
	}
	if _, err := actor.request(doctorCommand{
		kind:     doctorPlatformStatusCommand,
		platform: doctorPlatformStatus{State: "failed", Generation: 1},
	}); err != nil {
		t.Fatal(err)
	}
	close(runtime.release)
	deadline := time.Now().Add(time.Second)
	for time.Now().Before(deadline) {
		current := actor.Snapshot()
		if current.ExamID == "" && current.CauseCode == "byeDpiListenerFailed" {
			if current.Health != doctorBroken || current.Confidence != doctorConfirmed {
				t.Fatalf("snapshot = %+v", current)
			}
			return
		}
		if current.ExamID != snapshot.ExamID && current.CauseCode != "byeDpiListenerFailed" {
			t.Fatalf("deferred status was lost: %+v", current)
		}
		time.Sleep(time.Millisecond)
	}
	t.Fatal("deferred platform status was not applied")
}

func TestDoctorPlatformStatusKeepsLatestUpdateDuringExam(t *testing.T) {
	runtime := &fakeDoctorRuntime{release: make(chan struct{})}
	actor := newDoctorActor(runtime, nil)
	_, _ = actor.request(doctorCommand{kind: doctorStartCommand, start: doctorStartParams{Mode: doctorStandard}})
	for _, status := range []doctorPlatformStatus{
		{State: "failed", Generation: 1},
		{State: "healthy", Generation: 2},
		{State: "failed", Generation: 1},
	} {
		if _, err := actor.request(doctorCommand{kind: doctorPlatformStatusCommand, platform: status}); err != nil {
			t.Fatal(err)
		}
	}
	close(runtime.release)
	deadline := time.Now().Add(time.Second)
	for time.Now().Before(deadline) {
		current := actor.Snapshot()
		if current.ExamID == "" && len(current.Evidence) == 1 {
			if current.Evidence[0].Code != "byeDpiListenerHealthy" || current.Health != doctorUnknown {
				t.Fatalf("snapshot = %+v", current)
			}
			return
		}
		time.Sleep(time.Millisecond)
	}
	t.Fatal("latest platform status was not applied")
}

func TestDoctorFailedByeDPIListenerIsScopedConfirmedFailure(t *testing.T) {
	actor := newDoctorActor(&fakeDoctorRuntime{}, nil)
	snapshot, err := actor.request(doctorCommand{
		kind:     doctorPlatformStatusCommand,
		platform: doctorPlatformStatus{State: "failed", Generation: 1},
	})
	if err != nil {
		t.Fatal(err)
	}
	if snapshot.Health != doctorBroken || snapshot.Confidence != doctorConfirmed ||
		snapshot.CauseCode != "byeDpiListenerFailed" || snapshot.Layer != doctorLayerCapture {
		t.Fatalf("snapshot = %+v", snapshot)
	}
}
