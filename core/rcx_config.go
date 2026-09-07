package main

import (
	"crypto/sha256"
	"encoding/hex"
	"sort"
	"strconv"
	"strings"
)

type rcxMarker struct {
	URL      string `json:"url"`
	Statuses []int  `json:"statuses"`
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
}

func (c rcxConfig) fingerprints() rcxConfigFingerprints {
	return rcxConfigFingerprints{
		Open:      rcxMarkersFingerprint(c.OpenMarkers),
		Domestic:  rcxMarkersFingerprint(c.DomesticMarkers),
		Canaries:  rcxStringsFingerprint(c.CanaryForeign, c.CanaryDomestic),
		Countries: rcxStringsFingerprint(c.CensorCountries),
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

func rcxFingerprint(values []string) string {
	sum := sha256.Sum256([]byte(strings.Join(values, "\x1f")))
	return hex.EncodeToString(sum[:8])
}

type rcxConfig struct {
	Enabled                 bool        `json:"on"`
	Preset                  string      `json:"preset"`
	DefaultsVersion         int         `json:"dv"`
	Strategy                string      `json:"st"`
	CensorCountries         []string    `json:"cc"`
	CanaryForeign           []string    `json:"cf"`
	CanaryDomestic          []string    `json:"cd"`
	OpenMarkers             []rcxMarker `json:"om"`
	DomesticMarkers         []rcxMarker `json:"dm"`
	BreakerPatterns         []string    `json:"bp"`
	AllowDomesticLastResort bool        `json:"dlr"`
	RequireUDP              bool        `json:"udp"`
	RespectPick             bool        `json:"rpk"`
	DwellSeconds            int         `json:"dwl"`
	WaveWidth               int         `json:"ww"`
	ProofTTLMinutes         int         `json:"pttl"`
	DegradeConfirmSeconds   int         `json:"dgc"`
}

const (
	rcxStrategyBalanced = "balanced"
	rcxStrategyLatency  = "lowest-latency"

	rcxDwellSeconds       = 90
	rcxWaveWidth          = 12
	rcxProofTTLMinutes    = 30
	rcxDegradeConfirmSec  = 60
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
	if c.Strategy != rcxStrategyLatency {
		c.Strategy = rcxStrategyBalanced
	}
	return c
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
