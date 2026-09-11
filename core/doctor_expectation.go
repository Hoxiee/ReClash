package main

import (
	"context"
	"errors"
	"net"
	"net/netip"
	"sync"
	"time"

	"github.com/metacubex/mihomo/component/process"
	C "github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/tunnel"
	"github.com/metacubex/mihomo/tunnel/statistic"
)

var (
	errDoctorExpectationInactive = errors.New("exam_not_active")
	errDoctorExpectationInvalid  = errors.New("probe_expectation_invalid")
	errDoctorExpectationLimit    = errors.New("probe_budget_exhausted")
)

type doctorProbeExpectation struct {
	ExamID        string
	ProbeID       string
	Protocol      string
	SourcePort    uint16
	Destination   netip.AddrPort
	UID           uint32
	Package       string
	TunGeneration uint64
	Deadline      time.Time
	Matched       chan struct{}
}

type doctorProbeObservation struct {
	Protocol    string
	SourceIP    netip.Addr
	SourcePort  uint16
	Destination netip.AddrPort
	UID         uint32
	Package     string
}

type doctorExpectationRegistry struct {
	mu           sync.Mutex
	expectations map[string]doctorProbeExpectation
	confirmed    map[string]bool
}

func newDoctorExpectationRegistry() *doctorExpectationRegistry {
	return &doctorExpectationRegistry{
		expectations: make(map[string]doctorProbeExpectation),
		confirmed:    make(map[string]bool),
	}
}

func (registry *doctorExpectationRegistry) register(expectation doctorProbeExpectation, now ...time.Time) error {
	if expectation.ExamID == "" || expectation.ProbeID == "" ||
		expectation.Protocol == "" || expectation.SourcePort == 0 ||
		!expectation.Destination.IsValid() || expectation.Destination.Port() == 0 ||
		expectation.Deadline.IsZero() || (expectation.UID == 0 && expectation.Package == "") {
		return errDoctorExpectationInvalid
	}
	registry.mu.Lock()
	defer registry.mu.Unlock()
	current := time.Now()
	if len(now) != 0 {
		current = now[0]
	}
	registry.purgeExpiredLocked(current)
	if _, exists := registry.expectations[expectation.ProbeID]; !exists && len(registry.expectations) >= doctorMaxProbeCount {
		return errDoctorExpectationLimit
	}
	registry.expectations[expectation.ProbeID] = expectation
	registry.confirmed[expectation.ProbeID] = false
	return nil
}

func (registry *doctorExpectationRegistry) complete(examID, probeID string) {
	registry.mu.Lock()
	defer registry.mu.Unlock()
	if expectation, exists := registry.expectations[probeID]; exists && expectation.ExamID == examID {
		delete(registry.expectations, probeID)
		delete(registry.confirmed, probeID)
	}
}

func (registry *doctorExpectationRegistry) clearExam(examID string) {
	registry.mu.Lock()
	defer registry.mu.Unlock()
	for probeID, expectation := range registry.expectations {
		if expectation.ExamID == examID {
			delete(registry.expectations, probeID)
			delete(registry.confirmed, probeID)
		}
	}
}

func (registry *doctorExpectationRegistry) match(observation doctorProbeObservation, tunGeneration uint64, now time.Time) (doctorProbeExpectation, bool) {
	registry.mu.Lock()
	defer registry.mu.Unlock()
	registry.purgeExpiredLocked(now)
	for _, expectation := range registry.expectations {
		if expectation.TunGeneration != tunGeneration || expectation.Protocol != observation.Protocol ||
			expectation.SourcePort != observation.SourcePort || expectation.Destination != observation.Destination ||
			(expectation.UID != 0 && expectation.UID != observation.UID) ||
			(expectation.Package != "" && observation.Package != "" && expectation.Package != observation.Package) ||
			(expectation.UID == 0 && expectation.Package != observation.Package) {
			continue
		}
		return expectation, true
	}
	return doctorProbeExpectation{}, false
}

func (registry *doctorExpectationRegistry) candidate(observation doctorProbeObservation, tunGeneration uint64, now time.Time) (doctorProbeExpectation, bool) {
	registry.mu.Lock()
	defer registry.mu.Unlock()
	registry.purgeExpiredLocked(now)
	for _, expectation := range registry.expectations {
		if expectation.TunGeneration == tunGeneration && expectation.Protocol == observation.Protocol &&
			expectation.SourcePort == observation.SourcePort && expectation.Destination == observation.Destination {
			return expectation, true
		}
	}
	return doctorProbeExpectation{}, false
}

func (registry *doctorExpectationRegistry) confirm(expectation doctorProbeExpectation) bool {
	registry.mu.Lock()
	defer registry.mu.Unlock()
	current, exists := registry.expectations[expectation.ProbeID]
	if !exists || current.ExamID != expectation.ExamID || registry.confirmed[expectation.ProbeID] {
		return false
	}
	registry.confirmed[expectation.ProbeID] = true
	return true
}

func (registry *doctorExpectationRegistry) isConfirmed(expectation doctorProbeExpectation) bool {
	registry.mu.Lock()
	defer registry.mu.Unlock()
	current, exists := registry.expectations[expectation.ProbeID]
	return exists && current.ExamID == expectation.ExamID && registry.confirmed[expectation.ProbeID]
}

func (registry *doctorExpectationRegistry) purgeExpiredLocked(now time.Time) {
	for probeID, expectation := range registry.expectations {
		if !now.Before(expectation.Deadline) {
			delete(registry.expectations, probeID)
			delete(registry.confirmed, probeID)
		}
	}
}

type doctorExamSink struct {
	Emit     func(doctorEvidence)
	Register func(doctorProbeExpectation) error
	Complete func(string) error
}

func (actor *doctorActor) registerExpectation(ctx context.Context, examID string, expectation doctorProbeExpectation) error {
	expectation.ExamID = examID
	response := make(chan doctorResult, 1)
	command := doctorCommand{
		kind:        doctorRegisterExpectationCommand,
		examID:      examID,
		expectation: expectation,
		response:    response,
	}
	select {
	case actor.commands <- command:
	case <-ctx.Done():
		return ctx.Err()
	}
	select {
	case result := <-response:
		return result.err
	case <-ctx.Done():
		return ctx.Err()
	}
}

func (actor *doctorActor) completeExpectation(ctx context.Context, examID, probeID string) error {
	response := make(chan doctorResult, 1)
	command := doctorCommand{
		kind:     doctorCompleteExpectationCommand,
		examID:   examID,
		probeID:  probeID,
		response: response,
	}
	select {
	case actor.commands <- command:
	case <-ctx.Done():
		return ctx.Err()
	}
	select {
	case result := <-response:
		return result.err
	case <-ctx.Done():
		return ctx.Err()
	}
}

func (actor *doctorActor) activeEvidence(examID string, evidence doctorEvidence) {
	select {
	case actor.commands <- doctorCommand{kind: doctorExamEvidenceCommand, examID: examID, evidence: evidence}:
	default:
		actor.dropped.Add(1)
		select {
		case actor.commands <- doctorCommand{kind: doctorOverflowCommand}:
		default:
		}
	}
}

func (actor *doctorActor) matchedProbeEvidence(expectation doctorProbeExpectation, fact doctorEvidence) {
	actor.commands <- doctorCommand{kind: doctorMatchedProbeCommand, expectation: expectation, matchedFact: fact}
}

func (actor *doctorActor) ObserveFlow(event tunnel.FlowEvidence) {
	fact := doctorEvidenceFromFlow(event)
	observation, valid := doctorObservationFromFlow(event)
	if valid && event.InboundType == C.TUN {
		tunGeneration := actor.tunGeneration.Load()
		if expectation, matched := actor.expectations.match(observation, tunGeneration, actor.now()); matched {
			actor.acceptMatchedProbe(expectation, fact)
			return
		}
		if event.Stage == tunnel.FlowEvidenceIngress {
			if expectation, candidate := actor.expectations.candidate(observation, tunGeneration, actor.now()); candidate {
				safeGoDetached("connection doctor ingress identity", func() {
					resolved, ok := actor.resolveProbeIdentity(observation)
					if !ok {
						actor.activeEvidence(expectation.ExamID, doctorEvidence{
							Kind: doctorEvidenceIngress, Layer: doctorLayerIngress,
							Outcome: doctorOutcomeSeen, Confidence: doctorInsufficient,
							Code: "appIngressIdentityUnavailable", Inbound: "tun", at: actor.now(),
						})
						return
					}
					currentGeneration := actor.tunGeneration.Load()
					matched, ok := actor.expectations.match(resolved, currentGeneration, actor.now())
					if ok && matched.ProbeID == expectation.ProbeID {
						actor.acceptMatchedProbe(matched, fact)
					}
				})
				return
			}
		}
	}
	actor.Passive(fact)
}

func (actor *doctorActor) ObserveTracker(tracker statistic.Tracker, progress bool) {
	fact := doctorEvidenceFromTracker(tracker, progress)
	observation, valid := doctorObservationFromTracker(tracker)
	if valid && tracker.Info().Metadata.Type == C.TUN {
		tunGeneration := actor.tunGeneration.Load()
		if expectation, matched := actor.expectations.match(observation, tunGeneration, actor.now()); matched {
			actor.acceptMatchedProbe(expectation, fact)
			return
		}
	}
	actor.Passive(fact)
}

func (actor *doctorActor) acceptMatchedProbe(expectation doctorProbeExpectation, fact doctorEvidence) {
	actor.matchedProbeEvidence(expectation, fact)
}

func (actor *doctorActor) resolveProbeIdentity(observation doctorProbeObservation) (doctorProbeObservation, bool) {
	if actor.identity == nil {
		return doctorProbeObservation{}, false
	}
	return actor.identity(observation)
}

func resolveDoctorProbeIdentity(observation doctorProbeObservation) (doctorProbeObservation, bool) {
	if !observation.SourceIP.IsValid() || !observation.Destination.IsValid() {
		return doctorProbeObservation{}, false
	}
	metadata := &C.Metadata{
		NetWork: observationNetwork(observation.Protocol),
		SrcIP:   observation.SourceIP,
		SrcPort: observation.SourcePort,
		DstIP:   observation.Destination.Addr(),
		DstPort: observation.Destination.Port(),
	}
	if metadata.NetWork == C.TCP {
		metadata.RawSrcAddr = net.TCPAddrFromAddrPort(netip.AddrPortFrom(observation.SourceIP, observation.SourcePort))
		metadata.RawDstAddr = net.TCPAddrFromAddrPort(observation.Destination)
	} else {
		return doctorProbeObservation{}, false
	}
	packageName, err := process.FindPackageName(metadata)
	if err != nil || metadata.Uid == 0 {
		return doctorProbeObservation{}, false
	}
	observation.UID = metadata.Uid
	observation.Package = packageName
	return observation, true
}

func observationNetwork(protocol string) C.NetWork {
	if protocol == C.TCP.String() {
		return C.TCP
	}
	return C.ALLNet
}

func doctorObservationFromFlow(event tunnel.FlowEvidence) (doctorProbeObservation, bool) {
	return newDoctorProbeObservation(
		event.Network,
		event.SourceIP,
		event.SourcePort,
		event.TargetIP,
		event.TargetPort,
		event.UID,
		"",
	)
}

func doctorObservationFromTracker(tracker statistic.Tracker) (doctorProbeObservation, bool) {
	if tracker == nil || tracker.Info() == nil || tracker.Info().Metadata == nil {
		return doctorProbeObservation{}, false
	}
	metadata := tracker.Info().Metadata
	return newDoctorProbeObservation(
		metadata.NetWork,
		metadata.SrcIP,
		metadata.SrcPort,
		metadata.DstIP,
		metadata.DstPort,
		metadata.Uid,
		metadata.Process,
	)
}

func newDoctorProbeObservation(protocol C.NetWork, sourceIP netip.Addr, sourcePort uint16, destinationIP netip.Addr, destinationPort uint16, uid uint32, packageName string) (doctorProbeObservation, bool) {
	if sourcePort == 0 || !destinationIP.IsValid() || destinationPort == 0 {
		return doctorProbeObservation{}, false
	}
	return doctorProbeObservation{
		Protocol:    protocol.String(),
		SourceIP:    sourceIP.Unmap(),
		SourcePort:  sourcePort,
		Destination: netip.AddrPortFrom(destinationIP.Unmap(), destinationPort),
		UID:         uid,
		Package:     packageName,
	}, true
}
