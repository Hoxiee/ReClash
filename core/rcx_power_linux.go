//go:build linux && !android

package core

import (
	"os"
	"path/filepath"
	"strings"
)

func readPowerState() (rcxPowerState, bool) {
	dirs, _ := filepath.Glob("/sys/class/power_supply/*")
	found := false
	for _, dir := range dirs {
		// Mice and headsets report batteries too, with scope "Device".
		if sysfsValue(dir, "type") != "Battery" || sysfsValue(dir, "scope") == "Device" {
			continue
		}
		found = true
		if sysfsValue(dir, "status") == "Discharging" {
			return rcxPowerState{onBattery: true}, true
		}
	}
	return rcxPowerState{}, found
}

func sysfsValue(dir, name string) string {
	data, _ := os.ReadFile(filepath.Join(dir, name))
	return strings.TrimSpace(string(data))
}
