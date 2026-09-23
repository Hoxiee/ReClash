package main

import (
	"context"
	"errors"
	"net/netip"
	"slices"
	"sync/atomic"
	"testing"
	"time"

	C "github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/tunnel"
)

func TestDoctorStandardExamUsesOneApplicationScopedProbe(t *testing.T) {
	var probes atomic.Int32
	runtime := coreDoctorRuntime{probe: func(context.Context, string) error {
		probes.Add(1)
		return nil
	}}
	var facts []doctorEvidence
	runtime.RunExam(context.Background(), "exam", doctorStandard, doctorExamSink{Emit: func(fact doctorEvidence) {
		facts = append(facts, fact)
	}})

	if probes.Load() != 1 || len(facts) != 2 {
		t.Fatalf("probes = %d, facts = %+v", probes.Load(), facts)
	}
	if facts[0].Code != "coreResolverSucceeded" || facts[1].Layer != doctorLayerMarker || facts[1].Outcome != doctorOutcomeSucceeded || facts[1].Confidence != doctorConfirmed {
		t.Fatalf("facts = %+v", facts)
	}
}

func TestDoctorDeepExamSeparatesResolverAndApplicationProof(t *testing.T) {
	previous := currentTestURL()
	setTestURL("https://doctor.invalid/generate_204")
	t.Cleanup(func() { setTestURL(previous) })
	var coreHost string
	var systemHost string
	runtime := coreDoctorRuntime{
		resolveCore: func(_ context.Context, host string) error {
			coreHost = host
			return errors.New("resolver unavailable")
		},
		resolveSystem: func(_ context.Context, host string) error {
			systemHost = host
			return nil
		},
		probe: func(context.Context, string) error { return nil },
	}
	var facts []doctorEvidence
	runtime.RunExam(context.Background(), "exam", doctorDeep, doctorExamSink{Emit: func(fact doctorEvidence) {
		facts = append(facts, fact)
	}})

	if coreHost != "doctor.invalid" || systemHost != "doctor.invalid" || len(facts) != 3 {
		t.Fatalf("coreHost = %q, systemHost = %q, facts = %+v", coreHost, systemHost, facts)
	}
	if facts[0].Layer != doctorLayerDNS || facts[0].Outcome != doctorOutcomeFailed || facts[0].Confidence != doctorProbable || facts[0].Code != "coreResolverStale" {
		t.Fatalf("resolver fact = %+v", facts[0])
	}
	if facts[1].Layer != doctorLayerDNS || facts[1].Outcome != doctorOutcomeSucceeded || facts[1].Code != "systemResolverSucceeded" {
		t.Fatalf("system resolver fact = %+v", facts[1])
	}
	if facts[2].Layer != doctorLayerMarker || facts[2].Outcome != doctorOutcomeSucceeded {
		t.Fatalf("application fact = %+v", facts[2])
	}
}

func TestDoctorProbeBudgetStaysBounded(t *testing.T) {
	tests := []struct {
		mode         doctorExamMode
		capabilities doctorCapabilities
		want         int
	}{
		{mode: doctorStandard, want: 2},
		{mode: doctorDeep, want: 3},
		{mode: doctorStandard, capabilities: doctorCapabilities{AndroidAppIngressProbe: true}, want: 3},
		{mode: doctorDeep, capabilities: doctorCapabilities{AndroidAppIngressProbe: true}, want: 4},
	}
	for _, test := range tests {
		count := doctorProbeCount(test.mode, test.capabilities)
		if count != test.want || count > doctorMaxProbeCount {
			t.Errorf("doctorProbeCount(%q, %+v) = %d, want %d", test.mode, test.capabilities, count, test.want)
		}
	}
}

func TestDoctorApplicationProbeRejectsGenerate204StatusMismatch(t *testing.T) {
	seenTarget := ""
	runtime := coreDoctorRuntime{probeStatus: func(_ context.Context, target string) (bool, error) {
		seenTarget = target
		return false, nil
	}}
	err := runtime.probeApplication(context.Background(), "https://doctor.invalid/generate_204")
	if !errors.Is(err, errDoctorStatusMismatch) || seenTarget != "https://doctor.invalid/generate_204" {
		t.Fatalf("err = %v, target = %q", err, seenTarget)
	}
	if code := doctorProbeErrorCode(err, "applicationProbeFailed"); code != "probeStatusMismatch" {
		t.Fatalf("code = %q", code)
	}
}

func TestDoctorExpectedStatusesAreStrictOnlyForGenerate204(t *testing.T) {
	statuses := doctorExpectedStatuses("https://doctor.invalid/generate_204")
	if statuses == nil || !statuses.Check(204) || statuses.Check(200) || statuses.Check(302) {
		t.Fatalf("generate_204 statuses = %v", statuses)
	}
	if statuses := doctorExpectedStatuses("https://doctor.invalid/"); statuses != nil {
		t.Fatalf("custom statuses = %v, want any status", statuses)
	}
}

func TestDoctorFlushDNSUsesInjectedRuntimeSeam(t *testing.T) {
	var flushes atomic.Int32
	coreDoctorRuntime{flush: func() { flushes.Add(1) }}.FlushDNS()
	if flushes.Load() != 1 {
		t.Fatalf("flushes = %d, want 1", flushes.Load())
	}
}

func TestDoctorPlatformProbeRegistersBeforeProducerAndMatchesIngress(t *testing.T) {
	previous := currentTestURL()
	setTestURL("https://doctor.invalid/generate_204")
	t.Cleanup(func() { setTestURL(previous) })

	registered := false
	completed := false
	runtime := coreDoctorRuntime{
		probe: func(context.Context, string) error { return nil },
		resolveProbe: func(context.Context, string) ([]netip.Addr, error) {
			return []netip.Addr{netip.MustParseAddr("203.0.113.10")}, nil
		},
		appUID:    func() uint32 { return 10001 },
		port:      func() (uint16, error) { return 49152, nil },
		tunActive: func() bool { return true },
		platformProbe: func(_ context.Context, request doctorPlatformProbeRequest) (doctorPlatformProbeResult, error) {
			if !registered {
				t.Fatal("producer started before expectation registration")
			}
			return doctorPlatformProbeResult{ProbeID: request.ProbeID, Outcome: doctorPlatformProbeCompleted}, nil
		},
	}
	var facts []doctorEvidence
	sink := doctorExamSink{
		Emit: func(fact doctorEvidence) { facts = append(facts, fact) },
		Register: func(expectation doctorProbeExpectation) error {
			registered = true
			expectation.Matched <- struct{}{}
			return nil
		},
		Complete: func(string) error {
			completed = true
			return nil
		},
	}
	runtime.RunExam(context.Background(), "exam", doctorStandard, sink)

	if !registered || !completed || len(facts) != 2 {
		t.Fatalf("registered = %v, completed = %v, facts = %+v", registered, completed, facts)
	}
	if facts[1].Layer != doctorLayerMarker || facts[1].Outcome != doctorOutcomeSucceeded {
		t.Fatalf("application fact = %+v", facts[1])
	}
}

func TestDoctorPlatformProbeRetriesBindCollisionWithNewPort(t *testing.T) {
	previous := currentTestURL()
	setTestURL("https://203.0.113.10/generate_204")
	t.Cleanup(func() { setTestURL(previous) })

	ports := []uint16{49152, 49153}
	calls := 0
	registered := make([]uint16, 0, 2)
	completed := 0
	runtime := coreDoctorRuntime{
		probe:  func(context.Context, string) error { return nil },
		appUID: func() uint32 { return 10001 },
		port: func() (uint16, error) {
			port := ports[calls]
			return port, nil
		},
		tunActive: func() bool { return true },
		platformProbe: func(_ context.Context, request doctorPlatformProbeRequest) (doctorPlatformProbeResult, error) {
			outcome := doctorPlatformProbeBindCollision
			if calls == 1 {
				outcome = doctorPlatformProbeIOError
			}
			calls++
			return doctorPlatformProbeResult{ProbeID: request.ProbeID, Outcome: outcome}, nil
		},
	}
	var facts []doctorEvidence
	runtime.RunExam(context.Background(), "exam", doctorStandard, doctorExamSink{
		Emit: func(fact doctorEvidence) { facts = append(facts, fact) },
		Register: func(expectation doctorProbeExpectation) error {
			registered = append(registered, expectation.SourcePort)
			return nil
		},
		Complete: func(string) error {
			completed++
			return nil
		},
	})

	if calls != 2 || completed != 2 || !slices.Equal(registered, ports) {
		t.Fatalf("calls = %d, completed = %d, registered = %v", calls, completed, registered)
	}
	if len(facts) != 3 || facts[1].Layer != doctorLayerIngress ||
		facts[1].Outcome != doctorOutcomeSeen || facts[1].Confidence != doctorInsufficient {
		t.Fatalf("facts = %+v", facts)
	}
}

func TestDoctorPlatformProbeFailuresDoNotDiagnoseIngress(t *testing.T) {
	for _, outcome := range []doctorPlatformProbeOutcome{
		doctorPlatformProbeBindCollision,
		doctorPlatformProbeTimeout,
		doctorPlatformProbeIOError,
	} {
		fact := doctorPlatformProbeEvidence(doctorPlatformProbeResult{Outcome: outcome})
		if fact.Outcome != doctorOutcomeSeen || fact.Confidence != doctorInsufficient {
			t.Errorf("outcome %q produced %+v", outcome, fact)
		}
	}
}

func TestDoctorCompletedPlatformProbeWithoutIngressStaysInsufficient(t *testing.T) {
	previous := currentTestURL()
	setTestURL("https://203.0.113.10/generate_204")
	t.Cleanup(func() { setTestURL(previous) })

	runtime := coreDoctorRuntime{
		probe:     func(context.Context, string) error { return nil },
		appUID:    func() uint32 { return 10001 },
		port:      func() (uint16, error) { return 49152, nil },
		tunActive: func() bool { return true },
		platformProbe: func(_ context.Context, request doctorPlatformProbeRequest) (doctorPlatformProbeResult, error) {
			return doctorPlatformProbeResult{ProbeID: request.ProbeID, Outcome: doctorPlatformProbeCompleted}, nil
		},
	}
	var facts []doctorEvidence
	runtime.RunExam(context.Background(), "exam", doctorStandard, doctorExamSink{
		Emit: func(fact doctorEvidence) { facts = append(facts, fact) },
		Register: func(doctorProbeExpectation) error {
			return nil
		},
		Complete: func(string) error {
			return nil
		},
	})

	if len(facts) != 3 {
		t.Fatalf("facts = %+v", facts)
	}
	if fact := facts[1]; fact.Layer != doctorLayerIngress || fact.Outcome != doctorOutcomeSeen ||
		fact.Confidence != doctorInsufficient || fact.Code != "appIngressNotObserved" {
		t.Fatalf("platform fact = %+v", fact)
	}
}

func TestDoctorActorCorrelatesRuntimePlatformProbe(t *testing.T) {
	previous := currentTestURL()
	setTestURL("https://203.0.113.10/generate_204")
	t.Cleanup(func() { setTestURL(previous) })

	var actor *doctorActor
	runtime := coreDoctorRuntime{
		probe:     func(context.Context, string) error { return nil },
		appUID:    func() uint32 { return 10001 },
		port:      func() (uint16, error) { return 49152, nil },
		tunActive: func() bool { return true },
		platformProbe: func(_ context.Context, request doctorPlatformProbeRequest) (doctorPlatformProbeResult, error) {
			actor.ObserveFlow(tunnel.FlowEvidence{
				Stage:       tunnel.FlowEvidenceIngress,
				At:          time.Now(),
				Network:     C.TCP,
				InboundType: C.TUN,
				SourceIP:    netip.MustParseAddr("10.0.0.2"),
				SourcePort:  request.SourcePort,
				TargetIP:    netip.MustParseAddr(request.DestinationIP),
				TargetPort:  request.DestinationPort,
			})
			return doctorPlatformProbeResult{ProbeID: request.ProbeID, Outcome: doctorPlatformProbeCompleted}, nil
		},
	}
	actor = newDoctorActor(runtime, nil)
	actor.SetIdentity(func(observation doctorProbeObservation) (doctorProbeObservation, bool) {
		observation.UID = 10001
		return observation, true
	})
	started, err := actor.Start(doctorStartParams{Mode: doctorStandard})
	if err != nil {
		t.Fatal(err)
	}

	deadline := time.Now().Add(2 * time.Second)
	for time.Now().Before(deadline) {
		snapshot := actor.Snapshot()
		if snapshot.ExamID == started.ExamID && snapshot.State == doctorComplete {
			matched := false
			for _, fact := range snapshot.Evidence {
				if fact.Code == "appIngressMatched" && fact.Outcome == doctorOutcomeSucceeded && fact.Confidence == doctorConfirmed {
					matched = true
				}
				if fact.Code == "appIngressNotObserved" {
					t.Fatalf("matched probe also emitted missing-ingress evidence: %+v", snapshot.Evidence)
				}
			}
			if !matched || snapshot.Health != doctorHealthy {
				t.Fatalf("snapshot = %+v", snapshot)
			}
			return
		}
		time.Sleep(time.Millisecond)
	}
	t.Fatal("correlated platform exam did not complete")
}

func TestDoctorPlatformProbeUsesLaterAddressWhenFirstFails(t *testing.T) {
	previous := currentTestURL()
	setTestURL("https://doctor.invalid/generate_204")
	t.Cleanup(func() { setTestURL(previous) })
	addresses := []netip.Addr{
		netip.MustParseAddr("203.0.113.10"),
		netip.MustParseAddr("203.0.113.11"),
	}
	var destinations []string
	var facts []doctorEvidence
	runtime := coreDoctorRuntime{
		probe:        func(context.Context, string) error { return nil },
		resolveProbe: func(context.Context, string) ([]netip.Addr, error) { return addresses, nil },
		appUID:       func() uint32 { return 10001 },
		port:         func() (uint16, error) { return 49152, nil },
		tunActive:    func() bool { return true },
		platformProbe: func(_ context.Context, request doctorPlatformProbeRequest) (doctorPlatformProbeResult, error) {
			destinations = append(destinations, request.DestinationIP)
			outcome := doctorPlatformProbeIOError
			if request.DestinationIP == addresses[1].String() {
				outcome = doctorPlatformProbeCompleted
			}
			return doctorPlatformProbeResult{ProbeID: request.ProbeID, Outcome: outcome}, nil
		},
	}
	runtime.RunExam(context.Background(), "exam", doctorStandard, doctorExamSink{
		Emit: func(fact doctorEvidence) { facts = append(facts, fact) },
		Register: func(expectation doctorProbeExpectation) error {
			if expectation.Destination.Addr() == addresses[1] {
				expectation.Matched <- struct{}{}
			}
			return nil
		},
		Complete: func(string) error { return nil },
	})
	if !slices.Equal(destinations, []string{addresses[0].String(), addresses[1].String()}) {
		t.Fatalf("destinations = %v", destinations)
	}
	for _, fact := range facts {
		if fact.Layer == doctorLayerIngress {
			t.Fatalf("matched later address emitted platform failure: %+v", facts)
		}
	}
}

func TestDoctorPlatformProbeEmitsOneMissAfterAllAddresses(t *testing.T) {
	previous := currentTestURL()
	setTestURL("https://doctor.invalid/generate_204")
	t.Cleanup(func() { setTestURL(previous) })
	var facts []doctorEvidence
	calls := 0
	runtime := coreDoctorRuntime{
		probe: func(context.Context, string) error { return nil },
		resolveProbe: func(context.Context, string) ([]netip.Addr, error) {
			return []netip.Addr{netip.MustParseAddr("203.0.113.10"), netip.MustParseAddr("203.0.113.11")}, nil
		},
		appUID:    func() uint32 { return 10001 },
		port:      func() (uint16, error) { return 49152, nil },
		tunActive: func() bool { return true },
		platformProbe: func(_ context.Context, request doctorPlatformProbeRequest) (doctorPlatformProbeResult, error) {
			calls++
			return doctorPlatformProbeResult{ProbeID: request.ProbeID, Outcome: doctorPlatformProbeCompleted}, nil
		},
	}
	runtime.RunExam(context.Background(), "exam", doctorStandard, doctorExamSink{
		Emit:     func(fact doctorEvidence) { facts = append(facts, fact) },
		Register: func(doctorProbeExpectation) error { return nil },
		Complete: func(string) error { return nil },
	})
	misses := 0
	for _, fact := range facts {
		if fact.Code == "appIngressNotObserved" {
			misses++
		}
	}
	if calls != 2 || misses != 1 {
		t.Fatalf("calls = %d, misses = %d, facts = %+v", calls, misses, facts)
	}
}

func TestDoctorProbeAddressesNormalizeDeduplicateAndBound(t *testing.T) {
	got := doctorProbeAddresses([]netip.Addr{
		{},
		netip.MustParseAddr("::ffff:203.0.113.10"),
		netip.MustParseAddr("203.0.113.10"),
		netip.MustParseAddr("2001:db8::1"),
		netip.MustParseAddr("203.0.113.11"),
	})
	want := []netip.Addr{netip.MustParseAddr("203.0.113.10"), netip.MustParseAddr("2001:db8::1")}
	if !slices.Equal(got, want) {
		t.Fatalf("addresses = %v, want %v", got, want)
	}
}

func TestDoctorInactiveTunReturnsConfirmedCaptureFailure(t *testing.T) {
	runtime := coreDoctorRuntime{
		probe: func(context.Context, string) error { return nil },
		platformProbe: func(context.Context, doctorPlatformProbeRequest) (doctorPlatformProbeResult, error) {
			t.Fatal("platform probe ran without an active TUN")
			return doctorPlatformProbeResult{}, nil
		},
		tunActive: func() bool { return false },
		pathContext: func() doctorPathContext {
			return doctorPathContext{PathKind: doctorPathVPN, CaptureState: doctorCaptureInactive}
		},
		appUID: func() uint32 { return 10001 },
	}
	actor := newDoctorActor(runtime, nil)
	if !actor.Snapshot().Capabilities.TunIngressProof || runtime.DoctorAppIngressAvailable() {
		t.Fatalf("capabilities = %+v, available = %v", actor.Snapshot().Capabilities, runtime.DoctorAppIngressAvailable())
	}
	started, err := actor.Start(doctorStartParams{Mode: doctorStandard})
	if err != nil {
		t.Fatal(err)
	}
	deadline := time.Now().Add(time.Second)
	for time.Now().Before(deadline) {
		snapshot := actor.Snapshot()
		if snapshot.ExamID == started.ExamID && snapshot.State == doctorComplete {
			if snapshot.Health != doctorBroken || snapshot.CauseCode != "vpnNotActive" || snapshot.Layer != doctorLayerCapture {
				t.Fatalf("snapshot = %+v", snapshot)
			}
			return
		}
		time.Sleep(time.Millisecond)
	}
	t.Fatal("inactive-TUN exam did not complete")
}

func TestDoctorApplicationFailureClassifiesKnownNetworkFacts(t *testing.T) {
	for _, test := range []struct {
		name  string
		facts networkFactsPayload
		want  string
	}{
		{name: "offline", facts: networkFactsPayload{}, want: "noPhysicalNetwork"},
		{name: "portal", facts: networkFactsPayload{Transport: "wifi", CaptivePortal: true}, want: "captivePortal"},
		{name: "unvalidated", facts: networkFactsPayload{Transport: "wifi"}, want: "networkUnvalidated"},
	} {
		t.Run(test.name, func(t *testing.T) {
			runtime := coreDoctorRuntime{probe: func(context.Context, string) error { return errors.New("failed") }, network: func() (networkFactsPayload, bool) { return test.facts, true }}
			var facts []doctorEvidence
			runtime.runApplicationProbe(context.Background(), func(fact doctorEvidence) { facts = append(facts, fact) })
			if len(facts) != 2 || facts[0].Code != test.want || facts[1].Layer != doctorLayerMarker {
				t.Fatalf("facts = %+v", facts)
			}
			verdict := reduceDoctorEvidence(facts, true, doctorPathContext{PathKind: doctorPathLocalProxy, CaptureState: doctorCaptureNotApplicable}, false)
			markDoctorConsequences(facts, verdict.Layer)
			if !facts[1].Consequence {
				t.Fatalf("consequences = %+v", facts)
			}
		})
	}
}

func TestDoctorApplicationSuccessDoesNotInventNetworkFault(t *testing.T) {
	runtime := coreDoctorRuntime{probe: func(context.Context, string) error { return nil }, network: func() (networkFactsPayload, bool) {
		return networkFactsPayload{Transport: "wifi", Validated: false}, true
	}}
	var facts []doctorEvidence
	runtime.runApplicationProbe(context.Background(), func(fact doctorEvidence) { facts = append(facts, fact) })
	if len(facts) != 1 || facts[0].Code != "applicationProbeSucceeded" {
		t.Fatalf("facts = %+v", facts)
	}
}

func TestDoctorApplicationFailureLeavesUnknownFactsUnclassified(t *testing.T) {
	runtime := coreDoctorRuntime{probe: func(context.Context, string) error { return errors.New("failed") }, network: func() (networkFactsPayload, bool) { return networkFactsPayload{}, false }}
	var facts []doctorEvidence
	runtime.runApplicationProbe(context.Background(), func(fact doctorEvidence) { facts = append(facts, fact) })
	if len(facts) != 1 || facts[0].Layer != doctorLayerMarker {
		t.Fatalf("facts = %+v", facts)
	}
}

func TestDoctorPathContextForStatusHonorsLifecyclePhase(t *testing.T) {
	for _, test := range []struct {
		name   string
		status doctorPathStatus
		tunUp  bool
		want   doctorPathContext
	}{
		{name: "active vpn still requires tun", status: doctorPathStatus{PathKind: doctorPathVPN, Phase: "active"}, want: doctorPathContext{PathKind: doctorPathVPN, CaptureState: doctorCaptureInactive}},
		{name: "active vpn with tun", status: doctorPathStatus{PathKind: doctorPathVPN, Phase: "active"}, tunUp: true, want: doctorPathContext{PathKind: doctorPathVPN, CaptureState: doctorCaptureActive}},
		{name: "paused vpn overrides stale tun", status: doctorPathStatus{PathKind: doctorPathVPN, Phase: "paused"}, tunUp: true, want: doctorPathContext{PathKind: doctorPathVPN, CaptureState: doctorCaptureInactive}},
		{name: "inactive vpn overrides stale tun", status: doctorPathStatus{PathKind: doctorPathVPN, Phase: "inactive"}, tunUp: true, want: doctorPathContext{PathKind: doctorPathVPN, CaptureState: doctorCaptureInactive}},
		{name: "local proxy capture is not applicable", status: doctorPathStatus{PathKind: doctorPathLocalProxy, Phase: "inactive"}, want: doctorPathContext{PathKind: doctorPathLocalProxy, CaptureState: doctorCaptureNotApplicable}},
	} {
		t.Run(test.name, func(t *testing.T) {
			if got := doctorPathContextForStatus(test.status, test.tunUp); got != test.want {
				t.Fatalf("path context = %+v, want %+v", got, test.want)
			}
		})
	}
}
