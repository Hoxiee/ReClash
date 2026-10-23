package core

import (
	"context"
	"net/http"
	"slices"
	"testing"
	"time"
)

func TestPublicWebsiteCheckersAreRegistered(t *testing.T) {
	names := []string{"telegram", "sberbank", "gosuslugi", "vk", "kinopoisk", "yandex"}
	checkers := selectedCheckers(names)
	if len(checkers) != len(names) {
		t.Fatalf("selected %d checks, want %d", len(checkers), len(names))
	}
	for i, name := range names {
		if checkers[i].name != name || checkers[i].check == nil {
			t.Errorf("checker %d = %+v, want %s", i, checkers[i], name)
		}
		count := 0
		for _, checker := range serviceCheckers {
			if checker.name == name {
				count++
			}
		}
		if count != 1 {
			t.Errorf("%s registered %d times, want 1", name, count)
		}
	}
}

func TestPublicWebsiteStatus(t *testing.T) {
	const target = "https://www.kinopoisk.ru/"
	cases := []struct {
		name string
		code int
		url  string
		body string
		want string
	}{
		{"page", 200, target, "<title>Кинопоиск</title>", serviceAvailable},
		{"same host redirect", 200, target + "?nr=1", "", serviceAvailable},
		{"no unlock inference", 200, target, "public landing page", serviceAvailable},
		{"cookie bridge", 200, "https://sso.passport.yandex.ru/push?retpath=" + target, "<body></body><script>install()</script>", serviceRestricted},
		{"captcha redirect", 200, target + "showcaptcha?retpath=/", "", serviceRestricted},
		{"challenge path", 200, target + "challenge/", "", serviceRestricted},
		{"captcha title", 200, target, "<title>CAPTCHA</title>", serviceRestricted},
		{"yandex challenge", 200, target, "<title>Ой!</title>", serviceRestricted},
		{"challenge form", 200, target, `<form id="advanced-captcha-form">`, serviceRestricted},
		{"cloudflare", 200, target, `<script src="/cdn-cgi/challenge-platform/foo">`, serviceRestricted},
		{"access denied", 200, target, "<title>Access Denied</title>", serviceRestricted},
		{"ordinary captcha reference", 200, target, `<script>var captchaEnabled = false;</script>`, serviceAvailable},
		{"unauthorized", 401, target, "", serviceRestricted},
		{"forbidden", 403, target, "", serviceRestricted},
		{"rate limited", 429, target, "", serviceRestricted},
		{"legal block", 451, target, "", serviceRestricted},
		{"missing", 404, target, "", serviceUnavailable},
		{"server error", 503, target, "<title>CAPTCHA</title>", serviceUnavailable},
		{"unfollowed redirect", 302, target, "", serviceUnavailable},
		{"invalid final url", 200, "://", "", serviceFailed},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			result := &ProbeResult{StatusCode: tc.code, Url: tc.url, Body: tc.body}
			if got := publicWebsiteStatus(target, result); got != tc.want {
				t.Errorf("status = %q, want %q", got, tc.want)
			}
		})
	}
}

func TestCheckPublicWebsiteUsesProbeAndPreservesRoute(t *testing.T) {
	withProbeProxies(t, "DIRECT")
	for _, code := range []int{200, 403, 503} {
		t.Run(http.StatusText(code), func(t *testing.T) {
			server := probeServer(t, func(w http.ResponseWriter, r *http.Request) {
				if r.UserAgent() != browserUserAgent {
					t.Errorf("user agent = %q", r.UserAgent())
				}
				w.WriteHeader(code)
				_, _ = w.Write([]byte("<title>Public website</title>"))
			})
			item := checkPublicWebsite(server.URL)(serviceEnv{
				ctx: context.Background(), proxyName: "DIRECT", timeout: time.Second,
			})
			if item.Status != statusFromCode(code) || item.Region != "" {
				t.Errorf("item = %+v, want web status without a region claim", item)
			}
			if !slices.Equal(item.Chains, []string{"DIRECT"}) {
				t.Errorf("chains = %v, want [DIRECT]", item.Chains)
			}
		})
	}
}

func TestCheckPublicWebsitePreservesTransportFailure(t *testing.T) {
	withProbeProxies(t, "DIRECT")
	ctx, cancel := context.WithCancel(context.Background())
	cancel()
	item := checkPublicWebsite("https://example.invalid/")(serviceEnv{
		ctx: ctx, proxyName: "DIRECT", timeout: time.Second,
	})
	if item.Status != serviceFailed || item.Delay != 0 || item.Region != "" {
		t.Errorf("cancelled item = %+v, want failed without delay or region", item)
	}
}

func TestCheckPublicWebsiteReadsSoftBlockBody(t *testing.T) {
	withProbeProxies(t, "DIRECT")
	server := probeServer(t, func(w http.ResponseWriter, r *http.Request) {
		_, _ = w.Write([]byte("<title>Just a moment...</title>"))
	})
	item := checkPublicWebsite(server.URL)(serviceEnv{
		ctx: context.Background(), proxyName: "DIRECT", timeout: time.Second,
	})
	if item.Status != serviceRestricted {
		t.Errorf("status = %q, want restricted for a 200 challenge", item.Status)
	}
}

func TestCheckPublicWebsitePreservesTimeout(t *testing.T) {
	withProbeProxies(t, "DIRECT")
	server := probeServer(t, func(w http.ResponseWriter, r *http.Request) {
		<-r.Context().Done()
	})
	item := checkPublicWebsite(server.URL)(serviceEnv{
		ctx: context.Background(), proxyName: "DIRECT", timeout: 20 * time.Millisecond,
	})
	if item.Status != serviceTimeout || item.Delay != 0 || item.Region != "" {
		t.Errorf("timed out item = %+v, want timeout without delay or region", item)
	}
}
