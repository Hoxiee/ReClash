package telegram

import (
	"context"
	"encoding/json"
	"io"
	"net"
	"net/http"
	"net/url"
	"sync"
	"time"
)

const (
	dohTimeout   = 1500 * time.Millisecond
	dohCacheTime = 5 * time.Minute
	dohMaxBody   = 64 << 10
)

var dohEndpoints = []string{
	"https://cloudflare-dns.com/dns-query",
	"https://dns.google/dns-query",
	"https://dns.quad9.net/dns-query",
	"https://dns.adguard-dns.com/dns-query",
}

var dohCache struct {
	sync.Mutex
	entries map[string]dohEntry
}

type dohEntry struct {
	address string
	expires time.Time
}

func cachedDoH(domain string, now time.Time) string {
	dohCache.Lock()
	defer dohCache.Unlock()
	entry, ok := dohCache.entries[domain]
	if !ok || now.After(entry.expires) {
		delete(dohCache.entries, domain)
		return ""
	}
	return entry.address
}

func storeDoH(domain, address string, now time.Time) {
	dohCache.Lock()
	defer dohCache.Unlock()
	if dohCache.entries == nil {
		dohCache.entries = make(map[string]dohEntry)
	}
	dohCache.entries[domain] = dohEntry{address: address, expires: now.Add(dohCacheTime)}
}

// resolveDoH asks public resolvers and the system one in parallel. Cloudflare-proxied hosts fail
// on networks whose DNS is poisoned, while their IPs stay reachable.
func resolveDoH(ctx context.Context, domain string) string {
	if net.ParseIP(domain) != nil {
		return domain
	}
	now := time.Now()
	if address := cachedDoH(domain, now); address != "" {
		return address
	}
	ctx, cancel := context.WithTimeout(ctx, dohTimeout)
	defer cancel()
	results := make(chan string, len(dohEndpoints)+1)
	for _, endpoint := range dohEndpoints {
		go func(endpoint string) {
			address := queryDoH(ctx, endpoint, domain)
			select {
			case results <- address:
			case <-ctx.Done():
			}
		}(endpoint)
	}
	go func() {
		addresses, err := net.DefaultResolver.LookupHost(ctx, domain)
		address := ""
		if err == nil {
			address = preferredIP(addresses)
		}
		select {
		case results <- address:
		case <-ctx.Done():
		}
	}()
	for range len(dohEndpoints) + 1 {
		select {
		case address := <-results:
			if address != "" {
				storeDoH(domain, address, now)
				return address
			}
		case <-ctx.Done():
			return ""
		}
	}
	return ""
}

func queryDoH(ctx context.Context, endpoint, domain string) string {
	request, err := http.NewRequestWithContext(ctx, http.MethodGet,
		endpoint+"?name="+url.QueryEscape(domain)+"&type=A", nil)
	if err != nil {
		return ""
	}
	request.Header.Set("Accept", "application/dns-json")
	response, err := http.DefaultClient.Do(request)
	if err != nil {
		return ""
	}
	defer response.Body.Close()
	if response.StatusCode != http.StatusOK {
		return ""
	}
	var answer struct {
		Answer []struct {
			Data string `json:"data"`
			Type int    `json:"type"`
		} `json:"Answer"`
	}
	decoder := json.NewDecoder(io.LimitReader(response.Body, dohMaxBody))
	if err := decoder.Decode(&answer); err != nil {
		return ""
	}
	for _, record := range answer.Answer {
		if record.Type == 1 && net.ParseIP(record.Data) != nil {
			return record.Data
		}
	}
	return ""
}

func preferredIP(addresses []string) string {
	for _, address := range addresses {
		if ip := net.ParseIP(address); ip != nil && ip.To4() != nil {
			return address
		}
	}
	for _, address := range addresses {
		if net.ParseIP(address) != nil {
			return address
		}
	}
	return ""
}
