// Command rcxlint checks routing profiles and routing bundles the way the app
// does when it imports them.
package main

import (
	"fmt"
	"maps"
	"os"
	"path/filepath"
	"slices"
	"strconv"
	"strings"

	"core/rcx"

	"go.yaml.in/yaml/v3"
)

func main() {
	if len(os.Args) < 2 {
		fmt.Fprintln(os.Stderr, "usage: rcxlint <profile.yaml | bundle.yaml>...")
		os.Exit(2)
	}
	failed := false
	for _, file := range os.Args[1:] {
		if !lintFile(file) {
			failed = true
		}
	}
	if failed {
		os.Exit(1)
	}
}

func lintFile(file string) bool {
	data, err := os.ReadFile(file)
	if err != nil {
		fmt.Printf("%s: error: %v\n", file, err)
		return false
	}
	var doc yaml.Node
	if err := yaml.Unmarshal(data, &doc); err != nil {
		fmt.Printf("%s: error: %v\n", file, err)
		return false
	}
	root := (*yaml.Node)(nil)
	if len(doc.Content) > 0 {
		root = doc.Content[0]
	}
	if child(root, "profiles") != nil || child(root, "scenarios") != nil {
		return lintBundle(file, data, root)
	}
	name := strings.TrimSuffix(strings.TrimSuffix(filepath.Base(file), ".yaml"), ".rcx")
	// Only a scenario names groups or a tunnel mode.
	if child(root, "groups") != nil || child(root, "mode") != nil {
		result := rcx.LintScenario(rcx.SubscriptionLayer{}, "provider/"+name, string(data))
		return report(file, "", result, func(issue rcx.Issue) int { return issue.Line })
	}
	result := rcx.LintProfile(rcx.SubscriptionLayer{}, "provider/"+name, string(data))
	return report(file, "", result, func(issue rcx.Issue) int { return issue.Line })
}

func lintBundle(file string, data []byte, root *yaml.Node) bool {
	var bundle struct {
		Profiles  map[string]any         `yaml:"profiles"`
		Groups    map[string]rcx.Binding `yaml:"groups"`
		Scenarios map[string]any         `yaml:"scenarios"`
		Scenario  string                 `yaml:"scenario"`
	}
	if err := yaml.Unmarshal(data, &bundle); err != nil {
		fmt.Printf("%s: error: %v\n", file, err)
		return false
	}
	if len(data) > 256<<10 {
		fmt.Printf("%s: error: bundle larger than 256 KiB\n", file)
		return false
	}
	layer := rcx.SubscriptionLayer{Groups: bundle.Groups, Profiles: bundle.Profiles, Scenarios: bundle.Scenarios}
	ok := true
	for _, name := range slices.Sorted(maps.Keys(bundle.Profiles)) {
		text, err := yaml.Marshal(bundle.Profiles[name])
		if err != nil {
			fmt.Printf("%s: error: profile %s: %v\n", file, name, err)
			ok = false
			continue
		}
		result := rcx.LintProfile(layer, "provider/"+name, string(text))
		base := child(child(root, "profiles"), name)
		if !report(file, name, result, func(issue rcx.Issue) int { return locate(base, issue.Path) }) {
			ok = false
		}
	}
	for _, name := range slices.Sorted(maps.Keys(bundle.Scenarios)) {
		text, err := yaml.Marshal(bundle.Scenarios[name])
		if err != nil {
			fmt.Printf("%s: error: scenario %s: %v\n", file, name, err)
			ok = false
			continue
		}
		result := rcx.LintScenario(layer, "provider/"+name, string(text))
		base := child(child(root, "scenarios"), name)
		if !report(file, "scenario "+name, result, func(issue rcx.Issue) int { return locate(base, issue.Path) }) {
			ok = false
		}
	}
	if ref := bundle.Scenario; ref != "" && !strings.HasPrefix(ref, "builtin/") && bundle.Scenarios[strings.TrimPrefix(ref, "provider/")] == nil {
		fmt.Printf("%s: error: scenario %q is not defined in the bundle\n", file, ref)
		ok = false
	}
	for _, group := range slices.Sorted(maps.Keys(bundle.Groups)) {
		binding := bundle.Groups[group]
		refs := append([]string{binding.Default}, binding.Profiles...)
		for _, ref := range refs {
			if ref == "" || strings.HasPrefix(ref, "builtin/") || bundle.Profiles[strings.TrimPrefix(ref, "provider/")] != nil {
				continue
			}
			fmt.Printf("%s: error: group %q names profile %q, which the bundle does not define\n", file, group, ref)
			ok = false
		}
	}
	return ok
}

func report(file, profile string, result rcx.StudioResult, line func(rcx.Issue) int) bool {
	prefix := file
	label := ""
	if strings.HasPrefix(profile, "scenario ") {
		label = profile + ": "
	} else if profile != "" {
		label = "profile " + profile + ": "
	}
	print := func(severity string, issues []rcx.Issue) {
		for _, issue := range issues {
			where := prefix
			if n := line(issue); n > 0 {
				where += ":" + strconv.Itoa(n)
			}
			fmt.Printf("%s: %s: %s%s\n", where, severity, label, issue.Message)
		}
	}
	print("error", result.Errors)
	print("warning", result.Warnings)
	for _, endpoint := range result.Endpoints {
		if endpoint.ThirdParty {
			fmt.Printf("%s: note: %scontacts third-party host %s (%s); the user must allow it\n", prefix, label, endpoint.Host, endpoint.Use)
		}
	}
	return len(result.Errors) == 0
}

func child(node *yaml.Node, key string) *yaml.Node {
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

// locate returns the line of the deepest part of a dotted issue path that the
// node has, so a bundle error points into the bundle file.
func locate(node *yaml.Node, path string) int {
	if node == nil {
		return 0
	}
	line := node.Line
	if path == "" {
		return line
	}
	for _, part := range strings.Split(path, ".") {
		var next *yaml.Node
		if index, err := strconv.Atoi(part); err == nil && node.Kind == yaml.SequenceNode && index < len(node.Content) {
			next = node.Content[index]
		} else if next = child(node, part); next != nil {
			for i := 0; i+1 < len(node.Content); i += 2 {
				if node.Content[i+1] == next {
					line = node.Content[i].Line
				}
			}
			node = next
			continue
		}
		if next == nil {
			return line
		}
		line, node = next.Line, next
	}
	return line
}
