package sitelock

import (
	"reflect"
	"testing"

	"github.com/metacubex/mihomo/adapter"
	"github.com/metacubex/mihomo/adapter/outbound"
	C "github.com/metacubex/mihomo/constant"
)

func TestCandidatesMergeNamesOfOneServerAndSkipBuiltIns(t *testing.T) {
	all := map[string]C.Proxy{
		"b":      socks(t, "b", "Example.com", 1080, false),
		"a":      socks(t, "a", "example.com", 1080, false),
		"c":      socks(t, "c", "10.0.0.1", 1080, false),
		"DIRECT": adapter.NewProxy(outbound.NewDirect()),
	}
	want := []Candidate{
		{Exit: Exit{Type: "socks5", Server: "example.com", Port: 1080, Name: "a"}, Names: []string{"a", "b"}},
		{Exit: Exit{Type: "socks5", Server: "10.0.0.1", Port: 1080, Name: "c"}, Names: []string{"c"}},
	}
	if got := Candidates(all); !reflect.DeepEqual(got, want) {
		t.Fatalf("got %+v, want %+v", got, want)
	}
}

func parsed(t *testing.T, name, user string) C.Proxy {
	t.Helper()
	proxy, err := adapter.ParseProxy(map[string]any{
		"name": name, "type": "socks5", "server": "10.0.0.1", "port": 1080, "username": user, "password": "p",
	})
	if err != nil {
		t.Fatal(err)
	}
	return proxy
}

func TestCandidatesSplitOneAddressByCredentials(t *testing.T) {
	all := map[string]C.Proxy{
		"nl":     parsed(t, "nl", "nl"),
		"de":     parsed(t, "de", "de"),
		"de bis": parsed(t, "de bis", "de"),
	}
	got := Candidates(all)
	if len(got) != 2 || !reflect.DeepEqual(got[0].Names, []string{"de", "de bis"}) || got[0].Name != "de" ||
		!reflect.DeepEqual(got[1].Names, []string{"nl"}) || got[0].Route == "" || got[0].Route == got[1].Route {
		t.Fatalf("got %+v", got)
	}
}

func TestRouteExitKeepsItsServerThenFallsBackToItsName(t *testing.T) {
	de := Candidates(map[string]C.Proxy{"de": parsed(t, "de", "de")})[0].Exit
	lock := chatgpt
	lock.Exits = []Exit{de}
	set := compileOK(t, lock)

	if got := claimName(set, host("chatgpt.com"), C.RuleMatchHelper{}, testEnv(nil, parsed(t, "nl", "nl"), parsed(t, "de", "de"))); got != "de" {
		t.Errorf("claimed by %q, want de", got)
	}
	if got := claimName(set, host("chatgpt.com"), C.RuleMatchHelper{}, testEnv(nil, parsed(t, "nl", "nl"), parsed(t, "de", "rotated"))); got != "de" {
		t.Errorf("after rotation claimed by %q, want de", got)
	}
	if got := claimName(set, host("chatgpt.com"), C.RuleMatchHelper{}, testEnv(nil, parsed(t, "nl", "nl"))); got != refusal.Name() {
		t.Errorf("without de claimed by %q, want refusal", got)
	}
}
