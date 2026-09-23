package main

import "core/doctor"

// Bridge back to the extracted doctor package: lowercase names main still
// uses map onto the exported seam, and host couplings are injected once.

var buildDoctorReport = doctor.BuildReport

type doctorActor = doctor.Actor

const doctorBroken = doctor.Broken

type doctorCancelParams = doctor.CancelParams

const doctorCancelled = doctor.Cancelled

type doctorCapabilities = doctor.Capabilities

const doctorCaptureActive = doctor.CaptureActive
const doctorCaptureInactive = doctor.CaptureInactive
const doctorCaptureNotApplicable = doctor.CaptureNotApplicable
const doctorCaptureUnknown = doctor.CaptureUnknown

type doctorCommand = doctor.Command

const doctorComplete = doctor.Complete
const doctorConfigGeneration = doctor.ConfigGeneration
const doctorConfirmed = doctor.Confirmed
const doctorDeep = doctor.Deep
const doctorDegraded = doctor.Degraded

var doctorDurationBucket = doctor.DurationBucket

const doctorEnvironmentGeneration = doctor.EnvironmentGeneration

type doctorEvidence = doctor.Evidence

const doctorEvidenceProbe = doctor.EvidenceProbe

type doctorExamMode = doctor.ExamMode
type doctorExamSink = doctor.ExamSink
type doctorGenerationChange = doctor.GenerationChange

const doctorGenerationCommand = doctor.GenerationCommand

type doctorGenerationKind = doctor.GenerationKind
type doctorGenerations = doctor.Generations
type doctorHealAudit = doctor.HealAudit
type doctorHealParams = doctor.HealParams

const doctorHealthy = doctor.Healthy

type doctorIncident = doctor.Incident

const doctorInsufficient = doctor.Insufficient
const doctorLayerCapture = doctor.LayerCapture
const doctorLayerDNS = doctor.LayerDNS
const doctorLayerIngress = doctor.LayerIngress
const doctorLayerMarker = doctor.LayerMarker
const doctorMaxProbeCount = doctor.MaxProbeCount
const doctorObserving = doctor.Observing
const doctorOutcomeFailed = doctor.OutcomeFailed
const doctorOutcomeNotApplicable = doctor.OutcomeNotApplicable
const doctorOutcomeSeen = doctor.OutcomeSeen
const doctorOutcomeSucceeded = doctor.OutcomeSucceeded
const doctorPathByeDPI = doctor.PathByeDPI

type doctorPathContext = doctor.PathContext

var doctorPathContextForStatus = doctor.PathContextForStatus

const doctorPathDirect = doctor.PathDirect

type doctorPathKind = doctor.PathKind

const doctorPathLocalProxy = doctor.PathLocalProxy

type doctorPathStatus = doctor.PathStatus

const doctorPathTun = doctor.PathTun
const doctorPathUnknown = doctor.PathUnknown
const doctorPathVPN = doctor.PathVPN

type doctorPlatformStatus = doctor.PlatformStatus

const doctorProbable = doctor.Probable

var doctorProbeCount = doctor.ProbeCount

type doctorProbeExpectation = doctor.ProbeExpectation
type doctorProbeObservation = doctor.ProbeObservation

const doctorResetCommand = doctor.ResetCommand
const doctorRoutingGeneration = doctor.RoutingGeneration
const doctorSchemaVersion = doctor.SchemaVersion

type doctorSnapshot = doctor.Snapshot

const doctorStageFailed = doctor.StageFailed

var doctorStages = doctor.Stages

const doctorStandard = doctor.Standard
const doctorStartCommand = doctor.StartCommand

type doctorStartParams = doctor.StartParams
type doctorStatusProjection = doctor.StatusProjection

const doctorTunGeneration = doctor.TunGeneration
const doctorUnknown = doctor.Unknown

var errDoctorExpectationInactive = doctor.ErrExpectationInactive
var markDoctorConsequences = doctor.MarkConsequences
var newDoctorActor = doctor.NewActor
var newDoctorExamID = doctor.NewExamID
var reduceDoctorEvidence = doctor.ReduceEvidence

func init() {
	doctor.SetGoDetached(safeGoDetached)
	doctor.SetOdometer(odometerInstance)
	doctor.SetTunActive(tunUp.Load)
}
