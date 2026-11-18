package core

import (
	"net/netip"
	"reflect"
	"slices"
	"testing"

	"core/sitelock"

	"github.com/metacubex/mihomo/adapter"
	"github.com/metacubex/mihomo/adapter/outbound"
	"github.com/metacubex/mihomo/config"
	"github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/tunnel"
)

var lockedChatgpt = sitelock.Lock{
	ID: "chatgpt", Enabled: true,
	Match: []string{"DOMAIN-SUFFIX,chatgpt.com"},
	Exits: []sitelock.Exit{{Type: "socks5", Server: "10.0.0.1", Port: 1080}},
}

func withSiteLockTunnel(t *testing.T) {
	t.Helper()
	pinned, err := outbound.NewSocks5(outbound.Socks5Option{Name: "pinned", Server: "10.0.0.1", Port: 1080})
	if err != nil {
		t.Fatal(err)
	}
	tunnel.UpdateProxies(map[string]constant.Proxy{
		"DIRECT": adapter.NewProxy(outbound.NewDirect()),
		"GLOBAL": namedProxy("GLOBAL"),
		"pinned": adapter.NewProxy(pinned),
	}, nil)
	mode := tunnel.Mode()
	t.Cleanup(func() {
		tunnel.SetMode(mode)
		tunnel.UpdateProxies(nil, nil)
		siteLocks.Store(nil)
	})
}

func routeOf(t *testing.T, host string) string {
	t.Helper()
	proxy, err := tunnel.ResolveRoute(&constant.Metadata{NetWork: constant.TCP, Type: constant.HTTP, Host: host, DstPort: 443})
	if err != nil {
		t.Fatalf("%s: %v", host, err)
	}
	return proxy.Name()
}

func TestSiteLockOutranksDirectAndGlobalModes(t *testing.T) {
	withSiteLockTunnel(t)
	if report := setSiteLocks([]sitelock.Lock{lockedChatgpt}); !report.Applied {
		t.Fatalf("locks refused: %+v", report.Problems)
	}

	for _, mode := range []tunnel.TunnelMode{tunnel.Direct, tunnel.Global} {
		tunnel.SetMode(mode)
		if got := routeOf(t, "chatgpt.com"); got != "pinned" {
			t.Errorf("%s mode routes chatgpt.com to %s, want pinned", mode, got)
		}
	}
	tunnel.SetMode(tunnel.Direct)
	if got := routeOf(t, "example.com"); got != "DIRECT" {
		t.Errorf("an unlocked host routes to %s, want DIRECT", got)
	}
}

func TestSiteLockOutranksAListenerProxyButNotTheInnerListener(t *testing.T) {
	withSiteLockTunnel(t)
	setSiteLocks([]sitelock.Lock{lockedChatgpt})

	for kind, want := range map[constant.Type]string{constant.SOCKS5: "pinned", constant.INNER: "DIRECT"} {
		metadata := &constant.Metadata{NetWork: constant.TCP, Type: kind, Host: "chatgpt.com", DstPort: 443, SpecialProxy: "DIRECT"}
		proxy, err := tunnel.ResolveRoute(metadata)
		if err != nil || proxy.Name() != want {
			t.Errorf("%s listener with proxy DIRECT routes to %v (%v), want %s", kind, proxy, err, want)
		}
	}
}

func TestSiteLockReportWarnsThatDomainsNeedTheSniffer(t *testing.T) {
	withSiteLockTunnel(t)
	setSiteLocks([]sitelock.Lock{lockedChatgpt})
	want := []sitelock.Warning{{Code: sitelock.WarningSnifferOff, Locks: []string{"chatgpt"}}}
	if tunnel.IsSniffing() {
		want = []sitelock.Warning{}
	}
	if got := siteLockReport(true, nil).Warnings; !reflect.DeepEqual(got, want) {
		t.Errorf("warnings %+v, want %+v", got, want)
	}
}

func TestSiteLockPolicyHoldsFakeAddressesOnlyWhileNamesAreLocked(t *testing.T) {
	withSiteLockTunnel(t)
	configMu.Lock()
	saved := currentConfig
	currentConfig = &config.Config{DNS: &config.DNS{
		FakeIPRange:  netip.MustParsePrefix("198.18.0.1/16"),
		FakeIPRange6: netip.MustParsePrefix("fc00::/18"),
	}}
	configMu.Unlock()
	t.Cleanup(func() {
		configMu.Lock()
		currentConfig = saved
		configMu.Unlock()
	})
	if got := siteLockPolicy(""); got != nil {
		t.Fatalf("a core without locks yet reports %+v, want nil", got)
	}

	lock := lockedChatgpt
	lock.Match = append([]string{"IP-CIDR,198.51.100.7/24"}, lock.Match...)
	setSiteLocks([]sitelock.Lock{lock})
	policy := siteLockPolicy("")
	if want := []string{"198.18.0.0/16", "198.51.100.0/24", "fc00::/18"}; !slices.Equal(policy.Addresses, want) {
		t.Errorf("addresses %v, want %v", policy.Addresses, want)
	}
	if !slices.Equal(policy.Names.Suffix, []string{"chatgpt.com"}) {
		t.Errorf("names %+v, want the chatgpt.com suffix", policy.Names)
	}

	if again := siteLockPolicy(policy.Revision); !again.Unchanged || again.Names != nil {
		t.Errorf("a host holding the revision gets %+v, want it unchanged and bare", again)
	}

	lock.Match = lock.Match[:1]
	setSiteLocks([]sitelock.Lock{lock})
	if again := siteLockPolicy(policy.Revision); again.Unchanged {
		t.Error("a changed policy keeps its revision")
	}
	if got := siteLockPolicy("").Addresses; !slices.Equal(got, []string{"198.51.100.0/24"}) {
		t.Errorf("address-only locks hold %v, want no fake ranges", got)
	}
	setSiteLocks(nil)
	if got := siteLockPolicy(""); got == nil || len(got.Addresses) != 0 || !got.Names.Empty() {
		t.Errorf("lifted locks keep %+v", got)
	}
}

func TestSiteLockRefusesWhenTheConfigHasNoExit(t *testing.T) {
	withSiteLockTunnel(t)
	lock := lockedChatgpt
	lock.Exits = []sitelock.Exit{{Type: "socks5", Server: "10.0.0.9", Port: 1080}}
	setSiteLocks([]sitelock.Lock{lock})
	tunnel.SetMode(tunnel.Direct)

	if got := routeOf(t, "chatgpt.com"); got != siteLockRefusal.Name() {
		t.Errorf("routes to %s, want the refusal", got)
	}
}

func TestFailedSiteLockEditKeepsTheLocksInForce(t *testing.T) {
	withSiteLockTunnel(t)
	setSiteLocks([]sitelock.Lock{lockedChatgpt})
	broken := lockedChatgpt
	broken.Match = []string{"RULE-SET,proxy"}

	report := setSiteLocks([]sitelock.Lock{broken})
	if report.Applied || len(report.Problems) != 1 {
		t.Fatalf("report %+v, want the edit refused with one problem", report)
	}
	tunnel.SetMode(tunnel.Direct)
	if got := routeOf(t, "chatgpt.com"); got != "pinned" {
		t.Errorf("after a refused edit routes to %s, want the lock still in force", got)
	}
}

func TestSetupSiteLocksKeepWhenAbsentAndReportWhatTheyDrop(t *testing.T) {
	withSiteLockTunnel(t)
	applySetupSiteLocks(&[]sitelock.Lock{lockedChatgpt})
	applySetupSiteLocks(nil)
	if report := siteLockReport(true, nil); len(report.Locks) != 1 || report.Locks[0].Status != sitelock.StatusReady {
		t.Fatalf("absent setup locks left %+v, want the lock kept", report.Locks)
	}

	broken := lockedChatgpt
	broken.ID = "broken"
	broken.Exits = nil
	applySetupSiteLocks(&[]sitelock.Lock{lockedChatgpt, broken})
	report := siteLockReport(true, nil)
	if len(report.Locks) != 1 || len(report.Problems) != 1 || report.Problems[0].ID != "broken" {
		t.Errorf("report %+v, want the valid lock applied and the broken one reported", report)
	}

	applySetupSiteLocks(&[]sitelock.Lock{})
	tunnel.SetMode(tunnel.Direct)
	if got := routeOf(t, "chatgpt.com"); got != "DIRECT" {
		t.Errorf("an empty setup list routes to %s, want the locks lifted", got)
	}
}
