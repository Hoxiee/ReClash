package extensions

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"errors"
	"fmt"
	"os"
	"time"

	"github.com/metacubex/mihomo/component/dialer"
)

type nodeState int

const (
	stateIdle nodeState = iota
	stateStarting
	stateReady
	stateBackoff
	stateFailed
)

func (s nodeState) String() string {
	switch s {
	case stateStarting:
		return "starting"
	case stateReady:
		return "ready"
	case stateBackoff:
		return "backoff"
	case stateFailed:
		return "failed"
	default:
		return "idle"
	}
}

var errStopped = errors.New("stopped")

// node is one extension process slot: an extension id, a link and the egress options of the nodes using them.
type node struct {
	key         string
	id          string
	link        string
	tag         string
	options     []dialer.Option
	dialerProxy string

	state nodeState
	// gen moves on with every start, stop and exit; work started for an older gen is superseded.
	gen     uint64
	settled chan struct{}
	proc    *process
	lastErr string
	errAt   time.Time
	crashes []time.Time
	retry   *time.Timer
	idle    *time.Timer
	active  int
	lastUse time.Time
	removed bool
}

func (n *node) setError(reason string) {
	n.lastErr = reason
	n.errAt = time.Now()
}

func stopTimer(timer **time.Timer) {
	if *timer != nil {
		(*timer).Stop()
		*timer = nil
	}
}

func closeSettled(n *node) {
	if n.settled == nil {
		return
	}
	select {
	case <-n.settled:
	default:
		close(n.settled)
	}
}

func (m *Manager) nodeLocked(a *Adapter) *node {
	if n := m.nodes[a.key]; n != nil {
		return n
	}
	sum := sha256.Sum256([]byte(a.link))
	n := &node{
		key:         a.key,
		id:          a.id,
		link:        a.link,
		tag:         a.id + "/" + hex.EncodeToString(sum[:4]),
		options:     a.DialOptions(),
		dialerProxy: a.dialerProxy,
	}
	m.nodes[a.key] = n
	return n
}

// acquire returns the ready process of a's node, starting it when nothing runs. A stop that lands while the
// caller waits for the start wins: the caller gets an error rather than a new start.
func (m *Manager) acquire(ctx context.Context, a *Adapter) (*process, error) {
	if a.invalid != "" {
		return nil, unavailable(a.id, a.invalid)
	}
	m.mu.Lock()
	n := m.nodeLocked(a)
	for {
		switch n.state {
		case stateReady:
			n.lastUse = time.Now()
			p := n.proc
			m.mu.Unlock()
			return p, nil
		case stateFailed, stateBackoff:
			err := unavailable(n.id, n.lastErr)
			m.mu.Unlock()
			return nil, err
		case stateIdle:
			if err := m.startLocked(n); err != nil {
				m.mu.Unlock()
				return nil, unavailable(n.id, err.Error())
			}
		case stateStarting:
			n.lastUse = time.Now()
			settled := n.settled
			m.mu.Unlock()
			select {
			case <-settled:
			case <-ctx.Done():
				return nil, fmt.Errorf("extension %s is starting: %w", n.id, ctx.Err())
			}
			m.mu.Lock()
			if n.removed || n.state == stateIdle {
				m.mu.Unlock()
				return nil, unavailable(n.id, errStopped.Error())
			}
		}
	}
}

func (m *Manager) liveLocked() int {
	live := 0
	for _, n := range m.nodes {
		if n.state == stateStarting || n.state == stateReady {
			live++
		}
	}
	return live
}

func (m *Manager) evictLocked() bool {
	var victim *node
	for _, n := range m.nodes {
		if n.state == stateReady && n.active == 0 && (victim == nil || n.lastUse.Before(victim.lastUse)) {
			victim = n
		}
	}
	if victim == nil {
		return false
	}
	m.stopLocked(victim, "evicted for a newer node")
	return true
}

func (m *Manager) startLocked(n *node) error {
	if m.liveLocked() >= m.cfg.MaxLive && !m.evictLocked() {
		return fmt.Errorf("%d extension processes are already in use", m.cfg.MaxLive)
	}
	stopTimer(&n.retry)
	stopTimer(&n.idle)
	n.gen++
	n.state = stateStarting
	n.settled = make(chan struct{})
	n.lastUse = time.Now()
	gen := n.gen
	m.logf(LevelInfo, "%s starting", n.tag)
	m.cfg.Spawn("extension "+n.tag, func() { m.run(n, gen) })
	return nil
}

func (m *Manager) stopLocked(n *node, reason string) {
	stopTimer(&n.retry)
	stopTimer(&n.idle)
	running := n.state == stateStarting || n.state == stateReady
	n.gen++
	n.state = stateIdle
	closeSettled(n)
	if p := n.proc; p != nil {
		n.proc = nil
		m.dying[p] = struct{}{}
		p.requestStop(m.cfg.StopGrace)
	}
	if running {
		m.logf(LevelInfo, "%s stopped: %s", n.tag, reason)
	}
}

func (m *Manager) resetLocked(n *node) {
	stopTimer(&n.retry)
	n.state = stateIdle
	n.crashes = nil
	n.lastErr = ""
}

func (m *Manager) removeLocked(n *node) {
	n.removed = true
	if m.nodes[n.key] == n {
		delete(m.nodes, n.key)
	}
}

func (m *Manager) egressLocked() (*egressServer, error) {
	if m.egress == nil {
		egress, err := newEgressServer(m)
		if err != nil {
			return nil, err
		}
		m.egress = egress
	}
	return m.egress, nil
}

// run owns one process from install checks to exit. It stays on its goroutine the whole time: on Linux the child
// is tied to this goroutine's OS thread (see startCommand).
func (m *Manager) run(n *node, gen uint64) {
	home := m.cfg.Home()
	inst, data, err := m.prepare(home, n)
	if err != nil {
		m.startFailed(n, gen, err.Error())
		return
	}
	m.mu.Lock()
	if n.gen != gen {
		m.mu.Unlock()
		return
	}
	egress, err := m.egressLocked()
	if err != nil {
		m.mu.Unlock()
		m.startFailed(n, gen, "egress: "+err.Error())
		return
	}
	credentials := egress.add(&egressIdentity{key: n.key, options: n.options, dialerProxy: n.dialerProxy})
	m.mu.Unlock()

	request := RunRequest{
		Protocol: ProtocolVersion,
		Link:     n.link,
		Listen:   "127.0.0.1:0",
		Egress:   credentials,
		DataDir:  data,
		LogLevel: m.cfg.LogLevel(),
	}
	p, err := startProcess(inst, request)
	if err != nil {
		egress.remove(credentials.Username)
		m.startFailed(n, gen, "start: "+err.Error())
		return
	}
	m.mu.Lock()
	if n.gen == gen {
		n.proc = p
	} else {
		m.dying[p] = struct{}{}
		p.kill()
	}
	m.mu.Unlock()

	m.cfg.Spawn("extension events "+n.tag, func() { m.readEvents(n, p) })
	m.cfg.Spawn("extension log "+n.tag, func() { m.readLog(n, p) })
	m.cfg.Spawn("extension ready "+n.tag, func() { m.awaitReady(n, gen, p) })
	waitErr := p.cmd.Wait()
	killGroup(p.cmd.Process)
	close(p.exited)
	select {
	case <-p.eventsDone:
	case <-time.After(time.Second):
	}
	egress.remove(credentials.Username)
	m.exited(n, p, waitErr)
}

func (m *Manager) prepare(home string, n *node) (installation, string, error) {
	if home == "" {
		return installation{}, "", errors.New("Core home is not set")
	}
	if m.cfg.Privileged() {
		return installation{}, "", errors.New("requires an unprivileged Core")
	}
	inst, err := findInstallation(home, n.id)
	if err != nil {
		return installation{}, "", err
	}
	if err := verifyExecutable(inst); err != nil {
		return installation{}, "", err
	}
	data := dataDir(home, n.id, n.link)
	if err := os.MkdirAll(data, 0o700); err != nil {
		return installation{}, "", err
	}
	return inst, data, nil
}

func (m *Manager) startFailed(n *node, gen uint64, reason string) {
	m.mu.Lock()
	defer m.mu.Unlock()
	if n.gen != gen {
		return
	}
	n.gen++
	n.state = stateFailed
	n.setError(reason)
	closeSettled(n)
	m.logf(LevelWarning, "%s unavailable: %s", n.tag, reason)
}

func (m *Manager) awaitReady(n *node, gen uint64, p *process) {
	timer := time.NewTimer(m.cfg.ReadyTimeout)
	defer timer.Stop()
	select {
	case event := <-p.ready:
		m.markReady(n, gen, p, event)
	case <-timer.C:
		m.mu.Lock()
		p.failReason = fmt.Sprintf("not ready within %s", m.cfg.ReadyTimeout)
		m.mu.Unlock()
		p.kill()
	case <-p.exited:
	}
}

func (m *Manager) markReady(n *node, gen uint64, p *process, event Event) {
	m.mu.Lock()
	defer m.mu.Unlock()
	if n.gen != gen || n.proc != p {
		return
	}
	p.setReady(m, n, event)
	n.state = stateReady
	n.lastUse = time.Now()
	closeSettled(n)
	m.armIdleLocked(n, m.cfg.IdleTimeout)
	m.logf(LevelInfo, "%s ready, udp %t", n.tag, event.UDP)
}

func (m *Manager) exited(n *node, p *process, waitErr error) {
	m.mu.Lock()
	defer m.mu.Unlock()
	delete(m.dying, p)
	if n.proc != p {
		return
	}
	n.proc = nil
	n.gen++
	stopTimer(&n.idle)
	defer closeSettled(n)
	if p.fatal != "" {
		n.state = stateFailed
		n.setError(p.fatal)
		m.logf(LevelWarning, "%s failed: %s", n.tag, p.fatal)
		return
	}
	reason := p.failReason
	if reason == "" {
		reason = "exited"
		if waitErr != nil {
			reason = "exited: " + waitErr.Error()
		}
	}
	now := time.Now()
	recent := n.crashes[:0]
	for _, at := range n.crashes {
		if now.Sub(at) < m.cfg.CrashWindow {
			recent = append(recent, at)
		}
	}
	n.crashes = append(recent, now)
	if len(n.crashes) >= m.cfg.CrashLimit {
		n.state = stateFailed
		n.setError(fmt.Sprintf("crashed %d times in %s, last: %s", len(n.crashes), m.cfg.CrashWindow, reason))
		m.logf(LevelWarning, "%s failed: %s", n.tag, n.lastErr)
		return
	}
	delay := m.cfg.BackoffMin << (len(n.crashes) - 1)
	if delay > m.cfg.BackoffMax || delay <= 0 {
		delay = m.cfg.BackoffMax
	}
	n.state = stateBackoff
	n.setError(reason + ", restarting")
	gen := n.gen
	n.retry = time.AfterFunc(delay, func() {
		m.cfg.Spawn("extension retry "+n.tag, func() { m.retryStart(n, gen) })
	})
	m.logf(LevelWarning, "%s %s, restarting in %s", n.tag, reason, delay)
}

// retryStart restarts a crashed node only while something still uses it; otherwise it waits for the next dial.
func (m *Manager) retryStart(n *node, gen uint64) {
	m.mu.Lock()
	defer m.mu.Unlock()
	if n.gen != gen || n.state != stateBackoff || n.removed {
		return
	}
	n.state = stateIdle
	if time.Since(n.lastUse) >= m.cfg.IdleTimeout {
		return
	}
	if err := m.startLocked(n); err != nil {
		n.setError(err.Error())
	}
}

func (m *Manager) armIdleLocked(n *node, after time.Duration) {
	stopTimer(&n.idle)
	gen := n.gen
	n.idle = time.AfterFunc(after, func() {
		m.cfg.Spawn("extension idle "+n.tag, func() { m.idleCheck(n, gen) })
	})
}

func (m *Manager) idleCheck(n *node, gen uint64) {
	m.mu.Lock()
	defer m.mu.Unlock()
	if n.gen != gen || n.state != stateReady || n.active > 0 {
		return
	}
	if remaining := m.cfg.IdleTimeout - time.Since(n.lastUse); remaining > 0 {
		m.armIdleLocked(n, remaining)
		return
	}
	m.stopLocked(n, "idle")
}

func (m *Manager) track(n *node, p *process) bool {
	m.mu.Lock()
	defer m.mu.Unlock()
	if n.proc != p || n.state != stateReady {
		return false
	}
	n.active++
	n.lastUse = time.Now()
	stopTimer(&n.idle)
	return true
}

func (m *Manager) release(n *node, p *process) {
	m.mu.Lock()
	defer m.mu.Unlock()
	n.active--
	n.lastUse = time.Now()
	if n.active == 0 && n.proc == p && n.state == stateReady {
		m.armIdleLocked(n, m.cfg.IdleTimeout)
	}
}
