package sitelock

import (
	"errors"
	"reflect"
	"testing"

	"github.com/metacubex/mihomo/component/geodata/router"
	C "github.com/metacubex/mihomo/constant"
)

func geoSites(code string) ([]*router.Domain, error) {
	switch code {
	case "openai":
		return []*router.Domain{
			{Type: router.Domain_Domain, Value: "OpenAI.com"},
			{Type: router.Domain_Full, Value: "cdn.oaistatic.com", Attribute: []*router.Domain_Attribute{{Key: "cdn"}}},
			{Type: router.Domain_Plain, Value: "chatgpt"},
			{Type: router.Domain_Regex, Value: `^sora\.`},
		}, nil
	case "lookahead":
		return []*router.Domain{{Type: router.Domain_Regex, Value: `^(?!www)\w+\.example$`}}, nil
	}
	return nil, errors.New("no such list")
}

func namesOf(t *testing.T, match ...string) (Names, []string) {
	t.Helper()
	// Built by hand: compiling a GEOSITE entry would load the real database.
	set := &Set{enabled: []*compiled{{lock: Lock{ID: "lock", Enabled: true, Match: match}}}}
	names, _, partial := set.Names(geoSites, true)
	return names, partial
}

func TestNamesMirrorTheCoreMatchers(t *testing.T) {
	names, partial := namesOf(t,
		"DOMAIN,Api.Example.com", "DOMAIN-SUFFIX,.example.org", "DOMAIN-KEYWORD,Claude",
		"DOMAIN-REGEX,^x\\d+\\.test$", "DOMAIN-WILDCARD,*.a?.net", "GEOSITE,openai", "IP-CIDR,10.1.0.0/16",
	)
	want := Names{
		Full:    []string{"api.example.com", "cdn.oaistatic.com"},
		Suffix:  []string{"example.org", "openai.com"},
		Keyword: []string{"chatgpt", "claude"},
		Regex:   []string{`(?i)^sora\.`, `(?i)^x\d+\.test$`, `^.*\.a.\.net$`},
	}
	if !reflect.DeepEqual(names, want) || len(partial) != 0 {
		t.Errorf("names %+v partial %v, want %+v and none", names, partial, want)
	}
}

func TestNamesFilterGeoSiteByAttribute(t *testing.T) {
	names, _ := namesOf(t, "GEOSITE,openai@cdn")
	if want := []string{"cdn.oaistatic.com"}; !reflect.DeepEqual(names.Full, want) || len(names.Suffix) != 0 {
		t.Errorf("names %+v, want only %v", names, want)
	}
}

func TestNamesLeaveWhatTheFilterCannotMirrorToTheCore(t *testing.T) {
	for _, entry := range []string{
		"GEOSITE,!openai", "GEOSITE,missing", "GEOSITE,lookahead", "DOMAIN-REGEX,^(?!www)",
		"AND,((DOMAIN,a.com),(NETWORK,TCP))", "DST-PORT,443",
	} {
		if _, partial := namesOf(t, entry); !reflect.DeepEqual(partial, []string{"lock"}) {
			t.Errorf("%s: partial %v, want the lock", entry, partial)
		}
	}
}

func TestNamesSkipDisabledLocks(t *testing.T) {
	set, _ := Compile([]Lock{{ID: "off", Match: []string{"DST-PORT,443"}}})
	names, guarded, partial := set.Names(geoSites, true)
	if !names.Empty() || len(guarded) != 0 || len(partial) != 0 || names.Full == nil {
		t.Errorf("names %+v partial %v, want empty lists and nothing partial", names, partial)
	}
}

func TestNamesKeepExceptionsWithTheirOwnLock(t *testing.T) {
	set := &Set{enabled: []*compiled{
		{lock: Lock{ID: "plain", Enabled: true, Match: []string{"DOMAIN-SUFFIX,example.org"}}},
		{lock: Lock{ID: "guarded", Enabled: true, Match: []string{"DOMAIN-SUFFIX,example.com"}, Except: []string{"DOMAIN,free.example.com"}}},
		{lock: Lock{ID: "addresses", Enabled: true, Match: []string{"DOMAIN,a.test"}, Except: []string{"IP-CIDR,10.0.0.0/8"}}},
	}}
	names, guarded, _ := set.Names(geoSites, true)
	if want := []string{"example.org"}; !reflect.DeepEqual(names.Suffix, want) || !reflect.DeepEqual(names.Full, []string{"a.test"}) {
		t.Errorf("names %+v, want example.org and a.test merged", names)
	}
	if len(guarded) != 1 || !reflect.DeepEqual(guarded[0].Names.Suffix, []string{"example.com"}) ||
		!reflect.DeepEqual(guarded[0].Except.Full, []string{"free.example.com"}) {
		t.Errorf("guarded %+v, want example.com except free.example.com", guarded)
	}
}

func TestNamesWithoutPatternsLeaveKeywordsAndRegexesToTheCore(t *testing.T) {
	set := &Set{enabled: []*compiled{
		{lock: Lock{ID: "names", Enabled: true, Match: []string{"DOMAIN-SUFFIX,example.org"}}},
		{lock: Lock{ID: "keyword", Enabled: true, Match: []string{"DOMAIN,a.test", "DOMAIN-KEYWORD,claude"}}},
		{lock: Lock{ID: "geosite", Enabled: true, Match: []string{"GEOSITE,openai"}}},
	}}
	names, _, partial := set.Names(geoSites, false)
	want := Names{
		Full:    []string{"a.test", "cdn.oaistatic.com"},
		Suffix:  []string{"example.org", "openai.com"},
		Keyword: []string{},
		Regex:   []string{},
	}
	if !reflect.DeepEqual(names, want) || !reflect.DeepEqual(partial, []string{"keyword", "geosite"}) {
		t.Errorf("names %+v partial %v, want %+v and the keyword and geosite locks", names, partial, want)
	}
}

func TestUnicodeNamesMatchTheirPunycodeForm(t *testing.T) {
	names, _ := namesOf(t, "DOMAIN-SUFFIX,Пример.рф", "DOMAIN-WILDCARD,*.пример.рф")
	if want := []string{"xn--e1afmkfd.xn--p1ai"}; !reflect.DeepEqual(names.Suffix, want) {
		t.Errorf("suffix %v, want %v", names.Suffix, want)
	}
	if want := []string{`^.*\.xn--e1afmkfd\.xn--p1ai$`}; !reflect.DeepEqual(names.Regex, want) {
		t.Errorf("regex %v, want %v", names.Regex, want)
	}
	rule, err := parseEntry("DOMAIN,пример.рф", "")
	if err != nil {
		t.Fatal(err)
	}
	if matched, _ := rule.Match(&C.Metadata{Host: "xn--e1afmkfd.xn--p1ai"}, C.RuleMatchHelper{}); !matched {
		t.Error("DOMAIN,пример.рф does not match its punycode host")
	}
}
