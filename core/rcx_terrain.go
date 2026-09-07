package main

import (
	"crypto/sha1"
	"encoding/hex"
	"net"
	"sort"
	"strings"
	"time"
)

type rcxNetworkPayload struct {
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

// A /24 alone is not an identity: home, office and cafe are commonly all
// 192.168.1.0/24. Gateway plus DHCP server plus resolver set separates them.
func rcxLinkFingerprint(payload rcxNetworkPayload) string {
	parts := make([]string, 0, 4)
	parts = append(parts, strings.Join(rcxSortedCopy(payload.Gateways), ","))
	parts = append(parts, payload.DHCPServer)
	parts = append(parts, strings.Join(rcxSortedCopy(payload.DNSServers), ","))
	parts = append(parts, strings.Join(rcxSubnets(payload.IPv4), ","))
	return rcxLinkHash(parts)
}

func rcxStableLinkFingerprint(payload rcxNetworkPayload) string {
	parts := make([]string, 0, 3)
	parts = append(parts, strings.Join(rcxSortedCopy(payload.Gateways), ","))
	parts = append(parts, payload.DHCPServer)
	parts = append(parts, strings.Join(rcxSubnets(payload.IPv4), ","))
	return rcxLinkHash(parts)
}

func rcxLinkHash(parts []string) string {
	sum := sha1.Sum([]byte(strings.Join(parts, "|")))
	return hex.EncodeToString(sum[:])[:12]
}

func rcxSortedCopy(values []string) []string {
	out := make([]string, 0, len(values))
	for _, value := range values {
		if value != "" {
			out = append(out, value)
		}
	}
	sort.Strings(out)
	return out
}

func rcxSubnets(addresses []string) []string {
	out := make([]string, 0, len(addresses))
	for _, address := range addresses {
		ip := net.ParseIP(address)
		if ip == nil || ip.To4() == nil {
			continue
		}
		masked := ip.To4().Mask(net.CIDRMask(24, 32))
		out = append(out, masked.String()+"/24")
	}
	sort.Strings(out)
	return out
}

func rcxEnvKeys(payload rcxNetworkPayload) (primary string, aliases []string) {
	transport := strings.TrimSpace(strings.ToLower(payload.Transport))
	if transport == "" {
		transport = "other"
	}
	stable := rcxStableLinkFingerprint(payload)
	legacy := rcxLinkFingerprint(payload)
	label := ""
	prefix := "o"
	switch transport {
	case "cellular":
		prefix = "c"
		label = strings.TrimSpace(payload.Carrier)
	case "ethernet":
		prefix = "e"
	case "wifi":
		prefix = "w"
		label = strings.TrimSpace(payload.SSID)
	}
	primary = "v2:" + prefix + ":"
	if label != "" {
		primary += label + "#" + stable
	} else {
		primary += "#" + stable
	}
	aliases = append(aliases, prefix+":#"+legacy, prefix+":#"+stable)
	if label != "" {
		aliases = append([]string{prefix + ":" + label, "v2:" + prefix + ":#" + stable}, aliases...)
	}
	return primary, rcxUniqueStrings(aliases, primary)
}

func rcxUniqueStrings(values []string, exclude string) []string {
	out := make([]string, 0, len(values))
	seen := map[string]struct{}{exclude: {}}
	for _, value := range values {
		if value == "" {
			continue
		}
		if _, ok := seen[value]; ok {
			continue
		}
		seen[value] = struct{}{}
		out = append(out, value)
	}
	return out
}

// Keyed on these fields, not the transport label a desktop link never reports.
func rcxPayloadIdentifies(payload rcxNetworkPayload) bool {
	if payload.SSID != "" || payload.Carrier != "" || payload.DHCPServer != "" {
		return true
	}
	return len(rcxSortedCopy(payload.Gateways)) > 0 ||
		len(rcxSortedCopy(payload.DNSServers)) > 0 ||
		len(rcxSubnets(payload.IPv4)) > 0
}

type rcxTerrainFacts struct {
	Validated      bool
	CaptivePortal  bool
	UnvalidatedFor time.Duration
	ForeignReach   rcxProbeOutcome
	DomesticReach  rcxProbeOutcome
	PortalMarker   bool
}

const rcxUnvalidatedDebounce = 3 * time.Second

// Android reports every new network unvalidated while its own probe runs, so the
// flag is a prior: entering portal needs the capability bit or a status mismatch.
func rcxClassifyTerrain(facts rcxTerrainFacts) rcxTerrain {
	if facts.CaptivePortal || facts.PortalMarker {
		return rcxTerrainPortal
	}
	if !facts.Validated && facts.UnvalidatedFor < rcxUnvalidatedDebounce {
		return rcxTerrainUnknown
	}
	switch {
	case facts.DomesticReach == rcxProbeOK && facts.ForeignReach != rcxProbeOK:
		return rcxTerrainWhitelist
	case facts.ForeignReach == rcxProbeOK:
		return rcxTerrainNormal
	case facts.DomesticReach == rcxProbeFail:
		return rcxTerrainOffline
	default:
		return rcxTerrainUnknown
	}
}

type rcxTerrainState struct {
	terrain       rcxTerrain
	since         time.Time
	unvalidatedAt time.Time
	portalUntil   time.Time
	whitelistSeen int
}

const (
	rcxPortalGrace      = 20 * time.Second
	rcxWhitelistConfirm = 2
)

func (s *rcxTerrainState) settle(terrain rcxTerrain, measured bool) rcxTerrain {
	if terrain != rcxTerrainWhitelist {
		s.whitelistSeen = 0
		return terrain
	}
	if s.terrain == rcxTerrainWhitelist {
		return terrain
	}
	if measured {
		s.whitelistSeen++
	}
	if s.whitelistSeen >= rcxWhitelistConfirm {
		return terrain
	}
	return rcxTerrainUnknown
}

func (s *rcxTerrainState) portalExpired(now time.Time) bool {
	return s.terrain == rcxTerrainPortal &&
		!s.portalUntil.IsZero() &&
		now.After(s.portalUntil)
}

func (s *rcxTerrainState) observe(terrain rcxTerrain, now time.Time) bool {
	if terrain == s.terrain {
		return false
	}
	s.terrain = terrain
	s.since = now
	if terrain == rcxTerrainPortal {
		s.portalUntil = now.Add(rcxPortalGrace)
	} else {
		s.portalUntil = time.Time{}
	}
	return true
}

func (s *rcxTerrainState) noteValidation(validated bool, now time.Time) {
	if validated {
		s.unvalidatedAt = time.Time{}
		return
	}
	if s.unvalidatedAt.IsZero() {
		s.unvalidatedAt = now
	}
}

func (s *rcxTerrainState) unvalidatedFor(now time.Time) time.Duration {
	if s.unvalidatedAt.IsZero() {
		return 0
	}
	return now.Sub(s.unvalidatedAt)
}
