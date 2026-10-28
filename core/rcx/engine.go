package rcx

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"sync"
	"sync/atomic"
	"time"
)

const (
	failureDrainDelay    = 250 * time.Millisecond
	trafficDrainDelay    = 2 * time.Second
	publishInterval      = 500 * time.Millisecond
	saveInterval         = 5 * time.Minute
	maxSnapshotBytes     = 1 << 20
	userCheckConcurrency = 8
	snapshotVersion      = 1
)

// Prober measures one node; the core runs mihomo's URL test through it.
// Check and Exit go through the node; Diagnose goes direct, outside the
// tunnel.
type Prober interface {
	Probe(ctx context.Context, node string) (ms int, err error)
	Check(ctx context.Context, node string, check Check) error
	Exit(ctx context.Context, node string, egress Egress) (votes []ExitVote, requests int, err error)
	Diagnose(ctx context.Context, target Target) error
}

// Store persists the engine snapshot.
type Store interface {
	Load() ([]byte, error)
	Save(data []byte) error
}

// Host receives status pushes.
type Host interface {
	Publish(status Status)
}

type snapshot struct {
	Version    int                       `json:"v"`
	Salt       []byte                    `json:"salt"`
	Identities IdentityIndex             `json:"identities"`
	Evidence   Evidence                  `json:"evidence"`
	Controls   map[string]*controlRecord `json:"controls"`
	Journal    journal                   `json:"journal"`
	Energy     EnergyDay                 `json:"energy"`
	Buckets    map[Bucket]*tokenBucket   `json:"buckets,omitempty"`
}

type counter struct {
	traffic atomic.Int32
	fails   atomic.Int32
}

type nodeCounters map[string]*counter

// Engine serialises every change to the machine under one lock. Hot paths
// (dials, first bytes) only bump counters and arm one coalesced drain, so a
// burst of traffic costs a few atomic adds.
type Engine struct {
	mu      sync.Mutex
	m       *machine
	prober  Prober
	store   Store
	host    Host
	now     func() time.Time
	timer   *time.Timer
	dueAt   time.Time
	closed  bool
	ctx     context.Context
	cancel  context.CancelFunc
	storeOK error

	lastPublish time.Time
	lastSave    time.Time

	counters      atomic.Pointer[nodeCounters]
	drainPending  atomic.Uint32
	drainMu       sync.Mutex
	drainTimer    *time.Timer
	drainAt       time.Time
	drainRevision uint64
	drainClosed   bool
	urlTests      chan urlTest
	userSlots     chan struct{}
	split         atomic.Pointer[string]
}

type urlTest struct {
	node string
	ms   int
}

func NewEngine(rt Runtime, prober Prober, store Store, host Host) *Engine {
	ctx, cancel := context.WithCancel(context.Background())
	e := &Engine{
		m:         newMachine(rt),
		prober:    prober,
		store:     store,
		host:      host,
		now:       time.Now,
		ctx:       ctx,
		cancel:    cancel,
		urlTests:  make(chan urlTest, 256),
		userSlots: make(chan struct{}, userCheckConcurrency),
	}
	e.load()
	return e
}

func (e *Engine) load() {
	if e.store == nil {
		return
	}
	data, err := e.store.Load()
	if err != nil || len(data) == 0 {
		return
	}
	var snap snapshot
	if err := json.Unmarshal(data, &snap); err != nil || snap.Version != snapshotVersion {
		return
	}
	m := e.m
	m.salt, m.ids, m.evidence, m.journal = snap.Salt, snap.Identities, snap.Evidence, snap.Journal
	if snap.Controls != nil {
		m.controls = snap.Controls
	}
	m.budget.day, m.budget.buckets = snap.Energy, snap.Buckets
}

func (e *Engine) saveLocked(now time.Time) {
	if e.store == nil || !e.m.dirty {
		return
	}
	m := e.m
	data, err := json.Marshal(snapshot{
		Version:    snapshotVersion,
		Salt:       m.salt,
		Identities: m.ids,
		Evidence:   m.evidence,
		Controls:   m.controls,
		Journal:    m.journal,
		Energy:     m.budget.day,
		Buckets:    m.budget.buckets,
	})
	if err == nil && len(data) > maxSnapshotBytes {
		err = fmt.Errorf("state is %d KiB, over the %d KiB limit", len(data)>>10, maxSnapshotBytes>>10)
	}
	if err == nil {
		err = e.store.Save(data)
	}
	if (err == nil) != (e.storeOK == nil) {
		m.statusDirty = true
	}
	e.storeOK = err
	e.lastSave = now
	if err == nil {
		m.dirty = false
	}
}

// step is the whole engine cycle: decide, buy checks, publish, persist, and
// arm the one timer for the next moment that needs attention.
func (e *Engine) stepLocked() {
	if e.closed {
		return
	}
	now := e.now()
	m := e.m
	m.expireCooldowns(now)
	m.settle(now)
	for _, job := range m.plan(now) {
		go e.probe(job)
	}
	if m.statusDirty && now.Sub(e.lastPublish) >= publishInterval {
		m.statusDirty = false
		e.lastPublish = now
		if e.host != nil {
			e.host.Publish(e.statusLocked(now))
		}
	}
	if m.dirty && now.Sub(e.lastSave) >= saveInterval {
		e.saveLocked(now)
	}
	if current := e.split.Load(); current == nil || *current != m.split {
		split := m.split
		e.split.Store(&split)
	}
	due := m.nextDue(now)
	if m.statusDirty {
		due = earliest(due, e.lastPublish.Add(publishInterval))
	}
	if m.dirty && m.running {
		due = earliest(due, e.lastSave.Add(saveInterval))
	}
	e.arm(due, now)
}

func earliest(a, b time.Time) time.Time {
	if a.IsZero() || (!b.IsZero() && b.Before(a)) {
		return b
	}
	return a
}

func (e *Engine) arm(due, now time.Time) {
	if due.IsZero() {
		if e.timer != nil {
			e.timer.Stop()
		}
		e.dueAt = time.Time{}
		return
	}
	if !e.dueAt.IsZero() && e.dueAt.Equal(due) {
		return
	}
	e.dueAt = due
	wait := max(due.Sub(now), 10*time.Millisecond)
	if e.timer == nil {
		e.timer = time.AfterFunc(wait, e.onTimer)
		return
	}
	e.timer.Reset(wait)
}

func (e *Engine) onTimer() {
	e.mu.Lock()
	defer e.mu.Unlock()
	if e.closed {
		return
	}
	e.dueAt = time.Time{}
	e.drainLocked(0)
	e.stepLocked()
}

func (e *Engine) probe(job probeJob) {
	if job.Bucket == UserBucket {
		select {
		case e.userSlots <- struct{}{}:
			defer func() { <-e.userSlots }()
		case <-e.ctx.Done():
			return
		}
	}
	res := e.run(job)
	if e.ctx.Err() != nil {
		return
	}
	e.mu.Lock()
	defer e.mu.Unlock()
	e.m.onProbeResult(job, res, e.now())
	e.stepLocked()
}

func (e *Engine) run(job probeJob) probeResult {
	if job.Targets != nil {
		return e.diagnose(job.Targets)
	}
	ctx, cancel := context.WithTimeout(e.ctx, probeTimeout)
	ms, err := e.prober.Probe(ctx, job.Node)
	cancel()
	res := probeResult{Ms: ms, Failed: err != nil || ms <= 0}
	if res.Failed {
		return res
	}
	for id, check := range job.Checks {
		ctx, cancel := context.WithTimeout(e.ctx, probeTimeout)
		if res.Checks == nil {
			res.Checks = map[string]bool{}
		}
		res.Checks[id] = e.prober.Check(ctx, job.Node, check) == nil
		cancel()
	}
	if job.Exit != nil {
		ctx, cancel := context.WithTimeout(e.ctx, 2*probeTimeout)
		votes, requests, _ := e.prober.Exit(ctx, job.Node, *job.Exit)
		cancel()
		res.Votes, res.Requests = votes, max(requests-1, 0)
	}
	return res
}

// diagnose tries every target at once; one slow endpoint never delays the
// verdict on the others past the probe timeout.
func (e *Engine) diagnose(targets []Target) probeResult {
	res := probeResult{Diag: map[string]bool{}}
	var mu sync.Mutex
	var wg sync.WaitGroup
	for _, target := range targets {
		wg.Go(func() {
			ctx, cancel := context.WithTimeout(e.ctx, probeTimeout)
			defer cancel()
			ok := e.prober.Diagnose(ctx, target) == nil
			mu.Lock()
			res.Diag[target.String()] = ok
			mu.Unlock()
		})
	}
	wg.Wait()
	return res
}

func (e *Engine) with(run func(now time.Time)) {
	e.mu.Lock()
	defer e.mu.Unlock()
	if e.closed {
		return
	}
	run(e.now())
	e.stepLocked()
}

// --- inputs from the core ---

func (e *Engine) SetTopology(topology Topology) {
	e.with(func(now time.Time) {
		if topology.User != nil {
			e.m.user = *topology.User
			topology.User = nil
		}
		e.m.topology = topology
		e.refreshCounters(topology)
		e.m.rebuild(now)
	})
}

func (e *Engine) SetUserLayer(user UserLayer) {
	e.with(func(now time.Time) {
		e.m.user = user
		e.m.rebuild(now)
	})
}

// SetUserMode tells the engine the tunnel mode the user set, which holds
// whenever no scenario sets one.
func (e *Engine) SetUserMode(mode string) {
	e.with(func(time.Time) {
		if e.m.userMode != mode {
			e.m.userMode = mode
			e.m.suppressProviders()
			e.m.statusDirty = true
		}
	})
}

// Targets lists the groups the scenario may name on any network and the
// members it holds groups on, so the runtime builds them into the topology
// whole.
func (e *Engine) Targets(groups []string, main string) (targets, fixed []string) {
	e.mu.Lock()
	defer e.mu.Unlock()
	if c := e.m.scn.c; c != nil {
		return c.allTargets(groups, main), c.fixedMembers()
	}
	return nil, nil
}

func (e *Engine) SetHints(hints Hints) {
	e.with(func(now time.Time) {
		e.m.ensureSalt()
		e.m.onHints(hints, now)
		// Going to the background is the moment to persist: the process may
		// not get another chance.
		if hints.Screen != nil && !*hints.Screen {
			e.saveLocked(now)
		}
	})
}

func (e *Engine) SetRunning(running bool) {
	e.with(func(now time.Time) {
		if e.m.running == running {
			return
		}
		e.m.running = running
		e.m.statusDirty = true
		if !running {
			e.saveLocked(now)
		}
	})
}

// Flush persists pending state, as the host does before it may be killed.
func (e *Engine) Flush() {
	e.mu.Lock()
	defer e.mu.Unlock()
	e.saveLocked(e.now())
}

func (e *Engine) Close() {
	e.mu.Lock()
	defer e.mu.Unlock()
	if e.closed {
		return
	}
	e.closed = true
	e.counters.Store(nil)
	e.drainMu.Lock()
	e.drainClosed = true
	e.cancelDrainLocked()
	e.drainMu.Unlock()
	e.cancel()
	if e.timer != nil {
		e.timer.Stop()
	}
	e.saveLocked(e.now())
}

// SplitTarget is the group DIRECT rules should go through now, or empty. It
// takes no lock: mihomo asks on every rule match.
func (e *Engine) SplitTarget() string {
	if target := e.split.Load(); target != nil {
		return *target
	}
	return ""
}

func (e *Engine) refreshCounters(topology Topology) {
	previous := e.counters.Load()
	next := make(nodeCounters, len(topology.Leaves))
	add := func(node string) {
		if _, exists := next[node]; exists {
			return
		}
		var c *counter
		if previous != nil {
			c = (*previous)[node]
		}
		if c == nil {
			c = &counter{}
		}
		next[node] = c
	}
	for _, group := range topology.Groups {
		add(group.Name)
		for _, member := range group.Members {
			add(member.Name)
		}
	}
	for _, node := range topology.Leaves {
		add(node)
	}
	// In-flight callbacks keep reaching retained nodes through the same atomics.
	e.counters.Store(&next)
}

func (e *Engine) counter(node string) *counter {
	if counters := e.counters.Load(); counters != nil {
		return (*counters)[node]
	}
	return nil
}

// NoteDial counts a dial through a node. Only failures matter here; a dial
// that succeeds has not yet carried any data.
func (e *Engine) NoteDial(node string, failed bool) {
	if !failed {
		return
	}
	if c := e.counter(node); c != nil {
		c.fails.Add(1)
		e.scheduleDrain(true)
	}
}

// NoteTraffic records that a connection through the node received data.
func (e *Engine) NoteTraffic(node string) {
	if c := e.counter(node); c != nil {
		c.traffic.Add(1)
		e.scheduleDrain(false)
	}
}

// NoteURLTest takes any URL test of the configured test URL, including the
// user's own delay tests, as a measurement.
func (e *Engine) NoteURLTest(node string, ms int) {
	if e.counter(node) == nil {
		return
	}
	select {
	case e.urlTests <- urlTest{node: node, ms: ms}:
		e.scheduleDrain(false)
	default:
	}
}

func (e *Engine) scheduleDrain(urgent bool) {
	priority := uint32(1)
	if urgent {
		priority = 2
	}
	for {
		pending := e.drainPending.Load()
		if pending >= priority {
			return
		}
		if e.drainPending.CompareAndSwap(pending, priority) {
			break
		}
	}
	e.drainMu.Lock()
	defer e.drainMu.Unlock()
	if e.drainClosed {
		e.drainPending.Store(0)
		return
	}
	pending := e.drainPending.Load()
	if pending == 0 {
		return
	}
	delay := trafficDrainDelay
	if pending == 2 {
		delay = failureDrainDelay
	}
	due := time.Now().Add(delay)
	if !e.drainAt.IsZero() && !due.Before(e.drainAt) {
		return
	}
	if e.drainTimer != nil {
		e.drainTimer.Stop()
	}
	e.drainRevision++
	revision := e.drainRevision
	e.drainAt = due
	e.drainTimer = time.AfterFunc(delay, func() { e.drain(revision) })
}

func (e *Engine) cancelDrainLocked() {
	if e.drainTimer != nil {
		e.drainTimer.Stop()
		e.drainTimer = nil
	}
	e.drainAt = time.Time{}
	e.drainRevision++
	e.drainPending.Store(0)
}

func (e *Engine) NoteManualPick(group, node string) {
	e.with(func(now time.Time) { e.m.onManualPick(group, node, now) })
}

func (e *Engine) drain(revision uint64) {
	e.mu.Lock()
	defer e.mu.Unlock()
	if e.drainLocked(revision) {
		e.stepLocked()
	}
}

func (e *Engine) drainLocked(revision uint64) bool {
	e.drainMu.Lock()
	if e.drainClosed || revision != 0 && revision != e.drainRevision {
		e.drainMu.Unlock()
		return false
	}
	// Reset before swapping counters: later events must be able to arm their own drain.
	e.cancelDrainLocked()
	e.drainMu.Unlock()
	now := e.now()
	traffic, fails := map[string]int{}, map[string]int{}
	if counters := e.counters.Load(); counters != nil {
		for node, c := range *counters {
			if n := c.traffic.Swap(0); n > 0 {
				traffic[node] = int(n)
			}
			if n := c.fails.Swap(0); n > 0 {
				fails[node] = int(n)
			}
		}
	}
	if len(traffic) > 0 {
		e.m.onTraffic(traffic, now)
	}
	if len(fails) > 0 {
		e.m.onDialFailures(fails, now)
	}
	for {
		select {
		case t := <-e.urlTests:
			e.m.onURLTest(t.node, t.ms, now)
		default:
			return true
		}
	}
}

// --- queries and actions from the host ---

func (e *Engine) Status() Status {
	e.mu.Lock()
	defer e.mu.Unlock()
	return e.statusLocked(e.now())
}

func (e *Engine) statusLocked(now time.Time) Status {
	s := e.m.status(now)
	if e.storeOK != nil {
		s.Problems = append(s.Problems, Reason{Code: "store.failed", Args: map[string]any{"error": e.storeOK.Error()}})
	}
	return s
}

var ErrUnknownGroup = errors.New("not a smart group")

func (e *Engine) Explain(group string) (Explanation, error) {
	e.mu.Lock()
	defer e.mu.Unlock()
	g := e.m.groups[group]
	if g == nil {
		return Explanation{}, ErrUnknownGroup
	}
	now := e.now()
	d := g.decision
	if g.policy != nil && len(g.members) > 0 {
		d = e.m.decideGroup(g, now)
	}
	return Explanation{
		Group:     group,
		Profile:   g.profileID,
		Decision:  d,
		Freshness: int(e.m.env(now).Freshness(now).Seconds()),
		At:        now,
	}, nil
}

func (e *Engine) Journal(cursor uint64, group string, limit int) []JournalEntry {
	e.mu.Lock()
	defer e.mu.Unlock()
	return e.m.journal.after(cursor, group, limit)
}

// Studio runs one profile-editor operation against the live library and
// evidence; it changes nothing.
func (e *Engine) Studio(req StudioRequest) (StudioResult, error) {
	e.mu.Lock()
	defer e.mu.Unlock()
	return e.m.studio(req, e.now())
}

func (e *Engine) Profiles() []ProfileInfo {
	e.mu.Lock()
	defer e.mu.Unlock()
	return e.m.library.Infos()
}

type ActionRequest struct {
	Group  string `json:"group"`
	Action string `json:"action"`
	Node   string `json:"node,omitempty"`
	// Here pins to the current network only.
	Here bool `json:"here,omitempty"`
}

type ActionResult struct {
	Decision Decision `json:"decision"`
	Now      string   `json:"now"`
}

// Act applies one user action: change server, pin, auto or manual.
func (e *Engine) Act(req ActionRequest) (ActionResult, error) {
	e.mu.Lock()
	defer e.mu.Unlock()
	now := e.now()
	m := e.m
	g := m.groups[req.Group]
	if g == nil {
		return ActionResult{}, ErrUnknownGroup
	}
	ctl := m.controls[req.Group]
	switch req.Action {
	case "change":
		key, ok := m.keyOf(req.Group, g.now)
		if ok {
			if ctl.Excluded == nil {
				ctl.Excluded = map[string]time.Time{}
			}
			ctl.Excluded[key] = now.Add(ChangeCooldown)
		}
		if ctl.Mode == PinnedMode {
			ctl.Mode, ctl.Pin, ctl.PinName, ctl.PinEnv = AutoMode, "", "", ""
		}
		g.force = true
		m.journal.add(JournalEntry{At: now, Group: req.Group, Kind: "change", From: g.now, Reason: reason("change.requested")})
	case "pin":
		key, ok := m.keyOf(req.Group, req.Node)
		if !ok {
			return ActionResult{}, fmt.Errorf("%s is not in %s", req.Node, req.Group)
		}
		ctl.Mode, ctl.Pin, ctl.PinName = PinnedMode, key, req.Node
		ctl.PinEnv = ""
		if req.Here {
			ctl.PinEnv = m.envKey
		}
		m.journal.add(JournalEntry{At: now, Group: req.Group, Kind: "pin", To: req.Node, Reason: reason("pin.requested")})
	case "auto":
		ctl.Mode, ctl.Pin, ctl.PinName, ctl.PinEnv = AutoMode, "", "", ""
		m.journal.add(JournalEntry{At: now, Group: req.Group, Kind: "auto", Reason: reason("auto.requested")})
	case "manual":
		ctl.Mode, ctl.Pin, ctl.PinName, ctl.PinEnv = ManualMode, "", "", ""
		m.journal.add(JournalEntry{At: now, Group: req.Group, Kind: "manual", Reason: reason("manual.requested")})
	case "check":
		// An explicit check is the user's request and is paid from its own
		// bucket: every candidate of the group, a few at a time.
		e.checkAllLocked(g, now)
	default:
		return ActionResult{}, fmt.Errorf("unknown action %q", req.Action)
	}
	m.suppressProviders()
	m.dirty, m.statusDirty = true, true
	e.stepLocked()
	return ActionResult{Decision: g.decision, Now: g.now}, nil
}

func (e *Engine) checkAllLocked(g *groupState, now time.Time) {
	m := e.m
	for _, member := range g.members {
		if isUnroutable(member.Type) {
			continue
		}
		if _, busy := m.inflight[member.Key]; busy {
			continue
		}
		if !m.budget.spend(UserBucket, m.level(), now) {
			return
		}
		job := probeJob{Group: g.name, Node: member.Name, Key: member.Key, Bucket: UserBucket, Kind: "user"}
		m.attachExtras(&job, g.active(), m.level(), now)
		m.inflight[member.Key] = job
		m.lastProbe[member.Key] = now
		go e.probe(job)
	}
}
