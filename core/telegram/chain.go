package telegram

import (
	"context"
	"errors"
	"fmt"
	"net"
	"strconv"
	"sync"
	"sync/atomic"
	"time"
)

// step is one transport of the per-connection chain, tried in this order.
type step int

const (
	stepWSS step = iota
	stepWS
	stepCloudflare
	stepTCP
	stepOutbound
	stepCount
)

var stepRoutes = [stepCount]Route{RouteWebSocket, RouteWebSocket, RouteCloudflare, RouteTCP, RouteOutbound}
var stepNames = [stepCount]string{"wss", "ws", "cloudflare", "tcp", "outbound"}

const (
	stepBudget        = 12 * time.Second
	attemptBudget     = 5 * time.Second
	trialBudget       = 2 * time.Second
	tcpBudget         = 10 * time.Second
	cfParallel        = 2
	cfDialAttempts    = 2
	tcpDialAttempts   = 3
	plainPort         = "80"
	secureDirectPort  = "443"
	cfBasesPerConnect = 2
)

// chainOrder starts from the step that worked last and falls back to the whole chain. The outbound
// is never sticky: it is the last resort, and the direct steps are cheap to skip while closed.
func chainOrder(sticky step, has bool) []step {
	order := make([]step, 0, stepCount)
	if has {
		order = append(order, sticky)
	}
	for s := range stepCount {
		if !has || s != sticky {
			order = append(order, s)
		}
	}
	return order
}

// connect walks the chain. Remembered failures are skipped at once.
func (r *Relay) connect(ctx context.Context, dest target, state *dcState) (upstream, Route, *endpoint, error) {
	state.mu.Lock()
	order := chainOrder(state.sticky, state.hasSticky)
	pooledStep := state.sticky
	pooledFirst := state.hasSticky && (pooledStep == stepWSS || pooledStep == stepWS)
	state.mu.Unlock()
	if pooledFirst {
		if ws, used, ok := r.pool.take(dest, pooledStep); ok {
			state.mu.Lock()
			state.steps[pooledStep].succeed()
			state.mu.Unlock()
			if used != nil {
				r.endpoints.reportReused(used)
			}
			return ws, stepRoutes[pooledStep], used, nil
		}
	}
	var lastErr error
	skipped, noOutbound := false, false
	for _, s := range order {
		if ctx.Err() != nil {
			break
		}
		if s == stepOutbound && r.outbound.Load() == nil {
			noOutbound = true
			continue
		}
		state.mu.Lock()
		trial := state.steps[s].failures > 0
		allowed := state.steps[s].allow(r.now())
		state.mu.Unlock()
		if !allowed {
			skipped = true
			continue
		}
		up, used, err := r.attempt(ctx, s, dest, trial)
		state.mu.Lock()
		switch {
		case err == nil:
			state.steps[s].succeed()
			if s != stepOutbound {
				state.sticky, state.hasSticky = s, true
			}
		case errors.Is(err, ErrNoOutbound):
			state.steps[s].succeed()
		default:
			state.steps[s].fail(r.now(), backoffMax)
			if state.hasSticky && state.sticky == s {
				state.hasSticky = false
			}
		}
		state.mu.Unlock()
		if err == nil {
			return up, stepRoutes[s], used, nil
		}
		if errors.Is(err, ErrNoOutbound) {
			noOutbound = true
			continue
		}
		lastErr = err
		r.config.Logf("dc=%d %s: %v", dest.dc, stepNames[s], err)
	}
	switch {
	case lastErr != nil:
		return nil, "", nil, lastErr
	case skipped:
		return nil, "", nil, errNoRoute
	case noOutbound:
		return nil, "", nil, ErrNoOutbound
	}
	return nil, "", nil, ctx.Err()
}

func (r *Relay) attempt(ctx context.Context, s step, dest target, trial bool) (upstream, *endpoint, error) {
	budget := attemptBudget
	if trial {
		budget = trialBudget
	}
	switch s {
	case stepWSS:
		return r.connectWebSocket(ctx, dest, true, budget)
	case stepWS:
		return r.connectWebSocket(ctx, dest, false, budget)
	case stepCloudflare:
		up, err := r.connectCloudflare(ctx, dest, budget)
		return up, nil, err
	case stepTCP:
		up, err := r.connectTCP(ctx, dest)
		return up, nil, err
	}
	up, err := r.connectOutbound(ctx, dest)
	return up, nil, err
}

func directStep(secure bool) step {
	if secure {
		return stepWSS
	}
	return stepWS
}

func kwsHosts(dest target) []string {
	main := "kws" + strconv.Itoa(dest.hostDC) + ".web.telegram.org"
	if dest.media {
		return []string{"kws" + strconv.Itoa(dest.hostDC) + "-1.web.telegram.org", main}
	}
	return []string{main}
}

func withPort(address, port string) string {
	host, _, err := net.SplitHostPort(address)
	if err != nil {
		host = address
	}
	return net.JoinHostPort(host, port)
}

// connectWebSocket reaches the kws hosts through the endpoint set and then the DC's own addresses.
// The plain variant uses port 80; it never touches endpoint scoring, which rates the TLS path.
func (r *Relay) connectWebSocket(ctx context.Context, dest target, secure bool, budget time.Duration) (upstream, *endpoint, error) {
	ctx, cancel := context.WithTimeout(ctx, stepBudget)
	defer cancel()
	hosts := kwsHosts(dest)
	var ranked []*endpoint
	if secure {
		ranked = r.endpoints.candidates(r.now())
	} else {
		ranked = r.endpoints.ranked()
	}
	var lastErr error
	tried := make(map[string]bool)
	for i, e := range ranked {
		address := e.address
		if !secure {
			address = withPort(address, plainPort)
		}
		tried[address] = true
		ws, latency, err := r.dialEndpoint(ctx, address, hosts, secure, budget)
		if err == nil {
			if !secure {
				r.pool.note(dest, stepWS, address, nil)
				return ws, nil, nil
			}
			r.pool.note(dest, stepWSS, address, e)
			r.endpoints.reportSuccess(e, latency)
			if i > 0 {
				r.config.Logf("failed over to endpoint %s", e.address)
			}
			return ws, e, nil
		}
		lastErr = err
		if secure {
			r.endpoints.reportFailure(e, r.now(), err)
			r.config.Logf("endpoint %s: %v", e.address, err)
			r.reprobeSoon()
		}
		if ctx.Err() != nil {
			return nil, nil, lastErr
		}
	}
	for _, own := range dcAddresses[dest.dc] {
		port := secureDirectPort
		if !secure {
			port = plainPort
		}
		address := withPort(own, port)
		if tried[address] {
			continue
		}
		ws, _, err := r.dialEndpoint(ctx, address, hosts, secure, budget)
		if err == nil {
			r.pool.note(dest, directStep(secure), address, nil)
			return ws, nil, nil
		}
		lastErr = err
		if ctx.Err() != nil {
			break
		}
	}
	if lastErr == nil {
		return nil, nil, errNoRoute
	}
	return nil, nil, lastErr
}

func (r *Relay) upgrade(ctx context.Context, raw net.Conn, host string, secure bool) (*webSocket, error) {
	if !secure {
		return upgradeWebSocketPath(ctx, raw, host, wsPath, nil)
	}
	return upgradeWebSocket(ctx, raw, host, r.config.TLS)
}

// dialEndpoint opens TCP once and walks the hosts over fresh connections only when a host, rather
// than the address, turned out to be the problem.
func (r *Relay) dialEndpoint(ctx context.Context, address string, hosts []string, secure bool, budget time.Duration) (*webSocket, time.Duration, error) {
	ctx, cancel := context.WithTimeout(ctx, budget)
	defer cancel()
	started := r.now()
	var lastErr error
	for _, host := range hosts {
		raw, tries, err := dialHedged(ctx, r.config.Dial, address, dialAttempts, dialStagger)
		if err != nil {
			return nil, 0, fmt.Errorf("tcp after %d tries: %w", tries, err)
		}
		ws, err := r.upgrade(ctx, raw, host, secure)
		if err == nil {
			return ws, r.now().Sub(started), nil
		}
		_ = raw.Close()
		lastErr = err
		var handshake *handshakeError
		if !errors.As(err, &handshake) {
			break
		}
	}
	return nil, 0, lastErr
}

// connectCloudflare reaches Telegram's kws host through a Cloudflare-proxied base domain. The host
// is resolved by the dialer, and TLS is verified against that very name.
func (r *Relay) connectCloudflare(ctx context.Context, dest target, budget time.Duration) (upstream, error) {
	bases := r.cf.ordered()
	if len(bases) == 0 {
		return nil, errors.New("no cloudflare domains")
	}
	bases = bases[:min(cfBasesPerConnect, len(bases))]
	type plan struct {
		base   string
		host   string
		secure bool
	}
	var plans []plan
	for _, secure := range []bool{true, false} {
		for _, base := range bases {
			plans = append(plans, plan{base, "kws" + strconv.Itoa(dest.hostDC) + "." + base, secure})
		}
	}
	tasks := make([]func(context.Context) (*webSocket, error), len(plans))
	for i, p := range plans {
		tasks[i] = func(ctx context.Context) (*webSocket, error) {
			ctx, cancel := context.WithTimeout(ctx, budget)
			defer cancel()
			port := plainPort
			if p.secure {
				port = secureDirectPort
			}
			raw, tries, err := dialHedged(ctx, r.config.Dial, net.JoinHostPort(p.host, port), cfDialAttempts, dialStagger)
			if err != nil {
				return nil, fmt.Errorf("%s tcp after %d tries: %w", p.host, tries, err)
			}
			ws, err := r.upgrade(ctx, raw, p.host, p.secure)
			if err != nil {
				_ = raw.Close()
			}
			return ws, err
		}
	}
	ws, index, err := firstWebSocket(ctx, cfParallel, tasks)
	if err != nil {
		r.cf.rotate(len(bases))
		return nil, err
	}
	r.cf.markGood(plans[index].base)
	return ws, nil
}

// firstWebSocket runs the tasks with a bounded parallelism and returns the first that connects;
// a loser that connects later is closed.
func firstWebSocket(ctx context.Context, parallel int, tasks []func(context.Context) (*webSocket, error)) (*webSocket, int, error) {
	ctx, cancel := context.WithCancel(ctx)
	defer cancel()
	type result struct {
		ws    *webSocket
		index int
		err   error
	}
	results := make(chan result, len(tasks))
	var next atomic.Int32
	var wg sync.WaitGroup
	for range min(parallel, len(tasks)) {
		wg.Go(func() {
			for ctx.Err() == nil {
				i := int(next.Add(1)) - 1
				if i >= len(tasks) {
					return
				}
				ws, err := tasks[i](ctx)
				results <- result{ws, i, err}
			}
		})
	}
	go func() {
		wg.Wait()
		close(results)
	}()
	var lastErr error
	for res := range results {
		if res.err != nil {
			lastErr = res.err
			continue
		}
		go func() {
			for late := range results {
				if late.ws != nil {
					_ = late.ws.Close()
				}
			}
		}()
		return res.ws, res.index, nil
	}
	if lastErr == nil {
		lastErr = ctx.Err()
	}
	return nil, 0, lastErr
}

// connectTCP speaks obfuscated MTProto straight to the DC. Port 80 first: it is the one most
// networks that block 443 to Telegram still let through.
func (r *Relay) connectTCP(ctx context.Context, dest target) (upstream, error) {
	ctx, cancel := context.WithTimeout(ctx, tcpBudget)
	defer cancel()
	var lastErr error
	for _, port := range []string{plainPort, secureDirectPort} {
		for _, own := range dcAddresses[dest.dc] {
			conn, _, err := dialHedged(ctx, r.config.Dial, withPort(own, port), tcpDialAttempts, dialStagger)
			if err == nil {
				return &tcpUpstream{conn: conn}, nil
			}
			lastErr = err
			if ctx.Err() != nil {
				return nil, lastErr
			}
		}
	}
	if lastErr == nil {
		return nil, errNoRoute
	}
	return nil, lastErr
}

func (r *Relay) connectOutbound(ctx context.Context, dest target) (upstream, error) {
	outbound := r.outbound.Load()
	if outbound == nil {
		return nil, ErrNoOutbound
	}
	ctx, cancel := context.WithTimeout(ctx, outboundBudget)
	defer cancel()
	var lastErr error
	for _, address := range dcAddresses[dest.dc] {
		conn, err := (*outbound)(ctx, address)
		if err == nil {
			return &tcpUpstream{conn: conn}, nil
		}
		lastErr = err
		if errors.Is(err, ErrNoOutbound) {
			return nil, err
		}
	}
	return nil, lastErr
}
