package doctor

import (
	"runtime"
	"time"

	"github.com/metacubex/mihomo/constant"
)

type doctorReport struct {
	SchemaVersion int                `json:"schemaVersion"`
	CoreVersion   string             `json:"coreVersion"`
	Platform      string             `json:"platform"`
	Architecture  string             `json:"architecture"`
	GeneratedAt   int64              `json:"generatedAt"`
	State         doctorExamState    `json:"state"`
	Health        doctorHealth       `json:"health"`
	Confidence    doctorConfidence   `json:"confidence"`
	Scope         doctorScope        `json:"scope"`
	PathKind      doctorPathKind     `json:"pathKind"`
	CaptureState  doctorCaptureState `json:"captureState"`
	Stages        []doctorStage      `json:"stages"`
	Mode          doctorExamMode     `json:"mode,omitempty"`
	CauseCode     string             `json:"causeCode,omitempty"`
	Layer         doctorLayer        `json:"layer,omitempty"`
	Generations   doctorGenerations  `json:"generations"`
	Evidence      []doctorEvidence   `json:"evidence"`
	HealAudit     []doctorHealAudit  `json:"healAudit"`
	Incidents     []doctorIncident   `json:"incidents"`
}

func buildDoctorReport(snapshot doctorSnapshot) doctorReport {
	evidence := append([]doctorEvidence(nil), snapshot.Evidence...)
	for index := range evidence {
		evidence[index].At = time.Time{}
	}
	return doctorReport{
		SchemaVersion: doctorSchemaVersion,
		CoreVersion:   constant.Version,
		Platform:      runtime.GOOS,
		Architecture:  runtime.GOARCH,
		GeneratedAt:   time.Now().UnixMilli(),
		State:         snapshot.State,
		Health:        snapshot.Health,
		Confidence:    snapshot.Confidence,
		Scope:         snapshot.Scope,
		PathKind:      snapshot.PathKind,
		CaptureState:  snapshot.CaptureState,
		Stages:        append([]doctorStage(nil), snapshot.Stages...),
		Mode:          snapshot.Mode,
		CauseCode:     snapshot.CauseCode,
		Layer:         snapshot.Layer,
		Generations:   snapshot.Generations,
		Evidence:      evidence,
		HealAudit:     append([]doctorHealAudit(nil), snapshot.HealAudit...),
		Incidents:     append([]doctorIncident(nil), snapshot.Incidents...),
	}
}
