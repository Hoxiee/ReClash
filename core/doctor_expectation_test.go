package main

import (
	"net/netip"
	"slices"
	"testing"
	"time"

	C "github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/tunnel"
)

func testDoctorExpectation() doctorProbeExpectation {
	return doctorProbeExpectation{
		ExamID:        "exam",
		ProbeID:       "probe",
		Protocol:      "tcp",
		SourcePort:    49152,
		Destination:   netip.MustParseAddrPort("203.0.113.10:443"),
		UID:           10001,
		TunGeneration: 4,
		Deadline:      time.Now().Add(time.Minute),
	}
}

func testDoctorObservation() doctorProbeObservation {
	return doctorProbeObservation{
		Protocol:    "tcp",
		SourcePort:  49152,
		Destination: netip.MustParseAddrPort("203.0.113.10:443"),
		UID:         10001,
	}
}

func TestDoctorExpectationMatchesExactObservation(t *testing.T) {
	registry := newDoctorExpectationRegistry()
	expectation := testDoctorExpectation()
	if err := registry.register(expectation); err != nil {
		t.Fatal(err)
	}

	matched, ok := registry.match(testDoctorObservation(), expectation.TunGeneration, time.Now())
	if !ok || matched.ProbeID != expectation.ProbeID || matched.ExamID != expectation.ExamID {
		t.Fatalf("matched = %+v, ok = %v", matched, ok)
	}
}

func TestDoctorExpectationRejectsTupleIdentityAndGenerationMismatches(t *testing.T) {
	for name, mutate := range map[string]func(*doctorProbeObservation, *uint64){
		"source": func(observation *doctorProbeObservation, _ *uint64) {
			observation.SourcePort++
		},
		"destination": func(observation *doctorProbeObservation, _ *uint64) {
			observation.Destination = netip.MustParseAddrPort("203.0.113.11:443")
		},
		"uid": func(observation *doctorProbeObservation, _ *uint64) {
			observation.UID++
		},
		"generation": func(_ *doctorProbeObservation, generation *uint64) {
			*generation++
		},
	} {
		t.Run(name, func(t *testing.T) {
			registry := newDoctorExpectationRegistry()
			expectation := testDoctorExpectation()
			if err := registry.register(expectation); err != nil {
				t.Fatal(err)
			}
			observation := testDoctorObservation()
			generation := expectation.TunGeneration
			mutate(&observation, &generation)
			if matched, ok := registry.match(observation, generation, time.Now()); ok {
				t.Fatalf("unexpected match: %+v", matched)
			}
		})
	}
}

func TestDoctorExpectationExpiresAndClearsWithExam(t *testing.T) {
	registry := newDoctorExpectationRegistry()
	expired := testDoctorExpectation()
	expired.Deadline = time.Now().Add(-time.Second)
	if err := registry.register(expired); err != nil {
		t.Fatal(err)
	}
	if matched, ok := registry.match(testDoctorObservation(), expired.TunGeneration, time.Now()); ok {
		t.Fatalf("expired expectation matched: %+v", matched)
	}

	active := testDoctorExpectation()
	active.ProbeID = "active"
	if err := registry.register(active); err != nil {
		t.Fatal(err)
	}
	registry.clearExam(active.ExamID)
	if matched, ok := registry.match(testDoctorObservation(), active.TunGeneration, time.Now()); ok {
		t.Fatalf("cleared expectation matched: %+v", matched)
	}
}

func TestDoctorExpectationCompletionRequiresOwningExam(t *testing.T) {
	registry := newDoctorExpectationRegistry()
	expectation := testDoctorExpectation()
	if err := registry.register(expectation); err != nil {
		t.Fatal(err)
	}
	registry.complete("other", expectation.ProbeID)
	if _, ok := registry.match(testDoctorObservation(), expectation.TunGeneration, time.Now()); !ok {
		t.Fatal("another exam removed the expectation")
	}
	registry.complete(expectation.ExamID, expectation.ProbeID)
	if matched, ok := registry.match(testDoctorObservation(), expectation.TunGeneration, time.Now()); ok {
		t.Fatalf("completed expectation matched: %+v", matched)
	}
}

func TestDoctorFlowObservationNormalizesAddress(t *testing.T) {
	observation, ok := doctorObservationFromFlow(tunnel.FlowEvidence{
		Network:    C.TCP,
		SourcePort: 49152,
		TargetIP:   netip.MustParseAddr("::ffff:203.0.113.10"),
		TargetPort: 443,
		UID:        10001,
	})
	if !ok || observation.Protocol != "tcp" || observation.Destination.String() != "203.0.113.10:443" {
		t.Fatalf("observation = %+v, ok = %v", observation, ok)
	}
}

func TestDoctorActorClearsExpectationOnCancellationAndSupersession(t *testing.T) {
	for name, terminate := range map[string]func(*doctorActor, doctorSnapshot){
		"cancel": func(actor *doctorActor, snapshot doctorSnapshot) {
			if _, err := actor.request(doctorCommand{kind: doctorCancelCommand, cancel: doctorCancelParams{ExamID: snapshot.ExamID}}); err != nil {
				t.Fatal(err)
			}
		},
		"supersede": func(actor *doctorActor, _ doctorSnapshot) {
			_, _ = actor.request(doctorCommand{kind: doctorGenerationCommand, generation: doctorTunGeneration})
		},
	} {
		t.Run(name, func(t *testing.T) {
			runtime := &fakeDoctorRuntime{release: make(chan struct{})}
			actor := newDoctorActor(runtime, nil)
			snapshot, err := actor.request(doctorCommand{kind: doctorStartCommand, start: doctorStartParams{Mode: doctorStandard}})
			if err != nil {
				t.Fatal(err)
			}
			expectation := testDoctorExpectation()
			expectation.ExamID = snapshot.ExamID
			expectation.TunGeneration = snapshot.Generations.Tun
			if err := actor.expectations.register(expectation); err != nil {
				t.Fatal(err)
			}
			terminate(actor, snapshot)
			if matched, ok := actor.expectations.match(testDoctorObservation(), actor.Snapshot().Generations.Tun, time.Now()); ok {
				t.Fatalf("terminated exam retained expectation: %+v", matched)
			}
			close(runtime.release)
		})
	}
}

func TestDoctorExpectationMatchesPackageIdentity(t *testing.T) {
	registry := newDoctorExpectationRegistry()
	expectation := testDoctorExpectation()
	expectation.UID = 0
	expectation.Package = "com.reclash"
	if err := registry.register(expectation); err != nil {
		t.Fatal(err)
	}
	observation := testDoctorObservation()
	observation.UID = 0
	observation.Package = expectation.Package
	if _, ok := registry.match(observation, expectation.TunGeneration, time.Now()); !ok {
		t.Fatal("package-only identity did not match")
	}
	observation.Package = "com.example.other"
	if matched, ok := registry.match(observation, expectation.TunGeneration, time.Now()); ok {
		t.Fatalf("wrong package matched: %+v", matched)
	}
}

func TestDoctorConfirmedExpectationKeepsLaterFlowEvidence(t *testing.T) {
	runtime := &fakeDoctorRuntime{release: make(chan struct{})}
	actor := newDoctorActor(runtime, nil)
	snapshot, err := actor.request(doctorCommand{kind: doctorStartCommand, start: doctorStartParams{Mode: doctorStandard}})
	if err != nil {
		t.Fatal(err)
	}
	expectation := testDoctorExpectation()
	expectation.ExamID = snapshot.ExamID
	expectation.TunGeneration = snapshot.Generations.Tun
	if err := actor.expectations.register(expectation); err != nil {
		t.Fatal(err)
	}
	actor.acceptMatchedProbeCommand(expectation, doctorEvidence{Layer: doctorLayerIngress, Outcome: doctorOutcomeSeen})
	actor.acceptMatchedProbeCommand(expectation, doctorEvidence{Layer: doctorLayerDial, Outcome: doctorOutcomeFailed, Confidence: doctorConfirmed, Code: "outerDialFailed"})

	facts := actor.Snapshot().Evidence
	if !slices.ContainsFunc(facts, func(fact doctorEvidence) bool { return fact.Code == "outerDialFailed" }) {
		t.Fatalf("later correlated evidence was lost: %+v", facts)
	}
	close(runtime.release)
}

func TestDoctorIngressCandidateRequiresResolvedIdentity(t *testing.T) {
	runtime := &fakeDoctorRuntime{release: make(chan struct{})}
	actor := newDoctorActor(runtime, nil)
	resolved := make(chan struct{}, 1)
	actor.identity = func(observation doctorProbeObservation) (doctorProbeObservation, bool) {
		observation.UID = 10001
		resolved <- struct{}{}
		return observation, true
	}
	snapshot, err := actor.request(doctorCommand{kind: doctorStartCommand, start: doctorStartParams{Mode: doctorStandard}})
	if err != nil {
		t.Fatal(err)
	}
	expectation := testDoctorExpectation()
	expectation.ExamID = snapshot.ExamID
	expectation.TunGeneration = snapshot.Generations.Tun
	expectation.Matched = make(chan struct{}, 1)
	if err := actor.expectations.register(expectation); err != nil {
		t.Fatal(err)
	}
	actor.ObserveFlow(tunnel.FlowEvidence{
		Stage:       tunnel.FlowEvidenceIngress,
		At:          time.Now(),
		Network:     C.TCP,
		InboundType: C.TUN,
		SourceIP:    netip.MustParseAddr("10.0.0.2"),
		SourcePort:  expectation.SourcePort,
		TargetIP:    expectation.Destination.Addr(),
		TargetPort:  expectation.Destination.Port(),
	})
	select {
	case <-resolved:
	case <-time.After(time.Second):
		t.Fatal("identity resolution was not attempted")
	}
	select {
	case <-expectation.Matched:
	case <-time.After(time.Second):
		t.Fatal("resolved ingress did not match expectation")
	}
	deadline := time.Now().Add(time.Second)
	for time.Now().Before(deadline) {
		for _, fact := range actor.Snapshot().Evidence {
			if fact.Code == "appIngressMatched" && fact.Outcome == doctorOutcomeSucceeded {
				close(runtime.release)
				return
			}
		}
		time.Sleep(time.Millisecond)
	}
	close(runtime.release)
	t.Fatal("matched ingress was not added to active exam")
}

func TestDoctorLateIngressIdentityDoesNotSurviveTermination(t *testing.T) {
	for name, terminate := range map[string]func(*doctorActor, doctorSnapshot){
		"cancel": func(actor *doctorActor, snapshot doctorSnapshot) {
			if _, err := actor.request(doctorCommand{kind: doctorCancelCommand, cancel: doctorCancelParams{ExamID: snapshot.ExamID}}); err != nil {
				t.Fatal(err)
			}
		},
		"supersede": func(actor *doctorActor, _ doctorSnapshot) {
			_, _ = actor.request(doctorCommand{kind: doctorGenerationCommand, generation: doctorTunGeneration})
		},
	} {
		t.Run(name, func(t *testing.T) {
			runtime := &fakeDoctorRuntime{release: make(chan struct{})}
			actor := newDoctorActor(runtime, nil)
			identityStarted := make(chan struct{}, 1)
			identityRelease := make(chan struct{})
			identityDone := make(chan struct{})
			actor.identity = func(observation doctorProbeObservation) (doctorProbeObservation, bool) {
				identityStarted <- struct{}{}
				<-identityRelease
				observation.UID = 10001
				close(identityDone)
				return observation, true
			}
			snapshot, err := actor.request(doctorCommand{kind: doctorStartCommand, start: doctorStartParams{Mode: doctorStandard}})
			if err != nil {
				t.Fatal(err)
			}
			expectation := testDoctorExpectation()
			expectation.ExamID = snapshot.ExamID
			expectation.TunGeneration = snapshot.Generations.Tun
			expectation.Matched = make(chan struct{}, 1)
			if err := actor.expectations.register(expectation); err != nil {
				t.Fatal(err)
			}
			actor.ObserveFlow(tunnel.FlowEvidence{
				Stage:       tunnel.FlowEvidenceIngress,
				At:          time.Now(),
				Network:     C.TCP,
				InboundType: C.TUN,
				SourceIP:    netip.MustParseAddr("10.0.0.2"),
				SourcePort:  expectation.SourcePort,
				TargetIP:    expectation.Destination.Addr(),
				TargetPort:  expectation.Destination.Port(),
			})
			select {
			case <-identityStarted:
			case <-time.After(time.Second):
				t.Fatal("identity resolution was not started")
			}
			terminate(actor, snapshot)
			close(identityRelease)
			select {
			case <-identityDone:
			case <-time.After(time.Second):
				t.Fatal("identity resolution did not finish")
			}
			select {
			case <-expectation.Matched:
				t.Fatal("late identity result matched a terminated exam")
			case <-time.After(20 * time.Millisecond):
			}
			for _, fact := range actor.Snapshot().Evidence {
				if fact.Code == "appIngressMatched" {
					t.Fatalf("late identity result entered snapshot: %+v", actor.Snapshot())
				}
			}
			close(runtime.release)
		})
	}
}
