//go:build unix && !linux

package extensions

import (
	"os"
	"os/exec"
	"syscall"
)

func startCommand(cmd *exec.Cmd) error {
	cmd.SysProcAttr = &syscall.SysProcAttr{Setpgid: true}
	return cmd.Start()
}

func killGroup(process *os.Process) {
	_ = syscall.Kill(-process.Pid, syscall.SIGKILL)
}

func privileged() bool {
	return os.Geteuid() == 0
}
