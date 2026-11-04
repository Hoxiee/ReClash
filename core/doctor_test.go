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
	"os"
	"syscall"
	"testing"
	"time"

	"github.com/metacubex/http"
	"github.com/metacubex/mihomo/constant"
)

func TestClassifyFailure(t *testing.T) {
	cases := []struct {
		name string
		err  error
		want failureCause
	}{
		{"nil", nil, ""},
		{"deadline", fmt.Errorf("dial: %w", context.DeadlineExceeded), causeTimeout},
		{"net timeout", &net.OpError{Err: os.ErrDeadlineExceeded}, causeTimeout},
		{"dns", &net.DNSError{Err: "no such host", Name: "x.example"}, causeServerDns},
		{"refused", &net.OpError{Err: os.NewSyscallError("connect", syscall.ECONNREFUSED)}, causeRefused},
		{"reset", fmt.Errorf("read: %w", syscall.ECONNRESET), causeReset},
		{"pipe", syscall.EPIPE, causeReset},
		{"unexpected eof", fmt.Errorf("x: %w", io.ErrUnexpectedEOF), causeReset},
		{"net unreachable", &net.OpError{Err: os.NewSyscallError("connect", syscall.ENETUNREACH)}, causeNoUpstream},
		{"host unreachable", syscall.EHOSTUNREACH, causeNoUpstream},
		{"record header", tls.RecordHeaderError{Msg: "bad"}, causeTlsHandshake},
		{"unknown authority", fmt.Errorf("get: %w", x509.UnknownAuthorityError{}), causeTlsHandshake},
		{"tls text", errors.New("tls: handshake failure"), causeTlsHandshake},
		{"x509 text", errors.New("x509: certificate has expired"), causeTlsHandshake},
		{"reality", fmt.Errorf("dial: %w", errors.New("REALITY authentication failed")), causeAuthRejected},
		{"socks auth", errors.New("rejected username/password"), causeAuthRejected},
		{"auth failed", errors.New("auth failed"), causeAuthRejected},
		{"udp", errors.New("proxy adapter [a] UDP is not supported"), causeUdpBlocked},
		{"snell udp", errors.New("snell version 1 not support UDP"), causeUdpBlocked},
		{"no ip", errors.New("couldn't find ip"), causeServerDns},
		{"dns resolve", errors.New("dns resolve failed: boom"), causeServerDns},
		{"no route", errors.New("connect: No route to host"), causeNoUpstream},
		{"unreachable text", errors.New("network is unreachable"), causeNoUpstream},
		{"port in use", errors.New("listen tcp 127.0.0.1:7890: bind: address already in use"), causePortTaken},
		{"windows port in use", errors.New("bind: Only one usage of each socket address (protocol/network address/port) is normally permitted."), causePortTaken},
		{"wintun name taken", errors.New("create wintun adapter: Cannot create a file when that file already exists."), causeTunnelTaken},
		{"firewall", errors.New("connectex: An attempt was made to access a socket in a way forbidden by its access permissions."), causeCoreBlocked},
		{"unknown", errors.New("something odd"), causeUnknown},
	}
	for _, c := range cases {
		t.Run(c.name, func(t *testing.T) {
			if got := classifyFailure(c.err); got != c.want {
				t.Fatalf("classifyFailure(%v) = %q, want %q", c.err, got, c.want)
			}
		})
	}
}

func TestClockSkewFrom(t *testing.T) {
	server := time.Date(2026, 1, 2, 3, 4, 5, 0, time.UTC)
	header := http.Header{}
	header.Set("Date", server.Format(http.TimeFormat))
	at := func(offset time.Duration) time.Time { return server.Add(offset) }

	skew, serverMs, err := clockSkewFrom(header, at(time.Hour), at(time.Hour+200*time.Millisecond))
	if err != nil {
		t.Fatal(err)
	}
	if serverMs != server.UnixMilli() || skew != time.Hour.Milliseconds()-400 {
		t.Fatalf("ahead: skew %d server %d", skew, serverMs)
	}

	skew, _, err = clockSkewFrom(header, at(-time.Hour), at(-time.Hour))
	if err != nil || skew != -time.Hour.Milliseconds()-500 {
		t.Fatalf("behind: skew %d err %v", skew, err)
	}

	if _, _, err = clockSkewFrom(http.Header{}, at(0), at(0)); err == nil {
		t.Fatal("missing header must fail")
	}
	header.Set("Date", "garbage")
	if _, _, err = clockSkewFrom(header, at(0), at(0)); err == nil {
		t.Fatal("bad header must fail")
	}
}

type fakeNode struct {
	constant.Proxy
	name, addr string
}

func (n fakeNode) Name() string { return n.name }
func (n fakeNode) Addr() string { return n.addr }
func (n fakeNode) Type() constant.AdapterType {
	return constant.Vless
}

func reachFakes(node constant.Proxy) reachSteps {
	ip := netip.MustParseAddr("192.0.2.1")
	return reachSteps{
		resolveHost: func(context.Context, string) (netip.Addr, error) { return ip, nil },
		pickNode: func(context.Context, *constant.Metadata) (constant.Proxy, bool, error) {
			return node, false, nil
		},
		resolveNode: func(context.Context, string) (netip.Addr, error) { return ip, nil },
		dialTCP: func(context.Context, string) (net.Conn, error) {
			client, server := net.Pipe()
			_ = server.Close()
			return client, nil
		},
		handshake: func(context.Context, constant.Proxy, *constant.Metadata) (net.Conn, error) {
			client, server := net.Pipe()
			_ = server.Close()
			return client, nil
		},
	}
}

func TestReachRun(t *testing.T) {
	node := fakeNode{name: "hk", addr: "node.example:8443"}
	listener, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatal(err)
	}
	closed := listener.Addr().String()
	_ = listener.Close()

	cases := []struct {
		name      string
		change    func(*reachSteps)
		stage     string
		cause     failureCause
		direct    bool
		wantProxy string
	}{
		{"dns", func(s *reachSteps) {
			s.resolveHost = func(context.Context, string) (netip.Addr, error) {
				return netip.Addr{}, &net.DNSError{Err: "no such host", Name: "x"}
			}
		}, reachDns, causeServerDns, false, ""},
		{"unknown proxy", func(s *reachSteps) {
			s.pickNode = func(context.Context, *constant.Metadata) (constant.Proxy, bool, error) {
				return nil, false, fmt.Errorf("hk: %w", errReachUnknownProxy)
			}
		}, reachRoute, causeNoUpstream, false, ""},
		{"direct", func(s *reachSteps) {
			s.pickNode = func(context.Context, *constant.Metadata) (constant.Proxy, bool, error) {
				return nil, true, nil
			}
		}, reachDone, "", true, ""},
		{"node dns", func(s *reachSteps) {
			s.resolveNode = func(context.Context, string) (netip.Addr, error) {
				return netip.Addr{}, errors.New("boom")
			}
		}, reachResolve, causeServerDns, false, "hk"},
		{"refused", func(s *reachSteps) {
			s.dialTCP = func(ctx context.Context, _ string) (net.Conn, error) {
				return (&net.Dialer{}).DialContext(ctx, "tcp", closed)
			}
		}, reachTcp, causeRefused, false, "hk"},
		{"tcp timeout", func(s *reachSteps) {
			s.dialTCP = func(context.Context, string) (net.Conn, error) {
				return nil, fmt.Errorf("dial: %w", context.DeadlineExceeded)
			}
		}, reachTcp, causeTimeout, false, "hk"},
		{"handshake timeout", func(s *reachSteps) {
			s.handshake = func(ctx context.Context, _ constant.Proxy, _ *constant.Metadata) (net.Conn, error) {
				<-ctx.Done()
				return nil, ctx.Err()
			}
		}, reachHandshake, causeTimeout, false, "hk"},
		{"reality", func(s *reachSteps) {
			s.handshake = func(context.Context, constant.Proxy, *constant.Metadata) (net.Conn, error) {
				return nil, errors.New("REALITY authentication failed")
			}
		}, reachHandshake, causeAuthRejected, false, "hk"},
		{"success", func(*reachSteps) {}, reachDone, "", false, "hk"},
	}
	for _, c := range cases {
		t.Run(c.name, func(t *testing.T) {
			steps := reachFakes(node)
			c.change(&steps)
			ctx, cancel := context.WithTimeout(context.Background(), 50*time.Millisecond)
			defer cancel()
			got := steps.run(ctx, "https://example.com/path")
			if got.Stage != c.stage || got.Cause != string(c.cause) || got.Direct != c.direct || got.Proxy != c.wantProxy {
				t.Fatalf("got stage %q cause %q direct %v proxy %q", got.Stage, got.Cause, got.Direct, got.Proxy)
			}
			if c.cause == "" && got.Message != "" || c.cause != "" && got.Message == "" {
				t.Fatalf("message %q for cause %q", got.Message, got.Cause)
			}
			if got.DnsMs < 0 || got.ResolveMs < 0 || got.TcpMs < 0 || got.HandshakeMs < 0 {
				t.Fatalf("negative timing %+v", got)
			}
		})
	}
}

func TestReachTarget(t *testing.T) {
	for raw, want := range map[string]string{
		"https://example.com/x": "example.com:443",
		"http://example.com":    "example.com:80",
		"http://[::1]:8080/":    "[::1]:8080",
	} {
		host, port, err := reachTarget(raw)
		if err != nil || net.JoinHostPort(host, port) != want {
			t.Fatalf("%s: %s:%s %v", raw, host, port, err)
		}
	}
	if _, _, err := reachTarget("nothing"); err == nil {
		t.Fatal("missing host must fail")
	}
}

func dialFakes(dialed *string) dialSteps {
	pipe := func() (net.Conn, error) {
		client, server := net.Pipe()
		_ = server.Close()
		return client, nil
	}
	return dialSteps{
		resolve: func(context.Context, string) (netip.Addr, error) {
			return netip.MustParseAddr("192.0.2.1"), nil
		},
		dialTCP: func(_ context.Context, address string) (net.Conn, error) {
			*dialed = address
			return pipe()
		},
		handshake: func(context.Context) (net.Conn, error) { return pipe() },
	}
}

func TestDialStepsRun(t *testing.T) {
	listener, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatal(err)
	}
	closed := listener.Addr().String()
	_ = listener.Close()

	cases := []struct {
		name   string
		server string
		change func(*dialSteps)
		stage  string
		cause  failureCause
		dialed string
	}{
		{"dns", "node.example:443", func(s *dialSteps) {
			s.resolve = func(context.Context, string) (netip.Addr, error) {
				return netip.Addr{}, errors.New("no answer")
			}
		}, reachResolve, causeServerDns, ""},
		{"refused", "node.example:443", func(s *dialSteps) {
			s.dialTCP = func(ctx context.Context, _ string) (net.Conn, error) {
				return (&net.Dialer{}).DialContext(ctx, "tcp", closed)
			}
		}, reachTcp, causeRefused, ""},
		{"tcp timeout", "node.example:443", func(s *dialSteps) {
			s.dialTCP = func(ctx context.Context, _ string) (net.Conn, error) {
				<-ctx.Done()
				return nil, ctx.Err()
			}
		}, reachTcp, causeTimeout, ""},
		{"tls", "node.example:443", func(s *dialSteps) {
			s.handshake = func(context.Context) (net.Conn, error) {
				return nil, errors.New("tls: handshake failure")
			}
		}, reachHandshake, causeTlsHandshake, "192.0.2.1:443"},
		{"auth", "node.example:443", func(s *dialSteps) {
			s.handshake = func(context.Context) (net.Conn, error) {
				return nil, errors.New("REALITY authentication failed")
			}
		}, reachHandshake, causeAuthRejected, "192.0.2.1:443"},
		{"ip server skips resolve", "198.51.100.7:8443", func(s *dialSteps) {
			s.resolve = func(context.Context, string) (netip.Addr, error) {
				t.Fatal("an IP server must not be resolved")
				return netip.Addr{}, nil
			}
		}, reachDone, "", "198.51.100.7:8443"},
		{"success", "node.example:443", func(*dialSteps) {}, reachDone, "", "192.0.2.1:443"},
	}
	for _, c := range cases {
		t.Run(c.name, func(t *testing.T) {
			var dialed string
			steps := dialFakes(&dialed)
			c.change(&steps)
			ctx, cancel := context.WithTimeout(context.Background(), 50*time.Millisecond)
			defer cancel()
			got := steps.run(ctx, c.server)
			if got.Stage != c.stage || got.Cause != string(c.cause) {
				t.Fatalf("got stage %q cause %q (%s)", got.Stage, got.Cause, got.Message)
			}
			if c.dialed != "" && dialed != c.dialed {
				t.Fatalf("dialed %q, want %q", dialed, c.dialed)
			}
			host, port, _ := net.SplitHostPort(c.server)
			if got.Server != host || fmt.Sprint(got.Port) != port {
				t.Fatalf("server %q port %d", got.Server, got.Port)
			}
			if got.ResolveMs < 0 || got.TcpMs < 0 || got.HandshakeMs < 0 {
				t.Fatalf("negative timing %+v", got)
			}
		})
	}
}

func TestHandleDialDirectLeavesAnUnknownNodeWithoutServer(t *testing.T) {
	got := handleDialDirect(&DialDirectParams{ProxyName: "no such node", Timeout: 50})
	if got.Server != "" || got.Stage != "" || got.Cause != "" {
		t.Fatalf("got %+v", got)
	}
}
