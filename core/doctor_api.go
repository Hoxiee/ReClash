package main

import "fmt"

var connectionDoctor = newDoctorActor(coreDoctorRuntime{}, func(status doctorStatusProjection) {
	sendMessage(Message{Type: DoctorStatusMessage, Data: status})
})

func init() {
	registerMethod(doctorSnapshotMethod, withoutArguments(func(response MethodResponse) {
		response.success(connectionDoctor.Snapshot())
	}))
	registerMethod(doctorStartMethod, withArguments(func(params *doctorStartParams, response MethodResponse) {
		safeGo(response, func() {
			snapshot, err := connectionDoctor.request(doctorCommand{kind: doctorStartCommand, start: *params})
			respondDoctor(response, snapshot, err)
		})
	}))
	registerMethod(doctorCancelMethod, withArguments(func(params *doctorCancelParams, response MethodResponse) {
		snapshot, err := connectionDoctor.request(doctorCommand{kind: doctorCancelCommand, cancel: *params})
		respondDoctor(response, snapshot, err)
	}))
	registerMethod(doctorFlushDNSMethod, withArguments(func(params *doctorHealParams, response MethodResponse) {
		safeGo(response, func() {
			snapshot, err := connectionDoctor.request(doctorCommand{kind: doctorHealCommand, heal: *params})
			respondDoctor(response, snapshot, err)
		})
	}))
	registerMethod(doctorExportMethod, withoutArguments(func(response MethodResponse) {
		response.success(buildDoctorReport(connectionDoctor.Snapshot()))
	}))
	registerMethod(doctorPlatformStatusMethod, withArguments(func(status *doctorPlatformStatus, response MethodResponse) {
		_, err := connectionDoctor.request(doctorCommand{kind: doctorPlatformStatusCommand, platform: *status})
		if err != nil {
			response.failure("invalid_platform_status", "connection doctor: invalid platform status", nil)
			return
		}
		response.success(true)
	}))
	registerMethod(doctorPathStatusMethod, withArguments(func(status *doctorPathStatus, response MethodResponse) {
		if !validDoctorPathKind(status.PathKind) || !validDoctorPathPhase(status.Phase) || status.Generation == 0 || status.Timestamp < 0 {
			response.failure("invalid_path_status", "connection doctor: invalid path status", nil)
			return
		}
		snapshot, err := connectionDoctor.request(doctorCommand{kind: doctorPathStatusCommand, pathStatus: *status})
		respondDoctor(response, snapshot, err)
	}))
}

func respondDoctor(response MethodResponse, snapshot doctorSnapshot, err error) {
	if err == nil {
		response.success(snapshot)
		return
	}
	code := err.Error()
	response.failure(code, fmt.Sprintf("connection doctor: %s", code), nil)
}

func doctorReset() {
	_, _ = connectionDoctor.request(doctorCommand{kind: doctorResetCommand})
}

func doctorBumpGeneration(kind doctorGenerationKind) {
	_, _ = connectionDoctor.request(doctorCommand{kind: doctorGenerationCommand, generation: kind})
}

func doctorBumpGenerations(change doctorGenerationChange) {
	_, _ = connectionDoctor.request(doctorCommand{kind: doctorGenerationCommand, generations: change})
}

func validDoctorPathKind(kind doctorPathKind) bool {
	switch kind {
	case doctorPathUnknown, doctorPathVPN, doctorPathTun, doctorPathLocalProxy, doctorPathDirect, doctorPathByeDPI:
		return true
	default:
		return false
	}
}

func validDoctorPathPhase(phase string) bool {
	switch phase {
	case "active", "inactive", "paused":
		return true
	default:
		return false
	}
}
