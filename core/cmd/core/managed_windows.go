//go:build windows && !android

package main

import (
	"context"
	"core"
	"encoding/binary"
	"errors"
	"fmt"
	"io"
	"net"
	"os"
	"path/filepath"
	"runtime"
	"strconv"
	"strings"
	"sync"
	"time"
	"unsafe"

	"github.com/Microsoft/go-winio"
	"golang.org/x/sys/windows"
)

const windowsBootstrapTimeout = 10 * time.Second
const windowsPipeAccess = windows.FILE_READ_DATA | windows.FILE_WRITE_DATA | windows.SYNCHRONIZE
const windowsRPCPrefix = `\\.\pipe\ReClashCore_`

type windowsLaunch struct {
	pipe, address, session, sid, home string
	parentPID                         uint32
	parentCreated                     uint64
	terminalSession                   uint32
}

type windowsParent struct {
	handle  windows.Handle
	pid     uint32
	created uint64
	home    string
}

func windowsHex(value string, length int) bool {
	return len(value) == length && strings.IndexFunc(value, func(r rune) bool {
		return !(r >= '0' && r <= '9' || r >= 'a' && r <= 'f')
	}) < 0
}

func windowsLocalPath(value string) bool {
	value = strings.TrimPrefix(value, `\\?\`)
	if len(value) <= 3 || !(value[0] >= 'a' && value[0] <= 'z' || value[0] >= 'A' && value[0] <= 'Z') || value[1] != ':' || value[2] != '\\' {
		return false
	}
	for _, component := range strings.Split(value[3:], `\`) {
		if component == "" || component == "." || component == ".." || strings.HasSuffix(component, ".") || strings.HasSuffix(component, " ") || strings.ContainsAny(component, "/:<>|\"?*") || strings.IndexFunc(component, func(r rune) bool { return r < 32 }) >= 0 {
			return false
		}
	}
	return true
}

func validWindowsRPCAddress(address string) bool {
	return strings.HasPrefix(address, windowsRPCPrefix) && windowsHex(strings.TrimPrefix(address, windowsRPCPrefix), 32)
}

func parseWindowsLaunch(args []string) (windowsLaunch, error) {
	var launch windowsLaunch
	if len(args) != 9 || args[0] != "--managed-windows" {
		return launch, errors.New("windows_invalid_managed_arguments")
	}
	pid, pidErr := strconv.ParseUint(args[2], 10, 32)
	created, createdErr := strconv.ParseUint(args[3], 10, 64)
	terminal, terminalErr := strconv.ParseUint(args[5], 10, 32)
	if pidErr != nil || createdErr != nil || terminalErr != nil || pid == 0 || created == 0 {
		return launch, errors.New("windows_invalid_parent_identity")
	}
	if _, err := windows.StringToSid(args[4]); err != nil {
		return launch, fmt.Errorf("windows_invalid_parent_sid: %w", err)
	}
	if !windowsHex(args[7], 32) {
		return launch, errors.New("windows_invalid_session")
	}
	if args[1] != fmt.Sprintf(`\\.\pipe\ReClash.bootstrap.%d.%s`, pid, args[7]) || !validWindowsRPCAddress(args[6]) {
		return launch, errors.New("windows_invalid_pipe_namespace")
	}
	if !windowsLocalPath(args[8]) {
		return launch, errors.New("windows_invalid_home")
	}
	return windowsLaunch{pipe: args[1], address: args[6], sid: args[4], session: args[7], home: filepath.Clean(args[8]),
		parentPID: uint32(pid), parentCreated: created, terminalSession: uint32(terminal)}, nil
}

func windowsProcessCreated(handle windows.Handle) (uint64, error) {
	var created, exited, kernel, user windows.Filetime
	if err := windows.GetProcessTimes(handle, &created, &exited, &kernel, &user); err != nil {
		return 0, err
	}
	return uint64(created.HighDateTime)<<32 | uint64(created.LowDateTime), nil
}

func windowsProcessImage(handle windows.Handle) (string, error) {
	buffer := make([]uint16, 32768)
	size := uint32(len(buffer))
	if err := windows.QueryFullProcessImageName(handle, 0, &buffer[0], &size); err != nil {
		return "", err
	}
	return windows.UTF16ToString(buffer[:size]), nil
}

func verifyWindowsParent(handle windows.Handle, launch windowsLaunch, expectedImage string) error {
	pid, err := windows.GetProcessId(handle)
	if err != nil || pid != launch.parentPID {
		return errors.New("windows_parent_pid_mismatch")
	}
	status, err := windows.WaitForSingleObject(handle, 0)
	if err != nil || status != uint32(windows.WAIT_TIMEOUT) {
		return errors.New("windows_parent_exited")
	}
	created, err := windowsProcessCreated(handle)
	if err != nil || created != launch.parentCreated {
		return errors.New("windows_parent_creation_mismatch")
	}
	var terminal uint32
	if err := windows.ProcessIdToSessionId(launch.parentPID, &terminal); err != nil || terminal != launch.terminalSession {
		return errors.New("windows_parent_session_mismatch")
	}
	if err := windows.ProcessIdToSessionId(uint32(os.Getpid()), &terminal); err != nil || terminal != launch.terminalSession {
		return errors.New("windows_core_session_mismatch")
	}
	var token windows.Token
	if err := windows.OpenProcessToken(handle, windows.TOKEN_QUERY, &token); err != nil {
		return fmt.Errorf("windows_parent_token_unavailable: %w", err)
	}
	defer token.Close()
	user, err := token.GetTokenUser()
	if err != nil || user.User.Sid.String() != launch.sid {
		return errors.New("windows_parent_sid_mismatch")
	}
	image, err := windowsProcessImage(handle)
	if err != nil || !windowsLocalPath(image) || !windowsLocalPath(expectedImage) {
		return errors.New("windows_parent_image_unavailable")
	}
	actual, err := os.Stat(image)
	if err != nil {
		return err
	}
	expected, err := os.Stat(expectedImage)
	if err != nil || !os.SameFile(actual, expected) {
		return errors.New("windows_parent_image_mismatch")
	}
	return nil
}

func windowsPipeServer(connection net.Conn) (uint32, error) {
	file, ok := connection.(interface{ Fd() uintptr })
	if !ok {
		return 0, errors.New("windows_pipe_handle_unavailable")
	}
	var pid uint32
	if err := windows.GetNamedPipeServerProcessId(windows.Handle(file.Fd()), &pid); err != nil {
		return 0, err
	}
	return pid, nil
}

func joinWindowsJob(parent windows.Handle, source uint64) error {
	if source == 0 || uint64(uintptr(source)) != source {
		return errors.New("windows_invalid_job_handle")
	}
	var job windows.Handle
	if err := windows.DuplicateHandle(parent, windows.Handle(source), windows.CurrentProcess(), &job, 0, false, windows.DUPLICATE_SAME_ACCESS); err != nil {
		return fmt.Errorf("windows_job_duplicate_failed: %w", err)
	}
	defer windows.CloseHandle(job)
	var limits windows.JOBOBJECT_EXTENDED_LIMIT_INFORMATION
	if err := windows.QueryInformationJobObject(job, windows.JobObjectExtendedLimitInformation,
		uintptr(unsafe.Pointer(&limits)), uint32(unsafe.Sizeof(limits)), nil); err != nil {
		return fmt.Errorf("windows_job_query_failed: %w", err)
	}
	if limits.BasicLimitInformation.LimitFlags != windows.JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE {
		return errors.New("windows_invalid_job_limits")
	}
	if err := windows.AssignProcessToJobObject(job, windows.CurrentProcess()); err != nil {
		return fmt.Errorf("windows_job_join_failed: %w", err)
	}
	return nil
}

func lockWindowsDirectories(path string, includeSelf bool) ([]windows.Handle, error) {
	if !windowsLocalPath(path) {
		return nil, errors.New("windows_local_path_required")
	}
	var paths []string
	if !includeSelf {
		path = filepath.Dir(path)
	}
	for ; ; path = filepath.Dir(path) {
		paths = append(paths, path)
		if filepath.Dir(path) == path {
			break
		}
	}
	var handles []windows.Handle
	for index := len(paths) - 1; index >= 0; index-- {
		name, err := windows.UTF16PtrFromString(paths[index])
		if err != nil {
			closeWindowsHandles(handles)
			return nil, err
		}
		handle, err := windows.CreateFile(name, windows.FILE_READ_ATTRIBUTES,
			windows.FILE_SHARE_READ|windows.FILE_SHARE_WRITE, nil, windows.OPEN_EXISTING,
			windows.FILE_FLAG_BACKUP_SEMANTICS|windows.FILE_FLAG_OPEN_REPARSE_POINT, 0)
		if err != nil {
			closeWindowsHandles(handles)
			return nil, err
		}
		handles = append(handles, handle)
		var info windows.ByHandleFileInformation
		if err := windows.GetFileInformationByHandle(handle, &info); err != nil {
			closeWindowsHandles(handles)
			return nil, err
		}
		if info.FileAttributes&windows.FILE_ATTRIBUTE_REPARSE_POINT != 0 || info.FileAttributes&windows.FILE_ATTRIBUTE_DIRECTORY == 0 {
			closeWindowsHandles(handles)
			return nil, errors.New("windows_reparse_path_rejected")
		}
	}
	return handles, nil
}

func lockWindowsHome(home string) ([]windows.Handle, error) {
	return lockWindowsDirectories(home, true)
}

func lockWindowsImage(path string) ([]windows.Handle, error) {
	handles, err := lockWindowsDirectories(path, false)
	if err != nil {
		return nil, err
	}
	name, err := windows.UTF16PtrFromString(path)
	if err != nil {
		closeWindowsHandles(handles)
		return nil, err
	}
	handle, err := windows.CreateFile(name, windows.FILE_READ_ATTRIBUTES|windows.FILE_READ_DATA,
		windows.FILE_SHARE_READ, nil, windows.OPEN_EXISTING, windows.FILE_FLAG_OPEN_REPARSE_POINT, 0)
	if err != nil {
		closeWindowsHandles(handles)
		return nil, err
	}
	handles = append(handles, handle)
	var info windows.ByHandleFileInformation
	if err := windows.GetFileInformationByHandle(handle, &info); err != nil {
		closeWindowsHandles(handles)
		return nil, err
	}
	if info.FileAttributes&(windows.FILE_ATTRIBUTE_REPARSE_POINT|windows.FILE_ATTRIBUTE_DIRECTORY) != 0 {
		closeWindowsHandles(handles)
		return nil, errors.New("windows_reparse_image_rejected")
	}
	return handles, nil
}

func closeWindowsHandles(handles []windows.Handle) {
	for index := len(handles) - 1; index >= 0; index-- {
		_ = windows.CloseHandle(handles[index])
	}
}

type windowsTokenAccess struct {
	token      windows.Token
	descriptor *windows.SECURITY_DESCRIPTOR
	acl        *windows.ACL
	protection windows.SECURITY_INFORMATION
	restored   bool
}

func captureWindowsTokenAccess() (*windowsTokenAccess, error) {
	var token windows.Token
	if err := windows.OpenProcessToken(windows.CurrentProcess(), windows.TOKEN_QUERY|windows.READ_CONTROL|windows.WRITE_DAC, &token); err != nil {
		return nil, err
	}
	descriptor, err := windows.GetSecurityInfo(windows.Handle(token), windows.SE_KERNEL_OBJECT, windows.DACL_SECURITY_INFORMATION)
	if err != nil {
		token.Close()
		return nil, err
	}
	acl, _, err := descriptor.DACL()
	if err != nil {
		token.Close()
		return nil, err
	}
	control, _, err := descriptor.Control()
	if err != nil {
		token.Close()
		return nil, err
	}
	protection := windows.SECURITY_INFORMATION(windows.UNPROTECTED_DACL_SECURITY_INFORMATION)
	if control&windows.SE_DACL_PROTECTED != 0 {
		protection = windows.PROTECTED_DACL_SECURITY_INFORMATION
	}
	return &windowsTokenAccess{token: token, descriptor: descriptor, acl: acl, protection: protection, restored: true}, nil
}

func (access *windowsTokenAccess) grant(sid string) error {
	if access.acl == nil {
		return nil
	}
	owner, err := windows.StringToSid(sid)
	if err != nil {
		return err
	}
	var pin runtime.Pinner
	pin.Pin(owner)
	defer pin.Unpin()
	acl, err := windows.ACLFromEntries([]windows.EXPLICIT_ACCESS{{AccessPermissions: windows.TOKEN_QUERY,
		AccessMode: windows.GRANT_ACCESS, Trustee: windows.TRUSTEE{TrusteeForm: windows.TRUSTEE_IS_SID,
			TrusteeType: windows.TRUSTEE_IS_USER, TrusteeValue: windows.TrusteeValueFromSID(owner)}}}, access.acl)
	if err != nil {
		return err
	}
	access.restored = false
	return windows.SetSecurityInfo(windows.Handle(access.token), windows.SE_KERNEL_OBJECT,
		windows.DACL_SECURITY_INFORMATION|access.protection, nil, nil, acl, nil)
}

func (access *windowsTokenAccess) restore() error {
	if access.restored {
		return nil
	}
	if err := windows.SetSecurityInfo(windows.Handle(access.token), windows.SE_KERNEL_OBJECT,
		windows.DACL_SECURITY_INFORMATION|access.protection, nil, nil, access.acl, nil); err != nil {
		return err
	}
	access.restored = true
	return nil
}

func (access *windowsTokenAccess) close() error {
	if err := access.restore(); err != nil {
		return err
	}
	return access.token.Close()
}

func prepareDesktopStartup(args []string) (string, func(), error) {
	if len(args) == 1 && validWindowsRPCAddress(args[0]) {
		if windows.GetCurrentProcessToken().IsElevated() {
			return "", nil, errors.New("windows_elevated_core_requires_managed_session")
		}
		if err := core.ConfigureDesktopLaunch("", verifyWindowsRPCServer); err != nil {
			return "", nil, err
		}
		return args[0], func() {}, nil
	}
	launch, err := parseWindowsLaunch(args)
	if err != nil {
		return "", nil, err
	}
	if !windows.GetCurrentProcessToken().IsElevated() {
		return "", nil, errors.New("windows_managed_core_not_elevated")
	}
	created, err := windowsProcessCreated(windows.CurrentProcess())
	if err != nil {
		return "", nil, err
	}
	started := windows.Filetime{LowDateTime: uint32(created), HighDateTime: uint32(created >> 32)}
	deadline := time.Unix(0, started.Nanoseconds()).Add(windowsBootstrapTimeout)
	if !time.Now().Before(deadline) {
		return "", nil, errors.New("windows_bootstrap_expired")
	}
	watchdog := time.AfterFunc(time.Until(deadline), func() { os.Exit(1) })
	defer watchdog.Stop()
	parent, err := windows.OpenProcess(windows.PROCESS_QUERY_LIMITED_INFORMATION|windows.PROCESS_DUP_HANDLE|windows.SYNCHRONIZE, false, launch.parentPID)
	if err != nil {
		return "", nil, fmt.Errorf("windows_parent_open_failed: %w", err)
	}
	var handles []windows.Handle
	keepParent := false
	defer func() {
		if !keepParent {
			_ = windows.CloseHandle(parent)
			closeWindowsHandles(handles)
		}
	}()
	executable, err := os.Executable()
	if err != nil || !strings.EqualFold(filepath.Base(executable), "ReClashCore.exe") {
		return "", nil, errors.New("windows_core_image_mismatch")
	}
	app := filepath.Join(filepath.Dir(executable), "ReClash.exe")
	for _, image := range []string{app, executable} {
		locked, err := lockWindowsImage(image)
		if err != nil {
			return "", nil, fmt.Errorf("windows_image_pin_failed: %w", err)
		}
		handles = append(handles, locked...)
	}
	if err := verifyWindowsParent(parent, launch, app); err != nil {
		return "", nil, err
	}
	ctx, cancel := context.WithDeadline(context.Background(), deadline)
	defer cancel()
	pipe, err := winio.DialPipeAccessImpLevel(ctx, launch.pipe, windowsPipeAccess, winio.PipeImpLevelIdentification)
	if err != nil {
		return "", nil, fmt.Errorf("windows_bootstrap_connect_failed: %w", err)
	}
	defer pipe.Close()
	if pid, err := windowsPipeServer(pipe); err != nil || pid != launch.parentPID {
		return "", nil, errors.New("windows_bootstrap_server_mismatch")
	}
	if err := pipe.SetDeadline(deadline); err != nil {
		return "", nil, err
	}
	access, err := captureWindowsTokenAccess()
	if err != nil {
		return "", nil, err
	}
	defer access.close()
	if err := access.grant(launch.sid); err != nil {
		return "", nil, err
	}
	hello := append([]byte("RCXWIN01"), make([]byte, 8)...)
	binary.LittleEndian.PutUint64(hello[8:], created)
	if _, err := pipe.Write(hello); err != nil {
		return "", nil, err
	}
	var source [8]byte
	if _, err := io.ReadFull(pipe, source[:]); err != nil {
		return "", nil, err
	}
	if err := joinWindowsJob(parent, binary.LittleEndian.Uint64(source[:])); err != nil {
		return "", nil, err
	}
	homeHandles, err := lockWindowsHome(launch.home)
	if err != nil {
		return "", nil, fmt.Errorf("windows_home_pin_failed: %w", err)
	}
	handles = append(handles, homeHandles...)
	if err := access.restore(); err != nil {
		return "", nil, fmt.Errorf("windows_acl_restore_failed: %w", err)
	}
	if _, err := pipe.Write([]byte("RCXJOIN1")); err != nil {
		return "", nil, err
	}
	var commit [8]byte
	if _, err := io.ReadFull(pipe, commit[:]); err != nil {
		return "", nil, err
	}
	if string(commit[:]) != "RCXGO001" {
		return "", nil, errors.New("windows_launch_not_committed")
	}
	identity := &windowsParent{handle: parent, pid: launch.parentPID, created: launch.parentCreated, home: launch.home}
	if err := core.ConfigureDesktopLaunch(launch.home, windowsRPCVerifier(identity)); err != nil {
		return "", nil, err
	}
	keepParent = true
	stop, done := make(chan struct{}), make(chan struct{})
	go func() {
		defer close(done)
		for {
			select {
			case <-stop:
				return
			default:
			}
			status, err := windows.WaitForSingleObject(parent, 100)
			if err != nil || status != uint32(windows.WAIT_TIMEOUT) {
				os.Exit(1)
			}
		}
	}()
	var cleanup sync.Once
	return launch.address, func() {
		cleanup.Do(func() {
			close(stop)
			<-done
			_ = windows.CloseHandle(parent)
			closeWindowsHandles(handles)
		})
	}, nil
}

func windowsRPCVerifier(parent *windowsParent) func(net.Conn) error {
	return func(connection net.Conn) error {
		pid, err := windowsPipeServer(connection)
		if err != nil {
			return err
		}
		status, err := windows.WaitForSingleObject(parent.handle, 0)
		if err != nil || status != uint32(windows.WAIT_TIMEOUT) || pid != parent.pid {
			return errors.New("windows_rpc_server_mismatch")
		}
		created, err := windowsProcessCreated(parent.handle)
		if err != nil || created != parent.created {
			return errors.New("windows_rpc_parent_mismatch")
		}
		return nil
	}
}

func verifyWindowsRPCServer(connection net.Conn) error {
	pid, err := windowsPipeServer(connection)
	if err != nil {
		return err
	}
	parent, err := windows.OpenProcess(windows.PROCESS_QUERY_LIMITED_INFORMATION|windows.SYNCHRONIZE, false, pid)
	if err != nil {
		return err
	}
	defer windows.CloseHandle(parent)
	created, err := windowsProcessCreated(parent)
	if err != nil {
		return err
	}
	user, err := windows.GetCurrentProcessToken().GetTokenUser()
	if err != nil {
		return err
	}
	var terminal uint32
	if err := windows.ProcessIdToSessionId(uint32(os.Getpid()), &terminal); err != nil {
		return err
	}
	executable, err := os.Executable()
	if err != nil {
		return err
	}
	return verifyWindowsParent(parent, windowsLaunch{parentPID: pid, parentCreated: created, terminalSession: terminal, sid: user.User.Sid.String()},
		filepath.Join(filepath.Dir(executable), "ReClash.exe"))
}
