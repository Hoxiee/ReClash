package subscription

import (
	"context"
	"errors"
	"fmt"
	"io"
	"net"
	"net/http"
	"net/http/httptest"
	"strings"
	"sync/atomic"
	"syscall"
	"testing"
	"time"
)

func subscriptionParams(url string) *FetchParams {
	return &FetchParams{URL: url, Headers: map[string]string{"User-Agent": "test-client", "X-Hwid": "test-id"}, TimeoutMillis: 1000}
}

func TestSubscriptionFetchResponse(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Header.Get("X-Hwid") != "test-id" || r.UserAgent() != "test-client" {
			t.Error("request headers lost")
		}
		w.Header().Set("X-Hwid-Not-Supported", "true")
		_, _ = io.WriteString(w, "proxies: []")
	}))
	defer server.Close()
	result, err := fetchSubscription(subscriptionParams(server.URL), &net.Dialer{})
	if err != nil {
		t.Fatal(err)
	}
	if result.Status != 200 || string(result.Body) != "proxies: []" || result.Headers["X-Hwid-Not-Supported"][0] != "true" {
		t.Fatalf("unexpected response: %+v", result)
	}
}

func TestSubscriptionFetchDoesNotFollowRedirect(t *testing.T) {
	var calls atomic.Int32
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		calls.Add(1)
		w.Header().Set("Location", "/secret")
		w.WriteHeader(http.StatusFound)
	}))
	defer server.Close()
	result, err := fetchSubscription(subscriptionParams(server.URL), &net.Dialer{})
	if err != nil || result.Status != 302 || calls.Load() != 1 || len(result.Body) != 0 {
		t.Fatalf("redirect was not returned intact: %+v %v calls=%d", result, err, calls.Load())
	}
}

func TestSubscriptionFetchRejectsUntrustedTLS(t *testing.T) {
	server := httptest.NewTLSServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) { w.WriteHeader(200) }))
	defer server.Close()
	if _, err := fetchSubscription(subscriptionParams(server.URL), &net.Dialer{}); err == nil {
		t.Fatal("untrusted TLS certificate accepted")
	}
}

func TestSubscriptionFetchLimits(t *testing.T) {
	for _, declared := range []bool{false, true} {
		t.Run(fmt.Sprint(declared), func(t *testing.T) {
			server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				if declared {
					w.Header().Set("Content-Length", fmt.Sprint(subscriptionBodyLimit+1))
				}
				_, _ = io.WriteString(w, strings.Repeat("x", subscriptionBodyLimit+1))
			}))
			defer server.Close()
			if _, err := fetchSubscription(subscriptionParams(server.URL), &net.Dialer{}); !errors.Is(err, errSubscriptionTooLarge) {
				t.Fatalf("expected size limit, got %v", err)
			}
		})
	}
}

func TestSubscriptionFetchDeadlineAndStop(t *testing.T) {
	for _, stop := range []bool{false, true} {
		t.Run(fmt.Sprint(stop), func(t *testing.T) {
			started := make(chan struct{})
			server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				close(started)
				<-r.Context().Done()
			}))
			defer server.Close()
			params := subscriptionParams(server.URL)
			params.TimeoutMillis = 100
			done := make(chan error, 1)
			go func() { _, err := fetchSubscription(params, &net.Dialer{}); done <- err }()
			<-started
			if stop {
				cancelSubscriptionFetches()
			}
			select {
			case err := <-done:
				if err == nil {
					t.Fatal("request should fail")
				}
			case <-time.After(time.Second):
				t.Fatal("request outlived deadline")
			}
		})
	}
}

func TestSubscriptionProtectionRefusalIsLatched(t *testing.T) {
	var calls atomic.Int32
	dialer := newSubscriptionDialer(func(_, _ string, _ syscall.RawConn) error {
		calls.Add(1)
		return errSubscriptionProtection
	}, []string{"127.0.0.1:53"})
	for i := 0; i < 2; i++ {
		if _, err := dialer.DialContext(context.Background(), "tcp", "127.0.0.1:1"); !errors.Is(err, errSubscriptionProtection) {
			t.Fatalf("socket protection did not fail closed: %v", err)
		}
	}
	if calls.Load() != 1 {
		t.Fatalf("retried refused protection %d times", calls.Load())
	}
}

func TestSubscriptionDNSUsesProtectedSocket(t *testing.T) {
	var network string
	dialer := newSubscriptionDialer(func(n, address string, _ syscall.RawConn) error {
		network = n
		if address != "127.0.0.1:53" {
			t.Errorf("wrong DNS server: %s", address)
		}
		return errSubscriptionProtection
	}, []string{"127.0.0.1:53"})
	_, err := dialer.DialContext(context.Background(), "tcp", "subscription.invalid:443")
	if !errors.Is(err, errSubscriptionProtection) || network != "udp4" {
		t.Fatalf("DNS escaped protected dialer: network=%s err=%v", network, err)
	}
}

func TestSubscriptionConcurrentProtectionRefusal(t *testing.T) {
	var calls atomic.Int32
	dialer := newSubscriptionDialer(func(_, _ string, _ syscall.RawConn) error {
		calls.Add(1)
		return errSubscriptionProtection
	}, []string{"127.0.0.1:53"})
	results := make(chan error, 16)
	for i := 0; i < cap(results); i++ {
		go func() {
			_, err := dialer.DialContext(context.Background(), "tcp", "subscription.invalid:443")
			results <- err
		}()
	}
	for i := 0; i < cap(results); i++ {
		select {
		case err := <-results:
			if !errors.Is(err, errSubscriptionProtection) {
				t.Fatalf("protection refusal lost: %v", err)
			}
		case <-time.After(time.Second):
			t.Fatal("refused attempt did not stop")
		}
	}
	if calls.Load() != 1 {
		t.Fatalf("protection retried concurrently: %d", calls.Load())
	}
}

func TestSubscriptionFetchRejectsUnsafeInput(t *testing.T) {
	for _, url := range []string{"file:///secret", "ftp://example.com/sub", "https://user:pass@example.com/sub", "https://"} {
		if _, err := fetchSubscription(subscriptionParams(url), &net.Dialer{}); err == nil {
			t.Errorf("accepted %s", url)
		}
	}
	params := subscriptionParams("http://127.0.0.1:1")
	params.Headers["Proxy-Authorization"] = "secret"
	if _, err := fetchSubscription(params, &net.Dialer{}); err == nil {
		t.Fatal("accepted proxy credentials")
	}
}
