package doctor

import (
	"testing"
	"time"
)

type fakeDoctorOdometer struct {
	exams int
	clean int
}

func (f *fakeDoctorOdometer) NoteExam(healthy bool) {
	f.exams++
	if healthy {
		f.clean++
	}
}

func TestDoctorActorBatchesGenerationChangesIntoOneRevision(t *testing.T) {
	actor := newDoctorActor(&fakeDoctorRuntime{}, nil)
	before := actor.Snapshot()
	after, _ := actor.request(doctorCommand{
		kind:        doctorGenerationCommand,
		generations: doctorGenerationChange{Config: true, Routing: true},
	})
	if after.Revision != before.Revision+1 || after.Generations.Config != 1 || after.Generations.Routing != 1 {
		t.Fatalf("before = %+v, after = %+v", before, after)
	}
}

func TestDoctorResetClearsSessionStateAndQueuedEvidence(t *testing.T) {
	actor := newDoctorActor(&fakeDoctorRuntime{}, nil)
	actor.passive <- doctorEvidence{Kind: doctorEvidenceProbe, Layer: doctorLayerMarker, Outcome: doctorOutcomeSucceeded, Confidence: doctorConfirmed, Code: "staleApplicationSuccess"}
	actor.snapshot.Incidents = []doctorIncident{{ExamID: "stale"}}
	actor.snapshot.HealAudit = []doctorHealAudit{{}}
	actor.snapshot.Generations = doctorGenerations{Environment: 3, Config: 4, Routing: 5, Tun: 6}
	actor.lastPathGeneration = 9
	actor.lastPlatformGeneration = 8
	actor.dropped.Store(7)

	snapshot, err := actor.request(doctorCommand{kind: doctorResetCommand})
	if err != nil {
		t.Fatal(err)
	}
	if snapshot.State != doctorObserving || snapshot.Health != doctorUnknown || snapshot.PathKind != doctorPathUnknown || snapshot.CaptureState != doctorCaptureUnknown {
		t.Fatalf("snapshot = %+v", snapshot)
	}
	if snapshot.Generations != (doctorGenerations{}) || len(snapshot.Evidence) != 0 || len(snapshot.Incidents) != 0 || len(snapshot.HealAudit) != 0 || snapshot.EvidenceDropped != 0 {
		t.Fatalf("reset retained session state: %+v", snapshot)
	}
	select {
	case evidence := <-actor.passive:
		t.Fatalf("reset retained queued evidence: %+v", evidence)
	default:
	}
}

func TestDoctorFinishIncidentCountsCompletedExamsOnce(t *testing.T) {
	previous := doctorOdometer
	odo := &fakeDoctorOdometer{}
	SetOdometer(odo)
	t.Cleanup(func() { doctorOdometer = previous })
	actor := &doctorActor{now: time.Now}
	actor.snapshot = doctorSnapshot{
		ExamID: "completed", StartedAt: time.Now().UnixMilli(),
		State: doctorComplete, Health: doctorDegraded,
	}
	actor.finishIncident()
	actor.finishIncident()
	actor.snapshot.ExamID = "cancelled"
	actor.snapshot.State = doctorCancelled
	actor.finishIncident()
	actor.snapshot.ExamID = "broken"
	actor.snapshot.State = doctorComplete
	actor.snapshot.Health = doctorBroken
	actor.finishIncident()
	if odo.exams != 2 || odo.clean != 1 {
		t.Fatalf("exam counters = %d/%d, want 2/1", odo.exams, odo.clean)
	}
}
