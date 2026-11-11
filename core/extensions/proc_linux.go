package extensions

import (
	"os"
	"os/exec"
	"runtime"
	"syscall"

	"golang.org/x/sys/unix"
)

// startCommand must run on the goroutine that later waits for the child. It locks that goroutine to its OS thread
// and never unlocks it: no_new_privs is per thread and SysProcAttr cannot set it, so the thread sets it on itself
// before forking, and Pdeathsig follows the forking thread. When the goroutine returns the runtime ends the thread
// (or parks it for good if it is the main thread), so the flag never reaches code the Core runs.
func startCommand(cmd *exec.Cmd) error {
	runtime.LockOSThread()
	if err := unix.Prctl(unix.PR_SET_NO_NEW_PRIVS, 1, 0, 0, 0); err != nil {
		return err
	}
	cmd.SysProcAttr = &syscall.SysProcAttr{Setpgid: true, Pdeathsig: syscall.SIGKILL}
	return cmd.Start()
}

func killGroup(process *os.Process) {
	_ = syscall.Kill(-process.Pid, syscall.SIGKILL)
}

func privileged() bool {
	return os.Geteuid() == 0
}
