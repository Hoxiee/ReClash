package rcx

import (
	"slices"
	"testing"
)

func TestCountryOfName(t *testing.T) {
	for name, want := range map[string]string{
		"🇩🇪 Frankfurt 01":        "DE",
		"🇺🇸US | 🇯🇵":              "US",
		"US-01":                  "US",
		"HK|SG premium":          "HK",
		"UK London":              "GB",
		"RU LTE 4":               "RU",
		"United Kingdom 3":       "GB",
		"Papua New Guinea":       "PG",
		"Guinea fast":            "GN",
		"hong kong 02":           "HK",
		"Netherlands-Amsterdam":  "NL",
		"Turkiye":                "TR",
		"plain server":           "",
		"Germanyish":             "",
		"de lowercase is a word": "",
	} {
		if got := CountryOfName(name); got != want {
			t.Errorf("CountryOfName(%q) = %q, want %q", name, got, want)
		}
	}
}

func TestCountriesCountServersByCountry(t *testing.T) {
	s := newScenarioSim(t, UserLayer{Groups: map[string]Binding{"Proxy": {}}})
	s.m.topology.Leaves = []string{"🇩🇪 a", "🇩🇪 b", "US c", "x"}
	s.m.rebuild(s.now)
	if got := s.m.countries("", s.now); !slices.Equal(got, []CountryCount{{Code: "DE", Count: 2}, {Code: "US", Count: 1}}) {
		t.Errorf("all servers = %+v", got)
	}
	result, err := s.m.studio(StudioRequest{Op: "countries", Group: "Proxy"}, s.now)
	if err != nil {
		t.Fatal(err)
	}
	if !slices.Equal(result.Countries, []CountryCount{{Code: "RU", Count: 1}}) {
		t.Errorf("group Proxy = %+v", result.Countries)
	}
	g := s.m.groups["Proxy"]
	key := g.members[g.byName["n1"]].Key
	s.m.evidence.Exits = map[string]*ExitFact{key: {Country: "FI", At: s.now}}
	if got := s.m.countries("Proxy", s.now); !slices.Equal(got, []CountryCount{{Code: "FI", Count: 1, Verified: true}, {Code: "RU", Count: 1}}) {
		t.Errorf("with a verified exit = %+v", got)
	}
}
