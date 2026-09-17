package main

import (
	"testing"
	"time"
)

func TestOdometerBootClockIncludesSuspendAndClipsClockChanges(t *testing.T) {
	o, clock := newTestOdometer(newOdoMemStorage())
	boot := time.Hour
	o.monotonic = func() time.Duration { return boot }
	o.NoteUp(clock.at, "")
	boot += 8 * time.Hour
	clock.at = clock.at.Add(8 * time.Hour)
	o.Tick(clock.at)
	if got := o.Report().TotalCoveredMillis; got != (8 * time.Hour).Milliseconds() {
		t.Fatalf("coverage after suspend = %d", got)
	}
	boot += time.Second
	clock.at = clock.at.Add(24 * time.Hour)
	o.Tick(clock.at)
	want := (8*time.Hour + time.Second).Milliseconds()
	if got := o.Report().TotalCoveredMillis; got != want {
		t.Fatalf("forward wall jump inflated coverage: %d != %d", got, want)
	}
	boot += time.Second
	clock.at = clock.at.Add(-24 * time.Hour)
	o.Tick(clock.at)
	if got := o.Report().TotalCoveredMillis; got != want {
		t.Fatalf("backward wall jump inflated coverage: %d != %d", got, want)
	}
}

func TestOdometerExamCountsOnlyCompletedIncidentsOnce(t *testing.T) {
	previous := odometerInstance
	o, clock := newTestOdometer(newOdoMemStorage())
	odometerInstance = o
	t.Cleanup(func() { odometerInstance = previous })
	actor := &doctorActor{now: clock.now}
	actor.snapshot = doctorSnapshot{
		ExamID: "completed", StartedAt: clock.at.UnixMilli(),
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
	report := o.Report()
	if report.Exams != 2 || report.ExamsClean != 1 {
		t.Fatalf("exam counters = %d/%d, want 2/1", report.Exams, report.ExamsClean)
	}
}
