package rcx

import (
	"bytes"
	"errors"
	"fmt"
	"maps"
	"slices"
	"strings"
	"unicode/utf8"

	"go.yaml.in/yaml/v3"
)

// Group targets a scenario may name besides a group's own name.
const (
	MainTarget   = "$main"
	AllTarget    = "*"
	GlobalTarget = "GLOBAL"

	maxPrograms     = 32
	maxTargetLength = 64
)

// Scenario is the connection-wide auto control above smart groups: per
// network kind it holds the tunnel mode and gives groups a profile, a
// narrower pool, or one fixed member. A group it does not name keeps its
// own binding.
type Scenario struct {
	RCX     int                          `yaml:"rcx,omitempty" json:"rcx,omitempty"`
	Title   string                       `yaml:"title,omitempty" json:"title,omitempty"`
	Tags    map[string]string            `yaml:"tags,omitempty" json:"tags,omitempty"`
	Network NetworkSpec                  `yaml:"network,omitempty" json:"network,omitzero"`
	Mode    string                       `yaml:"mode,omitempty" json:"mode,omitempty"`
	Groups  map[string]Program           `yaml:"groups,omitempty" json:"groups,omitempty"`
	On      map[string]ScenarioLayer     `yaml:"on,omitempty" json:"on,omitempty"`
	L10n    map[string]map[string]string `yaml:"l10n,omitempty" json:"l10n,omitempty"`
}

// ScenarioLayer applies on one network kind; a group it names replaces the
// base program for that group whole.
type ScenarioLayer struct {
	Mode   string             `yaml:"mode,omitempty" json:"mode,omitempty"`
	Groups map[string]Program `yaml:"groups,omitempty" json:"groups,omitempty"`
}

// Program is what a scenario does with one group.
type Program struct {
	Profile string `yaml:"profile,omitempty" json:"profile,omitempty"`
	Pool    Pool   `yaml:"pool,omitempty" json:"pool,omitzero"`
	// To holds the group on one member, a server or a whole nested group
	// such as a load balancer, with no search.
	To string `yaml:"to,omitempty" json:"to,omitempty"`
}

func ParseScenario(data []byte) (*Scenario, error) {
	if len(data) > maxProfileBytes {
		return nil, fmt.Errorf("scenario larger than %d KiB", maxProfileBytes>>10)
	}
	decoder := yaml.NewDecoder(bytes.NewReader(data))
	decoder.KnownFields(true)
	var s Scenario
	if err := decoder.Decode(&s); err != nil {
		return nil, err
	}
	return &s, s.validate()
}

func validMode(mode string) bool {
	return mode == "" || mode == "rule" || mode == "global" || mode == "direct"
}

func (s *Scenario) validate() error {
	if s.RCX > FormatVersion {
		return fmt.Errorf("scenario format %d is newer than this app understands (%d)", s.RCX, FormatVersion)
	}
	if len(s.Tags) > maxTags {
		return atPath(fmt.Errorf("more than %d tags", maxTags), "tags")
	}
	if !validMode(s.Mode) {
		return atPath(fmt.Errorf("mode %q is not rule, global or direct", s.Mode), "mode")
	}
	if err := validatePrograms(s.Groups); err != nil {
		return atPath(err, "groups")
	}
	if err := s.Network.validate(); err != nil {
		return atPath(err, "network")
	}
	if len(s.On) > maxKinds {
		return atPath(fmt.Errorf("more than %d network overrides", maxKinds), "on")
	}
	for _, kind := range slices.Sorted(maps.Keys(s.On)) {
		layer := s.On[kind]
		if !validName(kind) {
			return atPath(fmt.Errorf("network kind %q is not a short lowercase name", kind), "on", kind)
		}
		if !validMode(layer.Mode) {
			return atPath(fmt.Errorf("on %s: mode %q is not rule, global or direct", kind, layer.Mode), "on", kind, "mode")
		}
		if err := validatePrograms(layer.Groups); err != nil {
			return atPath(fmt.Errorf("on %s: %w", kind, err), "on", kind, "groups")
		}
	}
	return validateL10n(s.L10n)
}

func validatePrograms(programs map[string]Program) error {
	if len(programs) > maxPrograms {
		return fmt.Errorf("more than %d groups", maxPrograms)
	}
	for _, target := range slices.Sorted(maps.Keys(programs)) {
		program := programs[target]
		if strings.TrimSpace(target) == "" || utf8.RuneCountInString(target) > maxTargetLength {
			return atPath(fmt.Errorf("group %q needs a name of 1 to %d characters", target, maxTargetLength), target)
		}
		if program.To != "" && (program.Profile != "" || program.Pool != (Pool{})) {
			return atPath(fmt.Errorf("group %s: to holds one member, so profile and pool do not apply", target), target, "to")
		}
	}
	return nil
}

// compiledScenario is a scenario resolved against the library: every
// profile it names exists and every condition parses.
type compiledScenario struct {
	id     string
	title  string
	tags   map[string]string
	net    *Policy
	mode   string
	modeOn map[string]string
	base   map[string]Program
	on     map[string]map[string]Program
}

func (s *compiledScenario) kinds() []KindRule { return s.net.Kinds }

func (s *compiledScenario) modeFor(kind string) string {
	if mode := s.modeOn[kind]; mode != "" {
		return mode
	}
	return s.mode
}

func (s *compiledScenario) holdsMode() bool {
	return s.mode != "" || slices.ContainsFunc(slices.Collect(maps.Values(s.modeOn)), func(mode string) bool { return mode != "" })
}

func (s *compiledScenario) programs(kind string) map[string]Program {
	if layered, ok := s.on[kind]; ok {
		return layered
	}
	return s.base
}

// assignment is a program resolved to one group, with the key that named it.
type assignment struct {
	Key string
	Program
}

// targets resolves program keys to group names: a group's own name, the
// group the final MATCH rule routes to, or every other select group. A
// group's own name wins over $main, and both over *.
func (s *compiledScenario) targets(kind string, groups []string, main string) map[string]assignment {
	programs := s.programs(kind)
	out := map[string]assignment{}
	for key, program := range programs {
		if key != AllTarget && key != MainTarget {
			out[key] = assignment{key, program}
		}
	}
	if program, ok := programs[MainTarget]; ok && main != "" {
		if _, named := out[main]; !named {
			out[main] = assignment{MainTarget, program}
		}
	}
	if program, ok := programs[AllTarget]; ok {
		for _, name := range groups {
			if _, named := out[name]; !named && name != GlobalTarget {
				out[name] = assignment{AllTarget, program}
			}
		}
	}
	return out
}

// allTargets is every group the scenario names on any network kind.
func (s *compiledScenario) allTargets(groups []string, main string) []string {
	seen := map[string]bool{}
	for _, kind := range append([]string{""}, slices.Collect(maps.Keys(s.on))...) {
		for name := range s.targets(kind, groups, main) {
			seen[name] = true
		}
	}
	return slices.Sorted(maps.Keys(seen))
}

func scenarioKey(id string) string { return "scenario:" + id }

func (lib *Library) CompileScenario(id string) (*compiledScenario, error) {
	entry, ok := lib.scenarios[CanonicalID(id)]
	if !ok {
		return nil, fmt.Errorf("scenario %s not found", id)
	}
	if entry.scenario == nil {
		return nil, errors.New(entry.info.Error)
	}
	if err := lib.scenarioConsent(entry); err != nil {
		return nil, err
	}
	return lib.compileScenario(entry.info.ID, entry.scenario)
}

func (lib *Library) compileScenario(id string, s *Scenario) (*compiledScenario, error) {
	out := &compiledScenario{id: id, title: s.Title, tags: s.Tags, mode: s.Mode, modeOn: map[string]string{},
		base: maps.Clone(s.Groups), on: map[string]map[string]Program{}}
	if out.base == nil {
		out.base = map[string]Program{}
	}
	out.net = &Policy{ID: id}
	if err := compileNetwork(out.net, &Profile{Network: s.Network}); err != nil {
		return nil, err
	}
	tags := map[string]bool{}
	for name := range s.Tags {
		tags[name] = true
	}
	for _, name := range slices.Sorted(maps.Keys(s.Tags)) {
		if _, err := ParseCond(s.Tags[name], nil); err != nil {
			return nil, atPath(fmt.Errorf("tag %s: %w", name, err), "tags", name)
		}
	}
	if err := lib.checkPrograms(s.Groups, tags, "groups"); err != nil {
		return nil, err
	}
	declared := map[string]bool{}
	for _, rule := range out.net.Kinds {
		declared[rule.Kind] = true
	}
	for _, kind := range slices.Sorted(maps.Keys(s.On)) {
		if !declared[kind] {
			return nil, atPath(fmt.Errorf("on %s: the scenario declares no network kind %s", kind, kind), "on", kind)
		}
		layer := s.On[kind]
		if err := lib.checkPrograms(layer.Groups, tags, "on", kind, "groups"); err != nil {
			return nil, err
		}
		out.modeOn[kind] = layer.Mode
		merged := maps.Clone(out.base)
		maps.Copy(merged, layer.Groups)
		out.on[kind] = merged
	}
	return out, nil
}

// checkPrograms parses each pool in the scope of the scenario's tags and of
// the profile the program names; a group keeping its own profile is checked
// once it runs.
func (lib *Library) checkPrograms(programs map[string]Program, tags map[string]bool, path ...any) error {
	for _, target := range slices.Sorted(maps.Keys(programs)) {
		program := programs[target]
		at := append(slices.Clip(path), target)
		scope := condScope{tags: maps.Clone(tags), checks: map[string]bool{}}
		if program.Profile != "" {
			profile, err := lib.Resolve(program.Profile)
			if err != nil {
				return atPath(fmt.Errorf("group %s: %w", target, err), append(at, "profile")...)
			}
			for name := range profile.Tags {
				scope.tags[name] = true
			}
			for check := range profile.Checks {
				scope.checks[check] = true
			}
		}
		if program.Profile == "" && program.Pool != (Pool{}) {
			// The group's own profile is not known here; its tags resolve
			// when it runs.
			continue
		}
		if _, err := parseCond(program.Pool.Include, scope); err != nil {
			return atPath(fmt.Errorf("group %s pool include: %w", target, err), append(at, "pool", "include")...)
		}
		if _, err := parseCond(program.Pool.Exclude, scope); err != nil {
			return atPath(fmt.Errorf("group %s pool exclude: %w", target, err), append(at, "pool", "exclude")...)
		}
	}
	return nil
}

// fixedMembers are the members scenarios hold groups on; the runtime keeps
// them whole instead of opening them up.
func (s *compiledScenario) fixedMembers() []string {
	seen := map[string]bool{}
	for _, programs := range append([]map[string]Program{s.base}, slices.Collect(maps.Values(s.on))...) {
		for _, program := range programs {
			if program.To != "" {
				seen[program.To] = true
			}
		}
	}
	return slices.Sorted(maps.Keys(seen))
}

func (s *Scenario) endpoints() []Endpoint {
	return (&Profile{Network: s.Network}).endpoints()
}

func (lib *Library) scenarioConsent(entry *scenarioEntry) error {
	if entry.info.Source != SubscriptionSource {
		return nil
	}
	hosts := map[string]bool{}
	for _, endpoint := range entry.scenario.endpoints() {
		if !lib.trust.allows(endpoint.Host) {
			hosts[endpoint.Host] = true
		}
	}
	if len(hosts) == 0 {
		return nil
	}
	return &ConsentError{Profile: entry.info.ID, Hosts: slices.Sorted(maps.Keys(hosts))}
}

// FormatScenario writes a scenario in the canonical layout profiles use.
func FormatScenario(s *Scenario) (string, error) {
	return formatNode(s)
}
