package telegram

import (
	"context"
	"errors"
	"fmt"
	"io"
	"net/http"
	"slices"
	"strings"
	"sync"
	"time"
)

const (
	// CFDomainsURL hosts the community list of Cloudflare-proxied base domains.
	CFDomainsURL = "https://raw.githubusercontent.com/Flowseal/tg-ws-proxy/main/.github/cfproxy-domains.txt"

	cfRefreshFirst    = 5 * time.Second
	cfRefreshInterval = time.Hour
	cfFetchTimeout    = 15 * time.Second
	cfMinRefreshed    = 3
	cfMaxListBytes    = 64 << 10
)

var builtinCFDomains = []string{
	"pclead.co.uk",
	"offshor.co.uk",
	"cakeisalie.co.uk",
	"noskomnadzor.co.uk",
	"lovetrue.co.uk",
	"sorokdva.co.uk",
	"pyatdesyatdva.co.uk",
	"kartoshka.co.uk",
	"sorokodin.co.uk",
	"pyatdesyatodin.co.uk",
	"notelega.co.uk",
	"ebally.co.uk",
	"nebally.co.uk",
	"havegreatday.co.uk",
	"pomogite.co.uk",
	"fixtelega.co.uk",
	"sadnews.co.uk",
	"onedaychamp.co.uk",
	"stopblocking.co.uk",
	"nothingthere.co.uk",
}

type CFFetchFunc func(ctx context.Context) (string, error)

func fetchCFDomains(ctx context.Context) (string, error) {
	ctx, cancel := context.WithTimeout(ctx, cfFetchTimeout)
	defer cancel()
	request, err := http.NewRequestWithContext(ctx, http.MethodGet, CFDomainsURL, nil)
	if err != nil {
		return "", err
	}
	response, err := http.DefaultClient.Do(request)
	if err != nil {
		return "", err
	}
	defer response.Body.Close()
	if response.StatusCode != http.StatusOK {
		return "", fmt.Errorf("status %d", response.StatusCode)
	}
	body, err := io.ReadAll(io.LimitReader(response.Body, cfMaxListBytes))
	return string(body), err
}

// decodeCFDomain undoes the letter shift the hosted list applies to ".com" entries, so the
// published file does not name the domains in plain text.
func decodeCFDomain(s string) string {
	body, ok := strings.CutSuffix(s, ".com")
	if !ok {
		return s
	}
	letters := 0
	for _, c := range body {
		if c >= 'a' && c <= 'z' || c >= 'A' && c <= 'Z' {
			letters++
		}
	}
	shift := letters % 26
	out := []byte(body)
	for i, c := range out {
		switch {
		case c >= 'a' && c <= 'z':
			out[i] = byte((int(c-'a')-shift+26)%26) + 'a'
		case c >= 'A' && c <= 'Z':
			out[i] = byte((int(c-'A')-shift+26)%26) + 'A'
		}
	}
	return string(out) + ".co.uk"
}

func validHostname(name string) bool {
	if name == "" || len(name) > 253 {
		return false
	}
	labels := strings.Split(name, ".")
	if len(labels) < 2 {
		return false
	}
	for _, label := range labels {
		if label == "" || len(label) > 63 || label[0] == '-' || label[len(label)-1] == '-' {
			return false
		}
		for _, c := range label {
			if !(c >= 'a' && c <= 'z' || c >= '0' && c <= '9' || c == '-') {
				return false
			}
		}
	}
	tld := labels[len(labels)-1]
	return len(tld) >= 2 && strings.ContainsFunc(tld, func(c rune) bool { return c >= 'a' && c <= 'z' })
}

// parseCFDomains reads the hosted list: one domain a line, '#' and '//' start comments. Only
// ".co.uk" bases are taken, which is what the list publishes.
func parseCFDomains(body string) []string {
	var out []string
	for _, line := range strings.Split(body, "\n") {
		line = strings.TrimSpace(line)
		if line == "" || strings.HasPrefix(line, "#") || strings.HasPrefix(line, "//") {
			continue
		}
		name := strings.TrimRight(strings.ToLower(decodeCFDomain(line)), ".")
		if strings.HasSuffix(name, ".co.uk") && validHostname(name) {
			out = append(out, name)
		}
	}
	return out
}

func cleanUserDomains(domains []string) []string {
	var out []string
	for _, d := range domains {
		d = strings.TrimRight(strings.ToLower(strings.TrimSpace(d)), ".")
		if validHostname(d) {
			out = append(out, d)
		}
	}
	return out
}

type cfList struct {
	mu        sync.Mutex
	user      []string
	refreshed []string
	good      string
	offset    int
}

func (l *cfList) setUser(domains []string) {
	l.mu.Lock()
	defer l.mu.Unlock()
	l.user = cleanUserDomains(domains)
}

func (l *cfList) ordered() []string {
	l.mu.Lock()
	defer l.mu.Unlock()
	var out []string
	for _, list := range [][]string{l.user, l.refreshed, builtinCFDomains} {
		for _, d := range list {
			if !slices.Contains(out, d) {
				out = append(out, d)
			}
		}
	}
	if n := len(out); n > 0 {
		out = slices.Concat(out[l.offset%n:], out[:l.offset%n])
	}
	if i := slices.Index(out, l.good); i > 0 {
		out = slices.Concat([]string{l.good}, out[:i], out[i+1:])
	}
	return out
}

func (l *cfList) markGood(base string) {
	l.mu.Lock()
	defer l.mu.Unlock()
	l.good = base
	l.offset = 0
}

// rotate moves past bases that just failed, so the next connection tries others.
func (l *cfList) rotate(n int) {
	l.mu.Lock()
	defer l.mu.Unlock()
	l.offset += n
	l.good = ""
}

// refresh replaces the refreshed list; a failed or too short answer keeps the previous one.
func (l *cfList) refresh(ctx context.Context, fetch CFFetchFunc) error {
	body, err := fetch(ctx)
	if err != nil {
		return err
	}
	domains := parseCFDomains(body)
	if len(domains) < cfMinRefreshed {
		return errors.New("too few valid domains in the list")
	}
	l.mu.Lock()
	l.refreshed = domains
	l.mu.Unlock()
	return nil
}

func (r *Relay) cfRefreshLoop() {
	delay := cfRefreshFirst
	for {
		select {
		case <-time.After(delay):
		case <-r.ctx.Done():
			return
		}
		if err := r.cf.refresh(r.ctx, r.config.CFFetch); err != nil {
			r.config.Logf("cloudflare domain list: %v", err)
		}
		delay = cfRefreshInterval
	}
}
