package core

import (
	"syscall"
	"unsafe"
)

var getSystemPowerStatus = syscall.NewLazyDLL("kernel32.dll").NewProc("GetSystemPowerStatus")

type systemPowerStatus struct {
	ACLineStatus        uint8
	BatteryFlag         uint8
	BatteryLifePercent  uint8
	SystemStatusFlag    uint8
	BatteryLifeTime     uint32
	BatteryFullLifeTime uint32
}

const acLineUnknown = 255

func readPowerState() (rcxPowerState, bool) {
	var status systemPowerStatus
	if ok, _, _ := getSystemPowerStatus.Call(uintptr(unsafe.Pointer(&status))); ok == 0 || status.ACLineStatus == acLineUnknown {
		return rcxPowerState{}, false
	}
	// SystemStatusFlag 1 is battery saver.
	return rcxPowerState{onBattery: status.ACLineStatus == 0, powerSave: status.SystemStatusFlag == 1}, true
}
