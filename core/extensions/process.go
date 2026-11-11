package extensions

import (
	"bufio"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net"
	"net/netip"
	"os"
	"os/exec"
	"runtime"
	"slices"
	"strconv"
	"strings"
	"sync"
	"time"

	"github.com/metacubex/mihomo/adapter/outbound"
)

const maxLineSize = 1 << 20

// inheritedEnv is all the environment a process gets: proxy variables or library paths from the Core's own
// environment must not change where an extension sends its traffic or what it loads.
var inheritedEnv = []string{
	"PATH", "HOME", "TMPDIR", "TMP", "TEMP", "LANG", "LC_ALL",
	"SYSTEMROOT", "WINDIR", "USERPROFILE", "APPDATA", "LOCALAPPDATA",
	"ANDROID_ROOT", "ANDROID_DATA",
}

type process struct {
	cmd    *exec.Cmd
	stdin  *os.File
	stdout *os.File
	stderr *os.File
	redact *redactor

	exited     chan struct{}
	eventsDone chan struct{}
	ready      chan Event
	stopOnce   sync.Once

	// Guarded by Manager.mu.
	fatal      string
	failReason string

	mu     sync.Mutex
	event  Event
	front  frontDialer
	fronts map[string]*outbound.Socks5
}

func processEnv() []string {
	var env []string
	for _, entry := range os.Environ() {
		name, _, _ := strings.Cut(entry, "=")
		for _, allowed := range inheritedEnv {
			if name == allowed || runtime.GOOS == "windows" && strings.EqualFold(name, allowed) {
				env = append(env, entry)
				break
			}
		}
	}
	return env
}

// startProcess runs `<exe> run` with the request on its stdin. It must be called from the goroutine that waits
// for the process.
func startProcess(inst installation, request RunRequest) (*process, error) {
	payload, err := json.Marshal(request)
	if err != nil {
		return nil, err
	}
	stdinRead, stdinWrite, err := os.Pipe()
	if err != nil {
		return nil, err
	}
	stdoutRead, stdoutWrite, err := os.Pipe()
	if err != nil {
		closeFiles(stdinRead, stdinWrite)
		return nil, err
	}
	stderrRead, stderrWrite, err := os.Pipe()
	if err != nil {
		closeFiles(stdinRead, stdinWrite, stdoutRead, stdoutWrite)
		return nil, err
	}
	cmd := exec.Command(inst.executable(), CommandRun)
	cmd.Dir = inst.dir
	cmd.Env = processEnv()
	cmd.Stdin, cmd.Stdout, cmd.Stderr = stdinRead, stdoutWrite, stderrWrite
	err = startCommand(cmd)
	closeFiles(stdinRead, stdoutWrite, stderrWrite)
	if err != nil {
		closeFiles(stdinWrite, stdoutRead, stderrRead)
		return nil, err
	}
	p := &process{
		cmd:        cmd,
		stdin:      stdinWrite,
		stdout:     stdoutRead,
		stderr:     stderrRead,
		redact:     newRedactor(request),
		exited:     make(chan struct{}),
		eventsDone: make(chan struct{}),
		ready:      make(chan Event, 1),
	}
	if _, err := p.stdin.Write(append(payload, '\n')); err != nil {
		p.kill()
	}
	return p, nil
}

func closeFiles(files ...*os.File) {
	for _, file := range files {
		_ = file.Close()
	}
}

// requestStop closes stdin, the protocol's stop request, and kills the group if the process outlives grace.
func (p *process) requestStop(grace time.Duration) {
	p.stopOnce.Do(func() {
		_ = p.stdin.Close()
		time.AfterFunc(grace, p.kill)
	})
}

func (p *process) kill() {
	select {
	case <-p.exited:
	default:
		killGroup(p.cmd.Process)
	}
}

func (m *Manager) readEvents(n *node, p *process) {
	defer close(p.eventsDone)
	defer p.stdout.Close()
	scanner := bufio.NewScanner(p.stdout)
	scanner.Buffer(make([]byte, 4096), maxLineSize)
	readySeen := false
	for scanner.Scan() {
		var event Event
		if err := json.Unmarshal(scanner.Bytes(), &event); err != nil {
			m.logf(LevelDebug, "%s wrote a non-JSON line to stdout", n.tag)
			continue
		}
		switch event.Event {
		case EventReady:
			if readySeen {
				continue
			}
			readySeen = true
			if err := validateReady(event); err != nil {
				m.mu.Lock()
				p.failReason = "invalid ready event: " + err.Error()
				m.mu.Unlock()
				p.kill()
				continue
			}
			p.redact.add(event.Username, event.Password)
			p.ready <- event
		case EventStatus:
			m.logf(LevelInfo, "%s status %s: %s", n.tag, event.State, p.redact.apply(event.Message))
		case EventFatal:
			message := p.redact.apply(event.Message)
			if message == "" {
				message = "fatal error"
			}
			m.mu.Lock()
			p.fatal = message
			m.mu.Unlock()
		}
	}
	_, _ = io.Copy(io.Discard, p.stdout)
}

func (m *Manager) readLog(n *node, p *process) {
	defer p.stderr.Close()
	scanner := bufio.NewScanner(p.stderr)
	scanner.Buffer(make([]byte, 4096), maxLineSize)
	for scanner.Scan() {
		m.logf(LevelInfo, "%s: %s", n.tag, p.redact.apply(scanner.Text()))
	}
	_, _ = io.Copy(io.Discard, p.stderr)
}

func validateReady(event Event) error {
	ap, err := netip.ParseAddrPort(event.SOCKS5)
	if err != nil {
		return err
	}
	if !ap.Addr().IsLoopback() || ap.Port() == 0 {
		return fmt.Errorf("front %s is not a loopback address", event.SOCKS5)
	}
	return nil
}

func (p *process) setReady(m *Manager, n *node, event Event) {
	p.mu.Lock()
	defer p.mu.Unlock()
	p.event = event
	p.front = frontDialer{m: m, n: n, p: p}
	p.fronts = map[string]*outbound.Socks5{}
}

func (p *process) udp() bool {
	p.mu.Lock()
	defer p.mu.Unlock()
	return p.event.UDP
}

// frontFor is the SOCKS5 client of this process, named after the node dialing so mihomo's chains stay right. It
// dials loopback only, so it carries none of the node's dial options; those apply to the egress.
func (p *process) frontFor(name string) (*outbound.Socks5, error) {
	p.mu.Lock()
	defer p.mu.Unlock()
	if front := p.fronts[name]; front != nil {
		return front, nil
	}
	host, portText, err := net.SplitHostPort(p.event.SOCKS5)
	if err != nil {
		return nil, err
	}
	port, err := strconv.Atoi(portText)
	if err != nil {
		return nil, err
	}
	front, err := outbound.NewSocks5(outbound.Socks5Option{
		BasicOption: outbound.BasicOption{DialerForAPI: p.front},
		Name:        name,
		Server:      host,
		Port:        port,
		UserName:    p.event.Username,
		Password:    p.event.Password,
		UDP:         p.event.UDP,
	})
	if err != nil {
		return nil, err
	}
	p.fronts[name] = front
	return front, nil
}

var errProcessGone = errors.New("extension process is no longer running")

type frontDialer struct {
	m *Manager
	n *node
	p *process
}

func (d frontDialer) DialContext(ctx context.Context, network, address string) (net.Conn, error) {
	if !d.m.track(d.n, d.p) {
		return nil, errProcessGone
	}
	var dialer net.Dialer
	conn, err := dialer.DialContext(ctx, network, address)
	if err != nil {
		d.m.release(d.n, d.p)
		return nil, err
	}
	return &trackedConn{Conn: conn, release: func() { d.m.release(d.n, d.p) }}, nil
}

func (d frontDialer) ListenPacket(ctx context.Context, network, _ string, rAddrPort netip.AddrPort) (net.PacketConn, error) {
	local := "127.0.0.1:0"
	if rAddrPort.Addr().Is6() && !rAddrPort.Addr().Is4In6() {
		local = "[::1]:0"
	}
	var config net.ListenConfig
	return config.ListenPacket(ctx, network, local)
}

type trackedConn struct {
	net.Conn
	once    sync.Once
	release func()
}

func (c *trackedConn) Close() error {
	c.once.Do(c.release)
	return c.Conn.Close()
}

// redactor hides the link and every credential of one process from the lines it logs.
type redactor struct {
	mu       sync.Mutex
	secrets  []string
	replacer *strings.Replacer
}

func newRedactor(request RunRequest) *redactor {
	r := &redactor{}
	secrets := []string{request.Link, request.Egress.Username, request.Egress.Password}
	if _, body, ok := strings.Cut(request.Link, "://"); ok {
		secrets = append(secrets, body)
	}
	r.add(secrets...)
	return r
}

const minSecretLength = 4

func (r *redactor) add(secrets ...string) {
	r.mu.Lock()
	defer r.mu.Unlock()
	for _, secret := range secrets {
		if len(secret) >= minSecretLength {
			r.secrets = append(r.secrets, secret)
		}
	}
	// Longest first, so the link is replaced before its body.
	ordered := slices.Clone(r.secrets)
	slices.SortFunc(ordered, func(a, b string) int { return len(b) - len(a) })
	pairs := make([]string, 0, 2*len(ordered))
	for _, secret := range ordered {
		pairs = append(pairs, secret, "<redacted>")
	}
	r.replacer = strings.NewReplacer(pairs...)
}

func (r *redactor) apply(text string) string {
	r.mu.Lock()
	replacer := r.replacer
	r.mu.Unlock()
	return replacer.Replace(text)
}
