//go:build unix

package extensions

import (
	"bytes"
	"context"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net"
	"net/netip"
	"os"
	"os/exec"
	"path/filepath"
	"strconv"
	"strings"
	"sync"
	"sync/atomic"
	"syscall"
	"testing"
	"time"

	"github.com/metacubex/mihomo/adapter"
	"github.com/metacubex/mihomo/adapter/outbound"
	C "github.com/metacubex/mihomo/constant"
)

var fakeExecutable string

func TestMain(m *testing.M) {
	dir, err := os.MkdirTemp("", "fakeext-")
	if err != nil {
		panic(err)
	}
	fakeExecutable = filepath.Join(dir, "fakeext")
	build := exec.Command("go", "build", "-o", fakeExecutable, "./testdata/fakeext")
	build.Env = append(os.Environ(), "CGO_ENABLED=0")
	if output, err := build.CombinedOutput(); err != nil {
		panic(fmt.Sprintf("build fake extension: %v\n%s", err, output))
	}
	code := m.Run()
	_ = os.RemoveAll(dir)
	os.Exit(code)
}

type installOptions struct {
	version   string
	protocol  []int
	wrongHash bool
	noExe     bool
}

func install(t *testing.T, home string, opts installOptions) string {
	t.Helper()
	if opts.version == "" {
		opts.version = "1.0.0"
	}
	if opts.protocol == nil {
		opts.protocol = []int{1}
	}
	dir := filepath.Join(home, "extensions", "fake", opts.version)
	if err := os.MkdirAll(dir, 0o755); err != nil {
		t.Fatal(err)
	}
	data, err := os.ReadFile(fakeExecutable)
	if err != nil {
		t.Fatal(err)
	}
	sum := sha256.Sum256(data)
	digest := hex.EncodeToString(sum[:])
	if opts.wrongHash {
		digest = strings.Repeat("0", 64)
	}
	if !opts.noExe {
		if err := os.WriteFile(filepath.Join(dir, "fakeext"), data, 0o755); err != nil {
			t.Fatal(err)
		}
	}
	manifest, _ := json.Marshal(Manifest{ID: "fake", Version: opts.version, Protocol: opts.protocol,
		Schemes: []string{"fake"}, Executable: "fakeext", SHA256: digest})
	if err := os.WriteFile(filepath.Join(dir, manifestName), manifest, 0o644); err != nil {
		t.Fatal(err)
	}
	return dir
}

type logSink struct {
	mu    sync.Mutex
	lines []string
}

func (s *logSink) logf(_ Level, format string, args ...any) {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.lines = append(s.lines, fmt.Sprintf(format, args...))
}

func (s *logSink) text() string {
	s.mu.Lock()
	defer s.mu.Unlock()
	return strings.Join(s.lines, "\n")
}

func newManager(t *testing.T, home string, tune func(*Config)) (*Manager, *logSink) {
	t.Helper()
	sink := &logSink{}
	cfg := Config{
		Home:         func() string { return home },
		Logf:         sink.logf,
		Privileged:   func() bool { return false },
		ReadyTimeout: 5 * time.Second,
		BackoffMin:   20 * time.Millisecond,
		BackoffMax:   80 * time.Millisecond,
		StopGrace:    300 * time.Millisecond,
		SweepDelay:   50 * time.Millisecond,
	}
	if tune != nil {
		tune(&cfg)
	}
	m := New(cfg)
	m.Register()
	t.Cleanup(m.StopAll)
	return m, sink
}

func parseNode(t *testing.T, mapping map[string]any) C.Proxy {
	t.Helper()
	full := map[string]any{"name": "node", "type": TypeName, "extension": "fake", "udp": true}
	for k, v := range mapping {
		full[k] = v
	}
	proxy, err := adapter.ParseProxy(full)
	if err != nil {
		t.Fatalf("parse: %v", err)
	}
	return proxy
}

func tcpMetadata(t *testing.T, address string) *C.Metadata {
	t.Helper()
	metadata := &C.Metadata{NetWork: C.TCP}
	if err := metadata.SetRemoteAddress(address); err != nil {
		t.Fatal(err)
	}
	return metadata
}

func echoTCP(t *testing.T) string {
	t.Helper()
	listener, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() { listener.Close() })
	go func() {
		for {
			conn, err := listener.Accept()
			if err != nil {
				return
			}
			go func() {
				defer conn.Close()
				_, _ = io.Copy(conn, conn)
			}()
		}
	}()
	return listener.Addr().String()
}

func echoUDP(t *testing.T) *net.UDPAddr {
	t.Helper()
	conn, err := net.ListenUDP("udp", &net.UDPAddr{IP: net.IPv4(127, 0, 0, 1)})
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() { conn.Close() })
	go func() {
		buf := make([]byte, 2048)
		for {
			n, from, err := conn.ReadFrom(buf)
			if err != nil {
				return
			}
			_, _ = conn.WriteTo(buf[:n], from)
		}
	}()
	return conn.LocalAddr().(*net.UDPAddr)
}

func dialEcho(t *testing.T, proxy C.Proxy, address string) {
	t.Helper()
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	conn, err := proxy.DialContext(ctx, tcpMetadata(t, address))
	if err != nil {
		t.Fatalf("dial: %v", err)
	}
	defer conn.Close()
	expectEcho(t, conn)
}

func expectEcho(t *testing.T, conn net.Conn) {
	t.Helper()
	_ = conn.SetDeadline(time.Now().Add(5 * time.Second))
	if _, err := conn.Write([]byte("ping")); err != nil {
		t.Fatal(err)
	}
	reply := make([]byte, 4)
	if _, err := io.ReadFull(conn, reply); err != nil || string(reply) != "ping" {
		t.Fatalf("echo: %q %v", reply, err)
	}
}

func nodeOf(m *Manager, link string) *node {
	m.mu.Lock()
	defer m.mu.Unlock()
	for _, n := range m.nodes {
		if n.link == link {
			return n
		}
	}
	return nil
}

func stateOf(m *Manager, link string) (nodeState, string) {
	n := nodeOf(m, link)
	if n == nil {
		return stateIdle, ""
	}
	m.mu.Lock()
	defer m.mu.Unlock()
	return n.state, n.lastErr
}

func waitFor(t *testing.T, what string, timeout time.Duration, done func() bool) {
	t.Helper()
	deadline := time.Now().Add(timeout)
	for !done() {
		if time.Now().After(deadline) {
			t.Fatalf("timed out waiting for %s", what)
		}
		time.Sleep(10 * time.Millisecond)
	}
}

func readPid(t *testing.T, home, link string) int {
	t.Helper()
	var pid int
	waitFor(t, "pid file", 5*time.Second, func() bool {
		data, err := os.ReadFile(filepath.Join(dataDir(home, "fake", link), "pid"))
		if err != nil {
			return false
		}
		pid, err = strconv.Atoi(string(data))
		return err == nil
	})
	return pid
}

func processGone(pid int) bool {
	err := syscall.Kill(pid, 0)
	return errors.Is(err, syscall.ESRCH)
}

func liveCount(m *Manager) int {
	m.mu.Lock()
	defer m.mu.Unlock()
	count := 0
	for _, n := range m.nodes {
		if n.proc != nil {
			count++
		}
	}
	return count + len(m.dying)
}

func TestReadyNodeCarriesTCPAndUDPThroughTheEgress(t *testing.T) {
	home := t.TempDir()
	install(t, home, installOptions{})
	m, sink := newManager(t, home, nil)
	proxy := parseNode(t, map[string]any{"link": "fake://ok"})
	if proxy.Type() != C.Extension {
		t.Fatalf("type %s", proxy.Type())
	}
	dialEcho(t, proxy, echoTCP(t))

	echo := echoUDP(t)
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	metadata := &C.Metadata{NetWork: C.UDP, DstIP: netip.MustParseAddr("127.0.0.1"), DstPort: uint16(echo.Port)}
	pc, err := proxy.ListenPacketContext(ctx, metadata)
	if err != nil {
		t.Fatalf("listen packet: %v", err)
	}
	defer pc.Close()
	reply := make([]byte, 64)
	got := false
	for attempt := 0; attempt < 50 && !got; attempt++ {
		if _, err := pc.WriteTo([]byte("udp-ping"), echo); err != nil {
			t.Fatal(err)
		}
		_ = pc.SetReadDeadline(time.Now().Add(100 * time.Millisecond))
		n, _, err := pc.ReadFrom(reply)
		got = err == nil && string(reply[:n]) == "udp-ping"
	}
	if !got {
		t.Fatal("no UDP echo through the extension")
	}

	logs := sink.text()
	if !strings.Contains(logs, "starting <redacted> with egress <redacted>") || strings.Contains(logs, "fake://ok") {
		t.Fatalf("stderr not redacted:\n%s", logs)
	}
	list := m.List()
	if len(list) != 1 || list[0].ID != "fake" || !list[0].Verified || list[0].Processes != 1 || list[0].Version != "1.0.0" {
		t.Fatalf("list: %+v", list)
	}
}

func TestCrashesBackOffAndFiveCrashesFailUntilApply(t *testing.T) {
	home := t.TempDir()
	install(t, home, installOptions{})
	m, _ := newManager(t, home, nil)
	proxy := parseNode(t, map[string]any{"link": "fake://crash"})
	ctx := context.Background()
	_, err := proxy.DialContext(ctx, tcpMetadata(t, "127.0.0.1:1"))
	if err == nil || !strings.Contains(err.Error(), "extension fake unavailable") {
		t.Fatalf("dial: %v", err)
	}
	waitFor(t, "failed after five crashes", 5*time.Second, func() bool {
		state, _ := stateOf(m, "fake://crash")
		return state == stateFailed
	})
	_, reason := stateOf(m, "fake://crash")
	if !strings.Contains(reason, "crashed 5 times") {
		t.Fatalf("reason %q", reason)
	}
	if n := nodeOf(m, "fake://crash"); len(n.crashes) != 5 {
		t.Fatalf("crashes %d", len(n.crashes))
	}
	_, err = proxy.DialContext(ctx, tcpMetadata(t, "127.0.0.1:1"))
	if err == nil || !strings.Contains(err.Error(), "crashed 5 times") {
		t.Fatalf("failed node dialed: %v", err)
	}
	m.Applied()
	if state, _ := stateOf(m, "fake://crash"); state != stateIdle {
		t.Fatalf("apply left state %s", state)
	}
}

func TestFatalEventFailsWithoutRestart(t *testing.T) {
	home := t.TempDir()
	install(t, home, installOptions{})
	m, _ := newManager(t, home, nil)
	proxy := parseNode(t, map[string]any{"link": "fake://fatal"})
	_, err := proxy.DialContext(context.Background(), tcpMetadata(t, "127.0.0.1:1"))
	if err == nil || !strings.Contains(err.Error(), "link: unsupported mode") {
		t.Fatalf("dial: %v", err)
	}
	if state, _ := stateOf(m, "fake://fatal"); state != stateFailed {
		t.Fatalf("state %s", state)
	}
}

func TestReadyTimeoutKillsTheProcess(t *testing.T) {
	home := t.TempDir()
	install(t, home, installOptions{})
	m, _ := newManager(t, home, func(c *Config) {
		c.ReadyTimeout = 300 * time.Millisecond
		c.BackoffMin = time.Hour
		c.BackoffMax = time.Hour
	})
	proxy := parseNode(t, map[string]any{"link": "fake://slow-ready"})
	started := time.Now()
	_, err := proxy.DialContext(context.Background(), tcpMetadata(t, "127.0.0.1:1"))
	if err == nil || !strings.Contains(err.Error(), "not ready within 300ms") {
		t.Fatalf("dial: %v", err)
	}
	if time.Since(started) > 3*time.Second {
		t.Fatal("ready timeout not applied")
	}
	pid := readPid(t, home, "fake://slow-ready")
	waitFor(t, "killed process", 3*time.Second, func() bool { return processGone(pid) })
	if state, _ := stateOf(m, "fake://slow-ready"); state != stateBackoff {
		t.Fatalf("state %s", state)
	}
}

func TestIdleProcessStops(t *testing.T) {
	home := t.TempDir()
	install(t, home, installOptions{})
	m, _ := newManager(t, home, func(c *Config) { c.IdleTimeout = 200 * time.Millisecond })
	proxy := parseNode(t, map[string]any{"link": "fake://ok"})
	address := echoTCP(t)
	ctx := context.Background()
	conn, err := proxy.DialContext(ctx, tcpMetadata(t, address))
	if err != nil {
		t.Fatal(err)
	}
	expectEcho(t, conn)
	time.Sleep(400 * time.Millisecond)
	if state, _ := stateOf(m, "fake://ok"); state != stateReady {
		t.Fatalf("stopped with an open connection: %s", state)
	}
	conn.Close()
	pid := readPid(t, home, "fake://ok")
	waitFor(t, "idle stop", 3*time.Second, func() bool {
		state, _ := stateOf(m, "fake://ok")
		return state == stateIdle && liveCount(m) == 0
	})
	if !processGone(pid) {
		t.Fatal("idle process still alive")
	}
	dialEcho(t, proxy, address)
}

func TestStopSupersedesAPendingStart(t *testing.T) {
	home := t.TempDir()
	install(t, home, installOptions{})
	m, _ := newManager(t, home, func(c *Config) { c.ReadyTimeout = time.Minute })
	proxy := parseNode(t, map[string]any{"link": "fake://slow-ready"})
	result := make(chan error, 1)
	go func() {
		_, err := proxy.DialContext(context.Background(), tcpMetadata(t, "127.0.0.1:1"))
		result <- err
	}()
	pid := readPid(t, home, "fake://slow-ready")
	m.StopAll()
	select {
	case err := <-result:
		if err == nil || !strings.Contains(err.Error(), "stopped") {
			t.Fatalf("dial: %v", err)
		}
	case <-time.After(3 * time.Second):
		t.Fatal("waiting dial not released by the stop")
	}
	waitFor(t, "stopped process", 3*time.Second, func() bool { return processGone(pid) })
	if n := nodeOf(m, "fake://slow-ready"); n != nil {
		t.Fatalf("stop restarted the node: %s", n.state)
	}
}

func TestStopKillsAProcessIgnoringStdin(t *testing.T) {
	home := t.TempDir()
	install(t, home, installOptions{})
	m, _ := newManager(t, home, nil)
	proxy := parseNode(t, map[string]any{"link": "fake://stubborn"})
	dialEcho(t, proxy, echoTCP(t))
	pid := readPid(t, home, "fake://stubborn")
	started := time.Now()
	m.StopAll()
	if !processGone(pid) {
		t.Fatal("process outlived StopAll")
	}
	if elapsed := time.Since(started); elapsed < 250*time.Millisecond {
		t.Fatalf("killed before the grace period: %s", elapsed)
	}
}

func TestSweepStopsNodesNoLongerInTheConfig(t *testing.T) {
	home := t.TempDir()
	install(t, home, installOptions{})
	var present atomic.Pointer[map[string]C.Proxy]
	m, _ := newManager(t, home, func(c *Config) {
		c.Proxies = func() map[string]C.Proxy { return *present.Load() }
	})
	kept := parseNode(t, map[string]any{"name": "kept", "link": "fake://ok/kept"})
	dropped := parseNode(t, map[string]any{"name": "dropped", "link": "fake://ok/dropped"})
	address := echoTCP(t)
	dialEcho(t, kept, address)
	dialEcho(t, dropped, address)
	m.mu.Lock()
	clear(m.seen)
	m.mu.Unlock()
	present.Store(&map[string]C.Proxy{"kept": kept})
	m.Applied()
	waitFor(t, "sweep", 3*time.Second, func() bool { return nodeOf(m, "fake://ok/dropped") == nil })
	if state, _ := stateOf(m, "fake://ok/kept"); state != stateReady {
		t.Fatalf("kept node %s", state)
	}
}

func TestLeastRecentlyUsedIdleProcessIsEvicted(t *testing.T) {
	home := t.TempDir()
	install(t, home, installOptions{})
	m, _ := newManager(t, home, func(c *Config) { c.MaxLive = 1 })
	first := parseNode(t, map[string]any{"name": "a", "link": "fake://ok/a"})
	second := parseNode(t, map[string]any{"name": "b", "link": "fake://ok/b"})
	address := echoTCP(t)
	conn, err := first.DialContext(context.Background(), tcpMetadata(t, address))
	if err != nil {
		t.Fatal(err)
	}
	if _, err := second.DialContext(context.Background(), tcpMetadata(t, address)); err == nil ||
		!strings.Contains(err.Error(), "already in use") {
		t.Fatalf("busy process evicted: %v", err)
	}
	conn.Close()
	waitFor(t, "release", time.Second, func() bool {
		n := nodeOf(m, "fake://ok/a")
		m.mu.Lock()
		defer m.mu.Unlock()
		return n.active == 0
	})
	dialEcho(t, second, address)
	if state, _ := stateOf(m, "fake://ok/a"); state != stateIdle {
		t.Fatalf("first node %s", state)
	}
}

func TestUnavailableExtensionStillParses(t *testing.T) {
	cases := []struct {
		name    string
		prepare func(home string)
		want    string
	}{
		{"not installed", func(string) {}, "not installed"},
		{"missing executable", func(home string) { install(t, home, installOptions{noExe: true}) }, "executable fakeext is missing"},
		{"hash mismatch", func(home string) { install(t, home, installOptions{wrongHash: true}) }, "executable fakeext does not match its manifest hash"},
		{"incompatible", func(home string) { install(t, home, installOptions{protocol: []int{2}}) }, "installed version speaks protocol [2]"},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			home := t.TempDir()
			tc.prepare(home)
			m, _ := newManager(t, home, nil)
			proxy := parseNode(t, map[string]any{"link": "fake://ok"})
			_, err := proxy.DialContext(context.Background(), tcpMetadata(t, "127.0.0.1:1"))
			if err == nil || !strings.Contains(err.Error(), "extension fake unavailable: "+tc.want) {
				t.Fatalf("dial: %v", err)
			}
			if tc.name != "not installed" {
				if list := m.List(); len(list) != 1 || list[0].Verified || !strings.Contains(list[0].LastError, tc.want) {
					t.Fatalf("list: %+v", list)
				}
			}
		})
	}
}

func TestPrivilegedCoreRefuses(t *testing.T) {
	home := t.TempDir()
	install(t, home, installOptions{})
	newManager(t, home, func(c *Config) { c.Privileged = func() bool { return true } })
	proxy := parseNode(t, map[string]any{"link": "fake://ok"})
	_, err := proxy.DialContext(context.Background(), tcpMetadata(t, "127.0.0.1:1"))
	if err == nil || !strings.Contains(err.Error(), "requires an unprivileged Core") {
		t.Fatalf("dial: %v", err)
	}
}

func TestHighestCompatibleVersionIsPicked(t *testing.T) {
	home := t.TempDir()
	install(t, home, installOptions{version: "1.2.0"})
	install(t, home, installOptions{version: "1.10.0"})
	install(t, home, installOptions{version: "2.0.0", protocol: []int{2}})
	inst, err := findInstallation(home, "fake")
	if err != nil || inst.Version != "1.10.0" {
		t.Fatalf("picked %+v %v", inst.Manifest, err)
	}
}

type countingProxy struct {
	*outbound.Base
	dials atomic.Int32
}

func (p *countingProxy) DialContext(ctx context.Context, metadata *C.Metadata) (C.Conn, error) {
	p.dials.Add(1)
	var d net.Dialer
	conn, err := d.DialContext(ctx, "tcp", metadata.RemoteAddress())
	if err != nil {
		return nil, err
	}
	return outbound.NewConn(conn, p), nil
}

func newCountingProxy(name string) (*countingProxy, C.Proxy) {
	p := &countingProxy{Base: outbound.NewBase(outbound.BaseOption{Name: name, Type: C.Socks5})}
	return p, adapter.NewProxy(p)
}

func TestDialerProxyIsResolvedAtDialTime(t *testing.T) {
	home := t.TempDir()
	install(t, home, installOptions{})
	firstCounter, first := newCountingProxy("hop")
	secondCounter, second := newCountingProxy("hop")
	var current atomic.Pointer[C.Proxy]
	current.Store(&first)
	newManager(t, home, func(c *Config) {
		c.Lookup = func(name string) C.Proxy {
			if name != "hop" {
				return nil
			}
			return *current.Load()
		}
	})
	proxy := parseNode(t, map[string]any{"link": "fake://ok", "dialer-proxy": "hop"})
	if proxy.ProxyInfo().DialerProxy != "hop" {
		t.Fatal("dialer-proxy not reported")
	}
	address := echoTCP(t)
	dialEcho(t, proxy, address)
	current.Store(&second)
	dialEcho(t, proxy, address)
	if firstCounter.dials.Load() != 1 || secondCounter.dials.Load() != 1 {
		t.Fatalf("dials %d/%d", firstCounter.dials.Load(), secondCounter.dials.Load())
	}
}

func TestEgressMapsFakeIPBackToTheHost(t *testing.T) {
	home := t.TempDir()
	install(t, home, installOptions{})
	fake := netip.MustParseAddr("198.18.0.7")
	newManager(t, home, func(c *Config) {
		c.HostByFakeIP = func(ip netip.Addr) (string, bool) {
			if ip == fake {
				return "127.0.0.1", true
			}
			return "", false
		}
	})
	proxy := parseNode(t, map[string]any{"link": "fake://ok"})
	_, port, _ := net.SplitHostPort(echoTCP(t))
	dialEcho(t, proxy, net.JoinHostPort(fake.String(), port))
}

func TestEgressRejectsUnknownCredentials(t *testing.T) {
	m, _ := newManager(t, t.TempDir(), nil)
	m.mu.Lock()
	egress, err := m.egressLocked()
	m.mu.Unlock()
	if err != nil {
		t.Fatal(err)
	}
	granted := egress.add(&egressIdentity{key: "k"})
	conn, err := net.Dial("tcp", egress.addr())
	if err != nil {
		t.Fatal(err)
	}
	defer conn.Close()
	user := granted.Username
	request := append([]byte{5, 1, 2, 1, byte(len(user))}, user...)
	request = append(request, 5)
	request = append(request, "wrong"...)
	_, _ = conn.Write(request)
	reply := make([]byte, 4)
	_ = conn.SetReadDeadline(time.Now().Add(2 * time.Second))
	if _, err := io.ReadFull(conn, reply); err != nil || !bytes.Equal(reply, []byte{5, 2, 1, 1}) {
		t.Fatalf("reply %v %v", reply, err)
	}
}

func TestRedactorHidesLinkAndCredentials(t *testing.T) {
	r := newRedactor(RunRequest{Link: "openflux://v1/SECRETBODY", Egress: Egress{Username: "e-user", Password: "pw-123456"}})
	r.add("front-pass")
	got := r.apply("link openflux://v1/SECRETBODY body v1/SECRETBODY e-user pw-123456 front-pass")
	if strings.Contains(got, "SECRET") || strings.Contains(got, "pw-") || strings.Contains(got, "front-pass") || strings.Contains(got, "e-user") {
		t.Fatalf("leaked: %s", got)
	}
}
