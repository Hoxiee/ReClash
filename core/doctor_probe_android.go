//go:build android && cgo

package main

import (
	"context"
	"encoding/json"
	"errors"
	"time"
)

const doctorProbeCancelGrace = time.Second

func doctorPlatformProbeRunnerForRuntime() doctorPlatformProbeRunner {
	return runAndroidDoctorProbe
}

func runAndroidDoctorProbe(ctx context.Context, request doctorPlatformProbeRequest) (doctorPlatformProbeResult, error) {
	select {
	case <-ctx.Done():
		return doctorPlatformProbeResult{}, ctx.Err()
	default:
	}
	data, err := json.Marshal(request)
	if err != nil {
		return doctorPlatformProbeResult{}, err
	}
	resultChannel := make(chan string, 1)
	go func() {
		resultChannel <- handleDoctorProbe(string(data))
	}()
	var resultData string
	select {
	case resultData = <-resultChannel:
	case <-ctx.Done():
		handleCancelDoctorProbe(request.ProbeID)
		select {
		case <-resultChannel:
		case <-time.After(doctorProbeCancelGrace):
		}
		return doctorPlatformProbeResult{
			ProbeID:   request.ProbeID,
			Outcome:   doctorPlatformProbeCancelled,
			ErrorCode: doctorProbeErrorCode(ctx.Err(), "probeCancelled"),
		}, nil
	}
	if resultData == "" {
		return doctorPlatformProbeResult{}, errors.New("platform probe unavailable")
	}
	var result doctorPlatformProbeResult
	if err := json.Unmarshal([]byte(resultData), &result); err != nil {
		return doctorPlatformProbeResult{}, err
	}
	return result, nil
}

func doctorByeDPIStatusAvailable() bool {
	return true
}
