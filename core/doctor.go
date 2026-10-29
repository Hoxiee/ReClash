package core

import (
	"context"
	"crypto/tls"
	"crypto/x509"
	"errors"
	"fmt"
	"io"
	"net"
	"net/netip"
	"net/url"
	"strings"
	"syscall"
	"time"

	"github.com/metacubex/http"
	"github.com/metacubex/mihomo/component/dialer"
	"github.com/metacubex/mihomo/component/resolver"
	"github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/tunnel"
)

type failureCause string

const (
	causeServerDns    failureCause = "serverDns"
	causeRefused      failureCause = "refused"
	causeTimeout      failureCause = "timeout"
	causeReset        failureCause = "reset"
	causeTlsHandshake failureCause = "tlsHandshake"
	causeAuthRejected failureCause = "authRejected"
	causeUdpBlocked   failureCause = "udpBlocked"
	causeNoUpstream   failureCause = "noUpstream"
	causeUnknown      failureCause = "unknown"
)

// Mihomo reports these only as text, so they are matched in order: the
// specific authentication messages come before the generic TLS prefixes.
var failureMessages = []struct {
	fragment string
	cause    failureCause
}{
	{"reality authentication failed", causeAuthRejected},
	{"rejected username/password", causeAuthRejected},
	{"auth failed", causeAuthRejected},
	{"udp is not supported", causeUdpBlocked},
	{"not support udp", causeUdpBlocked},
	{"couldn't find ip", causeServerDns},
	{"dns resolve failed", causeServerDns},
	{"no route to host", causeNoUpstream},
	{"network is unreachable", causeNoUpstream},
	{"tls:", causeTlsHandshake},
	{"x509:", causeTlsHandshake},
}

func classifyFailure(err error) failureCause {
	if err == nil {
		return ""
	}
	var netErr net.Error
	if errors.Is(err, context.DeadlineExceeded) || (errors.As(err, &netErr) && netErr.Timeout()) {
		return causeTimeout
	}
	var dnsErr *net.DNSError
	if errors.As(err, &dnsErr) {
		return causeServerDns
	}
	switch {
	case errors.Is(err, syscall.ECONNREFUSED):
		return causeRefused
	case errors.Is(err, syscall.ECONNRESET), errors.Is(err, syscall.EPIPE), errors.Is(err, io.ErrUnexpectedEOF):
		return causeReset
	case errors.Is(err, syscall.ENETUNREACH), errors.Is(err, syscall.EHOSTUNREACH):
		return causeNoUpstream
	}
	var (
		recordErr   tls.RecordHeaderError
		alertErr    tls.AlertError
		verifyErr   *tls.CertificateVerificationError
		unknownAuth x509.UnknownAuthorityError
		hostErr     x509.HostnameError
		invalidErr  x509.CertificateInvalidError
	)
	if errors.As(err, &recordErr) || errors.As(err, &alertErr) || errors.As(err, &verifyErr) ||
		errors.As(err, &unknownAuth) || errors.As(err, &hostErr) || errors.As(err, &invalidErr) {
		return causeTlsHandshake
	}
	message := strings.ToLower(err.Error())
	for _, entry := range failureMessages {
		if strings.Contains(message, entry.fragment) {
			return entry.cause
		}
	}
	return causeUnknown
}

func handleClockSkew(params *ClockSkewParams) *ClockSkewResult {
	before := time.Now()
	probe := runProbe(context.Background(), probeRequest{
		method:     http.MethodHead,
		url:        params.Url,
		proxyName:  params.ProxyName,
		timeout:    timeoutFromMillis(params.Timeout, defaultProbeTimeout),
		noRedirect: true,
	})
	after := time.Now()
	if probe == nil {
		return nil
	}
	result := &ClockSkewResult{Delay: probe.Delay, Url: probe.Url}
	if probe.Error != "" {
		result.Cause = probe.Cause
		result.Message = probe.Message
		return result
	}
	skew, server, err := clockSkewFrom(probe.header, before, after)
	if err != nil {
		result.Cause = string(causeUnknown)
		result.Message = err.Error()
		return result
	}
	result.SkewMs = skew
	result.ServerTime = server
	return result
}

// The Date header has one second resolution, so the server second is taken
// at its middle.
func clockSkewFrom(header http.Header, before, after time.Time) (skewMs, serverMs int64, err error) {
	date := header.Get("Date")
	if date == "" {
		return 0, 0, errors.New("no Date header")
	}
	server, err := http.ParseTime(date)
	if err != nil {
		return 0, 0, errors.New("no Date header")
	}
	reference := before.Add(after.Sub(before) / 2)
	serverMs = server.UnixMilli()
	return reference.UnixMilli() - (serverMs + 500), serverMs, nil
}

const (
	reachDns       = "dns"
	reachRoute     = "route"
	reachResolve   = "resolve"
	reachTcp       = "tcp"
	reachHandshake = "handshake"
	reachDone      = "done"
)

var errReachUnknownProxy = errors.New("proxy is not part of the applied config")

type reachSteps struct {
	resolveHost func(ctx context.Context, host string) (netip.Addr, error)
	pickNode    func(ctx context.Context, metadata *constant.Metadata) (node constant.Proxy, direct bool, err error)
	resolveNode func(ctx context.Context, host string) (netip.Addr, error)
	dialTCP     func(ctx context.Context, address string) (net.Conn, error)
	handshake   func(ctx context.Context, node constant.Proxy, metadata *constant.Metadata) (net.Conn, error)
}

func (s reachSteps) run(ctx context.Context, rawUrl string) *ReachResult {
	result := &ReachResult{Stage: reachDns}
	fail := func(err error) *ReachResult {
		result.Cause = string(classifyFailure(err))
		result.Message = err.Error()
		return result
	}
	elapsed := func(since time.Time) int64 { return time.Since(since).Milliseconds() }

	host, port, err := reachTarget(rawUrl)
	if err != nil {
		return fail(err)
	}
	address := net.JoinHostPort(host, port)
	if _, err = netip.ParseAddr(host); err != nil {
		start := time.Now()
		_, err = s.resolveHost(ctx, host)
		result.DnsMs = elapsed(start)
		if err != nil {
			return fail(err)
		}
	}

	result.Stage = reachRoute
	metadata, err := probeMetadata(address)
	if err != nil {
		return fail(err)
	}
	node, direct, err := s.pickNode(ctx, metadata)
	if errors.Is(err, errReachUnknownProxy) {
		result.Cause = string(causeNoUpstream)
		result.Message = err.Error()
		return result
	}
	if err != nil {
		return fail(err)
	}
	if direct {
		result.Direct = true
		result.Stage = reachDone
		return result
	}
	result.Proxy = node.Name()
	result.Server = node.Addr()
	serverHost, serverPort, err := net.SplitHostPort(result.Server)
	if err != nil {
		return fail(err)
	}

	result.Stage = reachResolve
	serverIp, err := netip.ParseAddr(serverHost)
	if err != nil {
		start := time.Now()
		serverIp, err = s.resolveNode(ctx, serverHost)
		result.ResolveMs = elapsed(start)
		if err != nil {
			result.Cause = string(causeServerDns)
			result.Message = err.Error()
			return result
		}
	}

	result.Stage = reachTcp
	start := time.Now()
	conn, err := s.dialTCP(ctx, net.JoinHostPort(serverIp.String(), serverPort))
	result.TcpMs = elapsed(start)
	if err != nil {
		return fail(err)
	}
	_ = conn.Close()

	result.Stage = reachHandshake
	start = time.Now()
	conn, err = s.handshake(ctx, node, metadata)
	result.HandshakeMs = elapsed(start)
	if err != nil {
		return fail(err)
	}
	_ = conn.Close()

	result.Stage = reachDone
	return result
}

func reachTarget(rawUrl string) (host, port string, err error) {
	parsed, err := url.Parse(rawUrl)
	if err != nil {
		return "", "", err
	}
	host, port = parsed.Hostname(), parsed.Port()
	if host == "" {
		return "", "", fmt.Errorf("no host in %q", rawUrl)
	}
	if port == "" {
		port = "80"
		if parsed.Scheme == "https" {
			port = "443"
		}
	}
	return host, port, nil
}

// Groups are followed down to the node that would dial out.
func reachLeaf(proxy constant.Proxy, metadata *constant.Metadata) (node constant.Proxy, direct bool) {
	for {
		next := proxy.Unwrap(metadata, false)
		if next == nil {
			break
		}
		proxy = next
	}
	switch proxy.Type() {
	case constant.Direct, constant.Reject, constant.RejectDrop, constant.Pass:
		return proxy, true
	}
	return proxy, proxy.Addr() == ""
}

func handleReach(params *ReachParams) *ReachResult {
	timeout := timeoutFromMillis(params.Timeout, defaultProbeTimeout)
	if !probeSlots.acquireWithin(context.Background(), timeout) {
		return nil
	}
	defer probeSlots.release()
	epoch, version := routeStamp()
	ctx, cancel := context.WithTimeout(context.Background(), timeout)
	defer cancel()

	steps := reachSteps{
		resolveHost: resolver.ResolveIP,
		pickNode: func(_ context.Context, metadata *constant.Metadata) (constant.Proxy, bool, error) {
			var proxy constant.Proxy
			if params.ProxyName != "" {
				if proxy = lookupProxy(params.ProxyName); proxy == nil {
					return nil, false, errReachUnknownProxy
				}
			} else {
				var err error
				if proxy, err = tunnel.ResolveRoute(metadata); err != nil {
					return nil, false, err
				}
			}
			node, direct := reachLeaf(proxy, metadata)
			return node, direct, nil
		},
		resolveNode: func(ctx context.Context, host string) (netip.Addr, error) {
			if resolver.ProxyServerHostResolver == nil {
				return resolver.ResolveIP(ctx, host)
			}
			return resolver.ResolveIPWithResolver(ctx, host, resolver.ProxyServerHostResolver)
		},
		dialTCP: func(ctx context.Context, address string) (net.Conn, error) {
			return dialer.DialContext(ctx, "tcp", address)
		},
		handshake: func(ctx context.Context, node constant.Proxy, metadata *constant.Metadata) (net.Conn, error) {
			return node.DialContext(ctx, metadata)
		},
	}
	result := steps.run(ctx, params.Url)
	result.CoreEpoch, result.RouteVersion = epoch, version
	result.Hits = []RouteHit{}
	if host, port, err := reachTarget(params.Url); err == nil {
		address := net.JoinHostPort(host, port)
		result.Hits = []RouteHit{{Host: address, Proxy: params.ProxyName, Exit: resolveExit(address, params.ProxyName)}}
	}
	return result
}
