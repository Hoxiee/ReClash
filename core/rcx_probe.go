package main

import (
	"context"
	"sync"
	"time"
)

type rcxProbeTarget struct {
	Node    string
	Key     string
	Role    rcxRole
	Marker  rcxMarker
	Markers []rcxMarker
	Echoes  []string
}

type rcxMarkerAttempt struct {
	ID      string
	Outcome rcxProbeOutcome
	DelayMs int
}

type rcxProbeResult struct {
	Node           string
	Key            string
	Role           rcxRole
	Fingerprint    string
	Outcome        rcxProbeOutcome
	DelayMs        int
	Attempts       []rcxMarkerAttempt
	ExitCountry    string
	chargeNegative bool
}

type rcxTestFunc func(ctx context.Context, node string, marker rcxMarker) (delayMs int, satisfied bool, err error)

type rcxLocateFunc func(ctx context.Context, node, echo string) string

type rcxProber struct {
	test        rcxTestFunc
	locate      rcxLocateFunc
	concurrency int
	staggerMs   int
	timeout     time.Duration
	echoTimeout time.Duration
	jitter      func(spread int) int
	sleep       func(ctx context.Context, d time.Duration) bool
	enough      func(rcxProbeResult) bool
}

func newRcxProber(test rcxTestFunc, locate rcxLocateFunc) *rcxProber {
	return &rcxProber{
		test:        test,
		locate:      locate,
		concurrency: rcxProbeConcurrency,
		staggerMs:   rcxProbeStaggerMs,
		timeout:     10 * time.Second,
		echoTimeout: rcxLocateTimeout,
	}
}

func (p *rcxProber) stagger() time.Duration {
	base := p.staggerMs
	if base <= 0 {
		return 0
	}
	spread := base / 2
	offset := 0
	if p.jitter != nil && spread > 0 {
		offset = p.jitter(spread*2) - spread
	}
	return time.Duration(base+offset) * time.Millisecond
}

func (p *rcxProber) wait(ctx context.Context, d time.Duration) bool {
	if d <= 0 {
		return ctx.Err() == nil
	}
	if p.sleep != nil {
		return p.sleep(ctx, d)
	}
	timer := time.NewTimer(d)
	defer timer.Stop()
	select {
	case <-timer.C:
		return true
	case <-ctx.Done():
		return false
	}
}

func (p *rcxProber) Run(ctx context.Context, targets []rcxProbeTarget) []rcxProbeResult {
	results := make([]rcxProbeResult, len(targets))
	for i, target := range targets {
		results[i] = rcxUnmeasuredProbe(target)
	}
	p.Stream(ctx, targets, func(index int, result rcxProbeResult) {
		results[index] = result
	})
	return results
}

func (p *rcxProber) Stream(
	ctx context.Context,
	targets []rcxProbeTarget,
	deliver func(int, rcxProbeResult),
) {
	if len(targets) == 0 {
		return
	}
	concurrency := p.concurrency
	if concurrency < 1 {
		concurrency = 1
	}
	ctx, cancel := context.WithCancel(ctx)
	defer cancel()
	slots := make(chan struct{}, concurrency)
	var wg sync.WaitGroup

dispatch:
	for i := range targets {
		if i > 0 && !p.wait(ctx, p.stagger()) {
			break dispatch
		}
		select {
		case slots <- struct{}{}:
		case <-ctx.Done():
			break dispatch
		}
		wg.Add(1)
		index := i
		safeGoDetached("rcx probe", func() {
			result := rcxUnmeasuredProbe(targets[index])
			defer func() {
				deliver(index, result)
				if p.enough != nil && p.enough(result) {
					cancel()
				}
				<-slots
				wg.Done()
			}()
			result = p.probe(ctx, targets[index])
		})
	}
	wg.Wait()
}

func rcxUnmeasuredProbe(target rcxProbeTarget) rcxProbeResult {
	return rcxProbeResult{
		Node:        target.Node,
		Key:         target.Key,
		Role:        target.Role,
		Fingerprint: rcxMarkersFingerprint(rcxTargetMarkers(target)),
		Outcome:     rcxProbeOverloaded,
	}
}

func rcxTargetMarkers(target rcxProbeTarget) []rcxMarker {
	if len(target.Markers) > 0 {
		return target.Markers
	}
	return []rcxMarker{target.Marker}
}

func (p *rcxProber) probe(parent context.Context, target rcxProbeTarget) rcxProbeResult {
	result := rcxUnmeasuredProbe(target)
	markers := rcxTargetMarkers(target)
	if len(markers) == 0 {
		return result
	}
	for _, marker := range markers {
		attempt := p.probeMarker(parent, target.Node, target.Role, marker)
		result.Attempts = append(result.Attempts, attempt)
		result.Outcome = attempt.Outcome
		result.DelayMs = attempt.DelayMs
		result.Fingerprint = attempt.ID
		if attempt.Outcome == rcxProbeOK || attempt.Outcome == rcxProbeOverloaded {
			break
		}
	}
	if result.Outcome == rcxProbeOK {
		result.ExitCountry = p.echo(parent, target)
	}
	return result
}

// Ridden on the open probe on purpose: the event that grants the open proof
// carries the egress with it, so no tick ranks a fronted node while unmeasured.
func (p *rcxProber) echo(parent context.Context, target rcxProbeTarget) string {
	if p.locate == nil || target.Role != rcxRoleOpen {
		return ""
	}
	for _, echo := range target.Echoes {
		ctx, cancel := context.WithTimeout(parent, p.echoTimeout)
		country := p.locate(ctx, target.Node, echo)
		cancel()
		if country != "" {
			return country
		}
		if parent.Err() != nil {
			break
		}
	}
	return ""
}

func (p *rcxProber) probeMarker(
	parent context.Context,
	node string,
	role rcxRole,
	marker rcxMarker,
) rcxMarkerAttempt {
	ctx, cancel := context.WithTimeout(parent, p.timeout)
	defer cancel()
	delayMs, satisfied, err := p.test(ctx, node, marker)
	attempt := rcxMarkerAttempt{ID: rcxMarkerID(role, marker), DelayMs: delayMs}
	switch {
	case err != nil && parent.Err() != nil:
		attempt.Outcome = rcxProbeOverloaded
		attempt.DelayMs = 0
	case err != nil:
		attempt.Outcome = rcxProbeFail
		attempt.DelayMs = 0
	case !satisfied:
		attempt.Outcome = rcxProbeStatusMismatch
	default:
		attempt.Outcome = rcxProbeOK
	}
	return attempt
}

type rcxProbeNode struct {
	Name      string
	Key       string
	Provider  string
	Transport string
	Type      string
	Port      int
}

func rcxPortClass(port int) string {
	switch port {
	case 443, 8443:
		return "tls"
	case 80, 8080:
		return "plain"
	case 2053, 2083, 2087, 2096, 2052, 2082, 2086, 2095:
		return "cdn"
	default:
		return "other"
	}
}

func rcxHoistNode(nodes []rcxProbeNode, name string) {
	for at, node := range nodes {
		if node.Name != name {
			continue
		}
		copy(nodes[1:at+1], nodes[:at])
		nodes[0] = node
		return
	}
}

func rcxDiverseWave(nodes []rcxProbeNode, width int) []rcxProbeNode {
	if width <= 0 || len(nodes) == 0 {
		return nil
	}
	type bucket struct {
		key   string
		items []rcxProbeNode
	}
	order := make([]string, 0, len(nodes))
	index := map[string]int{}
	buckets := make([]bucket, 0, len(nodes))
	for _, node := range nodes {
		key := node.Provider + "|" + node.Transport + "|" + node.Type + "|" + rcxPortClass(node.Port)
		position, ok := index[key]
		if !ok {
			index[key] = len(buckets)
			buckets = append(buckets, bucket{key: key})
			order = append(order, key)
			position = len(buckets) - 1
		}
		buckets[position].items = append(buckets[position].items, node)
	}

	wave := make([]rcxProbeNode, 0, width)
	for round := 0; len(wave) < width; round++ {
		added := false
		for _, key := range order {
			at := index[key]
			if round >= len(buckets[at].items) {
				continue
			}
			wave = append(wave, buckets[at].items[round])
			added = true
			if len(wave) == width {
				return wave
			}
		}
		if !added {
			break
		}
	}
	return wave
}

type rcxProbeBudget struct {
	limit  int
	window time.Duration
	stamps []time.Time
}

func newRcxProbeBudget(limit int, window time.Duration) *rcxProbeBudget {
	return &rcxProbeBudget{limit: limit, window: window}
}

func (b *rcxProbeBudget) Take(want int, now time.Time) int {
	b.prune(now)
	if want <= 0 {
		return 0
	}
	free := b.limit - len(b.stamps)
	if free <= 0 {
		return 0
	}
	if want > free {
		want = free
	}
	for i := 0; i < want; i++ {
		b.stamps = append(b.stamps, now)
	}
	return want
}

// An aborted wave measured nothing, so the cap must not charge for it.
func (b *rcxProbeBudget) Refund(count int) {
	if count <= 0 {
		return
	}
	if count > len(b.stamps) {
		count = len(b.stamps)
	}
	b.stamps = b.stamps[:len(b.stamps)-count]
}

func (b *rcxProbeBudget) Remaining(now time.Time) int {
	b.prune(now)
	free := b.limit - len(b.stamps)
	if free < 0 {
		return 0
	}
	return free
}

func (b *rcxProbeBudget) prune(now time.Time) {
	kept := b.stamps[:0]
	for _, stamp := range b.stamps {
		if now.Sub(stamp) < b.window {
			kept = append(kept, stamp)
		}
	}
	b.stamps = kept
}
