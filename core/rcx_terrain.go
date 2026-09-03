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
	parts := make([]string, 0, 8)
	parts = append(parts, strings.Join(rcxSortedCopy(payload.Gateways), ","))
	parts = append(parts, payload.DHCPServer)
	parts = append(parts, strings.Join(rcxSortedCopy(payload.DNSServers), ","))
	parts = append(parts, strings.Join(rcxSubnets(payload.IPv4), ","))
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

// The secondary key is the permission-free one, so a record written before the
// SSID became readable can be migrated rather than orphaned.
func rcxEnvKeys(payload rcxNetworkPayload) (primary, secondary string) {
	fingerprint := rcxLinkFingerprint(payload)
	switch payload.Transport {
	case "cellular":
		key := "c:" + payload.Carrier
		if payload.Carrier == "" {
			key = "c:#" + fingerprint
		}
		return key, key
	case "ethernet":
		return "e:#" + fingerprint, "e:#" + fingerprint
	case "wifi":
		secondary = "w:#" + fingerprint
		if payload.SSID != "" {
			return "w:" + payload.SSID, secondary
		}
		return secondary, secondary
	default:
		return "o:#" + fingerprint, "o:#" + fingerprint
	}
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
	case facts.ForeignReach == rcxProbeOK:
		return rcxTerrainNormal
	case facts.ForeignReach == rcxProbeOverloaded:
		return rcxTerrainUnknown
	case facts.DomesticReach == rcxProbeOK:
		return rcxTerrainWhitelist
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
}

const rcxPortalGrace = 20 * time.Second

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
