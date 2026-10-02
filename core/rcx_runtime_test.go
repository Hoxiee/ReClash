package main

import (
	"context"
	"net"
	"net/http"
	"net/http/httptest"
	"net/netip"
	"sync"
	"sync/atomic"
	"testing"
	"time"

	"github.com/metacubex/mihomo/adapter"
	"github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/tunnel"

	"core/rcx"
)

func rcxForgetHost(t *testing.T, host string) {
	t.Helper()
	t.Cleanup(func() {
		rcxResolveMu.Lock()
		delete(rcxResolveHosts, host)
		rcxResolveMu.Unlock()
	})
}

func rcxSeedHost(host string, entry rcxResolvedHost) {
	rcxResolveMu.Lock()
	rcxResolveHosts[host] = entry
	rcxResolveMu.Unlock()
}

func TestResolveHostAnswersFromCacheAndFillsInLater(t *testing.T) {
	const host = "node.example"
	rcxForgetHost(t, host)
	restore := rcxResolveIP
	t.Cleanup(func() { rcxResolveIP = restore })
	rcxResolveIP = func(context.Context, string) (netip.Addr, error) {
		return netip.MustParseAddr("203.0.113.7"), nil
	}

	if got := rcxResolveHost(host); got.IsValid() {
		t.Fatalf("addr = %v on the first ask: the decision loop must not wait on DNS", got)
	}

	deadline := time.Now().Add(2 * time.Second)
	for !rcxResolveHost(host).IsValid() {
		if time.Now().After(deadline) {
			t.Fatal("the resolved address never reached the cache, so origin stays unknown forever")
		}
		time.Sleep(time.Millisecond)
	}
}

func TestResolveHostRetriesAFailureOnlyAfterTheFloor(t *testing.T) {
	const host = "gone.example"
	rcxForgetHost(t, host)
	var calls atomic.Int32
	restore := rcxResolveIP
	t.Cleanup(func() { rcxResolveIP = restore })
	rcxResolveIP = func(context.Context, string) (netip.Addr, error) {
		calls.Add(1)
		return netip.Addr{}, context.DeadlineExceeded
	}

	rcxSeedHost(host, rcxResolvedHost{at: time.Now()})
	if got := rcxResolveHost(host); got.IsValid() {
		t.Fatalf("addr = %v, want nothing for a host that just failed", got)
	}
	if got := calls.Load(); got != 0 {
		t.Fatalf("resolves = %d, want 0: a fresh failure must not be re-asked every tick", got)
	}

	rcxSeedHost(host, rcxResolvedHost{at: time.Now().Add(-rcxResolveRetry - time.Second)})
	rcxResolveHost(host)

	deadline := time.Now().Add(2 * time.Second)
	for calls.Load() == 0 {
		if time.Now().After(deadline) {
			t.Fatal("a failure older than the retry floor must buy a new resolve")
		}
		time.Sleep(time.Millisecond)
	}
}

func TestMmdbGuardIsSpacedOutButNotAnsweredOnce(t *testing.T) {
	rcxMmdbMu.Lock()
	ok, at := rcxMmdbOK, rcxMmdbCheckAt
	rcxMmdbMu.Unlock()
	t.Cleanup(func() {
		rcxMmdbMu.Lock()
		rcxMmdbOK, rcxMmdbCheckAt = ok, at
		rcxMmdbMu.Unlock()
	})

	now := time.Now()
	rcxMmdbMu.Lock()
	rcxMmdbOK, rcxMmdbCheckAt = true, now
	rcxMmdbMu.Unlock()

	if !rcxMmdbUsable(now.Add(rcxMmdbRecheck / 2)) {
		t.Error("the database was verified moments ago: opening it again per node is the cost")
	}

	rcxMmdbUsable(now.Add(rcxMmdbRecheck + time.Second))

	rcxMmdbMu.Lock()
	checked := rcxMmdbCheckAt
	rcxMmdbMu.Unlock()
	if !checked.After(now) {
		t.Error("a geo update resets the loader's once, so the guard has to run again")
	}
}

func rcxClosedServerURL(t *testing.T) string {
	t.Helper()
	server := httptest.NewServer(http.HandlerFunc(func(http.ResponseWriter, *http.Request) {}))
	url := server.URL
	server.Close()
	return url
}

func rcxLiveServerURL(t *testing.T) string {
	t.Helper()
	server := httptest.NewServer(http.HandlerFunc(func(http.ResponseWriter, *http.Request) {}))
	t.Cleanup(server.Close)
	return server.URL
}

func TestHostDelayValueRefusesAnAnswerFasterThanAnyRemote(t *testing.T) {
	if delay, dead := rcxHostDelayValue(1); delay != 0 || dead {
		t.Errorf("delay = %d, dead = %v: a millisecond answer is local, so it is unknown rather than fast", delay, dead)
	}
	if delay, dead := rcxHostDelayValue(rcxHostDelayUnknown); delay != 0 || dead {
		t.Errorf("delay = %d, dead = %v: an unmeasured node reads unknown", delay, dead)
	}
	if delay, dead := rcxHostDelayValue(120); delay != 120 || dead {
		t.Errorf("delay = %d, dead = %v, want 120: a plausible measurement is the park-wide latency source", delay, dead)
	}
}

func TestHostDelayTreatsAForeignFailureAsSilence(t *testing.T) {
	node := namedProxy("node")
	foreign := rcxClosedServerURL(t)
	ours := rcxLiveServerURL(t)

	if _, err := node.URLTest(context.Background(), foreign, nil); err == nil {
		t.Fatal("the setup needs the node to fail under the foreign URL")
	}

	if _, dead, _ := rcxHostDelayInfo(node, ours); dead {
		t.Error("a failure under another test URL condemned the node: mihomo's global alive flag is not a record under ours")
	}
}

func TestHostDelayCondemnsOnlyUnderItsOwnURL(t *testing.T) {
	node := namedProxy("node")
	ours := rcxClosedServerURL(t)
	foreign := rcxLiveServerURL(t)

	previous := currentTestURL()
	setTestURL(ours)
	t.Cleanup(func() { setTestURL(previous) })
	if _, err := rcxHostProbes.test(context.Background(), node, ours); err == nil {
		t.Fatal("the setup needs the node to fail under our own URL")
	}
	if _, dead, _ := rcxHostDelayInfo(node, ours); !dead {
		t.Error("a failed record under our own URL must stay a verdict")
	}

	if _, err := node.URLTest(context.Background(), foreign, nil); err != nil {
		t.Fatalf("the node must answer under the foreign URL: %v", err)
	}
	if _, dead, _ := rcxHostDelayInfo(node, ours); !dead {
		t.Error("a foreign success masked the failed record under our URL")
	}
}

type rcxHostProbeAdapter struct {
	constant.ProxyAdapter
	started chan context.Context
	release <-chan struct{}
}

func (p rcxHostProbeAdapter) DialContext(ctx context.Context, metadata *constant.Metadata) (constant.Conn, error) {
	p.started <- ctx
	select {
	case <-p.release:
		return p.ProxyAdapter.DialContext(ctx, metadata)
	case <-ctx.Done():
		return nil, ctx.Err()
	}
}

type rcxSweepContext struct {
	context.Context
	onDone func()
}

func (c rcxSweepContext) Done() <-chan struct{} {
	c.onDone()
	return c.Context.Done()
}

func rcxHoldDelayTestSlots(t *testing.T, count int) func() {
	t.Helper()
	held := 0
	release := sync.OnceFunc(func() {
		for held > 0 {
			releaseDelayTestSlot()
			held--
		}
	})
	t.Cleanup(release)
	ctx, cancel := context.WithTimeout(context.Background(), rcxHostProbeDial+time.Second)
	defer cancel()
	for held < count {
		if !acquireDelayTestSlot(ctx) {
			t.Fatalf("acquired %d of %d delay-test slots", held, count)
		}
		held++
	}
	return release
}

func rcxInstallSweepProxies(t *testing.T, nodes ...*adapter.Proxy) {
	t.Helper()
	previous := currentTestURL()
	setTestURL(rcxLiveServerURL(t))
	proxies := make(map[string]constant.Proxy, len(nodes))
	for _, node := range nodes {
		proxies[node.Name()] = node
	}
	tunnel.UpdateProxies(proxies, nil)
	t.Cleanup(func() {
		rcxHoldDelayTestSlots(t, cap(delayTestSlots))()
		settleMessageBatcher()
		setTestURL(previous)
		tunnel.UpdateProxies(nil, nil)
	})
}

func rcxAwaitHostSweep(t *testing.T, done <-chan struct{}) {
	t.Helper()
	select {
	case <-done:
	case <-time.After(time.Second):
		t.Fatal("host sweep did not return after admission closed")
	}
}

func rcxRunHostSweep(t *testing.T, ctx context.Context, cancel context.CancelFunc, nodes ...string) <-chan struct{} {
	t.Helper()
	done := make(chan struct{})
	go func() {
		(rcxCoreRuntime{}).Sweep(ctx, nodes)
		close(done)
	}()
	t.Cleanup(func() {
		cancel()
		rcxAwaitHostSweep(t, done)
	})
	return done
}

func rcxAwaitHostProbe(t *testing.T, started <-chan context.Context) context.Context {
	t.Helper()
	select {
	case ctx := <-started:
		return ctx
	case <-time.After(time.Second):
		t.Fatal("admitted host probe did not start")
		return nil
	}
}

func TestCoreRuntimeSweepKeepsTheAdmittedProbeBudget(t *testing.T) {
	for _, stop := range []string{"deadline", "cancel"} {
		t.Run(stop, func(t *testing.T) {
			started := make(chan context.Context, 1)
			queued := make(chan context.Context, 1)
			release := make(chan struct{})
			node := adapter.NewProxy(rcxHostProbeAdapter{
				ProxyAdapter: namedProxy("node").Adapter(), started: started, release: release,
			})
			waiting := adapter.NewProxy(rcxHostProbeAdapter{
				ProxyAdapter: namedProxy("waiting").Adapter(), started: queued, release: release,
			})
			rcxInstallSweepProxies(t, node, waiting)
			rcxHoldDelayTestSlots(t, cap(delayTestSlots)-1)
			releaseQueue := rcxHoldDelayTestSlots(t, 1)
			ctx, cancel := context.WithTimeout(context.Background(), time.Second)
			admission := make(chan struct{})
			observed := rcxSweepContext{
				Context: ctx, onDone: sync.OnceFunc(func() { close(admission) }),
			}
			done := rcxRunHostSweep(t, observed, cancel, "node", "waiting")
			releaseProbe := sync.OnceFunc(func() { close(release) })
			t.Cleanup(releaseProbe)

			select {
			case <-admission:
			case <-ctx.Done():
				t.Fatal("host sweep never reached the full semaphore")
			}
			time.Sleep(100 * time.Millisecond)
			admittedAfter := time.Now()
			releaseQueue()
			probeCtx := rcxAwaitHostProbe(t, started)
			deadline, bounded := probeCtx.Deadline()
			if !bounded || deadline.Before(admittedAfter.Add(rcxHostProbeDial)) || deadline.After(time.Now().Add(rcxHostProbeDial)) {
				t.Errorf("probe deadline = %v, bounded = %v: want a full, independent %v budget", deadline, bounded, rcxHostProbeDial)
			}
			if stop == "cancel" {
				cancel()
			}
			<-ctx.Done()
			rcxAwaitHostSweep(t, done)
			if err := probeCtx.Err(); err != nil {
				t.Errorf("started probe inherited admission cancellation: %v", err)
			}
			releaseProbe()
			rcxHoldDelayTestSlots(t, 1)()
			if _, dead, at := rcxHostDelayInfo(node, currentTestURL()); dead || at.IsZero() {
				t.Errorf("dead = %v, measured at = %v: the admitted probe must record its successful answer", dead, at)
			}
			if len(queued) != 0 || len(waiting.ExtraDelayHistories()) != 0 {
				t.Fatal("the queued node was tested after admission closed")
			}
		})
	}
}

func TestCoreRuntimeSweepSkipsCanceledAdmission(t *testing.T) {
	tests := []struct {
		name    string
		context func() (context.Context, context.CancelFunc)
	}{
		{
			name: "already canceled",
			context: func() (context.Context, context.CancelFunc) {
				ctx, cancel := context.WithCancel(context.Background())
				cancel()
				return ctx, cancel
			},
		},
		{
			name: "already expired",
			context: func() (context.Context, context.CancelFunc) {
				return context.WithDeadline(context.Background(), time.Now().Add(-time.Second))
			},
		},
		{
			name: "cancel races available slot",
			context: func() (context.Context, context.CancelFunc) {
				ctx, cancel := context.WithCancel(context.Background())
				return rcxSweepContext{Context: ctx, onDone: sync.OnceFunc(cancel)}, cancel
			},
		},
	}
	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			started := make(chan context.Context, 32)
			release := make(chan struct{})
			close(release)
			node := adapter.NewProxy(rcxHostProbeAdapter{
				ProxyAdapter: namedProxy("node").Adapter(), started: started, release: release,
			})
			rcxInstallSweepProxies(t, node)
			for attempt := 0; attempt < cap(started); attempt++ {
				ctx, cancel := test.context()
				(rcxCoreRuntime{}).Sweep(ctx, []string{"node"})
				cancel()
			}
			rcxHoldDelayTestSlots(t, cap(delayTestSlots))()
			if len(started) != 0 || len(node.ExtraDelayHistories()) != 0 {
				t.Fatalf("started probes = %d, histories = %v: canceled admission must not reach URLTest", len(started), node.ExtraDelayHistories())
			}
		})
	}
}

func TestCoreRuntimeSweepBoundsStartedProbes(t *testing.T) {
	started := make(chan context.Context, 1)
	node := adapter.NewProxy(rcxHostProbeAdapter{
		ProxyAdapter: namedProxy("node").Adapter(), started: started,
	})
	rcxInstallSweepProxies(t, node)
	ctx, cancel := context.WithCancel(context.Background())
	done := rcxRunHostSweep(t, ctx, cancel, "node")
	probeCtx := rcxAwaitHostProbe(t, started)
	cancel()
	rcxAwaitHostSweep(t, done)
	select {
	case <-probeCtx.Done():
	case <-time.After(rcxHostProbeDial + time.Second):
		t.Fatal("started host probe outlived its own timeout")
	}
	if err := probeCtx.Err(); err != context.DeadlineExceeded {
		t.Errorf("probe error = %v, want its own deadline rather than admission cancellation", err)
	}
	rcxHoldDelayTestSlots(t, cap(delayTestSlots))()
	if _, dead, at := rcxHostDelayInfo(node, currentTestURL()); !dead || at.IsZero() {
		t.Errorf("dead = %v, measured at = %v: exhausting the full probe budget must remain a failed measurement", dead, at)
	}
}

// The gate under test accepts the handshake and answers TLS with a certificate
// the public pool does not root, which is the signature a whitelist MITM leaves.
func TestVerifyTLSRejectsAForgedChain(t *testing.T) {
	server := httptest.NewTLSServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(http.StatusNoContent)
	}))
	t.Cleanup(server.Close)

	remote := server.Listener.Addr().String()
	host, port, err := net.SplitHostPort(remote)
	if err != nil {
		t.Fatalf("split %s: %v", remote, err)
	}
	address := host + ":" + port
	if ip, err := netip.ParseAddr(host); err == nil {
		address = ip.String() + ":" + port
	}
	conn, err := net.Dial("tcp", remote)
	if err != nil {
		t.Fatalf("dial: %v", err)
	}
	t.Cleanup(func() { _ = conn.Close() })

	got := rcxVerifyTLS(context.Background(), conn, address)
	if got != rcx.ProbeStatusMismatch {
		t.Errorf("outcome = %s, want mismatch: a self-signed answer is not an open network", rcx.OutcomeName(got))
	}
}

func installRcxTopology(t *testing.T, groups map[string][]string) {
	t.Helper()
	proxies := make(map[string]constant.Proxy, len(groups))
	for name, members := range groups {
		proxies[name] = selectorGroup(t, name, members...)
	}
	tunnel.UpdateProxies(proxies, nil)
	t.Cleanup(func() { tunnel.UpdateProxies(nil, nil) })
}

func TestCoreRuntimeAcceptsOnlyTheGeneratedRcxTopology(t *testing.T) {
	installRcxTopology(t, map[string][]string{
		rcx.GroupNode:   {"node"},
		rcx.GroupDirect: {"DIRECT", rcx.GroupNode},
		rcx.GroupFinal:  {rcx.GroupNode, "DIRECT"},
	})

	if !(rcxCoreRuntime{}).TopologyValid(rcx.DefaultConfig()) {
		t.Fatal("the generated selector skeleton was rejected")
	}
}

func TestCoreRuntimeRejectsIncompleteOrReorderedRcxTopology(t *testing.T) {
	tests := []struct {
		name   string
		groups map[string][]string
	}{
		{
			name: "missing final",
			groups: map[string][]string{
				rcx.GroupNode:   {"node"},
				rcx.GroupDirect: {"DIRECT", rcx.GroupNode},
			},
		},
		{
			name: "reordered direct",
			groups: map[string][]string{
				rcx.GroupNode:   {"node"},
				rcx.GroupDirect: {rcx.GroupNode, "DIRECT"},
				rcx.GroupFinal:  {rcx.GroupNode, "DIRECT"},
			},
		},
	}
	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			installRcxTopology(t, tc.groups)
			if (rcxCoreRuntime{}).TopologyValid(rcx.DefaultConfig()) {
				t.Fatal("a user-owned or malformed reserved topology activated RCX")
			}
		})
	}
}

func TestCoreRuntimeRequiresConfiguredLaneShape(t *testing.T) {
	config := rcx.DefaultConfig()
	config.Lanes = []rcx.LaneConfig{{
		ID: "gemini", Group: "RCX-CAP-GEMINI_ACCESS", Fallback: rcx.LaneFallbackMain,
	}}
	installRcxTopology(t, map[string][]string{
		rcx.GroupNode:           {"node"},
		rcx.GroupDirect:         {"DIRECT", rcx.GroupNode},
		rcx.GroupFinal:          {rcx.GroupNode, "DIRECT"},
		"RCX-CAP-GEMINI_ACCESS": {"REJECT", "node"},
	})

	if (rcxCoreRuntime{}).TopologyValid(config) {
		t.Fatal("a lane missing RCX-NODE fallback activated RCX")
	}
}

func TestParseEchoCountry(t *testing.T) {
	cases := map[string]string{
		"RU":                              "RU",
		" ru\n":                           "RU",
		`{"ip":"1.2.3.4","country":"RU"}`: "RU",
		`{"country_code":"ir"}`:           "IR",
		`{"countryCode":"CN"}`:            "CN",
		"1.2.3.4":                         "",
		"Russia":                          "",
		`{"ip":"1.2.3.4"}`:                "",
	}
	for body, want := range cases {
		if got := rcxParseEchoCountry([]byte(body)); got != want {
			t.Errorf("rcxParseEchoCountry(%q) = %q, want %q", body, got, want)
		}
	}
}
