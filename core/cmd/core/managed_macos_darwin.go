//go:build darwin

package main

import (
	"bufio"
	"bytes"
	"core"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net"
	"os"
	"path/filepath"
	"sync"
	"syscall"
	"time"

	"golang.org/x/sys/unix"
)

func prepareDesktopStartup(args []string) (string, func(), error) {
	if len(args) == 1 && args[0] != "" {
		if os.Geteuid() == 0 {
			return "", nil, errors.New("direct root or setuid Core is forbidden; use the signed managed macOS Helper")
		}
		return args[0], func() {}, nil
	}
	if len(args) != 3 || args[0] != "--reclash-macos-managed" || args[1] != "--bootstrap-fd" || args[2] != "3" {
		return "", nil, errors.New("invalid managed macOS Core arguments")
	}
	if os.Geteuid() != 0 || os.Getuid() == 0 {
		return "", nil, errors.New("managed macOS Core requires the authenticated client real UID and Helper effective UID")
	}
	if err := verifyMacOSParent(3); err != nil {
		return "", nil, err
	}
	file := os.NewFile(3, "ReClash managed lifetime")
	if file == nil {
		return "", nil, errors.New("managed macOS lifetime descriptor is missing")
	}
	connection, err := net.FileConn(file)
	file.Close()
	if err != nil {
		return "", nil, err
	}
	var closeOnce sync.Once
	cleanup := func() { closeOnce.Do(func() { connection.Close() }) }
	failed := true
	defer func() {
		if failed {
			cleanup()
		}
	}()
	if err := connection.SetReadDeadline(time.Now().Add(5 * time.Second)); err != nil {
		return "", nil, err
	}
	reader := bufio.NewReaderSize(connection, macOSBootstrapLimit+1)
	line, err := reader.ReadSlice('\n')
	if err != nil || len(line) > macOSBootstrapLimit {
		return "", nil, errors.New("managed macOS bootstrap is missing or exceeds the size limit")
	}
	bootstrap, err := readMacOSBootstrap(bytes.NewReader(line))
	if err != nil {
		return "", nil, err
	}
	if bootstrap.OwnerUID != uint32(os.Getuid()) || bootstrap.OwnerGID != uint32(os.Getgid()) {
		return "", nil, errors.New("managed macOS bootstrap does not match inherited client credentials")
	}
	if err := verifyMacOSHome(bootstrap); err != nil {
		return "", nil, err
	}
	if err := verifyMacOSSocket(bootstrap.Address, bootstrap.OwnerUID); err != nil {
		return "", nil, err
	}
	if err := core.ConfigureDesktopLaunch(bootstrap.HomeDir, func(peer net.Conn) error {
		return verifyMacOSRPCPeer(peer, bootstrap.OwnerUID, bootstrap.ClientPID)
	}); err != nil {
		return "", nil, err
	}
	if err := connection.SetDeadline(time.Now().Add(5 * time.Second)); err != nil {
		return "", nil, err
	}
	if err := json.NewEncoder(connection).Encode(map[string]any{
		"version": 1, "ready": true, "sessionId": bootstrap.SessionID, "pid": os.Getpid(),
	}); err != nil {
		return "", nil, err
	}
	if err := connection.SetDeadline(time.Time{}); err != nil {
		return "", nil, err
	}
	failed = false
	go func() {
		_, _ = io.Copy(io.Discard, reader)
		_ = syscall.Kill(os.Getpid(), syscall.SIGTERM)
	}()
	return bootstrap.Address, cleanup, nil
}

func verifyMacOSParent(fd int) error {
	var mode unix.Stat_t
	if err := unix.Fstat(fd, &mode); err != nil || mode.Mode&unix.S_IFMT != unix.S_IFSOCK {
		return errors.New("managed macOS bootstrap descriptor is not a socket")
	}
	credential, err := unix.GetsockoptXucred(fd, unix.SOL_LOCAL, unix.LOCAL_PEERCRED)
	if err != nil || credential.Version != 0 || credential.Uid != 0 {
		return errors.New("managed macOS bootstrap parent is not root")
	}
	pid, err := unix.GetsockoptInt(fd, unix.SOL_LOCAL, unix.LOCAL_PEERPID)
	if err != nil || pid <= 1 || pid != os.Getppid() {
		return errors.New("managed macOS bootstrap peer does not match the process parent")
	}
	return nil
}

func verifyMacOSHome(bootstrap macOSBootstrap) error {
	for _, path := range []string{bootstrap.AccountHome, bootstrap.HomeDir} {
		canonical, err := filepath.EvalSymlinks(path)
		if err != nil || canonical != path {
			return errors.New("managed macOS home has a symbolic link")
		}
		info, err := os.Lstat(path)
		if err != nil || !info.IsDir() || info.Mode().Perm()&0022 != 0 {
			return errors.New("managed macOS home permissions are invalid")
		}
		stat, ok := info.Sys().(*syscall.Stat_t)
		if !ok || stat.Uid != bootstrap.OwnerUID {
			return errors.New("managed macOS home is not owned by the authenticated client")
		}
	}
	executable, err := os.Executable()
	if err != nil || executable != bootstrap.CorePath {
		return errors.New("managed macOS Core executable differs from the authenticated fixed path")
	}
	return nil
}

func verifyMacOSSocket(address string, uid uint32) error {
	if !macOSSocketPattern.MatchString(address) {
		return errors.New("invalid managed macOS Core socket namespace")
	}
	info, err := os.Lstat("/private" + address)
	if err != nil || info.Mode()&os.ModeSocket == 0 || info.Mode().Perm() != 0600 {
		return errors.New("managed macOS Core socket must be private")
	}
	stat, ok := info.Sys().(*syscall.Stat_t)
	if !ok || stat.Uid != uid {
		return errors.New("managed macOS Core socket owner differs from the signed client")
	}
	return nil
}

func verifyMacOSRPCPeer(connection net.Conn, uid uint32, expectedPID int) error {
	peer, ok := connection.(*net.UnixConn)
	if !ok {
		return errors.New("managed macOS Core only accepts a Unix RPC peer")
	}
	raw, err := peer.SyscallConn()
	if err != nil {
		return err
	}
	var identityError error
	err = raw.Control(func(fd uintptr) {
		credential, peerError := unix.GetsockoptXucred(int(fd), unix.SOL_LOCAL, unix.LOCAL_PEERCRED)
		if peerError != nil || credential.Version != 0 || credential.Uid != uid {
			identityError = errors.New("managed macOS RPC effective UID differs from the signed client")
			return
		}
		pid, peerError := unix.GetsockoptInt(int(fd), unix.SOL_LOCAL, unix.LOCAL_PEEREPID)
		if peerError != nil || pid != expectedPID {
			identityError = fmt.Errorf("managed macOS RPC peer PID differs from the authenticated client: %d", pid)
		}
	})
	if err != nil {
		return err
	}
	return identityError
}
