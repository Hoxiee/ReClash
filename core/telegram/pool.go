package telegram

import (
	"context"
	"errors"
	"net"
	"sync"
	"sync/atomic"
	"time"
)

const (
	poolSize        = 4
	poolMaxInflight = 2
	poolMaxAge      = 60 * time.Second
	poolIdleWindow  = 5 * time.Minute
	poolTick        = 15 * time.Second
	poolBackoffMax  = 60 * time.Second
	poolPeekWindow  = time.Millisecond
)

type poolKey struct {
	hostDC int
	media  bool
	test   bool
}

type pooledSocket struct {
	ws      *webSocket
	created time.Time
}

type poolEntry struct {
	idle     []pooledSocket
	step     step
	address  string
	endpoint *endpoint
	lastUsed time.Time
	inflight int
	back     backoff
}

// wsPool keeps upgraded WebSockets of the direct steps ready for the DCs in use, so a new Telegram
// connection skips TCP, TLS and the upgrade. Only the maintenance goroutine starts refills, which
// keeps them inside the relay's WaitGroup.
type wsPool struct {
	r    *Relay
	kick chan struct{}

	mu     sync.Mutex
	keys   map[poolKey]*poolEntry
	ctx    context.Context
	cancel context.CancelFunc
	size   int
	maxAge time.Duration
	tick   time.Duration
	hits   atomic.Int64
	misses atomic.Int64
}

func newWSPool(r *Relay) *wsPool {
	p := &wsPool{r: r, kick: make(chan struct{}, 1), keys: make(map[poolKey]*poolEntry), size: poolSize, maxAge: poolMaxAge, tick: poolTick}
	if r.config.poolSize != 0 {
		p.size = max(r.config.poolSize, 0)
	}
	if r.config.poolMaxAge > 0 {
		p.maxAge = r.config.poolMaxAge
	}
	p.ctx, p.cancel = context.WithCancel(r.ctx)
	return p
}

func (p *wsPool) wake() {
	select {
	case p.kick <- struct{}{}:
	default:
	}
}

func (p *wsPool) run() {
	ticker := time.NewTicker(p.tick)
	defer ticker.Stop()
	for {
		select {
		case <-p.r.ctx.Done():
			return
		case <-ticker.C:
		case <-p.kick:
		}
		p.maintain()
	}
}

// note records the step and address that just carried a connection and keeps the key active.
func (p *wsPool) note(dest target, s step, address string, e *endpoint) {
	key := poolKey{hostDC: dest.hostDC, media: dest.media, test: dest.test}
	var stale []pooledSocket
	p.mu.Lock()
	ks := p.keys[key]
	if ks == nil {
		ks = &poolEntry{}
		p.keys[key] = ks
	}
	if len(ks.idle) > 0 && (ks.step != s || ks.address != address) {
		stale, ks.idle = ks.idle, nil
	}
	ks.step, ks.address, ks.endpoint, ks.lastUsed = s, address, e, p.r.now()
	p.mu.Unlock()
	closeAll(stale)
	p.wake()
}

// take returns the newest live socket of the key, or false to fall through to the chain.
func (p *wsPool) take(dest target, s step) (*webSocket, *endpoint, bool) {
	key := poolKey{hostDC: dest.hostDC, media: dest.media, test: dest.test}
	for {
		p.mu.Lock()
		ks := p.keys[key]
		if ks == nil || ks.step != s || len(ks.idle) == 0 {
			p.mu.Unlock()
			p.misses.Add(1)
			return nil, nil, false
		}
		now := p.r.now()
		last := len(ks.idle) - 1
		item := ks.idle[last]
		ks.idle = ks.idle[:last]
		endpoint := ks.endpoint
		if now.Sub(item.created) > p.maxAge {
			p.mu.Unlock()
			_ = item.ws.Close()
			continue
		}
		ks.lastUsed = now
		p.mu.Unlock()
		if !socketAlive(item.ws) {
			_ = item.ws.Close()
			continue
		}
		p.hits.Add(1)
		p.wake()
		return item.ws, endpoint, true
	}
}

// socketAlive peeks without consuming: anything readable before the first MTProto byte, EOF
// included, means the server or a middlebox touched the socket.
func socketAlive(ws *webSocket) bool {
	if ws.reader.Buffered() > 0 {
		return false
	}
	_ = ws.conn.SetReadDeadline(time.Now().Add(poolPeekWindow))
	_, err := ws.reader.Peek(1)
	var timeout net.Error
	if !errors.As(err, &timeout) || !timeout.Timeout() {
		return false
	}
	_ = ws.conn.SetReadDeadline(time.Time{})
	return true
}

func closeAll(items []pooledSocket) {
	for _, item := range items {
		_ = item.ws.Close()
	}
}

func (p *wsPool) maintain() {
	if p.r.ctx.Err() != nil {
		return
	}
	var dead []pooledSocket
	p.mu.Lock()
	now := p.r.now()
	for key, ks := range p.keys {
		live := ks.idle[:0]
		for _, item := range ks.idle {
			if now.Sub(item.created) > p.maxAge {
				dead = append(dead, item)
			} else {
				live = append(live, item)
			}
		}
		ks.idle = live
		if now.Sub(ks.lastUsed) > poolIdleWindow {
			dead, ks.idle = append(dead, ks.idle...), nil
			if ks.inflight == 0 {
				delete(p.keys, key)
			}
			continue
		}
		need := p.size - len(ks.idle) - ks.inflight
		for ; need > 0 && ks.inflight < poolMaxInflight && ks.back.allow(now); need-- {
			ks.inflight++
			ctx, step, address := p.ctx, ks.step, ks.address
			p.r.wg.Go(func() { p.refill(ctx, key, step, address) })
		}
	}
	p.mu.Unlock()
	closeAll(dead)
}

func (p *wsPool) refill(ctx context.Context, key poolKey, s step, address string) {
	hosts := kwsHosts(target{hostDC: key.hostDC, media: key.media, test: key.test})
	ws, _, err := p.r.dialEndpoint(ctx, address, hosts, s == stepWSS, attemptBudget, wsPathFor(key.test))
	p.mu.Lock()
	ks := p.keys[key]
	current := ctx.Err() == nil && ks != nil
	if ks != nil {
		ks.inflight--
	}
	var retry time.Duration
	switch {
	case !current:
	case err != nil:
		ks.back.fail(p.r.now(), poolBackoffMax)
		retry = ks.back.until.Sub(p.r.now())
	default:
		ks.back.succeed()
		ks.idle = append(ks.idle, pooledSocket{ws, p.r.now()})
	}
	p.mu.Unlock()
	switch {
	case err == nil && !current:
		_ = ws.Close()
	case err == nil:
		p.wake()
	case current:
		time.AfterFunc(max(retry, time.Millisecond), p.wake)
	}
}

// drain closes everything and cancels refills in flight; the next success re-learns the routes.
func (p *wsPool) drain() {
	var dead []pooledSocket
	p.mu.Lock()
	p.cancel()
	p.ctx, p.cancel = context.WithCancel(p.r.ctx)
	for key, ks := range p.keys {
		dead = append(dead, ks.idle...)
		delete(p.keys, key)
	}
	p.mu.Unlock()
	closeAll(dead)
}

func (p *wsPool) count(hostDC int) int {
	p.mu.Lock()
	defer p.mu.Unlock()
	total := 0
	for key, ks := range p.keys {
		if key.hostDC == hostDC {
			total += len(ks.idle)
		}
	}
	return total
}
