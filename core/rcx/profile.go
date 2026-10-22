package rcx

import (
	"bytes"
	"errors"
	"fmt"
	"maps"
	"net"
	"net/url"
	"slices"
	"strconv"
	"strings"
	"time"
	"unicode/utf8"

	"go.yaml.in/yaml/v3"
)

const (
	FormatVersion   = 1
	maxProfileBytes = 64 << 10
	maxTiers        = 16
	maxTags         = 32
	maxExtendsDepth = 4
	maxChips        = 12
	maxChecks       = 8
	maxDiagnostics  = 8
	maxTargets      = 4
	maxKinds        = 8
	maxEcho         = 4
	maxLanguages    = 16
	maxStrings      = 64
	maxStringLength = 160
)

// Profile is the routing policy document: built-in, provider and user
// profiles, import and export all use it.
type Profile struct {
	RCX      int               `yaml:"rcx,omitempty" json:"rcx,omitempty"`
	Title    string            `yaml:"title,omitempty" json:"title,omitempty"`
	Level    string            `yaml:"level,omitempty" json:"level,omitempty"`
	Extends  string            `yaml:"extends,omitempty" json:"extends,omitempty"`
	Pool     Pool              `yaml:"pool,omitempty" json:"pool,omitzero"`
	Tags     map[string]string `yaml:"tags,omitempty" json:"tags,omitempty"`
	Prefer   []TierSpec        `yaml:"prefer,omitempty" json:"prefer,omitempty"`
	Rank     RankSpec          `yaml:"rank,omitempty" json:"rank,omitzero"`
	Switch   SwitchSpec        `yaml:"switch,omitempty" json:"switch,omitzero"`
	Stranded string            `yaml:"stranded,omitempty" json:"stranded,omitempty"`
	Energy   string            `yaml:"energy,omitempty" json:"energy,omitempty"`
	Checks   map[string]Check  `yaml:"checks,omitempty" json:"checks,omitempty"`
	Network  NetworkSpec       `yaml:"network,omitempty" json:"network,omitzero"`
	On       map[string]Layer  `yaml:"on,omitempty" json:"on,omitempty"`
	// DirectSplit is a network condition under which DIRECT rules go through
	// the group; it applies only once the user turns it on for the group.
	DirectSplit string `yaml:"direct-split,omitempty" json:"direct-split,omitempty"`
	Egress      Egress `yaml:"egress-verify,omitempty" json:"egress-verify,omitzero"`
	// L10n translates the profile's own text (title, tier labels, kind,
	// check and chip names) per language, keyed by the source string.
	L10n map[string]map[string]string `yaml:"l10n,omitempty" json:"l10n,omitempty"`
}

// PathError ties a profile error to the key it is about, so an editor can
// point at the line.
type PathError struct {
	Path []any
	Err  error
}

func (e *PathError) Error() string { return e.Err.Error() }
func (e *PathError) Unwrap() error { return e.Err }

func atPath(err error, path ...any) error {
	if err == nil {
		return nil
	}
	var inner *PathError
	if errors.As(err, &inner) {
		path = append(slices.Clip(path), inner.Path...)
	}
	return &PathError{Path: path, Err: err}
}

// Check is one declared measurement through a node: an HTTP request with the
// statuses that count as success, or a TCP or TLS connection.
type Check struct {
	HTTP   string `yaml:"http,omitempty" json:"http,omitempty"`
	TCP    string `yaml:"tcp,omitempty" json:"tcp,omitempty"`
	TLS    string `yaml:"tls,omitempty" json:"tls,omitempty"`
	SNI    string `yaml:"sni,omitempty" json:"sni,omitempty"`
	Expect []int  `yaml:"expect,omitempty" json:"expect,omitempty"`
	// Optional: a failure is not evidence against the node.
	Optional bool `yaml:"optional,omitempty" json:"optional,omitempty"`
}

// NetworkSpec classifies the network from direct (non-tunnel) diagnostics:
// the first kind whose condition holds wins.
type NetworkSpec struct {
	Diagnose map[string]Diagnostic `yaml:"diagnose,omitempty" json:"diagnose,omitempty"`
	Kinds    []KindSpec            `yaml:"kinds,omitempty" json:"kinds,omitempty"`
}

// Diagnostic succeeds when any of its targets answers.
type Diagnostic struct {
	HTTP []string `yaml:"http,omitempty" json:"http,omitempty"`
	TCP  []string `yaml:"tcp,omitempty" json:"tcp,omitempty"`
	TLS  []string `yaml:"tls,omitempty" json:"tls,omitempty"`
}

type KindSpec struct {
	Kind string `yaml:"kind" json:"kind"`
	When string `yaml:"when" json:"when"`
	// Pause: on this network nothing is checked, switched or condemned.
	Pause bool `yaml:"pause,omitempty" json:"pause,omitempty"`
}

// Layer overrides part of a profile on one network kind.
type Layer struct {
	Pool     Pool       `yaml:"pool,omitempty" json:"pool,omitzero"`
	Prefer   []TierSpec `yaml:"prefer,omitempty" json:"prefer,omitempty"`
	Rank     RankSpec   `yaml:"rank,omitempty" json:"rank,omitzero"`
	Switch   SwitchSpec `yaml:"switch,omitempty" json:"switch,omitzero"`
	Stranded string     `yaml:"stranded,omitempty" json:"stranded,omitempty"`
	Energy   string     `yaml:"energy,omitempty" json:"energy,omitempty"`
}

// Egress verifies a node's exit country: echo services asked through the
// node, plus the local GeoIP database, must agree.
type Egress struct {
	Echo  []string `yaml:"echo,omitempty" json:"echo,omitempty"`
	Agree int      `yaml:"agree,omitempty" json:"agree,omitempty"`
}

type Pool struct {
	Include string `yaml:"include,omitempty" json:"include,omitempty"`
	Exclude string `yaml:"exclude,omitempty" json:"exclude,omitempty"`
}

type TierSpec struct {
	Label      string `yaml:"label" json:"label"`
	When       string `yaml:"when" json:"when"`
	LastResort bool   `yaml:"last-resort,omitempty" json:"last-resort,omitempty"`
}

type RankSpec struct {
	By        string `yaml:"by,omitempty" json:"by,omitempty"`
	Tolerance int    `yaml:"tolerance,omitempty" json:"tolerance,omitempty"`
}

type SwitchSpec struct {
	Feel       string   `yaml:"feel,omitempty" json:"feel,omitempty"`
	Improve    *bool    `yaml:"improve,omitempty" json:"improve,omitempty"`
	Dwell      Duration `yaml:"dwell,omitempty" json:"dwell,omitempty"`
	MinGainMs  int      `yaml:"min-gain-ms,omitempty" json:"min-gain-ms,omitempty"`
	MinGainPct int      `yaml:"min-gain-pct,omitempty" json:"min-gain-pct,omitempty"`
	Confirm    int      `yaml:"confirm,omitempty" json:"confirm,omitempty"`
	MaxPerHour int      `yaml:"max-per-hour,omitempty" json:"max-per-hour,omitempty"`
}

type Duration time.Duration

func (d *Duration) UnmarshalText(text []byte) error {
	value, err := time.ParseDuration(string(text))
	if err != nil {
		return err
	}
	if value < 0 {
		return errors.New("negative duration")
	}
	*d = Duration(value)
	return nil
}

func (d Duration) MarshalText() ([]byte, error) {
	return []byte(time.Duration(d).String()), nil
}

// ParseProfile reads one profile document; unknown keys are errors, so a typo
// never silently becomes a default.
func ParseProfile(data []byte) (*Profile, error) {
	if len(data) > maxProfileBytes {
		return nil, fmt.Errorf("profile larger than %d KiB", maxProfileBytes>>10)
	}
	decoder := yaml.NewDecoder(bytes.NewReader(data))
	decoder.KnownFields(true)
	var profile Profile
	if err := decoder.Decode(&profile); err != nil {
		return nil, err
	}
	return &profile, profile.validate()
}

func (p *Profile) validate() error {
	if p.RCX > FormatVersion {
		return fmt.Errorf("profile format %d is newer than this app understands (%d)", p.RCX, FormatVersion)
	}
	switch p.Level {
	case "", "simple", "advanced":
	default:
		return atPath(fmt.Errorf("level %q is not simple or advanced", p.Level), "level")
	}
	if len(p.Tags) > maxTags {
		return atPath(fmt.Errorf("more than %d tags", maxTags), "tags")
	}
	if err := validateLayer(p.layer()); err != nil {
		return err
	}
	if len(p.Checks) > maxChecks {
		return atPath(fmt.Errorf("more than %d checks", maxChecks), "checks")
	}
	for _, id := range slices.Sorted(maps.Keys(p.Checks)) {
		if err := p.Checks[id].validate(); err != nil {
			return atPath(fmt.Errorf("check %s: %w", id, err), "checks", id)
		}
	}
	if err := p.Network.validate(); err != nil {
		return atPath(err, "network")
	}
	if len(p.On) > maxKinds {
		return atPath(fmt.Errorf("more than %d network overrides", maxKinds), "on")
	}
	for _, kind := range slices.Sorted(maps.Keys(p.On)) {
		if !validName(kind) {
			return atPath(fmt.Errorf("network kind %q is not a short lowercase name", kind), "on", kind)
		}
		if err := validateLayer(p.On[kind]); err != nil {
			return atPath(fmt.Errorf("on %s: %w", kind, err), "on", kind)
		}
	}
	if len(p.Egress.Echo) > maxEcho {
		return atPath(fmt.Errorf("more than %d echo services", maxEcho), "egress-verify", "echo")
	}
	for i, echo := range p.Egress.Echo {
		if !validURL(echo) {
			return atPath(fmt.Errorf("echo %q is not an http(s) URL", echo), "egress-verify", "echo", i)
		}
	}
	if p.Egress.Agree < 0 || p.Egress.Agree > 3 {
		return atPath(fmt.Errorf("egress agree %d is not 1 to 3", p.Egress.Agree), "egress-verify", "agree")
	}
	return validateL10n(p.L10n)
}

func validateL10n(l10n map[string]map[string]string) error {
	if len(l10n) > maxLanguages {
		return atPath(fmt.Errorf("more than %d languages", maxLanguages), "l10n")
	}
	for _, lang := range slices.Sorted(maps.Keys(l10n)) {
		if !validLanguage(lang) {
			return atPath(fmt.Errorf("%q is not a language tag like ru or zh-CN", lang), "l10n", lang)
		}
		texts := l10n[lang]
		if len(texts) > maxStrings {
			return atPath(fmt.Errorf("l10n %s: more than %d strings", lang, maxStrings), "l10n", lang)
		}
		for source, text := range texts {
			if source == "" || text == "" || utf8.RuneCountInString(source) > maxStringLength || utf8.RuneCountInString(text) > maxStringLength {
				return atPath(fmt.Errorf("l10n %s: %q needs a translation of 1 to %d characters", lang, source, maxStringLength), "l10n", lang, source)
			}
		}
	}
	return nil
}

func validLanguage(tag string) bool {
	lang, region, hasRegion := strings.Cut(tag, "-")
	if len(lang) < 2 || len(lang) > 3 || strings.ToLower(lang) != lang || hasRegion && (len(region) < 2 || len(region) > 8) {
		return false
	}
	for _, r := range lang + region {
		if (r < 'a' || r > 'z') && (r < 'A' || r > 'Z') && (r < '0' || r > '9') {
			return false
		}
	}
	return true
}

func (p *Profile) layer() Layer {
	return Layer{Pool: p.Pool, Prefer: p.Prefer, Rank: p.Rank, Switch: p.Switch, Stranded: p.Stranded, Energy: p.Energy}
}

func validateLayer(l Layer) error {
	if len(l.Prefer) > maxTiers {
		return atPath(fmt.Errorf("more than %d preference tiers", maxTiers), "prefer")
	}
	switch l.Rank.By {
	case "", "latency", "stability":
	default:
		return atPath(fmt.Errorf("rank by %q is not latency or stability", l.Rank.By), "rank", "by")
	}
	if _, ok := feels[l.Switch.Feel]; !ok && l.Switch.Feel != "" {
		return atPath(fmt.Errorf("switch feel %q is not calm, balanced or eager", l.Switch.Feel), "switch", "feel")
	}
	if _, ok := energyLevels[l.Energy]; !ok && l.Energy != "" {
		return atPath(fmt.Errorf("energy %q is not eco, balanced or precise", l.Energy), "energy")
	}
	if l.Stranded != "" && l.Stranded != "hold" && l.Stranded != "direct" && !strings.HasPrefix(l.Stranded, "group:") {
		return atPath(fmt.Errorf("stranded %q is not hold, direct or group:<name>", l.Stranded), "stranded")
	}
	return nil
}

func (c Check) validate() error {
	set := 0
	for _, target := range []string{c.HTTP, c.TCP, c.TLS} {
		if target != "" {
			set++
		}
	}
	switch {
	case set != 1:
		return errors.New("needs exactly one of http, tcp or tls")
	case c.HTTP != "" && !validURL(c.HTTP):
		return fmt.Errorf("%q is not an http(s) URL", c.HTTP)
	case c.TCP != "" && !validAddr(c.TCP), c.TLS != "" && !validAddr(c.TLS):
		return errors.New("tcp and tls need host:port")
	case len(c.Expect) > 0 && c.HTTP == "":
		return errors.New("expect applies to http only")
	}
	for _, status := range c.Expect {
		if status < 100 || status > 599 {
			return fmt.Errorf("status %d is not an HTTP status", status)
		}
	}
	return nil
}

func (n NetworkSpec) validate() error {
	if len(n.Diagnose) > maxDiagnostics {
		return atPath(fmt.Errorf("more than %d network diagnostics", maxDiagnostics), "diagnose")
	}
	for _, name := range slices.Sorted(maps.Keys(n.Diagnose)) {
		targets := n.Diagnose[name].targets()
		if !validName(name) || len(targets) == 0 || len(targets) > maxTargets {
			return atPath(fmt.Errorf("diagnostic %s needs a short lowercase name and 1 to %d targets", name, maxTargets), "diagnose", name)
		}
		for _, target := range targets {
			if target.Kind == "http" && !validURL(target.Addr) || target.Kind != "http" && !validAddr(target.Addr) {
				return atPath(fmt.Errorf("diagnostic %s: %q is not a valid %s target", name, target.Addr, target.Kind), "diagnose", name, target.Kind)
			}
		}
	}
	if len(n.Kinds) > maxKinds {
		return atPath(fmt.Errorf("more than %d network kinds", maxKinds), "kinds")
	}
	for i, kind := range n.Kinds {
		if !validName(kind.Kind) {
			return atPath(fmt.Errorf("network kind %q is not a short lowercase name", kind.Kind), "kinds", i, "kind")
		}
	}
	return nil
}

// Target is one direct diagnostic endpoint; its string form keys results
// shared by every profile that names it.
type Target struct {
	Kind string `json:"kind"`
	Addr string `json:"addr"`
}

func (t Target) String() string { return t.Kind + " " + t.Addr }

func (d Diagnostic) targets() []Target {
	var out []Target
	for _, addr := range d.HTTP {
		out = append(out, Target{"http", addr})
	}
	for _, addr := range d.TCP {
		out = append(out, Target{"tcp", addr})
	}
	for _, addr := range d.TLS {
		out = append(out, Target{"tls", addr})
	}
	return out
}

func validName(name string) bool {
	if name == "" || len(name) > 24 {
		return false
	}
	for _, r := range name {
		if (r < 'a' || r > 'z') && (r < '0' || r > '9') && r != '-' {
			return false
		}
	}
	return true
}

func validURL(raw string) bool {
	u, err := url.Parse(raw)
	return err == nil && (u.Scheme == "https" || u.Scheme == "http") && u.Host != ""
}

func validAddr(addr string) bool {
	host, port, err := net.SplitHostPort(addr)
	if err != nil || host == "" {
		return false
	}
	n, err := strconv.Atoi(port)
	return err == nil && n > 0 && n < 1<<16
}

// Binding attaches a profile to one select group. The subscription offers
// profiles and a default; the user layer picks one and may narrow the pool.
type Binding struct {
	Profiles []string `yaml:"profiles,omitempty" json:"profiles,omitempty"`
	Default  string   `yaml:"default,omitempty" json:"default,omitempty"`
	Profile  string   `yaml:"profile,omitempty" json:"profile,omitempty"`
	Pool     Pool     `yaml:"pool,omitempty" json:"pool,omitzero"`
	Feel     string   `yaml:"feel,omitempty" json:"feel,omitempty"`
	Energy   string   `yaml:"energy,omitempty" json:"energy,omitempty"`
	Chips    []Chip   `yaml:"chips,omitempty" json:"chips,omitempty"`
	// DirectSplit is honoured from the user layer only.
	DirectSplit bool `yaml:"-" json:"directSplit,omitempty"`

	// What the active scenario adds while it names the group.
	fixed string
	extra Pool
	tags  map[string]string
}

// Chip is a pool the user can switch the group to in one tap ("Change to").
type Chip struct {
	Label   string `yaml:"label" json:"label"`
	Include string `yaml:"include" json:"include"`
}

// usableChips keeps the UI from offering a pool that would break the group.
func usableChips(chips []Chip, policy *Policy) []Chip {
	tags := map[string]bool{}
	if policy != nil {
		for _, tag := range policy.Tags {
			tags[tag.Name] = true
		}
	}
	var out []Chip
	seen := map[string]bool{}
	for _, chip := range chips {
		if chip.Label == "" || seen[chip.Include] || len(out) == maxChips {
			continue
		}
		if cond, err := ParseCond(chip.Include, tags); err != nil || cond == nil {
			continue
		}
		seen[chip.Include] = true
		out = append(out, chip)
	}
	return out
}

type UserLayer struct {
	Groups   map[string]Binding `json:"groups,omitempty"`
	Profiles map[string]string  `json:"profiles,omitempty"`
	// Scenario picks the auto control over the subscription's default;
	// ScenarioOff turns auto control off altogether.
	Scenario    string            `json:"scenario,omitempty"`
	ScenarioOff bool              `json:"scenarioOff,omitempty"`
	Scenarios   map[string]string `json:"scenarios,omitempty"`
	// ManualMode: the user chose the tunnel mode, so a scenario no longer
	// sets it.
	ManualMode bool `json:"manualMode,omitempty"`
	// ProviderHosts are the hosts the subscription came from; a provider
	// profile may contact them, and the neutral built-in endpoints, freely.
	ProviderHosts []string `json:"providerHosts,omitempty"`
	// Trusted are third-party hosts the user allowed provider profiles to
	// contact.
	Trusted []string `json:"trusted,omitempty"`
}

type SubscriptionLayer struct {
	Groups    map[string]Binding
	Profiles  map[string]any
	Scenarios map[string]any
	// Scenario is the provider's default auto control.
	Scenario string
}
