//go:build windows && !(android && cgo)

package main

import (
	"context"
	"encoding/binary"
	"errors"
	"fmt"
	"io"
	"net"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"time"
	"unsafe"

	"github.com/Microsoft/go-winio"
	"golang.org/x/sys/windows"
)

const windowsBootstrapTimeout = 10 * time.Second
const windowsPipeAccess = windows.FILE_READ_DATA | windows.FILE_WRITE_DATA | windows.SYNCHRONIZE

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

var managedWindowsParent *windowsParent

func parseWindowsLaunch(args []string) (windowsLaunch, error) {
	var launch windowsLaunch
	if len(args) != 9 || args[0] != "--managed-windows" {
		return launch, errors.New("invalid managed Windows arguments")
	}
	pid, pidErr := strconv.ParseUint(args[2], 10, 32)
	created, createdErr := strconv.ParseUint(args[3], 10, 64)
	terminal, terminalErr := strconv.ParseUint(args[5], 10, 32)
	if pidErr != nil || createdErr != nil || terminalErr != nil || pid == 0 || created == 0 {
		return launch, errors.New("invalid Windows parent identity")
	}
	if _, err := windows.StringToSid(args[4]); err != nil {
		return launch, fmt.Errorf("invalid Windows parent SID: %w", err)
	}
	if len(args[7]) != 32 || strings.IndexFunc(args[7], func(r rune) bool {
		return !(r >= '0' && r <= '9' || r >= 'a' && r <= 'f')
	}) >= 0 {
		return launch, errors.New("invalid Windows launch session")
	}
	if args[1] != fmt.Sprintf(`\\.\pipe\ReClash.bootstrap.%d.%s`, pid, args[7]) ||
		!strings.HasPrefix(args[6], `\\.\pipe\ReClashCore_`) || strings.ContainsRune(args[6], 0) {
		return launch, errors.New("invalid Windows pipe name")
	}
	if !filepath.IsAbs(args[8]) || filepath.VolumeName(args[8]) == "" || strings.HasPrefix(args[8], `\\`) ||
		strings.ContainsRune(args[8], 0) || filepath.Clean(args[8]) == filepath.VolumeName(args[8])+`\` {
		return launch, errors.New("invalid Windows user data directory")
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
		return errors.New("Windows parent PID mismatch")
	}
	status, err := windows.WaitForSingleObject(handle, 0)
	if err != nil || status != uint32(windows.WAIT_TIMEOUT) {
		return errors.New("Windows parent has exited")
	}
	created, err := windowsProcessCreated(handle)
	if err != nil || created != launch.parentCreated {
		return errors.New("Windows parent creation identity mismatch")
	}
	var terminal uint32
	if err := windows.ProcessIdToSessionId(launch.parentPID, &terminal); err != nil || terminal != launch.terminalSession {
		return errors.New("Windows parent terminal session mismatch")
	}
	if err := windows.ProcessIdToSessionId(uint32(os.Getpid()), &terminal); err != nil || terminal != launch.terminalSession {
		return errors.New("Windows Core terminal session mismatch")
	}
	var token windows.Token
	if err := windows.OpenProcessToken(handle, windows.TOKEN_QUERY, &token); err != nil {
		return fmt.Errorf("query Windows parent token: %w", err)
	}
	defer token.Close()
	user, err := token.GetTokenUser()
	if err != nil || user.User.Sid.String() != launch.sid {
		return errors.New("Windows parent user mismatch")
	}
	image, err := windowsProcessImage(handle)
	if err != nil {
		return err
	}
	actual, err := os.Stat(image)
	if err != nil {
		return err
	}
	expected, err := os.Stat(expectedImage)
	if err != nil || !os.SameFile(actual, expected) {
		return errors.New("Windows parent executable mismatch")
	}
	return nil
}

func windowsPipeServer(connection net.Conn) (uint32, error) {
	file, ok := connection.(interface{ Fd() uintptr })
	if !ok {
		return 0, errors.New("Windows pipe handle unavailable")
	}
	var pid uint32
	if err := windows.GetNamedPipeServerProcessId(windows.Handle(file.Fd()), &pid); err != nil {
		return 0, err
	}
	return pid, nil
}

func joinWindowsJob(parent windows.Handle, source uint64) error {
	if source == 0 || uint64(uintptr(source)) != source {
		return errors.New("invalid Windows job handle")
	}
	var job windows.Handle
	if err := windows.DuplicateHandle(parent, windows.Handle(source), windows.CurrentProcess(), &job, 0, false, windows.DUPLICATE_SAME_ACCESS); err != nil {
		return fmt.Errorf("duplicate Windows job: %w", err)
	}
	defer windows.CloseHandle(job)
	var limits windows.JOBOBJECT_EXTENDED_LIMIT_INFORMATION
	if err := windows.QueryInformationJobObject(job, windows.JobObjectExtendedLimitInformation,
		uintptr(unsafe.Pointer(&limits)), uint32(unsafe.Sizeof(limits)), nil); err != nil {
		return fmt.Errorf("query Windows job: %w", err)
	}
	if limits.BasicLimitInformation.LimitFlags != windows.JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE {
		return errors.New("Windows job must use kill-on-close only")
	}
	if err := windows.AssignProcessToJobObject(job, windows.CurrentProcess()); err != nil {
		return fmt.Errorf("join Windows job: %w", err)
	}
	return nil
}

func lockWindowsHome(home string) ([]windows.Handle, error) {
	var handles []windows.Handle
	closeHandles := func() {
		for _, handle := range handles {
			windows.CloseHandle(handle)
		}
	}
	for path := home; ; path = filepath.Dir(path) {
		name, err := windows.UTF16PtrFromString(path)
		if err != nil {
			closeHandles()
			return nil, err
		}
		handle, err := windows.CreateFile(name, windows.FILE_READ_ATTRIBUTES,
			windows.FILE_SHARE_READ|windows.FILE_SHARE_WRITE, nil, windows.OPEN_EXISTING,
			windows.FILE_FLAG_BACKUP_SEMANTICS|windows.FILE_FLAG_OPEN_REPARSE_POINT, 0)
		if err != nil {
			closeHandles()
			return nil, err
		}
		handles = append(handles, handle)
		var info windows.ByHandleFileInformation
		if err := windows.GetFileInformationByHandle(handle, &info); err != nil {
			closeHandles()
			return nil, err
		}
		if info.FileAttributes&windows.FILE_ATTRIBUTE_REPARSE_POINT != 0 || info.FileAttributes&windows.FILE_ATTRIBUTE_DIRECTORY == 0 {
			closeHandles()
			return nil, errors.New("Windows user data path contains a reparse point")
		}
		if filepath.Dir(path) == path {
			break
		}
	}
	return handles, nil
}

func prepareDesktopStartup(args []string) (string, func(), error) {
	if len(args) < 2 {
		return "", nil, errors.New("arguments error")
	}
	if len(args) == 2 && !strings.HasPrefix(args[1], "--") {
		if windows.GetCurrentProcessToken().IsElevated() {
			return "", nil, errors.New("elevated Windows Core requires a managed session")
		}
		return args[1], func() {}, nil
	}
	launch, err := parseWindowsLaunch(args[1:])
	if err != nil {
		return "", nil, err
	}
	if !windows.GetCurrentProcessToken().IsElevated() {
		return "", nil, errors.New("managed Windows Core is not elevated")
	}
	created, err := windowsProcessCreated(windows.CurrentProcess())
	if err != nil {
		return "", nil, err
	}
	started := windows.Filetime{LowDateTime: uint32(created), HighDateTime: uint32(created >> 32)}
	deadline := time.Unix(0, started.Nanoseconds()).Add(windowsBootstrapTimeout)
	if !time.Now().Before(deadline) {
		return "", nil, errors.New("Windows bootstrap expired")
	}
	watchdog := time.AfterFunc(time.Until(deadline), func() { os.Exit(1) })
	defer watchdog.Stop()
	parent, err := windows.OpenProcess(windows.PROCESS_QUERY_LIMITED_INFORMATION|windows.PROCESS_DUP_HANDLE|windows.SYNCHRONIZE, false, launch.parentPID)
	if err != nil {
		return "", nil, fmt.Errorf("open Windows parent: %w", err)
	}
	var homeHandles []windows.Handle
	keepParent := false
	defer func() {
		if !keepParent {
			windows.CloseHandle(parent)
			for _, handle := range homeHandles {
				windows.CloseHandle(handle)
			}
		}
	}()
	executable, err := os.Executable()
	if err != nil {
		return "", nil, err
	}
	if err := verifyWindowsParent(parent, launch, filepath.Join(filepath.Dir(executable), "ReClash.exe")); err != nil {
		return "", nil, err
	}
	ctx, cancel := context.WithDeadline(context.Background(), deadline)
	defer cancel()
	pipe, err := winio.DialPipeAccessImpLevel(ctx, launch.pipe, windowsPipeAccess, winio.PipeImpLevelIdentification)
	if err != nil {
		return "", nil, fmt.Errorf("connect Windows bootstrap: %w", err)
	}
	defer pipe.Close()
	if pid, err := windowsPipeServer(pipe); err != nil || pid != launch.parentPID {
		return "", nil, errors.New("Windows bootstrap server mismatch")
	}
	if err := pipe.SetDeadline(deadline); err != nil {
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
	homeHandles, err = lockWindowsHome(launch.home)
	if err != nil {
		return "", nil, fmt.Errorf("pin Windows user data directory: %w", err)
	}
	if _, err := pipe.Write([]byte("RCXJOIN1")); err != nil {
		return "", nil, err
	}
	var commit [8]byte
	if _, err := io.ReadFull(pipe, commit[:]); err != nil {
		return "", nil, err
	}
	if string(commit[:]) != "RCXGO001" {
		return "", nil, errors.New("Windows launch was not committed")
	}
	managedWindowsParent = &windowsParent{handle: parent, pid: launch.parentPID, created: launch.parentCreated, home: launch.home}
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
	return launch.address, func() {
		close(stop)
		<-done
		windows.CloseHandle(parent)
		for _, handle := range homeHandles {
			windows.CloseHandle(handle)
		}
	}, nil
}

func permittedCoreHome(home string) bool {
	parent := managedWindowsParent
	return parent == nil || strings.EqualFold(filepath.Clean(home), parent.home)
}

func verifyWindowsRPCServer(connection net.Conn) error {
	pid, err := windowsPipeServer(connection)
	if err != nil {
		return err
	}
	if parent := managedWindowsParent; parent != nil {
		status, err := windows.WaitForSingleObject(parent.handle, 0)
		if err != nil || status != uint32(windows.WAIT_TIMEOUT) || pid != parent.pid {
			return errors.New("managed Windows RPC server mismatch")
		}
		created, err := windowsProcessCreated(parent.handle)
		if err != nil || created != parent.created {
			return errors.New("managed Windows RPC parent mismatch")
		}
		return nil
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
