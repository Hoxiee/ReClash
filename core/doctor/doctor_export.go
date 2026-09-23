package doctor

// Exported alias seam: package main drives the connection doctor through
// these names while the implementation stays lowercase and internal.

var BuildReport = buildDoctorReport

type Actor = doctorActor

const Broken = doctorBroken

type CancelParams = doctorCancelParams

const Cancelled = doctorCancelled

type Capabilities = doctorCapabilities

const CaptureActive = doctorCaptureActive
const CaptureInactive = doctorCaptureInactive
const CaptureNotApplicable = doctorCaptureNotApplicable
const CaptureUnknown = doctorCaptureUnknown

type Command = doctorCommand

const Complete = doctorComplete
const ConfigGeneration = doctorConfigGeneration
const Confirmed = doctorConfirmed
const Deep = doctorDeep
const Degraded = doctorDegraded

var DurationBucket = doctorDurationBucket

const EnvironmentGeneration = doctorEnvironmentGeneration

type Evidence = doctorEvidence

const EvidenceProbe = doctorEvidenceProbe

type ExamMode = doctorExamMode
type ExamSink = doctorExamSink
type GenerationChange = doctorGenerationChange

const GenerationCommand = doctorGenerationCommand

type GenerationKind = doctorGenerationKind
type Generations = doctorGenerations
type HealAudit = doctorHealAudit
type HealParams = doctorHealParams

const Healthy = doctorHealthy

type Incident = doctorIncident

const Insufficient = doctorInsufficient
const LayerCapture = doctorLayerCapture
const LayerDNS = doctorLayerDNS
const LayerIngress = doctorLayerIngress
const LayerMarker = doctorLayerMarker
const MaxProbeCount = doctorMaxProbeCount
const Observing = doctorObserving
const OutcomeFailed = doctorOutcomeFailed
const OutcomeNotApplicable = doctorOutcomeNotApplicable
const OutcomeSeen = doctorOutcomeSeen
const OutcomeSucceeded = doctorOutcomeSucceeded
const PathByeDPI = doctorPathByeDPI

type PathContext = doctorPathContext

var PathContextForStatus = doctorPathContextForStatus
var PathContextFor = doctorPathContextFor
var NormalizePathContext = normalizedDoctorPathContext

const PathDirect = doctorPathDirect

type PathKind = doctorPathKind

const PathLocalProxy = doctorPathLocalProxy

type PathStatus = doctorPathStatus

const PathTun = doctorPathTun
const PathUnknown = doctorPathUnknown
const PathVPN = doctorPathVPN

type PlatformStatus = doctorPlatformStatus

const Probable = doctorProbable

var ProbeCount = doctorProbeCount

type ProbeExpectation = doctorProbeExpectation
type ProbeObservation = doctorProbeObservation

const ResetCommand = doctorResetCommand
const RoutingGeneration = doctorRoutingGeneration
const SchemaVersion = doctorSchemaVersion

type Snapshot = doctorSnapshot

const StageFailed = doctorStageFailed

var Stages = doctorStages

const Standard = doctorStandard
const StartCommand = doctorStartCommand

type StartParams = doctorStartParams
type StatusProjection = doctorStatusProjection

const TunGeneration = doctorTunGeneration
const Unknown = doctorUnknown

var ErrExpectationInactive = errDoctorExpectationInactive
var MarkConsequences = markDoctorConsequences
var NewActor = newDoctorActor
var NewExamID = newDoctorExamID
var ReduceEvidence = reduceDoctorEvidence
var AndroidPathStatus = &doctorAndroidPathStatus
