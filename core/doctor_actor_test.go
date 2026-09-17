package main

import (
	"context"
	"errors"
	"reflect"
	"sync"
	"sync/atomic"
	"testing"
	"time"
)

type fakeDoctorRuntime struct {
	mu      sync.Mutex
	runs    []doctorExamMode
	started chan struct{}
	release chan struct{}
	facts   []doctorEvidence
	flushes int
}

func (runtime *fakeDoctorRuntime) RunExam(ctx context.Context, _ string, mode doctorExamMode, sink doctorExamSink) {
	runtime.mu.Lock()
	runtime.runs = append(runtime.runs, mode)
	started := runtime.started
	release := runtime.release
	facts := append([]doctorEvidence(nil), runtime.facts...)
	runtime.mu.Unlock()
	if started != nil {
		select {
		case started <- struct{}{}:
		default:
		}
	}
	if release != nil {
		select {
		case <-release:
		case <-ctx.Done():
			return
		}
	}
	for _, fact := range facts {
		sink.Emit(fact)
	}
}

func (runtime *fakeDoctorRuntime) FlushDNS() {
	runtime.mu.Lock()
	defer runtime.mu.Unlock()
	runtime.flushes++
}

func (runtime *fakeDoctorRuntime) DoctorPathContext() doctorPathContext {
	return doctorPathContext{PathKind: doctorPathLocalProxy, CaptureState: doctorCaptureNotApplicable}
}

func TestDoctorActorRequestHonorsContextWhenQueueIsFull(t *testing.T) {
	actor := &doctorActor{commands: make(chan doctorCommand, 1)}
	actor.commands <- doctorCommand{}
	ctx, cancel := context.WithTimeout(context.Background(), 20*time.Millisecond)
	defer cancel()

	_, err := actor.requestContext(ctx, doctorCommand{})
	if !errors.Is(err, context.DeadlineExceeded) {
		t.Fatalf("err = %v", err)
	}
}

func TestDoctorActorRequestHonorsContextWithoutResponse(t *testing.T) {
	actor := &doctorActor{commands: make(chan doctorCommand, 1)}
	ctx, cancel := context.WithTimeout(context.Background(), 20*time.Millisecond)
	defer cancel()

	_, err := actor.requestContext(ctx, doctorCommand{})
	if !errors.Is(err, context.DeadlineExceeded) {
		t.Fatalf("err = %v", err)
	}
}

func TestDoctorActorCoalescesAnActiveExamOfTheSameMode(t *testing.T) {
	runtime := &fakeDoctorRuntime{started: make(chan struct{}, 2), release: make(chan struct{})}
	actor := newDoctorActor(runtime, nil)
	first, err := actor.request(doctorCommand{kind: doctorStartCommand, start: doctorStartParams{Mode: doctorStandard}})
	if err != nil {
		t.Fatal(err)
	}
	<-runtime.started

	second, err := actor.request(doctorCommand{kind: doctorStartCommand, start: doctorStartParams{Mode: doctorStandard}})
	if err != nil {
		t.Fatal(err)
	}

	if first.ExamID != second.ExamID || first.Revision != second.Revision {
		t.Fatalf("first = %+v, second = %+v", first, second)
	}
	close(runtime.release)
}

func TestDoctorActorSupersedesAnActiveExamOnModeChange(t *testing.T) {
	runtime := &fakeDoctorRuntime{started: make(chan struct{}, 2), release: make(chan struct{})}
	actor := newDoctorActor(runtime, nil)
	first, _ := actor.request(doctorCommand{kind: doctorStartCommand, start: doctorStartParams{Mode: doctorStandard}})
	<-runtime.started

	second, _ := actor.request(doctorCommand{kind: doctorStartCommand, start: doctorStartParams{Mode: doctorDeep}})

	if first.ExamID == second.ExamID || second.Mode != doctorDeep || second.State != doctorExamining {
		t.Fatalf("first = %+v, second = %+v", first, second)
	}
	if len(second.Incidents) != 1 || second.Incidents[0].State != doctorSuperseded {
		t.Fatalf("incidents = %+v, want superseded first exam", second.Incidents)
	}
	close(runtime.release)
}

func TestDoctorActorCancellationIgnoresLateResults(t *testing.T) {
	runtime := &fakeDoctorRuntime{started: make(chan struct{}, 1), release: make(chan struct{}), facts: []doctorEvidence{{
		Layer: doctorLayerMarker, Outcome: doctorOutcomeSucceeded, Confidence: doctorConfirmed,
	}}}
	actor := newDoctorActor(runtime, nil)
	started, _ := actor.request(doctorCommand{kind: doctorStartCommand, start: doctorStartParams{Mode: doctorStandard}})
	<-runtime.started

	cancelled, err := actor.request(doctorCommand{kind: doctorCancelCommand, cancel: doctorCancelParams{ExamID: started.ExamID}})
	if err != nil {
		t.Fatal(err)
	}
	close(runtime.release)
	time.Sleep(20 * time.Millisecond)
	current := actor.Snapshot()

	if cancelled.State != doctorCancelled || current.State != doctorCancelled || current.Health != doctorUnknown {
		t.Fatalf("cancelled = %+v, current = %+v", cancelled, current)
	}
}

type mutablePathRuntime struct {
	path doctorPathContext
}

func (*mutablePathRuntime) RunExam(context.Context, string, doctorExamMode, doctorExamSink) {}
func (*mutablePathRuntime) FlushDNS()                                                       {}
func (runtime *mutablePathRuntime) DoctorPathContext() doctorPathContext                    { return runtime.path }

func TestDoctorTunGenerationRefreshesRuntimePath(t *testing.T) {
	runtime := &mutablePathRuntime{path: doctorPathContext{PathKind: doctorPathLocalProxy, CaptureState: doctorCaptureNotApplicable}}
	actor := newDoctorActor(runtime, nil)
	runtime.path = doctorPathContext{PathKind: doctorPathTun, CaptureState: doctorCaptureActive}

	snapshot, err := actor.request(doctorCommand{kind: doctorGenerationCommand, generation: doctorTunGeneration})
	if err != nil {
		t.Fatal(err)
	}
	if snapshot.PathKind != doctorPathTun || snapshot.CaptureState != doctorCaptureActive {
		t.Fatalf("snapshot = %+v", snapshot)
	}
}

func TestDoctorActorGenerationChangeSupersedesExam(t *testing.T) {
	runtime := &fakeDoctorRuntime{started: make(chan struct{}, 1), release: make(chan struct{})}
	actor := newDoctorActor(runtime, nil)
	_, _ = actor.request(doctorCommand{kind: doctorStartCommand, start: doctorStartParams{Mode: doctorStandard}})
	<-runtime.started

	snapshot, _ := actor.request(doctorCommand{kind: doctorGenerationCommand, generation: doctorRoutingGeneration})

	if snapshot.State != doctorSuperseded || snapshot.Generations.Routing != 1 {
		t.Fatalf("snapshot = %+v", snapshot)
	}
	close(runtime.release)
}

func TestDoctorActorCompletesWithConfirmedProof(t *testing.T) {
	runtime := &fakeDoctorRuntime{facts: []doctorEvidence{{
		Layer: doctorLayerMarker, Outcome: doctorOutcomeSucceeded, Confidence: doctorConfirmed,
	}}}
	actor := newDoctorActor(runtime, nil)
	started, _ := actor.request(doctorCommand{kind: doctorStartCommand, start: doctorStartParams{Mode: doctorStandard}})

	deadline := time.Now().Add(time.Second)
	for time.Now().Before(deadline) {
		snapshot := actor.Snapshot()
		if snapshot.ExamID == started.ExamID && snapshot.State == doctorComplete {
			if snapshot.Health != doctorHealthy || snapshot.Confidence != doctorConfirmed {
				t.Fatalf("snapshot = %+v", snapshot)
			}
			return
		}
		time.Sleep(time.Millisecond)
	}
	t.Fatal("exam did not complete")
}

func TestDoctorActorUsesApplicationScopeForExplicitExam(t *testing.T) {
	runtime := &fakeDoctorRuntime{release: make(chan struct{})}
	actor := newDoctorActor(runtime, nil)
	snapshot, _ := actor.request(doctorCommand{kind: doctorStartCommand, start: doctorStartParams{Mode: doctorStandard}})
	if snapshot.Scope != doctorScopeApp || snapshot.Progress.Total != doctorProbeCount(doctorStandard, snapshot.Capabilities) {
		t.Fatalf("snapshot = %+v", snapshot)
	}
	close(runtime.release)
}

func TestDoctorActorDoesNotTurnPassiveSeenEvidenceIntoHealth(t *testing.T) {
	actor := newDoctorActor(&fakeDoctorRuntime{}, nil)
	actor.Passive(doctorEvidence{
		Kind: doctorEvidenceIngress, Layer: doctorLayerIngress, Outcome: doctorOutcomeSeen,
		Confidence: doctorConfirmed, Inbound: "tun", at: time.Now(),
	})
	deadline := time.Now().Add(time.Second)
	for time.Now().Before(deadline) {
		snapshot := actor.Snapshot()
		if len(snapshot.Evidence) == 1 {
			if snapshot.Health != doctorUnknown || snapshot.Confidence != doctorInsufficient || snapshot.Scope != doctorScopeInbound {
				t.Fatalf("snapshot = %+v", snapshot)
			}
			return
		}
		time.Sleep(time.Millisecond)
	}
	t.Fatal("passive evidence was not observed")
}

func TestDoctorActorStaleSnapshotRefreshesActionEligibility(t *testing.T) {
	actor := newDoctorActor(&fakeDoctorRuntime{}, nil)
	now := time.Unix(100, 0)
	actor.now = func() time.Time { return now }
	actor.snapshot.ExamID = "exam"
	actor.snapshot.State = doctorComplete
	actor.snapshot.Health = doctorDegraded
	actor.snapshot.Confidence = doctorProbable
	actor.snapshot.CauseCode = "dnsCacheStale"
	actor.snapshot.FreshUntil = now.Add(time.Second).UnixMilli()
	actor.changed()
	now = now.Add(2 * time.Second)

	snapshot := actor.Snapshot()
	if snapshot.Health != doctorUnknown || snapshot.CauseCode != "staleEvidence" {
		t.Fatalf("snapshot = %+v", snapshot)
	}
	for _, action := range snapshot.Actions {
		if action.ID == "flushDns" && action.Eligible {
			t.Fatalf("stale snapshot kept flushDns eligible: %+v", snapshot.Actions)
		}
	}
}

func TestDoctorActorPublishesPassiveQueueOverflow(t *testing.T) {
	actor := &doctorActor{
		commands: make(chan doctorCommand, 1),
		passive:  make(chan doctorEvidence, 1),
		now:      time.Now,
		runtime:  &fakeDoctorRuntime{},
	}
	actor.snapshot = doctorSnapshot{
		SchemaVersion: doctorSchemaVersion,
		Revision:      1,
		State:         doctorObserving,
		Health:        doctorUnknown,
		Confidence:    doctorInsufficient,
	}
	actor.storeView()
	actor.passive <- doctorEvidence{}
	actor.Passive(doctorEvidence{})
	actor.handle(<-actor.commands)
	actor.handle(<-actor.commands)

	if snapshot := actor.Snapshot(); snapshot.EvidenceDropped != 1 || snapshot.Revision != 2 {
		t.Fatalf("snapshot = %+v", snapshot)
	}
}

func TestDoctorActorBoundedHistoryDoesNotReportQueueOverflow(t *testing.T) {
	actor := newDoctorActor(&fakeDoctorRuntime{}, nil)
	for i := 0; i < doctorMaxFacts+5; i++ {
		actor.appendEvidence(doctorEvidence{Layer: doctorLayerRoute})
	}
	if len(actor.snapshot.Evidence) != doctorMaxFacts || actor.snapshot.EvidenceDropped != 0 {
		t.Fatalf("snapshot = %+v", actor.snapshot)
	}
}

func TestDoctorActorGenerationChangeInvalidatesTerminalVerdict(t *testing.T) {
	actor := newDoctorActor(&fakeDoctorRuntime{}, nil)
	actor.snapshot.ExamID = "exam"
	actor.snapshot.FreshUntil = actor.now().Add(doctorEvidenceFreshFor).UnixMilli()
	actor.snapshot.State = doctorComplete
	actor.snapshot.Health = doctorBroken
	actor.snapshot.Confidence = doctorConfirmed
	actor.snapshot.CauseCode = "dialTimeout"
	actor.snapshot.Layer = doctorLayerDial
	actor.changed()

	snapshot, err := actor.request(doctorCommand{kind: doctorGenerationCommand, generation: doctorRoutingGeneration})
	if err != nil {
		t.Fatal(err)
	}
	if snapshot.State != doctorObserving || snapshot.Health != doctorUnknown || snapshot.Confidence != doctorInsufficient ||
		snapshot.CauseCode != "" || snapshot.Layer != "" || snapshot.Generations.Routing != 1 {
		t.Fatalf("snapshot = %+v", snapshot)
	}
}

func TestDoctorActorPassiveEvidencePreservesFreshExam(t *testing.T) {
	for name, facts := range map[string][]doctorEvidence{
		"healthy":      {{Layer: doctorLayerMarker, Outcome: doctorOutcomeSucceeded, Confidence: doctorConfirmed}},
		"broken":       {{Layer: doctorLayerDial, Outcome: doctorOutcomeFailed, Confidence: doctorConfirmed, Code: "dialTimeout"}},
		"degraded":     {{Layer: doctorLayerDNS, Outcome: doctorOutcomeFailed, Confidence: doctorProbable, Code: "coreResolverStale"}},
		"inconclusive": nil,
	} {
		t.Run(name, func(t *testing.T) {
			now := time.Unix(100, 0)
			actor := &doctorActor{
				now:      func() time.Time { return now },
				commands: make(chan doctorCommand, 1),
				snapshot: doctorSnapshot{
					ExamID: "exam", Mode: doctorStandard, State: doctorExamining,
					PathKind: doctorPathLocalProxy, CaptureState: doctorCaptureNotApplicable,
					StartedAt: now.Add(-time.Second).UnixMilli(),
					Progress:  doctorProgress{Total: 2},
					Evidence:  facts,
				},
			}
			actor.applyVerdict(true)
			t.Cleanup(actor.stopFreshnessTimer)
			actor.snapshot.Incidents = []doctorIncident{{ExamID: "exam", State: actor.snapshot.State}}
			actor.changed()
			before := actor.Snapshot()
			for _, fact := range []doctorEvidence{
				{Kind: doctorEvidenceIngress, Layer: doctorLayerIngress, Outcome: doctorOutcomeSeen, Inbound: "tun"},
				{Kind: doctorEvidenceOuterDial, Layer: doctorLayerDial, Outcome: doctorOutcomeFailed},
				{Kind: doctorEvidenceMarker, Layer: doctorLayerMarker, Outcome: doctorOutcomeSucceeded, Confidence: doctorConfirmed},
			} {
				now = now.Add(time.Second)
				actor.handlePassive(fact)
				actor.flushPassive()
				if current := actor.Snapshot(); !reflect.DeepEqual(current, before) {
					t.Fatalf("passive fact %+v replaced exam: before = %+v, current = %+v", fact, before, current)
				}
			}
		})
	}
}

func TestDoctorActorPassiveEvidenceResumesAfterExamExpiry(t *testing.T) {
	for _, expireFirst := range []bool{false, true} {
		t.Run(map[bool]string{false: "beforeTimer", true: "afterTimer"}[expireFirst], func(t *testing.T) {
			now := time.Unix(100, 0)
			actor := &doctorActor{
				now:      func() time.Time { return now },
				commands: make(chan doctorCommand, 1),
				snapshot: doctorSnapshot{
					ExamID: "exam", State: doctorComplete, Health: doctorBroken,
					CauseCode: "dialTimeout", FreshUntil: now.Add(time.Second).UnixMilli(),
				},
			}
			actor.changed()
			now = now.Add(time.Second)
			if expireFirst {
				actor.expireFreshness(0)
			}
			actor.handlePassive(doctorEvidence{Kind: doctorEvidenceIngress, Layer: doctorLayerIngress, Outcome: doctorOutcomeSeen})
			actor.flushPassive()
			snapshot := actor.Snapshot()
			if snapshot.State != doctorObserving || snapshot.ExamID != "" || snapshot.Health != doctorUnknown ||
				snapshot.FreshUntil != 0 || snapshot.CauseCode != "" || len(snapshot.Evidence) != 1 {
				t.Fatalf("snapshot = %+v", snapshot)
			}
		})
	}
}

func TestDoctorActorDoesNotPublishEveryPassiveFact(t *testing.T) {
	var published atomic.Int32
	actor := newDoctorActor(&fakeDoctorRuntime{}, func(doctorStatusProjection) { published.Add(1) })
	for index := 0; index < 20; index++ {
		actor.handlePassive(doctorEvidence{
			Kind: doctorEvidenceIngress, Layer: doctorLayerIngress, Outcome: doctorOutcomeSeen,
			Confidence: doctorConfirmed, Inbound: "tun", at: actor.now(),
		})
	}
	if published.Load() != 0 {
		t.Fatalf("published %d events before coalesced flush", published.Load())
	}
	actor.flushPassive()
	if published.Load() != 1 {
		t.Fatalf("published %d events after coalesced flush", published.Load())
	}
}

func TestDoctorActorProgressCountsCompletedProbesInsteadOfFacts(t *testing.T) {
	facts := []doctorEvidence{
		{Kind: doctorEvidenceProbe, Layer: doctorLayerDNS, Code: "coreResolverSucceeded"},
		{Kind: doctorEvidenceProbe, Layer: doctorLayerDNS, Code: "systemResolverSucceeded"},
		{Kind: doctorEvidenceProbe, Layer: doctorLayerCapture, Code: "networkUnvalidated"},
	}
	if completed := doctorCompletedProbeCount(facts, false); completed != 2 {
		t.Fatalf("completed = %d, want 2 before application result", completed)
	}
	facts = append(facts, doctorEvidence{Kind: doctorEvidenceProbe, Layer: doctorLayerMarker, Code: "applicationProbeFailed"})
	if completed := doctorCompletedProbeCount(facts, false); completed != 3 {
		t.Fatalf("completed = %d, want 3 after application result", completed)
	}
	facts = append(facts, doctorEvidence{Kind: doctorEvidenceIngress, Layer: doctorLayerIngress, Code: "appIngressMatched"})
	if completed := doctorCompletedProbeCount(facts, true); completed != 4 {
		t.Fatalf("completed = %d, want 4 after matched ingress", completed)
	}
}

func TestDoctorActorPassiveFlowFailureDoesNotBecomeGlobalFailure(t *testing.T) {
	actor := newDoctorActor(&fakeDoctorRuntime{}, nil)
	actor.handlePassive(doctorEvidence{
		Kind: doctorEvidenceOuterDial, Layer: doctorLayerDial, Outcome: doctorOutcomeFailed,
		Confidence: doctorConfirmed, Code: "outerDialTimeout", Inbound: "tun", at: actor.now(),
	})
	actor.flushPassive()
	snapshot := actor.Snapshot()
	if snapshot.Health != doctorUnknown || snapshot.Confidence != doctorInsufficient || snapshot.CauseCode != "" {
		t.Fatalf("snapshot = %+v", snapshot)
	}
}

func TestDoctorActorFreshnessExpiryPublishesAtTheDeadline(t *testing.T) {
	var published atomic.Int32
	actor := newDoctorActor(&fakeDoctorRuntime{}, func(doctorStatusProjection) { published.Add(1) })
	now := time.Unix(100, 0)
	actor.now = func() time.Time { return now }
	actor.snapshot.State = doctorComplete
	actor.snapshot.Health = doctorDegraded
	actor.snapshot.Confidence = doctorProbable
	actor.snapshot.CauseCode = "dnsCacheStale"
	actor.snapshot.FreshUntil = now.Add(time.Second).UnixMilli()
	actor.changed()
	token := actor.freshnessToken
	now = now.Add(time.Second)
	actor.expireFreshness(token)
	snapshot := actor.Snapshot()
	if snapshot.Health != doctorUnknown || snapshot.Confidence != doctorInsufficient || snapshot.CauseCode != "staleEvidence" || snapshot.FreshUntil != 0 {
		t.Fatalf("snapshot = %+v", snapshot)
	}
	if published.Load() != 2 {
		t.Fatalf("published %d transitions, want 2", published.Load())
	}
}

func TestDoctorActorIgnoresStaleFreshnessTimer(t *testing.T) {
	actor := newDoctorActor(&fakeDoctorRuntime{}, nil)
	now := time.Unix(100, 0)
	actor.now = func() time.Time { return now }
	actor.snapshot.State = doctorComplete
	actor.snapshot.Health = doctorDegraded
	actor.snapshot.Confidence = doctorProbable
	actor.snapshot.FreshUntil = now.Add(time.Hour).UnixMilli()
	actor.scheduleFreshnessExpiry()
	staleToken := actor.freshnessToken
	t.Cleanup(func() { actor.stopFreshnessTimer() })

	actor.snapshot.FreshUntil = now.Add(2 * time.Hour).UnixMilli()
	actor.scheduleFreshnessExpiry()
	now = now.Add(time.Hour)
	actor.expireFreshness(staleToken)
	if actor.snapshot.Health != doctorDegraded {
		t.Fatalf("stale timer expired current verdict: %+v", actor.snapshot)
	}
	now = now.Add(time.Hour)
	actor.expireFreshness(actor.freshnessToken)
	if actor.snapshot.Health != doctorUnknown || actor.snapshot.CauseCode != "staleEvidence" {
		t.Fatalf("current timer did not expire verdict: %+v", actor.snapshot)
	}
}

func TestDoctorActorDeadlineTerminalizesNonCooperativeRuntime(t *testing.T) {
	previous := doctorExamTimeout
	doctorExamTimeout = 20 * time.Millisecond
	t.Cleanup(func() { doctorExamTimeout = previous })
	runtime := &fakeDoctorRuntime{release: make(chan struct{})}
	actor := newDoctorActor(runtime, nil)
	started, err := actor.request(doctorCommand{kind: doctorStartCommand, start: doctorStartParams{Mode: doctorStandard}})
	if err != nil {
		t.Fatal(err)
	}
	deadline := time.Now().Add(time.Second)
	for time.Now().Before(deadline) {
		snapshot := actor.Snapshot()
		if snapshot.ExamID == started.ExamID && snapshot.State == doctorInconclusive {
			if snapshot.CauseCode != "insufficientEvidence" {
				t.Fatalf("snapshot = %+v", snapshot)
			}
			close(runtime.release)
			return
		}
		time.Sleep(time.Millisecond)
	}
	close(runtime.release)
	t.Fatal("deadline did not terminalize non-cooperative runtime")
}

func TestDoctorActorFinishCancelsStoredContext(t *testing.T) {
	observed := make(chan context.Context, 1)
	runtime := doctorRuntimeFunc{run: func(ctx context.Context, _ string, _ doctorExamMode, sink doctorExamSink) {
		sink.Emit(doctorEvidence{Layer: doctorLayerMarker, Outcome: doctorOutcomeSucceeded, Confidence: doctorConfirmed, Code: "applicationProbeSucceeded"})
		observed <- ctx
	}}
	actor := newDoctorActor(runtime, nil)
	_, _ = actor.request(doctorCommand{kind: doctorStartCommand, start: doctorStartParams{Mode: doctorStandard}})
	select {
	case ctx := <-observed:
		select {
		case <-ctx.Done():
		case <-time.After(time.Second):
			t.Fatal("finish did not cancel stored runtime context")
		}
	case <-time.After(time.Second):
		t.Fatal("runtime did not receive exam context")
	}
}

type doctorRuntimeFunc struct {
	run func(context.Context, string, doctorExamMode, doctorExamSink)
}

func (runtime doctorRuntimeFunc) RunExam(ctx context.Context, id string, mode doctorExamMode, sink doctorExamSink) {
	runtime.run(ctx, id, mode, sink)
}
func (doctorRuntimeFunc) FlushDNS() {}
func (doctorRuntimeFunc) DoctorPathContext() doctorPathContext {
	return doctorPathContext{PathKind: doctorPathLocalProxy, CaptureState: doctorCaptureNotApplicable}
}

func TestDoctorPathStatusRejectsStaleRuntimeProjection(t *testing.T) {
	actor := newDoctorActor(&fakeDoctorRuntime{}, nil)
	newer := doctorPathStatus{
		PathKind: doctorPathVPN, Phase: "active", Generation: 2, Timestamp: 2,
	}
	stale := doctorPathStatus{
		PathKind: doctorPathLocalProxy, Phase: "inactive", Generation: 1, Timestamp: 1,
	}
	if _, err := actor.request(doctorCommand{kind: doctorPathStatusCommand, pathStatus: newer}); err != nil {
		t.Fatal(err)
	}
	if _, err := actor.request(doctorCommand{kind: doctorPathStatusCommand, pathStatus: stale}); err != nil {
		t.Fatal(err)
	}
	stored, _ := doctorAndroidPathStatus.Load().(doctorPathStatus)
	if stored != newer {
		t.Fatalf("stored path status = %+v, want %+v", stored, newer)
	}
}

func TestDoctorPathStatusGenerationInvalidatesTerminalVerdict(t *testing.T) {
	actor := newDoctorActor(&fakeDoctorRuntime{}, nil)
	actor.snapshot.State = doctorComplete
	actor.snapshot.Health = doctorHealthy
	actor.snapshot.Confidence = doctorConfirmed
	actor.snapshot.PathKind = doctorPathLocalProxy
	actor.snapshot.CaptureState = doctorCaptureNotApplicable
	actor.changed()
	snapshot, err := actor.request(doctorCommand{kind: doctorPathStatusCommand, pathStatus: doctorPathStatus{PathKind: doctorPathLocalProxy, Phase: "active", Generation: 1, Timestamp: 1}})
	if err != nil {
		t.Fatal(err)
	}
	if snapshot.State != doctorObserving || snapshot.Health != doctorUnknown || snapshot.Generations.Tun != 1 {
		t.Fatalf("snapshot = %+v", snapshot)
	}
}
