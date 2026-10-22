package rcx

import (
	"cmp"
	"embed"
	"errors"
	"fmt"
	"maps"
	"path"
	"slices"
	"strings"
	"time"

	"go.yaml.in/yaml/v3"
)

//go:embed builtin/*.yaml builtin/scenarios/*.yaml
var builtinFiles embed.FS

const (
	BuiltinSource      = "builtin"
	SubscriptionSource = "provider"
	UserSource         = "user"

	DefaultProfile = "builtin/simple"
)

// Neutral echo services, asked through the node only; the local GeoIP
// database is the other voice when it is installed.
var defaultEcho = []string{"https://www.cloudflare.com/cdn-cgi/trace", "https://ipinfo.io/json"}

const defaultAgree = 2

type feel struct {
	dwell      time.Duration
	minGainMs  int
	minGainPct int
	confirm    int
	maxPerHour int
}

var feels = map[string]feel{
	"calm":     {dwell: 30 * time.Minute, minGainMs: 60, minGainPct: 30, confirm: 3, maxPerHour: 2},
	"balanced": {dwell: 10 * time.Minute, minGainMs: 30, minGainPct: 20, confirm: 2, maxPerHour: 4},
	"eager":    {dwell: 2 * time.Minute, minGainMs: 15, minGainPct: 10, confirm: 2, maxPerHour: 8},
}

// Policy is a profile compiled for one group: every condition parsed and every
// default resolved, so Decide never interprets text.
type Policy struct {
	ID         string
	Title      string
	Level      string
	Include    *Cond
	Exclude    *Cond
	Tags       []NamedCond
	Tiers      []Tier
	RankBy     string
	Tolerance  int
	Improve    bool
	Dwell      time.Duration
	MinGainMs  int
	MinGainPct int
	Confirm    int
	MaxPerHour int
	Stranded   string
	Energy     string
	// Fixed holds the group on this member; a scenario sets it.
	Fixed string

	Checks      map[string]Check
	CheckIDs    []string
	UsesExit    bool
	Egress      Egress
	Diagnostics map[string][]Target
	Kinds       []KindRule
	DirectSplit *Cond
	// On holds the policy compiled for each network kind with an override.
	On map[string]*Policy
}

type KindRule struct {
	Kind  string
	When  *Cond
	Pause bool
}

// forKind is the policy in force on a network of the given kind.
func (p *Policy) forKind(kind string) *Policy {
	if layered, ok := p.On[kind]; ok {
		return layered
	}
	return p
}

func (p *Policy) pauses(kind string) bool {
	for _, rule := range p.Kinds {
		if rule.Kind == kind {
			return rule.Pause
		}
	}
	return false
}

type NamedCond struct {
	Name string
	Cond *Cond
}

type Tier struct {
	Label      string
	When       *Cond
	LastResort bool
}

// ProfileInfo is one entry of the chooser.
type ProfileInfo struct {
	ID string `json:"id"`
	// Kind is "scenario" for the connection-wide auto control, empty for a
	// group profile.
	Kind    string `json:"kind,omitempty"`
	Title   string `json:"title"`
	Level   string `json:"level"`
	Source  string `json:"source"`
	Extends string `json:"extends,omitempty"`
	Error   string `json:"error,omitempty"`
	// L10n is resolved through extends, so a fork keeps its base's text.
	L10n map[string]map[string]string `json:"l10n,omitempty"`
	// Consent lists the third-party hosts the user must allow before this
	// provider profile runs.
	Consent []string `json:"consent,omitempty"`
}

type libraryEntry struct {
	info    ProfileInfo
	profile *Profile
	source  []byte
}

type scenarioEntry struct {
	info     ProfileInfo
	scenario *Scenario
	source   []byte
}

// Library holds every profile a binding may name and every scenario, each
// keyed by canonical id (builtin/x, provider/x, user/x) in its own space.
type Library struct {
	entries   map[string]*libraryEntry
	scenarios map[string]*scenarioEntry
	trust     trust
}

func NewLibrary(sub SubscriptionLayer, user UserLayer) *Library {
	lib := &Library{entries: map[string]*libraryEntry{}, scenarios: map[string]*scenarioEntry{}, trust: newTrust(user)}
	files, _ := builtinFiles.ReadDir("builtin")
	for _, file := range files {
		data, err := builtinFiles.ReadFile("builtin/" + file.Name())
		if err != nil {
			continue
		}
		name := strings.TrimSuffix(file.Name(), path.Ext(file.Name()))
		profile, err := ParseProfile(data)
		lib.add(BuiltinSource+"/"+name, BuiltinSource, data, profile, err)
	}
	for name, node := range sub.Profiles {
		data, err := yaml.Marshal(node)
		var profile *Profile
		if err == nil {
			profile, err = ParseProfile(data)
		}
		// Map order is lost on the way here; the canonical layout reads
		// like the built-ins.
		if err == nil {
			if text, err := FormatProfile(profile); err == nil {
				data = []byte(text)
			}
		}
		lib.add(SubscriptionSource+"/"+name, SubscriptionSource, data, profile, err)
	}
	for name, text := range user.Profiles {
		profile, err := ParseProfile([]byte(text))
		lib.add(UserSource+"/"+name, UserSource, []byte(text), profile, err)
	}
	for id, entry := range lib.entries {
		if entry.profile == nil {
			continue
		}
		entry.info.L10n = entry.profile.L10n
		if resolved, err := lib.Resolve(id); err == nil {
			entry.info.L10n = resolved.L10n
		}
		var consent *ConsentError
		if errors.As(lib.consent(id), &consent) {
			entry.info.Consent = consent.Hosts
		}
	}
	// Scenarios name profiles, so they load once every profile is in.
	lib.loadScenarios(sub, user)
	return lib
}

func (lib *Library) add(id, source string, data []byte, profile *Profile, err error) {
	entry := &libraryEntry{info: ProfileInfo{ID: id, Source: source, Title: id}, profile: profile, source: data}
	if profile != nil {
		if profile.Title != "" {
			entry.info.Title = profile.Title
		}
		entry.info.Level = profile.Level
		entry.info.Extends = profile.Extends
	}
	if err != nil {
		entry.info.Error = err.Error()
		entry.profile = nil
	}
	lib.entries[id] = entry
}

// CanonicalID resolves a bare name, as a subscription writes it, to its
// provider profile.
func CanonicalID(id string) string {
	id = strings.TrimSpace(id)
	if id == "" || strings.Contains(id, "/") {
		return id
	}
	return SubscriptionSource + "/" + id
}

func (lib *Library) Infos() []ProfileInfo {
	infos := make([]ProfileInfo, 0, len(lib.entries)+len(lib.scenarios))
	for _, entry := range lib.entries {
		infos = append(infos, entry.info)
	}
	for _, entry := range lib.scenarios {
		infos = append(infos, entry.info)
	}
	sourceOrder := map[string]int{BuiltinSource: 0, SubscriptionSource: 1, UserSource: 2}
	slices.SortFunc(infos, func(a, b ProfileInfo) int {
		if d := strings.Compare(a.Kind, b.Kind); d != 0 {
			return d
		}
		if d := sourceOrder[a.Source] - sourceOrder[b.Source]; d != 0 {
			return d
		}
		return strings.Compare(a.ID, b.ID)
	})
	return infos
}

func (lib *Library) loadScenarios(sub SubscriptionLayer, user UserLayer) {
	files, _ := builtinFiles.ReadDir("builtin/scenarios")
	for _, file := range files {
		data, err := builtinFiles.ReadFile("builtin/scenarios/" + file.Name())
		if err != nil {
			continue
		}
		name := strings.TrimSuffix(file.Name(), path.Ext(file.Name()))
		lib.addScenario(BuiltinSource+"/"+name, BuiltinSource, data)
	}
	for name, node := range sub.Scenarios {
		data, err := yaml.Marshal(node)
		if err != nil {
			continue
		}
		if s, err := ParseScenario(data); err == nil {
			if text, err := FormatScenario(s); err == nil {
				data = []byte(text)
			}
		}
		lib.addScenario(SubscriptionSource+"/"+name, SubscriptionSource, data)
	}
	for name, text := range user.Scenarios {
		lib.addScenario(UserSource+"/"+name, UserSource, []byte(text))
	}
}

func (lib *Library) addScenario(id, source string, data []byte) {
	entry := &scenarioEntry{info: ProfileInfo{ID: id, Kind: "scenario", Source: source, Title: id}, source: data}
	lib.scenarios[id] = entry
	s, err := ParseScenario(data)
	if err != nil {
		entry.info.Error = err.Error()
		return
	}
	entry.scenario = s
	entry.info.Title, entry.info.L10n = cmp.Or(s.Title, id), s.L10n
	if _, err := lib.compileScenario(id, s); err != nil {
		entry.info.Error = err.Error()
	}
	var consent *ConsentError
	if errors.As(lib.scenarioConsent(entry), &consent) {
		entry.info.Consent = consent.Hosts
	}
}

func (lib *Library) ScenarioInfo(id string) (ProfileInfo, bool) {
	entry, ok := lib.scenarios[CanonicalID(id)]
	if !ok {
		return ProfileInfo{}, false
	}
	return entry.info, true
}

func (lib *Library) ScenarioSource(id string) ([]byte, error) {
	entry, ok := lib.scenarios[CanonicalID(id)]
	if !ok {
		return nil, fmt.Errorf("scenario %s not found", id)
	}
	return entry.source, nil
}

func (lib *Library) Info(id string) (ProfileInfo, bool) {
	entry, ok := lib.entries[CanonicalID(id)]
	if !ok {
		return ProfileInfo{}, false
	}
	return entry.info, true
}

func (lib *Library) Has(id string) bool {
	_, ok := lib.entries[CanonicalID(id)]
	return ok
}

// Source is the profile's document as its author wrote it: the base a fork
// is made from and later compared against.
func (lib *Library) Source(id string) ([]byte, error) {
	entry, ok := lib.entries[CanonicalID(id)]
	if !ok {
		return nil, fmt.Errorf("profile %s not found", id)
	}
	return entry.source, nil
}

// Resolve flattens the extends chain of a profile, base first.
func (lib *Library) Resolve(id string) (*Profile, error) {
	chain, err := lib.chain(id)
	if err != nil {
		return nil, err
	}
	merged := &Profile{}
	for i := len(chain) - 1; i >= 0; i-- {
		merged = mergeProfile(merged, chain[i].profile)
	}
	merged.Extends = ""
	return merged, nil
}

// chain lists a profile and every profile it extends, the profile first.
func (lib *Library) chain(id string) ([]*libraryEntry, error) {
	id = CanonicalID(id)
	var chain []*libraryEntry
	seen := map[string]bool{}
	for current := id; current != ""; {
		if seen[current] {
			return nil, fmt.Errorf("profile %s extends itself", current)
		}
		if len(chain) > maxExtendsDepth {
			return nil, fmt.Errorf("profile %s extends more than %d levels deep", id, maxExtendsDepth)
		}
		seen[current] = true
		entry, ok := lib.entries[current]
		if !ok {
			return nil, fmt.Errorf("profile %s not found", current)
		}
		if entry.profile == nil {
			return nil, fmt.Errorf("profile %s: %s", current, entry.info.Error)
		}
		chain = append(chain, entry)
		current = CanonicalID(entry.profile.Extends)
	}
	return chain, nil
}

// mergeProfile layers child over base. Pools only ever narrow: includes are
// joined with and, excludes with or, so no layer can admit what a lower one
// kept out.
func mergeProfile(base, child *Profile) *Profile {
	out := *base
	out.Tags = maps.Clone(base.Tags)
	if child.RCX != 0 {
		out.RCX = child.RCX
	}
	if child.Title != "" {
		out.Title = child.Title
	}
	if child.Level != "" {
		out.Level = child.Level
	}
	out.Pool = narrowPool(base.Pool, child.Pool)
	for name, cond := range child.Tags {
		if out.Tags == nil {
			out.Tags = map[string]string{}
		}
		out.Tags[name] = cond
	}
	if len(child.Prefer) > 0 {
		out.Prefer = slices.Clone(child.Prefer)
	}
	if child.Rank.By != "" {
		out.Rank.By = child.Rank.By
	}
	if child.Rank.Tolerance != 0 {
		out.Rank.Tolerance = child.Rank.Tolerance
	}
	s, c := &out.Switch, child.Switch
	if c.Feel != "" {
		*s = SwitchSpec{Feel: c.Feel, Improve: s.Improve}
	}
	if c.Improve != nil {
		s.Improve = c.Improve
	}
	if c.Dwell != 0 {
		s.Dwell = c.Dwell
	}
	if c.MinGainMs != 0 {
		s.MinGainMs = c.MinGainMs
	}
	if c.MinGainPct != 0 {
		s.MinGainPct = c.MinGainPct
	}
	if c.Confirm != 0 {
		s.Confirm = c.Confirm
	}
	if c.MaxPerHour != 0 {
		s.MaxPerHour = c.MaxPerHour
	}
	if child.Stranded != "" {
		out.Stranded = child.Stranded
	}
	if child.Energy != "" {
		out.Energy = child.Energy
	}
	out.Checks = mergeMap(base.Checks, child.Checks)
	out.Network.Diagnose = mergeMap(base.Network.Diagnose, child.Network.Diagnose)
	if len(child.Network.Kinds) > 0 {
		out.Network.Kinds = slices.Clone(child.Network.Kinds)
	}
	out.On = mergeMap(base.On, child.On)
	if child.DirectSplit != "" {
		out.DirectSplit = child.DirectSplit
	}
	if len(child.Egress.Echo) > 0 {
		out.Egress.Echo = slices.Clone(child.Egress.Echo)
	}
	if child.Egress.Agree != 0 {
		out.Egress.Agree = child.Egress.Agree
	}
	if len(child.L10n) > 0 {
		out.L10n = map[string]map[string]string{}
		for lang := range mergeMap(base.L10n, child.L10n) {
			out.L10n[lang] = mergeMap(base.L10n[lang], child.L10n[lang])
		}
	}
	return &out
}

func mergeMap[V any](base, child map[string]V) map[string]V {
	if len(child) == 0 {
		return maps.Clone(base)
	}
	out := maps.Clone(base)
	if out == nil {
		out = map[string]V{}
	}
	maps.Copy(out, child)
	return out
}

func narrowPool(base, child Pool) Pool {
	join := func(a, b, op string) string {
		switch {
		case strings.TrimSpace(a) == "":
			return b
		case strings.TrimSpace(b) == "":
			return a
		default:
			return "(" + a + ") " + op + " (" + b + ")"
		}
	}
	return Pool{Include: join(base.Include, child.Include, "and"), Exclude: join(base.Exclude, child.Exclude, "or")}
}

// Compile builds the policy a group runs: its profile with the binding's
// narrowing and slider choices on top.
func (lib *Library) Compile(id string, binding Binding) (*Policy, error) {
	profile, err := lib.Resolve(id)
	if err != nil {
		return nil, err
	}
	if err := lib.consent(id); err != nil {
		return nil, err
	}
	overlay := &Profile{Pool: narrowPool(binding.Pool, binding.extra), Energy: binding.Energy, Tags: binding.tags}
	if binding.Feel != "" {
		overlay.Switch.Feel = binding.Feel
	}
	if err := overlay.validate(); err != nil {
		return nil, err
	}
	policy, err := compileProfile(CanonicalID(id), mergeProfile(profile, overlay))
	if err != nil {
		return nil, err
	}
	policy.Fixed = binding.fixed
	declared := map[string]bool{}
	for _, rule := range policy.Kinds {
		declared[rule.Kind] = true
	}
	// The user's choices sit above a network override, as they sit above
	// the profile.
	for _, kind := range slices.Sorted(maps.Keys(profile.On)) {
		if !declared[kind] {
			return nil, atPath(fmt.Errorf("on %s: the profile declares no network kind %s", kind, kind), "on", kind)
		}
		layer := profile.On[kind]
		layered := mergeProfile(mergeProfile(profile, &Profile{
			Pool: layer.Pool, Prefer: layer.Prefer, Rank: layer.Rank, Switch: layer.Switch,
			Stranded: layer.Stranded, Energy: layer.Energy,
		}), overlay)
		compiled, err := compileProfile(CanonicalID(id), layered)
		if err != nil {
			return nil, atPath(fmt.Errorf("on %s: %w", kind, err), "on", kind)
		}
		compiled.Fixed = binding.fixed
		if policy.On == nil {
			policy.On = map[string]*Policy{}
		}
		policy.On[kind] = compiled
	}
	return policy, nil
}

func compileProfile(id string, profile *Profile) (*Policy, error) {
	policy := &Policy{
		ID:        id,
		Title:     profile.Title,
		Level:     profile.Level,
		RankBy:    profile.Rank.By,
		Tolerance: profile.Rank.Tolerance,
		Stranded:  profile.Stranded,
		Energy:    profile.Energy,
	}
	if policy.Level == "" {
		policy.Level = "simple"
	}
	if policy.RankBy == "" {
		policy.RankBy = "latency"
	}
	if policy.Stranded == "" {
		policy.Stranded = "hold"
	}
	if policy.Energy == "" {
		policy.Energy = "balanced"
	}
	tagNames := map[string]bool{}
	for name := range profile.Tags {
		tagNames[name] = true
	}
	for _, name := range slices.Sorted(maps.Keys(profile.Tags)) {
		cond, err := ParseCond(profile.Tags[name], nil)
		if err != nil {
			return nil, atPath(fmt.Errorf("tag %s: %w", name, err), "tags", name)
		}
		policy.Tags = append(policy.Tags, NamedCond{Name: name, Cond: cond})
	}
	nodeScope := condScope{tags: tagNames, checks: map[string]bool{}}
	for id := range profile.Checks {
		nodeScope.checks[id] = true
	}
	var err error
	if policy.Include, err = parseCond(profile.Pool.Include, nodeScope); err != nil {
		return nil, atPath(fmt.Errorf("pool include: %w", err), "pool", "include")
	}
	if policy.Exclude, err = parseCond(profile.Pool.Exclude, nodeScope); err != nil {
		return nil, atPath(fmt.Errorf("pool exclude: %w", err), "pool", "exclude")
	}
	for i, spec := range profile.Prefer {
		when, err := parseCond(spec.When, nodeScope)
		if err != nil {
			return nil, atPath(fmt.Errorf("prefer %d (%s): %w", i+1, spec.Label, err), "prefer", i, "when")
		}
		label := spec.Label
		if label == "" {
			label = fmt.Sprintf("Tier %d", i+1)
		}
		policy.Tiers = append(policy.Tiers, Tier{Label: label, When: when, LastResort: spec.LastResort})
	}
	if len(policy.Tiers) == 0 {
		when, _ := ParseCond("not dead", nil)
		policy.Tiers = []Tier{{Label: "Working", When: when}}
	}
	feelName := profile.Switch.Feel
	if feelName == "" {
		feelName = "balanced"
	}
	preset := feels[feelName]
	policy.Dwell = pick(time.Duration(profile.Switch.Dwell), preset.dwell)
	policy.MinGainMs = pick(profile.Switch.MinGainMs, preset.minGainMs)
	policy.MinGainPct = pick(profile.Switch.MinGainPct, preset.minGainPct)
	policy.Confirm = pick(profile.Switch.Confirm, preset.confirm)
	policy.MaxPerHour = pick(profile.Switch.MaxPerHour, preset.maxPerHour)
	if profile.Switch.Improve != nil {
		policy.Improve = *profile.Switch.Improve
	}
	if err := compileNetwork(policy, profile); err != nil {
		return nil, err
	}
	conds := []*Cond{policy.Include, policy.Exclude}
	for _, tier := range policy.Tiers {
		conds = append(conds, tier.When)
	}
	used := map[string]bool{}
	for _, cond := range conds {
		cond.walk(func(n condNode) {
			switch n := n.(type) {
			case checkNode:
				used[n.check] = true
			case stringNode:
				policy.UsesExit = policy.UsesExit || n.field == "exit.country"
			}
		})
	}
	policy.Checks = profile.Checks
	policy.CheckIDs = slices.Sorted(maps.Keys(used))
	policy.Egress = Egress{Echo: profile.Egress.Echo, Agree: pick(profile.Egress.Agree, defaultAgree)}
	if len(policy.Egress.Echo) == 0 {
		policy.Egress.Echo = defaultEcho
	}
	return policy, nil
}

func compileNetwork(policy *Policy, profile *Profile) error {
	netScope := condScope{diags: map[string]bool{}}
	policy.Diagnostics = map[string][]Target{}
	for name, diag := range profile.Network.Diagnose {
		netScope.diags[name] = true
		policy.Diagnostics[name] = diag.targets()
	}
	for i, spec := range profile.Network.Kinds {
		when, err := parseCond(spec.When, netScope)
		if err != nil {
			return atPath(fmt.Errorf("network kind %s: %w", spec.Kind, err), "network", "kinds", i, "when")
		}
		policy.Kinds = append(policy.Kinds, KindRule{Kind: spec.Kind, When: when, Pause: spec.Pause})
	}
	split, err := parseCond(profile.DirectSplit, netScope)
	if err != nil {
		return atPath(fmt.Errorf("direct-split: %w", err), "direct-split")
	}
	policy.DirectSplit = split
	return nil
}

func pick[T comparable](value, fallback T) T {
	var zero T
	if value == zero {
		return fallback
	}
	return value
}
