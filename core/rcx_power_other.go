//go:build !linux && !darwin && !windows

package core

func readPowerState() (rcxPowerState, bool) { return rcxPowerState{}, false }
