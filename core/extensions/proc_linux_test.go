package extensions

import (
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"testing"
	"time"
)

func noNewPrivs(status string) bool {
	return strings.Contains(status, "NoNewPrivs:\t1")
}

func TestChildRunsWithNoNewPrivsAndTheCoreDoesNot(t *testing.T) {
	home := t.TempDir()
	install(t, home, installOptions{})
	m, _ := newManager(t, home, nil)
	proxy := parseNode(t, map[string]any{"link": "fake://ok"})
	dialEcho(t, proxy, echoTCP(t))
	status, err := os.ReadFile(filepath.Join(dataDir(home, "fake", "fake://ok"), "status"))
	if err != nil {
		t.Fatal(err)
	}
	if !noNewPrivs(string(status)) {
		t.Fatalf("child without no_new_privs:\n%s", status)
	}
	m.StopAll()
	time.Sleep(time.Second)
	tasks, _ := filepath.Glob("/proc/self/task/*/status")
	// A locked goroutine that ends on the main thread parks that thread for good instead of ending it.
	mainThread := filepath.Join("/proc/self/task", strconv.Itoa(os.Getpid()), "status")
	for _, task := range tasks {
		if task == mainThread {
			continue
		}
		if data, err := os.ReadFile(task); err == nil && noNewPrivs(string(data)) {
			t.Fatalf("no_new_privs leaked into Core thread %s of %d", task, os.Getpid())
		}
	}
}
