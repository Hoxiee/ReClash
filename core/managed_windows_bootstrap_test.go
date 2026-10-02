//go:build windows

package main

import (
	"bufio"
	"bytes"
	"context"
	"encoding/binary"
	"encoding/json"
	"fmt"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"strconv"
	"strings"
	"testing"
	"time"

	"github.com/Microsoft/go-winio"
	"golang.org/x/sys/windows"
)

func TestWindowsStartupRejectsWrongElevationMode(t *testing.T) {
	if windows.GetCurrentProcessToken().IsElevated() {
		if _, _, err := prepareDesktopStartup([]string{os.Args[0], `\\.\pipe\ReClashCore_test`}); err == nil {
			t.Fatal("elevated Core accepted an unmanaged launch")
		}
		return
	}
	args := windowsBootstrapArgs(t, t.TempDir())
	if _, _, err := prepareDesktopStartup(append([]string{os.Args[0]}, args...)); err == nil || err.Error() != "managed Windows Core is not elevated" {
		t.Fatalf("non-administrative Core passed the elevation guard: %v", err)
	}
}

func windowsBootstrapArgs(t *testing.T, home string) []string {
	t.Helper()
	identity := windowsTestIdentity(t)
	session := "0123456789abcdef0123456789abcdef"
	return []string{"--managed-windows", fmt.Sprintf(`\\.\pipe\ReClash.bootstrap.%d.%s`, identity.parentPID, session),
		strconv.FormatUint(uint64(identity.parentPID), 10), strconv.FormatUint(identity.parentCreated, 10), identity.sid,
		strconv.FormatUint(uint64(identity.terminalSession), 10), `\\.\pipe\ReClashCore_test`, session, home}
}

func TestWindowsBootstrapSurvivesNoUnownedPhase(t *testing.T) {
	if !windows.GetCurrentProcessToken().IsElevated() {
		if os.Getenv("RECLASH_REQUIRE_WINDOWS_BOOTSTRAP") == "1" {
			t.Fatal("managed bootstrap integration requires an elevated Windows test host")
		}
		t.Skip("managed bootstrap integration requires an elevated Windows test host")
	}
	image, err := os.ReadFile(os.Args[0])
	if err != nil {
		t.Fatal(err)
	}
	directory := t.TempDir()
	guiPath := filepath.Join(directory, "ReClash.exe")
	if err := os.WriteFile(guiPath, image, 0700); err != nil {
		t.Fatal(err)
	}
	if err := os.Link(guiPath, filepath.Join(directory, "ReClashCore.exe")); err != nil {
		t.Fatal(err)
	}
	for _, phase := range []string{"before-job", "joined", "committed", "bad-commit", "timeout"} {
		t.Run(phase, func(t *testing.T) {
			ctx, cancel := context.WithTimeout(context.Background(), 20*time.Second)
			defer cancel()
			gui := exec.CommandContext(ctx, guiPath, "-test.run=^TestWindowsBootstrapHarness$")
			gui.Env = append(os.Environ(), "RECLASH_BOOTSTRAP_ROLE=gui", "RECLASH_BOOTSTRAP_PHASE="+phase,
				"RECLASH_BOOTSTRAP_HOME="+t.TempDir())
			var diagnostics bytes.Buffer
			gui.Stderr = &diagnostics
			out, err := gui.StdoutPipe()
			if err != nil {
				t.Fatal(err)
			}
			input, err := gui.StdinPipe()
			if err != nil {
				t.Fatal(err)
			}
			if err := gui.Start(); err != nil {
				t.Fatal(err)
			}
			t.Cleanup(func() { gui.Process.Kill(); gui.Wait() })
			var observer windows.Handle
			var lines []string
			scanner := bufio.NewScanner(out)
			for scanner.Scan() {
				line := scanner.Text()
				lines = append(lines, line)
				if !strings.HasPrefix(line, "core:") {
					continue
				}
				if observer != 0 {
					t.Fatal("more than one Core was started")
				}
				pid, err := strconv.ParseUint(strings.TrimPrefix(line, "core:"), 10, 32)
				if err != nil {
					t.Fatal(err)
				}
				observer, err = windows.OpenProcess(windows.PROCESS_QUERY_LIMITED_INFORMATION|windows.SYNCHRONIZE, false, uint32(pid))
				if err != nil {
					t.Fatal(err)
				}
				t.Cleanup(func() {
					if status, _ := windows.WaitForSingleObject(observer, 0); status == uint32(windows.WAIT_TIMEOUT) {
						if orphan, err := os.FindProcess(int(pid)); err == nil {
							orphan.Kill()
						}
					}
					windows.CloseHandle(observer)
				})
				if _, err := fmt.Fprintln(input, "observed"); err != nil {
					t.Fatal(err)
				}
				input.Close()
			}
			if err := gui.Wait(); err != nil {
				t.Fatalf("GUI harness failed: %v\n%s\n%s", err, strings.Join(lines, "\n"), diagnostics.String())
			}
			if scanner.Err() != nil || observer == 0 || !strings.Contains(strings.Join(lines, "\n"), "done:"+phase) {
				t.Fatalf("incomplete bootstrap: %v, %v", scanner.Err(), lines)
			}
			if status, err := windows.WaitForSingleObject(observer, 12000); err != nil || status != windows.WAIT_OBJECT_0 {
				t.Fatalf("Core survived GUI exit: status=%d, error=%v", status, err)
			}
			if ctx.Err() != nil {
				t.Fatal("bootstrap required the test watchdog")
			}
		})
	}
}

func TestWindowsBootstrapHarness(t *testing.T) {
	switch os.Getenv("RECLASH_BOOTSTRAP_ROLE") {
	case "core":
		var args []string
		if err := json.Unmarshal([]byte(os.Getenv("RECLASH_BOOTSTRAP_ARGS")), &args); err != nil {
			t.Fatal(err)
		}
		address, cleanup, err := prepareDesktopStartup(append([]string{os.Args[0]}, args...))
		if err != nil {
			t.Fatal(err)
		}
		defer cleanup()
		if address != args[6] || !permittedCoreHome(args[8]) {
			t.Fatal("bootstrap did not retain the original GUI parameters")
		}
		fmt.Println("ready")
		time.Sleep(30 * time.Second)
	case "gui":
		windowsBootstrapGUI(t)
	}
}

func windowsBootstrapGUI(t *testing.T) {
	t.Helper()
	args := windowsBootstrapArgs(t, os.Getenv("RECLASH_BOOTSTRAP_HOME"))
	listener, err := winio.ListenPipe(args[1], &winio.PipeConfig{SecurityDescriptor: "D:P(A;;GA;;;" + args[4] + ")"})
	if err != nil {
		t.Fatal(err)
	}
	defer listener.Close()
	job := windowsTestJob(t, windows.JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE)
	defer windows.CloseHandle(job)
	ctx, cancel := context.WithTimeout(context.Background(), 17*time.Second)
	defer cancel()
	stopAccept := context.AfterFunc(ctx, func() { listener.Close() })
	defer stopAccept()
	encoded, err := json.Marshal(args)
	if err != nil {
		t.Fatal(err)
	}
	core := exec.CommandContext(ctx, filepath.Join(filepath.Dir(os.Args[0]), "ReClashCore.exe"), "-test.run=^TestWindowsBootstrapHarness$")
	core.Env = append(os.Environ(), "RECLASH_BOOTSTRAP_ROLE=core", "RECLASH_BOOTSTRAP_ARGS="+string(encoded))
	core.Stderr = os.Stderr
	out, err := core.StdoutPipe()
	if err != nil {
		t.Fatal(err)
	}
	if err := core.Start(); err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() { core.Process.Kill(); core.Wait() })
	fmt.Printf("core:%d\n", core.Process.Pid)
	input := bufio.NewScanner(os.Stdin)
	if !input.Scan() || input.Text() != "observed" {
		t.Fatal("Core observer was not attached")
	}
	pipe, err := listener.Accept()
	if err != nil {
		t.Fatal(err)
	}
	defer pipe.Close()
	if err := pipe.SetDeadline(time.Now().Add(15 * time.Second)); err != nil {
		t.Fatal(err)
	}
	var hello [16]byte
	if _, err := io.ReadFull(pipe, hello[:]); err != nil || string(hello[:8]) != "RCXWIN01" {
		t.Fatalf("missing bootstrap hello: %v", err)
	}
	phase := os.Getenv("RECLASH_BOOTSTRAP_PHASE")
	if phase == "before-job" {
		fmt.Println("done:" + phase)
		os.Exit(0)
	}
	var source [8]byte
	binary.LittleEndian.PutUint64(source[:], uint64(job))
	if _, err := pipe.Write(source[:]); err != nil {
		t.Fatal(err)
	}
	var joined [8]byte
	if _, err := io.ReadFull(pipe, joined[:]); err != nil || string(joined[:]) != "RCXJOIN1" {
		t.Fatalf("missing job confirmation: %v", err)
	}
	if phase == "joined" {
		fmt.Println("done:" + phase)
		os.Exit(0)
	}
	if phase == "committed" || phase == "bad-commit" {
		commit := "RCXGO001"
		if phase == "bad-commit" {
			commit = "RCXNO001"
		}
		if _, err := io.WriteString(pipe, commit); err != nil {
			t.Fatal(err)
		}
	}
	if phase == "committed" {
		output := bufio.NewScanner(out)
		if !output.Scan() || output.Text() != "ready" {
			t.Fatal("committed Core did not become ready")
		}
		fmt.Println("done:" + phase)
		os.Exit(0)
	}
	output, err := io.ReadAll(out)
	if err != nil {
		t.Fatal(err)
	}
	if err := core.Wait(); err == nil || ctx.Err() != nil || strings.Contains(string(output), "\nready\n") || strings.HasPrefix(string(output), "ready\n") {
		t.Fatalf("uncommitted Core did not fail closed: %v, %s", err, output)
	}
	if phase == "timeout" {
		created := binary.LittleEndian.Uint64(hello[8:])
		started := windows.Filetime{LowDateTime: uint32(created), HighDateTime: uint32(created >> 32)}
		if time.Now().Before(time.Unix(0, started.Nanoseconds()).Add(windowsBootstrapTimeout - time.Second)) {
			t.Fatalf("Core exited before the bootstrap deadline: %s", output)
		}
	}
	fmt.Println("done:" + phase)
}
