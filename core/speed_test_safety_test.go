package core

import (
	"context"
	"errors"
	"net"
	"net/http"
	"net/http/httptest"
	"net/netip"
	"slices"
	"sync"
	"testing"

	"github.com/metacubex/mihomo/component/resolver"
	"github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/tunnel"
)

func (r *speedTestResolver) Invalid() bool { return true }

type speedTestMetadataProxy struct {
	constant.Proxy
	mu    sync.Mutex
	hosts []string
}

func (p *speedTestMetadataProxy) DialContext(ctx context.Context, metadata *constant.Metadata) (constant.Conn, error) {
	p.mu.Lock()
	p.hosts = append(p.hosts, metadata.Host)
	p.mu.Unlock()
	return p.Proxy.DialContext(ctx, metadata)
}

func TestSpeedTestSystemDNSIsNormalizedOffForPinnedAndRuleRoutes(t *testing.T) {
	oldDefault, oldDirect, oldSystem, oldIPv6 := resolver.DefaultResolver, resolver.DirectHostResolver, resolver.SystemResolver, resolver.DisableIPv6
	t.Cleanup(func() {
		resolver.DefaultResolver, resolver.DirectHostResolver, resolver.SystemResolver, resolver.DisableIPv6 = oldDefault, oldDirect, oldSystem, oldIPv6
	})
	coreDNS := &speedTestResolver{ips: []netip.Addr{netip.MustParseAddr("127.0.0.1")}}
	systemDNS := &speedTestResolver{err: errors.New("system DNS must not be used")}
	resolver.DefaultResolver, resolver.DirectHostResolver, resolver.SystemResolver, resolver.DisableIPv6 = coreDNS, coreDNS, systemDNS, true
	direct := &speedTestMetadataProxy{Proxy: namedProxy("DIRECT")}
	pinned := &speedTestMetadataProxy{Proxy: namedProxy("pinned")}
	tunnel.UpdateProxies(map[string]constant.Proxy{"DIRECT": direct, "pinned": pinned}, nil)
	t.Cleanup(func() { tunnel.UpdateProxies(nil, nil) })
	tunnel.OnRunning()
	t.Cleanup(tunnel.OnSuspend)
	fixture := &speedTestFixture{}
	server := httptest.NewServer(http.HandlerFunc(fixture.serve))
	defer server.Close()
	_, port, _ := net.SplitHostPort(server.Listener.Addr().String())
	for _, proxy := range []string{"", "pinned"} {
		for _, requested := range []bool{false, true} {
			params := speedTestTestParams(t, "latencyOnly")
			params.Direct, params.ProxyName, params.UseSystemDNS = false, proxy, requested
			normalized, err := normalizeSpeedTestParams(params)
			if err != nil || normalized.UseSystemDNS {
				t.Fatalf("non-direct DNS normalization = %+v, %v", normalized, err)
			}
			run := newSpeedTestRun(params)
			run.prepare = func(context.Context, *speedTestRun) (*speedTestTarget, error) {
				return &speedTestTarget{backend: "cloudflare", latencyURL: "http://speed-test.invalid:" + port + "/latency"}, nil
			}
			run.run()
			state := run.snapshot()
			want := "DIRECT"
			if proxy != "" {
				want = proxy
			}
			if state.Phase != "done" || !slices.Equal(state.Chains, []string{want}) || run.transport.params.UseSystemDNS {
				t.Fatalf("route changed under DNS toggle: %+v", state)
			}
		}
	}
	if systemDNS.calls.Load() != 0 || coreDNS.calls.Load() == 0 {
		t.Fatalf("resolver calls: system=%d core=%d", systemDNS.calls.Load(), coreDNS.calls.Load())
	}
	for _, proxy := range []*speedTestMetadataProxy{direct, pinned} {
		proxy.mu.Lock()
		hosts := slices.Clone(proxy.hosts)
		proxy.mu.Unlock()
		if len(hosts) == 0 {
			t.Fatal("route was never dialed")
		}
		for _, host := range hosts {
			if host != "speed-test.invalid" {
				t.Fatalf("Host was lost before outbound selection: %q", host)
			}
		}
	}
	transport, err := newSpeedTestTransport(context.Background(), SpeedTestParams{ProxyName: "pinned", UseSystemDNS: true})
	if err != nil {
		t.Fatal(err)
	}
	defer transport.close()
	packet, _, err := transport.listenUDP(context.Background(), "speed-test.invalid:443")
	if err != nil {
		t.Fatal(err)
	}
	packet.close()
	if systemDNS.calls.Load() != 0 {
		t.Fatal("pinned HTTP3 used the system resolver")
	}
}

func TestSpeedTestDirectSystemDNSFailureNeverFallsBackToCoreDNS(t *testing.T) {
	oldDefault, oldDirect, oldSystem, oldIPv6 := resolver.DefaultResolver, resolver.DirectHostResolver, resolver.SystemResolver, resolver.DisableIPv6
	t.Cleanup(func() {
		resolver.DefaultResolver, resolver.DirectHostResolver, resolver.SystemResolver, resolver.DisableIPv6 = oldDefault, oldDirect, oldSystem, oldIPv6
	})
	coreDNS := &speedTestResolver{ips: []netip.Addr{netip.MustParseAddr("127.0.0.1")}}
	systemDNS := &speedTestResolver{err: errors.New("system DNS failed")}
	resolver.DefaultResolver, resolver.DirectHostResolver, resolver.SystemResolver, resolver.DisableIPv6 = coreDNS, coreDNS, systemDNS, true
	fixture := &speedTestFixture{}
	server := httptest.NewServer(http.HandlerFunc(fixture.serve))
	defer server.Close()
	_, port, _ := net.SplitHostPort(server.Listener.Addr().String())
	params := speedTestTestParams(t, "latencyOnly")
	params.UseSystemDNS = true
	run := newSpeedTestRun(params)
	run.prepare = func(context.Context, *speedTestRun) (*speedTestTarget, error) {
		return &speedTestTarget{backend: "cloudflare", latencyURL: "http://speed-test.invalid:" + port + "/latency"}, nil
	}
	run.run()
	if run.snapshot().Phase != "failed" || fixture.latencies.Load() != 0 || systemDNS.calls.Load() == 0 || coreDNS.calls.Load() != 0 {
		t.Fatalf("DNS failure escaped its resolver: %+v, system=%d core=%d", run.snapshot(), systemDNS.calls.Load(), coreDNS.calls.Load())
	}
}

func TestSpeedTestAutomaticServerProbesConsumeTheSharedBudget(t *testing.T) {
	fixture := &speedTestFixture{}
	server := httptest.NewServer(http.HandlerFunc(fixture.serve))
	defer server.Close()
	transport, err := newSpeedTestTransport(context.Background(), SpeedTestParams{Direct: true})
	if err != nil {
		t.Fatal(err)
	}
	defer transport.close()
	budget := newSpeedTestBudget(128 * 1024)
	targets := []*speedTestTarget{speedTestLocalTarget(server), speedTestLocalTarget(server)}
	measureSpeedTestTargets(context.Background(), transport, targets, 3, budget)
	if fixture.latencies.Load() != 6 || budget.spent() != 24 || budget.used[speedTestDownload] != 0 || budget.used[speedTestUpload] != 0 {
		t.Fatalf("automatic selection accounting: requests=%d spent=%d", fixture.latencies.Load(), budget.spent())
	}
}
