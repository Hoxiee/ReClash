package telegram

import (
	"context"
	"crypto/tls"
	"errors"
	"fmt"
	"io"
	"net"
	"strings"
	"sync"
	"sync/atomic"
	"time"
)

const (
	clientHeaderTimeout = 10 * time.Second
	clientWriteTimeout  = 2 * time.Minute
	maxClients          = 1024
	copyBufferSize      = 32 << 10

	connectBudget        = 45 * time.Second
	outboundBudget       = 10 * time.Second
	reprobeInterval      = time.Minute
	probeTimeout         = 10 * time.Second
	stopWaitLimit        = 3 * time.Second
	silentUpstreamMinAge = 3 * time.Second
	unavailableHold      = 5 * time.Second
	bridgeReadTimeout    = 2 * time.Minute
	bridgePingInterval   = 30 * time.Second
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
	// CFDomains are the user's own Cloudflare base domains, tried before the built-in list.
	CFDomains []string
	// CFWorkerDomains serve /apiws?dst=&dc= and are tried before CF base domains.
	CFWorkerDomains []string
	// FakeTLSDomain enables the ee secret and masks unauthenticated TLS with this site.
	FakeTLSDomain string
	// ProxyProtocol reads a PROXY protocol v1 line before the MTProto header.
	ProxyProtocol bool
	// Targets overrides the IP a DC is dialled at; negative keys cover media connections.
	Targets map[int]string
	// TestDC sends every DC to Telegram's test infrastructure.
	TestDC bool
	// DisableSecure uses port 80 for Cloudflare and worker connections.
	DisableSecure bool
	// CFFetch downloads the hosted domain list; nil means CFDomainsURL over plain HTTPS.
	CFFetch CFFetchFunc
	Logf    func(format string, args ...any)

	holdUnavailable time.Duration
	poolSize        int
	poolMaxAge      time.Duration
	clock           func() time.Time
}

// Route is how a DC is currently reached.
type Route string

const (
	RouteIdle             Route = "idle"
	RouteWebSocket        Route = "websocket"
	RouteCloudflare       Route = "cloudflare"
	RouteCloudflareWorker Route = "cloudflare-worker"
	RouteTCP              Route = "tcp"
	RouteOutbound         Route = "outbound"
	RouteUnavailable      Route = "unavailable"
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
	Pooled      int    `json:"pooled"`
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
	HTTPRejects uint64           `json:"httpRejects"`
	Masked      uint64           `json:"masked"`
	PoolHits    uint64           `json:"poolHits"`
	PoolMisses  uint64           `json:"poolMisses"`
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
	steps       [stepCount]backoff
	sticky      step
	hasSticky   bool
	wsBlocked   bool
	wsFailUntil time.Time
	ipFailUntil map[string]time.Time
}

// Relay is one running proxy. Its lifetime is the caller's; it holds no global state.
type Relay struct {
	config    Config
	listener  net.Listener
	endpoints *endpointSet
	cf        cfList
	cfSlots   chan struct{}
	pool      *wsPool
	outbound  atomic.Pointer[OutboundFunc]
	now       func() time.Time

	ctx    context.Context
	cancel context.CancelFunc
	wg     sync.WaitGroup

	mu       sync.Mutex
	sessions map[io.Closer]struct{}
	held     map[net.Conn]struct{}
	dcs      map[int]*dcState
	targets  map[int]string
	workers  []string

	clients     atomic.Int64
	badSecrets  atomic.Uint64
	httpRejects atomic.Uint64
	masked      atomic.Uint64
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
	if config.FakeTLSDomain != "" && !validHostname(config.FakeTLSDomain) {
		return nil, fmt.Errorf("telegram: invalid fake tls domain %q", config.FakeTLSDomain)
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
		cfSlots:   make(chan struct{}, cfGlobalParallel),
		now:       time.Now,
		ctx:       ctx,
		cancel:    cancel,
		sessions:  make(map[io.Closer]struct{}),
		held:      make(map[net.Conn]struct{}),
		dcs:       make(map[int]*dcState),
		targets:   cloneTargets(config.Targets),
		workers:   cleanUserDomains(config.CFWorkerDomains),
	}
	if config.clock != nil {
		r.now = config.clock
	}
	r.pool = newWSPool(r)
	r.SetOutbound(config.Outbound)
	r.cf.setUser(config.CFDomains)
	if r.config.CFFetch == nil {
		r.config.CFFetch = fetchCFDomains
	}
	r.wg.Go(r.acceptLoop)
	r.wg.Go(r.cfRefreshLoop)
	r.wg.Go(r.pool.run)
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
	r.pool.drain()
}

func (r *Relay) SetCFDomains(domains []string) {
	r.cf.setUser(domains)
}

func (r *Relay) SetCFWorkerDomains(domains []string) {
	r.mu.Lock()
	defer r.mu.Unlock()
	r.workers = cleanUserDomains(domains)
}

func (r *Relay) workerDomains() []string {
	r.mu.Lock()
	defer r.mu.Unlock()
	return append([]string(nil), r.workers...)
}

func (r *Relay) SetTargets(targets map[int]string) {
	r.mu.Lock()
	r.targets = cloneTargets(targets)
	r.mu.Unlock()
	r.pool.drain()
}

func cloneTargets(targets map[int]string) map[int]string {
	if len(targets) == 0 {
		return nil
	}
	out := make(map[int]string, len(targets))
	for dc, address := range targets {
		if address != "" {
			out[dc] = address
		}
	}
	return out
}

// targetOverride names the address a DC should be dialled at, preferring the media key.
func (r *Relay) targetOverride(dest target) string {
	r.mu.Lock()
	defer r.mu.Unlock()
	if dest.media {
		if address := r.targets[-dest.dc]; address != "" {
			return address
		}
	}
	return r.targets[dest.dc]
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
		state.steps = [stepCount]backoff{}
		state.hasSticky = false
		state.wsBlocked = false
		state.wsFailUntil = time.Time{}
		state.ipFailUntil = nil
		state.mu.Unlock()
	}
	r.mu.Unlock()
	r.endpoints.clearBackoff()
	r.pool.drain()
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
	if r.config.ProxyProtocol && !r.readProxyLine(client) {
		return
	}
	conn := client
	if r.config.FakeTLSDomain != "" {
		_ = client.SetReadDeadline(time.Now().Add(clientHeaderTimeout))
		var first [1]byte
		if _, err := io.ReadFull(client, first[:]); err != nil {
			return
		}
		if first[0] != tlsRecordHandshake {
			r.badSecrets.Add(1)
			_ = client.SetWriteDeadline(time.Now().Add(clientHeaderTimeout))
			_, _ = io.WriteString(client, "HTTP/1.1 301 Moved Permanently\r\nLocation: https://"+
				r.config.FakeTLSDomain+"/\r\nContent-Length: 0\r\nConnection: close\r\n\r\n")
			return
		}
		var ok bool
		if conn, ok = r.serveFakeTLS(client, first[0]); !ok {
			return
		}
	}
	r.serveStream(conn)
}

func (r *Relay) readProxyLine(client net.Conn) bool {
	_ = client.SetReadDeadline(time.Now().Add(clientHeaderTimeout))
	var line []byte
	var one [1]byte
	for len(line) <= 108 {
		if _, err := io.ReadFull(client, one[:]); err != nil {
			return false
		}
		line = append(line, one[0])
		if one[0] == '\n' {
			break
		}
	}
	_ = client.SetReadDeadline(time.Time{})
	fields := strings.Fields(string(line))
	if len(fields) >= 6 && fields[0] == "PROXY" {
		r.config.Logf("proxy protocol client %s:%s", fields[2], fields[4])
	}
	return true
}

func (r *Relay) serveStream(client net.Conn) {
	_ = client.SetReadDeadline(time.Now().Add(clientHeaderTimeout))
	var header [headerSize]byte
	if _, err := io.ReadFull(client, header[:]); err != nil {
		return
	}
	_ = client.SetReadDeadline(time.Time{})
	if isHTTPTransport(header[:]) {
		r.httpRejects.Add(1)
		_ = client.SetWriteDeadline(time.Now().Add(clientHeaderTimeout))
		_, _ = io.WriteString(client, "HTTP/1.1 404 Not Found\r\nConnection: close\r\n\r\n")
		return
	}
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
	if r.config.TestDC {
		dest.test = true
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

func isHTTPTransport(data []byte) bool {
	if len(data) < 4 {
		return false
	}
	switch string(data[:4]) {
	case "POST", "HEAD", "OPTI":
		return true
	}
	return string(data[:3]) == "GET"
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
	var lastActivity atomic.Int64
	lastActivity.Store(time.Now().UnixNano())
	pumpCtx, stop := context.WithCancel(r.ctx)
	defer stop()
	go r.keepAlive(pumpCtx, up, &lastActivity)
	go func() { done <- r.pumpUp(client, up, clientStreams, telegram, tag, state, &sentUp, &lastActivity) }()
	go func() { done <- r.pumpDown(client, up, clientStreams, telegram, state, &sawDownlink, &lastActivity) }()
	err := <-done
	stop()
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

// keepAlive pings an idle WebSocket. A proxy path that stays open but silent is what mobile
// networks and Cloudflare drop first, and a pong keeps the read deadline from expiring.
func (r *Relay) keepAlive(ctx context.Context, up upstream, last *atomic.Int64) {
	pinger, ok := up.(interface{ ping() error })
	if !ok {
		return
	}
	ticker := time.NewTicker(bridgePingInterval)
	defer ticker.Stop()
	for {
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
			if time.Since(time.Unix(0, last.Load())) < bridgePingInterval {
				continue
			}
			if err := pinger.ping(); err != nil {
				return
			}
		}
	}
}

func (r *Relay) pumpUp(client net.Conn, up upstream, clientStreams, telegram streams, tag uint32, state *dcState, sent *atomic.Bool, last *atomic.Int64) error {
	_, unframed := up.(*tcpUpstream)
	split := splitter{tag: tag, disabled: unframed}
	emit := func(packet []byte) {
		telegram.send.XORKeyStream(packet, packet)
		up.add(packet)
	}
	buf := make([]byte, copyBufferSize)
	for {
		_ = client.SetReadDeadline(time.Now().Add(bridgeReadTimeout))
		n, err := client.Read(buf)
		if n > 0 {
			last.Store(time.Now().UnixNano())
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

func (r *Relay) pumpDown(client net.Conn, up upstream, clientStreams, telegram streams, state *dcState, saw *atomic.Bool, last *atomic.Int64) error {
	buf := make([]byte, copyBufferSize)
	for {
		up.setDeadline(time.Now().Add(bridgeReadTimeout))
		n, err := up.recv(buf)
		if n > 0 {
			last.Store(time.Now().UnixNano())
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
		HTTPRejects: r.httpRejects.Load(),
		Masked:      r.masked.Load(),
		PoolHits:    uint64(r.pool.hits.Load()),
		PoolMisses:  uint64(r.pool.misses.Load()),
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
		dc.Pooled = r.pool.count(numbers[i])
		status.BytesUp += dc.BytesUp
		status.BytesDown += dc.BytesDown
		status.DCs = append(status.DCs, dc)
	}
	return status
}
