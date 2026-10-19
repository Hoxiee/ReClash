//go:build linux && !android

package main

import (
	"fmt"
	"net"
	"os"
	"runtime"
	"strconv"
	"strings"
	"sync"
	"syscall"
	"testing"
)

func TestLinuxStartupRejectsRootAndSetuid(t *testing.T) {
	for _, credentials := range [][4]int{{0, 0, 0, 0}, {1000, 0, 1000, 1000}, {0, 1000, 1000, 1000}, {1000, 1001, 1000, 1000}, {1000, 1000, 1000, 0}} {
		if err := validateLinuxCredentials(credentials[0], credentials[1], credentials[2], credentials[3]); err == nil {
			t.Fatalf("accepted privileged credentials %v", credentials)
		}
	}
	if err := validateLinuxCredentials(1000, 1000, 1000, 1000); err != nil {
		t.Fatal(err)
	}
}

func TestLinuxStartupAcceptsOnlyCurrentCoreSocketNamespace(t *testing.T) {
	for _, address := range []string{"/tmp/ReClashSocket_0.sock", "/tmp/ReClashSocket_4821.sock"} {
		if !validLinuxCoreAddress(address) {
			t.Fatalf("rejected current namespace %s", address)
		}
	}
	for _, address := range []string{"", "127.0.0.1:9090", "9090", "/tmp/ReClashSocket_.sock", "/tmp/ReClashSocket_4821", "/tmp/ReClashSocket_../evil.sock", "/tmp/Other_4821.sock", "/tmp/ReClashSocket_4294967296.sock", "/tmp/ReClashSocket_+1.sock", "/tmp/ReClashSocket_abc.sock"} {
		if validLinuxCoreAddress(address) {
			t.Fatalf("accepted invalid Core address %s", address)
		}
	}
	for _, arguments := range [][]string{nil, {}, {"/tmp/ReClashSocket_1.sock", "--exec", "/bin/sh"}, {"9090"}} {
		if _, cleanup, err := prepareDesktopStartup(arguments); err == nil || cleanup != nil {
			t.Fatalf("accepted invalid startup arguments %v", arguments)
		}
	}
}

func TestLinuxSocketMustBePrivateAndOwnerMatched(t *testing.T) {
	path := t.TempDir() + "/socket"
	listener, err := net.ListenUnix("unix", &net.UnixAddr{Name: path, Net: "unix"})
	if err != nil {
		t.Fatal(err)
	}
	defer listener.Close()
	if err := os.Chmod(path, 0600); err != nil {
		t.Fatal(err)
	}
	if err := validateLinuxCoreSocket(path, os.Getuid()); err != nil {
		t.Fatal(err)
	}
	if err := validateLinuxCoreSocket(path, os.Getuid()+1); err == nil {
		t.Fatal("accepted another owner's socket")
	}
	if err := os.Chmod(path, 0660); err != nil {
		t.Fatal(err)
	}
	if err := validateLinuxCoreSocket(path, os.Getuid()); err == nil {
		t.Fatal("accepted group-accessible socket")
	}
	link := t.TempDir() + "/link"
	if err := os.Symlink(path, link); err != nil {
		t.Fatal(err)
	}
	if err := validateLinuxCoreSocket(link, os.Getuid()); err == nil {
		t.Fatal("followed socket symlink")
	}
}

func TestLinuxDesktopPeerHasCurrentOwnerIdentity(t *testing.T) {
	path := t.TempDir() + "/socket"
	listener, err := net.ListenUnix("unix", &net.UnixAddr{Name: path, Net: "unix"})
	if err != nil {
		t.Fatal(err)
	}
	defer listener.Close()
	connection, err := net.DialUnix("unix", nil, &net.UnixAddr{Name: path, Net: "unix"})
	if err != nil {
		t.Fatal(err)
	}
	defer connection.Close()
	if err := verifyLinuxDesktopPeer(connection, os.Getuid()); err != nil {
		t.Fatal(err)
	}
	if err := verifyLinuxDesktopPeer(connection, os.Getuid()+1); err == nil {
		t.Fatal("accepted mismatched IPC peer UID")
	}
	left, right := net.Pipe()
	defer left.Close()
	defer right.Close()
	if err := verifyLinuxDesktopPeer(left, os.Getuid()); err == nil {
		t.Fatal("accepted non-Unix IPC")
	}
}

func TestLinuxAmbientClearReachesEveryRuntimeThread(t *testing.T) {
	var workers sync.WaitGroup
	ready := make(chan struct{}, 8)
	release := make(chan struct{})
	for range 8 {
		workers.Add(1)
		go func() {
			defer workers.Done()
			runtime.LockOSThread()
			defer runtime.UnlockOSThread()
			ready <- struct{}{}
			<-release
		}()
	}
	for range 8 {
		<-ready
	}
	defer func() { close(release); workers.Wait() }()
	before := linuxThreadCapabilities(t)
	if err := clearLinuxAmbientCapabilities(); err != nil {
		t.Fatal(err)
	}
	after := linuxThreadCapabilities(t)
	for tid, caps := range after {
		if caps["CapAmb"] != 0 {
			t.Fatalf("thread %s retained ambient capabilities %x", tid, caps["CapAmb"])
		}
		if prior, found := before[tid]; found && prior["CapEff"] != caps["CapEff"] {
			t.Fatalf("clearing ambient changed effective caps on thread %s", tid)
		}
	}
}

func linuxThreadCapabilities(t *testing.T) map[string]map[string]uint64 {
	t.Helper()
	threads, err := os.ReadDir("/proc/self/task")
	if err != nil {
		t.Fatal(err)
	}
	result := make(map[string]map[string]uint64)
	for _, thread := range threads {
		status, err := os.ReadFile(fmt.Sprintf("/proc/self/task/%s/status", thread.Name()))
		if err != nil {
			if os.IsNotExist(err) {
				continue
			}
			t.Fatal(err)
		}
		caps := make(map[string]uint64)
		for _, line := range strings.Split(string(status), "\n") {
			for _, name := range []string{"CapEff", "CapAmb"} {
				if value, found := strings.CutPrefix(line, name+":"); found {
					capabilities, err := strconv.ParseUint(strings.TrimSpace(value), 16, 64)
					if err != nil {
						t.Fatal(err)
					}
					caps[name] = capabilities
				}
			}
		}
		result[thread.Name()] = caps
	}
	return result
}

func TestLinuxStartupUsesValidatedSocket(t *testing.T) {
	if os.Getuid() == 0 || os.Getuid() != os.Geteuid() {
		t.Skip("test process does not have ordinary owner credentials")
	}
	path := fmt.Sprintf("/tmp/ReClashSocket_%d.sock", uint32(syscall.Gettid()))
	listener, err := net.ListenUnix("unix", &net.UnixAddr{Name: path, Net: "unix"})
	if err != nil {
		t.Fatal(err)
	}
	defer listener.Close()
	if err := os.Chmod(path, 0600); err != nil {
		t.Fatal(err)
	}
	address, cleanup, err := prepareDesktopStartup([]string{path})
	if err != nil {
		t.Fatal(err)
	}
	cleanup()
	if address != path {
		t.Fatalf("startup changed IPC address to %s", address)
	}
}
