//go:build linux && !android

package main

import (
	"fmt"
	"syscall"

	"golang.org/x/sys/unix"
)

func restrictChildPrivileges() error {
	// Capabilities are per-thread; a single prctl leaves other threads privileged across exec.
	_, _, err := syscall.AllThreadsSyscall6(unix.SYS_PRCTL, unix.PR_CAP_AMBIENT, unix.PR_CAP_AMBIENT_CLEAR_ALL, 0, 0, 0, 0)
	if err != 0 {
		return fmt.Errorf("clear ambient capabilities: %w", err)
	}
	return nil
}
