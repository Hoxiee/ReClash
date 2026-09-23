//go:build !linux && !android

package odometer

import "time"

var odoClockStart = time.Now()

func odoElapsedRealtime() time.Duration {
	return time.Since(odoClockStart)
}
