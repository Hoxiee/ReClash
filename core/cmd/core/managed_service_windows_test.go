//go:build windows

package main

import (
	"os"
	"os/exec"
	"path/filepath"
	"strconv"
	"strings"
	"testing"

	"golang.org/x/sys/windows"
)

func windowsServiceArgs(t *testing.T, home string) []string {
	t.Helper()
	identity := windowsTestIdentity(t)
	return []string{"--managed-service", `\\.\pipe\ReClashCore_aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa`,
		"0123456789abcdef0123456789abcdef", home, strconv.FormatUint(uint64(identity.parentPID), 10),
		strconv.FormatUint(identity.parentCreated, 10), identity.sid}
}

func TestWindowsServiceLaunchArguments(t *testing.T) {
	home := t.TempDir()
	args := windowsServiceArgs(t, home)
	launch, err := parseWindowsServiceLaunch(args)
	if err != nil {
		t.Fatal(err)
	}
	if launch.address != args[1] || launch.session != args[2] || launch.home != filepath.Clean(home) ||
		strconv.FormatUint(uint64(launch.hostPID), 10) != args[4] ||
		strconv.FormatUint(launch.hostCreated, 10) != args[5] || launch.owner != args[6] {
		t.Fatalf("parsed launch differs from arguments: %+v", launch)
	}
	for _, test := range []struct {
		index int
		value string
	}{
		{0, "--managed-windows"}, {1, `\\remote\pipe\ReClashCore_aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa`},
		{1, `\\.\pipe\ReClash.bootstrap.1.aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa`}, {1, `\\.\pipe\ReClashCore_` + strings.Repeat("A", 32)},
		{2, strings.Repeat("A", 32)}, {2, "short"}, {3, "relative"}, {3, `\\server\share\home`}, {3, `C:\`},
		{3, `C:\Users\..\Windows`}, {3, `C:\home\`}, {4, "0"}, {4, "-1"}, {4, "4294967296"}, {5, "0"}, {5, "x"},
		{6, "invalid"}, {6, strings.ToLower(args[6])},
	} {
		bad := append([]string(nil), args...)
		bad[test.index] = test.value
		if _, err := parseWindowsServiceLaunch(bad); err == nil {
			t.Fatalf("accepted argument %d: %q", test.index, test.value)
		}
	}
	if _, err := parseWindowsServiceLaunch(args[:6]); err == nil {
		t.Fatal("accepted incomplete arguments")
	}
	if _, err := parseWindowsServiceLaunch(append(append([]string(nil), args...), "extra")); err == nil {
		t.Fatal("accepted extra arguments")
	}
}

func TestWindowsServiceStartupRequiresLocalSystem(t *testing.T) {
	if system, err := windowsRunningAsSystem(); err != nil || system {
		t.Skip("the guard is exercised only by a non-LocalSystem test host")
	}
	if _, _, err := prepareDesktopStartup(windowsServiceArgs(t, t.TempDir())); err == nil ||
		err.Error() != "windows_service_core_not_system" {
		t.Fatalf("non-LocalSystem Core passed the service guard: %v", err)
	}
}

func TestWindowsServiceHostIdentity(t *testing.T) {
	identity := windowsTestIdentity(t)
	if err := verifyWindowsProcess(windows.CurrentProcess(), identity.parentPID, identity.parentCreated, identity.sid); err != nil {
		t.Fatal(err)
	}
	other := "S-1-5-18"
	if identity.sid == other {
		other = "S-1-5-19"
	}
	if err := verifyWindowsProcess(windows.CurrentProcess(), identity.parentPID+1, identity.parentCreated, identity.sid); err == nil {
		t.Fatal("accepted a different host PID")
	}
	if err := verifyWindowsProcess(windows.CurrentProcess(), identity.parentPID, identity.parentCreated+1, identity.sid); err == nil {
		t.Fatal("accepted a reused host PID")
	}
	if err := verifyWindowsProcess(windows.CurrentProcess(), identity.parentPID, identity.parentCreated, other); err == nil {
		t.Fatal("accepted a host of another account")
	}
	child := exec.Command(os.Args[0], "-test.run=^$")
	if err := child.Start(); err != nil {
		t.Fatal(err)
	}
	pid := uint32(child.Process.Pid)
	host, err := windows.OpenProcess(windows.PROCESS_QUERY_LIMITED_INFORMATION|windows.SYNCHRONIZE, false, pid)
	if err != nil {
		_ = child.Wait()
		t.Fatal(err)
	}
	defer windows.CloseHandle(host)
	created, err := windowsProcessCreated(host)
	if err != nil {
		t.Fatal(err)
	}
	if err := child.Wait(); err != nil {
		t.Fatal(err)
	}
	if err := verifyWindowsProcess(host, pid, created, identity.sid); err == nil {
		t.Fatal("accepted an exited host")
	}
}

func TestWindowsServiceHomeOwner(t *testing.T) {
	home := t.TempDir()
	pinned, err := lockWindowsHome(home)
	if err != nil {
		t.Fatal(err)
	}
	owner, err := windowsPinnedDirectoryOwner(home, pinned[len(pinned)-1])
	closeWindowsHandles(pinned)
	if err != nil {
		t.Fatal(err)
	}
	handles, err := lockWindowsOwnedHome(home, owner)
	if err != nil {
		t.Fatal(err)
	}
	closeWindowsHandles(handles)
	other := "S-1-5-18"
	if owner == other {
		other = "S-1-5-19"
	}
	if handles, err := lockWindowsOwnedHome(home, other); err == nil {
		closeWindowsHandles(handles)
		t.Fatal("accepted a home owned by another account")
	}
	sibling := filepath.Join(home, "sibling")
	if err := os.Mkdir(sibling, 0700); err != nil {
		t.Fatal(err)
	}
	pinned, err = lockWindowsHome(sibling)
	if err != nil {
		t.Fatal(err)
	}
	defer closeWindowsHandles(pinned)
	if _, err := windowsPinnedDirectoryOwner(home, pinned[len(pinned)-1]); err == nil {
		t.Fatal("read the owner of a directory other than the pinned one")
	}
	file := filepath.Join(home, "file")
	if err := os.WriteFile(file, nil, 0600); err != nil {
		t.Fatal(err)
	}
	for _, path := range []string{file, filepath.Join(home, "missing")} {
		if handles, err := lockWindowsOwnedHome(path, owner); err == nil {
			closeWindowsHandles(handles)
			t.Fatalf("accepted %s as the managed home", path)
		}
	}
}

func TestWindowsServiceHomeRejectsJunction(t *testing.T) {
	root := t.TempDir()
	target := filepath.Join(root, "target")
	if err := os.MkdirAll(filepath.Join(target, "child"), 0700); err != nil {
		t.Fatal(err)
	}
	link := filepath.Join(root, "junction")
	if output, err := exec.Command("cmd", "/c", "mklink", "/J", link, target).CombinedOutput(); err != nil {
		t.Fatalf("create junction: %v: %s", err, output)
	}
	t.Cleanup(func() { os.Remove(link) })
	user, err := windows.GetCurrentProcessToken().GetTokenUser()
	if err != nil {
		t.Fatal(err)
	}
	for _, path := range []string{link, filepath.Join(link, "child")} {
		if handles, err := lockWindowsOwnedHome(path, user.User.Sid.String()); err == nil {
			closeWindowsHandles(handles)
			t.Fatalf("accepted a junction in the managed home %s", path)
		}
	}
}
