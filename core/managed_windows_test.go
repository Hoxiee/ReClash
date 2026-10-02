//go:build windows

package main

import (
	"bufio"
	"context"
	"fmt"
	"net"
	"os"
	"os/exec"
	"path/filepath"
	"strconv"
	"strings"
	"testing"
	"time"
	"unsafe"

	"github.com/Microsoft/go-winio"
	"golang.org/x/sys/windows"
)

func windowsTestIdentity(t *testing.T) windowsLaunch {
	t.Helper()
	created, err := windowsProcessCreated(windows.CurrentProcess())
	if err != nil {
		t.Fatal(err)
	}
	user, err := windows.GetCurrentProcessToken().GetTokenUser()
	if err != nil {
		t.Fatal(err)
	}
	var session uint32
	if err := windows.ProcessIdToSessionId(uint32(os.Getpid()), &session); err != nil {
		t.Fatal(err)
	}
	return windowsLaunch{parentPID: uint32(os.Getpid()), parentCreated: created, terminalSession: session, sid: user.User.Sid.String()}
}

func TestWindowsLaunchArguments(t *testing.T) {
	identity := windowsTestIdentity(t)
	session := "0123456789abcdef0123456789abcdef"
	args := []string{"--managed-windows", fmt.Sprintf(`\\.\pipe\ReClash.bootstrap.%d.%s`, identity.parentPID, session),
		strconv.FormatUint(uint64(identity.parentPID), 10), strconv.FormatUint(identity.parentCreated, 10), identity.sid,
		strconv.FormatUint(uint64(identity.terminalSession), 10), `\\.\pipe\ReClashCore_test`, session, t.TempDir()}
	if _, err := parseWindowsLaunch(args); err != nil {
		t.Fatal(err)
	}
	for _, test := range []struct {
		index int
		value string
	}{
		{0, "--other"}, {1, `\\.\pipe\other`}, {2, "0"}, {2, "4294967296"}, {3, "0"}, {4, "invalid"},
		{5, "-1"}, {6, `\\remote\pipe\ReClashCore_test`}, {6, "\\\\.\\pipe\\ReClashCore_\x00"},
		{7, strings.Repeat("A", 32)}, {7, "short"}, {8, "relative"}, {8, `\\server\share\home`}, {8, `C:\`},
	} {
		bad := append([]string(nil), args...)
		bad[test.index] = test.value
		if _, err := parseWindowsLaunch(bad); err == nil {
			t.Fatalf("accepted argument %d: %q", test.index, test.value)
		}
	}
	if _, err := parseWindowsLaunch(args[:8]); err == nil {
		t.Fatal("accepted incomplete arguments")
	}
	if _, _, err := prepareDesktopStartup(nil); err == nil {
		t.Fatal("accepted missing executable")
	}
}

func TestWindowsParentIdentity(t *testing.T) {
	identity := windowsTestIdentity(t)
	image, err := os.Executable()
	if err != nil {
		t.Fatal(err)
	}
	if err := verifyWindowsParent(windows.CurrentProcess(), identity, image); err != nil {
		t.Fatal(err)
	}
	for _, mutate := range []func(*windowsLaunch){
		func(p *windowsLaunch) { p.parentPID++ },
		func(p *windowsLaunch) { p.parentCreated++ },
		func(p *windowsLaunch) { p.terminalSession++ },
		func(p *windowsLaunch) {
			p.sid = "S-1-5-18"
			if p.sid == identity.sid {
				p.sid = "S-1-5-19"
			}
		},
	} {
		bad := identity
		mutate(&bad)
		if err := verifyWindowsParent(windows.CurrentProcess(), bad, image); err == nil {
			t.Fatal("accepted mismatched identity")
		}
	}
	other := filepath.Join(t.TempDir(), "ReClash.exe")
	if err := os.WriteFile(other, []byte("other image"), 0600); err != nil {
		t.Fatal(err)
	}
	if err := verifyWindowsParent(windows.CurrentProcess(), identity, other); err == nil {
		t.Fatal("accepted another executable")
	}
}

func TestWindowsHomeLockRetainsHandlesAndGates(t *testing.T) {
	home := t.TempDir()
	handles, err := lockWindowsHome(home)
	if err != nil {
		t.Fatal(err)
	}
	defer func() {
		for _, handle := range handles {
			windows.CloseHandle(handle)
		}
	}()
	// The open handles document retention only: neither rename nor removal
	// is refused while pinned, so assert the handles and the gating instead.
	if len(handles) == 0 {
		t.Fatal("home lock holds no handles")
	}
	if _, err := lockWindowsHome(filepath.Join(home, "missing")); err == nil {
		t.Fatal("locked a missing home path")
	}
	previous := managedWindowsParent
	managedWindowsParent = &windowsParent{home: home}
	defer func() { managedWindowsParent = previous }()
	if !permittedCoreHome(home) || !permittedCoreHome(strings.ToUpper(home)) {
		t.Fatal("original home rejected")
	}
	if permittedCoreHome(filepath.Join(home, "other")) || permittedCoreHome(filepath.Dir(home)) {
		t.Fatal("managed home escaped")
	}
}

func TestWindowsHomeRejectsJunction(t *testing.T) {
	root := t.TempDir()
	target := filepath.Join(root, "target")
	if err := os.Mkdir(target, 0700); err != nil {
		t.Fatal(err)
	}
	link := filepath.Join(root, "junction")
	if output, err := exec.Command("cmd", "/c", "mklink", "/J", link, target).CombinedOutput(); err != nil {
		t.Fatalf("create junction: %v: %s", err, output)
	}
	t.Cleanup(func() { os.Remove(link) })
	if handles, err := lockWindowsHome(link); err == nil {
		for _, handle := range handles {
			windows.CloseHandle(handle)
		}
		t.Fatal("accepted a junction in the managed home")
	}
}

func TestWindowsRPCServerUsesKernelIdentity(t *testing.T) {
	identity := windowsTestIdentity(t)
	path := fmt.Sprintf(`\\.\pipe\ReClash.test.%d`, os.Getpid())
	listener, err := winio.ListenPipe(path, &winio.PipeConfig{SecurityDescriptor: "D:P(A;;GA;;;" + identity.sid + ")"})
	if err != nil {
		t.Fatal(err)
	}
	defer listener.Close()
	accepted := make(chan net.Conn, 1)
	go func() {
		conn, err := listener.Accept()
		if err == nil {
			accepted <- conn
		}
	}()
	ctx, cancel := context.WithTimeout(context.Background(), time.Second)
	defer cancel()
	conn, err := winio.DialPipeAccessImpLevel(ctx, path, windowsPipeAccess, winio.PipeImpLevelAnonymous)
	if err != nil {
		t.Fatal(err)
	}
	defer conn.Close()
	select {
	case server := <-accepted:
		defer server.Close()
	case <-ctx.Done():
		t.Fatal(ctx.Err())
	}
	previous := managedWindowsParent
	managedWindowsParent = &windowsParent{handle: windows.CurrentProcess(), pid: identity.parentPID, created: identity.parentCreated}
	defer func() { managedWindowsParent = previous }()
	if err := verifyWindowsRPCServer(conn); err != nil {
		t.Fatal(err)
	}
	managedWindowsParent.pid++
	if err := verifyWindowsRPCServer(conn); err == nil {
		t.Fatal("accepted a different server PID")
	}
	managedWindowsParent.pid = identity.parentPID
	managedWindowsParent.created++
	if err := verifyWindowsRPCServer(conn); err == nil {
		t.Fatal("accepted a reused server PID")
	}
}

func windowsTestJob(t *testing.T, flags uint32) windows.Handle {
	t.Helper()
	job, err := windows.CreateJobObject(nil, nil)
	if err != nil {
		t.Fatal(err)
	}
	limits := windows.JOBOBJECT_EXTENDED_LIMIT_INFORMATION{}
	limits.BasicLimitInformation.LimitFlags = flags
	if _, err := windows.SetInformationJobObject(job, windows.JobObjectExtendedLimitInformation,
		uintptr(unsafe.Pointer(&limits)), uint32(unsafe.Sizeof(limits))); err != nil {
		windows.CloseHandle(job)
		t.Fatal(err)
	}
	return job
}

func TestWindowsJobRejectsUnownedAndWrongObjects(t *testing.T) {
	if err := joinWindowsJob(windows.CurrentProcess(), 0); err == nil {
		t.Fatal("accepted null job")
	}
	if err := joinWindowsJob(windows.CurrentProcess(), uint64(windows.CurrentProcess())); err == nil {
		t.Fatal("accepted process as job")
	}
	job := windowsTestJob(t, 0)
	defer windows.CloseHandle(job)
	if err := joinWindowsJob(windows.CurrentProcess(), uint64(job)); err == nil {
		t.Fatal("accepted job without kill-on-close")
	}
}

func TestWindowsJobChild(t *testing.T) {
	if os.Getenv("RECLASH_GO_JOB_CHILD") == "" {
		return
	}
	pid, _ := strconv.ParseUint(os.Getenv("RECLASH_GO_JOB_PARENT"), 10, 32)
	source, _ := strconv.ParseUint(os.Getenv("RECLASH_GO_JOB_SOURCE"), 10, 64)
	parent, err := windows.OpenProcess(windows.PROCESS_DUP_HANDLE, false, uint32(pid))
	if err != nil {
		t.Fatal(err)
	}
	defer windows.CloseHandle(parent)
	if err := joinWindowsJob(parent, source); err != nil {
		t.Fatal(err)
	}
	fmt.Println("joined")
	time.Sleep(30 * time.Second)
}

func TestWindowsJobDuplicateDoesNotKeepOrphanAlive(t *testing.T) {
	job := windowsTestJob(t, windows.JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE)
	defer func() {
		if job != 0 {
			windows.CloseHandle(job)
		}
	}()
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	child := exec.CommandContext(ctx, os.Args[0], "-test.run=^TestWindowsJobChild$")
	child.Env = append(os.Environ(), "RECLASH_GO_JOB_CHILD=1", fmt.Sprintf("RECLASH_GO_JOB_PARENT=%d", os.Getpid()), fmt.Sprintf("RECLASH_GO_JOB_SOURCE=%d", job))
	out, err := child.StdoutPipe()
	if err != nil {
		t.Fatal(err)
	}
	if err := child.Start(); err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() { child.Process.Kill(); child.Wait() })
	scanner := bufio.NewScanner(out)
	joined := false
	for scanner.Scan() {
		if scanner.Text() == "joined" {
			joined = true
			break
		}
	}
	if !joined {
		t.Fatal("child did not join the job")
	}
	if err := windows.CloseHandle(job); err != nil {
		t.Fatal(err)
	}
	job = 0
	// A job-close kill reports a success exit code, so survival is proven
	// by the watchdog below (10s budget against a 30s sleep), not by status.
	_ = child.Wait()
	if ctx.Err() != nil {
		t.Fatal("child required watchdog termination")
	}
}
