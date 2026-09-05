package main

import (
	"context"
	"sync"
	"time"
)

type rcxProbeTarget struct {
	Node   string
	Role   rcxRole
	Marker rcxMarker
}

type rcxProbeResult struct {
	Node    string
	Role    rcxRole
	Outcome rcxProbeOutcome
	DelayMs int
}

type rcxTestFunc func(ctx context.Context, node string, marker rcxMarker) (delayMs int, satisfied bool, err error)

type rcxProber struct {
	test        rcxTestFunc
	concurrency int
	staggerMs   int
	timeout     time.Duration
	jitter      func(spread int) int
	sleep       func(ctx context.Context, d time.Duration) bool
	enough      func(rcxProbeResult) bool
}

func newRcxProber(test rcxTestFunc) *rcxProber {
	return &rcxProber{
		test:        test,
		concurrency: rcxProbeConcurrency,
		staggerMs:   rcxProbeStaggerMs,
		timeout:     10 * time.Second,
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

// Targets that never started stay overloaded, which the ledger reads as no
// information: a wave cut short by a dead radio must not condemn the park.
func (p *rcxProber) Run(ctx context.Context, targets []rcxProbeTarget) []rcxProbeResult {
	results := make([]rcxProbeResult, len(targets))
	for i, target := range targets {
		results[i] = rcxProbeResult{
			Node:    target.Node,
			Role:    target.Role,
			Outcome: rcxProbeOverloaded,
		}
	}
	if len(targets) == 0 {
		return results
	}

	concurrency := p.concurrency
	if concurrency < 1 {
		concurrency = 1
	}
	ctx, cancel := context.WithCancel(ctx)
	defer cancel()
	slots := make(chan struct{}, concurrency)
	var wg sync.WaitGroup
	var mu sync.Mutex

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
		// A zero result reads as a pass, so an unanswered slot starts overloaded.
		safeGoDetached("rcx probe", func() {
			defer func() {
				<-slots
				wg.Done()
			}()
			result := rcxProbeResult{
				Node:    targets[index].Node,
				Role:    targets[index].Role,
				Outcome: rcxProbeOverloaded,
			}
			defer func() {
				mu.Lock()
				results[index] = result
				mu.Unlock()
				if p.enough != nil && p.enough(result) {
					cancel()
				}
			}()
			result = p.probe(ctx, targets[index])
		})
	}
	wg.Wait()
	return results
}

func (p *rcxProber) probe(parent context.Context, target rcxProbeTarget) rcxProbeResult {
	ctx, cancel := context.WithTimeout(parent, p.timeout)
	defer cancel()

	delayMs, satisfied, err := p.test(ctx, target.Node, target.Marker)
	result := rcxProbeResult{Node: target.Node, Role: target.Role, DelayMs: delayMs}
	switch {
	case err != nil && parent.Err() != nil:
		result.Outcome = rcxProbeOverloaded
		result.DelayMs = 0
	case err != nil:
		result.Outcome = rcxProbeFail
		result.DelayMs = 0
	case !satisfied:
		result.Outcome = rcxProbeStatusMismatch
	default:
		result.Outcome = rcxProbeOK
	}
	return result
}

type rcxProbeNode struct {
	Name          string
	Key           string
	Type          string
	Port          int
	HasServerName bool
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

// One blocked transport, port class or SNI habit usually takes every node
// sharing it, so a wave of twelve clones measures one fact twelve times.
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
		key := node.Type + "|" + rcxPortClass(node.Port)
		if node.HasServerName {
			key += "|sni"
		}
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
