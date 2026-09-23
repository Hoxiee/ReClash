package main

import (
	"time"
)

type odoSignal struct {
	Kind   string `json:"kind"`
	Reason string `json:"reason,omitempty"`
	Value  int    `json:"value,omitempty"`
}

func init() {
	registerMethod(odometerReportMethod, withoutArguments(func(response MethodResponse) {
		response.success(odometerInstance.Report())
	}))
	registerMethod(odometerSignalMethod, withArguments(func(signal *odoSignal, response MethodResponse) {
		now := time.Now()
		switch signal.Kind {
		case "prepareUp":
			setOdoStartReason(signal.Reason)
		case "prepareDown":
			odometerInstance.NoteDown(now, signal.Reason == "user")
		case "ladder":
			odometerInstance.NoteLadder(signal.Value, signal.Reason == "completed")
		}
		response.success(true)
	}))
}
