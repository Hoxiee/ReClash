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
		{Exit: Exit{Type: "socks5", Server: "example.com", Port: 1080}, Names: []string{"a", "b"}},
		{Exit: Exit{Type: "socks5", Server: "10.0.0.1", Port: 1080}, Names: []string{"c"}},
	}
	if got := Candidates(all); !reflect.DeepEqual(got, want) {
		t.Fatalf("got %+v, want %+v", got, want)
	}
}
