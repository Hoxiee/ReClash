package telegram

import (
	"context"
	"crypto/tls"
	"errors"
	"fmt"
	"io"
	"net"
	"strconv"
	"sync"
	"sync/atomic"
	"time"
)

const (
	clientHeaderTimeout = 10 * time.Second
	clientWriteTimeout  = 2 * time.Minute
	maxClients          = 1024
	copyBufferSize      = 32 << 10

	connectBudget        = 15 * time.Second
	endpointBudget       = 6 * time.Second
	outboundBudget       = 10 * time.Second
	reprobeInterval      = time.Minute
	probeTimeout         = 10 * time.Second
	stopWaitLimit        = 3 * time.Second
	silentUpstreamMinAge = 3 * time.Second
	unavailableHold      = 5 * time.Second
)

// DefaultEndpoints is the tested list, best known first. Only addresses that answered a real
// req_pq exchange with a valid certificate belong here.
var DefaultEndpoints = []string{"149.154.167.220"}

// OutboundFunc dials a Telegram address through the user's chosen outbound. It returns
// ErrNoOutbound when the active profile offers none.
type OutboundFunc func(ctx context.Context, address string) (net.Conn, error)

// ErrNoOutbound marks the absence of an outbound, not its failure: there is nothing to retry.
var ErrNoOutbound = errors.New("telegram: no outbound available")

type Config struct {
	// Listen is a loopback address. Port 0 picks a free one.
	Listen string
	Secret []byte
	// Endpoints are "ip" or "ip:port" entries serving kws hosts; empty means DefaultEndpoints.
	Endpoints []string
	Dial      DialFunc
	Outbound  OutboundFunc
	TLS       *tls.Config
	Logf      func(format string, args ...any)

	holdUnavailable time.Duration
}

// Route is how a DC is currently reached.
type Route string

const (
	RouteIdle        Route = "idle"
	RouteWebSocket   Route = "websocket"
	RouteOutbound    Route = "outbound"
	RouteUnavailable Route = "unavailable"
)

type DCStatus struct {
	DC          int    `json:"dc"`
	Route       Route  `json:"route"`
	Active      int64  `json:"active"`
	Connects    uint64 `json:"connects"`
	Failures    uint64 `json:"failures"`
	FastFails   uint64 `json:"fastFails"`
	ConnectMs   int64  `json:"connectMs"`
	LastConnect int64  `json:"lastConnect"`
	LastError   string `json:"lastError,omitempty"`
	BytesUp     uint64 `json:"bytesUp"`
	BytesDown   uint64 `json:"bytesDown"`
}

type EndpointStatus struct {
	Address   string `json:"address"`
	LatencyMs int64  `json:"latencyMs"`
	Successes uint64 `json:"successes"`
	Failures  uint64 `json:"failures"`
	Healthy   bool   `json:"healthy"`
	LastError string `json:"lastError,omitempty"`
}

type Status struct {
	Port        int              `json:"port"`
	Clients     int64            `json:"clients"`
	BadSecrets  uint64           `json:"badSecrets"`
	BytesUp     uint64           `json:"bytesUp"`
	BytesDown   uint64           `json:"bytesDown"`
	LastTraffic int64            `json:"lastTraffic"`
	DCs         []DCStatus       `json:"dcs"`
	Endpoints   []EndpointStatus `json:"endpoints"`
	HasOutbound bool             `json:"hasOutbound"`
}

// dcState is keyed by the absolute DC number, so media and main connections of a DC report as one.
type dcState struct {
	active    atomic.Int64
	bytesUp   atomic.Uint64
	bytesDown atomic.Uint64

	mu          sync.Mutex
	route       Route
	connects    uint64
	failures    uint64
	fastFails   uint64
	connectMs   int64
	lastConnect time.Time
	lastError   string
	ws          backoff
	outbound    backoff
}

// Relay is one running proxy. Its lifetime is the caller's; it holds no global state.
type Relay struct {
	config    Config
	listener  net.Listener
	endpoints *endpointSet
	outbound  atomic.Pointer[OutboundFunc]
	now       func() time.Time

	ctx    context.Context
	cancel context.CancelFunc
	wg     sync.WaitGroup

	mu       sync.Mutex
	sessions map[io.Closer]struct{}
	held     map[net.Conn]struct{}
	dcs      map[int]*dcState

	clients     atomic.Int64
	badSecrets  atomic.Uint64
	lastTraffic atomic.Int64
	lastProbe   atomic.Int64
	probing     atomic.Bool
}

// Start binds the listener; an occupied port is reported here rather than from a background task.
func Start(config Config) (*Relay, error) {
	if len(config.Secret) != secretSize {
		return nil, errors.New("telegram: secret must be 16 bytes")
	}
	if config.Dial == nil {
		config.Dial = (&net.Dialer{}).DialContext
	}
	if config.Logf == nil {
		config.Logf = func(string, ...any) {}
	}
	if err := requireLoopback(config.Listen); err != nil {
		return nil, err
	}
	addresses := config.Endpoints
	if len(addresses) == 0 {
		addresses = DefaultEndpoints
	}
	listener, err := net.Listen("tcp4", config.Listen)
	if err != nil {
		return nil, err
	}
	ctx, cancel := context.WithCancel(context.Background())
	r := &Relay{
		config:    config,
		listener:  listener,
		endpoints: newEndpointSet(normalizeEndpoints(addresses)),
		now:       time.Now,
		ctx:       ctx,
		cancel:    cancel,
		sessions:  make(map[io.Closer]struct{}),
		held:      make(map[net.Conn]struct{}),
		dcs:       make(map[int]*dcState),
	}
	r.SetOutbound(config.Outbound)
	r.wg.Go(r.acceptLoop)
	return r, nil
}

func requireLoopback(address string) error {
	host, _, err := net.SplitHostPort(address)
	if err != nil {
		return err
	}
	if ip := net.ParseIP(host); ip == nil || !ip.IsLoopback() {
		return fmt.Errorf("telegram: %s is not a loopback address", address)
	}
	return nil
}

func normalizeEndpoints(addresses []string) []string {
	out := make([]string, 0, len(addresses))
	for _, address := range addresses {
		if _, _, err := net.SplitHostPort(address); err != nil {
			address = net.JoinHostPort(address, "443")
		}
		out = append(out, address)
	}
	return out
}

func (r *Relay) Port() int {
	return r.listener.Addr().(*net.TCPAddr).Port
}

func (r *Relay) SetOutbound(outbound OutboundFunc) {
	if outbound == nil {
		r.outbound.Store(nil)
		return
	}
	r.outbound.Store(&outbound)
	r.releaseHeld()
}

func (r *Relay) SetEndpoints(addresses []string) {
	if len(addresses) == 0 {
		addresses = DefaultEndpoints
	}
	r.endpoints.replace(normalizeEndpoints(addresses))
}

// Stop ends the listener and every session.
func (r *Relay) Stop() {
	r.cancel()
	_ = r.listener.Close()
	r.ResetConnections()
	done := make(chan struct{})
	go func() {
		r.wg.Wait()
		close(done)
	}()
	select {
	case <-done:
	case <-time.After(stopWaitLimit):
	}
}

// ResetConnections drops every session and forgets remembered failures. A changed network or a
// TUN that came up invalidates the sockets and the routes they proved; Telegram reconnects at once.
func (r *Relay) ResetConnections() {
	r.mu.Lock()
	for session := range r.sessions {
		_ = session.Close()
	}
	for _, state := range r.dcs {
		state.mu.Lock()
		state.ws.succeed()
		state.outbound.succeed()
		state.mu.Unlock()
	}
	r.mu.Unlock()
	r.endpoints.clearBackoff()
}

func (r *Relay) acceptLoop() {
	delay := 10 * time.Millisecond
	for {
		conn, err := r.listener.Accept()
		if err != nil {
			if r.ctx.Err() != nil || errors.Is(err, net.ErrClosed) {
				return
			}
			// Out of descriptors: stay alive, a dead proxy is the worst failure here.
			r.config.Logf("accept: %v", err)
			select {
			case <-time.After(delay):
			case <-r.ctx.Done():
				return
			}
			delay = min(delay*2, time.Second)
			continue
		}
		delay = 10 * time.Millisecond
		if r.clients.Load() >= maxClients {
			_ = conn.Close()
			continue
		}
		r.clients.Add(1)
		r.track(conn)
		r.wg.Go(func() {
			defer r.clients.Add(-1)
			defer r.untrack(conn)
			defer conn.Close()
			r.serve(conn)
		})
	}
}

func (r *Relay) track(session io.Closer) {
	r.mu.Lock()
	defer r.mu.Unlock()
	if r.ctx.Err() != nil {
		_ = session.Close()
		return
	}
	r.sessions[session] = struct{}{}
}

func (r *Relay) untrack(session io.Closer) {
	r.mu.Lock()
	defer r.mu.Unlock()
	delete(r.sessions, session)
}

func (r *Relay) dc(number int) *dcState {
	r.mu.Lock()
	defer r.mu.Unlock()
	state := r.dcs[number]
	if state == nil {
		state = &dcState{route: RouteIdle}
		r.dcs[number] = state
	}
	return state
}

func (r *Relay) serve(client net.Conn) {
	_ = client.SetReadDeadline(time.Now().Add(clientHeaderTimeout))
	var header [headerSize]byte
	if _, err := io.ReadFull(client, header[:]); err != nil {
		return
	}
	_ = client.SetReadDeadline(time.Time{})
	clientStreams, tag, index, err := openClientHeader(header[:], r.config.Secret)
	if err != nil {
		r.badSecrets.Add(1)
		return
	}
	dest, ok := resolveTarget(index)
	if !ok {
		r.config.Logf("client asked for unknown dc %d", index)
		return
	}
	state := r.dc(dest.dc)

	ctx, cancel := context.WithTimeout(r.ctx, connectBudget)
	started := r.now()
	up, route, endpointUsed, err := r.connect(ctx, dest, state)
	cancel()
	if err != nil {
		r.config.Logf("dc=%d media=%v tag=%08x unavailable: %v", dest.dc, dest.media, tag, err)
		state.mu.Lock()
		state.route = RouteUnavailable
		state.lastError = err.Error()
		if errors.Is(err, errNoRoute) || errors.Is(err, ErrNoOutbound) {
			state.fastFails++
		} else {
			state.failures++
		}
		state.mu.Unlock()
		if errors.Is(err, errNoRoute) || errors.Is(err, ErrNoOutbound) {
			r.hold(client)
		}
		return
	}
	defer up.Close()
	r.track(up)
	defer r.untrack(up)

	connectTime := r.now().Sub(started)
	state.mu.Lock()
	state.route = route
	state.connects++
	state.connectMs = connectTime.Milliseconds()
	state.lastConnect = r.now()
	state.lastError = ""
	state.mu.Unlock()
	state.active.Add(1)
	defer state.active.Add(-1)
	r.config.Logf("dc=%d media=%v tag=%08x route=%s connect=%dms", dest.dc, dest.media, tag, route, connectTime.Milliseconds())

	r.pump(client, up, clientStreams, tag, dest, state, endpointUsed, started)
}

// connect tries WebSocket on DCs that have it, then the outbound. Remembered failures fail at once.
func (r *Relay) connect(ctx context.Context, dest target, state *dcState) (upstream, Route, *endpoint, error) {
	var firstErr error
	if dest.overWebSocket() {
		now := r.now()
		state.mu.Lock()
		allowed := state.ws.allow(now)
		state.mu.Unlock()
		if allowed {
			up, used, err := r.connectWebSocket(ctx, dest)
			state.mu.Lock()
			if err == nil {
				state.ws.succeed()
			} else {
				state.ws.fail(r.now(), backoffMax)
			}
			state.mu.Unlock()
			if err == nil {
				return up, RouteWebSocket, used, nil
			}
			firstErr = err
		} else {
			firstErr = errNoRoute
		}
	}
	up, err := r.connectOutbound(ctx, dest, state)
	if err == nil {
		return up, RouteOutbound, nil, nil
	}
	if firstErr != nil && errors.Is(err, ErrNoOutbound) {
		return nil, "", nil, firstErr
	}
	return nil, "", nil, err
}

func kwsHosts(dest target) []string {
	main := "kws" + strconv.Itoa(dest.hostDC) + ".web.telegram.org"
	if dest.media {
		return []string{"kws" + strconv.Itoa(dest.hostDC) + "-1.web.telegram.org", main}
	}
	return []string{main}
}

func (r *Relay) connectWebSocket(ctx context.Context, dest target) (upstream, *endpoint, error) {
	candidates := r.endpoints.candidates(r.now())
	if len(candidates) == 0 {
		return nil, nil, errNoRoute
	}
	var lastErr error
	for i, e := range candidates {
		ws, latency, err := r.dialEndpoint(ctx, e.address, kwsHosts(dest))
		if err == nil {
			r.endpoints.reportSuccess(e, latency)
			if i > 0 {
				r.config.Logf("failed over to endpoint %s", e.address)
			}
			return ws, e, nil
		}
		lastErr = err
		r.endpoints.reportFailure(e, r.now(), err)
		r.config.Logf("endpoint %s: %v", e.address, err)
		r.reprobeSoon()
		if ctx.Err() != nil {
			break
		}
	}
	return nil, nil, lastErr
}

// dialEndpoint opens TCP once and walks the hosts over fresh connections only when a host, rather
// than the address, turned out to be the problem.
func (r *Relay) dialEndpoint(ctx context.Context, address string, hosts []string) (*webSocket, time.Duration, error) {
	ctx, cancel := context.WithTimeout(ctx, endpointBudget)
	defer cancel()
	started := r.now()
	var lastErr error
	for _, host := range hosts {
		raw, tries, err := dialHedged(ctx, r.config.Dial, address, dialAttempts, dialStagger)
		if err != nil {
			return nil, 0, fmt.Errorf("tcp after %d tries: %w", tries, err)
		}
		ws, err := upgradeWebSocket(ctx, raw, host, r.config.TLS)
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

func (r *Relay) connectOutbound(ctx context.Context, dest target, state *dcState) (upstream, error) {
	outbound := r.outbound.Load()
	if outbound == nil {
		return nil, ErrNoOutbound
	}
	now := r.now()
	state.mu.Lock()
	allowed := state.outbound.allow(now)
	state.mu.Unlock()
	if !allowed {
		return nil, errNoRoute
	}
	ctx, cancel := context.WithTimeout(ctx, outboundBudget)
	defer cancel()
	var lastErr error
	for _, address := range dcAddresses[dest.dc] {
		conn, err := (*outbound)(ctx, address)
		if err == nil {
			state.mu.Lock()
			state.outbound.succeed()
			state.mu.Unlock()
			return &tcpUpstream{conn: conn}, nil
		}
		lastErr = err
		if errors.Is(err, ErrNoOutbound) {
			return nil, err
		}
	}
	state.mu.Lock()
	state.outbound.fail(r.now(), backoffMax)
	state.mu.Unlock()
	return nil, lastErr
}

// pump re-encrypts both directions until either side ends.
func (r *Relay) pump(client net.Conn, up upstream, clientStreams streams, tag uint32, dest target, state *dcState, used *endpoint, started time.Time) {
	header, telegram := newHeader(tag, dest.index, nil)
	up.add(header)
	if err := up.flush(); err != nil {
		return
	}
	done := make(chan error, 2)
	var sawDownlink atomic.Bool
	var sentUp atomic.Bool
	go func() { done <- r.pumpUp(client, up, clientStreams, telegram, tag, state, &sentUp) }()
	go func() { done <- r.pumpDown(client, up, clientStreams, telegram, state, &sawDownlink) }()
	err := <-done
	_ = client.Close()
	_ = up.Close()
	<-done
	// An address that accepts the upgrade and then swallows traffic looks healthy to every dial.
	if used != nil && !sawDownlink.Load() && r.now().Sub(started) >= silentUpstreamMinAge && sentUp.Load() {
		r.endpoints.reportSilent(used)
		r.reprobeSoon()
	}
	r.config.Logf("dc=%d media=%v closed after %s: %v", dest.dc, dest.media, r.now().Sub(started).Round(time.Millisecond), err)
}

// Refused at once, Telegram redials a DC it wants about twice a second for as
// long as it wants that file, which measured as a steady wakeup on a phone.
func (r *Relay) hold(client net.Conn) {
	wait := r.config.holdUnavailable
	if wait == 0 {
		wait = unavailableHold
	}
	if wait < 0 {
		return
	}
	r.mu.Lock()
	r.held[client] = struct{}{}
	r.mu.Unlock()
	defer func() {
		r.mu.Lock()
		delete(r.held, client)
		r.mu.Unlock()
	}()
	_ = client.SetReadDeadline(time.Now().Add(wait))
	_, _ = io.Copy(io.Discard, client)
}

func (r *Relay) releaseHeld() {
	r.mu.Lock()
	defer r.mu.Unlock()
	for client := range r.held {
		_ = client.Close()
	}
}

func (r *Relay) pumpUp(client net.Conn, up upstream, clientStreams, telegram streams, tag uint32, state *dcState, sent *atomic.Bool) error {
	_, unframed := up.(*tcpUpstream)
	split := splitter{tag: tag, disabled: unframed}
	emit := func(packet []byte) {
		telegram.send.XORKeyStream(packet, packet)
		up.add(packet)
	}
	buf := make([]byte, copyBufferSize)
	for {
		n, err := client.Read(buf)
		if n > 0 {
			plain := buf[:n]
			clientStreams.send.XORKeyStream(plain, plain)
			split.feed(plain, emit)
			if flushErr := up.flush(); flushErr != nil {
				return flushErr
			}
			sent.Store(true)
			state.bytesUp.Add(uint64(n))
		}
		if err != nil {
			return err
		}
	}
}

func (r *Relay) pumpDown(client net.Conn, up upstream, clientStreams, telegram streams, state *dcState, saw *atomic.Bool) error {
	buf := make([]byte, copyBufferSize)
	for {
		n, err := up.recv(buf)
		if n > 0 {
			chunk := buf[:n]
			telegram.recv.XORKeyStream(chunk, chunk)
			clientStreams.recv.XORKeyStream(chunk, chunk)
			_ = client.SetWriteDeadline(time.Now().Add(clientWriteTimeout))
			if _, writeErr := client.Write(chunk); writeErr != nil {
				return writeErr
			}
			saw.Store(true)
			state.bytesDown.Add(uint64(n))
			r.lastTraffic.Store(r.now().UnixMilli())
		}
		if err != nil {
			return err
		}
	}
}

// Status is a consistent-enough snapshot for a screen: counters are read without stopping traffic.
func (r *Relay) Status() Status {
	status := Status{
		Port:        r.Port(),
		Clients:     r.clients.Load(),
		BadSecrets:  r.badSecrets.Load(),
		LastTraffic: r.lastTraffic.Load(),
		HasOutbound: r.outbound.Load() != nil,
		Endpoints:   r.endpoints.snapshot(),
	}
	r.mu.Lock()
	numbers := make([]int, 0, len(r.dcs))
	states := make([]*dcState, 0, len(r.dcs))
	for number, state := range r.dcs {
		numbers = append(numbers, number)
		states = append(states, state)
	}
	r.mu.Unlock()
	for i, state := range states {
		state.mu.Lock()
		dc := DCStatus{
			DC:        numbers[i],
			Route:     state.route,
			Connects:  state.connects,
			Failures:  state.failures,
			FastFails: state.fastFails,
			ConnectMs: state.connectMs,
			LastError: state.lastError,
		}
		if !state.lastConnect.IsZero() {
			dc.LastConnect = state.lastConnect.UnixMilli()
		}
		state.mu.Unlock()
		dc.Active = state.active.Load()
		dc.BytesUp = state.bytesUp.Load()
		dc.BytesDown = state.bytesDown.Load()
		status.BytesUp += dc.BytesUp
		status.BytesDown += dc.BytesDown
		status.DCs = append(status.DCs, dc)
	}
	return status
}
