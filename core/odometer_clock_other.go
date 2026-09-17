//go:build !linux && !android

package main

import "time"

var odoClockStart = time.Now()

func odoElapsedRealtime() time.Duration {
	return time.Since(odoClockStart)
}
