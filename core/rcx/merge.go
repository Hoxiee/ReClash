package rcx

import (
	"bytes"
	"errors"
	"fmt"

	"go.yaml.in/yaml/v3"
)

// MergeProfiles brings the source's changes from base to theirs into the
// user's fork, key by key: a key the user never touched follows the source,
// a key only the user changed stays, and a key both changed differently is a
// conflict that keeps the user's value. Nested maps merge the same way, so
// two edits of different checks do not collide. The user's comments survive.
func MergeProfiles(base, theirs, mine []byte) (string, []string, error) {
	b, err := mergeRoot(base)
	if err != nil {
		return "", nil, fmt.Errorf("base: %w", err)
	}
	t, err := mergeRoot(theirs)
	if err != nil {
		return "", nil, fmt.Errorf("source: %w", err)
	}
	var doc yaml.Node
	if err := yaml.Unmarshal(mine, &doc); err != nil {
		return "", nil, fmt.Errorf("your profile: %w", err)
	}
	if len(doc.Content) == 0 || doc.Content[0].Kind != yaml.MappingNode {
		return "", nil, errors.New("your profile is not a mapping")
	}
	conflicts := mergeMapping(b, t, doc.Content[0], "")
	var buf bytes.Buffer
	encoder := yaml.NewEncoder(&buf)
	encoder.SetIndent(2)
	if err := encoder.Encode(&doc); err != nil {
		return "", nil, err
	}
	_ = encoder.Close()
	if _, err := ParseProfile(buf.Bytes()); err != nil {
		return "", conflicts, fmt.Errorf("the merged profile does not parse: %w", err)
	}
	return buf.String(), conflicts, nil
}

func mergeRoot(data []byte) (*yaml.Node, error) {
	var doc yaml.Node
	if err := yaml.Unmarshal(data, &doc); err != nil {
		return nil, err
	}
	if len(doc.Content) == 0 {
		return &yaml.Node{Kind: yaml.MappingNode}, nil
	}
	if doc.Content[0].Kind != yaml.MappingNode {
		return nil, errors.New("not a mapping")
	}
	return doc.Content[0], nil
}

func mergeMapping(base, theirs, mine *yaml.Node, prefix string) []string {
	var conflicts []string
	keys := mappingKeys(mine)
	for _, key := range mappingKeys(theirs) {
		if mappingValue(mine, key) == nil {
			keys = append(keys, key)
		}
	}
	for _, key := range keys {
		b, t, m := mappingValue(base, key), mappingValue(theirs, key), mappingValue(mine, key)
		switch {
		case sameNode(t, b), sameNode(m, t):
		case sameNode(m, b):
			setMappingValue(mine, key, t, theirs)
		case m != nil && t != nil && m.Kind == yaml.MappingNode && t.Kind == yaml.MappingNode && (b == nil || b.Kind == yaml.MappingNode):
			if b == nil {
				b = &yaml.Node{Kind: yaml.MappingNode}
			}
			conflicts = append(conflicts, mergeMapping(b, t, m, prefix+key+".")...)
		default:
			conflicts = append(conflicts, prefix+key)
		}
	}
	return conflicts
}

func mappingKeys(node *yaml.Node) []string {
	var keys []string
	for i := 0; node != nil && i+1 < len(node.Content); i += 2 {
		keys = append(keys, node.Content[i].Value)
	}
	return keys
}

func mappingValue(node *yaml.Node, key string) *yaml.Node {
	for i := 0; node != nil && i+1 < len(node.Content); i += 2 {
		if node.Content[i].Value == key {
			return node.Content[i+1]
		}
	}
	return nil
}

// setMappingValue replaces, removes (value nil) or adds the key; an added key
// takes the source's key node, comments included.
func setMappingValue(node *yaml.Node, key string, value, from *yaml.Node) {
	for i := 0; i+1 < len(node.Content); i += 2 {
		if node.Content[i].Value != key {
			continue
		}
		if value == nil {
			node.Content = append(node.Content[:i], node.Content[i+2:]...)
		} else {
			node.Content[i+1] = value
		}
		return
	}
	if value == nil {
		return
	}
	keyNode := &yaml.Node{Kind: yaml.ScalarNode, Tag: "!!str", Value: key}
	for i := 0; from != nil && i+1 < len(from.Content); i += 2 {
		if from.Content[i].Value == key {
			keyNode = from.Content[i]
		}
	}
	node.Content = append(node.Content, keyNode, value)
}

// sameNode compares meaning, not layout: flow and block styles, quoting and
// comments do not make two values differ.
func sameNode(a, b *yaml.Node) bool {
	if a == nil || b == nil {
		return a == b
	}
	var av, bv any
	if a.Decode(&av) != nil || b.Decode(&bv) != nil {
		return false
	}
	ab, _ := yaml.Marshal(av)
	bb, _ := yaml.Marshal(bv)
	return bytes.Equal(ab, bb)
}
