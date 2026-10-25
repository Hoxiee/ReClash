package rcx

import (
	"bytes"
	"errors"
	"fmt"
	"maps"
	"regexp"
	"strconv"
	"strings"

	"go.yaml.in/yaml/v3"
)

const maxBundleBytes = 256 << 10

// BundleItem is one scenario or profile unpacked from a shared document.
type BundleItem struct {
	Kind  string `json:"kind"`
	Name  string `json:"name"`
	Title string `json:"title,omitempty"`
	Text  string `json:"text"`
}

var nameRun = regexp.MustCompile(`[^a-z0-9]+`)

// freeName mirrors rcxFreeProfileName on the Dart side.
func freeName(taken map[string]bool, title, fallback string) string {
	base := strings.Trim(nameRun.ReplaceAllString(strings.ToLower(title), "-"), "-")
	if base == "" {
		base = fallback
	}
	name := base
	for i := 2; taken[name]; i++ {
		name = base + "-" + strconv.Itoa(i)
	}
	return name
}

func mapValue(node *yaml.Node, key string) *yaml.Node {
	if node == nil || node.Kind != yaml.MappingNode {
		return nil
	}
	for i := 0; i+1 < len(node.Content); i += 2 {
		if node.Content[i].Value == key {
			return node.Content[i+1]
		}
	}
	return nil
}

func docRoot(data []byte) (*yaml.Node, error) {
	var doc yaml.Node
	if err := yaml.Unmarshal(data, &doc); err != nil {
		return nil, err
	}
	if len(doc.Content) == 0 {
		return nil, errors.New("empty document")
	}
	return doc.Content[0], nil
}

func nodeText(node *yaml.Node) (string, error) {
	var buf bytes.Buffer
	encoder := yaml.NewEncoder(&buf)
	encoder.SetIndent(2)
	if err := encoder.Encode(node); err != nil {
		return "", err
	}
	return buf.String(), encoder.Close()
}

// profileRefs are the scalar nodes of a profile or scenario that name a
// profile.
func profileRefs(root *yaml.Node, scenario bool) []*yaml.Node {
	var out []*yaml.Node
	add := func(node *yaml.Node) {
		if ref := mapValue(node, "profile"); ref != nil && ref.Kind == yaml.ScalarNode && ref.Value != "" {
			out = append(out, ref)
		}
	}
	if !scenario {
		if ref := mapValue(root, "extends"); ref != nil && ref.Kind == yaml.ScalarNode && ref.Value != "" {
			out = append(out, ref)
		}
		return out
	}
	programs := func(groups *yaml.Node) {
		if groups != nil && groups.Kind == yaml.MappingNode {
			for i := 1; i < len(groups.Content); i += 2 {
				add(groups.Content[i])
			}
		}
	}
	programs(mapValue(root, "groups"))
	if on := mapValue(root, "on"); on != nil && on.Kind == yaml.MappingNode {
		for i := 1; i < len(on.Content); i += 2 {
			programs(mapValue(on.Content[i], "groups"))
		}
	}
	if routes := mapValue(root, "routes"); routes != nil && routes.Kind == yaml.SequenceNode {
		for _, route := range routes.Content {
			add(route)
		}
	}
	return out
}

func isBuiltinRef(ref string) bool { return strings.HasPrefix(CanonicalID(ref), BuiltinSource+"/") }

func mapEntry(key, value string) []*yaml.Node {
	return []*yaml.Node{{Kind: yaml.ScalarNode, Value: key}, {Kind: yaml.ScalarNode, Value: value}}
}

// Export returns the document of id as it is when it needs only built-ins;
// otherwise a bundle carrying every other profile it reaches, renamed to
// user profiles.
func (lib *Library) Export(id, kind string) (string, error) {
	scenario := kind == "scenario"
	var data []byte
	var err error
	if scenario {
		data, err = lib.ScenarioSource(id)
	} else {
		data, err = lib.Source(id)
	}
	if err != nil {
		return "", err
	}
	root, err := docRoot(data)
	if err != nil {
		return "", err
	}
	names := map[string]string{}
	used := map[string]bool{}
	var order []string
	var queue []*yaml.Node
	queue = append(queue, profileRefs(root, scenario)...)
	var refs []*yaml.Node
	profiles := map[string]*yaml.Node{}
	for len(queue) > 0 {
		ref := queue[0]
		queue = queue[1:]
		if isBuiltinRef(ref.Value) {
			continue
		}
		refs = append(refs, ref)
		canon := CanonicalID(ref.Value)
		if _, ok := names[canon]; ok {
			continue
		}
		source, err := lib.Source(canon)
		if err != nil {
			return "", err
		}
		node, err := docRoot(source)
		if err != nil {
			return "", fmt.Errorf("profile %s: %w", canon, err)
		}
		title := mapValue(node, "title")
		label := canon[strings.LastIndex(canon, "/")+1:]
		if title != nil && title.Value != "" {
			label = title.Value
		}
		names[canon] = freeName(used, label, "profile")
		used[names[canon]] = true
		order = append(order, canon)
		profiles[canon] = node
		queue = append(queue, profileRefs(node, false)...)
	}
	if len(order) == 0 {
		return string(data), nil
	}
	for _, ref := range refs {
		ref.Value = UserSource + "/" + names[CanonicalID(ref.Value)]
	}
	title := mapValue(root, "title")
	bundleTitle := id[strings.LastIndex(id, "/")+1:]
	if title != nil && title.Value != "" {
		bundleTitle = title.Value
	}
	top := &yaml.Node{Kind: yaml.MappingNode}
	top.Content = append(top.Content, mapEntry("rcx", "1")...)
	top.Content[1].Tag = "!!int"
	top.Content = append(top.Content, mapEntry("kind", "bundle")...)
	top.Content = append(top.Content, mapEntry("title", bundleTitle)...)
	if scenario {
		name := freeName(used, bundleTitle, "scenario")
		top.Content = append(top.Content, &yaml.Node{Kind: yaml.ScalarNode, Value: "scenarios"},
			&yaml.Node{Kind: yaml.MappingNode, Content: []*yaml.Node{{Kind: yaml.ScalarNode, Value: name}, root}})
	}
	section := &yaml.Node{Kind: yaml.MappingNode}
	if !scenario {
		self := freeName(used, bundleTitle, "profile")
		section.Content = append(section.Content, &yaml.Node{Kind: yaml.ScalarNode, Value: self}, root)
	}
	for _, canon := range order {
		section.Content = append(section.Content, &yaml.Node{Kind: yaml.ScalarNode, Value: names[canon]}, profiles[canon])
	}
	top.Content = append(top.Content, &yaml.Node{Kind: yaml.ScalarNode, Value: "profiles"}, section)
	return nodeText(top)
}

type bundleDoc struct {
	kind string
	key  string
	node *yaml.Node
}

// readBundle lists the documents of a bundle, profiles first; nil when the
// text is not a bundle.
func readBundle(data []byte) ([]bundleDoc, *yaml.Node, error) {
	root, err := docRoot(data)
	if err != nil || root.Kind != yaml.MappingNode {
		return nil, nil, nil
	}
	if kind := mapValue(root, "kind"); kind == nil || kind.Value != "bundle" {
		return nil, nil, nil
	}
	if len(data) > maxBundleBytes {
		return nil, root, fmt.Errorf("bundle larger than %d KiB", maxBundleBytes>>10)
	}
	var docs []bundleDoc
	for _, section := range []struct{ key, kind string }{{"profiles", "profile"}, {"scenarios", "scenario"}} {
		node := mapValue(root, section.key)
		if node == nil {
			continue
		}
		if node.Kind != yaml.MappingNode {
			return nil, root, fmt.Errorf("bundle %s must be a mapping", section.key)
		}
		for i := 0; i+1 < len(node.Content); i += 2 {
			if node.Content[i+1].Kind != yaml.MappingNode {
				return nil, root, fmt.Errorf("bundle %s.%s must be a mapping", section.key, node.Content[i].Value)
			}
			docs = append(docs, bundleDoc{section.kind, node.Content[i].Value, node.Content[i+1]})
		}
	}
	if len(docs) == 0 {
		return nil, root, errors.New("bundle holds no profiles or scenarios")
	}
	return docs, root, nil
}

// Unpack splits a shared document into the profiles and scenarios it holds,
// named free of taken.
func Unpack(data []byte, taken []string) ([]BundleItem, error) {
	used := map[string]bool{}
	for _, name := range taken {
		used[name] = true
	}
	docs, _, err := readBundle(data)
	if err != nil {
		return nil, err
	}
	if docs == nil {
		kind := plainKind(data)
		title := ""
		if root, err := docRoot(data); err == nil {
			if node := mapValue(root, "title"); node != nil {
				title = node.Value
			}
		}
		return []BundleItem{{Kind: kind, Name: freeName(used, title, kind), Title: title, Text: string(data)}}, nil
	}
	renamed := map[string]string{}
	newNames := make([]string, len(docs))
	for i, d := range docs {
		newNames[i] = freeName(used, d.key, d.kind)
		used[newNames[i]] = true
		if d.kind == "profile" {
			renamed[d.key] = newNames[i]
		}
	}
	items := make([]BundleItem, 0, len(docs))
	for i, d := range docs {
		for _, ref := range profileRefs(d.node, d.kind == "scenario") {
			if old, ok := strings.CutPrefix(ref.Value, UserSource+"/"); ok && renamed[old] != "" {
				ref.Value = UserSource + "/" + renamed[old]
			}
		}
		text, err := nodeText(d.node)
		if err != nil {
			return nil, err
		}
		item := BundleItem{Kind: d.kind, Name: newNames[i], Text: text}
		if title := mapValue(d.node, "title"); title != nil {
			item.Title = title.Value
		}
		items = append(items, item)
	}
	return items, nil
}

// plainKind tells a scenario document from a profile: only a scenario names
// groups, routes or a tunnel mode at its top level.
func plainKind(data []byte) string {
	root, err := docRoot(data)
	if err != nil {
		return "profile"
	}
	for _, key := range []string{"groups", "mode", "routes"} {
		if mapValue(root, key) != nil {
			return "scenario"
		}
	}
	if _, err := ParseProfile(data); err != nil {
		if _, err := ParseScenario(data); err == nil {
			return "scenario"
		}
	}
	return "profile"
}

// lintBundle lints every document of a bundle text against the bundle's own
// profiles, as they will be once imported under the same names.
func (m *machine) lintBundle(text string, docs []bundleDoc) StudioResult {
	groups := make([]string, 0, len(m.topology.Groups))
	for _, g := range m.topology.Groups {
		groups = append(groups, g.Name)
	}
	return lintBundleIn(m.library, groups, text, docs)
}

// LintBundle lints an exported bundle on its own, for tools without a
// running engine; ok is false when text is not a bundle.
func LintBundle(text string) (result StudioResult, ok bool) {
	docs, _, _ := readBundle([]byte(text))
	if docs == nil {
		return StudioResult{}, false
	}
	return lintBundleIn(NewLibrary(SubscriptionLayer{}, UserLayer{}), nil, text, docs), true
}

func lintBundleIn(library *Library, groups []string, text string, docs []bundleDoc) StudioResult {
	draft := &Library{entries: maps.Clone(library.entries), scenarios: library.scenarios, trust: library.trust.clone()}
	texts := make([]string, len(docs))
	var out StudioResult
	for i, d := range docs {
		var err error
		if texts[i], err = nodeText(d.node); err != nil {
			out.Errors = append(out.Errors, Issue{Message: err.Error()})
		}
		if d.kind == "profile" {
			profile, err := ParseProfile([]byte(texts[i]))
			draft.add(UserSource+"/"+d.key, UserSource, []byte(texts[i]), profile, err)
		}
	}
	for i, d := range docs {
		var result StudioResult
		section := "profiles"
		if d.kind == "scenario" {
			section = "scenarios"
			result = lintScenarioIn(draft, UserSource+"/"+d.key, texts[i], groups)
		} else {
			result, _ = lintIn(draft, UserSource+"/"+d.key, texts[i], Binding{})
		}
		prefix := section + "." + d.key
		place := func(issues []Issue) []Issue {
			for j := range issues {
				path := prefix
				if issues[j].Path != "" {
					path += "." + issues[j].Path
				}
				parts := []any{section, d.key}
				for _, part := range strings.Split(issues[j].Path, ".") {
					if part == "" {
						continue
					}
					if n, err := strconv.Atoi(part); err == nil {
						parts = append(parts, n)
					} else {
						parts = append(parts, part)
					}
				}
				issues[j].Path, issues[j].Line = path, locate(text, parts)
			}
			return issues
		}
		out.Errors = append(out.Errors, place(result.Errors)...)
		out.Warnings = append(out.Warnings, place(result.Warnings)...)
		out.Endpoints = append(out.Endpoints, result.Endpoints...)
	}
	return out
}
