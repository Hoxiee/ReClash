package extensions

import (
	"fmt"
	"net/netip"
	"sort"
	"sync"
	"time"

	"github.com/metacubex/mihomo/adapter/outbound"
	"github.com/metacubex/mihomo/component/resolver"
	C "github.com/metacubex/mihomo/constant"
)

// TypeName is the mihomo proxy type of an extension node.
const TypeName = "extension"

// StopGrace is how long a process has to exit after its stdin closes before its process group is killed.
const StopGrace = 3 * time.Second

const (
	DefaultReadyTimeout = 15 * time.Second
	DefaultIdleTimeout  = 10 * time.Minute
	DefaultBackoffMin   = time.Second
	DefaultBackoffMax   = time.Minute
	DefaultCrashWindow  = 5 * time.Minute
	DefaultCrashLimit   = 5
	DefaultMaxLive      = 16
	// Providers parse their nodes after the config apply returns, so the sweep for removed nodes waits for them.
	DefaultSweepDelay = 30 * time.Second
)

type Level int

const (
	LevelDebug Level = iota
	LevelInfo
	LevelWarning
	LevelError
)

// Config carries everything the package needs from its host. Zero durations take the defaults.
type Config struct {
	// Home is the Core home directory; empty while the Core is not initialised.
	Home func() string
	// Spawn runs every goroutine of the package; the Core passes its recovering safeGo.
	Spawn func(name string, run func())
	Logf  func(level Level, format string, args ...any)
	// Lookup resolves a dialer-proxy by name at dial time.
	Lookup func(name string) C.Proxy
	// Proxies lists the proxies of the applied config, consulted by the sweep that stops removed nodes.
	Proxies func() map[string]C.Proxy
	// HostByFakeIP maps a fake-ip address back to its host; nil uses mihomo's resolver mapping.
	HostByFakeIP func(netip.Addr) (string, bool)
	// LogLevel is passed to every started process.
	LogLevel func() string
	// Privileged reports a Core that must not start extensions; nil uses the platform check.
	Privileged func() bool

	ReadyTimeout time.Duration
	IdleTimeout  time.Duration
	BackoffMin   time.Duration
	BackoffMax   time.Duration
	CrashWindow  time.Duration
	CrashLimit   int
	MaxLive      int
	StopGrace    time.Duration
	SweepDelay   time.Duration
}

func (c *Config) applyDefaults() {
	setDefault(&c.ReadyTimeout, DefaultReadyTimeout)
	setDefault(&c.IdleTimeout, DefaultIdleTimeout)
	setDefault(&c.BackoffMin, DefaultBackoffMin)
	setDefault(&c.BackoffMax, DefaultBackoffMax)
	setDefault(&c.CrashWindow, DefaultCrashWindow)
	setDefault(&c.StopGrace, StopGrace)
	setDefault(&c.SweepDelay, DefaultSweepDelay)
	setDefault(&c.CrashLimit, DefaultCrashLimit)
	setDefault(&c.MaxLive, DefaultMaxLive)
	if c.Spawn == nil {
		c.Spawn = func(_ string, run func()) { go run() }
	}
	if c.Home == nil {
		c.Home = func() string { return "" }
	}
	if c.Privileged == nil {
		c.Privileged = privileged
	}
	if c.LogLevel == nil {
		c.LogLevel = func() string { return "info" }
	}
}

func setDefault[T comparable](value *T, fallback T) {
	var zero T
	if *value == zero {
		*value = fallback
	}
}

// Manager owns the extension processes of one Core: their state lives here and nowhere else.
type Manager struct {
	cfg Config

	mu     sync.Mutex
	nodes  map[string]*node
	dying  map[*process]struct{}
	egress *egressServer
	seen   map[string]struct{}
	sweep  *time.Timer
}

func New(cfg Config) *Manager {
	cfg.applyDefaults()
	return &Manager{
		cfg:   cfg,
		nodes: map[string]*node{},
		dying: map[*process]struct{}{},
		seen:  map[string]struct{}{},
	}
}

// Register makes TypeName parse into this manager's adapters. A later Register replaces the earlier one.
func (m *Manager) Register() {
	outbound.RegisterExternal(TypeName, m.parse)
}

func (m *Manager) logf(level Level, format string, args ...any) {
	if m.cfg.Logf != nil {
		m.cfg.Logf(level, "[Extension] "+format, args...)
	}
}

func (m *Manager) hostByFakeIP(ip netip.Addr) (string, bool) {
	if m.cfg.HostByFakeIP != nil {
		return m.cfg.HostByFakeIP(ip)
	}
	if !resolver.IsFakeIP(ip) {
		return "", false
	}
	return resolver.FindHostByIP(ip)
}

// Applied is called after every config apply: failed nodes get another chance, and nodes no config refers to any
// more are stopped once providers had time to load.
func (m *Manager) Applied() {
	m.mu.Lock()
	defer m.mu.Unlock()
	for _, n := range m.nodes {
		if n.state == stateFailed {
			m.resetLocked(n)
		}
	}
	if m.sweep != nil {
		m.sweep.Stop()
	}
	m.sweep = time.AfterFunc(m.cfg.SweepDelay, func() {
		m.cfg.Spawn("extension sweep", m.sweepRemoved)
	})
}

// Retry clears the failed state of every node of id, as a new apply would.
func (m *Manager) Retry(id string) {
	m.mu.Lock()
	defer m.mu.Unlock()
	for _, n := range m.nodes {
		if n.id == id && n.state == stateFailed {
			m.resetLocked(n)
		}
	}
}

func (m *Manager) sweepRemoved() {
	present := map[string]struct{}{}
	if m.cfg.Proxies != nil {
		for _, proxy := range m.cfg.Proxies() {
			if a, ok := unwrapAdapter(proxy); ok {
				present[a.key] = struct{}{}
			}
		}
	}
	m.mu.Lock()
	defer m.mu.Unlock()
	for key := range m.seen {
		present[key] = struct{}{}
	}
	clear(m.seen)
	for key, n := range m.nodes {
		if _, ok := present[key]; !ok {
			m.stopLocked(n, "removed from the config")
			m.removeLocked(n)
		}
	}
}

// StopAll stops every process and waits for them to exit, killing those still alive after the grace period.
func (m *Manager) StopAll() {
	m.mu.Lock()
	if m.sweep != nil {
		m.sweep.Stop()
		m.sweep = nil
	}
	for _, n := range m.nodes {
		m.stopLocked(n, "Core shutdown")
		m.removeLocked(n)
	}
	waiting := make([]*process, 0, len(m.dying))
	for p := range m.dying {
		waiting = append(waiting, p)
	}
	egress := m.egress
	m.egress = nil
	m.mu.Unlock()

	deadline := time.NewTimer(m.cfg.StopGrace + time.Second)
	defer deadline.Stop()
wait:
	for _, p := range waiting {
		select {
		case <-p.exited:
		case <-deadline.C:
			for _, p := range waiting {
				p.kill()
			}
			break wait
		}
	}
	if egress != nil {
		egress.close()
	}
}

// Installed is one entry of the getExtensions answer.
type Installed struct {
	ID        string `json:"id"`
	Version   string `json:"version"`
	Verified  bool   `json:"verified"`
	Processes int    `json:"processes"`
	LastError string `json:"lastError"`
}

func (m *Manager) List() []Installed {
	home := m.cfg.Home()
	if home == "" {
		return []Installed{}
	}
	result := []Installed{}
	for _, id := range installedIDs(home) {
		entry := Installed{ID: id}
		inst, err := findInstallation(home, id)
		if err == nil {
			entry.Version = inst.Version
			err = verifyExecutable(inst)
			entry.Verified = err == nil
		}
		if err != nil {
			entry.LastError = err.Error()
		}
		result = append(result, entry)
	}
	m.mu.Lock()
	defer m.mu.Unlock()
	for i := range result {
		var latest time.Time
		installErr := result[i].LastError != ""
		for _, n := range m.nodes {
			if n.id != result[i].ID {
				continue
			}
			if n.proc != nil {
				result[i].Processes++
			}
			if !installErr && n.lastErr != "" && n.errAt.After(latest) {
				latest = n.errAt
				result[i].LastError = n.lastErr
			}
		}
	}
	sort.Slice(result, func(i, j int) bool { return result[i].ID < result[j].ID })
	return result
}

func unavailable(id, reason string) error {
	return fmt.Errorf("extension %s unavailable: %s", id, reason)
}
