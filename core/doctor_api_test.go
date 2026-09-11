package main

import (
	"encoding/json"
	"testing"
)

func TestDoctorMethodsAreRegistered(t *testing.T) {
	for _, method := range []CoreMethod{
		doctorSnapshotMethod,
		doctorStartMethod,
		doctorCancelMethod,
		doctorFlushDNSMethod,
		doctorExportMethod,
		doctorPlatformStatusMethod,
		doctorPathStatusMethod,
	} {
		if methodHandlers[method] == nil {
			t.Errorf("method %s is not registered", method)
		}
	}
}

func TestDoctorSnapshotEnvelopeIsPortable(t *testing.T) {
	snapshot := connectionDoctor.Snapshot()
	response := MethodResponse{ID: "doctor", Result: snapshot}
	data, err := response.JSON()
	if err != nil {
		t.Fatal(err)
	}
	var envelope struct {
		ID     string          `json:"id"`
		Result json.RawMessage `json:"result"`
		Error  *MethodError    `json:"error"`
	}
	if err := json.Unmarshal(data, &envelope); err != nil {
		t.Fatal(err)
	}
	if envelope.ID != "doctor" || envelope.Error != nil {
		t.Fatalf("envelope = %+v", envelope)
	}
	var decoded doctorSnapshot
	if err := json.Unmarshal(envelope.Result, &decoded); err != nil {
		t.Fatal(err)
	}
	if decoded.SchemaVersion != doctorSchemaVersion || !decoded.Supported || decoded.Revision == 0 {
		t.Fatalf("snapshot = %+v", decoded)
	}
}

func TestDoctorErrorEnvelopeUsesStableCode(t *testing.T) {
	response := MethodResponse{
		ID:     "doctor-error",
		Result: nil,
		Error: &MethodError{
			Code:    errDoctorExpectationInactive.Error(),
			Message: "connection doctor: " + errDoctorExpectationInactive.Error(),
			Details: nil,
		},
	}
	data, err := response.JSON()
	if err != nil {
		t.Fatal(err)
	}
	var envelope struct {
		Result any          `json:"result"`
		Error  *MethodError `json:"error"`
	}
	if err := json.Unmarshal(data, &envelope); err != nil {
		t.Fatal(err)
	}
	if envelope.Result != nil || envelope.Error == nil || envelope.Error.Code != "exam_not_active" {
		t.Fatalf("envelope = %+v", envelope)
	}
}
