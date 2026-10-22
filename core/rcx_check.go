package core

import (
	"bufio"
	"bytes"
	"context"
	"crypto/tls"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net"
	"net/netip"
	"net/url"
	"os"
	"slices"
	"strings"
	"sync"
	"time"

	"core/rcx"

	"github.com/metacubex/http"
	"github.com/metacubex/mihomo/component/ca"
	"github.com/metacubex/mihomo/component/mmdb"
	"github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/tunnel"
)

const (
	rcxEchoBodyLimit = 4 << 10
	rcxDirectName    = "DIRECT"
)

// Checks dial through the adapter itself, not the hooked proxy: a site the
// node cannot reach is a fact about the site, never a failed dial of the node.
func rcxDialer(proxy constant.Proxy) func(ctx context.Context, address string) (net.Conn, error) {
	return func(ctx context.Context, address string) (net.Conn, error) {
		metadata := &constant.Metadata{NetWork: constant.TCP, Type: constant.INNER, DNSMode: constant.DNSNormal, Process: constant.MihomoName}
		if err := metadata.SetRemoteAddress(address); err != nil {
			return nil, err
		}
		return proxy.Adapter().DialContext(ctx, metadata)
	}
}

func (rcxProber) Check(ctx context.Context, node string, check rcx.Check) error {
	proxy := lookupProxy(node)
	if proxy == nil {
		return errors.New("proxy not found")
	}
	return rcxReach(ctx, rcxDialer(proxy), check)
}

// Diagnose goes out the way DIRECT traffic does, with its interface and
// routing options, so it sees the network as the user's direct rules do.
func (rcxProber) Diagnose(ctx context.Context, target rcx.Target) error {
	direct := tunnel.AllProxies()[rcxDirectName]
	if direct == nil {
		return errors.New("no DIRECT outbound")
	}
	check := rcx.Check{}
	switch target.Kind {
	case "http":
		check.HTTP = target.Addr
	case "tls":
		check.TLS = target.Addr
	default:
		check.TCP = target.Addr
	}
	return rcxReach(ctx, rcxDialer(direct), check)
}

func rcxReach(ctx context.Context, dial func(context.Context, string) (net.Conn, error), check rcx.Check) error {
	switch {
	case check.HTTP != "":
		status, _, err := rcxFetch(ctx, dial, http.MethodHead, check.HTTP, 0)
		if err != nil {
			return err
		}
		if len(check.Expect) > 0 && !slices.Contains(check.Expect, status) {
			return fmt.Errorf("status %d", status)
		}
		return nil
	case check.TLS != "":
		conn, err := dial(ctx, check.TLS)
		if err != nil {
			return err
		}
		defer conn.Close()
		host, _, _ := net.SplitHostPort(check.TLS)
		sni := check.SNI
		if sni == "" && net.ParseIP(host) == nil {
			sni = host
		}
		// Reachability only: an IP endpoint has no name to verify against.
		client := tls.Client(conn, &tls.Config{ServerName: sni, InsecureSkipVerify: true})
		return client.HandshakeContext(ctx)
	default:
		conn, err := dial(ctx, check.TCP)
		if err != nil {
			return err
		}
		return conn.Close()
	}
}

func rcxFetch(ctx context.Context, dial func(context.Context, string) (net.Conn, error), method, rawURL string, limit int64) (int, []byte, error) {
	tlsConfig, err := ca.GetTLSConfig(ca.Option{})
	if err != nil {
		return 0, nil, err
	}
	transport := &http.Transport{
		DialContext:       func(ctx context.Context, _, address string) (net.Conn, error) { return dial(ctx, address) },
		TLSClientConfig:   tlsConfig,
		DisableKeepAlives: true,
	}
	defer transport.CloseIdleConnections()
	client := http.Client{
		Transport:     transport,
		CheckRedirect: func(*http.Request, []*http.Request) error { return http.ErrUseLastResponse },
	}
	req, err := http.NewRequestWithContext(ctx, method, rawURL, nil)
	if err != nil {
		return 0, nil, err
	}
	resp, err := client.Do(req)
	if err != nil {
		return 0, nil, err
	}
	defer resp.Body.Close()
	body, err := io.ReadAll(io.LimitReader(resp.Body, limit))
	return resp.StatusCode, body, err
}

// Exit asks echo services through the node, one at a time, until the votes
// settle: each answer is one vote, and the GeoIP database is another for the
// address it reports.
func (rcxProber) Exit(ctx context.Context, node string, egress rcx.Egress) ([]rcx.ExitVote, int, error) {
	proxy := lookupProxy(node)
	if proxy == nil {
		return nil, 0, errors.New("proxy not found")
	}
	geo := rcxGeo()
	var votes []rcx.ExitVote
	requests := 0
	for _, echo := range egress.Echo {
		if ctx.Err() != nil {
			break
		}
		requests++
		_, body, err := rcxFetch(ctx, rcxDialer(proxy), http.MethodGet, echo, rcxEchoBodyLimit)
		if err != nil {
			continue
		}
		ip, country := rcxParseEcho(body)
		if country != "" {
			source := echo
			if u, err := url.Parse(echo); err == nil {
				source = u.Host
			}
			votes = append(votes, rcx.ExitVote{Source: source, Country: country})
		}
		if code := geo(ip); code != "" && !slices.ContainsFunc(votes, func(v rcx.ExitVote) bool { return v.Source == "mmdb" }) {
			votes = append(votes, rcx.ExitVote{Source: "mmdb", Country: code})
		}
		if rcxVotesSettled(votes, egress.Agree) {
			break
		}
	}
	return votes, requests, nil
}

// Votes are settled once enough agree, or once two disagree: no further echo
// can make a split verdict trustworthy.
func rcxVotesSettled(votes []rcx.ExitVote, agree int) bool {
	seen := map[string]int{}
	for _, v := range votes {
		seen[strings.ToUpper(v.Country)]++
	}
	if len(seen) > 1 {
		return true
	}
	for _, n := range seen {
		return n >= max(agree, 1)
	}
	return false
}

// rcxParseEcho reads the common echo formats: Cloudflare's key=value trace,
// a JSON object, or a bare address.
func rcxParseEcho(body []byte) (ip netip.Addr, country string) {
	var object map[string]any
	if json.Unmarshal(body, &object) == nil {
		for _, key := range []string{"ip", "query", "ip_addr"} {
			if text, ok := object[key].(string); ok {
				ip, _ = netip.ParseAddr(text)
				break
			}
		}
		for _, key := range []string{"country_code", "countryCode", "country"} {
			if text, ok := object[key].(string); ok && len(text) == 2 {
				return ip, text
			}
		}
		return ip, ""
	}
	if addr, err := netip.ParseAddr(string(bytes.TrimSpace(body))); err == nil {
		return addr, ""
	}
	scanner := bufio.NewScanner(bytes.NewReader(body))
	for scanner.Scan() {
		key, value, _ := strings.Cut(scanner.Text(), "=")
		switch key {
		case "ip":
			ip, _ = netip.ParseAddr(value)
		case "loc":
			country = value
		}
	}
	return ip, country
}

var rcxGeoCache struct {
	sync.Mutex
	path    string
	modTime time.Time
	ok      bool
}

// rcxGeo looks a country up in the installed GeoIP database. mihomo exits the
// process on a database it cannot open, so the file is verified first and
// the verdict cached until it changes.
func rcxGeo() func(netip.Addr) string {
	path := constant.Path.MMDB()
	info, err := os.Stat(path)
	if err != nil {
		return func(netip.Addr) string { return "" }
	}
	rcxGeoCache.Lock()
	if rcxGeoCache.path != path || !rcxGeoCache.modTime.Equal(info.ModTime()) {
		rcxGeoCache.path, rcxGeoCache.modTime, rcxGeoCache.ok = path, info.ModTime(), mmdb.Verify(path)
	}
	ok := rcxGeoCache.ok
	rcxGeoCache.Unlock()
	if !ok {
		return func(netip.Addr) string { return "" }
	}
	reader := mmdb.IPInstance()
	return func(ip netip.Addr) string {
		if !ip.IsValid() {
			return ""
		}
		for _, code := range reader.LookupCode(ip.AsSlice()) {
			if len(code) == 2 {
				return strings.ToUpper(code)
			}
		}
		return ""
	}
}
