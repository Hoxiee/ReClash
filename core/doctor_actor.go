package main

import (
	"context"
	"crypto/rand"
	"encoding/hex"
	"errors"
	"slices"
	"strings"
	"sync/atomic"
	"time"
)

type doctorGenerationKind int

const (
	doctorEnvironmentGeneration doctorGenerationKind = iota
	doctorConfigGeneration
	doctorRoutingGeneration
	doctorTunGeneration
)

type doctorCommandKind int

const (
	doctorStartCommand doctorCommandKind = iota
	doctorCancelCommand
	doctorHealCommand
	doctorGenerationCommand
	doctorExamEvidenceCommand
	doctorFinishCommand
	doctorOverflowCommand
	doctorRegisterExpectationCommand
	doctorCompleteExpectationCommand
	doctorPlatformStatusCommand
	doctorPassiveFlushCommand
	doctorFreshnessExpiredCommand
	doctorDeadlineCommand
	doctorPathStatusCommand
	doctorMatchedProbeCommand
	doctorResetCommand
	doctorHealCompleteCommand
)

type doctorGenerationChange struct {
	Environment bool
	Config      bool
	Routing     bool
	Tun         bool
}

type doctorCommand struct {
	kind        doctorCommandKind
	start       doctorStartParams
	cancel      doctorCancelParams
	heal        doctorHealParams
	generation  doctorGenerationKind
	generations doctorGenerationChange
	examID      string
	probeID     string
	evidence    doctorEvidence
	expectation doctorProbeExpectation
	platform    doctorPlatformStatus
	pathStatus  doctorPathStatus
	matchedFact doctorEvidence
	healToken   uint64
	token       uint64
	response    chan doctorResult
}

type doctorResult struct {
	snapshot doctorSnapshot
	err      error
}

type doctorRuntime interface {
	RunExam(context.Context, string, doctorExamMode, doctorExamSink)
	FlushDNS()
}

type doctorPathContextProvider interface {
	DoctorPathContext() doctorPathContext
}

type doctorActor struct {
	commands      chan doctorCommand
	passive       chan doctorEvidence
	dropped       atomic.Uint64
	view          atomic.Pointer[doctorSnapshot]
	runtime       doctorRuntime
	now           func() time.Time
	publish       func(doctorStatusProjection)
	expectations  *doctorExpectationRegistry
	identity      func(doctorProbeObservation) (doctorProbeObservation, bool)
	tunGeneration atomic.Uint64
	ingressGate   doctorIngressGate

	snapshot               doctorSnapshot
	cancel                 context.CancelFunc
	passiveDirty           bool
	passiveFlushScheduled  bool
	freshnessTimer         *time.Timer
	freshnessToken         uint64
	deadlineTimer          *time.Timer
	lastPathGeneration     uint64
	lastPlatformGeneration uint64
	requireAppIngressProof bool
	healToken              uint64
	healInProgress         bool
	healExamID             string
	pendingPlatform        *doctorEvidence
}

func newDoctorActor(runtime doctorRuntime, publish func(doctorStatusProjection)) *doctorActor {
	actor := &doctorActor{
		commands:     make(chan doctorCommand, 64),
		passive:      make(chan doctorEvidence, doctorEvidenceQueue),
		runtime:      runtime,
		now:          time.Now,
		publish:      publish,
		expectations: newDoctorExpectationRegistry(),
		identity:     resolveDoctorProbeIdentity,
	}
	capabilities := doctorCapabilities{
		PassiveWitness: true,
		ExplicitExam:   true,
		Cancel:         true,
		DNSFlush:       true,
		RedactedExport: true,
	}
	if provider, ok := runtime.(interface{ DoctorCapabilities() doctorCapabilities }); ok {
		platform := provider.DoctorCapabilities()
		capabilities.AndroidAppIngressProbe = platform.AndroidAppIngressProbe
		capabilities.TunIngressProof = platform.TunIngressProof
		capabilities.ByeDPIStatus = platform.ByeDPIStatus
	}
	now := actor.now().UnixMilli()
	actor.snapshot = doctorSnapshot{
		SchemaVersion: doctorSchemaVersion,
		Revision:      1,
		Supported:     true,
		Capabilities:  capabilities,
		State:         doctorObserving,
		Health:        doctorUnknown,
		Confidence:    doctorInsufficient,
		Scope:         doctorScopeUnknown,
		UpdatedAt:     now,
		Evidence:      []doctorEvidence{},
		Actions:       []doctorAction{},
		HealAudit:     []doctorHealAudit{},
		Incidents:     []doctorIncident{},
		Stages:        doctorStages(nil, doctorPathContext{PathKind: doctorPathUnknown, CaptureState: doctorCaptureUnknown}, false),
	}
	actor.applyRuntimePathContext()
	actor.refreshActions()
	actor.storeView()
	safeGoDetached("connection doctor actor", actor.loop)
	return actor
}

func (actor *doctorActor) loop() {
	for {
		select {
		case command := <-actor.commands:
			actor.handle(command)
		case evidence := <-actor.passive:
			actor.handlePassive(evidence)
		}
	}
}

func (actor *doctorActor) handle(command doctorCommand) {
	var result doctorResult
	switch command.kind {
	case doctorStartCommand:
		result.snapshot = actor.start(command.start)
	case doctorCancelCommand:
		result.snapshot, result.err = actor.cancelExam(command.cancel.ExamID)
	case doctorHealCommand:
		result.snapshot, result.err = actor.heal(command.heal)
	case doctorGenerationCommand:
		if command.generations == (doctorGenerationChange{}) {
			actor.bumpGeneration(command.generation)
		} else {
			actor.bumpGenerations(command.generations)
		}
		result.snapshot = actor.copySnapshot()
	case doctorExamEvidenceCommand:
		if command.examID == actor.snapshot.ExamID && actor.snapshot.State == doctorExamining {
			actor.appendEvidence(command.evidence)
			actor.updateExamVerdict()
			actor.changed()
		}
	case doctorFinishCommand:
		actor.finishExam(command.examID)
	case doctorDeadlineCommand:
		actor.finishExam(command.examID)
	case doctorOverflowCommand:
		actor.passiveDirty = true
		actor.schedulePassiveFlush()
	case doctorRegisterExpectationCommand:
		if command.examID != actor.snapshot.ExamID || actor.snapshot.State != doctorExamining {
			result.err = errDoctorExpectationInactive
		} else {
			command.expectation.ExamID = command.examID
			command.expectation.TunGeneration = actor.snapshot.Generations.Tun
			result.err = actor.expectations.register(command.expectation, actor.now())
		}
	case doctorCompleteExpectationCommand:
		if command.examID != actor.snapshot.ExamID || actor.snapshot.State != doctorExamining {
			result.err = errDoctorExpectationInactive
		} else {
			actor.expectations.complete(command.examID, command.probeID)
		}
	case doctorPlatformStatusCommand:
		result.err = actor.handlePlatformStatus(command.platform)
		result.snapshot = actor.copySnapshot()
	case doctorPassiveFlushCommand:
		actor.passiveFlushScheduled = false
		actor.flushPassive()
	case doctorFreshnessExpiredCommand:
		actor.expireFreshness(command.token)
	case doctorPathStatusCommand:
		actor.applyPathStatus(command.pathStatus)
		result.snapshot = actor.copySnapshot()
	case doctorMatchedProbeCommand:
		actor.acceptMatchedProbeCommand(command.expectation, command.matchedFact)
	case doctorResetCommand:
		actor.reset()
		result.snapshot = actor.copySnapshot()
	case doctorHealCompleteCommand:
		actor.completeHeal(command.healToken, doctorExamMode(command.heal.ActionID), command.token != 0)
		result.snapshot = actor.copySnapshot()
	}
	if command.response != nil {
		command.response <- result
	}
}

func (actor *doctorActor) start(params doctorStartParams) doctorSnapshot {
	actor.flushPassive()
	mode := params.Mode
	if mode != "deep" {
		mode = "standard"
	}
	if actor.snapshot.State == doctorExamining && actor.snapshot.Mode == mode {
		return actor.copySnapshot()
	}
	if actor.snapshot.State == doctorExamining {
		actor.terminate(doctorSuperseded, "examSuperseded")
	}
	now := actor.now()
	actor.applyRuntimePathContext()
	actor.snapshot.ExamID = newDoctorExamID()
	actor.snapshot.Mode = mode
	actor.snapshot.State = doctorExamining
	actor.snapshot.Health = doctorUnknown
	actor.snapshot.Confidence = doctorInsufficient
	actor.snapshot.CauseCode = ""
	actor.snapshot.Layer = ""
	actor.snapshot.Scope = doctorScopeApp
	actor.snapshot.Stages = doctorStages(nil, actor.pathContext(), false)
	actor.snapshot.StartGenerations = actor.snapshot.Generations
	actor.snapshot.StartedAt = now.UnixMilli()
	actor.requireAppIngressProof = actor.appIngressProofAvailable()
	examCapabilities := actor.snapshot.Capabilities
	examCapabilities.AndroidAppIngressProbe = actor.requireAppIngressProof
	actor.snapshot.Progress = doctorProgress{
		Phase: "probing",
		Total: doctorProbeCount(mode, examCapabilities),
	}
	actor.snapshot.Severity = doctorSeverityInfo
	actor.stopFreshnessTimer()
	actor.snapshot.FreshUntil = 0
	actor.snapshot.EvidenceDropped = 0
	actor.snapshot.Evidence = []doctorEvidence{}
	ctx, cancel := context.WithTimeout(context.Background(), doctorExamTimeout)
	actor.cancel = cancel
	examID := actor.snapshot.ExamID
	actor.scheduleExamDeadline(examID)
	actor.changed()
	safeGoDetached("connection doctor exam", func() {
		actor.runExam(ctx, examID, mode)
	})
	return actor.copySnapshot()
}

func (actor *doctorActor) runExam(ctx context.Context, examID string, mode doctorExamMode) {
	defer actor.sendCommand(context.Background(), doctorCommand{kind: doctorFinishCommand, examID: examID})
	actor.runtime.RunExam(ctx, examID, mode, doctorExamSink{
		Emit: func(evidence doctorEvidence) {
			actor.sendCommand(ctx, doctorCommand{
				kind:     doctorExamEvidenceCommand,
				examID:   examID,
				evidence: evidence,
			})
		},
		Register: func(expectation doctorProbeExpectation) error {
			return actor.registerExpectation(ctx, examID, expectation)
		},
		Complete: func(probeID string) error {
			return actor.completeExpectation(ctx, examID, probeID)
		},
	})
}

func (actor *doctorActor) sendCommand(ctx context.Context, command doctorCommand) {
	select {
	case actor.commands <- command:
	case <-ctx.Done():
	}
}

func (actor *doctorActor) finishExam(examID string) {
	if examID != actor.snapshot.ExamID || actor.snapshot.State != doctorExamining {
		return
	}
	actor.applyVerdict(true)
	actor.finishIncident()
	actor.expectations.clearExam(examID)
	actor.stopExamDeadline()
	if actor.cancel != nil {
		actor.cancel()
		actor.cancel = nil
	}
	actor.changed()
	actor.applyPendingPlatformStatus()
}

func (actor *doctorActor) scheduleExamDeadline(examID string) {
	actor.stopExamDeadline()
	actor.deadlineTimer = time.AfterFunc(doctorExamTimeout, func() {
		actor.sendCommand(context.Background(), doctorCommand{kind: doctorDeadlineCommand, examID: examID})
	})
}

func (actor *doctorActor) stopExamDeadline() {
	if actor.deadlineTimer != nil {
		actor.deadlineTimer.Stop()
		actor.deadlineTimer = nil
	}
}

func (actor *doctorActor) cancelExam(examID string) (doctorSnapshot, error) {
	if actor.snapshot.State != doctorExamining || actor.snapshot.ExamID != examID {
		return actor.copySnapshot(), errors.New("exam_not_active")
	}
	actor.terminate(doctorCancelled, "examCancelled")
	return actor.copySnapshot(), nil
}

func (actor *doctorActor) terminate(state doctorExamState, cause string) {
	actor.flushPassive()
	actor.stopExamDeadline()
	actor.expectations.clearExam(actor.snapshot.ExamID)
	if actor.cancel != nil {
		actor.cancel()
		actor.cancel = nil
	}
	actor.snapshot.State = state
	actor.snapshot.Health = doctorUnknown
	actor.snapshot.Confidence = doctorInsufficient
	actor.snapshot.CauseCode = cause
	actor.snapshot.Layer = ""
	actor.snapshot.Severity = doctorSeverityInfo
	actor.snapshot.Progress.Phase = string(state)
	actor.finishIncident()
	actor.changed()
	actor.applyPendingPlatformStatus()
}

func (actor *doctorActor) reset() {
	actor.passiveDirty = false
	for {
		select {
		case <-actor.passive:
			continue
		default:
			actor.finishReset()
			return
		}
	}
}

func (actor *doctorActor) finishReset() {
	actor.stopExamDeadline()
	actor.expectations.clearExam(actor.snapshot.ExamID)
	if actor.cancel != nil {
		actor.cancel()
		actor.cancel = nil
	}
	actor.resetObservation()
	actor.snapshot.Generations = doctorGenerations{}
	actor.snapshot.PathKind = doctorPathUnknown
	actor.snapshot.CaptureState = doctorCaptureUnknown
	actor.snapshot.HealAudit = []doctorHealAudit{}
	actor.snapshot.Incidents = []doctorIncident{}
	actor.snapshot.Stages = doctorStages(nil, actor.pathContext(), false)
	actor.lastPathGeneration = 0
	actor.lastPlatformGeneration = 0
	actor.requireAppIngressProof = false
	actor.healToken++
	actor.healInProgress = false
	actor.healExamID = ""
	actor.pendingPlatform = nil
	actor.dropped.Store(0)
	actor.tunGeneration.Store(0)
	doctorAndroidPathStatus.Store(doctorPathStatus{PathKind: doctorPathUnknown})
	actor.changed()
}

func (actor *doctorActor) bumpGenerations(change doctorGenerationChange) {
	actor.flushPassive()
	if change.Environment {
		actor.snapshot.Generations.Environment++
	}
	if change.Config {
		actor.snapshot.Generations.Config++
	}
	if change.Routing {
		actor.snapshot.Generations.Routing++
	}
	if change.Tun {
		actor.snapshot.Generations.Tun++
		actor.tunGeneration.Store(actor.snapshot.Generations.Tun)
	}
	if actor.snapshot.State == doctorExamining {
		actor.ingressGate.reset()
		actor.terminate(doctorSuperseded, "generationChanged")
		return
	}
	if change.Tun {
		actor.applyRuntimePathContext()
	}
	actor.resetObservation()
	actor.changed()
}

func (actor *doctorActor) bumpGeneration(kind doctorGenerationKind) {
	actor.flushPassive()
	switch kind {
	case doctorEnvironmentGeneration:
		actor.snapshot.Generations.Environment++
	case doctorConfigGeneration:
		actor.snapshot.Generations.Config++
	case doctorRoutingGeneration:
		actor.snapshot.Generations.Routing++
	case doctorTunGeneration:
		actor.snapshot.Generations.Tun++
		actor.tunGeneration.Store(actor.snapshot.Generations.Tun)
	}
	if actor.snapshot.State == doctorExamining {
		actor.ingressGate.reset()
		actor.terminate(doctorSuperseded, "generationChanged")
		return
	}
	if kind == doctorTunGeneration {
		actor.applyRuntimePathContext()
	}
	actor.resetObservation()
	actor.changed()
}

func (actor *doctorActor) handlePassive(evidence doctorEvidence) {
	if actor.snapshot.State == doctorExamining {
		return
	}
	listenerFailed := evidence.Code == "byeDpiListenerFailed" && evidence.Inbound == "byedpi"
	freshExam := actor.snapshot.ExamID != "" &&
		(actor.snapshot.State == doctorComplete || actor.snapshot.State == doctorInconclusive) &&
		actor.snapshot.FreshUntil > actor.now().UnixMilli()
	if freshExam && !listenerFailed {
		return
	}
	if actor.snapshot.State != doctorObserving {
		actor.resetObservation()
	}
	actor.snapshot.Scope = doctorScopeForEvidence(evidence)
	actor.appendEvidence(evidence)
	if doctorPassiveHealthEvidence(evidence, actor.pathContext()) {
		actor.snapshot.Health = doctorHealthy
		actor.snapshot.Confidence = doctorConfirmed
		actor.snapshot.CauseCode = ""
		actor.snapshot.Layer = ""
		actor.snapshot.FreshUntil = actor.now().Add(doctorEvidenceFreshFor).UnixMilli()
		actor.scheduleFreshnessExpiry()
	}
	if listenerFailed {
		actor.snapshot.Health = doctorBroken
		actor.snapshot.Confidence = doctorConfirmed
		actor.snapshot.CauseCode = evidence.Code
		actor.snapshot.Layer = evidence.Layer
		actor.snapshot.FreshUntil = actor.now().Add(doctorEvidenceFreshFor).UnixMilli()
		actor.scheduleFreshnessExpiry()
	}
	actor.snapshot.Severity = doctorSeverityFor(actor.snapshot.Health)
	actor.passiveDirty = true
	actor.schedulePassiveFlush()
}

func doctorPassiveHealthEvidence(evidence doctorEvidence, path doctorPathContext) bool {
	return (path.PathKind == doctorPathLocalProxy || path.PathKind == doctorPathDirect || path.PathKind == doctorPathByeDPI) &&
		evidence.Outcome == doctorOutcomeSucceeded && evidence.Confidence == doctorConfirmed && evidence.Layer == doctorLayerMarker
}

func (actor *doctorActor) resetObservation() {
	actor.ingressGate.reset()
	actor.snapshot.ExamID = ""
	actor.snapshot.Mode = ""
	actor.snapshot.State = doctorObserving
	actor.snapshot.Health = doctorUnknown
	actor.snapshot.Confidence = doctorInsufficient
	actor.snapshot.CauseCode = ""
	actor.snapshot.Layer = ""
	actor.snapshot.Scope = doctorScopeUnknown
	actor.snapshot.StartGenerations = doctorGenerations{}
	actor.snapshot.StartedAt = 0
	actor.snapshot.Progress = doctorProgress{}
	actor.snapshot.Severity = doctorSeverityInfo
	actor.snapshot.FreshUntil = 0
	actor.snapshot.EvidenceDropped = 0
	actor.snapshot.Evidence = []doctorEvidence{}
	actor.snapshot.Stages = doctorStages(nil, actor.pathContext(), false)
	actor.requireAppIngressProof = false
	actor.stopFreshnessTimer()
}

func (actor *doctorActor) stopFreshnessTimer() {
	actor.freshnessToken++
	if actor.freshnessTimer != nil {
		actor.freshnessTimer.Stop()
	}
}

func (actor *doctorActor) schedulePassiveFlush() {
	if actor.passiveFlushScheduled {
		return
	}
	actor.passiveFlushScheduled = true
	time.AfterFunc(doctorPassivePublishPeriod, func() {
		actor.sendCommand(context.Background(), doctorCommand{kind: doctorPassiveFlushCommand})
	})
}

func (actor *doctorActor) flushPassive() {
	if !actor.passiveDirty {
		return
	}
	actor.passiveDirty = false
	actor.changed()
}

func (actor *doctorActor) scheduleFreshnessExpiry() {
	actor.freshnessToken++
	token := actor.freshnessToken
	deadline := time.UnixMilli(actor.snapshot.FreshUntil)
	delay := deadline.Sub(actor.now())
	if delay < 0 {
		delay = 0
	}
	if actor.freshnessTimer == nil {
		actor.freshnessTimer = time.AfterFunc(delay, func() {
			actor.sendCommand(context.Background(), doctorCommand{kind: doctorFreshnessExpiredCommand, token: token})
		})
		return
	}
	actor.freshnessTimer.Stop()
	actor.freshnessTimer = time.AfterFunc(delay, func() {
		actor.sendCommand(context.Background(), doctorCommand{kind: doctorFreshnessExpiredCommand, token: token})
	})
}

func (actor *doctorActor) expireFreshness(token uint64) {
	if (token != 0 && token != actor.freshnessToken) || !actor.freshnessExpired() {
		return
	}
	actor.snapshot.Health = doctorUnknown
	actor.snapshot.Confidence = doctorInsufficient
	actor.snapshot.Severity = doctorSeverityInfo
	actor.snapshot.CauseCode = "staleEvidence"
	actor.snapshot.Layer = ""
	actor.snapshot.FreshUntil = 0
	actor.changed()
}

func (actor *doctorActor) applyPendingPlatformStatus() {
	if actor.pendingPlatform == nil {
		return
	}
	evidence := *actor.pendingPlatform
	actor.pendingPlatform = nil
	actor.handlePassive(evidence)
}

func (actor *doctorActor) appendEvidence(evidence doctorEvidence) {
	if actor.snapshot.StartedAt != 0 && evidence.at.IsZero() == false {
		evidence.OffsetMillis = evidence.at.UnixMilli() - actor.snapshot.StartedAt
	}
	actor.snapshot.Evidence = appendBounded(actor.snapshot.Evidence, evidence, doctorMaxFacts)
}

func (actor *doctorActor) updateExamVerdict() {
	verdict := reduceDoctorEvidence(actor.snapshot.Evidence, false, actor.pathContext(), actor.requiresAppIngressProof())
	actor.snapshot.Health = verdict.Health
	actor.snapshot.Confidence = verdict.Confidence
	actor.snapshot.CauseCode = verdict.CauseCode
	actor.snapshot.Layer = verdict.Layer
	actor.snapshot.Severity = doctorSeverityFor(verdict.Health)
	actor.snapshot.Progress.Completed = doctorCompletedProbeCount(actor.snapshot.Evidence, actor.requireAppIngressProof)
	if verdict.Layer != "" {
		markDoctorConsequences(actor.snapshot.Evidence, verdict.Layer)
	}
	actor.snapshot.Stages = doctorStages(actor.snapshot.Evidence, actor.pathContext(), false)
}

func doctorCompletedProbeCount(evidence []doctorEvidence, requireAppIngressProof bool) int {
	completed := 0
	if slices.ContainsFunc(evidence, func(fact doctorEvidence) bool {
		return fact.Code == "coreResolverSucceeded" || strings.HasPrefix(fact.Code, "coreResolver")
	}) {
		completed++
	}
	if slices.ContainsFunc(evidence, func(fact doctorEvidence) bool {
		return fact.Code == "systemResolverSucceeded" || strings.HasPrefix(fact.Code, "systemResolver")
	}) {
		completed++
	}
	if requireAppIngressProof && slices.ContainsFunc(evidence, func(fact doctorEvidence) bool {
		return (fact.Layer == doctorLayerIngress && fact.Kind == doctorEvidenceProbe) || fact.Code == "appIngressMatched"
	}) {
		completed++
	}
	if slices.ContainsFunc(evidence, func(fact doctorEvidence) bool {
		return fact.Layer == doctorLayerMarker && strings.HasPrefix(fact.Code, "applicationProbe")
	}) {
		completed++
	}
	return completed
}

func (actor *doctorActor) appIngressProofAvailable() bool {
	if !actor.snapshot.Capabilities.TunIngressProof {
		return false
	}
	provider, ok := actor.runtime.(interface{ DoctorAppIngressAvailable() bool })
	return ok && provider.DoctorAppIngressAvailable()
}

func (actor *doctorActor) requiresAppIngressProof() bool {
	return actor.requireAppIngressProof
}

func (actor *doctorActor) applyVerdict(terminal bool) {
	verdict := reduceDoctorEvidence(actor.snapshot.Evidence, terminal, actor.pathContext(), actor.requiresAppIngressProof())
	actor.snapshot.State = verdict.State
	actor.snapshot.Health = verdict.Health
	actor.snapshot.Confidence = verdict.Confidence
	actor.snapshot.CauseCode = verdict.CauseCode
	actor.snapshot.Layer = verdict.Layer
	actor.snapshot.Severity = doctorSeverityFor(verdict.Health)
	if verdict.Layer != "" {
		markDoctorConsequences(actor.snapshot.Evidence, verdict.Layer)
	}
	actor.snapshot.Stages = doctorStages(actor.snapshot.Evidence, actor.pathContext(), terminal)
	if terminal {
		actor.snapshot.Progress.Phase = "complete"
		actor.snapshot.Progress.Completed = actor.snapshot.Progress.Total
		actor.snapshot.FreshUntil = actor.now().Add(doctorEvidenceFreshFor).UnixMilli()
		actor.scheduleFreshnessExpiry()
	}
}

func (actor *doctorActor) finishIncident() {
	if actor.snapshot.ExamID == "" || actor.snapshot.StartedAt == 0 {
		return
	}
	for _, incident := range actor.snapshot.Incidents {
		if incident.ExamID == actor.snapshot.ExamID {
			return
		}
	}
	if actor.snapshot.State == doctorComplete {
		odometerInstance.NoteExam(actor.snapshot.Health != doctorBroken)
	}
	actor.snapshot.Incidents = appendBounded(actor.snapshot.Incidents, doctorIncident{
		ExamID:     actor.snapshot.ExamID,
		Mode:       actor.snapshot.Mode,
		State:      actor.snapshot.State,
		Health:     actor.snapshot.Health,
		Confidence: actor.snapshot.Confidence,
		CauseCode:  actor.snapshot.CauseCode,
		Layer:      actor.snapshot.Layer,
		StartedAt:  actor.snapshot.StartedAt,
		FinishedAt: actor.now().UnixMilli(),
	}, doctorMaxIncidents)
}

func (actor *doctorActor) changed() {
	actor.snapshot.Revision++
	actor.snapshot.UpdatedAt = actor.now().UnixMilli()
	actor.snapshot.EvidenceDropped += actor.dropped.Swap(0)
	actor.refreshActions()
	actor.storeView()
	if actor.publish != nil {
		actor.publish(doctorStatusProjection{
			Revision:   actor.snapshot.Revision,
			State:      actor.snapshot.State,
			Health:     actor.snapshot.Health,
			Confidence: actor.snapshot.Confidence,
			CauseCode:  actor.snapshot.CauseCode,
		})
	}
}

func (actor *doctorActor) refreshActions() {
	actor.snapshot.Actions = doctorActionsFor(actor.snapshot)
}

func doctorActionsFor(snapshot doctorSnapshot) []doctorAction {
	flushEligible := snapshot.State != doctorExamining && doctorDNSFlushEligible(snapshot.CauseCode)
	return []doctorAction{
		{ID: "startStandard", Eligible: snapshot.State != doctorExamining, EligibilityReasonCode: eligibilityCode(snapshot.State != doctorExamining, "examActive")},
		{ID: "startDeep", Eligible: snapshot.State != doctorExamining, EligibilityReasonCode: eligibilityCode(snapshot.State != doctorExamining, "examActive")},
		{ID: "cancel", Eligible: snapshot.State == doctorExamining, EligibilityReasonCode: eligibilityCode(snapshot.State == doctorExamining, "noActiveExam")},
		{ID: "flushDns", Eligible: flushEligible, EligibilityReasonCode: eligibilityCode(flushEligible, "causeNotEligible")},
		{ID: "exportRedacted", Eligible: true},
	}
}

func eligibilityCode(eligible bool, code string) string {
	if eligible {
		return ""
	}
	return code
}

func (actor *doctorActor) storeView() {
	copy := actor.copySnapshot()
	actor.view.Store(&copy)
}

func (actor *doctorActor) copySnapshot() doctorSnapshot {
	copy := actor.snapshot
	copy.Evidence = append([]doctorEvidence(nil), actor.snapshot.Evidence...)
	copy.Actions = append([]doctorAction(nil), actor.snapshot.Actions...)
	copy.HealAudit = append([]doctorHealAudit(nil), actor.snapshot.HealAudit...)
	copy.Incidents = append([]doctorIncident(nil), actor.snapshot.Incidents...)
	copy.Stages = append([]doctorStage(nil), actor.snapshot.Stages...)
	return copy
}

func (actor *doctorActor) pathContext() doctorPathContext {
	return doctorPathContext{PathKind: actor.snapshot.PathKind, CaptureState: actor.snapshot.CaptureState}
}

func (actor *doctorActor) applyRuntimePathContext() {
	if provider, ok := actor.runtime.(doctorPathContextProvider); ok {
		actor.setPathContext(provider.DoctorPathContext())
	}
}

func (actor *doctorActor) setPathContext(path doctorPathContext) {
	if path.PathKind == "" {
		path.PathKind = doctorPathUnknown
	}
	if path.CaptureState == "" {
		path.CaptureState = doctorCaptureUnknown
	}
	actor.snapshot.PathKind = path.PathKind
	actor.snapshot.CaptureState = path.CaptureState
}

func (actor *doctorActor) applyPathStatus(status doctorPathStatus) {
	generationChanged := status.Generation != 0
	if generationChanged && status.Generation <= actor.lastPathGeneration {
		return
	}
	if generationChanged {
		actor.lastPathGeneration = status.Generation
		doctorAndroidPathStatus.Store(status)
	}
	before := actor.pathContext()
	actor.setPathContext(doctorPathContextForStatus(status, tunUp.Load()))
	if !generationChanged && before == actor.pathContext() {
		return
	}
	actor.bumpGeneration(doctorTunGeneration)
}

func (actor *doctorActor) acceptMatchedProbeCommand(expectation doctorProbeExpectation, fact doctorEvidence) {
	if expectation.ExamID != actor.snapshot.ExamID || actor.snapshot.State != doctorExamining {
		return
	}
	if actor.expectations.isConfirmed(expectation) {
		actor.appendEvidence(fact)
		actor.updateExamVerdict()
		actor.changed()
		return
	}
	if !actor.expectations.confirm(expectation) {
		return
	}
	ingress := fact
	ingress.Kind = doctorEvidenceIngress
	ingress.Layer = doctorLayerIngress
	ingress.Outcome = doctorOutcomeSucceeded
	ingress.Confidence = doctorConfirmed
	ingress.Code = "appIngressMatched"
	actor.appendEvidence(ingress)
	if fact.Layer != doctorLayerIngress {
		actor.appendEvidence(fact)
	}
	actor.updateExamVerdict()
	actor.changed()
	if expectation.Matched != nil {
		select {
		case expectation.Matched <- struct{}{}:
		default:
		}
	}
}

func (actor *doctorActor) freshnessExpired() bool {
	return actor.snapshot.State != doctorExamining && actor.snapshot.FreshUntil != 0 &&
		actor.now().UnixMilli() >= actor.snapshot.FreshUntil
}

func (actor *doctorActor) Snapshot() doctorSnapshot {
	stored := actor.view.Load()
	if stored == nil {
		return doctorSnapshot{}
	}
	copy := *stored
	copy.Evidence = append([]doctorEvidence(nil), stored.Evidence...)
	copy.Actions = append([]doctorAction(nil), stored.Actions...)
	copy.HealAudit = append([]doctorHealAudit(nil), stored.HealAudit...)
	copy.Incidents = append([]doctorIncident(nil), stored.Incidents...)
	copy.Stages = append([]doctorStage(nil), stored.Stages...)
	if copy.State != doctorExamining && copy.FreshUntil != 0 && actor.now().UnixMilli() >= copy.FreshUntil {
		copy.Health = doctorUnknown
		copy.Confidence = doctorInsufficient
		copy.Severity = doctorSeverityInfo
		copy.CauseCode = "staleEvidence"
		copy.Layer = ""
		copy.Actions = doctorActionsFor(copy)
	}
	return copy
}

func (actor *doctorActor) Passive(evidence doctorEvidence) {
	select {
	case actor.passive <- evidence:
	default:
		actor.dropped.Add(1)
		select {
		case actor.commands <- doctorCommand{kind: doctorOverflowCommand}:
		default:
		}
	}
}

func (actor *doctorActor) request(command doctorCommand) (doctorSnapshot, error) {
	ctx, cancel := context.WithTimeout(context.Background(), doctorExamTimeout)
	defer cancel()
	return actor.requestContext(ctx, command)
}

func (actor *doctorActor) requestContext(ctx context.Context, command doctorCommand) (doctorSnapshot, error) {
	response := make(chan doctorResult, 1)
	command.response = response
	select {
	case actor.commands <- command:
	case <-ctx.Done():
		return actor.Snapshot(), ctx.Err()
	}
	select {
	case result := <-response:
		return result.snapshot, result.err
	case <-ctx.Done():
		return actor.Snapshot(), ctx.Err()
	}
}

func newDoctorExamID() string {
	var value [12]byte
	if _, err := rand.Read(value[:]); err != nil {
		return hex.EncodeToString([]byte(time.Now().Format(time.RFC3339Nano)))
	}
	return hex.EncodeToString(value[:])
}
