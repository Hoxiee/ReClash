package core

import (
	"encoding/base64"
	"errors"
	"fmt"
	"io"
	"net"
	"net/http"
	"net/http/httptest"
	"net/url"
	"path/filepath"
	"strings"
	"sync"
	"testing"
	"time"
)

func fetchTestParams(url string) SubscriptionFetchParams {
	return SubscriptionFetchParams{RequestID: "test-" + url, URL: url, TimeoutMillis: 1000, MaxBytes: 1024}
}

func TestFetchSubscriptionResponse(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("X-Test", "ok")
		_, _ = io.WriteString(w, "payload")
	}))
	defer server.Close()
	result, err := fetchSubscription(fetchTestParams(server.URL), &net.Dialer{})
	if err != nil {
		t.Fatal(err)
	}
	if result.Status != http.StatusOK || result.BodyBase64 == "" || result.Headers["X-Test"][0] != "ok" || result.FinalURL != server.URL {
		t.Fatalf("unexpected response: %+v", result)
	}
	if result.Protected {
		t.Fatal("non-protected test connector reported protected=true")
	}
}

func TestFetchSubscriptionStripsHeadersAcrossOrigins(t *testing.T) {
	var leaked bool
	destination := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		leaked = r.Header.Get("Authorization") != "" || r.Header.Get("Cookie") != "" || r.Header.Get("X-Custom") != ""
		_, _ = io.WriteString(w, "ok")
	}))
	defer destination.Close()
	source := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Header.Get("Authorization") != "Bearer secret" || r.Header.Get("X-Custom") != "custom" {
			t.Errorf("initial request lost headers: %v", r.Header)
		}
		http.Redirect(w, r, destination.URL, http.StatusTemporaryRedirect)
	}))
	defer source.Close()
	params := fetchTestParams(source.URL)
	params.Headers = map[string]string{"Authorization": "Bearer secret", "Cookie": "session=secret", "X-Custom": "custom"}
	if _, err := fetchSubscription(params, &net.Dialer{}); err != nil {
		t.Fatal(err)
	}
	if leaked {
		t.Fatal("sensitive or custom header crossed origins")
	}
}

func TestFetchSubscriptionEnforcesBodyAndHeaderLimits(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if got := r.Header.Get("X-HWID"); got != "" && got != "device" {
			t.Errorf("X-HWID = %q", got)
		}
		_, _ = io.WriteString(w, "12345")
	}))
	defer server.Close()
	params := fetchTestParams(server.URL)
	params.MaxBytes = 4
	if _, err := fetchSubscription(params, &net.Dialer{}); err != errSubscriptionTooLarge {
		t.Fatalf("oversize response error = %v", err)
	}
	params = fetchTestParams(server.URL)
	params.Headers = map[string]string{"Connection": "close"}
	if _, err := fetchSubscription(params, &net.Dialer{}); err == nil {
		t.Fatal("accepted connection-controlled header")
	}
	params.Headers = map[string]string{"X-HWID": "device"}
	if err := validateSubscriptionHeaders(params.Headers); err != nil {
		t.Fatalf("rejected generic provider header: %v", err)
	}
	if _, err := fetchSubscription(params, &net.Dialer{}); err != nil {
		t.Fatal(err)
	}
}

func TestFetchSubscriptionWireLimit(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		_, _ = io.CopyN(w, strings.NewReader(strings.Repeat("x", subscriptionFetchWireLimit+1)), subscriptionFetchWireLimit+1)
	}))
	defer server.Close()
	params := fetchTestParams(server.URL)
	params.MaxBytes = subscriptionFetchBodyLimit
	if _, err := fetchSubscription(params, &net.Dialer{}); err != errSubscriptionTooLarge {
		t.Fatalf("wire-limit error = %v", err)
	}
}

func TestFetchSubscriptionCapsRedirectsAndRejectsDowngrade(t *testing.T) {
	var server *httptest.Server
	server = httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		depth := 0
		_, _ = fmt.Sscanf(strings.TrimPrefix(r.URL.Path, "/"), "%d", &depth)
		if depth < 6 {
			http.Redirect(w, r, fmt.Sprintf("%s/%d", server.URL, depth+1), http.StatusTemporaryRedirect)
			return
		}
		_, _ = io.WriteString(w, "ok")
	}))
	defer server.Close()
	params := fetchTestParams(server.URL + "/0")
	if _, err := fetchSubscription(params, &net.Dialer{}); err == nil || !strings.Contains(err.Error(), "too many subscription redirects") {
		t.Fatalf("redirect chain error = %v", err)
	}
	secure, _ := url.Parse("https://example.test/path")
	insecure, _ := url.Parse("http://example.test/path")
	if err := validateSubscriptionRedirect(secure, insecure); err == nil {
		t.Fatal("accepted HTTPS downgrade")
	}
}

func TestFetchSubscriptionCancellationAndTimeout(t *testing.T) {
	started := make(chan struct{})
	var startOnce sync.Once
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		startOnce.Do(func() { close(started) })
		<-r.Context().Done()
	}))
	defer server.Close()
	params := fetchTestParams(server.URL)
	params.RequestID = "cancel-one"
	params.TimeoutMillis = 1000
	done := make(chan error, 1)
	go func() {
		_, err := fetchSubscription(params, &net.Dialer{})
		done <- err
	}()
	<-started
	if !cancelSubscriptionFetch(params.RequestID) {
		t.Fatal("active request was not found")
	}
	select {
	case err := <-done:
		if err != errSubscriptionCancelled {
			t.Fatalf("cancel error = %v", err)
		}
	case <-time.After(time.Second):
		t.Fatal("cancel did not stop request")
	}
	params.RequestID = "timeout-one"
	params.TimeoutMillis = 50
	if _, err := fetchSubscription(params, &net.Dialer{}); err == nil {
		t.Fatal("request exceeded deadline without error")
	}
}

func TestFetchSubscriptionValidatesURLAndLimits(t *testing.T) {
	for _, raw := range []string{"file:///etc/passwd", "ftp://example.test/file", "http://user:pass@example.test/a"} {
		if strings.HasPrefix(raw, "http://user:") {
			if _, err := parseSubscriptionURL(raw); err != nil {
				t.Fatalf("basic-auth URL should be extracted at initial request: %v", err)
			}
			continue
		}
		if _, err := parseSubscriptionURL(raw); err == nil {
			t.Errorf("accepted unsafe URL %q", raw)
		}
	}
	params := fetchTestParams("http://example.test")
	params.TimeoutMillis = int((subscriptionFetchTimeoutLimit / time.Millisecond) + 1)
	if _, err := fetchSubscription(params, &net.Dialer{}); err == nil {
		t.Fatal("accepted timeout above hard limit")
	}
}

func TestSubscriptionFetchRegistryRejectsDuplicateAndExcessRequests(t *testing.T) {
	_, firstCleanup, err := registerSubscriptionFetch("duplicate", time.Second)
	if err != nil {
		t.Fatal(err)
	}
	defer firstCleanup()
	if _, _, err := registerSubscriptionFetch("duplicate", time.Second); err == nil {
		t.Fatal("accepted duplicate request id")
	}
	cleanups := make([]func(), 0, subscriptionFetchMaxConcurrent-1)
	for i := 0; i < subscriptionFetchMaxConcurrent-1; i++ {
		_, cleanup, err := registerSubscriptionFetch(fmt.Sprintf("active-%d", i), time.Second)
		if err != nil {
			t.Fatal(err)
		}
		cleanups = append(cleanups, cleanup)
	}
	defer func() {
		for _, cleanup := range cleanups {
			cleanup()
		}
	}()
	if _, _, err := registerSubscriptionFetch("overflow", time.Second); err == nil {
		t.Fatal("exceeded active request limit")
	}
}

func TestCancelSubscriptionFetchesCancelsActiveRequests(t *testing.T) {
	ctx, unregister, err := registerSubscriptionFetch("teardown", time.Second)
	if err != nil {
		t.Fatal(err)
	}
	defer unregister()
	cancelSubscriptionFetches()
	select {
	case <-ctx.Done():
	case <-time.After(time.Second):
		t.Fatal("teardown did not cancel the active fetch")
	}
}

func TestUnprotectedCoreSubscriptionFetchUsesPlatformRoute(t *testing.T) {
	_, err := handleFetchSubscription(fetchTestParams("https://example.test/profile"))
	var methodErr *MethodError
	if !errors.As(err, &methodErr) || methodErr.Code != "invalid_arguments" {
		t.Fatalf("non-bypass request error = %v, want invalid_arguments", err)
	}
	if bypassSubscriptionConnector == nil {
		params := fetchTestParams("https://example.test/profile")
		params.Bypass = true
		_, err := handleFetchSubscription(params)
		var methodErr *MethodError
		if !errors.As(err, &methodErr) || methodErr.Code != "subscription_protection" {
			t.Fatalf("error = %v, want subscription_protection", err)
		}
		return
	}
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		_, _ = io.WriteString(w, "profile")
	}))
	defer server.Close()
	params := fetchTestParams(server.URL)
	params.Bypass = true
	result, err := handleFetchSubscription(params)
	if err != nil {
		t.Fatal(err)
	}
	if result.Protected {
		t.Fatal("desktop bypass route reported Android socket protection")
	}
	if !result.Bypassed {
		t.Fatal("subscription response did not report bypass route")
	}
	body, err := base64.StdEncoding.DecodeString(result.BodyBase64)
	if err != nil || string(body) != "profile" {
		t.Fatalf("body = %q, error = %v", body, err)
	}
}

func TestProtectedSubscriptionFetchFailsClosedWithoutTransport(t *testing.T) {
	params := fetchTestParams("https://example.test/subscription")
	params.Protected = true
	params.Bypass = true
	_, err := handleFetchSubscription(params)
	var methodErr *MethodError
	if !errors.As(err, &methodErr) || methodErr.Code != "subscription_protection" {
		t.Fatalf("error = %v, want subscription_protection", err)
	}
}

func TestCancelSubscriptionFetchReturnsFalseAfterCompletion(t *testing.T) {
	ctx, unregister, err := registerSubscriptionFetch("completed", time.Second)
	if err != nil {
		t.Fatal(err)
	}
	if err := ctx.Err(); err != nil {
		t.Fatal(err)
	}
	unregister()
	if cancelSubscriptionFetch("completed") {
		t.Fatal("completed request remained active")
	}
}

func TestFetchSubscriptionPreservesHTTPFlagsWithoutRetryClassification(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		w.Header().Add("Retry-After", "30")
		w.Header().Set("X-Device-Flag", "quota")
		w.WriteHeader(http.StatusTooManyRequests)
		_, _ = io.WriteString(w, "server detail must not be returned as body")
	}))
	defer server.Close()
	result, err := fetchSubscription(fetchTestParams(server.URL), &net.Dialer{})
	if err != nil {
		t.Fatal(err)
	}
	if result.Status != http.StatusTooManyRequests || result.Headers["Retry-After"][0] != "30" || result.Headers["X-Device-Flag"][0] != "quota" || result.BodyBase64 != base64.StdEncoding.EncodeToString([]byte("server detail must not be returned as body")) {
		t.Fatalf("HTTP flags were not preserved safely: %+v", result)
	}
}

func TestSubscriptionHeadersRejectCaseInsensitiveDuplicates(t *testing.T) {
	if err := validateSubscriptionHeaders(map[string]string{"X-Source": "one", "x-source": "two"}); err == nil {
		t.Fatal("accepted case-insensitive duplicate headers")
	}
}

func TestSubscriptionURLCredentialsBecomeInitialBasicAuth(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		user, password, ok := r.BasicAuth()
		if !ok || user != "user@name" || password != "p:ss" {
			t.Errorf("basic auth = %q, %q, %t", user, password, ok)
		}
		_, _ = io.WriteString(w, "ok")
	}))
	defer server.Close()
	params := fetchTestParams(strings.Replace(server.URL, "http://", "http://user%40name:p%3Ass@", 1))
	result, err := fetchSubscription(params, &net.Dialer{})
	if err != nil {
		t.Fatal(err)
	}
	if strings.Contains(result.FinalURL, "user") || strings.Contains(result.FinalURL, "p%3Ass") {
		t.Fatalf("credentials leaked into final URL: %q", result.FinalURL)
	}
}

func TestDownloadRuleSetPassesSourceHeadersToHTTPVehicle(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Header.Get("Authorization") != "Bearer source-token" || r.Header.Get("X-HWID") != "" {
			t.Errorf("source headers = %v", r.Header)
		}
		if r.Header.Get("X-App-Identity") != "" {
			t.Errorf("app identity leaked into source request")
		}
		_, _ = io.WriteString(w, "payload:\n  - example.com\n")
	}))
	defer server.Close()
	body, err := downloadRuleSet(server.URL, filepath.Join(t.TempDir(), "rules"), map[string]string{
		"Authorization": "Bearer source-token",
	})
	if err != nil {
		t.Fatal(err)
	}
	if string(body) != "payload:\n  - example.com\n" {
		t.Fatalf("download body = %q", body)
	}
	if _, err := downloadRuleSet(server.URL, filepath.Join(t.TempDir(), "rules"), map[string]string{"Connection": "close"}); err == nil {
		t.Fatal("accepted forbidden source header")
	}
	if _, err := downloadRuleSet(server.URL, filepath.Join(t.TempDir(), "rules"), map[string]string{"X-HWID": "device-id"}); err == nil {
		t.Fatal("accepted device identity on resource request")
	}
}
