package main

import (
	"context"
	"errors"
	"net/netip"
	"net/url"
	"os"
	"strings"
	"sync/atomic"
	"time"

	"github.com/metacubex/mihomo/common/utils"
	"github.com/metacubex/mihomo/component/resolver"
	"github.com/metacubex/mihomo/constant/features"
	"github.com/metacubex/mihomo/listener"
)

const doctorProbeTimeout = 8 * time.Second

var (
	errDoctorNoActiveProxy  = errors.New("no active proxy")
	errDoctorStatusMismatch = errors.New("probe status mismatch")
	doctorAndroidPathStatus atomic.Value
)

func init() {
	doctorAndroidPathStatus.Store(doctorPathStatus{PathKind: doctorPathUnknown})
}

type coreDoctorRuntime struct {
	probe         func(context.Context, string) error
	probeStatus   func(context.Context, string) (bool, error)
	resolveCore   func(context.Context, string) error
	resolveSystem func(context.Context, string) error
	resolveProbe  func(context.Context, string) ([]netip.Addr, error)
	platformProbe doctorPlatformProbeRunner
	tunActive     func() bool
	pathContext   func() doctorPathContext
	network       func() (networkFactsPayload, bool)
	appUID        func() uint32
	port          func() (uint16, error)
	now           func() time.Time
	flush         func()
}

func (runtime coreDoctorRuntime) RunExam(ctx context.Context, examID string, mode doctorExamMode, sink doctorExamSink) {
	type probeFacts struct {
		resolver []doctorEvidence
		platform []doctorEvidence
		app      []doctorEvidence
	}
	facts := probeFacts{}
	resolverDone := make(chan struct{})
	go func() {
		defer close(resolverDone)
		runtime.runResolverProbe(ctx, mode == doctorDeep, func(fact doctorEvidence) {
			facts.resolver = append(facts.resolver, fact)
		})
	}()
	if runtime.canRunPlatformProbe(sink) {
		platformSink := sink
		platformSink.Emit = func(fact doctorEvidence) {
			facts.platform = append(facts.platform, fact)
		}
		runtime.runPlatformProbe(ctx, examID, platformSink)
	}
	runtime.runApplicationProbe(ctx, func(fact doctorEvidence) {
		facts.app = append(facts.app, fact)
	})
	<-resolverDone
	for _, group := range [][]doctorEvidence{facts.resolver, facts.platform, facts.app} {
		for _, fact := range group {
			sink.Emit(fact)
		}
	}
}

func (runtime coreDoctorRuntime) runResolverProbe(ctx context.Context, compareSystem bool, emit func(doctorEvidence)) {
	started := time.Now()
	fact := doctorEvidence{
		Kind:       doctorEvidenceProbe,
		Layer:      doctorLayerDNS,
		Outcome:    doctorOutcomeNotApplicable,
		Confidence: doctorInsufficient,
		Code:       "endpointDnsNotApplicable",
		at:         started,
	}
	parsed, err := url.Parse(currentTestURL())
	if err != nil || parsed.Hostname() == "" {
		emit(fact)
		return
	}
	if _, err := netip.ParseAddr(parsed.Hostname()); err == nil {
		emit(fact)
		return
	}
	probeCtx, cancel := context.WithTimeout(ctx, doctorProbeTimeout)
	coreErr := runtime.resolveWithCore(probeCtx, parsed.Hostname())
	cancel()
	fact.DurationBucketMs = doctorDurationBucket(time.Since(started))
	fact.at = time.Now()
	if coreErr == nil {
		fact.Outcome = doctorOutcomeSucceeded
		fact.Confidence = doctorConfirmed
		fact.Code = "coreResolverSucceeded"
	} else {
		fact.Outcome = doctorOutcomeFailed
		fact.Confidence = doctorProbable
		fact.Code = doctorProbeErrorCode(coreErr, "coreResolverFailed")
	}
	if !compareSystem {
		emit(fact)
		return
	}
	fallbackStarted := time.Now()
	fallbackCtx, fallbackCancel := context.WithTimeout(ctx, doctorProbeTimeout)
	fallbackErr := runtime.resolveWithSystem(fallbackCtx, parsed.Hostname())
	fallbackCancel()
	if coreErr != nil && fallbackErr == nil {
		fact.Code = "coreResolverStale"
	}
	emit(fact)
	fallback := doctorEvidence{
		Kind:             doctorEvidenceProbe,
		Layer:            doctorLayerDNS,
		Outcome:          doctorOutcomeSucceeded,
		Confidence:       doctorConfirmed,
		Code:             "systemResolverSucceeded",
		DurationBucketMs: doctorDurationBucket(time.Since(fallbackStarted)),
		at:               time.Now(),
	}
	if fallbackErr != nil {
		fallback.Outcome = doctorOutcomeFailed
		fallback.Confidence = doctorProbable
		fallback.Code = doctorProbeErrorCode(fallbackErr, "systemResolverFailed")
	}
	emit(fallback)
}

func (runtime coreDoctorRuntime) resolveWithCore(ctx context.Context, host string) error {
	if runtime.resolveCore != nil {
		return runtime.resolveCore(ctx, host)
	}
	_, err := resolver.LookupIP(ctx, host)
	return err
}

func (runtime coreDoctorRuntime) resolveWithSystem(ctx context.Context, host string) error {
	if runtime.resolveSystem != nil {
		return runtime.resolveSystem(ctx, host)
	}
	_, err := resolver.SystemResolver.LookupIP(ctx, host)
	return err
}

func (runtime coreDoctorRuntime) canRunPlatformProbe(sink doctorExamSink) bool {
	return runtime.DoctorAppIngressAvailable() && sink.Register != nil && sink.Complete != nil
}

func (runtime coreDoctorRuntime) DoctorAppIngressAvailable() bool {
	path := runtime.DoctorPathContext()
	return (path.PathKind == doctorPathVPN || path.PathKind == doctorPathTun) && path.CaptureState == doctorCaptureActive &&
		runtime.platformProbeRunner() != nil && runtime.applicationUID() != 0
}

func (runtime coreDoctorRuntime) DoctorPathContext() doctorPathContext {
	if runtime.pathContext != nil {
		return normalizedDoctorPathContext(runtime.pathContext())
	}
	if runtime.tunActive != nil {
		return doctorPathContextFor(doctorPathTun, runtime.tunActive())
	}
	if features.Android {
		status, _ := doctorAndroidPathStatus.Load().(doctorPathStatus)
		return doctorPathContextForStatus(status, tunUp.Load())
	}
	if tunUp.Load() {
		return doctorPathContext{PathKind: doctorPathTun, CaptureState: doctorCaptureActive}
	}
	ports := listener.GetPorts()
	if isRunning.Load() && (ports.Port != 0 || ports.SocksPort != 0 || ports.MixedPort != 0) {
		return doctorPathContext{PathKind: doctorPathLocalProxy, CaptureState: doctorCaptureNotApplicable}
	}
	return doctorPathContext{PathKind: doctorPathUnknown, CaptureState: doctorCaptureUnknown}
}

func doctorPathContextForStatus(status doctorPathStatus, tunActive bool) doctorPathContext {
	if (status.PathKind == doctorPathVPN || status.PathKind == doctorPathTun) && status.Phase != "active" {
		return doctorPathContext{PathKind: status.PathKind, CaptureState: doctorCaptureInactive}
	}
	return doctorPathContextFor(status.PathKind, tunActive)
}

func doctorPathContextFor(path doctorPathKind, tunActive bool) doctorPathContext {
	switch path {
	case doctorPathVPN, doctorPathTun:
		if tunActive {
			return doctorPathContext{PathKind: path, CaptureState: doctorCaptureActive}
		}
		return doctorPathContext{PathKind: path, CaptureState: doctorCaptureInactive}
	case doctorPathLocalProxy, doctorPathDirect, doctorPathByeDPI:
		return doctorPathContext{PathKind: path, CaptureState: doctorCaptureNotApplicable}
	default:
		return doctorPathContext{PathKind: doctorPathUnknown, CaptureState: doctorCaptureUnknown}
	}
}

func normalizedDoctorPathContext(path doctorPathContext) doctorPathContext {
	if path.PathKind == "" {
		path.PathKind = doctorPathUnknown
	}
	if path.CaptureState == "" {
		path.CaptureState = doctorCaptureUnknown
	}
	return path
}

func (runtime coreDoctorRuntime) networkSnapshot() (networkFactsPayload, bool) {
	if runtime.network != nil {
		return runtime.network()
	}
	return coreNetworkFacts.Snapshot()
}

func (runtime coreDoctorRuntime) platformProbeRunner() doctorPlatformProbeRunner {
	if runtime.platformProbe != nil {
		return runtime.platformProbe
	}
	return doctorPlatformProbeRunnerForRuntime()
}

func (runtime coreDoctorRuntime) DoctorCapabilities() doctorCapabilities {
	available := runtime.platformProbeRunner() != nil
	return doctorCapabilities{
		AndroidAppIngressProbe: available,
		TunIngressProof:        available,
		ByeDPIStatus:           doctorByeDPIStatusAvailable(),
	}
}

func (runtime coreDoctorRuntime) runPlatformProbe(ctx context.Context, examID string, sink doctorExamSink) {
	host, port, err := doctorProbeDestination(currentTestURL())
	if err != nil {
		sink.Emit(doctorPlatformProbeEvidence(doctorPlatformProbeResult{Outcome: doctorPlatformProbeUnsupported, ErrorCode: "invalidProbeTarget"}))
		return
	}
	addresses, err := runtime.resolveProbeAddresses(ctx, host)
	addresses = doctorProbeAddresses(addresses)
	if err != nil || len(addresses) == 0 {
		sink.Emit(doctorPlatformProbeEvidence(doctorPlatformProbeResult{Outcome: doctorPlatformProbeIOError, ErrorCode: "probeAddressResolutionFailed"}))
		return
	}

	var finalResult doctorPlatformProbeResult
	completed := false
	for _, address := range addresses {
		result, matched, advance := runtime.runPlatformProbeAddress(ctx, examID, address, port, sink)
		if matched {
			return
		}
		finalResult = result
		if result.Outcome == doctorPlatformProbeCompleted {
			completed = true
		}
		if !advance {
			break
		}
	}
	if completed {
		finalResult.Outcome = doctorPlatformProbeCompleted
		finalResult.ErrorCode = "appIngressNotObserved"
	}
	sink.Emit(doctorPlatformProbeEvidence(finalResult))
}

func (runtime coreDoctorRuntime) runPlatformProbeAddress(ctx context.Context, examID string, address netip.Addr, port uint16, sink doctorExamSink) (doctorPlatformProbeResult, bool, bool) {
	for attempt := 0; attempt < doctorProbeBindAttempts; attempt++ {
		if err := ctx.Err(); err != nil {
			return doctorPlatformProbeResult{Outcome: doctorPlatformProbeCancelled, ErrorCode: doctorProbeErrorCode(err, "probeCancelled")}, false, false
		}
		sourcePort, portErr := runtime.probePort()
		if portErr != nil {
			return doctorPlatformProbeResult{Outcome: doctorPlatformProbeIOError, ErrorCode: "sourcePortUnavailable"}, false, false
		}
		request := doctorPlatformProbeRequest{
			SchemaVersion: doctorProbeSchemaVersion, ExamID: examID, ProbeID: newDoctorExamID(), Protocol: "tcp",
			DestinationIP: address.String(), DestinationPort: port, SourcePort: sourcePort,
			ConnectTimeoutMillis: doctorProbeConnectTimeout.Milliseconds(), ReadTimeoutMillis: doctorProbeReadTimeout.Milliseconds(), ByteBudget: doctorProbeByteBudget,
		}
		matched := make(chan struct{}, 1)
		deadline := runtime.currentTime().Add(doctorProbeConnectTimeout + doctorProbeReadTimeout + doctorProbeIdentityWait)
		if err := sink.Register(doctorProbeExpectation{ProbeID: request.ProbeID, Protocol: request.Protocol, SourcePort: request.SourcePort, Destination: netip.AddrPortFrom(address, port), UID: runtime.applicationUID(), Deadline: deadline, Matched: matched}); err != nil {
			return doctorPlatformProbeResult{ProbeID: request.ProbeID, Outcome: doctorPlatformProbeCancelled, ErrorCode: doctorProbeErrorCode(err, "probeRegistrationFailed")}, false, false
		}
		result, runErr := runtime.platformProbeRunner()(ctx, request)
		if runErr != nil {
			result = doctorPlatformProbeResult{ProbeID: request.ProbeID, Outcome: doctorPlatformProbeIOError, ErrorCode: doctorProbeErrorCode(runErr, "platformProbeFailed")}
		}
		if !result.validFor(request) {
			result = doctorPlatformProbeResult{ProbeID: request.ProbeID, Outcome: doctorPlatformProbeIOError, ErrorCode: "invalidPlatformProbeResult"}
		}
		if result.Outcome == doctorPlatformProbeBindCollision {
			if err := sink.Complete(request.ProbeID); err != nil {
				return result, false, false
			}
			if attempt+1 < doctorProbeBindAttempts {
				continue
			}
			if result.ErrorCode == "" {
				result.ErrorCode = "sourcePortInUse"
			}
			return result, false, false
		}
		matchedIngress := false
		if result.Outcome == doctorPlatformProbeCompleted || result.Outcome == doctorPlatformProbeTimeout || result.Outcome == doctorPlatformProbeIOError {
			wait := time.NewTimer(doctorProbeIdentityWait)
			select {
			case <-matched:
				matchedIngress = true
			case <-ctx.Done():
				result.Outcome = doctorPlatformProbeCancelled
				result.ErrorCode = doctorProbeErrorCode(ctx.Err(), "probeCancelled")
			case <-wait.C:
				if result.Outcome == doctorPlatformProbeCompleted {
					result.ErrorCode = "appIngressNotObserved"
				}
			}
			if !wait.Stop() {
				select {
				case <-wait.C:
				default:
				}
			}
		}
		if err := sink.Complete(request.ProbeID); err != nil {
			return result, matchedIngress, false
		}
		if matchedIngress {
			return result, true, false
		}
		advance := ctx.Err() == nil && (result.Outcome == doctorPlatformProbeCompleted || result.Outcome == doctorPlatformProbeTimeout || result.Outcome == doctorPlatformProbeIOError)
		return result, false, advance
	}
	return doctorPlatformProbeResult{Outcome: doctorPlatformProbeBindCollision, ErrorCode: "sourcePortInUse"}, false, false
}

func (runtime coreDoctorRuntime) resolveProbeAddresses(ctx context.Context, host string) ([]netip.Addr, error) {
	if address, err := netip.ParseAddr(host); err == nil {
		return []netip.Addr{address}, nil
	}
	if runtime.resolveProbe != nil {
		return runtime.resolveProbe(ctx, host)
	}
	return resolver.LookupIP(ctx, host)
}

func (runtime coreDoctorRuntime) applicationUID() uint32 {
	if runtime.appUID != nil {
		return runtime.appUID()
	}
	return uint32(os.Getuid())
}
func (runtime coreDoctorRuntime) probePort() (uint16, error) {
	if runtime.port != nil {
		return runtime.port()
	}
	return randomDoctorProbePort()
}
func (runtime coreDoctorRuntime) currentTime() time.Time {
	if runtime.now != nil {
		return runtime.now()
	}
	return time.Now()
}

func doctorPlatformProbeEvidence(result doctorPlatformProbeResult) doctorEvidence {
	fact := doctorEvidence{Kind: doctorEvidenceProbe, Layer: doctorLayerIngress, Outcome: doctorOutcomeSeen, Confidence: doctorInsufficient, Code: result.ErrorCode, DurationBucketMs: result.DurationBucketMs, at: time.Now()}
	if result.Outcome == doctorPlatformProbeUnsupported {
		fact.Outcome = doctorOutcomeNotApplicable
	}
	if fact.Code == "" {
		fact.Code = "platformProbe" + string(result.Outcome)
	}
	return fact
}

func (runtime coreDoctorRuntime) runApplicationProbe(ctx context.Context, emit func(doctorEvidence)) {
	probeCtx, cancel := context.WithTimeout(ctx, doctorProbeTimeout)
	defer cancel()
	started := time.Now()
	err := runtime.probeApplication(probeCtx, currentTestURL())
	if err != nil {
		for _, fact := range runtime.applicationFailureContext() {
			emit(fact)
		}
	}
	fact := doctorEvidence{Kind: doctorEvidenceProbe, Layer: doctorLayerMarker, Outcome: doctorOutcomeSucceeded, Confidence: doctorConfirmed, Code: "applicationProbeSucceeded", DurationBucketMs: doctorDurationBucket(time.Since(started)), at: time.Now()}
	if err != nil {
		fact.Outcome = doctorOutcomeFailed
		fact.Confidence = doctorProbable
		fact.Code = doctorProbeErrorCode(err, "applicationProbeFailed")
	}
	emit(fact)
}

func (runtime coreDoctorRuntime) applicationFailureContext() []doctorEvidence {
	facts, known := runtime.networkSnapshot()
	if !known {
		return nil
	}
	now := time.Now()
	switch {
	case facts.Transport == "":
		return []doctorEvidence{{Kind: doctorEvidenceProbe, Layer: doctorLayerCapture, Outcome: doctorOutcomeFailed, Confidence: doctorConfirmed, Code: "noPhysicalNetwork", at: now}}
	case facts.CaptivePortal:
		return []doctorEvidence{{Kind: doctorEvidenceProbe, Layer: doctorLayerCapture, Outcome: doctorOutcomeFailed, Confidence: doctorProbable, Code: "captivePortal", at: now}}
	case !facts.Validated:
		return []doctorEvidence{{Kind: doctorEvidenceProbe, Layer: doctorLayerCapture, Outcome: doctorOutcomeFailed, Confidence: doctorProbable, Code: "networkUnvalidated", at: now}}
	default:
		return nil
	}
}

func (runtime coreDoctorRuntime) probeApplication(ctx context.Context, target string) error {
	if runtime.probe != nil {
		return runtime.probe(ctx, target)
	}
	if runtime.probeStatus != nil {
		satisfied, err := runtime.probeStatus(ctx, target)
		if err != nil || satisfied {
			return err
		}
		return errDoctorStatusMismatch
	}
	proxy := lookupProxy(globalProxyName)
	if proxy == nil {
		return errDoctorNoActiveProxy
	}
	statuses := doctorExpectedStatuses(target)
	if statuses == nil {
		_, err := proxy.URLTest(ctx, target, anyDelayTestStatus)
		return err
	}
	_, err := proxy.URLTest(ctx, target, statuses)
	if err != nil {
		return err
	}
	if proxy.AliveForTestUrl(target) {
		return nil
	}
	return errDoctorStatusMismatch
}

func doctorExpectedStatuses(target string) utils.IntRanges[uint16] {
	parsed, err := url.Parse(target)
	if err != nil || !strings.HasSuffix(parsed.Path, "/generate_204") {
		return nil
	}
	return utils.IntRanges[uint16]{utils.NewRange[uint16](204, 204)}
}

func doctorProbeErrorCode(err error, fallback string) string {
	switch {
	case err == nil:
		return ""
	case errors.Is(err, context.Canceled):
		return "probeCancelled"
	case errors.Is(err, context.DeadlineExceeded):
		return "probeTimeout"
	case errors.Is(err, errDoctorNoActiveProxy):
		return "noActiveProxy"
	case errors.Is(err, errDoctorStatusMismatch):
		return "probeStatusMismatch"
	default:
		return fallback
	}
}

func doctorProbeCount(mode doctorExamMode, capabilities doctorCapabilities) int {
	count := 2
	if mode == doctorDeep {
		count++
	}
	if capabilities.AndroidAppIngressProbe {
		count++
	}
	return count
}

func (runtime coreDoctorRuntime) FlushDNS() {
	if runtime.flush != nil {
		runtime.flush()
		return
	}
	if resolver.DefaultResolver != nil {
		resolver.DefaultResolver.ClearCache()
		resolver.DefaultResolver.ResetConnection()
	}
	resolver.SystemResolver.ClearCache()
	resolver.SystemResolver.ResetConnection()
	_ = resolver.FlushFakeIP()
}
