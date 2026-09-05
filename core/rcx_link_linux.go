//go:build linux

package main

import (
	"net"
	"os"
	"sort"
	"strconv"
	"strings"
)

func rcxLinkGateways(devices []string) []string {
	data, err := os.ReadFile("/proc/net/route")
	if err != nil {
		return nil
	}
	return rcxParseRoutes(string(data), devices)
}

func rcxLinkResolvers() []string {
	data, err := os.ReadFile("/etc/resolv.conf")
	if err != nil {
		return nil
	}
	return rcxParseResolvers(string(data))
}

// Naming the physical links is what leaves the tunnel's own default route out.
func rcxParseRoutes(table string, devices []string) []string {
	wanted := make(map[string]struct{}, len(devices))
	for _, device := range devices {
		wanted[device] = struct{}{}
	}
	gateways := make([]string, 0, len(devices))
	for _, line := range strings.Split(table, "\n") {
		fields := strings.Fields(line)
		if len(fields) < 3 || fields[1] != "00000000" {
			continue
		}
		if _, ok := wanted[fields[0]]; !ok {
			continue
		}
		if gateway := rcxRouteIPv4(fields[2]); gateway != "" {
			gateways = append(gateways, gateway)
		}
	}
	sort.Strings(gateways)
	return gateways
}

// The kernel prints a network-order address as a host integer, so the octets reverse.
func rcxRouteIPv4(field string) string {
	value, err := strconv.ParseUint(field, 16, 32)
	if err != nil || value == 0 {
		return ""
	}
	return net.IPv4(byte(value), byte(value>>8), byte(value>>16), byte(value>>24)).String()
}

func rcxParseResolvers(conf string) []string {
	servers := make([]string, 0, 3)
	for _, line := range strings.Split(conf, "\n") {
		fields := strings.Fields(line)
		if len(fields) < 2 || fields[0] != "nameserver" {
			continue
		}
		if ip := net.ParseIP(fields[1]); ip != nil {
			servers = append(servers, ip.String())
		}
	}
	sort.Strings(servers)
	return servers
}
