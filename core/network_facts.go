package main

import (
	"slices"
	"sort"
	"strings"
	"sync"
)

type networkFactsPayload struct {
	Transport     string   `json:"transport"`
	SSID          string   `json:"ssid"`
	Carrier       string   `json:"carrier"`
	Gateways      []string `json:"gateways"`
	DHCPServer    string   `json:"dhcp"`
	DNSServers    []string `json:"dns"`
	IPv4          []string `json:"ipv4"`
	Validated     bool     `json:"validated"`
	CaptivePortal bool     `json:"portal"`
	Metered       bool     `json:"metered"`
}

type rcxNetworkPayload = networkFactsPayload

type networkFactsFanout struct {
	mu      sync.Mutex
	current networkFactsPayload
	has     bool
	bump    func()
	network func(rcxNetworkPayload)
}

func (fanout *networkFactsFanout) Snapshot() (networkFactsPayload, bool) {
	fanout.mu.Lock()
	defer fanout.mu.Unlock()
	return cloneNetworkFacts(fanout.current), fanout.has
}

func cloneNetworkFacts(payload networkFactsPayload) networkFactsPayload {
	payload.Gateways = append([]string(nil), payload.Gateways...)
	payload.DNSServers = append([]string(nil), payload.DNSServers...)
	payload.IPv4 = append([]string(nil), payload.IPv4...)
	return payload
}

func (fanout *networkFactsFanout) Update(payload networkFactsPayload) {
	changed := fanout.changed(payload)
	if changed && fanout.bump != nil {
		fanout.bump()
	}
	if fanout.network != nil {
		fanout.network(payload)
	}
}

func (fanout *networkFactsFanout) changed(payload networkFactsPayload) bool {
	normalized := normalizedNetworkFacts(payload)
	fanout.mu.Lock()
	defer fanout.mu.Unlock()
	if fanout.has && equalNetworkFacts(fanout.current, normalized) {
		return false
	}
	fanout.current = cloneNetworkFacts(normalized)
	fanout.has = true
	return true
}

func normalizedNetworkFacts(payload networkFactsPayload) networkFactsPayload {
	payload.Transport = strings.ToLower(strings.TrimSpace(payload.Transport))
	payload.SSID = strings.TrimSpace(payload.SSID)
	payload.Carrier = strings.TrimSpace(payload.Carrier)
	payload.DHCPServer = strings.TrimSpace(payload.DHCPServer)
	payload.Gateways = normalizedNetworkFactList(payload.Gateways)
	payload.DNSServers = normalizedNetworkFactList(payload.DNSServers)
	payload.IPv4 = normalizedNetworkFactList(payload.IPv4)
	return payload
}

func normalizedNetworkFactList(values []string) []string {
	normalized := make([]string, 0, len(values))
	for _, value := range values {
		if value = strings.TrimSpace(value); value != "" {
			normalized = append(normalized, value)
		}
	}
	sort.Strings(normalized)
	return slices.Compact(normalized)
}

func equalNetworkFacts(left, right networkFactsPayload) bool {
	return left.Transport == right.Transport &&
		left.SSID == right.SSID &&
		left.Carrier == right.Carrier &&
		left.DHCPServer == right.DHCPServer &&
		left.Validated == right.Validated &&
		left.CaptivePortal == right.CaptivePortal &&
		left.Metered == right.Metered &&
		slices.Equal(left.Gateways, right.Gateways) &&
		slices.Equal(left.DNSServers, right.DNSServers) &&
		slices.Equal(left.IPv4, right.IPv4)
}

var coreNetworkFacts = networkFactsFanout{
	bump: func() {
		doctorBumpGeneration(doctorEnvironmentGeneration)
	},
	network: func(payload rcxNetworkPayload) {
		rcxEngineInstance.Network(payload)
	},
}
