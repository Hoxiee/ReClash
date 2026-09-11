package main

import "time"

const (
	doctorSchemaVersion        = 1
	doctorMaxFacts             = 128
	doctorMaxIncidents         = 32
	doctorEvidenceQueue        = 512
	doctorEvidenceFreshFor     = 90 * time.Second
	doctorPassivePublishPeriod = 250 * time.Millisecond
	doctorMaxProbeCount        = 8
)

var doctorExamTimeout = 20 * time.Second

type doctorExamState string
type doctorExamMode string
type doctorHealth string
type doctorConfidence string
type doctorSeverity string
type doctorScope string
type doctorLayer string
type doctorEvidenceKind string
type doctorEvidenceOutcome string
type doctorPathKind string
type doctorCaptureState string
type doctorStageState string

const (
	doctorObserving    doctorExamState = "observing"
	doctorExamining    doctorExamState = "examining"
	doctorComplete     doctorExamState = "complete"
	doctorInconclusive doctorExamState = "inconclusive"
	doctorSuperseded   doctorExamState = "superseded"
	doctorCancelled    doctorExamState = "cancelled"

	doctorStandard doctorExamMode = "standard"
	doctorDeep     doctorExamMode = "deep"

	doctorUnknown  doctorHealth = "unknown"
	doctorHealthy  doctorHealth = "healthy"
	doctorDegraded doctorHealth = "degraded"
	doctorBroken   doctorHealth = "broken"

	doctorConfirmed    doctorConfidence = "confirmed"
	doctorProbable     doctorConfidence = "probable"
	doctorInsufficient doctorConfidence = "insufficient"

	doctorSeverityInfo     doctorSeverity = "info"
	doctorSeverityWarning  doctorSeverity = "warning"
	doctorSeverityCritical doctorSeverity = "critical"

	doctorScopeUnknown doctorScope = "unknown"
	doctorScopeApp     doctorScope = "app"
	doctorScopeInbound doctorScope = "inbound"

	doctorLayerCapture   doctorLayer = "capture"
	doctorLayerIngress   doctorLayer = "ingress"
	doctorLayerDNS       doctorLayer = "dns"
	doctorLayerRoute     doctorLayer = "route"
	doctorLayerDial      doctorLayer = "dial"
	doctorLayerTransport doctorLayer = "transport"
	doctorLayerMarker    doctorLayer = "marker"

	doctorEvidenceIngress       doctorEvidenceKind = "ingress"
	doctorEvidencePreHandle     doctorEvidenceKind = "preHandle"
	doctorEvidenceRoute         doctorEvidenceKind = "route"
	doctorEvidenceOuterDial     doctorEvidenceKind = "outerDial"
	doctorEvidenceTrackerOpen   doctorEvidenceKind = "trackerOpen"
	doctorEvidenceFirstProgress doctorEvidenceKind = "firstProgress"
	doctorEvidenceMarker        doctorEvidenceKind = "marker"
	doctorEvidenceProbe         doctorEvidenceKind = "probe"
	doctorEvidenceOverflow      doctorEvidenceKind = "evidenceOverflow"

	doctorOutcomeSeen          doctorEvidenceOutcome = "seen"
	doctorOutcomeSucceeded     doctorEvidenceOutcome = "succeeded"
	doctorOutcomeFailed        doctorEvidenceOutcome = "failed"
	doctorOutcomeDropped       doctorEvidenceOutcome = "dropped"
	doctorOutcomeNotApplicable doctorEvidenceOutcome = "notApplicable"

	doctorPathUnknown    doctorPathKind = "unknown"
	doctorPathVPN        doctorPathKind = "vpn"
	doctorPathTun        doctorPathKind = "tun"
	doctorPathLocalProxy doctorPathKind = "localProxy"
	doctorPathDirect     doctorPathKind = "direct"
	doctorPathByeDPI     doctorPathKind = "byeDpi"

	doctorCaptureUnknown       doctorCaptureState = "unknown"
	doctorCaptureInactive      doctorCaptureState = "inactive"
	doctorCaptureActive        doctorCaptureState = "active"
	doctorCaptureNotApplicable doctorCaptureState = "notApplicable"

	doctorStagePassed        doctorStageState = "passed"
	doctorStageFailed        doctorStageState = "failed"
	doctorStageChecking      doctorStageState = "checking"
	doctorStageUnknown       doctorStageState = "unknown"
	doctorStageNotApplicable doctorStageState = "notApplicable"
	doctorStageConsequence   doctorStageState = "consequence"
)

type doctorCapabilities struct {
	PassiveWitness         bool `json:"passiveWitness"`
	ExplicitExam           bool `json:"explicitExam"`
	Cancel                 bool `json:"cancel"`
	DNSFlush               bool `json:"dnsFlush"`
	AndroidAppIngressProbe bool `json:"androidAppIngressProbe"`
	TunIngressProof        bool `json:"tunIngressProof"`
	ByeDPIStatus           bool `json:"byedpiStatus"`
	RedactedExport         bool `json:"redactedExport"`
}

type doctorGenerations struct {
	Environment uint64 `json:"environment"`
	Config      uint64 `json:"config"`
	Routing     uint64 `json:"routing"`
	Tun         uint64 `json:"tun"`
}

type doctorEvidence struct {
	Kind             doctorEvidenceKind    `json:"kind"`
	Layer            doctorLayer           `json:"layer"`
	Outcome          doctorEvidenceOutcome `json:"outcome"`
	Confidence       doctorConfidence      `json:"confidence"`
	Code             string                `json:"code,omitempty"`
	Network          string                `json:"network,omitempty"`
	Inbound          string                `json:"inbound,omitempty"`
	OffsetMillis     int64                 `json:"offsetMillis"`
	DurationBucketMs int64                 `json:"durationBucketMs,omitempty"`
	Consequence      bool                  `json:"consequence,omitempty"`
	at               time.Time
}

type doctorAction struct {
	ID                    string `json:"id"`
	Eligible              bool   `json:"eligible"`
	EligibilityReasonCode string `json:"eligibilityReasonCode,omitempty"`
}

type doctorHealAudit struct {
	ActionID       string `json:"actionId"`
	At             int64  `json:"at"`
	Outcome        string `json:"outcome"`
	BeforeRevision uint64 `json:"beforeRevision"`
	ReexamID       string `json:"reexamId,omitempty"`
}

type doctorIncident struct {
	ExamID     string           `json:"examId"`
	Mode       doctorExamMode   `json:"mode"`
	State      doctorExamState  `json:"state"`
	Health     doctorHealth     `json:"health"`
	Confidence doctorConfidence `json:"confidence"`
	CauseCode  string           `json:"causeCode,omitempty"`
	Layer      doctorLayer      `json:"layer,omitempty"`
	StartedAt  int64            `json:"startedAt"`
	FinishedAt int64            `json:"finishedAt"`
}

type doctorProgress struct {
	Phase     string `json:"phase"`
	Completed int    `json:"completed"`
	Total     int    `json:"total"`
}

type doctorStage struct {
	ID    string           `json:"id"`
	State doctorStageState `json:"state"`
	Layer doctorLayer      `json:"layer,omitempty"`
	Code  string           `json:"code,omitempty"`
}

type doctorSnapshot struct {
	SchemaVersion    int                `json:"schemaVersion"`
	Revision         uint64             `json:"revision"`
	Supported        bool               `json:"supported"`
	Capabilities     doctorCapabilities `json:"capabilities"`
	State            doctorExamState    `json:"state"`
	Health           doctorHealth       `json:"health"`
	Confidence       doctorConfidence   `json:"confidence"`
	Severity         doctorSeverity     `json:"severity"`
	Scope            doctorScope        `json:"scope"`
	PathKind         doctorPathKind     `json:"pathKind"`
	CaptureState     doctorCaptureState `json:"captureState"`
	Stages           []doctorStage      `json:"stages"`
	ExamID           string             `json:"examId,omitempty"`
	Mode             doctorExamMode     `json:"mode,omitempty"`
	CauseCode        string             `json:"causeCode,omitempty"`
	Layer            doctorLayer        `json:"layer,omitempty"`
	Progress         doctorProgress     `json:"progress"`
	Generations      doctorGenerations  `json:"generations"`
	StartGenerations doctorGenerations  `json:"startGenerations"`
	StartedAt        int64              `json:"startedAt,omitempty"`
	UpdatedAt        int64              `json:"updatedAt"`
	FreshUntil       int64              `json:"freshUntil,omitempty"`
	EvidenceDropped  uint64             `json:"evidenceDropped,omitempty"`
	Evidence         []doctorEvidence   `json:"evidence"`
	Actions          []doctorAction     `json:"actions"`
	HealAudit        []doctorHealAudit  `json:"healAudit"`
	Incidents        []doctorIncident   `json:"incidents"`
}

type doctorStatusProjection struct {
	Revision   uint64           `json:"revision"`
	State      doctorExamState  `json:"state"`
	Health     doctorHealth     `json:"health"`
	Confidence doctorConfidence `json:"confidence"`
	CauseCode  string           `json:"causeCode,omitempty"`
}

type doctorPathStatus struct {
	PathKind   doctorPathKind `json:"pathKind"`
	Phase      string         `json:"phase,omitempty"`
	Generation uint64         `json:"generation"`
	Timestamp  int64          `json:"timestamp,omitempty"`
}

type doctorStartParams struct {
	Mode doctorExamMode `json:"mode"`
}

type doctorCancelParams struct {
	ExamID string `json:"examId"`
}

type doctorHealParams struct {
	ExamID   string `json:"examId"`
	Revision uint64 `json:"revision"`
	ActionID string `json:"actionId"`
}
