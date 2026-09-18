package main

import (
	"sync"
	"time"

	"github.com/metacubex/mihomo/tunnel"
)

const subscriptionReportQueueSize = 512

// subscriptionReportMaxNodes caps distinct node identities the aggregator holds
// so a churning or huge park cannot grow memory without bound.
const subscriptionReportMaxNodes = 2048

type subscriptionOutcome struct {
	attempts int
	failures int
}

type subscriptionNodeStat struct {
	attempts    int
	failures    int
	failStreak  int
	classCounts map[string]int
	durationSum time.Duration
	durationN   int
	lastAt      time.Time
}

type subscriptionCounters struct {
	dialAttempts  int
	dialSuccess   int
	dialFailure   int
	byTransport   map[string]*subscriptionOutcome
	byStage       map[string]*subscriptionOutcome
	byErrClass    map[string]int
	nodes         map[string]*subscriptionNodeStat
	droppedEvents int
	startedAt     time.Time
	updatedAt     time.Time
}

type subscriptionDialEvent struct {
	node       string
	transport  string
	stage      string
	errorClass string
	failed     bool
	elapsed    time.Duration
	at         time.Time
}

// subscriptionReporter is an always-on witness of runtime dial outcomes. Unlike
// the rcx engine it never gates on Smart Route being enabled, and unlike the
// doctor it keeps counters over the whole session rather than a recent ring.
type subscriptionReporter struct {
	mu       sync.Mutex
	counters subscriptionCounters

	events  chan subscriptionDialEvent
	wake    chan struct{}
	quit    chan struct{}
	done    chan struct{}
	lifeMu  sync.Mutex
	started bool
}

func newSubscriptionReporter() *subscriptionReporter {
	reporter := &subscriptionReporter{
		events: make(chan subscriptionDialEvent, subscriptionReportQueueSize),
		wake:   make(chan struct{}, 1),
	}
	reporter.counters = newSubscriptionCounters(time.Now())
	return reporter
}

func newSubscriptionCounters(now time.Time) subscriptionCounters {
	return subscriptionCounters{
		byTransport: map[string]*subscriptionOutcome{},
		byStage:     map[string]*subscriptionOutcome{},
		byErrClass:  map[string]int{},
		nodes:       map[string]*subscriptionNodeStat{},
		startedAt:   now,
		updatedAt:   now,
	}
}

func (r *subscriptionReporter) Start() {
	r.lifeMu.Lock()
	defer r.lifeMu.Unlock()
	if r.started {
		return
	}
	r.quit = make(chan struct{})
	r.done = make(chan struct{})
	r.started = true
	safeGoDetached("subscription reporter", r.loop)
}

func (r *subscriptionReporter) Stop() {
	r.lifeMu.Lock()
	quit, done := r.quit, r.done
	if !r.started {
		r.lifeMu.Unlock()
		return
	}
	r.started = false
	r.lifeMu.Unlock()
	close(quit)
	<-done
}

func (r *subscriptionReporter) loop() {
	defer close(r.done)
	for {
		select {
		case <-r.quit:
			r.drain()
			return
		case <-r.wake:
			r.drain()
		}
	}
}

func (r *subscriptionReporter) drain() {
	for {
		select {
		case event := <-r.events:
			r.apply(event)
		default:
			return
		}
	}
}

// ObserveFlow runs under a held configMux.RLock in the tunnel, so it must take
// no locks and never block: push into the ring, wake the loop, and return.
func (r *subscriptionReporter) ObserveFlow(event tunnel.FlowEvidence) {
	if event.Stage != tunnel.FlowEvidenceDialFinished &&
		event.Stage != tunnel.FlowEvidenceRouteFailed &&
		event.Stage != tunnel.FlowEvidencePreHandleFailed {
		return
	}
	if event.Outbound == "" || event.Outbound == "DIRECT" {
		return
	}
	stage, failed := subscriptionStageOutcome(event.Stage)
	transport := event.Network.String()
	if transport == "" {
		transport = "other"
	}
	select {
	case r.events <- subscriptionDialEvent{
		node:       event.Outbound,
		transport:  transport,
		stage:      stage,
		errorClass: event.ErrorClass,
		failed:     failed,
		elapsed:    event.Duration,
		at:         event.At,
	}:
	default:
		r.mu.Lock()
		r.counters.droppedEvents++
		r.mu.Unlock()
		return
	}
	select {
	case r.wake <- struct{}{}:
	default:
	}
}

func subscriptionStageOutcome(stage tunnel.FlowEvidenceStage) (string, bool) {
	switch stage {
	case tunnel.FlowEvidencePreHandleFailed:
		return "ingress", true
	case tunnel.FlowEvidenceRouteFailed:
		return "route", true
	default:
		return "dial", false
	}
}

func (r *subscriptionReporter) apply(event subscriptionDialEvent) {
	r.mu.Lock()
	defer r.mu.Unlock()
	c := &r.counters
	c.updatedAt = event.at
	c.dialAttempts++
	failed := event.failed || event.errorClass != ""
	if failed {
		c.dialFailure++
	} else {
		c.dialSuccess++
	}
	addOutcome(c.byTransport, event.transport, 1, boolToInt(failed))
	addOutcome(c.byStage, event.stage, 1, boolToInt(failed))
	if event.errorClass != "" {
		c.byErrClass[event.errorClass]++
	}
	r.applyNode(event, failed)
}

func (r *subscriptionReporter) applyNode(event subscriptionDialEvent, failed bool) {
	c := &r.counters
	stat := c.nodes[event.node]
	if stat == nil {
		if len(c.nodes) >= subscriptionReportMaxNodes {
			return
		}
		stat = &subscriptionNodeStat{classCounts: map[string]int{}}
		c.nodes[event.node] = stat
	}
	stat.attempts++
	stat.lastAt = event.at
	if event.elapsed > 0 {
		stat.durationSum += event.elapsed
		stat.durationN++
	}
	if failed {
		stat.failures++
		stat.failStreak++
		if event.errorClass != "" {
			stat.classCounts[event.errorClass]++
		}
	} else {
		stat.failStreak = 0
	}
}

// Snapshot deep-copies the counters so the builder and redactor never touch live
// maps the loop goroutine is still writing.
func (r *subscriptionReporter) Snapshot() subscriptionCounters {
	r.mu.Lock()
	defer r.mu.Unlock()
	return r.counters.clone()
}

func (c subscriptionCounters) clone() subscriptionCounters {
	out := subscriptionCounters{
		dialAttempts:  c.dialAttempts,
		dialSuccess:   c.dialSuccess,
		dialFailure:   c.dialFailure,
		byTransport:   cloneOutcomes(c.byTransport),
		byStage:       cloneOutcomes(c.byStage),
		byErrClass:    cloneIntMap(c.byErrClass),
		nodes:         map[string]*subscriptionNodeStat{},
		droppedEvents: c.droppedEvents,
		startedAt:     c.startedAt,
		updatedAt:     c.updatedAt,
	}
	for name, stat := range c.nodes {
		copied := *stat
		copied.classCounts = cloneIntMap(stat.classCounts)
		out.nodes[name] = &copied
	}
	return out
}

func cloneOutcomes(m map[string]*subscriptionOutcome) map[string]*subscriptionOutcome {
	out := make(map[string]*subscriptionOutcome, len(m))
	for key, o := range m {
		copied := *o
		out[key] = &copied
	}
	return out
}

func cloneIntMap(m map[string]int) map[string]int {
	out := make(map[string]int, len(m))
	for key, v := range m {
		out[key] = v
	}
	return out
}

func boolToInt(b bool) int {
	if b {
		return 1
	}
	return 0
}
