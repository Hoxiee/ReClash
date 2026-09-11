package main

import (
	"encoding/json"
	"strings"
	"testing"
	"time"
)

func TestDoctorReportUsesExportTimeAndKeepsIdentifiersRedacted(t *testing.T) {
	before := time.Now().Add(-time.Second).UnixMilli()
	report := buildDoctorReport(doctorSnapshot{
		UpdatedAt: before,
		Evidence: []doctorEvidence{{
			Kind: doctorEvidenceProbe, Layer: doctorLayerMarker, Outcome: doctorOutcomeSucceeded,
			Confidence: doctorConfirmed, Network: "tcp", Inbound: "tun", at: time.Now(),
		}},
	})
	if report.GeneratedAt <= before {
		t.Fatalf("generatedAt = %d, updatedAt = %d", report.GeneratedAt, before)
	}
	encoded, err := json.Marshal(report)
	if err != nil {
		t.Fatal(err)
	}
	text := string(encoded)
	for _, forbidden := range []string{"hostname", "sourceIp", "targetIp", "profileName", "nodeName", "packageName", "environmentFingerprint"} {
		if strings.Contains(text, forbidden) {
			t.Fatalf("report contains forbidden field %q: %s", forbidden, text)
		}
	}
}

func TestDoctorReportCarriesSafePathAndStageContract(t *testing.T) {
	report := buildDoctorReport(doctorSnapshot{
		PathKind:     doctorPathVPN,
		CaptureState: doctorCaptureActive,
		Stages: []doctorStage{
			{ID: "app", State: doctorStagePassed, Layer: doctorLayerCapture, Code: "captureActive"},
		},
	})
	if report.PathKind != doctorPathVPN || report.CaptureState != doctorCaptureActive || len(report.Stages) != 1 || report.Stages[0].ID != "app" {
		t.Fatalf("report = %+v", report)
	}
}
