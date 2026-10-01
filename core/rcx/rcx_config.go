package rcx

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
		Canaries:  rcxStringsFingerprint(c.CanaryForeign, c.CanaryDomestic, c.CensorSNI),
		Countries: rcxStringsFingerprint(c.CensorCountries),
		Lanes:     rcxLanesFingerprint(c.Lanes),
		Egress:    rcxStringsFingerprint(c.EgressEchoes) + "|" + rcxMarkersFingerprint(c.LocalMarkers),
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
	CensorSNI               []string        `json:"cs"`
	OpenMarkers             []rcxMarker     `json:"om"`
	DomesticMarkers         []rcxMarker     `json:"dm"`
	LocalMarkers            []rcxMarker     `json:"lm"`
	NameHints               []string        `json:"nh"`
	EgressEchoes            []string        `json:"ee"`
	CountryEchoes           []string        `json:"ce,omitempty"`
	BreakerPatterns         []string        `json:"bp"`
	Lanes                   []rcxLaneConfig `json:"ln"`
	NodeRules               []rcxNodeRule   `json:"nr,omitempty"`
	AvoidCountries          []string        `json:"ac,omitempty"`
	LatencyBands            []int           `json:"lb,omitempty"`
	Ladder                  []rcxRungSpec   `json:"lad,omitempty"`
	AllowDomesticLastResort bool            `json:"dlr"`
	RequireUDP              bool            `json:"udp"`
	RespectPick             bool            `json:"rpk"`
	DwellSeconds            int             `json:"dwl"`
	WaveWidth               int             `json:"ww"`
	ProofTTLMinutes         int             `json:"pttl"`
	DegradeConfirmSeconds   int             `json:"dgc"`
	AbsCeilingMs            int             `json:"acm"`
	ThrottleFloorKBps       int             `json:"tfk"`
	SwitchImproveMs         int             `json:"sim,omitempty"`
	SwitchImprovePct        int             `json:"sip,omitempty"`
	LatencyStepMs           int             `json:"lst,omitempty"`
}

type rcxRuleAction string

const (
	rcxRuleIgnore     rcxRuleAction = "ignore"
	rcxRuleLastResort rcxRuleAction = "last-resort"
	rcxRulePrefer     rcxRuleAction = "prefer"
)

// A user rule matched on the attributes a candidate already carries. A country
// match is the measured egress, not the mmdb origin, so it fires only once a
// probe has placed the exit.
type rcxNodeRule struct {
	Provider     string        `json:"p,omitempty"`
	NameContains string        `json:"n,omitempty"`
	Group        string        `json:"g,omitempty"`
	Country      string        `json:"c,omitempty"`
	Action       rcxRuleAction `json:"a"`
}

func (r rcxNodeRule) matches(provider, name, group, country string) bool {
	if r.Provider == "" && r.NameContains == "" && r.Group == "" && r.Country == "" {
		return false
	}
	if r.Provider != "" && !strings.EqualFold(r.Provider, provider) {
		return false
	}
	if r.NameContains != "" && !strings.Contains(strings.ToLower(name), strings.ToLower(r.NameContains)) {
		return false
	}
	if r.Group != "" && !strings.EqualFold(r.Group, group) {
		return false
	}
	if r.Country != "" && !strings.EqualFold(r.Country, country) {
		return false
	}
	return true
}

func (c rcxConfig) ruleFor(provider, name, group, country string) rcxRuleAction {
	for _, rule := range c.NodeRules {
		if rule.matches(provider, name, group, country) {
			return rule.Action
		}
	}
	return ""
}

func (c rcxConfig) avoidsCountry(country string) bool {
	if country == "" {
		return false
	}
	for _, cc := range c.AvoidCountries {
		if strings.EqualFold(cc, country) {
			return true
		}
	}
	return false
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

	rcxDwellSeconds      = 90
	rcxWaveWidth         = 12
	rcxProofTTLMinutes   = 30
	rcxDegradeConfirmSec = 60
	rcxAbsCeilingMs      = 300
	rcxColdConfirmSec    = 15
	// Aggregate per-node download floor: sustained transit under demand below it reads
	// as a squeeze. Anchored at the ~128 kbit/s clamp operators throttle video to.
	rcxThrottleFloorKBps  = 16
	rcxThrottleMinConns   = 3
	rcxProbeConcurrency   = 2
	rcxProbeStaggerMs     = 250
	rcxLiveWindowSeconds  = 60
	rcxFreshWindowSeconds = 1800
)

func rcxDefaultLatencyBands() []int {
	return []int{80, 120, 180, 320}
}

// A usable ladder is non-empty and strictly increasing; anything else (a truncated
// or mis-edited payload) falls back to the shipped bands rather than mis-bucketing.
func rcxValidLatencyBands(bands []int) bool {
	if len(bands) == 0 {
		return false
	}
	previous := 0
	for _, edge := range bands {
		if edge <= previous {
			return false
		}
		previous = edge
	}
	return true
}

func (c rcxConfig) latencyBands() []int {
	if rcxValidLatencyBands(c.LatencyBands) {
		return c.LatencyBands
	}
	return rcxDefaultLatencyBands()
}

// A usable ladder names only known rungs, repeats none, and still carries the two
// safety-load-bearing rungs (verdict admits, latency ranks). Anything else — a
// truncated or mis-edited payload — falls back to the shipped default whole.
func rcxValidLadder(ladder []rcxRungSpec) bool {
	if len(ladder) == 0 {
		return false
	}
	seen := make(map[rcxRungID]struct{}, len(ladder))
	var hasVerdict, hasLatency bool
	for _, spec := range ladder {
		if !spec.ID.known() {
			return false
		}
		if _, dup := seen[spec.ID]; dup {
			return false
		}
		seen[spec.ID] = struct{}{}
		switch spec.ID {
		case rcxRungVerdict:
			hasVerdict = true
		case rcxRungLatency:
			hasLatency = true
		}
	}
	return hasVerdict && hasLatency
}

func (c rcxConfig) ladder() []rcxRungSpec {
	if rcxValidLadder(c.Ladder) {
		return c.Ladder
	}
	return rcxDefaultLadder()
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
		AbsCeilingMs:            rcxAbsCeilingMs,
		ThrottleFloorKBps:       rcxThrottleFloorKBps,
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
	if c.AbsCeilingMs <= 0 {
		c.AbsCeilingMs = rcxAbsCeilingMs
	}
	if c.ThrottleFloorKBps <= 0 {
		c.ThrottleFloorKBps = rcxThrottleFloorKBps
	}
	if !rcxKnownStrategy(c.Strategy) {
		c.Strategy = rcxStrategyBalanced
	}
	if c.SwitchImproveMs < 0 {
		c.SwitchImproveMs = 0
	}
	if c.SwitchImprovePct < 0 {
		c.SwitchImprovePct = 0
	}
	if c.LatencyStepMs < 0 {
		c.LatencyStepMs = 0
	}
	if rcxValidLadder(c.Ladder) {
		c.Ladder = rcxNormalizeLadder(c.Ladder)
	} else {
		c.Ladder = nil
	}
	c.Lanes = rcxNormalizeLanes(c.Lanes)
	return c
}

// rcxNormalizeLadder clamps a valid ladder's per-rung thresholds so a negative
// floor or tolerance cannot invert the intended comparison.
func rcxNormalizeLadder(ladder []rcxRungSpec) []rcxRungSpec {
	out := make([]rcxRungSpec, len(ladder))
	for i, spec := range ladder {
		if spec.RecurrenceFloor < 0 {
			spec.RecurrenceFloor = 0
		}
		if spec.LatencyToleranceMs < 0 {
			spec.LatencyToleranceMs = 0
		}
		out[i] = spec
	}
	return out
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
		LatencyBands:      c.latencyBands(),
		Ladder:            c.ladder(),
		Strategy:          c.Strategy,
		RequireUDP:        c.RequireUDP,
		AllowDomesticLast: c.AllowDomesticLastResort,
		Censoring:         len(c.CensorCountries) > 0,
		DwellSeconds:      c.DwellSeconds,
		AbsCeilingMs:      c.AbsCeilingMs,
		SwitchImproveMs:   c.SwitchImproveMs,
		SwitchImprovePct:  c.SwitchImprovePct,
		LatencyStepMs:     c.LatencyStepMs,
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
		if strings.EqualFold(code, countryCode) {
			return true
		}
	}
	return false
}
