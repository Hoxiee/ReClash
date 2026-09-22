package rcx

import (
	"slices"
	"sort"
	"strings"
)

func cloneNetworkFacts(payload rcxNetworkPayload) rcxNetworkPayload {
	payload.Gateways = append([]string(nil), payload.Gateways...)
	payload.DNSServers = append([]string(nil), payload.DNSServers...)
	payload.IPv4 = append([]string(nil), payload.IPv4...)
	return payload
}

func normalizedNetworkFacts(payload rcxNetworkPayload) rcxNetworkPayload {
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

func equalNetworkFacts(left, right rcxNetworkPayload) bool {
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
