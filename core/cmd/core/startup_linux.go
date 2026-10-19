//go:build linux && !android

package main

import (
	"core"
	"errors"
	"fmt"
	"net"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"syscall"
)

const linuxCoreSocketPrefix = "/tmp/ReClashSocket_"
const linuxCoreSocketSuffix = ".sock"
const prCapAmbient = 47
const prCapAmbientClearAll = 4

func prepareDesktopStartup(args []string) (string, func(), error) {
	if err := validateLinuxCredentials(os.Getuid(), os.Geteuid(), os.Getgid(), os.Getegid()); err != nil {
		return "", nil, err
	}
	if len(args) != 1 || !validLinuxCoreAddress(args[0]) {
		return "", nil, errors.New("expected one current ReClash Core socket address")
	}
	uid := os.Getuid()
	if err := validateLinuxCoreSocket(args[0], uid); err != nil {
		return "", nil, err
	}
	if err := clearLinuxAmbientCapabilities(); err != nil {
		return "", nil, err
	}
	if err := core.ConfigureDesktopLaunch("", func(connection net.Conn) error {
		return verifyLinuxDesktopPeer(connection, uid)
	}); err != nil {
		return "", nil, err
	}
	return args[0], func() {}, nil
}

func validateLinuxCredentials(uid, euid, gid, egid int) error {
	if uid == 0 || euid == 0 || uid != euid || gid != egid {
		return errors.New("Linux Core must run as its non-root owner, never root or setuid")
	}
	return nil
}

func validLinuxCoreAddress(address string) bool {
	if filepath.Clean(address) != address || !strings.HasPrefix(address, linuxCoreSocketPrefix) || !strings.HasSuffix(address, linuxCoreSocketSuffix) {
		return false
	}
	digits := strings.TrimSuffix(strings.TrimPrefix(address, linuxCoreSocketPrefix), linuxCoreSocketSuffix)
	if len(digits) == 0 || len(digits) > 10 {
		return false
	}
	for _, digit := range digits {
		if digit < '0' || digit > '9' {
			return false
		}
	}
	_, err := strconv.ParseUint(digits, 10, 32)
	return err == nil
}

func validateLinuxCoreSocket(address string, uid int) error {
	info, err := os.Lstat(address)
	if err != nil {
		return fmt.Errorf("inspect Core socket: %w", err)
	}
	stat, ok := info.Sys().(*syscall.Stat_t)
	if !ok || info.Mode()&os.ModeSocket == 0 || info.Mode().Perm()&0077 != 0 || stat.Uid != uint32(uid) {
		return errors.New("Core address must be a private Unix socket owned by the current user")
	}
	return nil
}

func clearLinuxAmbientCapabilities() error {
	// Ambient state is per-thread: a single prctl would leave Go exec workers privileged.
	_, _, errno := syscall.AllThreadsSyscall6(syscall.SYS_PRCTL, prCapAmbient, prCapAmbientClearAll, 0, 0, 0, 0)
	if errno != 0 {
		return fmt.Errorf("clear ambient capabilities on all Core threads: %w", errno)
	}
	return nil
}

func verifyLinuxDesktopPeer(connection net.Conn, uid int) error {
	unix, ok := connection.(*net.UnixConn)
	if !ok {
		return errors.New("Linux Core IPC requires a Unix socket")
	}
	raw, err := unix.SyscallConn()
	if err != nil {
		return err
	}
	var credentials *syscall.Ucred
	var credentialErr error
	if err := raw.Control(func(fd uintptr) {
		credentials, credentialErr = syscall.GetsockoptUcred(int(fd), syscall.SOL_SOCKET, syscall.SO_PEERCRED)
	}); err != nil {
		return err
	}
	if credentialErr != nil {
		return credentialErr
	}
	if credentials == nil || credentials.Uid != uint32(uid) || credentials.Pid <= 0 {
		return errors.New("Linux Core IPC peer does not belong to the current owner")
	}
	return nil
}
