//go:build windows && !android

package main

import (
	"core"
	"errors"
	"fmt"
	"path/filepath"
	"strconv"

	"golang.org/x/sys/windows"
)

type windowsServiceLaunch struct {
	address, session, home, owner string
	hostPID                       uint32
	hostCreated                   uint64
}

func parseWindowsServiceLaunch(args []string) (windowsServiceLaunch, error) {
	var launch windowsServiceLaunch
	if len(args) != 7 || args[0] != "--managed-service" {
		return launch, errors.New("windows_invalid_service_arguments")
	}
	if !validWindowsRPCAddress(args[1]) {
		return launch, errors.New("windows_invalid_pipe_namespace")
	}
	if !windowsHex(args[2], 32) {
		return launch, errors.New("windows_invalid_session")
	}
	if !windowsLocalPath(args[3]) {
		return launch, errors.New("windows_invalid_home")
	}
	pid, pidErr := strconv.ParseUint(args[4], 10, 32)
	created, createdErr := strconv.ParseUint(args[5], 10, 64)
	if pidErr != nil || createdErr != nil || pid == 0 || created == 0 {
		return launch, errors.New("windows_invalid_host_identity")
	}
	// Only the canonical form is accepted: every later check compares SID strings.
	owner, err := windows.StringToSid(args[6])
	if err != nil || owner.String() != args[6] {
		return launch, errors.New("windows_invalid_owner_sid")
	}
	return windowsServiceLaunch{address: args[1], session: args[2], home: filepath.Clean(args[3]), owner: args[6],
		hostPID: uint32(pid), hostCreated: created}, nil
}

func windowsPinnedDirectoryOwner(path string, pinned windows.Handle) (string, error) {
	name, err := windows.UTF16PtrFromString(path)
	if err != nil {
		return "", err
	}
	handle, err := windows.CreateFile(name, windows.READ_CONTROL|windows.FILE_READ_ATTRIBUTES,
		windows.FILE_SHARE_READ|windows.FILE_SHARE_WRITE, nil, windows.OPEN_EXISTING,
		windows.FILE_FLAG_BACKUP_SEMANTICS|windows.FILE_FLAG_OPEN_REPARSE_POINT, 0)
	if err != nil {
		return "", err
	}
	defer windows.CloseHandle(handle)
	var opened, expected windows.ByHandleFileInformation
	if err := windows.GetFileInformationByHandle(handle, &opened); err != nil {
		return "", err
	}
	if err := windows.GetFileInformationByHandle(pinned, &expected); err != nil {
		return "", err
	}
	if opened.VolumeSerialNumber != expected.VolumeSerialNumber || opened.FileIndexHigh != expected.FileIndexHigh ||
		opened.FileIndexLow != expected.FileIndexLow {
		return "", errors.New("windows_home_identity_changed")
	}
	descriptor, err := windows.GetSecurityInfo(handle, windows.SE_FILE_OBJECT, windows.OWNER_SECURITY_INFORMATION)
	if err != nil {
		return "", err
	}
	owner, _, err := descriptor.Owner()
	if err != nil || owner == nil {
		return "", errors.New("windows_home_owner_unavailable")
	}
	return owner.String(), nil
}

func lockWindowsOwnedHome(home, owner string) ([]windows.Handle, error) {
	handles, err := lockWindowsHome(home)
	if err != nil {
		return nil, err
	}
	actual, err := windowsPinnedDirectoryOwner(home, handles[len(handles)-1])
	if err != nil {
		closeWindowsHandles(handles)
		return nil, err
	}
	if actual != owner {
		closeWindowsHandles(handles)
		return nil, errors.New("windows_home_owner_mismatch")
	}
	return handles, nil
}

func prepareWindowsServiceStartup(args []string) (string, func(), error) {
	system, err := windowsRunningAsSystem()
	if err != nil || !system {
		return "", nil, errors.New("windows_service_core_not_system")
	}
	launch, err := parseWindowsServiceLaunch(args)
	if err != nil {
		return "", nil, err
	}
	host, err := windows.OpenProcess(windows.PROCESS_QUERY_LIMITED_INFORMATION|windows.SYNCHRONIZE, false, launch.hostPID)
	if err != nil {
		return "", nil, fmt.Errorf("windows_host_open_failed: %w", err)
	}
	var handles []windows.Handle
	keepHost := false
	defer func() {
		if !keepHost {
			_ = windows.CloseHandle(host)
			closeWindowsHandles(handles)
		}
	}()
	if err := verifyWindowsProcess(host, launch.hostPID, launch.hostCreated, launch.owner); err != nil {
		return "", nil, err
	}
	handles, err = lockWindowsOwnedHome(launch.home, launch.owner)
	if err != nil {
		return "", nil, fmt.Errorf("windows_home_pin_failed: %w", err)
	}
	identity := &windowsParent{handle: host, pid: launch.hostPID, created: launch.hostCreated, home: launch.home}
	if err := core.ConfigureDesktopLaunch(launch.home, windowsRPCVerifier(identity)); err != nil {
		return "", nil, err
	}
	cleanup, err := watchWindowsParent(host, handles)
	if err != nil {
		return "", nil, err
	}
	keepHost = true
	return launch.address, cleanup, nil
}
