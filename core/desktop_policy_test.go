package core

import (
	"errors"
	"net"
	"os"
	"path/filepath"
	"testing"
)

func resetDesktopPolicy(t *testing.T) {
	t.Helper()
	desktopPolicy.Lock()
	if desktopPolicy.root != nil {
		_ = desktopPolicy.root.Close()
	}
	desktopPolicy.root = nil
	desktopPolicy.home = ""
	desktopPolicy.verifier = nil
	desktopPolicy.configured = false
	desktopPolicy.Unlock()
}

func TestDesktopLaunchPolicyPinsHomeAndVerifiesEachPeer(t *testing.T) {
	resetDesktopPolicy(t)
	t.Cleanup(func() { resetDesktopPolicy(t) })
	home := t.TempDir()
	refused := errors.New("peer refused")
	calls := 0
	if err := ConfigureDesktopLaunch(home, func(net.Conn) error {
		calls++
		return refused
	}); err != nil {
		t.Fatal(err)
	}
	if !permittedDesktopHome(home) || permittedDesktopHome(t.TempDir()) || permittedDesktopHome(".") {
		t.Fatal("desktop initialization must retain its bootstrap home")
	}
	for range 2 {
		if !errors.Is(verifyDesktopConnection(nil), refused) {
			t.Fatal("each connection must reach the verifier")
		}
	}
	if calls != 2 {
		t.Fatalf("verifier calls = %d", calls)
	}
	if err := ConfigureDesktopLaunch(home, nil); err == nil {
		t.Fatal("the bootstrap policy cannot be replaced")
	}
}

func TestDesktopFileReadRejectsTraversalSymlinkAndHardLinkEscapes(t *testing.T) {
	resetDesktopPolicy(t)
	t.Cleanup(func() { resetDesktopPolicy(t) })
	home := t.TempDir()
	outside := t.TempDir()
	plain := filepath.Join(home, "profile.yaml")
	secret := filepath.Join(outside, "secret")
	for _, path := range []string{plain, secret} {
		if err := os.WriteFile(path, []byte("proxies: []"), 0o600); err != nil {
			t.Fatal(err)
		}
	}
	if err := ConfigureDesktopLaunch(home, nil); err != nil {
		t.Fatal(err)
	}
	if _, err := readCoreFile(plain); err != nil {
		t.Fatalf("owned regular file: %v", err)
	}
	for _, path := range []string{secret, "profile.yaml", home + "x/profile.yaml", filepath.Join(home, "..", filepath.Base(outside), "secret")} {
		if _, err := readCoreFile(path); err == nil {
			t.Errorf("accepted outside or relative path %q", path)
		}
	}
	link := filepath.Join(home, "linked.yaml")
	if err := os.Symlink(secret, link); err == nil {
		if _, err := readCoreFile(link); err == nil {
			t.Fatal("a symlink cannot escape the opened root")
		}
	}
	hardLink := filepath.Join(home, "hard.yaml")
	if err := os.Link(secret, hardLink); err == nil {
		if _, err := readCoreFile(hardLink); err == nil {
			t.Fatal("a hard link cannot smuggle a foreign inode")
		}
	}
}

func TestDesktopScopedWritesAndCleanupCannotEscapeHome(t *testing.T) {
	resetDesktopPolicy(t)
	t.Cleanup(func() { resetDesktopPolicy(t) })
	home := t.TempDir()
	outside := t.TempDir()
	secret := filepath.Join(outside, "secret")
	if err := os.WriteFile(secret, []byte("keep"), 0o600); err != nil {
		t.Fatal(err)
	}
	if err := ConfigureDesktopLaunch(home, nil); err != nil {
		t.Fatal(err)
	}
	if err := writeRuleSetFile(filepath.Join(home, "providers", "rule"), []byte("example.com")); err != nil {
		t.Fatal(err)
	}
	if err := writeRuleSetFile(secret, []byte("replace")); err == nil {
		t.Fatal("scoped write accepted a foreign path")
	}
	if err := removeCorePath(outside, true); err == nil {
		t.Fatal("scoped cleanup accepted a foreign directory")
	}
	if err := removeCorePath(home, true); err == nil {
		t.Fatal("scoped cleanup accepted the application root")
	}
	link := filepath.Join(home, "escape")
	if err := os.Symlink(outside, link); err == nil {
		if err := writeRuleSetFile(filepath.Join(link, "secret"), []byte("replace")); err == nil {
			t.Fatal("scoped write followed a directory symlink")
		}
		if err := removeCorePath(filepath.Join(link, "secret"), false); err == nil {
			t.Fatal("scoped cleanup followed a directory symlink")
		}
	}
	data, err := os.ReadFile(secret)
	if err != nil || string(data) != "keep" {
		t.Fatalf("foreign file changed: %q, %v", data, err)
	}
}
