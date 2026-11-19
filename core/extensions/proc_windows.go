package extensions

import (
	"os"
	"os/exec"
	"syscall"

	"golang.org/x/sys/windows"
)

// Core has no console of its own, so a console extension would otherwise open a visible one.
func startCommand(cmd *exec.Cmd) error {
	cmd.SysProcAttr = &syscall.SysProcAttr{HideWindow: true, CreationFlags: windows.CREATE_NO_WINDOW}
	return cmd.Start()
}

func killGroup(process *os.Process) {
	_ = process.Kill()
}

func privileged() bool {
	return windows.GetCurrentProcessToken().IsElevated()
}
