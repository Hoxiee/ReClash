package doctor

import (
	"testing"
	"time"
)

func newPassiveDialActor(t *testing.T, now *time.Time) *doctorActor {
	t.Helper()
	actor := newDoctorActor(&fakeDoctorRuntime{}, nil)
	actor.now = func() time.Time { return *now }
	actor.setPathContext(doctorPathContext{PathKind: doctorPathTun, CaptureState: doctorCaptureActive})
	return actor
}

func dialFailed() doctorEvidence {
	return doctorEvidence{
		Kind: doctorEvidenceOuterDial, Layer: doctorLayerDial,
		Outcome: doctorOutcomeFailed, Confidence: doctorConfirmed, Code: "outerDialTimeout",
	}
}

func dialSucceeded() doctorEvidence {
	return doctorEvidence{
		Kind: doctorEvidenceOuterDial, Layer: doctorLayerDial,
		Outcome: doctorOutcomeSucceeded, Confidence: doctorConfirmed, Code: "outerDialSucceeded",
	}
}

func feedPassive(actor *doctorActor, now *time.Time, fact doctorEvidence) doctorSnapshot {
	*now = now.Add(time.Second)
	actor.handlePassive(fact)
	actor.flushPassive()
	return actor.Snapshot()
}

func TestPassiveDialRunRaisesDegradedThenBroken(t *testing.T) {
	now := time.Unix(1_700_000_000, 0)
	actor := newPassiveDialActor(t, &now)

	if snapshot := feedPassive(actor, &now, dialFailed()); snapshot.Health != doctorUnknown {
		t.Fatalf("first failure health = %q, want unknown", snapshot.Health)
	}
	if snapshot := feedPassive(actor, &now, dialFailed()); snapshot.Health != doctorDegraded || snapshot.Confidence != doctorProbable {
		t.Fatalf("second failure = %q/%q, want degraded/probable", snapshot.Health, snapshot.Confidence)
	}
	feedPassive(actor, &now, dialFailed())
	snapshot := feedPassive(actor, &now, dialFailed())
	if snapshot.Health != doctorBroken || snapshot.Layer != doctorLayerDial {
		t.Fatalf("fourth failure = %q layer %q, want broken/dial", snapshot.Health, snapshot.Layer)
	}
	if snapshot.CauseCode != "outerDialTimeout" {
		t.Fatalf("cause = %q, want the triggering dial error class", snapshot.CauseCode)
	}
	if snapshot.FreshUntil <= now.UnixMilli() {
		t.Fatal("broken verdict must be fresh")
	}
}

func TestPassiveDialSuccessClearsVerdict(t *testing.T) {
	now := time.Unix(1_700_000_000, 0)
	actor := newPassiveDialActor(t, &now)
	for i := 0; i < doctorPassiveDialBrokenRun; i++ {
		feedPassive(actor, &now, dialFailed())
	}
	if snapshot := actor.Snapshot(); snapshot.Health != doctorBroken {
		t.Fatalf("setup health = %q, want broken", snapshot.Health)
	}
	snapshot := feedPassive(actor, &now, dialSucceeded())
	if snapshot.Health != doctorUnknown || snapshot.Layer != "" || snapshot.FreshUntil != 0 {
		t.Fatalf("recovery = %q layer %q fresh %d, want unknown/empty/0", snapshot.Health, snapshot.Layer, snapshot.FreshUntil)
	}
}

func TestPassiveTrafficProgressClearsVerdict(t *testing.T) {
	now := time.Unix(1_700_000_000, 0)
	actor := newPassiveDialActor(t, &now)
	for i := 0; i < doctorPassiveDialDegradedRun; i++ {
		feedPassive(actor, &now, dialFailed())
	}
	if snapshot := actor.Snapshot(); snapshot.Health != doctorDegraded {
		t.Fatalf("setup health = %q, want degraded", snapshot.Health)
	}
	progress := doctorEvidence{
		Kind: doctorEvidenceFirstProgress, Layer: doctorLayerTransport,
		Outcome: doctorOutcomeSucceeded, Confidence: doctorConfirmed, Code: "trafficProgress",
	}
	if snapshot := feedPassive(actor, &now, progress); snapshot.Health != doctorUnknown {
		t.Fatalf("progress recovery = %q, want unknown", snapshot.Health)
	}
}

func TestPassiveDialVerdictIgnoredOffVpnPaths(t *testing.T) {
	now := time.Unix(1_700_000_000, 0)
	actor := newDoctorActor(&fakeDoctorRuntime{}, nil)
	actor.now = func() time.Time { return now }
	actor.setPathContext(doctorPathContext{PathKind: doctorPathDirect, CaptureState: doctorCaptureNotApplicable})
	for i := 0; i < doctorPassiveDialBrokenRun+2; i++ {
		feedPassive(actor, &now, dialFailed())
	}
	if snapshot := actor.Snapshot(); snapshot.Health == doctorBroken || snapshot.Health == doctorDegraded {
		t.Fatalf("direct path must not take a dial verdict, got %q", snapshot.Health)
	}
}
