package doctor

import (
	"sync"
	"testing"
	"time"

	C "github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/tunnel"
)

func passiveDoctorForTest(now time.Time) *doctorActor {
	return &doctorActor{
		commands:              make(chan doctorCommand, 64),
		passive:               make(chan doctorEvidence, doctorEvidenceQueue),
		expectations:          newDoctorExpectationRegistry(),
		runtime:               &fakeDoctorRuntime{},
		now:                   func() time.Time { return now },
		snapshot:              doctorSnapshot{State: doctorObserving, Supported: true},
		passiveFlushScheduled: true,
	}
}

func TestDoctorUDPIngressCoalescesBeforeQueueAndHistory(t *testing.T) {
	now := time.Now()
	actor := passiveDoctorForTest(now)
	event := tunnel.FlowEvidence{Stage: tunnel.FlowEvidenceIngress, Network: C.UDP, InboundType: C.TUN, At: now}
	for i := 0; i < 10000; i++ {
		actor.ObserveFlow(event)
	}
	if len(actor.passive) != 1 || actor.dropped.Load() != 0 {
		t.Fatalf("queued=%d dropped=%d", len(actor.passive), actor.dropped.Load())
	}
	actor.handlePassive(<-actor.passive)
	if len(actor.snapshot.Evidence) != 1 {
		t.Fatalf("history=%d", len(actor.snapshot.Evidence))
	}
	event.Stage = tunnel.FlowEvidenceDialFinished
	event.ErrorClass = "timeout"
	for i := 0; i < 10; i++ {
		actor.ObserveFlow(event)
	}
	if len(actor.passive) != 10 {
		t.Fatal("dial errors were sampled")
	}
	for len(actor.passive) > 0 {
		if evidence := <-actor.passive; evidence.Outcome != doctorOutcomeFailed {
			t.Fatal("dial error lost failure classification")
		}
	}
	event.Stage = tunnel.FlowEvidenceIngress
	event.Network = C.TCP
	for i := 0; i < 10; i++ {
		actor.ObserveFlow(event)
	}
	if len(actor.passive) != 10 {
		t.Fatal("TCP ingress was sampled")
	}
}

func TestDoctorIngressGateWindowInboundAndReset(t *testing.T) {
	var gate doctorIngressGate
	now := time.Now()
	if !gate.allow(C.TUN, now) || gate.allow(C.TUN, now) || !gate.allow(C.SOCKS5, now) {
		t.Fatal("first event or inbound separation failed")
	}
	if gate.allow(C.TUN, now.Add(doctorPassivePublishPeriod-time.Nanosecond)) ||
		!gate.allow(C.TUN, now.Add(doctorPassivePublishPeriod)) {
		t.Fatal("publish window boundary failed")
	}
	gate.reset()
	if !gate.allow(C.TUN, now) {
		t.Fatal("reset suppressed first new observation")
	}
}

func TestDoctorIngressGateAdmitsOneConcurrentEvent(t *testing.T) {
	actor := passiveDoctorForTest(time.Now())
	event := tunnel.FlowEvidence{Stage: tunnel.FlowEvidenceIngress, Network: C.UDP, InboundType: C.TUN}
	var group sync.WaitGroup
	for i := 0; i < 32; i++ {
		group.Add(1)
		go func() {
			defer group.Done()
			for j := 0; j < 100; j++ {
				actor.ObserveFlow(event)
			}
		}()
	}
	group.Wait()
	if len(actor.passive) != 1 {
		t.Fatalf("queued=%d, want one", len(actor.passive))
	}
}

func TestDoctorExpectationRegisteredDuringIngressBurstStillMatches(t *testing.T) {
	now := time.Now()
	actor := passiveDoctorForTest(now)
	expectation := testDoctorExpectation()
	expectation.Protocol = "udp"
	actor.tunGeneration.Store(expectation.TunGeneration)
	event := tunnel.FlowEvidence{
		Stage: tunnel.FlowEvidenceIngress, Network: C.UDP, InboundType: C.TUN,
		SourcePort: expectation.SourcePort, TargetIP: expectation.Destination.Addr(),
		TargetPort: expectation.Destination.Port(), UID: expectation.UID, At: now,
	}
	actor.ObserveFlow(event)
	if err := actor.expectations.register(expectation, now); err != nil {
		t.Fatal(err)
	}
	actor.ObserveFlow(event)
	if len(actor.commands) != 1 || len(actor.passive) != 1 {
		t.Fatal("active expectation was suppressed by passive ingress gate")
	}
	command := <-actor.commands
	if command.kind != doctorMatchedProbeCommand || command.expectation.ProbeID != expectation.ProbeID {
		t.Fatal("incorrect matched evidence")
	}
	actor.tunGeneration.Add(1)
	actor.ObserveFlow(event)
	if len(actor.commands) != 0 {
		t.Fatal("stale generation matched")
	}
}

func TestDoctorObservationResetReopensIngressGate(t *testing.T) {
	actor := passiveDoctorForTest(time.Now())
	event := tunnel.FlowEvidence{Stage: tunnel.FlowEvidenceIngress, Network: C.UDP, InboundType: C.TUN}
	actor.ObserveFlow(event)
	<-actor.passive
	actor.bumpGeneration(doctorEnvironmentGeneration)
	actor.ObserveFlow(event)
	if len(actor.passive) != 1 {
		t.Fatal("generation change did not admit first ingress")
	}
	<-actor.passive
	actor.reset()
	actor.ObserveFlow(event)
	if len(actor.passive) != 1 {
		t.Fatal("reset did not admit first ingress")
	}
}

func TestDoctorExpectationEmptyFastPathLifecycle(t *testing.T) {
	registry := newDoctorExpectationRegistry()
	for _, remove := range []func(doctorProbeExpectation){
		func(e doctorProbeExpectation) { registry.complete(e.ExamID, e.ProbeID) },
		func(e doctorProbeExpectation) { registry.clearExam(e.ExamID) },
		func(e doctorProbeExpectation) { registry.match(testDoctorObservation(), e.TunGeneration, e.Deadline) },
	} {
		expectation := testDoctorExpectation()
		if err := registry.register(expectation); err != nil {
			t.Fatal(err)
		}
		if !registry.active.Load() {
			t.Fatal("register did not activate matching")
		}
		remove(expectation)
		if registry.active.Load() {
			t.Fatal("empty registry did not restore fast path")
		}
	}
}

func BenchmarkDoctorUDPIngressBurst(b *testing.B) {
	actor := passiveDoctorForTest(time.Now())
	event := tunnel.FlowEvidence{Stage: tunnel.FlowEvidenceIngress, Network: C.UDP, InboundType: C.TUN}
	actor.ObserveFlow(event)
	b.ReportAllocs()
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		actor.ObserveFlow(event)
	}
}
