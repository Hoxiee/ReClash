package rcx

import (
	"crypto/hmac"
	"crypto/sha256"
	"encoding/base64"
	"slices"
	"time"
)

const maxIdentities = 4096

// Identity remembers how a node was recognised, so a subscription refresh that
// rotates credentials or renames keeps the node's history. Fingerprints are
// stored only as salted HMACs.
type Identity struct {
	Key      string    `json:"key"`
	Strong   string    `json:"strong,omitempty"`
	Endpoint string    `json:"endpoint,omitempty"`
	Name     string    `json:"name"`
	Provider string    `json:"provider,omitempty"`
	Server   string    `json:"server,omitempty"`
	SeenAt   time.Time `json:"seenAt"`
}

type IdentityIndex struct {
	Entries []*Identity `json:"entries"`
}

type IdentityMatch string

const (
	MatchedStrong   IdentityMatch = "strong"
	MatchedEndpoint IdentityMatch = "endpoint"
	MatchedName     IdentityMatch = "name"
	MatchedNew      IdentityMatch = "new"
)

func digest(salt []byte, parts ...string) string {
	mac := hmac.New(sha256.New, salt)
	for _, part := range parts {
		mac.Write([]byte(part))
		mac.Write([]byte{0})
	}
	return base64.RawURLEncoding.EncodeToString(mac.Sum(nil)[:12])
}

// Resolve assigns every node a stable key: by its full configuration, else by
// a unique endpoint, else by a unique provider and name on the same server.
// A key is never handed to two nodes of one refresh.
func (ix *IdentityIndex) Resolve(salt []byte, nodes []Node, now time.Time) ([]string, []IdentityMatch) {
	byStrong := map[string]*Identity{}
	byEndpoint := map[string][]*Identity{}
	byName := map[string][]*Identity{}
	for _, entry := range ix.Entries {
		if entry.Strong != "" {
			byStrong[entry.Strong] = entry
		}
		if entry.Endpoint != "" {
			byEndpoint[entry.Endpoint] = append(byEndpoint[entry.Endpoint], entry)
		}
		byName[entry.Provider+"\x00"+entry.Name] = append(byName[entry.Provider+"\x00"+entry.Name], entry)
	}
	claimed := map[string]bool{}
	unique := func(candidates []*Identity, server string) *Identity {
		var found *Identity
		for _, c := range candidates {
			if claimed[c.Key] || (server != "" && c.Server != server) {
				continue
			}
			if found != nil {
				return nil
			}
			found = c
		}
		return found
	}
	keys := make([]string, len(nodes))
	matches := make([]IdentityMatch, len(nodes))
	for i, node := range nodes {
		strong := digestOrEmpty(salt, node.Strong)
		endpoint := digestOrEmpty(salt, node.Endpoint)
		server := digestOrEmpty(salt, node.Server)
		var entry *Identity
		match := MatchedNew
		if e := byStrong[strong]; strong != "" && e != nil && !claimed[e.Key] {
			entry, match = e, MatchedStrong
		} else if e := unique(byEndpoint[endpoint], ""); endpoint != "" && e != nil {
			entry, match = e, MatchedEndpoint
		} else if e := unique(byName[node.Provider+"\x00"+node.Name], server); e != nil {
			entry, match = e, MatchedName
		}
		if entry == nil {
			key := digest(salt, "key", node.Strong, node.Provider, node.Name, node.Server)
			for claimed[key] {
				key = digest(salt, "key", key)
			}
			entry = &Identity{Key: key}
			ix.Entries = append(ix.Entries, entry)
		}
		claimed[entry.Key] = true
		entry.Strong, entry.Endpoint, entry.Server = strong, endpoint, server
		entry.Name, entry.Provider, entry.SeenAt = node.Name, node.Provider, now
		keys[i], matches[i] = entry.Key, match
	}
	ix.trim()
	return keys, matches
}

func digestOrEmpty(salt []byte, value string) string {
	if value == "" {
		return ""
	}
	return digest(salt, value)
}

func (ix *IdentityIndex) trim() {
	if len(ix.Entries) <= maxIdentities {
		return
	}
	slices.SortStableFunc(ix.Entries, func(a, b *Identity) int { return b.SeenAt.Compare(a.SeenAt) })
	ix.Entries = ix.Entries[:maxIdentities]
}

func (ix *IdentityIndex) Known() map[string]bool {
	known := make(map[string]bool, len(ix.Entries))
	for _, e := range ix.Entries {
		known[e.Key] = true
	}
	return known
}
