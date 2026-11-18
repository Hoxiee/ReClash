package sitelock

import (
	"errors"
	"reflect"
	"testing"

	"github.com/metacubex/mihomo/component/geodata/router"
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
	return set.Names(geoSites)
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
	names, partial := set.Names(geoSites)
	if !names.Empty() || len(partial) != 0 || names.Full == nil {
		t.Errorf("names %+v partial %v, want empty lists and nothing partial", names, partial)
	}
}
