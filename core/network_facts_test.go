package main

import "testing"

func TestNetworkFactsFanoutBumpsEnvironmentOnlyForSemanticChanges(t *testing.T) {
	bumps := 0
	networks := 0
	fanout := networkFactsFanout{
		bump: func() { bumps++ },
		network: func(rcxNetworkPayload) {
			networks++
		},
	}
	first := networkFactsPayload{
		Transport:  " WiFi ",
		SSID:       " Home ",
		Gateways:   []string{"192.168.1.1", ""},
		DNSServers: []string{"1.1.1.1", "192.168.1.1"},
		Validated:  true,
	}
	fanout.Update(first)
	fanout.Update(networkFactsPayload{
		Transport:  "wifi",
		SSID:       "Home",
		Gateways:   []string{"192.168.1.1"},
		DNSServers: []string{"192.168.1.1", "1.1.1.1"},
		Validated:  true,
	})
	fanout.Update(networkFactsPayload{
		Transport:  "wifi",
		SSID:       "Home",
		Gateways:   []string{"192.168.1.1"},
		DNSServers: []string{"1.1.1.1", "192.168.1.1"},
		Validated:  false,
	})

	if bumps != 2 || networks != 3 {
		t.Fatalf("bumps = %d, networks = %d", bumps, networks)
	}
}

func TestNetworkFactsFanoutDoesNotDependOnRcxState(t *testing.T) {
	bumps := 0
	fanout := networkFactsFanout{
		bump:    func() { bumps++ },
		network: func(rcxNetworkPayload) {},
	}

	fanout.Update(networkFactsPayload{Transport: "cellular", Carrier: "25001"})

	if bumps != 1 {
		t.Fatalf("environment bumps = %d, want 1", bumps)
	}
}

func TestNetworkFactsSnapshotIsCopySafeAndDistinguishesUnknown(t *testing.T) {
	fanout := networkFactsFanout{}
	if _, known := fanout.Snapshot(); known {
		t.Fatal("unknown facts reported as known")
	}
	fanout.Update(networkFactsPayload{Transport: "wifi", Gateways: []string{"192.0.2.1"}, DNSServers: []string{"1.1.1.1"}})
	snapshot, known := fanout.Snapshot()
	if !known || snapshot.Transport != "wifi" {
		t.Fatalf("snapshot = %+v, known = %v", snapshot, known)
	}
	snapshot.Gateways[0] = "mutated"
	snapshot.DNSServers[0] = "mutated"
	again, _ := fanout.Snapshot()
	if again.Gateways[0] != "192.0.2.1" || again.DNSServers[0] != "1.1.1.1" {
		t.Fatalf("snapshot mutation leaked: %+v", again)
	}
	fanout = networkFactsFanout{}
	fanout.Update(networkFactsPayload{})
	if empty, known := fanout.Snapshot(); !known || empty.Transport != "" {
		t.Fatalf("known empty snapshot = %+v, known = %v", empty, known)
	}
}
