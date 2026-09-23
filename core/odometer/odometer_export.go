package odometer

var Instance = odometerInstance

var SignalWake = signalOdometerWake

var SetStartReason = setOdoStartReason
var TakeStartReason = takeOdoStartReason

var screenOff = func() bool { return false }

func SetScreenOff(fn func() bool) { screenOff = fn }
