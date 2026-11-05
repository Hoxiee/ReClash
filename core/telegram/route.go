package telegram

import (
	"cmp"
	"context"
	"errors"
	"net"
	"slices"
	"sync"
	"time"
)

const (
	dialAttempts       = 6
	dialStagger        = 500 * time.Millisecond
	dialAttemptTimeout = 5 * time.Second

	backoffBase = time.Second
	backoffMax  = 30 * time.Second
	// A half-open trial holds the route closed for other connections until it reports back.
	backoffTrial = 15 * time.Second

	unmeasuredLatency  = 1000.0
	failurePenalty     = 5000.0
	latencySmoothing   = 0.3
	endpointBackoffMax = 30 * time.Second
)

// DialFunc opens a TCP connection that leaves the device the way DIRECT does.
type DialFunc func(ctx context.Context, network, address string) (net.Conn, error)

// dialHedged starts staggered attempts because SYNs to Telegram are often dropped, and returns the
// first to connect. A failed attempt starts the next one at once, so a network that refuses
// outright fails fast instead of waiting out the stagger.
func dialHedged(ctx context.Context, dial DialFunc, address string, attempts int, stagger time.Duration) (net.Conn, int, error) {
	ctx, cancel := context.WithCancel(ctx)
	defer cancel()
	type result struct {
		conn net.Conn
		err  error
		try  int
	}
	results := make(chan result, attempts)
	launch := func(try int) {
		go func() {
			attemptCtx, attemptCancel := context.WithTimeout(ctx, dialAttemptTimeout)
			defer attemptCancel()
			conn, err := dial(attemptCtx, "tcp", address)
			results <- result{conn, err, try}
		}()
	}
	launch(1)
	launched, finished := 1, 0
	timer := time.NewTimer(stagger)
	defer timer.Stop()
	var lastErr error
	settle := func() {
		for range launched - finished {
			if late := <-results; late.conn != nil {
				_ = late.conn.Close()
			}
		}
	}
	for {
		select {
		case r := <-results:
			finished++
			if r.err == nil {
				go settle()
				return r.conn, r.try, nil
			}
			lastErr = r.err
			if launched < attempts {
				launched++
				launch(launched)
				timer.Reset(stagger)
			} else if finished == launched {
				return nil, launched, lastErr
			}
		case <-timer.C:
			if launched < attempts {
				launched++
				launch(launched)
				timer.Reset(stagger)
			}
		case <-ctx.Done():
			go settle()
			if lastErr == nil {
				lastErr = ctx.Err()
			}
			return nil, launched, lastErr
		}
	}
}

// backoff remembers that a route just failed. Inside the window callers fail at once; when it ends
// exactly one caller gets a trial, and the rest keep failing until that trial reports back.
type backoff struct {
	failures int
	until    time.Time
}

func (b *backoff) allow(now time.Time) bool {
	if b.failures == 0 {
		return true
	}
	if now.Before(b.until) {
		return false
	}
	b.until = now.Add(backoffTrial)
	return true
}

func (b *backoff) fail(now time.Time, limit time.Duration) {
	delay := limit
	if b.failures < 16 {
		delay = min(backoffBase<<b.failures, limit)
	}
	b.failures++
	b.until = now.Add(delay)
}

func (b *backoff) succeed() { *b = backoff{} }

// endpoint is one address serving kws hosts.
type endpoint struct {
	address string
	backoff backoff

	latency     float64
	consecutive int
	successes   uint64
	failures    uint64
	lastError   string
}

func (e *endpoint) score() float64 {
	latency := e.latency
	if latency == 0 {
		latency = unmeasuredLatency
	}
	return latency + float64(e.consecutive)*failurePenalty
}

// endpointSet ranks the addresses by real connections and probes. Order is stable between equal
// scores, so the first entry of the tested list stays preferred until something beats it.
type endpointSet struct {
	mu   sync.Mutex
	list []*endpoint
}

func newEndpointSet(addresses []string) *endpointSet {
	s := &endpointSet{}
	s.replace(addresses)
	return s
}

// replace keeps the history of an address that stays on the list.
func (s *endpointSet) replace(addresses []string) {
	s.mu.Lock()
	defer s.mu.Unlock()
	known := make(map[string]*endpoint, len(s.list))
	for _, e := range s.list {
		known[e.address] = e
	}
	s.list = s.list[:0:0]
	for _, address := range addresses {
		e := known[address]
		if e == nil {
			e = &endpoint{address: address}
		}
		delete(known, address)
		s.list = append(s.list, e)
	}
}

// candidates returns addresses a connection may try now, best first.
func (s *endpointSet) candidates(now time.Time) []*endpoint {
	s.mu.Lock()
	defer s.mu.Unlock()
	ranked := slices.Clone(s.list)
	slices.SortStableFunc(ranked, func(a, b *endpoint) int { return cmp.Compare(a.score(), b.score()) })
	allowed := ranked[:0]
	for _, e := range ranked {
		if e.backoff.allow(now) {
			allowed = append(allowed, e)
		}
	}
	return allowed
}

func (s *endpointSet) reportSuccess(e *endpoint, latency time.Duration) {
	s.mu.Lock()
	defer s.mu.Unlock()
	ms := float64(latency.Milliseconds())
	if e.latency == 0 {
		e.latency = ms
	} else {
		e.latency += (ms - e.latency) * latencySmoothing
	}
	e.consecutive = 0
	e.successes++
	e.lastError = ""
	e.backoff.succeed()
}

func (s *endpointSet) reportFailure(e *endpoint, now time.Time, err error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	e.consecutive++
	e.failures++
	e.lastError = err.Error()
	e.backoff.fail(now, endpointBackoffMax)
}

// reportSilent lowers an address that accepted a session and never answered. A client can also
// hang up early, so unlike a failed dial this cannot close the address to other connections.
func (s *endpointSet) reportSilent(e *endpoint) {
	s.mu.Lock()
	defer s.mu.Unlock()
	e.consecutive++
	e.failures++
	e.lastError = "no reply from telegram"
}

func (s *endpointSet) clearBackoff() {
	s.mu.Lock()
	defer s.mu.Unlock()
	for _, e := range s.list {
		e.backoff.succeed()
	}
}

func (s *endpointSet) snapshot() []EndpointStatus {
	s.mu.Lock()
	defer s.mu.Unlock()
	out := make([]EndpointStatus, 0, len(s.list))
	for _, e := range s.list {
		out = append(out, EndpointStatus{
			Address:   e.address,
			LatencyMs: int64(e.latency),
			Successes: e.successes,
			Failures:  e.failures,
			Healthy:   e.consecutive == 0,
			LastError: e.lastError,
		})
	}
	return out
}

func (s *endpointSet) size() int {
	s.mu.Lock()
	defer s.mu.Unlock()
	return len(s.list)
}

var errNoRoute = errors.New("telegram: no usable route")

func (s *endpointSet) report(address string, latency time.Duration, now time.Time, err error) {
	s.mu.Lock()
	var found *endpoint
	for _, e := range s.list {
		if e.address == address {
			found = e
			break
		}
	}
	s.mu.Unlock()
	if found == nil {
		return
	}
	if err != nil {
		s.reportFailure(found, now, err)
		return
	}
	s.reportSuccess(found, latency)
}
