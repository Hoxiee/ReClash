package main

import (
	"context"
	"net"
	"net/http"
	"net/http/httptest"
	"net/netip"
	"sync/atomic"
	"testing"
	"time"

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

func TestNodeKeyIgnoresTheNameAndSeparatesSharedEndpoints(t *testing.T) {
	stable := rcxNodeKey("Vless", "nl-1.example:443", "")
	if renamed := rcxNodeKey("Vless", "nl-1.example:443", ""); renamed != stable {
		t.Errorf("key = %q, want %q: a display name must not be part of the identity", renamed, stable)
	}
	if moved := rcxNodeKey("Vless", "nl-1.example:8443", ""); moved == stable {
		t.Error("two ports on one host share a key: they are separate egresses")
	}
	if nested := rcxNodeKey("Selector", "", ""); nested != "" {
		t.Errorf("key = %q for a node with no endpoint, want the name to take over", nested)
	}

	members := rcxSeparateCollisions([]rcx.Member{
		{Name: "account-a", ID: stable},
		{Name: "account-b", ID: stable},
		{Name: "alone", ID: rcxNodeKey("Vless", "de-1.example:443", "")},
	})

	if members[0].ID != "" || members[1].ID != "" {
		t.Error("two accounts on one endpoint kept one key: their measurements would pool")
	}
	if members[2].ID == "" {
		t.Error("an uncontested endpoint lost its key")
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

func TestLastDelayAtReturnsTheNewestRecord(t *testing.T) {
	first := time.Unix(10, 0)
	last := time.Unix(20, 0)
	history := []constant.DelayHistory{{Time: first, Delay: 90}, {Time: last, Delay: 120}}
	if got := rcxLastDelayAt(history); !got.Equal(last) {
		t.Errorf("last delay = %v, want %v", got, last)
	}
}

func TestHostDelayTreatsAForeignFailureAsSilence(t *testing.T) {
	node := namedProxy("node")
	foreign := rcxClosedServerURL(t)
	ours := rcxLiveServerURL(t)

	if _, err := node.URLTest(context.Background(), foreign, nil); err == nil {
		t.Fatal("the setup needs the node to fail under the foreign URL")
	}

	if _, dead := rcxHostDelay(node, ours); dead {
		t.Error("a failure under another test URL condemned the node: mihomo's global alive flag is not a record under ours")
	}
}

func TestHostDelayCondemnsOnlyUnderItsOwnURL(t *testing.T) {
	node := namedProxy("node")
	ours := rcxClosedServerURL(t)
	foreign := rcxLiveServerURL(t)

	if _, err := node.URLTest(context.Background(), ours, nil); err == nil {
		t.Fatal("the setup needs the node to fail under our own URL")
	}
	if _, dead := rcxHostDelay(node, ours); !dead {
		t.Error("a failed record under our own URL must stay a verdict")
	}

	if _, err := node.URLTest(context.Background(), foreign, nil); err != nil {
		t.Fatalf("the node must answer under the foreign URL: %v", err)
	}
	if _, dead := rcxHostDelay(node, ours); !dead {
		t.Error("a foreign success masked the failed record under our URL")
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
