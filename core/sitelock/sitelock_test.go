package sitelock

import (
	"net/netip"
	"slices"
	"testing"

	"github.com/metacubex/mihomo/adapter"
	"github.com/metacubex/mihomo/adapter/outbound"
	C "github.com/metacubex/mihomo/constant"
)

func socks(t *testing.T, name, server string, port int, udp bool) C.Proxy {
	t.Helper()
	s, err := outbound.NewSocks5(outbound.Socks5Option{Name: name, Server: server, Port: port, UDP: udp})
	if err != nil {
		t.Fatal(err)
	}
	return adapter.NewProxy(s)
}

var refusal = adapter.NewProxy(outbound.NewReject())

func testEnv(dead map[string]bool, proxies ...C.Proxy) Env {
	all := map[string]C.Proxy{}
	for _, proxy := range proxies {
		all[proxy.Name()] = proxy
	}
	return Env{
		Proxies: func() map[string]C.Proxy { return all },
		Alive:   func(proxy C.Proxy) bool { return !dead[proxy.Name()] },
		Refuse:  func() C.Proxy { return refusal },
	}
}

func compileOK(t *testing.T, locks ...Lock) *Set {
	t.Helper()
	set, problems := Compile(locks)
	if len(problems) > 0 {
		t.Fatalf("problems: %+v", problems)
	}
	return set
}

func host(name string) *C.Metadata {
	return &C.Metadata{NetWork: C.TCP, Host: name, DstPort: 443}
}

func claimName(set *Set, metadata *C.Metadata, helper C.RuleMatchHelper, env Env) string {
	proxy, _, _ := set.Claim(metadata, helper, env)
	if proxy == nil {
		return ""
	}
	return proxy.Name()
}

var chatgpt = Lock{
	ID: "chatgpt", Enabled: true,
	Match: []string{"DOMAIN-SUFFIX,chatgpt.com", "AND,((DOMAIN-SUFFIX,openai.com),(DST-PORT,443))"},
	Exits: []Exit{{Type: "socks5", Server: "10.0.0.1", Port: 1080}},
}

func TestClaimSendsOnlyLockedHostsThroughTheExit(t *testing.T) {
	set := compileOK(t, chatgpt)
	env := testEnv(nil, socks(t, "pinned", "10.0.0.1", 1080, false), socks(t, "other", "10.0.0.2", 1080, false))

	for _, name := range []string{"chatgpt.com", "api.chatgpt.com", "openai.com"} {
		if got := claimName(set, host(name), C.RuleMatchHelper{}, env); got != "pinned" {
			t.Errorf("%s claimed by %q, want pinned", name, got)
		}
	}
	plain := host("openai.com")
	plain.DstPort = 80
	for _, metadata := range []*C.Metadata{host("example.com"), plain} {
		if proxy, rule, _ := set.Claim(metadata, C.RuleMatchHelper{}, env); proxy != nil || rule != nil {
			t.Errorf("%s:%d claimed by %v, want it left to the rules", metadata.Host, metadata.DstPort, proxy.Name())
		}
	}
}

func TestClaimPrefersALiveExitThenTriesTheFirst(t *testing.T) {
	lock := chatgpt
	lock.Exits = []Exit{{Type: "socks5", Server: "10.0.0.1", Port: 1080}, {Type: "socks5", Server: "10.0.0.2", Port: 1080}}
	set := compileOK(t, lock)
	first, second := socks(t, "first", "10.0.0.1", 1080, false), socks(t, "second", "10.0.0.2", 1080, false)

	if got := claimName(set, host("chatgpt.com"), C.RuleMatchHelper{}, testEnv(map[string]bool{"first": true}, first, second)); got != "second" {
		t.Errorf("with the first exit down, claimed by %q, want second", got)
	}
	if got := claimName(set, host("chatgpt.com"), C.RuleMatchHelper{}, testEnv(map[string]bool{"first": true, "second": true}, first, second)); got != "first" {
		t.Errorf("with every exit down, claimed by %q, want the first tried anyway", got)
	}
}

func TestClaimRefusesWhenNoServerIsAnExit(t *testing.T) {
	set := compileOK(t, chatgpt)
	cases := map[string]Env{
		"no server":     testEnv(nil),
		"other port":    testEnv(nil, socks(t, "a", "10.0.0.1", 1081, false)),
		"other type":    testEnv(nil, adapter.NewProxy(mustHTTP(t, "a", "10.0.0.1", 1080))),
		"direct server": testEnv(nil, adapter.NewProxy(outbound.NewDirectWithOption(outbound.DirectOption{Name: "d"}))),
	}
	for name, env := range cases {
		proxy, rule, _ := set.Claim(host("chatgpt.com"), C.RuleMatchHelper{}, env)
		if proxy != refusal || rule == nil {
			t.Errorf("%s: claimed by %v, want the refusal", name, proxy)
		}
	}
}

func mustHTTP(t *testing.T, name, server string, port int) *outbound.Http {
	t.Helper()
	h, err := outbound.NewHttp(outbound.HttpOption{Name: name, Server: server, Port: port})
	if err != nil {
		t.Fatal(err)
	}
	return h
}

func TestClaimRefusesUDPAnExitCannotCarry(t *testing.T) {
	set := compileOK(t, chatgpt)
	udp := host("chatgpt.com")
	udp.NetWork = C.UDP

	if got := claimName(set, udp, C.RuleMatchHelper{}, testEnv(nil, socks(t, "tcp-only", "10.0.0.1", 1080, false))); got != refusal.Name() {
		t.Errorf("UDP claimed by %q, want the refusal", got)
	}
	if got := claimName(set, udp, C.RuleMatchHelper{}, testEnv(nil, socks(t, "udp", "10.0.0.1", 1080, true))); got != "udp" {
		t.Errorf("UDP claimed by %q, want udp", got)
	}
}

func TestExceptLeavesAConnectionToTheRules(t *testing.T) {
	lock := chatgpt
	lock.Except = []string{"PROCESS-NAME,curl"}
	set := compileOK(t, lock)
	env := testEnv(nil, socks(t, "pinned", "10.0.0.1", 1080, false))
	excepted := host("chatgpt.com")
	excepted.Process = "curl"
	if proxy, _, _ := set.Claim(excepted, C.RuleMatchHelper{}, env); proxy != nil {
		t.Errorf("excepted process claimed by %s", proxy.Name())
	}
	browser := host("chatgpt.com")
	browser.Process = "firefox"
	if got := claimName(set, browser, C.RuleMatchHelper{}, env); got != "pinned" {
		t.Errorf("other process claimed by %q, want pinned", got)
	}
}

func TestLaterLockClaimsWhatAnEarlierOneExcepts(t *testing.T) {
	first := chatgpt
	first.Except = []string{"PROCESS-NAME,curl"}
	second := Lock{ID: "all-curl", Enabled: true, Match: []string{"PROCESS-NAME,curl"}, Exits: []Exit{{Type: "socks5", Server: "10.0.0.2", Port: 1080}}}
	set := compileOK(t, first, second)
	metadata := host("chatgpt.com")
	metadata.Process = "curl"

	env := testEnv(nil, socks(t, "pinned", "10.0.0.1", 1080, false), socks(t, "curl", "10.0.0.2", 1080, false))
	if got := claimName(set, metadata, C.RuleMatchHelper{}, env); got != "curl" {
		t.Errorf("claimed by %q, want the second lock's exit", got)
	}
}

func TestIPEntriesResolveThroughTheHelper(t *testing.T) {
	lock := Lock{ID: "net", Enabled: true, Match: []string{"IP-CIDR,203.0.113.0/24"}, Exits: chatgpt.Exits}
	set := compileOK(t, lock)
	env := testEnv(nil, socks(t, "pinned", "10.0.0.1", 1080, false))
	metadata := host("example.net")
	helper := C.RuleMatchHelper{ResolveIP: func() { metadata.DstIP = netip.MustParseAddr("203.0.113.7") }}

	if got := claimName(set, metadata, helper, env); got != "pinned" {
		t.Errorf("claimed by %q, want pinned", got)
	}
}

func TestNoResolveIPEntriesLeaveOtherNamesUnresolved(t *testing.T) {
	lock := Lock{ID: "net", Enabled: true, Match: []string{"IP-CIDR,203.0.113.0/24,no-resolve"}, Exits: chatgpt.Exits}
	set := compileOK(t, lock)
	env := testEnv(nil, socks(t, "pinned", "10.0.0.1", 1080, false))
	helper := C.RuleMatchHelper{ResolveIP: func() { t.Error("a no-resolve entry resolved the name") }}

	if got := claimName(set, host("example.net"), helper, env); got != "" {
		t.Errorf("claimed by %q, want nothing", got)
	}
	if got := set.Prefixes(); len(got) != 1 || got[0] != netip.MustParsePrefix("203.0.113.0/24") {
		t.Errorf("prefixes %v, want the entry's range", got)
	}
}

func TestShadowsocksExitMatchesItsConfigType(t *testing.T) {
	ss, err := outbound.NewShadowSocks(outbound.ShadowSocksOption{Name: "ss", Server: "10.0.0.1", Port: 8388, Password: "p", Cipher: "aes-128-gcm"})
	if err != nil {
		t.Fatal(err)
	}
	lock := chatgpt
	lock.Exits = []Exit{{Type: "ss", Server: "10.0.0.1", Port: 8388}}
	set := compileOK(t, lock)

	if got := claimName(set, host("chatgpt.com"), C.RuleMatchHelper{}, testEnv(nil, adapter.NewProxy(ss))); got != "ss" {
		t.Errorf("claimed by %q, want ss", got)
	}
}

func TestNameFallbackStaysAtTheExitAddress(t *testing.T) {
	lock := chatgpt
	lock.Exits = []Exit{{Type: "socks5", Server: "10.0.0.1", Port: 1080, Route: "route-v1:old", Name: "pinned"}}
	set := compileOK(t, lock)

	if got := claimName(set, host("chatgpt.com"), C.RuleMatchHelper{}, testEnv(nil, socks(t, "pinned", "10.0.0.1", 1080, true))); got != "pinned" {
		t.Errorf("rotated credentials at the same address claimed by %q, want pinned", got)
	}
	if got := claimName(set, host("chatgpt.com"), C.RuleMatchHelper{}, testEnv(nil, socks(t, "pinned", "10.0.0.9", 1080, true))); got != refusal.Name() {
		t.Errorf("a server moved under the old name claimed by %q, want the refusal", got)
	}
}

func TestDisabledLockClaimsNothing(t *testing.T) {
	lock := chatgpt
	lock.Enabled = false
	set := compileOK(t, lock)
	if proxy, _, _ := set.Claim(host("chatgpt.com"), C.RuleMatchHelper{}, testEnv(nil)); proxy != nil {
		t.Errorf("disabled lock claimed by %s", proxy.Name())
	}
}

func TestCompileReportsEveryLockItCannotEnforce(t *testing.T) {
	broken := []Lock{
		chatgpt,
		{ID: "chatgpt", Match: []string{"DOMAIN,a.com"}, Exits: chatgpt.Exits},
		{ID: "no-exit", Match: []string{"DOMAIN,a.com"}},
		{ID: "rule-set", Match: []string{"RULE-SET,proxy"}, Exits: chatgpt.Exits},
		{ID: "nested", Match: []string{"AND,((rule-set,proxy),(DOMAIN,a.com))"}, Exits: chatgpt.Exits},
		{ID: "unknown", Match: []string{"FOO,bar"}, Exits: chatgpt.Exits},
		{ID: "bad-exit", Match: []string{"DOMAIN,a.com"}, Exits: []Exit{{Type: "socks5", Server: "x", Port: 0}}},
		{ID: "", Match: []string{"DOMAIN,a.com"}, Exits: chatgpt.Exits},
	}
	set, problems := Compile(broken)

	var got []string
	for _, problem := range problems {
		got = append(got, problem.ID+"/"+problem.Field)
	}
	want := []string{"chatgpt/id", "no-exit/exits", "rule-set/match.0", "nested/match.0", "unknown/match.0", "bad-exit/exits.0", "/id"}
	if !slices.Equal(got, want) {
		t.Errorf("problems %v, want %v", got, want)
	}
	if states := set.States(testEnv(nil)); len(states) != 1 || states[0].ID != "chatgpt" {
		t.Errorf("compiled %+v, want only the valid lock", states)
	}
}

func TestStatesReportEachLockAgainstTheTunnel(t *testing.T) {
	down := chatgpt
	down.ID = "down"
	down.Exits = []Exit{{Type: "socks5", Server: "10.0.0.2", Port: 1080}}
	missing := chatgpt
	missing.ID = "missing"
	missing.Exits = []Exit{{Type: "socks5", Server: "10.0.0.9", Port: 1080}}
	off := chatgpt
	off.ID, off.Enabled = "off", false
	set := compileOK(t, chatgpt, down, missing, off)
	env := testEnv(map[string]bool{"b": true}, socks(t, "a", "10.0.0.1", 1080, false), socks(t, "b", "10.0.0.2", 1080, false))

	want := []State{
		{ID: "chatgpt", Status: StatusReady, Exit: "a"},
		{ID: "down", Status: StatusExitsDown, Exit: "b"},
		{ID: "missing", Status: StatusNoExit},
		{ID: "off", Status: StatusDisabled},
	}
	if got := set.States(env); !slices.Equal(got, want) {
		t.Errorf("states %+v, want %+v", got, want)
	}
}

func TestNamedFindsEnabledLocksWithHostEntries(t *testing.T) {
	ip := Lock{ID: "ip", Enabled: true, Match: []string{"IP-CIDR,203.0.113.0/24"}, Exits: chatgpt.Exits}
	nested := Lock{ID: "nested", Enabled: true, Match: []string{"NOT,((DOMAIN-KEYWORD,openai))"}, Exits: chatgpt.Exits}
	off := chatgpt
	off.ID, off.Enabled = "off", false
	if got := compileOK(t, chatgpt, ip, nested, off).Named(); !slices.Equal(got, []string{"chatgpt", "nested"}) {
		t.Errorf("named %v, want [chatgpt nested]", got)
	}
}

func TestRuleTypesFindNestedTypes(t *testing.T) {
	got := ruleTypes("OR,((DOMAIN,a.com),(NOT,((rule-set,x))))")
	want := []string{"OR", "DOMAIN", "NOT", "RULE-SET"}
	if !slices.Equal(got, want) {
		t.Errorf("types %v, want %v", got, want)
	}
}
