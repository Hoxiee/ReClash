package main

import (
	"encoding/json"
	"net/netip"
	"testing"

	LC "github.com/metacubex/mihomo/listener/config"
)

func TestTunSchemaDecodesNewFields(t *testing.T) {
	raw := `{"tun":{"enable":true,"mtu":9000,"congestion-controller":"bbr3",` +
		`"strict-route":true,"route-exclude-address":["10.0.0.0/8","fd00::/8"]}}`
	params := &UpdateParams{}
	if err := json.Unmarshal([]byte(raw), params); err != nil {
		t.Fatalf("unmarshal error: %v", err)
	}
	tun := params.Tun
	if tun == nil {
		t.Fatal("tun schema missing")
	}
	if tun.MTU == nil || *tun.MTU != 9000 {
		t.Errorf("MTU = %v, want 9000", tun.MTU)
	}
	if tun.CongestionController == nil || *tun.CongestionController != "bbr3" {
		t.Errorf("CongestionController = %v, want bbr3", tun.CongestionController)
	}
	if tun.StrictRoute == nil || !*tun.StrictRoute {
		t.Errorf("StrictRoute = %v, want true", tun.StrictRoute)
	}
	if tun.RouteExcludeAddress == nil || len(*tun.RouteExcludeAddress) != 2 {
		t.Fatalf("RouteExcludeAddress = %v, want two prefixes", tun.RouteExcludeAddress)
	}
}

func TestPatchTunAppliesNewFields(t *testing.T) {
	target := &LC.Tun{}
	mtu := uint32(9000)
	cc := "bbr3"
	strict := true
	excludes := []netip.Prefix{netip.MustParsePrefix("10.0.0.0/8")}

	patchTun(target, &tunSchema{
		Enable:               true,
		MTU:                  &mtu,
		CongestionController: &cc,
		StrictRoute:          &strict,
		RouteExcludeAddress:  &excludes,
	})

	if target.MTU != 9000 {
		t.Errorf("MTU = %d, want 9000", target.MTU)
	}
	if target.CongestionController != "bbr3" {
		t.Errorf("CongestionController = %q, want bbr3", target.CongestionController)
	}
	if !target.StrictRoute {
		t.Error("StrictRoute stayed false")
	}
	if len(target.RouteExcludeAddress) != 1 {
		t.Errorf("RouteExcludeAddress = %v, want one prefix", target.RouteExcludeAddress)
	}
}

func TestPatchTunPreservesProfileOwnedAndOmittedFields(t *testing.T) {
	target := &LC.Tun{
		MTU:                   1500,
		CongestionController:  "cubic",
		StrictRoute:           true,
		DisableICMPForwarding: true,
		ExcludeInterface:      []string{"eth0"},
		RouteExcludeAddress:   []netip.Prefix{netip.MustParsePrefix("192.168.0.0/16")},
	}

	patchTun(target, &tunSchema{Enable: true})

	if !target.Enable {
		t.Error("Enable stayed false")
	}
	if target.MTU != 1500 {
		t.Errorf("MTU = %d, want the omitted field preserved", target.MTU)
	}
	if target.CongestionController != "cubic" {
		t.Errorf("CongestionController = %q, want preserved", target.CongestionController)
	}
	if !target.StrictRoute {
		t.Error("StrictRoute was reset by an omitted field")
	}
	if !target.DisableICMPForwarding {
		t.Error("profile-owned DisableICMPForwarding was clobbered")
	}
	if len(target.ExcludeInterface) != 1 || target.ExcludeInterface[0] != "eth0" {
		t.Errorf("ExcludeInterface = %v, want profile-owned value preserved", target.ExcludeInterface)
	}
	if len(target.RouteExcludeAddress) != 1 {
		t.Errorf("RouteExcludeAddress = %v, want preserved", target.RouteExcludeAddress)
	}
}

func TestPatchTunResetsWithFalseAndEmpty(t *testing.T) {
	target := &LC.Tun{
		StrictRoute:         true,
		RouteExcludeAddress: []netip.Prefix{netip.MustParsePrefix("10.0.0.0/8")},
	}
	strict := false
	empty := []netip.Prefix{}

	patchTun(target, &tunSchema{
		Enable:              true,
		StrictRoute:         &strict,
		RouteExcludeAddress: &empty,
	})

	if target.StrictRoute {
		t.Error("StrictRoute stayed true after an explicit false")
	}
	if len(target.RouteExcludeAddress) != 0 {
		t.Errorf("RouteExcludeAddress = %v, want cleared by an explicit empty list", target.RouteExcludeAddress)
	}
}
