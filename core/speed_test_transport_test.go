package core

import (
	"context"
	"errors"
	"net"
	"net/http"
	"net/http/httptest"
	"net/netip"
	"slices"
	"strconv"
	"sync/atomic"
	"testing"
	"time"

	mh "github.com/metacubex/http"
	"github.com/metacubex/mihomo/component/resolver"
	"github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/tunnel"
	"github.com/metacubex/quic-go/http3"
	mtls "github.com/metacubex/tls"
)

type speedTestRouteProxy struct {
	constant.Proxy
	kind  constant.AdapterType
	udp   bool
	fail  bool
	calls atomic.Int32
}

func (p *speedTestRouteProxy) Type() constant.AdapterType { return p.kind }
func (p *speedTestRouteProxy) SupportUDP() bool           { return p.udp }
func (p *speedTestRouteProxy) DialContext(ctx context.Context, metadata *constant.Metadata) (constant.Conn, error) {
	p.calls.Add(1)
	if p.fail {
		return nil, errors.New("proxy unavailable")
	}
	return p.Proxy.DialContext(ctx, metadata)
}

func TestSpeedTestMissingRejectedAndFailingProxiesNeverFallBackDirect(t *testing.T) {
	var requests atomic.Int32
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		requests.Add(1)
		w.WriteHeader(http.StatusNoContent)
	}))
	defer server.Close()
	reject := &speedTestRouteProxy{Proxy: namedProxy("reject"), kind: constant.Reject}
	failing := &speedTestRouteProxy{Proxy: namedProxy("failing"), kind: constant.Shadowsocks, fail: true}
	tunnel.UpdateProxies(map[string]constant.Proxy{"reject": reject, "failing": failing}, nil)
	t.Cleanup(func() { tunnel.UpdateProxies(nil, nil) })
	for _, direct := range []bool{false, true} {
		for _, name := range []string{"missing", "reject"} {
			params := speedTestTestParams(t, "latencyOnly")
			params.Direct, params.ProxyName = direct, name
			manager := &speedTestManager{}
			if ok, err := manager.start(params); ok || err == nil {
				t.Fatalf("accepted %s with direct=%v", name, direct)
			}
			if transport, err := newSpeedTestTransport(context.Background(), params); transport != nil || err == nil {
				t.Fatalf("created transport for %s", name)
			}
		}
	}
	transport, err := newSpeedTestTransport(context.Background(), SpeedTestParams{ProxyName: "failing"})
	if err != nil {
		t.Fatal(err)
	}
	defer transport.close()
	client, err := transport.newClient("h2")
	if err != nil {
		t.Fatal(err)
	}
	if _, _, err := speedTestPing(context.Background(), client, &speedTestTarget{latencyURL: server.URL}, nil); err == nil {
		t.Fatal("failing proxy returned a response")
	}
	if requests.Load() != 0 || reject.calls.Load() != 0 || failing.calls.Load() == 0 {
		t.Fatalf("external requests=%d reject dials=%d failing dials=%d", requests.Load(), reject.calls.Load(), failing.calls.Load())
	}
}

func TestSpeedTestPinnedTCPReportsActualChainsAndRouteStamp(t *testing.T) {
	withProbeProxies(t, "node-a")
	epoch, version := routeStamp()
	stampRoute(12, 34)
	t.Cleanup(func() { stampRoute(epoch, version) })
	run := speedTestLocalRun(t, "latencyOnly", &speedTestFixture{})
	run.params.Direct, run.params.ProxyName, run.params.Protocol = false, "node-a", "h3"
	run.run()
	state := run.snapshot()
	if state.Phase != "done" || !slices.Equal(state.Chains, []string{"node-a"}) || state.CoreEpoch != 12 || state.RouteVersion != 34 {
		t.Fatalf("routed result = %+v", state)
	}
	if len(state.Hits) != 1 || state.Hits[0].Proxy != "node-a" || state.Hits[0].Exit == "" {
		t.Fatalf("route hits = %+v", state.Hits)
	}
	if state.Protocol != "h1" || !state.ProtocolFallback {
		t.Fatalf("HTTP3 fallback = %s, %v", state.Protocol, state.ProtocolFallback)
	}
}

func TestSpeedTestUnnamedTCPUsesTheExistingTunnelRoute(t *testing.T) {
	withProbeProxies(t, "DIRECT")
	tunnel.OnRunning()
	t.Cleanup(tunnel.OnSuspend)
	run := speedTestLocalRun(t, "latencyOnly", &speedTestFixture{})
	run.params.Direct = false
	run.run()
	state := run.snapshot()
	if state.Phase != "done" || !slices.Equal(state.Chains, []string{"DIRECT"}) || len(state.Hits) != 1 || state.Hits[0].Proxy != "" || state.Hits[0].Exit == "" {
		t.Fatalf("tunnel result = %+v", state)
	}
}

func TestSpeedTestHTTP3RequiresAnExplicitStableUDPRoute(t *testing.T) {
	group := &speedTestRouteProxy{Proxy: namedProxy("group"), kind: constant.Selector, udp: true}
	udp := &speedTestRouteProxy{Proxy: namedProxy("udp"), kind: constant.Shadowsocks, udp: true}
	tcp := &speedTestRouteProxy{Proxy: namedProxy("tcp"), kind: constant.Shadowsocks}
	tunnel.UpdateProxies(map[string]constant.Proxy{"group": group, "udp": udp, "tcp": tcp}, nil)
	t.Cleanup(func() { tunnel.UpdateProxies(nil, nil) })
	target := &speedTestTarget{latencyURL: "https://example.invalid/latency", downloadURL: "https://example.invalid/down", uploadURL: "https://example.invalid/up"}
	for _, test := range []struct {
		params SpeedTestParams
		want   bool
	}{
		{params: SpeedTestParams{Direct: true}, want: true},
		{params: SpeedTestParams{}, want: false},
		{params: SpeedTestParams{ProxyName: "group"}, want: false},
		{params: SpeedTestParams{ProxyName: "udp"}, want: true},
		{params: SpeedTestParams{ProxyName: "tcp"}, want: false},
	} {
		transport, err := newSpeedTestTransport(context.Background(), test.params)
		if err != nil {
			t.Fatal(err)
		}
		if got := transport.canHTTP3(target); got != test.want {
			t.Fatalf("UDP route %+v = %v, want %v", test.params, got, test.want)
		}
		if !test.want {
			if _, _, err := transport.listenUDP(context.Background(), "example.invalid:443"); err == nil {
				t.Fatal("an unguaranteed UDP route was opened")
			}
		}
		transport.close()
	}
}

type speedTestResolver struct {
	resolver.Resolver
	ips   []netip.Addr
	err   error
	calls atomic.Int32
}

func (r *speedTestResolver) LookupIPv4(context.Context, string) ([]netip.Addr, error) {
	r.calls.Add(1)
	return r.ips, r.err
}

func (r *speedTestResolver) LookupIP(ctx context.Context, host string) ([]netip.Addr, error) {
	return r.LookupIPv4(ctx, host)
}

func TestSpeedTestDNSNeverUsesAnImplicitSystemFallback(t *testing.T) {
	oldDefault, oldDirect, oldSystem, oldIPv6 := resolver.DefaultResolver, resolver.DirectHostResolver, resolver.SystemResolver, resolver.DisableIPv6
	t.Cleanup(func() {
		resolver.DefaultResolver, resolver.DirectHostResolver, resolver.SystemResolver, resolver.DisableIPv6 = oldDefault, oldDirect, oldSystem, oldIPv6
	})
	coreDNS := &speedTestResolver{err: errors.New("configured DNS failed")}
	systemDNS := &speedTestResolver{ips: []netip.Addr{netip.MustParseAddr("127.0.0.1")}}
	resolver.DefaultResolver, resolver.DirectHostResolver, resolver.SystemResolver, resolver.DisableIPv6 = coreDNS, nil, systemDNS, true
	if _, err := speedTestResolveIP(context.Background(), "example.invalid", false, true); err == nil || coreDNS.calls.Load() != 1 || systemDNS.calls.Load() != 0 {
		t.Fatal("configured DNS failure escaped through the system resolver")
	}
	resolver.DefaultResolver = nil
	if _, err := speedTestResolveIP(context.Background(), "example.invalid", false, false); err == nil || systemDNS.calls.Load() != 0 {
		t.Fatal("missing Core DNS escaped through the system resolver")
	}
	if ip, err := speedTestResolveIP(context.Background(), "example.invalid", true, false); err != nil || ip.String() != "127.0.0.1" || systemDNS.calls.Load() != 1 {
		t.Fatalf("explicit system DNS = %s, %v", ip, err)
	}
	if ip, err := speedTestResolveIP(context.Background(), "127.0.0.1", false, true); err != nil || ip.String() != "127.0.0.1" || systemDNS.calls.Load() != 1 {
		t.Fatal("an IP literal used DNS")
	}
}

func TestSpeedTestNativeHTTP2NegotiatesOnThePermittedRoute(t *testing.T) {
	server := httptest.NewUnstartedServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) { w.WriteHeader(http.StatusNoContent) }))
	server.EnableHTTP2 = true
	server.StartTLS()
	defer server.Close()
	transport, err := newSpeedTestTransport(context.Background(), SpeedTestParams{Direct: true})
	if err != nil {
		t.Fatal(err)
	}
	defer transport.close()
	client, err := transport.newClient("h2")
	if err != nil {
		t.Fatal(err)
	}
	client.Transport.(*mh.Transport).TLSClientConfig.InsecureSkipVerify = true
	_, response, err := speedTestPing(context.Background(), client, &speedTestTarget{latencyURL: server.URL}, nil)
	if err != nil || response.ProtoMajor != 2 {
		t.Fatalf("HTTP2 response=%+v err=%v", response, err)
	}
}

func TestSpeedTestNativeHTTP3ClosesItsUDPSocket(t *testing.T) {
	certificateServer := httptest.NewTLSServer(http.HandlerFunc(func(http.ResponseWriter, *http.Request) {}))
	certificate := certificateServer.TLS.Certificates[0]
	certificateServer.Close()
	packet, err := net.ListenPacket("udp", "127.0.0.1:0")
	if err != nil {
		t.Fatal(err)
	}
	server := &http3.Server{
		TLSConfig: &mtls.Config{Certificates: []mtls.Certificate{{Certificate: certificate.Certificate, PrivateKey: certificate.PrivateKey}}},
		Handler:   mh.HandlerFunc(func(w mh.ResponseWriter, _ *mh.Request) { w.WriteHeader(mh.StatusNoContent) }),
	}
	serverDone := make(chan struct{})
	safeGo("testSpeedTestHTTP3Server", func() {
		defer close(serverDone)
		_ = server.Serve(packet)
	})
	t.Cleanup(func() {
		_ = server.Close()
		_ = packet.Close()
		awaitSpeedTest(t, serverDone)
	})
	transport, err := newSpeedTestTransport(context.Background(), SpeedTestParams{Direct: true})
	if err != nil {
		t.Fatal(err)
	}
	defer transport.close()
	client, err := transport.newClient("h3")
	if err != nil {
		t.Fatal(err)
	}
	client.Transport.(*http3.Transport).TLSClientConfig.InsecureSkipVerify = true
	_, response, err := speedTestPing(context.Background(), client, &speedTestTarget{latencyURL: "https://" + packet.LocalAddr().String()}, nil)
	if err != nil || response.ProtoMajor != 3 {
		t.Fatalf("HTTP3 response=%+v err=%v", response, err)
	}
	chains, hits := transport.evidence()
	if !slices.Equal(chains, []string{"DIRECT"}) || len(hits) != 1 || hits[0].Proxy != "DIRECT" {
		t.Fatalf("HTTP3 route chains=%v hits=%v", chains, hits)
	}
	transport.close()
	transport.mu.Lock()
	resources := len(transport.clients) + len(transport.conns) + len(transport.packets)
	transport.mu.Unlock()
	if resources != 0 {
		t.Fatalf("HTTP3 retained %d resources", resources)
	}
}

func TestSpeedTestRouteEvidenceAndCancellationRemainBounded(t *testing.T) {
	transport, err := newSpeedTestTransport(context.Background(), SpeedTestParams{Direct: true})
	if err != nil {
		t.Fatal(err)
	}
	defer transport.close()
	transport.mu.Lock()
	for index := range 1000 {
		transport.recordLocked("host-"+strconv.Itoa(index), "DIRECT", []string{"DIRECT"}, uint64(index))
	}
	transport.mu.Unlock()
	_, hits := transport.evidence()
	if len(hits) != speedTestMaxHits {
		t.Fatalf("retained %d route hits", len(hits))
	}
	ctx, cancel := context.WithCancel(context.Background())
	dial, stop := speedTestDialContext(context.Background(), ctx)
	defer stop()
	cancel()
	select {
	case <-dial.Done():
	case <-time.After(time.Second):
		t.Fatal("detached dial outlived its transport")
	}
}
