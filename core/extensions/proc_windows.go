package extensions

import (
	"os"
	"os/exec"

	"golang.org/x/sys/windows"
)

func startCommand(cmd *exec.Cmd) error {
	return cmd.Start()
}

func killGroup(process *os.Process) {
	_ = process.Kill()
}

func privileged() bool {
	return windows.GetCurrentProcessToken().IsElevated()
}
