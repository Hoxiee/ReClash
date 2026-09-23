//go:build linux || android

package odometer

import (
	"time"

	"golang.org/x/sys/unix"
)

func odoElapsedRealtime() time.Duration {
	var stamp unix.Timespec
	if err := unix.ClockGettime(unix.CLOCK_BOOTTIME, &stamp); err != nil {
		return 0
	}
	return time.Duration(stamp.Sec)*time.Second + time.Duration(stamp.Nsec)
}
