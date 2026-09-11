//go:build !(android && cgo)

package main

func doctorPlatformProbeRunnerForRuntime() doctorPlatformProbeRunner {
	return nil
}

func doctorByeDPIStatusAvailable() bool {
	return false
}
