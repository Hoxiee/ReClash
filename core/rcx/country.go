package rcx

import (
	"cmp"
	"maps"
	"slices"
	"strings"
	"time"
	"unicode"
	"unicode/utf8"
)

const (
	regionalA = 0x1F1E6
	regionalZ = 0x1F1FF
)

type countryName struct {
	name string
	code string
}

// spelledCountries is every English name, longest first, so "Papua New
// Guinea" wins over "Guinea".
var spelledCountries = func() []countryName {
	var out []countryName
	for code, name := range countryNames {
		out = append(out, countryName{strings.ToLower(name), code})
	}
	for name, code := range nameAliases {
		if len(name) > 2 {
			out = append(out, countryName{strings.ToLower(name), code})
		}
	}
	slices.SortFunc(out, func(a, b countryName) int {
		return cmp.Or(cmp.Compare(len(b.name), len(a.name)), strings.Compare(a.name, b.name))
	})
	return out
}()

// CountryOfName reads the country a server name declares: a flag emoji
// first, then an upper-case ISO 3166-1 alpha-2 token standing as a word,
// then an English country name. Empty when the name says none.
func CountryOfName(name string) string {
	if code := flagCountry(name); code != "" {
		return code
	}
	for _, token := range letterRuns(name) {
		if len(token) != 2 || strings.ToUpper(token) != token {
			continue
		}
		if code := nameAliases[token]; code != "" {
			return code
		}
		if _, ok := countryNames[token]; ok {
			return token
		}
	}
	lower := strings.ToLower(name)
	for _, entry := range spelledCountries {
		if containsWord(lower, entry.name) {
			return entry.code
		}
	}
	return ""
}

func flagCountry(name string) string {
	var prev rune
	for _, r := range name {
		if r >= regionalA && r <= regionalZ {
			if prev != 0 {
				code := string([]rune{'A' + prev - regionalA, 'A' + r - regionalA})
				if _, ok := countryNames[code]; ok {
					return code
				}
				prev = 0
				continue
			}
			prev = r
			continue
		}
		prev = 0
	}
	return ""
}

// letterRuns splits a name into runs of letters: digits, separators and
// emoji all end a word, so "US01" and "HK|SG" read as codes.
func letterRuns(name string) []string {
	return strings.FieldsFunc(name, func(r rune) bool { return !unicode.IsLetter(r) })
}

func containsWord(text, word string) bool {
	for start := 0; ; {
		i := strings.Index(text[start:], word)
		if i < 0 {
			return false
		}
		i += start
		before, _ := utf8.DecodeLastRuneInString(text[:i])
		after, _ := utf8.DecodeRuneInString(text[i+len(word):])
		if !unicode.IsLetter(before) && !unicode.IsLetter(after) {
			return true
		}
		start = i + 1
	}
}

func (m *machine) countryOf(name string) string {
	if code, ok := m.nameCountries[name]; ok {
		return code
	}
	if m.nameCountries == nil || len(m.nameCountries) > 8192 {
		m.nameCountries = map[string]string{}
	}
	code := CountryOfName(name)
	m.nameCountries[name] = code
	return code
}

// CountryCount is one country of the country picker: how many servers have
// it, and whether an exit check confirmed it for at least one.
type CountryCount struct {
	Code     string `json:"code"`
	Count    int    `json:"count"`
	Verified bool   `json:"verified,omitempty"`
}

// countries counts the group's members by country, or every server of the
// running config when the group is not a smart one; most servers first.
func (m *machine) countries(group string, now time.Time) []CountryCount {
	counts := map[string]*CountryCount{}
	note := func(code string, verified bool) {
		if code == "" {
			return
		}
		c := counts[code]
		if c == nil {
			c = &CountryCount{Code: code}
			counts[code] = c
		}
		c.Count++
		c.Verified = c.Verified || verified
	}
	exitOf := func(member Member) string { return m.evidence.Exits[member.Key].country(now) }
	if g := m.groups[group]; g != nil && group != "" {
		for _, member := range g.members {
			exit := exitOf(member)
			note(cmp.Or(exit, member.NameCountry), exit != "")
		}
	} else {
		known := map[string]Member{}
		for _, g := range m.groups {
			for _, member := range g.members {
				known[member.Name] = member
			}
		}
		for _, name := range m.topology.Leaves {
			member, ok := known[name]
			if !ok {
				note(CountryOfName(name), false)
				continue
			}
			exit := exitOf(member)
			note(cmp.Or(exit, member.NameCountry), exit != "")
		}
	}
	out := make([]CountryCount, 0, len(counts))
	for _, code := range slices.Sorted(maps.Keys(counts)) {
		out = append(out, *counts[code])
	}
	slices.SortStableFunc(out, func(a, b CountryCount) int { return cmp.Compare(b.Count, a.Count) })
	return out
}
