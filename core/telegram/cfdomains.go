package telegram

import (
	"context"
	"errors"
	"fmt"
	"io"
	mathrand "math/rand/v2"
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
	cfRefreshRetry    = 10 * time.Second
	cfRefreshInterval = time.Hour
	cfFetchTimeout    = 10 * time.Second
	cf429Cooldown     = 45 * time.Second
	cf429MaxCooldown  = 5 * time.Minute
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

func cacheBuster() string {
	var tag [7]byte
	for i := range tag {
		tag[i] = byte('a' + mathrand.IntN(26))
	}
	return string(tag[:])
}

func fetchCFDomains(ctx context.Context) (string, error) {
	ctx, cancel := context.WithTimeout(ctx, cfFetchTimeout)
	defer cancel()
	request, err := http.NewRequestWithContext(ctx, http.MethodGet, CFDomainsURL+"?"+cacheBuster(), nil)
	if err != nil {
		return "", err
	}
	request.Header.Set("User-Agent", "tg-ws-proxy")
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

type cfCooldown struct {
	until   time.Time
	strikes int
}

type cfList struct {
	mu        sync.Mutex
	user      []string
	refreshed []string
	chosen    map[int]string
	cooldown  map[string]cfCooldown
	offset    int
}

func (l *cfList) setUser(domains []string) {
	l.mu.Lock()
	defer l.mu.Unlock()
	l.user = cleanUserDomains(domains)
}

func (l *cfList) ordered() []string { return l.orderedForDC(0) }

// orderedForDC puts the domain that last worked for this DC first. The rest rotate, so a failed
// base is not the first one a later connection pays for.
func (l *cfList) orderedForDC(dc int) []string {
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
	if good := l.chosen[dc]; good != "" {
		if i := slices.Index(out, good); i > 0 {
			out = slices.Concat([]string{good}, out[:i], out[i+1:])
		}
	}
	return out
}

// availableForDC is orderedForDC without bases in an HTTP 429 cooldown.
func (l *cfList) availableForDC(dc int, now time.Time) []string {
	ordered := l.orderedForDC(dc)
	l.mu.Lock()
	defer l.mu.Unlock()
	out := ordered[:0]
	for _, base := range ordered {
		if state, ok := l.cooldown[base]; ok && now.Before(state.until) {
			continue
		}
		out = append(out, base)
	}
	return out
}

func (l *cfList) markGood(dc int, base string) {
	l.mu.Lock()
	defer l.mu.Unlock()
	if l.chosen == nil {
		l.chosen = make(map[int]string)
	}
	l.chosen[dc] = base
	l.offset = 0
	delete(l.cooldown, base)
}

// rotate moves past bases that just failed, so the next connection tries others.
func (l *cfList) rotate(n int) {
	l.mu.Lock()
	defer l.mu.Unlock()
	l.offset += n
	clear(l.chosen)
}

func (l *cfList) cooldownRemaining(base string, now time.Time) time.Duration {
	l.mu.Lock()
	defer l.mu.Unlock()
	state, ok := l.cooldown[base]
	if !ok || !now.Before(state.until) {
		return 0
	}
	return state.until.Sub(now)
}

// mark429 raises the cooldown: Retry-After when the server sends one, otherwise 45 seconds
// doubling per strike, capped at five minutes.
func (l *cfList) mark429(base string, retryAfter time.Duration, now time.Time) time.Duration {
	l.mu.Lock()
	defer l.mu.Unlock()
	if l.cooldown == nil {
		l.cooldown = make(map[string]cfCooldown)
	}
	previous := l.cooldown[base]
	strikes := previous.strikes
	if !previous.until.IsZero() && now.After(previous.until.Add(cf429MaxCooldown)) {
		strikes = 0
	}
	delay := retryAfter
	if delay <= 0 {
		delay = cf429Cooldown
		for range strikes {
			delay *= 2
			if delay >= cf429MaxCooldown {
				delay = cf429MaxCooldown
				break
			}
		}
	}
	delay = min(delay, cf429MaxCooldown)
	l.cooldown[base] = cfCooldown{until: now.Add(delay), strikes: strikes + 1}
	return delay
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
	select {
	case <-time.After(cfRefreshFirst):
	case <-r.ctx.Done():
		return
	}
	for range 3 {
		if err := r.cf.refresh(r.ctx, r.config.CFFetch); err == nil {
			break
		} else {
			r.config.Logf("cloudflare domain list: %v", err)
		}
		select {
		case <-time.After(cfRefreshRetry):
		case <-r.ctx.Done():
			return
		}
	}
	ticker := time.NewTicker(cfRefreshInterval)
	defer ticker.Stop()
	for {
		select {
		case <-ticker.C:
			if err := r.cf.refresh(r.ctx, r.config.CFFetch); err != nil {
				r.config.Logf("cloudflare domain list: %v", err)
			}
		case <-r.ctx.Done():
			return
		}
	}
}
