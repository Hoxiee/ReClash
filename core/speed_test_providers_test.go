package core

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"net/http/httptest"
	"strings"
	"sync"
	"sync/atomic"
	"testing"
	"time"
)

func TestSpeedTestServerParsingValidatesHostsSearchAndResultLimits(t *testing.T) {
	entries := make([]map[string]any, 0, 100)
	for index := range 60 {
		entries = append(entries, map[string]any{"id": index, "host": fmt.Sprintf("server%d.invalid:443", index), "name": "Tokyo & West", "cc": "jp", "sponsor": "Example"})
	}
	body, _ := json.Marshal(entries)
	servers, err := parseSpeedTestServers(body, "tokyo & west")
	if err != nil || len(servers) != speedTestMaxServers || servers[0].ID != "0" || servers[0].Country != "JP" {
		t.Fatalf("parsed servers=%+v err=%v", servers, err)
	}
	if servers, err := parseSpeedTestServers(body, "no match"); err != nil || len(servers) != 0 {
		t.Fatalf("search did not filter results: %+v, %v", servers, err)
	}
	for _, host := range []string{"", "https://server.invalid:443", "server.invalid:0", "user@server.invalid:443", "server.invalid:443/path", "server.invalid:70000"} {
		if validSpeedTestHost(host) {
			t.Fatalf("accepted invalid server host %q", host)
		}
	}
	if !validSpeedTestHost("[::1]:443") {
		t.Fatal("rejected a valid IPv6 host and port")
	}
	if _, err := parseSpeedTestServers([]byte(strings.Repeat(" ", speedTestMaxResponse+1)), ""); err == nil {
		t.Fatal("accepted an oversized server response")
	}
	if _, err := parseSpeedTestServers([]byte(`{"unexpected":true}`), ""); err == nil {
		t.Fatal("accepted a non-list server response")
	}
	duplicates := []byte(`[{"host":"one.invalid:443"},{"host":"one.invalid:443"},{"host":"bad.invalid:0"}]`)
	if servers, err := parseSpeedTestServers(duplicates, ""); err != nil || len(servers) != 1 {
		t.Fatalf("duplicate/invalid hosts = %+v, %v", servers, err)
	}
}

func TestSpeedTestLibreSpeedPreservesRelativeEndpointPaths(t *testing.T) {
	body := []byte(`[
		{"name":"First","server":"//example.invalid/backend","dlURL":"garbage.php","ulURL":"empty.php","pingURL":"empty.php"},
		{"name":"Second","server":"https://second.invalid/test/"},
		{"name":"Invalid","server":"https://invalid.invalid","dlURL":7},
		{"name":"Credentials","server":"https://example.invalid","pingURL":"https://user:password@example.invalid/ping"},
		{"name":"Local file","server":"file:///tmp/server"}
	]`)
	targets, err := parseLibreSpeedTargets(body)
	if err != nil || len(targets) != 2 {
		t.Fatalf("LibreSpeed targets=%+v err=%v", targets, err)
	}
	if targets[0].downloadURL != "https://example.invalid/backend/garbage.php" || targets[0].uploadURL != "https://example.invalid/backend/empty.php" || targets[1].latencyURL != "https://second.invalid/test/empty.php" {
		t.Fatalf("LibreSpeed paths = %+v %+v", targets[0], targets[1])
	}
	budget := newSpeedTestBudget(4 * speedTestLibreChunk)
	reservation := budget.reserve(speedTestDownload, speedTestLibreChunk+100, speedTestLibreChunk)
	if reservation == nil || reservation.amount != speedTestLibreChunk {
		t.Fatalf("whole-chunk reservation = %+v", reservation)
	}
	reservation.release()
	if budget.reserve(speedTestDownload, speedTestLibreChunk-1, speedTestLibreChunk) != nil {
		t.Fatal("LibreSpeed admitted a partial wire chunk")
	}
}

func TestSpeedTestCloudflareUsesOnlyItsProviderTrace(t *testing.T) {
	var requests atomic.Int32
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, req *http.Request) {
		requests.Add(1)
		if req.URL.Path != "/cdn-cgi/trace" {
			t.Errorf("unexpected provider request %s", req.URL.Path)
		}
		w.Header().Set("cf-ray", "test-iad")
		_, _ = io.WriteString(w, "ip=127.0.0.1\nloc=us\ncolo=iad\n")
	}))
	defer server.Close()
	previous := speedTestCloudflareURL
	speedTestCloudflareURL = server.URL
	defer func() { speedTestCloudflareURL = previous }()
	transport, err := newSpeedTestTransport(context.Background(), SpeedTestParams{Direct: true})
	if err != nil {
		t.Fatal(err)
	}
	defer transport.close()
	client, err := transport.newClient("h1")
	if err != nil {
		t.Fatal(err)
	}
	target, err := prepareCloudflareSpeedTest(context.Background(), client)
	if err != nil || target.server.Country != "US" || target.server.Name != "Cloudflare IAD" || target.latencyURL != server.URL+"/__down?bytes=0" || target.uploadURL != server.URL+"/__up" || requests.Load() != 1 {
		t.Fatalf("Cloudflare target=%+v err=%v requests=%d", target, err, requests.Load())
	}
}

func TestSpeedTestAppleConfigNeverUsesTheLargeBodyForLatencyOnly(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		_, _ = io.WriteString(w, `{"test_endpoint":"uschi-edge.example.invalid","urls":{"large_https_download_url":"https://apple.invalid/large","https_upload_url":"https://apple.invalid/upload"}}`)
	}))
	defer server.Close()
	previous := speedTestAppleConfigURL
	speedTestAppleConfigURL = server.URL
	defer func() { speedTestAppleConfigURL = previous }()
	transport, err := newSpeedTestTransport(context.Background(), SpeedTestParams{Direct: true})
	if err != nil {
		t.Fatal(err)
	}
	defer transport.close()
	client, err := transport.newClient("h1")
	if err != nil {
		t.Fatal(err)
	}
	target, err := prepareAppleSpeedTest(context.Background(), client)
	if err != nil || target.latencyMethod != http.MethodHead || target.latencyURL != target.downloadURL || target.server.Country != "US" || target.server.Name != "Apple CHI" {
		t.Fatalf("Apple target=%+v err=%v", target, err)
	}
	if country, colo := speedTestAppleLocation("not-an-apple-endpoint"); country != "" || colo != "" {
		t.Fatal("invented an Apple location")
	}
}

func TestSpeedTestServerDiscoveryIsExplicitSearchableAndBounded(t *testing.T) {
	searches := make(chan string, 1)
	var requests atomic.Int32
	var server *httptest.Server
	server = httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, req *http.Request) {
		requests.Add(1)
		if req.URL.Path == "/servers" {
			searches <- req.URL.Query().Get("search")
			_ = json.NewEncoder(w).Encode([]map[string]any{{"id": "local", "host": server.Listener.Addr().String(), "name": "Tokyo & West", "cc": "jp", "sponsor": "Local"}})
			return
		}
		if req.URL.Path != "/latency.txt" || req.Method != http.MethodGet {
			t.Errorf("discovery made a bulk request: %s %s", req.Method, req.URL.Path)
		}
		_, _ = io.WriteString(w, "latency")
	}))
	defer server.Close()
	oldURL, oldScheme := speedTestServersURL, speedTestServerScheme
	speedTestServersURL, speedTestServerScheme = server.URL+"/servers?engine=js&limit=10", "http"
	defer func() { speedTestServersURL, speedTestServerScheme = oldURL, oldScheme }()
	servers, err := handleSpeedTestServers(SpeedTestServersParams{RequestID: t.Name(), Direct: true, Search: " Tokyo & West "})
	if err != nil || len(servers) != 1 || servers[0].LatencyMs == nil || *servers[0].LatencyMs <= 0 {
		t.Fatalf("discovery=%+v err=%v", servers, err)
	}
	if search := <-searches; search != "Tokyo & West" || requests.Load() != 2 {
		t.Fatalf("query=%q requests=%d", search, requests.Load())
	}
}

func TestSpeedTestServerDiscoveryHonorsCancellationAndTombstones(t *testing.T) {
	entered := make(chan struct{})
	var once sync.Once
	server := httptest.NewServer(http.HandlerFunc(func(_ http.ResponseWriter, req *http.Request) {
		once.Do(func() { close(entered) })
		<-req.Context().Done()
	}))
	defer server.Close()
	previous := speedTestServersURL
	speedTestServersURL = server.URL
	defer func() { speedTestServersURL = previous }()
	cancelledID := t.Name() + "-cancelled"
	handleCancelSpeedTest(SpeedTestRequest{RequestID: cancelledID})
	if _, err := handleSpeedTestServers(SpeedTestServersParams{RequestID: cancelledID, Direct: true}); !errors.Is(err, context.Canceled) {
		t.Fatalf("cancel-before-discovery = %v", err)
	}
	id := t.Name() + "-active"
	result := make(chan error, 1)
	safeGo("testSpeedTestDiscovery", func() {
		_, err := handleSpeedTestServers(SpeedTestServersParams{RequestID: id, Direct: true})
		result <- err
	})
	awaitSpeedTest(t, entered)
	currentSpeedTests.mu.Lock()
	deadline, bounded := currentSpeedTests.discovery.ctx.Deadline()
	currentSpeedTests.mu.Unlock()
	if !bounded || time.Until(deadline) > speedTestDiscoveryLimit {
		t.Fatal("discovery has no bounded deadline")
	}
	handleCancelSpeedTest(SpeedTestRequest{RequestID: "unrelated-discovery"})
	select {
	case err := <-result:
		t.Fatalf("unrelated cancellation stopped discovery: %v", err)
	case <-time.After(10 * time.Millisecond):
	}
	if !handleCancelSpeedTest(SpeedTestRequest{RequestID: id}) {
		t.Fatal("matching discovery was not cancelled")
	}
	select {
	case err := <-result:
		if !errors.Is(err, context.Canceled) {
			t.Fatalf("cancelled discovery = %v", err)
		}
	case <-time.After(time.Second):
		t.Fatal("discovery did not cancel stalled I/O")
	}
}
