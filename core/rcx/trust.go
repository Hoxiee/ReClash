package rcx

import (
	"fmt"
	"maps"
	"net"
	"net/url"
	"slices"
	"strings"
	"sync"

	"golang.org/x/net/publicsuffix"
)

// Endpoint is one host a profile makes the app contact.
type Endpoint struct {
	Host string `json:"host"`
	// Use is check:<id>, diagnostic:<name> or echo.
	Use        string `json:"use"`
	Target     string `json:"target"`
	ThirdParty bool   `json:"thirdParty,omitempty"`
}

func (p *Profile) endpoints() []Endpoint {
	var out []Endpoint
	add := func(use, target string) {
		out = append(out, Endpoint{Host: endpointHost(target), Use: use, Target: target})
	}
	for _, id := range slices.Sorted(maps.Keys(p.Checks)) {
		check := p.Checks[id]
		for _, target := range []string{check.HTTP, check.TCP, check.TLS} {
			if target != "" {
				add("check:"+id, target)
			}
		}
	}
	for _, name := range slices.Sorted(maps.Keys(p.Network.Diagnose)) {
		for _, target := range p.Network.Diagnose[name].targets() {
			add("diagnostic:"+name, target.Addr)
		}
	}
	for _, echo := range p.Egress.Echo {
		add("echo", echo)
	}
	return out
}

func endpointHost(target string) string {
	if u, err := url.Parse(target); err == nil && u.Scheme != "" && u.Host != "" {
		return strings.ToLower(u.Hostname())
	}
	host, _, err := net.SplitHostPort(target)
	if err != nil {
		return strings.ToLower(target)
	}
	return strings.ToLower(host)
}

// neutralHosts are the endpoints the built-in profiles use: shipped with the
// app, they need nobody's consent.
var neutralHosts = sync.OnceValue(func() map[string]bool {
	hosts := map[string]bool{}
	for _, echo := range defaultEcho {
		hosts[endpointHost(echo)] = true
	}
	files, _ := builtinFiles.ReadDir("builtin")
	for _, file := range files {
		data, _ := builtinFiles.ReadFile("builtin/" + file.Name())
		if profile, err := ParseProfile(data); err == nil {
			for _, endpoint := range profile.endpoints() {
				hosts[endpoint.Host] = true
			}
		}
	}
	return hosts
})

// trust decides which hosts a provider profile may contact without asking:
// the neutral built-in endpoints, the provider's own site, and hosts the user
// allowed.
type trust struct {
	sites   map[string]bool
	allowed map[string]bool
}

func newTrust(user UserLayer) trust {
	t := trust{sites: map[string]bool{}, allowed: map[string]bool{}}
	for _, host := range user.ProviderHosts {
		if site := siteOf(host); site != "" {
			t.sites[site] = true
		}
	}
	for _, host := range user.Trusted {
		t.allowed[strings.ToLower(strings.TrimSpace(host))] = true
	}
	return t
}

func (t trust) clone() trust {
	return trust{sites: maps.Clone(t.sites), allowed: maps.Clone(t.allowed)}
}

func (t trust) allowAll(hosts []string) {
	for _, host := range hosts {
		t.allowed[host] = true
	}
}

func (t trust) allows(host string) bool {
	return neutralHosts()[host] || t.allowed[host] || t.sites[siteOf(host)]
}

// siteOf is the registrable domain, so api.example.com and sub.example.com
// count as one provider; an address is its own site.
func siteOf(host string) string {
	host = strings.TrimSuffix(strings.ToLower(strings.TrimSpace(host)), ".")
	if host == "" || net.ParseIP(host) != nil {
		return host
	}
	if site, err := publicsuffix.EffectiveTLDPlusOne(host); err == nil {
		return site
	}
	return host
}

// ConsentError holds a provider profile back until the user allows the
// third-party hosts it would contact.
type ConsentError struct {
	Profile string
	Hosts   []string
}

func (e *ConsentError) Error() string {
	return fmt.Sprintf("profile %s contacts %s; allow them first", e.Profile, strings.Join(e.Hosts, ", "))
}

// consent checks the endpoints each provider profile in the chain declares
// itself; what a built-in base declares is neutral, and the user's own
// profiles are the user's choice.
func (lib *Library) consent(id string) error {
	chain, err := lib.chain(id)
	if err != nil {
		return err
	}
	hosts := map[string]bool{}
	for _, entry := range chain {
		if entry.info.Source != SubscriptionSource {
			continue
		}
		for _, endpoint := range entry.profile.endpoints() {
			if !lib.trust.allows(endpoint.Host) {
				hosts[endpoint.Host] = true
			}
		}
	}
	if len(hosts) == 0 {
		return nil
	}
	return &ConsentError{Profile: CanonicalID(id), Hosts: slices.Sorted(maps.Keys(hosts))}
}
