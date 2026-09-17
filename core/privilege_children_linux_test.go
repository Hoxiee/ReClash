//go:build linux && !android && !cgo

package main

import (
	"os"
	"os/exec"
	"runtime"
	"strings"
	"testing"
)

func TestRestrictChildPrivileges(t *testing.T) {
	if os.Getenv("RECLASH_TEST_CLEAR_AMBIENT") != "1" {
		command := exec.Command(os.Args[0], "-test.run=^TestRestrictChildPrivileges$")
		command.Env = append(os.Environ(), "RECLASH_TEST_CLEAR_AMBIENT=1")
		if output, err := command.CombinedOutput(); err != nil {
			t.Fatalf("child: %v\n%s", err, output)
		}
		return
	}
	before, err := os.ReadFile("/proc/self/status")
	if err != nil {
		t.Fatal(err)
	}
	if err := restrictChildPrivileges(); err != nil {
		t.Fatal(err)
	}
	after, err := os.ReadFile("/proc/self/status")
	if err != nil {
		t.Fatal(err)
	}
	field := func(status []byte, name string) string {
		for _, line := range strings.Split(string(status), "\n") {
			if strings.HasPrefix(line, name+":") {
				return strings.TrimSpace(strings.TrimPrefix(line, name+":"))
			}
		}
		return ""
	}
	for _, name := range []string{"CapEff", "CapPrm"} {
		if field(before, name) != field(after, name) {
			t.Fatalf("%s changed", name)
		}
	}
	done := make(chan string, 4)
	for i := 0; i < 4; i++ {
		go func() {
			runtime.LockOSThread()
			defer runtime.UnlockOSThread()
			data, err := os.ReadFile("/proc/thread-self/status")
			if err != nil {
				done <- err.Error()
				return
			}
			done <- field(data, "CapAmb")
		}()
	}
	for i := 0; i < 4; i++ {
		if value := <-done; value != "0000000000000000" {
			t.Fatalf("thread ambient capabilities = %q", value)
		}
	}
}
