package main

import "core/odometer"

var odometerInstance = odometer.Instance
var signalOdometerWake = odometer.SignalWake
var setOdoStartReason = odometer.SetStartReason
var takeOdoStartReason = odometer.TakeStartReason

func init() {
	odometer.SetScreenOff(isScreenOff.Load)
}
