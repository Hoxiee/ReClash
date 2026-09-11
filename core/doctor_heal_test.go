package main

import (
	"context"
	"testing"
	"time"
)

func TestDoctorHealRejectsStaleDiagnosis(t *testing.T) {
	actor := newDoctorActor(&fakeDoctorRuntime{}, nil)
	actor.snapshot.ExamID = "exam"
	actor.snapshot.State = doctorComplete
	actor.snapshot.CauseCode = "dnsCacheStale"
	actor.refreshActions()
	actor.storeView()

	_, err := actor.request(doctorCommand{kind: doctorHealCommand, heal: doctorHealParams{
		ExamID: "exam", Revision: actor.snapshot.Revision - 1, ActionID: "flushDns",
	}})
	if err == nil || err.Error() != "stale_diagnosis" {
		t.Fatalf("err = %v", err)
	}
}

func TestDoctorHealTimeoutDoesNotBlockLaterActions(t *testing.T) {
	previous := doctorHealTimeout
	doctorHealTimeout = 20 * time.Millisecond
	t.Cleanup(func() { doctorHealTimeout = previous })
	flushStarted := make(chan struct{}, 1)
	actor := newDoctorActor(&blockingFlushRuntime{
		doctorRuntime: doctorRuntimeFunc{run: func(context.Context, string, doctorExamMode, doctorExamSink) {}},
		started:       flushStarted,
		release:       make(chan struct{}),
	}, nil)
	actor.snapshot.ExamID = "exam"
	actor.snapshot.State = doctorComplete
	actor.snapshot.CauseCode = "dnsCacheStale"
	actor.refreshActions()
	actor.storeView()
	if _, err := actor.request(doctorCommand{kind: doctorHealCommand, heal: doctorHealParams{
		ExamID: "exam", Revision: actor.snapshot.Revision, ActionID: "flushDns",
	}}); err != nil {
		t.Fatal(err)
	}
	<-flushStarted
	deadline := time.Now().Add(time.Second)
	for time.Now().Before(deadline) {
		snapshot := actor.Snapshot()
		if len(snapshot.HealAudit) == 1 && snapshot.HealAudit[0].Outcome == "timeout" {
			if _, err := actor.request(doctorCommand{kind: doctorGenerationCommand, generation: doctorRoutingGeneration}); err != nil {
				t.Fatal(err)
			}
			return
		}
		time.Sleep(time.Millisecond)
	}
	t.Fatal("DNS flush timeout was not recorded")
}

func TestDoctorHealDoesNotBlockActorOrReexamineStaleDiagnosis(t *testing.T) {
	flushStarted := make(chan struct{}, 1)
	flushRelease := make(chan struct{})
	runtime := &fakeDoctorRuntime{}
	runtimeOverride := doctorRuntimeFunc{run: runtime.RunExam}
	actor := newDoctorActor(&blockingFlushRuntime{
		doctorRuntime: runtimeOverride,
		started:       flushStarted,
		release:       flushRelease,
	}, nil)
	actor.snapshot.ExamID = "exam"
	actor.snapshot.Mode = doctorStandard
	actor.snapshot.State = doctorComplete
	actor.snapshot.CauseCode = "dnsCacheStale"
	actor.refreshActions()
	actor.storeView()

	if _, err := actor.request(doctorCommand{kind: doctorHealCommand, heal: doctorHealParams{
		ExamID: "exam", Revision: actor.snapshot.Revision, ActionID: "flushDns",
	}}); err != nil {
		t.Fatal(err)
	}
	select {
	case <-flushStarted:
	case <-time.After(time.Second):
		t.Fatal("DNS flush did not start")
	}
	snapshot, err := actor.request(doctorCommand{kind: doctorGenerationCommand, generation: doctorRoutingGeneration})
	if err != nil {
		t.Fatal(err)
	}
	if snapshot.Generations.Routing != 1 || snapshot.State != doctorObserving {
		t.Fatalf("snapshot = %+v", snapshot)
	}
	close(flushRelease)
	deadline := time.Now().Add(time.Second)
	for time.Now().Before(deadline) {
		snapshot = actor.Snapshot()
		if len(snapshot.HealAudit) == 1 && snapshot.HealAudit[0].Outcome == "applied" {
			if snapshot.ExamID != "" || snapshot.State != doctorObserving {
				t.Fatalf("stale heal started re-exam: %+v", snapshot)
			}
			return
		}
		time.Sleep(time.Millisecond)
	}
	t.Fatal("DNS flush completion was not recorded")
}

type blockingFlushRuntime struct {
	doctorRuntime
	started chan struct{}
	release chan struct{}
}

func (runtime *blockingFlushRuntime) FlushDNS() {
	runtime.started <- struct{}{}
	<-runtime.release
}

func TestDoctorHealFlushesAndStartsOneReexam(t *testing.T) {
	runtime := &fakeDoctorRuntime{release: make(chan struct{})}
	actor := newDoctorActor(runtime, nil)
	actor.snapshot.ExamID = "exam"
	actor.snapshot.Mode = doctorDeep
	actor.snapshot.State = doctorComplete
	actor.snapshot.CauseCode = "dnsCacheStale"
	actor.snapshot.StartedAt = time.Now().Add(-time.Second).UnixMilli()
	actor.refreshActions()
	actor.storeView()

	snapshot, err := actor.request(doctorCommand{kind: doctorHealCommand, heal: doctorHealParams{
		ExamID: "exam", Revision: actor.snapshot.Revision, ActionID: "flushDns",
	}})
	if err != nil {
		t.Fatal(err)
	}
	if snapshot.ExamID != "exam" || len(snapshot.HealAudit) != 1 || snapshot.HealAudit[0].Outcome != "pending" {
		t.Fatalf("initial snapshot = %+v", snapshot)
	}
	deadline := time.Now().Add(time.Second)
	for time.Now().Before(deadline) {
		snapshot = actor.Snapshot()
		runtime.mu.Lock()
		flushes := runtime.flushes
		runtime.mu.Unlock()
		if flushes == 1 && snapshot.ExamID != "exam" && snapshot.State == doctorExamining {
			if snapshot.Mode != doctorDeep || snapshot.HealAudit[0].Outcome != "applied" || snapshot.HealAudit[0].ReexamID != snapshot.ExamID {
				t.Fatalf("snapshot = %+v", snapshot)
			}
			close(runtime.release)
			return
		}
		time.Sleep(time.Millisecond)
	}
	close(runtime.release)
	t.Fatalf("DNS flush did not start one re-exam: %+v", actor.Snapshot())
}
