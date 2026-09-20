package main

import (
	"crypto/sha256"
	"encoding/hex"
	"sort"
	"strconv"
	"strings"

	"golang.org/x/text/unicode/norm"
)

type rcxMarker struct {
	URL      string `json:"url"`
	Statuses []int  `json:"statuses"`
}

type rcxLaneSelector struct {
	Provider     string `json:"p"`
	NameContains string `json:"has"`
	Group        string `json:"grp,omitempty"`
}

type rcxLaneConfig struct {
	ID        string            `json:"id"`
	Group     string            `json:"g"`
	Fallback  string            `json:"fb"`
	Role      string            `json:"role,omitempty"`
	Strategy  string            `json:"st,omitempty"`
	Selectors []rcxLaneSelector `json:"sel"`
}

// The version of the shipped preset data. A bump makes the engine drop the
// per-node facts it learned under the old set on the next start, so a corrected
// marker set is not fought by proofs a poisoned node earned before it.
const rcxDefaultsVersion = 4

type rcxConfigFingerprints struct {
	Open      string `json:"o"`
	Domestic  string `json:"d"`
	Canaries  string `json:"c"`
	Countries string `json:"r"`
	Lanes     string `json:"l"`
	Egress    string `json:"e"`
}

func (c rcxConfig) fingerprints() rcxConfigFingerprints {
	return rcxConfigFingerprints{
		Open:      rcxMarkersFingerprint(c.OpenMarkers),
		Domestic:  rcxMarkersFingerprint(c.DomesticMarkers),
		Canaries:  rcxStringsFingerprint(c.CanaryForeign, c.CanaryDomestic),
		Countries: rcxStringsFingerprint(c.CensorCountries),
		Lanes:     rcxLanesFingerprint(c.Lanes),
		Egress:    rcxStringsFingerprint(c.EgressEchoes),
	}
}

func rcxMarkerID(role rcxRole, marker rcxMarker) string {
	return strconv.Itoa(int(role)) + ":" + rcxMarkersFingerprint([]rcxMarker{marker})
}

func rcxMarkersFingerprint(markers []rcxMarker) string {
	values := make([]string, 0, len(markers))
	for _, marker := range markers {
		statuses := append([]int(nil), marker.Statuses...)
		sort.Ints(statuses)
		parts := make([]string, len(statuses))
		for i, status := range statuses {
			parts[i] = strconv.Itoa(status)
		}
		values = append(values, strings.TrimSpace(marker.URL)+"|"+strings.Join(parts, ","))
	}
	return rcxFingerprint(values)
}

func rcxStringsFingerprint(groups ...[]string) string {
	values := make([]string, 0)
	for _, group := range groups {
		normalized := make([]string, 0, len(group))
		for _, value := range group {
			if value = strings.TrimSpace(value); value != "" {
				normalized = append(normalized, value)
			}
		}
		sort.Strings(normalized)
		values = append(values, normalized...)
		values = append(values, "\x00")
	}
	return rcxFingerprint(values)
}

func rcxLanesFingerprint(lanes []rcxLaneConfig) string {
	values := make([]string, 0, len(lanes))
	for _, lane := range lanes {
		parts := []string{lane.ID, lane.Group, lane.Fallback, lane.Role, lane.Strategy}
		for _, selector := range lane.Selectors {
			parts = append(parts, selector.Provider, selector.NameContains, selector.Group)
		}
		values = append(values, strings.Join(parts, "\x00"))
	}
	return rcxFingerprint(values)
}

func rcxFingerprint(values []string) string {
	sum := sha256.Sum256([]byte(strings.Join(values, "\x1f")))
	return hex.EncodeToString(sum[:8])
}

type rcxConfig struct {
	Enabled                 bool            `json:"on"`
	Preset                  string          `json:"preset"`
	DefaultsVersion         int             `json:"dv"`
	Strategy                string          `json:"st"`
	CensorCountries         []string        `json:"cc"`
	CanaryForeign           []string        `json:"cf"`
	CanaryDomestic          []string        `json:"cd"`
	OpenMarkers             []rcxMarker     `json:"om"`
	DomesticMarkers         []rcxMarker     `json:"dm"`
	EgressEchoes            []string        `json:"ee"`
	BreakerPatterns         []string        `json:"bp"`
	Lanes                   []rcxLaneConfig `json:"ln"`
	AllowDomesticLastResort bool            `json:"dlr"`
	RequireUDP              bool            `json:"udp"`
	RespectPick             bool            `json:"rpk"`
	DwellSeconds            int             `json:"dwl"`
	WaveWidth               int             `json:"ww"`
	ProofTTLMinutes         int             `json:"pttl"`
	DegradeConfirmSeconds   int             `json:"dgc"`
}

const (
	rcxStrategyBalanced = "balanced"
	rcxStrategyLatency  = "lowest-latency"
	rcxStrategyStable   = "stable"
	rcxStrategySaver    = "saver"
	rcxLaneFallbackMain = "main"
	rcxLaneReject       = "reject"
	rcxLaneGroupPrefix  = "RCX-CAP-"
	rcxLaneRoleAny      = ""
	rcxLaneRoleForeign  = "foreign"
	rcxLaneRoleDomestic = "domestic"

	rcxDwellSeconds       = 90
	rcxWaveWidth          = 12
	rcxProofTTLMinutes    = 30
	rcxDegradeConfirmSec  = 60
	rcxColdConfirmSec     = 15
	rcxProbeConcurrency   = 2
	rcxProbeStaggerMs     = 250
	rcxLiveWindowSeconds  = 60
	rcxFreshWindowSeconds = 1800
	rcxDegradedPenalty    = 2
)

// Not a setting: a knob here lets milliseconds outrank whether a node works.
func rcxLatencyBands() []int {
	return []int{150, 300, 600, 1200}
}

// A strategy the host does not know must rank by the shipped order rather than
// by a zero key, so an unnamed one degrades to balanced instead of to nothing.
func rcxKnownStrategy(name string) bool {
	switch name {
	case rcxStrategyBalanced, rcxStrategyLatency, rcxStrategyStable, rcxStrategySaver:
		return true
	}
	return false
}

func rcxDefaultConfig() rcxConfig {
	return rcxConfig{
		Enabled:                 false,
		Preset:                  "off",
		DefaultsVersion:         rcxDefaultsVersion,
		Strategy:                rcxStrategyBalanced,
		AllowDomesticLastResort: true,
		RespectPick:             true,
		DwellSeconds:            rcxDwellSeconds,
		WaveWidth:               rcxWaveWidth,
		ProofTTLMinutes:         rcxProofTTLMinutes,
		DegradeConfirmSeconds:   rcxDegradeConfirmSec,
	}
}

// An older host or a truncated payload degrades to shipped values, not zero.
func (c rcxConfig) normalized() rcxConfig {
	if c.DwellSeconds <= 0 {
		c.DwellSeconds = rcxDwellSeconds
	}
	if c.WaveWidth <= 0 {
		c.WaveWidth = rcxWaveWidth
	}
	if c.ProofTTLMinutes <= 0 {
		c.ProofTTLMinutes = rcxProofTTLMinutes
	}
	if c.DegradeConfirmSeconds <= 0 {
		c.DegradeConfirmSeconds = rcxDegradeConfirmSec
	}
	if !rcxKnownStrategy(c.Strategy) {
		c.Strategy = rcxStrategyBalanced
	}
	c.Lanes = rcxNormalizeLanes(c.Lanes)
	return c
}

func rcxNormalizeLanes(lanes []rcxLaneConfig) []rcxLaneConfig {
	normalized := make([]rcxLaneConfig, 0, len(lanes))
	seenIDs := make(map[string]struct{}, len(lanes))
	seenGroups := make(map[string]struct{}, len(lanes))
	for _, lane := range lanes {
		lane.ID = strings.TrimSpace(lane.ID)
		lane.Group = strings.TrimSpace(lane.Group)
		if !rcxValidLaneID(lane.ID) || !rcxValidLaneGroup(lane.Group) {
			continue
		}
		if _, exists := seenIDs[lane.ID]; exists {
			continue
		}
		if _, exists := seenGroups[lane.Group]; exists {
			continue
		}
		seenIDs[lane.ID] = struct{}{}
		seenGroups[lane.Group] = struct{}{}
		if strings.TrimSpace(lane.Fallback) == rcxLaneReject {
			lane.Fallback = rcxLaneReject
		} else {
			lane.Fallback = rcxLaneFallbackMain
		}
		switch strings.TrimSpace(lane.Role) {
		case rcxLaneRoleForeign:
			lane.Role = rcxLaneRoleForeign
		case rcxLaneRoleDomestic:
			lane.Role = rcxLaneRoleDomestic
		default:
			lane.Role = rcxLaneRoleAny
		}
		if !rcxKnownStrategy(strings.TrimSpace(lane.Strategy)) {
			lane.Strategy = ""
		} else {
			lane.Strategy = strings.TrimSpace(lane.Strategy)
		}
		selectors := make([]rcxLaneSelector, 0, len(lane.Selectors))
		seenSelectors := make(map[rcxLaneSelector]struct{}, len(lane.Selectors))
		for _, selector := range lane.Selectors {
			selector.Provider = norm.NFC.String(strings.TrimSpace(selector.Provider))
			selector.NameContains = norm.NFC.String(strings.TrimSpace(selector.NameContains))
			selector.Group = norm.NFC.String(strings.TrimSpace(selector.Group))
			if selector.Provider == "" && selector.NameContains == "" && selector.Group == "" {
				continue
			}
			if _, exists := seenSelectors[selector]; exists {
				continue
			}
			seenSelectors[selector] = struct{}{}
			selectors = append(selectors, selector)
		}
		lane.Selectors = selectors
		normalized = append(normalized, lane)
	}
	return normalized
}

func rcxValidLaneID(value string) bool {
	if len(value) == 0 || len(value) > 64 || (value[0] < 'a' || value[0] > 'z') && (value[0] < '0' || value[0] > '9') {
		return false
	}
	for _, char := range value {
		if (char < 'a' || char > 'z') && (char < '0' || char > '9') && char != '.' && char != '-' {
			return false
		}
	}
	return true
}

func rcxValidLaneGroup(value string) bool {
	if !strings.HasPrefix(value, rcxLaneGroupPrefix) || len(value) == len(rcxLaneGroupPrefix) {
		return false
	}
	for _, char := range value[len(rcxLaneGroupPrefix):] {
		if (char < 'A' || char > 'Z') && (char < '0' || char > '9') && char != '_' {
			return false
		}
	}
	return true
}

// Without a marker no node can earn a verdict, so the engine is not running.
func (c rcxConfig) operable() bool {
	return c.Enabled && len(c.OpenMarkers) > 0
}

func (c rcxConfig) policy() rcxPolicy {
	return rcxPolicy{
		LatencyBands:        rcxLatencyBands(),
		Strategy:            c.Strategy,
		RequireUDP:          c.RequireUDP,
		AllowDomesticLast:   c.AllowDomesticLastResort,
		Censoring:           len(c.CensorCountries) > 0,
		DwellSeconds:        c.DwellSeconds,
		DegradedBandPenalty: rcxDegradedPenalty,
	}
}

// The provider's own naming is the only signal here: a specialist is a foreign
// node like its siblings, so no measurement separates them.
func (c rcxConfig) breaker(node string) bool {
	name := strings.ToLower(node)
	for _, pattern := range c.BreakerPatterns {
		needle := strings.ToLower(strings.TrimSpace(pattern))
		if needle != "" && strings.Contains(name, needle) {
			return true
		}
	}
	return false
}

func (c rcxConfig) censors(countryCode string) bool {
	for _, code := range c.CensorCountries {
		if code == countryCode {
			return true
		}
	}
	return false
}
