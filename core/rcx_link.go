package main

import (
	"net"
	"sort"
	"strings"

	"github.com/metacubex/mihomo/listener"
)

// Without a link there is one bucket per machine, and a cafe's cooling follows the user home.
func rcxSampleLink() (networkFactsPayload, bool) {
	devices, addresses := rcxPhysicalLinks()
	if len(devices) == 0 {
		return networkFactsPayload{}, false
	}
	return networkFactsPayload{
		Transport:  rcxLinkTransport(devices[0]),
		Gateways:   rcxLinkGateways(devices),
		DNSServers: rcxLinkResolvers(),
		IPv4:       addresses,
		// Nothing here sees a portal, and the canaries classify the terrain anyway.
		Validated: true,
	}, true
}

// The tunnel is present on every network, so a fingerprint counting it reads them all alike.
func rcxPhysicalLinks() (devices, addresses []string) {
	interfaces, err := net.Interfaces()
	if err != nil {
		return nil, nil
	}
	tun := strings.ToLower(listener.GetTunConf().Device)
	sort.Slice(interfaces, func(i, j int) bool { return interfaces[i].Index < interfaces[j].Index })
	for _, iface := range interfaces {
		if iface.Flags&net.FlagUp == 0 || iface.Flags&net.FlagLoopback != 0 {
			continue
		}
		if rcxVirtualLink(iface.Name, tun) {
			continue
		}
		found := rcxLinkAddresses(iface, &addresses)
		if found {
			devices = append(devices, iface.Name)
		}
	}
	sort.Strings(addresses)
	return devices, addresses
}

func rcxLinkAddresses(iface net.Interface, into *[]string) bool {
	addrs, err := iface.Addrs()
	if err != nil {
		return false
	}
	found := false
	for _, addr := range addrs {
		prefix, ok := addr.(*net.IPNet)
		if !ok {
			continue
		}
		ip := prefix.IP.To4()
		if ip == nil || !ip.IsGlobalUnicast() || ip.IsLinkLocalUnicast() {
			continue
		}
		*into = append(*into, ip.String())
		found = true
	}
	return found
}

var rcxVirtualPrefixes = []string{
	"tun", "tap", "utun", "wg", "docker", "veth", "br-", "virbr",
	"vmnet", "vboxnet", "zt", "tailscale", "hyper-v", "loopback",
}

func rcxVirtualLink(device, tun string) bool {
	name := strings.ToLower(device)
	if tun != "" && name == tun {
		return true
	}
	for _, prefix := range rcxVirtualPrefixes {
		if strings.HasPrefix(name, prefix) {
			return true
		}
	}
	return false
}

// Report-only: a heuristic that guesses wrong still guesses the same way every time.
func rcxLinkTransport(device string) string {
	name := strings.ToLower(device)
	switch {
	case strings.HasPrefix(name, "wl"), strings.Contains(name, "wi-fi"),
		strings.Contains(name, "wifi"), strings.Contains(name, "wireless"),
		strings.Contains(name, "airport"):
		return "wifi"
	case strings.HasPrefix(name, "eth"), strings.HasPrefix(name, "en"),
		strings.Contains(name, "ethernet"):
		return "ethernet"
	default:
		return ""
	}
}
