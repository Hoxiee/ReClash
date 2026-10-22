package rcx

import (
	"bytes"
	"cmp"
	"errors"
	"fmt"
	"maps"
	"regexp"
	"slices"
	"strconv"
	"strings"
	"time"

	"go.yaml.in/yaml/v3"
)

// StudioRequest is one profile-editor operation; Op picks the fields it reads.
//   - lint: Text as the user profile ID, against Group when set
//   - format: Profile to YAML
//   - cond: Text to Form, or Form to Text, in the scope of Profile
//   - source: the document of profile ID
//   - merge: Text (the user's fork) brought up to Theirs from Base
//
// Kind "scenario" makes lint, format and source work on a scenario.
type StudioRequest struct {
	Op       string    `json:"op"`
	Kind     string    `json:"kind,omitempty"`
	Scenario *Scenario `json:"scenario,omitempty"`
	Text     string    `json:"text,omitempty"`
	ID       string    `json:"id,omitempty"`
	Group    string    `json:"group,omitempty"`
	Profile  *Profile  `json:"profile,omitempty"`
	Network  bool      `json:"network,omitempty"`
	Form     *CondForm `json:"form,omitempty"`
	Base     string    `json:"base,omitempty"`
	Theirs   string    `json:"theirs,omitempty"`
}

type StudioResult struct {
	Text      string       `json:"text,omitempty"`
	Profile   *Profile     `json:"profile,omitempty"`
	Scenario  *Scenario    `json:"scenario,omitempty"`
	Info      *ProfileInfo `json:"info,omitempty"`
	Errors    []Issue      `json:"errors,omitempty"`
	Warnings  []Issue      `json:"warnings,omitempty"`
	Endpoints []Endpoint   `json:"endpoints,omitempty"`
	Form      *CondForm    `json:"form,omitempty"`
	Fields    []FieldInfo  `json:"fields,omitempty"`
	Conflicts []string     `json:"conflicts,omitempty"`
	// Current and Candidate are the group's decision under its policy and
	// under the draft, from the same evidence.
	Current   *Decision `json:"current,omitempty"`
	Candidate *Decision `json:"candidate,omitempty"`
}

// Issue is a lint finding; Code and Args let the UI word it, Message is the
// English fallback.
type Issue struct {
	Line    int            `json:"line,omitempty"`
	Path    string         `json:"path,omitempty"`
	Code    string         `json:"code,omitempty"`
	Args    map[string]any `json:"args,omitempty"`
	Message string         `json:"message"`
}

// draftName keys a profile under edit that has no name yet.
const draftName = "draft"

var yamlLine = regexp.MustCompile(`line (\d+)`)

func (m *machine) studio(req StudioRequest, now time.Time) (StudioResult, error) {
	if req.Kind == "scenario" {
		return m.studioScenario(req)
	}
	switch req.Op {
	case "lint":
		return m.lint(req, now), nil
	case "format":
		if req.Profile == nil {
			return StudioResult{}, errors.New("format needs a profile")
		}
		text, err := FormatProfile(req.Profile)
		return StudioResult{Text: text}, err
	case "cond":
		return studioCond(req)
	case "source":
		data, err := m.library.Source(req.ID)
		if err != nil {
			return StudioResult{}, err
		}
		return StudioResult{Text: string(data)}, nil
	case "merge":
		text, conflicts, err := MergeProfiles([]byte(req.Base), []byte(req.Theirs), []byte(req.Text))
		return StudioResult{Text: text, Conflicts: conflicts}, err
	}
	return StudioResult{}, fmt.Errorf("unknown studio operation %q", req.Op)
}

func (m *machine) lint(req StudioRequest, now time.Time) StudioResult {
	id := req.ID
	if id == "" {
		id = UserSource + "/" + draftName
	}
	g := m.groups[req.Group]
	binding := Binding{}
	if g != nil {
		binding = g.binding
	}
	out, policy := lintIn(m.library, CanonicalID(id), req.Text, binding)
	if policy == nil || g == nil || len(g.members) == 0 {
		return out
	}
	current := m.decideWith(g, g.active(), now)
	candidate := m.decideWith(g, policy.forKind(g.kind), now)
	out.Current, out.Candidate = &current, &candidate
	out.Warnings = append(out.Warnings, matchWarnings(policy.forKind(g.kind), candidate, g.name, req.Text)...)
	return out
}

// LintProfile checks a profile document as if saved under id beside the
// built-ins and the given subscription profiles; provider tooling uses it.
func LintProfile(sub SubscriptionLayer, id, text string) StudioResult {
	out, _ := lintIn(NewLibrary(sub, UserLayer{}), CanonicalID(id), text, Binding{})
	return out
}

func lintIn(library *Library, id, text string, binding Binding) (StudioResult, *Policy) {
	var out StudioResult
	profile, err := ParseProfile([]byte(text))
	if err != nil {
		out.Errors = append(out.Errors, issueOf(err, text))
		return out, nil
	}
	out.Profile = profile
	lib := library.withDraft(id, []byte(text), profile)
	info, _ := lib.Info(id)
	out.Info = &info
	for _, endpoint := range profile.endpoints() {
		endpoint.ThirdParty = !lib.trust.allows(endpoint.Host)
		out.Endpoints = append(out.Endpoints, endpoint)
	}
	policy, err := lib.Compile(id, binding)
	var consent *ConsentError
	if errors.As(err, &consent) {
		// Allowing hosts is the user's step, not a fault of the document.
		out.Warnings = append(out.Warnings, issueOf(err, text))
		lib.trust.allowAll(consent.Hosts)
		policy, err = lib.Compile(id, binding)
	}
	if err != nil {
		out.Errors = append(out.Errors, issueOf(err, text))
		return out, nil
	}
	out.Warnings = append(out.Warnings, unusedWarnings(profile, policy, text)...)
	return out, policy
}

func unusedWarnings(profile *Profile, policy *Policy, text string) []Issue {
	var out []Issue
	used := map[string]bool{}
	for _, tag := range policy.Tags {
		used["tag:"+tag.Name] = false
	}
	conds := []*Cond{policy.Include, policy.Exclude}
	for _, compiled := range append([]*Policy{policy}, slices.Collect(maps.Values(policy.On))...) {
		for _, tier := range compiled.Tiers {
			conds = append(conds, tier.When)
		}
		conds = append(conds, compiled.Include, compiled.Exclude)
	}
	for _, cond := range conds {
		cond.walk(func(n condNode) {
			switch n := n.(type) {
			case tagNode:
				used["tag:"+n.tag] = true
			case checkNode:
				used["check:"+n.check] = true
			}
		})
	}
	for _, name := range slices.Sorted(maps.Keys(profile.Tags)) {
		if !used["tag:"+name] {
			out = append(out, issueAt(text, "tag.unused", map[string]any{"tag": name},
				fmt.Sprintf("tag %s is never used", name), "tags", name))
		}
	}
	for _, id := range slices.Sorted(maps.Keys(profile.Checks)) {
		if !used["check:"+id] {
			out = append(out, issueAt(text, "check.unused", map[string]any{"check": id},
				fmt.Sprintf("check %s is never used, so it never runs", id), "checks", id))
		}
	}
	seen := map[string]int{}
	for i, tier := range profile.Prefer {
		key := strings.Join(strings.Fields(tier.When), " ")
		if first, ok := seen[key]; ok {
			out = append(out, issueAt(text, "tier.unreachable", map[string]any{"tier": tier.Label, "after": profile.Prefer[first].Label},
				fmt.Sprintf("tier %s repeats the condition of %s, so nothing lands in it", tier.Label, profile.Prefer[first].Label), "prefer", i, "when"))
			continue
		}
		seen[key] = i
	}
	return out
}

// matchWarnings points out filters that admit no server of the group right
// now; a tier a node may still reach once checked is not empty.
func matchWarnings(policy *Policy, d Decision, group, text string) []Issue {
	var out []Issue
	admitted := 0
	reached := map[int]bool{}
	for _, row := range d.Ranking {
		if row.Excluded != nil && strings.HasPrefix(row.Excluded.Code, "pool.") {
			continue
		}
		admitted++
		if row.Excluded == nil {
			reached[row.Tier] = true
		}
		if row.Pending != "" {
			reached[row.pendingTier] = true
		}
	}
	if admitted == 0 && len(d.Ranking) > 0 {
		out = append(out, issueAt(text, "pool.empty", map[string]any{"group": group},
			fmt.Sprintf("the pool admits no server of %s", group), "pool", "include"))
		return out
	}
	for i, tier := range policy.Tiers {
		if !reached[i] && !tier.LastResort {
			out = append(out, issueAt(text, "tier.empty", map[string]any{"tier": tier.Label, "group": group},
				fmt.Sprintf("no server of %s is in %s right now", group, tier.Label), "prefer", i, "when"))
		}
	}
	return out
}

func issueAt(text, code string, args map[string]any, message string, path ...any) Issue {
	return Issue{Line: locate(text, path), Path: pathString(path), Code: code, Args: args, Message: message}
}

func issueOf(err error, text string) Issue {
	issue := Issue{Message: err.Error()}
	var at *PathError
	if errors.As(err, &at) {
		issue.Path, issue.Line = pathString(at.Path), locate(text, at.Path)
	}
	var consent *ConsentError
	if errors.As(err, &consent) {
		issue.Code, issue.Args = "profile.consent", map[string]any{"hosts": consent.Hosts}
	}
	if match := yamlLine.FindStringSubmatch(issue.Message); issue.Line == 0 && match != nil {
		issue.Line, _ = strconv.Atoi(match[1])
	}
	return issue
}

func pathString(path []any) string {
	parts := make([]string, len(path))
	for i, part := range path {
		parts[i] = fmt.Sprint(part)
	}
	return strings.Join(parts, ".")
}

// locate finds the line of the deepest key on the path that the document
// has; 0 when not even the first is there.
func locate(text string, path []any) int {
	var doc yaml.Node
	if yaml.Unmarshal([]byte(text), &doc) != nil || len(doc.Content) == 0 {
		return 0
	}
	node, line := doc.Content[0], 0
	for _, part := range path {
		next := (*yaml.Node)(nil)
		switch key := part.(type) {
		case string:
			if node.Kind != yaml.MappingNode {
				return line
			}
			for i := 0; i+1 < len(node.Content); i += 2 {
				if node.Content[i].Value == key {
					line, next = node.Content[i].Line, node.Content[i+1]
					break
				}
			}
		case int:
			if node.Kind != yaml.SequenceNode || key >= len(node.Content) {
				return line
			}
			next = node.Content[key]
			line = next.Line
		}
		if next == nil {
			return line
		}
		node = next
	}
	return line
}

// withDraft is the library with one profile replaced by a draft, so extends
// and loops resolve as they will once it is saved.
func (lib *Library) withDraft(id string, data []byte, profile *Profile) *Library {
	draft := &Library{entries: maps.Clone(lib.entries), trust: lib.trust.clone()}
	draft.add(id, strings.SplitN(id, "/", 2)[0], data, profile, nil)
	entry := draft.entries[id]
	entry.info.L10n = profile.L10n
	if resolved, err := draft.Resolve(id); err == nil {
		entry.info.L10n = resolved.L10n
	}
	return draft
}

// FormatProfile writes a profile in its canonical layout: keys in document
// order, short scalar-only blocks on one line as the built-ins are written.
func FormatProfile(profile *Profile) (string, error) {
	return formatNode(profile)
}

func formatNode(doc any) (string, error) {
	var node yaml.Node
	if err := node.Encode(doc); err != nil {
		return "", err
	}
	compact(&node, 0)
	var buf bytes.Buffer
	encoder := yaml.NewEncoder(&buf)
	encoder.SetIndent(2)
	if err := encoder.Encode(&node); err != nil {
		return "", err
	}
	return buf.String(), encoder.Close()
}

const flowWidth = 72

func compact(node *yaml.Node, depth int) {
	for _, child := range node.Content {
		compact(child, depth+1)
	}
	if depth == 0 || node.Kind != yaml.MappingNode && node.Kind != yaml.SequenceNode {
		return
	}
	if width, ok := flowWidthOf(node); ok && width <= flowWidth {
		node.Style = yaml.FlowStyle
	}
}

func flowWidthOf(node *yaml.Node) (int, bool) {
	width := 0
	for _, child := range node.Content {
		switch {
		case child.Kind == yaml.ScalarNode && !strings.Contains(child.Value, "\n"):
			width += len(child.Value) + 4
		case child.Style == yaml.FlowStyle:
			inner, _ := flowWidthOf(child)
			width += inner + 4
		default:
			return 0, false
		}
	}
	return width, true
}

func (m *machine) studioScenario(req StudioRequest) (StudioResult, error) {
	switch req.Op {
	case "lint":
		id := cmp.Or(req.ID, UserSource+"/"+draftName)
		groups := make([]string, 0, len(m.topology.Groups))
		for _, g := range m.topology.Groups {
			groups = append(groups, g.Name)
		}
		return lintScenarioIn(m.library, CanonicalID(id), req.Text, groups), nil
	case "format":
		if req.Scenario == nil {
			return StudioResult{}, errors.New("format needs a scenario")
		}
		text, err := FormatScenario(req.Scenario)
		return StudioResult{Text: text}, err
	case "source":
		data, err := m.library.ScenarioSource(req.ID)
		return StudioResult{Text: string(data)}, err
	}
	return StudioResult{}, fmt.Errorf("unknown scenario operation %q", req.Op)
}

// LintScenario checks a scenario document as if saved under id; without
// groups, names are not checked against a config.
func LintScenario(sub SubscriptionLayer, id, text string) StudioResult {
	return lintScenarioIn(NewLibrary(sub, UserLayer{}), CanonicalID(id), text, nil)
}

func lintScenarioIn(library *Library, id, text string, groups []string) StudioResult {
	var out StudioResult
	s, err := ParseScenario([]byte(text))
	if err != nil {
		out.Errors = append(out.Errors, issueOf(err, text))
		return out
	}
	out.Scenario = s
	lib := library.withScenarioDraft(id, []byte(text))
	info, _ := lib.ScenarioInfo(id)
	out.Info = &info
	for _, endpoint := range s.endpoints() {
		endpoint.ThirdParty = !lib.trust.allows(endpoint.Host)
		out.Endpoints = append(out.Endpoints, endpoint)
	}
	if _, err := lib.compileScenario(id, s); err != nil {
		out.Errors = append(out.Errors, issueOf(err, text))
		return out
	}
	used := map[string]bool{}
	missing := func(programs map[string]Program, path ...any) {
		for _, target := range slices.Sorted(maps.Keys(programs)) {
			program := programs[target]
			for _, cond := range []string{program.Pool.Include, program.Pool.Exclude} {
				for name := range s.Tags {
					used[name] = used[name] || strings.Contains(cond, "tag("+name+")")
				}
			}
			if groups == nil || target == MainTarget || target == AllTarget || target == GlobalTarget || slices.Contains(groups, target) {
				continue
			}
			out.Warnings = append(out.Warnings, issueAt(text, "group.missing", map[string]any{"group": target},
				fmt.Sprintf("this config has no group %s", target), append(slices.Clip(path), target)...))
		}
	}
	missing(s.Groups, "groups")
	for _, kind := range slices.Sorted(maps.Keys(s.On)) {
		missing(s.On[kind].Groups, "on", kind, "groups")
	}
	for _, name := range slices.Sorted(maps.Keys(s.Tags)) {
		if !used[name] {
			out.Warnings = append(out.Warnings, issueAt(text, "tag.unused", map[string]any{"tag": name},
				fmt.Sprintf("tag %s is never used", name), "tags", name))
		}
	}
	return out
}

func (lib *Library) withScenarioDraft(id string, data []byte) *Library {
	draft := &Library{entries: lib.entries, scenarios: maps.Clone(lib.scenarios), trust: lib.trust.clone()}
	draft.addScenario(id, strings.SplitN(id, "/", 2)[0], data)
	return draft
}
