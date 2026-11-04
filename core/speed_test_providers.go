package core

import (
	"context"
	"encoding/json"
	"errors"
	"math"
	"net"
	"net/url"
	"slices"
	"strconv"
	"strings"
	"sync"
	"sync/atomic"
)

var (
	speedTestAppleConfigURL = "https://mensura.cdn-apple.com/api/v1/gm/config"
	speedTestCloudflareURL  = "https://speed.cloudflare.com"
	speedTestServersURL     = "https://www.speedtest.net/api/js/servers?engine=js&limit=10&https_functional=true"
	speedTestServerScheme   = "https"
	speedTestLibreListURL   = "https://librespeed.org/backend-servers/servers.php"
)

type speedTestTarget struct {
	backend       string
	latencyURL    string
	latencyMethod string
	downloadURL   string
	uploadURL     string
	server        SpeedTestServer
}

func validateSpeedTestServer(server SpeedTestServer) error {
	for _, value := range []string{server.ID, server.Name, server.Host, server.Country, server.Sponsor} {
		if len(value) > 512 {
			return errors.New("invalid speed test server field")
		}
	}
	if server.LatencyMs != nil && (math.IsNaN(*server.LatencyMs) || math.IsInf(*server.LatencyMs, 0) || *server.LatencyMs < 0) {
		return errors.New("invalid speed test server latency")
	}
	return nil
}

func validSpeedTestHost(host string) bool {
	if len(host) > 320 || strings.ContainsAny(host, "/?#@\\ \t\r\n") {
		return false
	}
	name, portText, err := net.SplitHostPort(host)
	if err != nil || name == "" {
		return false
	}
	port, err := strconv.ParseUint(portText, 10, 16)
	return err == nil && port > 0
}

func parseSpeedTestURL(raw string) (*url.URL, error) {
	if len(raw) > 2048 {
		return nil, errors.New("invalid speed test endpoint")
	}
	u, err := url.Parse(raw)
	if err != nil || u.Hostname() == "" || u.User != nil || u.Fragment != "" || (u.Scheme != "https" && u.Scheme != "http") {
		return nil, errors.New("invalid speed test endpoint")
	}
	return u, nil
}

func prepareSpeedTest(ctx context.Context, r *speedTestRun) (*speedTestTarget, error) {
	client, err := r.transport.newClient("h1")
	if err != nil {
		return nil, err
	}
	defer client.close()
	switch r.params.BackendID {
	case "cloudflare":
		return prepareCloudflareSpeedTest(ctx, client)
	case "apple":
		return prepareAppleSpeedTest(ctx, client)
	case "speedtest":
		return prepareSpeedtestNet(ctx, r, client)
	case "librespeed":
		return prepareLibreSpeedTest(ctx, r.transport, client, r.budget)
	default:
		return nil, errSpeedTestUnavailable
	}
}

func prepareCloudflareSpeedTest(ctx context.Context, client *speedTestClient) (*speedTestTarget, error) {
	body, response, err := fetchSpeedTestMetadata(ctx, client, speedTestCloudflareURL+"/cdn-cgi/trace")
	if err != nil {
		return nil, err
	}
	trace := make(map[string]string)
	for line := range strings.SplitSeq(string(body), "\n") {
		if key, value, ok := strings.Cut(strings.TrimSpace(line), "="); ok {
			trace[key] = value
		}
	}
	if response.Header.Get("cf-ray") == "" || trace["ip"] == "" {
		return nil, errSpeedTestUnavailable
	}
	base, err := parseSpeedTestURL(speedTestCloudflareURL)
	if err != nil {
		return nil, err
	}
	server := SpeedTestServer{
		ID: "cloudflare", Name: "Cloudflare", Host: base.Host,
		Country: strings.ToUpper(trace["loc"]), Sponsor: "Cloudflare",
	}
	if colo := trace["colo"]; colo != "" {
		server.Name += " " + strings.ToUpper(colo)
	}
	if err := validateSpeedTestServer(server); err != nil {
		return nil, err
	}
	return &speedTestTarget{
		backend: "cloudflare", latencyURL: speedTestCloudflareURL + "/__down?bytes=0",
		downloadURL: speedTestCloudflareURL + "/__down", uploadURL: speedTestCloudflareURL + "/__up", server: server,
	}, nil
}

func prepareAppleSpeedTest(ctx context.Context, client *speedTestClient) (*speedTestTarget, error) {
	body, _, err := fetchSpeedTestMetadata(ctx, client, speedTestAppleConfigURL)
	if err != nil {
		return nil, err
	}
	var config struct {
		TestEndpoint string `json:"test_endpoint"`
		URLs         struct {
			Small  string `json:"small_https_download_url"`
			Large  string `json:"large_https_download_url"`
			Upload string `json:"https_upload_url"`
		} `json:"urls"`
	}
	if err := json.Unmarshal(body, &config); err != nil {
		return nil, errSpeedTestUnavailable
	}
	for _, raw := range []string{config.URLs.Large, config.URLs.Upload} {
		u, err := parseSpeedTestURL(raw)
		if err != nil || u.Scheme != "https" {
			return nil, errSpeedTestUnavailable
		}
	}
	latencyURL, method := config.URLs.Small, "GET"
	if latencyURL == "" {
		latencyURL, method = config.URLs.Large, "HEAD"
	}
	if u, err := parseSpeedTestURL(latencyURL); err != nil || u.Scheme != "https" {
		return nil, errSpeedTestUnavailable
	}
	country, colo := speedTestAppleLocation(config.TestEndpoint)
	server := SpeedTestServer{ID: "apple", Name: "Apple", Host: config.TestEndpoint, Country: country, Sponsor: "Apple"}
	if colo != "" {
		server.Name += " " + colo
	}
	if server.Host == "" {
		u, _ := url.Parse(config.URLs.Large)
		server.Host = u.Host
	}
	if err := validateSpeedTestServer(server); err != nil {
		return nil, err
	}
	return &speedTestTarget{
		backend: "apple", latencyURL: latencyURL, latencyMethod: method,
		downloadURL: config.URLs.Large, uploadURL: config.URLs.Upload, server: server,
	}, nil
}

func speedTestAppleLocation(host string) (string, string) {
	label, _, _ := strings.Cut(host, "-")
	if len(label) < 5 {
		return "", ""
	}
	for _, char := range label[:5] {
		if char < 'a' || char > 'z' {
			return "", ""
		}
	}
	return strings.ToUpper(label[:2]), strings.ToUpper(label[2:5])
}

func speedTestNetTarget(server SpeedTestServer) *speedTestTarget {
	base := speedTestServerScheme + "://" + server.Host
	return &speedTestTarget{
		backend: "speedtest", latencyURL: base + "/latency.txt",
		downloadURL: base + "/download", uploadURL: base + "/upload", server: server,
	}
}

func parseSpeedTestServers(body []byte, search string) ([]SpeedTestServer, error) {
	if len(body) > speedTestMaxResponse {
		return nil, errors.New("oversized speed test server list")
	}
	var entries []struct {
		ID      json.RawMessage `json:"id"`
		Host    string          `json:"host"`
		Name    string          `json:"name"`
		Country string          `json:"cc"`
		Sponsor string          `json:"sponsor"`
	}
	if err := json.Unmarshal(body, &entries); err != nil {
		return nil, errSpeedTestUnavailable
	}
	servers := make([]SpeedTestServer, 0, min(len(entries), speedTestMaxServers))
	seen := make(map[string]bool)
	search = strings.ToLower(strings.TrimSpace(search))
	for _, entry := range entries {
		if !validSpeedTestHost(entry.Host) || seen[strings.ToLower(entry.Host)] {
			continue
		}
		server := SpeedTestServer{Host: entry.Host, Name: entry.Name, Country: strings.ToUpper(entry.Country), Sponsor: entry.Sponsor}
		if json.Unmarshal(entry.ID, &server.ID) != nil {
			var number json.Number
			if json.Unmarshal(entry.ID, &number) == nil {
				server.ID = number.String()
			}
		}
		if server.ID == "" {
			server.ID = server.Host
		}
		if validateSpeedTestServer(server) != nil {
			continue
		}
		if search != "" && !strings.Contains(strings.ToLower(strings.Join([]string{server.ID, server.Name, server.Host, server.Country, server.Sponsor}, " ")), search) {
			continue
		}
		seen[strings.ToLower(server.Host)] = true
		servers = append(servers, server)
		if len(servers) == speedTestMaxServers {
			break
		}
	}
	return servers, nil
}

func fetchSpeedTestServers(ctx context.Context, client *speedTestClient, search string) ([]SpeedTestServer, error) {
	u, err := parseSpeedTestURL(speedTestServersURL)
	if err != nil {
		return nil, err
	}
	if search = strings.TrimSpace(search); search != "" {
		query := u.Query()
		query.Set("search", search)
		u.RawQuery = query.Encode()
	}
	body, _, err := fetchSpeedTestMetadata(ctx, client, u.String())
	if err != nil {
		return nil, err
	}
	return parseSpeedTestServers(body, search)
}

func discoverSpeedTestServers(ctx context.Context, transport *speedTestTransport, search string, budget *speedTestBudget) ([]SpeedTestServer, error) {
	client, err := transport.newClient("h1")
	if err != nil {
		return nil, err
	}
	defer client.close()
	servers, err := fetchSpeedTestServers(ctx, client, search)
	if err != nil {
		return nil, err
	}
	targets := make([]*speedTestTarget, 0, len(servers))
	for _, server := range servers {
		targets = append(targets, speedTestNetTarget(server))
	}
	measureSpeedTestTargets(ctx, transport, targets, 1, budget)
	if errors.Is(ctx.Err(), context.Canceled) {
		return nil, ctx.Err()
	}
	for index, target := range targets {
		servers[index] = target.server
	}
	slices.SortStableFunc(servers, func(a, b SpeedTestServer) int {
		if a.LatencyMs == nil && b.LatencyMs == nil {
			return 0
		}
		if a.LatencyMs == nil {
			return 1
		}
		if b.LatencyMs == nil {
			return -1
		}
		if *a.LatencyMs < *b.LatencyMs {
			return -1
		}
		if *a.LatencyMs > *b.LatencyMs {
			return 1
		}
		return 0
	})
	return servers, nil
}

func prepareSpeedtestNet(ctx context.Context, r *speedTestRun, client *speedTestClient) (*speedTestTarget, error) {
	if r.params.Server != nil {
		if !validSpeedTestHost(r.params.Server.Host) {
			return nil, errors.New("invalid Speedtest.net server host")
		}
		target := speedTestNetTarget(*r.params.Server)
		if _, _, err := r.latencyOnce(ctx, client, target); err != nil {
			return nil, err
		}
		return target, nil
	}
	ctx, cancel := context.WithTimeout(ctx, speedTestDiscoveryLimit)
	defer cancel()
	for range 2 {
		servers, err := discoverSpeedTestServers(ctx, r.transport, "", r.budget)
		if err == nil && len(servers) > 0 && servers[0].LatencyMs != nil {
			return speedTestNetTarget(servers[0]), nil
		}
		if ctx.Err() != nil {
			return nil, ctx.Err()
		}
	}
	return nil, errSpeedTestUnavailable
}

func parseLibreSpeedTargets(body []byte) ([]*speedTestTarget, error) {
	if len(body) > speedTestMaxResponse {
		return nil, errors.New("oversized LibreSpeed server list")
	}
	var entries []map[string]json.RawMessage
	if json.Unmarshal(body, &entries) != nil {
		return nil, errSpeedTestUnavailable
	}
	targets := make([]*speedTestTarget, 0, min(len(entries), speedTestMaxServers))
	for _, entry := range entries {
		var name, raw string
		if json.Unmarshal(entry["name"], &name) != nil || json.Unmarshal(entry["server"], &raw) != nil {
			continue
		}
		if strings.HasPrefix(raw, "//") {
			raw = "https:" + raw
		}
		base, err := parseSpeedTestURL(raw)
		if err != nil || len(name) > 512 {
			continue
		}
		if !strings.HasSuffix(base.Path, "/") {
			base.Path += "/"
		}
		endpoint := func(key, fallback string) string {
			path := fallback
			if value, ok := entry[key]; ok && string(value) != "null" {
				if json.Unmarshal(value, &path) != nil {
					return ""
				}
			}
			relative, err := url.Parse(path)
			if err != nil {
				return ""
			}
			resolved := base.ResolveReference(relative).String()
			if _, err := parseSpeedTestURL(resolved); err != nil {
				return ""
			}
			return resolved
		}
		target := &speedTestTarget{
			backend: "librespeed", latencyURL: endpoint("pingURL", "empty.php"),
			downloadURL: endpoint("dlURL", "garbage.php"), uploadURL: endpoint("ulURL", "empty.php"),
			server: SpeedTestServer{ID: base.String(), Name: name, Host: base.Host, Sponsor: "LibreSpeed"},
		}
		if target.latencyURL != "" && target.downloadURL != "" && target.uploadURL != "" {
			targets = append(targets, target)
		}
		if len(targets) == speedTestMaxServers {
			break
		}
	}
	if len(targets) == 0 {
		return nil, errSpeedTestUnavailable
	}
	return targets, nil
}

func prepareLibreSpeedTest(ctx context.Context, transport *speedTestTransport, client *speedTestClient, budget *speedTestBudget) (*speedTestTarget, error) {
	ctx, cancel := context.WithTimeout(ctx, speedTestDiscoveryLimit)
	defer cancel()
	body, _, err := fetchSpeedTestMetadata(ctx, client, speedTestLibreListURL)
	if err != nil {
		return nil, err
	}
	targets, err := parseLibreSpeedTargets(body)
	if err != nil {
		return nil, err
	}
	measureSpeedTestTargets(ctx, transport, targets, 3, budget)
	var best *speedTestTarget
	for _, target := range targets {
		if target.server.LatencyMs != nil && (best == nil || *target.server.LatencyMs < *best.server.LatencyMs) {
			best = target
		}
	}
	if best == nil {
		return nil, errSpeedTestUnavailable
	}
	return best, nil
}

func measureSpeedTestTargets(ctx context.Context, transport *speedTestTransport, targets []*speedTestTarget, rounds int, budget *speedTestBudget) {
	var index atomic.Int32
	var workers sync.WaitGroup
	for range min(8, len(targets)) {
		workers.Add(1)
		safeGo("speedTestServerLatency", func() {
			defer workers.Done()
			client, err := transport.newClient("h1")
			if err != nil {
				return
			}
			defer client.close()
			for ctx.Err() == nil {
				i := int(index.Add(1)) - 1
				if i >= len(targets) {
					return
				}
				target := targets[i]
				for round := range rounds {
					rtt, _, err := speedTestPing(ctx, client, target, budget)
					if err != nil {
						break
					}
					if rounds > 1 && round == 0 {
						continue
					}
					value := math.Max(rtt, .001)
					if target.server.LatencyMs == nil || value < *target.server.LatencyMs {
						target.server.LatencyMs = &value
					}
				}
			}
		})
	}
	workers.Wait()
}
