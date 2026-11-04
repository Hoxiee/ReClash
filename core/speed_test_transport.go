package core

import (
	"context"
	"errors"
	"io"
	"net"
	"net/netip"
	"net/url"
	"slices"
	"strconv"
	"sync"
	"time"

	"github.com/metacubex/http"
	"github.com/metacubex/mihomo/component/ca"
	"github.com/metacubex/mihomo/component/dialer"
	"github.com/metacubex/mihomo/component/resolver"
	"github.com/metacubex/mihomo/constant"
	"github.com/metacubex/quic-go"
	"github.com/metacubex/quic-go/http3"
	mtls "github.com/metacubex/tls"
)

type speedTestClient struct {
	*http.Client
	owner   *speedTestTransport
	cancel  context.CancelFunc
	once    sync.Once
	release func()
}

func (c *speedTestClient) close() {
	c.once.Do(func() {
		c.cancel()
		c.release()
		c.owner.mu.Lock()
		delete(c.owner.clients, c)
		c.owner.mu.Unlock()
	})
}

type speedTestTransport struct {
	params SpeedTestParams
	ctx    context.Context
	cancel context.CancelFunc

	mu      sync.Mutex
	closed  bool
	clients map[*speedTestClient]struct{}
	conns   map[*speedTestConn]struct{}
	packets map[*speedTestPacket]struct{}
	serial  uint64
	last    uint64
	chains  []string
	hits    []RouteHit
}

func newSpeedTestTransport(parent context.Context, params SpeedTestParams) (*speedTestTransport, error) {
	params.UseSystemDNS = params.Direct && params.UseSystemDNS
	if err := validateSpeedTestProxy(params.ProxyName); err != nil {
		return nil, err
	}
	ctx, cancel := context.WithCancel(parent)
	return &speedTestTransport{
		params: params, ctx: ctx, cancel: cancel,
		clients: make(map[*speedTestClient]struct{}), conns: make(map[*speedTestConn]struct{}),
		packets: make(map[*speedTestPacket]struct{}), chains: []string{}, hits: []RouteHit{},
	}, nil
}

func (t *speedTestTransport) newClient(protocol string) (*speedTestClient, error) {
	tlsConfig, err := ca.GetTLSConfig(ca.Option{})
	if err != nil {
		return nil, err
	}
	ctx, cancel := context.WithCancel(t.ctx)
	client := &speedTestClient{owner: t, cancel: cancel}
	if protocol == "h3" {
		transport := &http3.Transport{
			TLSClientConfig: tlsConfig, DisableCompression: true, MaxResponseHeaderBytes: 64 * 1024,
			QUICConfig: &quic.Config{HandshakeIdleTimeout: speedTestLatencyTimeout, MaxIdleTimeout: speedTestRequestTimeout},
			Dial: func(requestCtx context.Context, address string, tlsConfig *mtls.Config, config *quic.Config) (*quic.Conn, error) {
				dialCtx, stop := speedTestDialContext(requestCtx, ctx)
				defer stop()
				packet, remote, err := t.listenUDP(dialCtx, address)
				if err != nil {
					return nil, err
				}
				conn, err := quic.DialEarly(dialCtx, packet.conn, remote, tlsConfig, config)
				if err != nil {
					packet.close()
					return nil, err
				}
				safeGo("speedTestQUICSocket", func() {
					<-conn.Context().Done()
					packet.close()
				})
				return conn, nil
			},
		}
		client.Client = &http.Client{Transport: transport}
		client.release = func() { _ = transport.Close() }
	} else {
		transport := &http.Transport{
			DialContext: func(requestCtx context.Context, network, address string) (net.Conn, error) {
				dialCtx, stop := speedTestDialContext(requestCtx, ctx)
				defer stop()
				return t.dial(dialCtx, network, address)
			},
			TLSClientConfig: tlsConfig, ForceAttemptHTTP2: protocol == "h2",
			DisableCompression: true, TLSHandshakeTimeout: speedTestRequestTimeout,
			ResponseHeaderTimeout: speedTestRequestTimeout, IdleConnTimeout: 30 * time.Second,
			MaxIdleConns: 1, MaxIdleConnsPerHost: 1, MaxConnsPerHost: 1,
			MaxResponseHeaderBytes: 64 * 1024,
		}
		if protocol == "h1" {
			transport.TLSNextProto = map[string]func(string, http.TLSConn) http.RoundTripper{}
		}
		client.Client = &http.Client{Transport: transport}
		client.release = transport.CloseIdleConnections
	}
	client.Timeout = speedTestRequestTimeout
	client.CheckRedirect = func(*http.Request, []*http.Request) error { return http.ErrUseLastResponse }
	t.mu.Lock()
	if t.closed {
		t.mu.Unlock()
		client.close()
		return nil, context.Canceled
	}
	t.clients[client] = struct{}{}
	t.mu.Unlock()
	return client, nil
}

// HTTP transports may detach a dial from a cancelled request to reuse it later.
func speedTestDialContext(request, lifetime context.Context) (context.Context, context.CancelFunc) {
	ctx, cancel := context.WithTimeout(request, speedTestRequestTimeout)
	safeGo("speedTestDialLifetime", func() {
		select {
		case <-lifetime.Done():
			cancel()
		case <-ctx.Done():
		}
	})
	return ctx, cancel
}

type speedTestConn struct {
	net.Conn
	owner  *speedTestTransport
	probe  *probeDialer
	host   string
	proxy  string
	serial uint64
	direct bool
	once   sync.Once
}

func (c *speedTestConn) Close() error {
	var err error
	c.once.Do(func() {
		c.owner.observe(c)
		err = c.Conn.Close()
		c.owner.mu.Lock()
		delete(c.owner.conns, c)
		c.owner.mu.Unlock()
	})
	return err
}

func (t *speedTestTransport) dial(ctx context.Context, network, address string) (net.Conn, error) {
	if err := ctx.Err(); err != nil {
		return nil, err
	}
	if err := validateSpeedTestProxy(t.params.ProxyName); err != nil {
		return nil, err
	}
	tracked := &speedTestConn{owner: t, host: address, proxy: t.params.ProxyName, direct: t.params.Direct}
	var err error
	if t.params.Direct {
		host, port, splitErr := net.SplitHostPort(address)
		if splitErr != nil {
			return nil, splitErr
		}
		ip, resolveErr := speedTestResolveIP(ctx, host, t.params.UseSystemDNS, true)
		if resolveErr != nil {
			return nil, resolveErr
		}
		tracked.Conn, err = dialer.DialContext(ctx, network, net.JoinHostPort(ip.String(), port))
		tracked.proxy = "DIRECT"
	} else {
		tracked.probe = &probeDialer{}
		if t.params.ProxyName != "" {
			tracked.probe.proxy = lookupProxy(t.params.ProxyName)
			if tracked.probe.proxy == nil {
				return nil, errors.New("speed test proxy disappeared")
			}
		}
		tracked.Conn, err = tracked.probe.dial(ctx, network, address)
	}
	if err != nil {
		return nil, err
	}
	t.mu.Lock()
	if t.closed || ctx.Err() != nil {
		t.mu.Unlock()
		_ = tracked.Conn.Close()
		return nil, context.Canceled
	}
	t.serial++
	tracked.serial = t.serial
	t.conns[tracked] = struct{}{}
	t.mu.Unlock()
	return tracked, nil
}

func speedTestResolveIP(ctx context.Context, host string, system, direct bool) (netip.Addr, error) {
	if ip, err := netip.ParseAddr(host); err == nil {
		return ip.Unmap(), nil
	}
	r := resolver.DefaultResolver
	if direct && resolver.DirectHostResolver != nil {
		r = resolver.DirectHostResolver
	}
	if system {
		r = resolver.SystemResolver
	}
	if r == nil {
		return netip.Addr{}, errors.New("speed test DNS resolver is not configured")
	}
	var ips []netip.Addr
	var err error
	if resolver.DisableIPv6 {
		ips, err = r.LookupIPv4(ctx, host)
	} else {
		ips, err = r.LookupIP(ctx, host)
	}
	if err != nil {
		return netip.Addr{}, err
	}
	for _, ip := range ips {
		if ip.Unmap().Is4() {
			return ip.Unmap(), nil
		}
	}
	if len(ips) > 0 && ips[0].IsValid() && !resolver.DisableIPv6 {
		return ips[0], nil
	}
	return netip.Addr{}, resolver.ErrIPNotFound
}

func (t *speedTestTransport) canHTTP3(target *speedTestTarget) bool {
	base, err := url.Parse(target.latencyURL)
	if err != nil || base.Scheme != "https" {
		return false
	}
	for _, endpoint := range []string{target.downloadURL, target.uploadURL} {
		u, err := url.Parse(endpoint)
		if err != nil || u.Scheme != "https" || u.Host != base.Host {
			return false
		}
	}
	if t.params.Direct {
		return true
	}
	proxy := lookupProxy(t.params.ProxyName)
	return t.params.ProxyName != "" && proxy != nil && proxy.SupportUDP() &&
		!isProxyGroupType(proxy.Type()) && proxy.Type() != constant.Reject && proxy.Type() != constant.RejectDrop
}

type speedTestPacket struct {
	conn  net.PacketConn
	owner *speedTestTransport
	once  sync.Once
}

func (p *speedTestPacket) close() {
	p.once.Do(func() {
		_ = p.conn.Close()
		p.owner.mu.Lock()
		delete(p.owner.packets, p)
		p.owner.mu.Unlock()
	})
}

func (t *speedTestTransport) listenUDP(ctx context.Context, address string) (*speedTestPacket, net.Addr, error) {
	host, portText, err := net.SplitHostPort(address)
	if err != nil {
		return nil, nil, err
	}
	port, err := strconv.ParseUint(portText, 10, 16)
	if err != nil || port == 0 {
		return nil, nil, errors.New("invalid speed test UDP port")
	}
	if err := validateSpeedTestProxy(t.params.ProxyName); err != nil {
		return nil, nil, err
	}
	var proxy constant.Proxy
	if !t.params.Direct {
		proxy = lookupProxy(t.params.ProxyName)
		if proxy == nil || !proxy.SupportUDP() || isProxyGroupType(proxy.Type()) {
			return nil, nil, errors.New("speed test UDP route is not guaranteed")
		}
	}
	ip, err := speedTestResolveIP(ctx, host, t.params.UseSystemDNS, t.params.Direct)
	if err != nil {
		return nil, nil, err
	}
	remote := netip.AddrPortFrom(ip, uint16(port))
	var conn net.PacketConn
	chains, pinned := []string{"DIRECT"}, "DIRECT"
	if proxy == nil {
		conn, err = dialer.ListenPacket(ctx, "udp", "", remote)
	} else {
		metadata := &constant.Metadata{
			NetWork: constant.UDP, Type: constant.INNER, DNSMode: constant.DNSNormal,
			Process: constant.MihomoName, Host: host, DstIP: ip, DstPort: uint16(port),
		}
		var packet constant.PacketConn
		packet, err = proxy.ListenPacketContext(ctx, metadata)
		if err == nil {
			conn, chains, pinned = packet, slices.Clone(packet.Chains()), t.params.ProxyName
		}
	}
	if err != nil {
		return nil, nil, err
	}
	packet := &speedTestPacket{conn: conn, owner: t}
	t.mu.Lock()
	if t.closed || ctx.Err() != nil {
		t.mu.Unlock()
		_ = conn.Close()
		return nil, nil, context.Canceled
	}
	t.serial++
	t.recordLocked(address, pinned, chains, t.serial)
	t.packets[packet] = struct{}{}
	t.mu.Unlock()
	return packet, net.UDPAddrFromAddrPort(remote), nil
}

func (t *speedTestTransport) recordLocked(host, proxy string, chains []string, serial uint64) {
	hit := RouteHit{Host: host, Proxy: proxy, Exit: exitOfChains(chains)}
	t.hits = withHit(t.hits, hit)
	if len(t.hits) > speedTestMaxHits {
		t.hits = t.hits[len(t.hits)-speedTestMaxHits:]
	}
	if len(chains) != 0 && serial >= t.last {
		t.last = serial
		t.chains = slices.Clone(chains[:min(len(chains), speedTestMaxHits)])
	}
}

func (t *speedTestTransport) observe(conn *speedTestConn) {
	var chains []string
	if conn.direct {
		chains = []string{"DIRECT"}
	} else if route := conn.probe.route(); route != nil {
		chains = route.chains
	}
	t.mu.Lock()
	t.recordLocked(conn.host, conn.proxy, chains, conn.serial)
	t.mu.Unlock()
}

func (t *speedTestTransport) evidence() ([]string, []RouteHit) {
	t.mu.Lock()
	conns := make([]*speedTestConn, 0, len(t.conns))
	for conn := range t.conns {
		conns = append(conns, conn)
	}
	t.mu.Unlock()
	for _, conn := range conns {
		t.observe(conn)
	}
	t.mu.Lock()
	defer t.mu.Unlock()
	return slices.Clone(t.chains), slices.Clone(t.hits)
}

func (t *speedTestTransport) close() {
	t.cancel()
	t.mu.Lock()
	if t.closed {
		t.mu.Unlock()
		return
	}
	t.closed = true
	clients := make([]*speedTestClient, 0, len(t.clients))
	for client := range t.clients {
		clients = append(clients, client)
	}
	conns := make([]*speedTestConn, 0, len(t.conns))
	for conn := range t.conns {
		conns = append(conns, conn)
	}
	packets := make([]*speedTestPacket, 0, len(t.packets))
	for packet := range t.packets {
		packets = append(packets, packet)
	}
	t.mu.Unlock()
	for _, conn := range conns {
		_ = conn.Close()
	}
	for _, packet := range packets {
		packet.close()
	}
	for _, client := range clients {
		client.close()
	}
}

func newSpeedTestRequest(ctx context.Context, method, endpoint string, body io.Reader) (*http.Request, error) {
	req, err := http.NewRequestWithContext(ctx, method, endpoint, body)
	if err != nil {
		return nil, err
	}
	req.Header.Set("Accept-Encoding", "identity")
	req.Header.Set("Cache-Control", "no-store")
	return req, nil
}

func checkSpeedTestResponse(response *http.Response) error {
	if response.StatusCode < 200 || response.StatusCode >= 300 {
		return errors.New("speed test endpoint refused the request")
	}
	if encoding := response.Header.Get("Content-Encoding"); encoding != "" && encoding != "identity" {
		return errors.New("encoded speed test response")
	}
	return nil
}

func readSpeedTestResponse(body io.Reader, limit int64) ([]byte, error) {
	data, err := io.ReadAll(io.LimitReader(body, limit+1))
	if int64(len(data)) > limit {
		return nil, errors.New("oversized speed test response")
	}
	return data, err
}

func fetchSpeedTestMetadata(ctx context.Context, client *speedTestClient, endpoint string) ([]byte, *http.Response, error) {
	ctx, cancel := context.WithTimeout(ctx, speedTestRequestTimeout)
	defer cancel()
	req, err := newSpeedTestRequest(ctx, http.MethodGet, endpoint, nil)
	if err != nil {
		return nil, nil, err
	}
	response, err := client.Do(req)
	if err != nil {
		return nil, nil, err
	}
	defer response.Body.Close()
	if err := checkSpeedTestResponse(response); err != nil {
		return nil, response, err
	}
	body, err := readSpeedTestResponse(response.Body, speedTestMaxResponse)
	return body, response, err
}

func (r *speedTestRun) setupProtocol(target *speedTestTarget) error {
	protocols := []string{"h1"}
	if r.params.Protocol != "h1" {
		protocols = []string{"h2", "h1"}
	}
	if r.params.Protocol == "h3" && r.transport.canHTTP3(target) {
		protocols = append([]string{"h3"}, protocols...)
	}
	var effective string
	for _, protocol := range protocols {
		client, err := r.transport.newClient(protocol)
		if err != nil {
			return err
		}
		if protocol == "h1" {
			r.latency, effective = client, protocol
			break
		}
		_, response, err := r.latencyOnce(r.ctx, client, target)
		if err == nil {
			r.latency, effective = client, "h1"
			if response.ProtoMajor == 2 {
				effective = "h2"
			} else if response.ProtoMajor == 3 {
				effective = "h3"
			}
			break
		}
		client.close()
		if r.ctx.Err() != nil {
			return r.ctx.Err()
		}
	}
	r.update(func(state *SpeedTestSnapshot) {
		state.Protocol, state.ProtocolFallback = effective, effective != r.params.Protocol
	})
	var err error
	r.probe, err = r.transport.newClient(effective)
	if err != nil {
		return err
	}
	if r.params.Mode == "complete" {
		for range r.params.Streams {
			client, err := r.transport.newClient(effective)
			if err != nil {
				return err
			}
			r.load = append(r.load, client)
		}
	}
	return nil
}
