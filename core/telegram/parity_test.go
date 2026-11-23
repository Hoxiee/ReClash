package telegram

import (
	"bytes"
	"context"
	"io"
	"net"
	"strings"
	"testing"
	"time"
)

func TestWorkerCarriesTheDCAndTargetInThePath(t *testing.T) {
	server := newFakeTelegram(t, "worker.example.org")
	relay := startRelay(t, Config{
		Endpoints:       []string{closedAddress(t)},
		CFWorkerDomains: []string{"worker.example.org"},
		TLS:             server.tls(),
		Dial:            routeDial(map[string]string{"worker.example.org:443": server.address()}),
	})
	if err := selfTest(t, relay, 2); err != nil {
		t.Fatal(err)
	}
	if status := dcStatus(relay, 2); status.Route != RouteCloudflareWorker {
		t.Fatalf("status %+v", status)
	}
	paths := server.seenPaths()
	if len(paths) != 1 || paths[0] != "/apiws?dst=149.154.167.51&dc=2" {
		t.Fatalf("paths %v", paths)
	}
}

func TestPerDCTargetOverridesTheBuiltInAddress(t *testing.T) {
	server := newFakeTelegram(t)
	target := server.address()
	relay := startRelay(t, Config{
		Endpoints: []string{closedAddress(t)},
		Targets:   map[int]string{2: target},
		TLS:       server.tls(),
		Dial:      routeDial(map[string]string{target: server.address()}),
	})
	if err := selfTest(t, relay, 2); err != nil {
		t.Fatal(err)
	}
	if hosts := server.seenHosts(); len(hosts) == 0 || hosts[0] != "kws2.web.telegram.org" {
		t.Fatalf("hosts %v", hosts)
	}
}

func TestTestDCUsesTestAddressAndPath(t *testing.T) {
	server := newFakeTelegram(t)
	relay := startRelay(t, Config{
		Endpoints: []string{closedAddress(t)},
		TLS:       server.tls(),
		Dial:      routeDial(map[string]string{"149.154.167.40:443": server.address()}),
	})
	if err := selfTest(t, relay, 10002); err != nil {
		t.Fatal(err)
	}
	if paths := server.seenPaths(); len(paths) != 1 || paths[0] != "/apiws_test" {
		t.Fatalf("paths %v", paths)
	}
	if hosts := server.seenHosts(); len(hosts) == 0 || hosts[0] != "kws2.web.telegram.org" {
		t.Fatalf("hosts %v", hosts)
	}
	server.mu.Lock()
	defer server.mu.Unlock()
	if len(server.headers) != 1 || server.headers[0] != 2 {
		t.Fatalf("headers %v", server.headers)
	}
}

func TestHTTPOnTheProxyPortGets404(t *testing.T) {
	relay := startRelay(t, Config{})
	conn, err := net.Dial("tcp", relay.testAddress())
	if err != nil {
		t.Fatal(err)
	}
	defer conn.Close()
	request := bytes.Repeat([]byte{'a'}, headerSize)
	copy(request, "GET / HTTP/1.1\r\n")
	if _, err := conn.Write(request); err != nil {
		t.Fatal(err)
	}
	_ = conn.SetReadDeadline(time.Now().Add(2 * time.Second))
	reply, _ := io.ReadAll(conn)
	if !strings.HasPrefix(string(reply), "HTTP/1.1 404") {
		t.Fatalf("reply %q", reply)
	}
	if status := relay.Status(); status.HTTPRejects != 1 {
		t.Fatalf("http rejects %d", status.HTTPRejects)
	}
}

func TestProxyProtocolLineIsSkipped(t *testing.T) {
	server := newFakeTelegram(t)
	relay := startRelay(t, Config{Endpoints: []string{server.address()}, TLS: server.tls(), ProxyProtocol: true})
	conn, err := net.Dial("tcp", relay.testAddress())
	if err != nil {
		t.Fatal(err)
	}
	defer conn.Close()
	_ = conn.SetDeadline(time.Now().Add(5 * time.Second))
	header, peer := newHeader(tagPadded, 2, testSecret)
	packet, nonce := reqPQPacket()
	peer.send.XORKeyStream(packet, packet)
	line := []byte("PROXY TCP4 1.2.3.4 5.6.7.8 1234 443\r\n")
	if _, err := conn.Write(append(line, append(header, packet...)...)); err != nil {
		t.Fatal(err)
	}
	if err := readResPQ(conn, peer.recv.XORKeyStream, nonce); err != nil {
		t.Fatal(err)
	}
}

func TestCloudflare429ParksTheBaseAndUsesAnother(t *testing.T) {
	server := newFakeTelegram(t, "kws2.one.example.co.uk", "kws2.two.example.co.uk")
	server.statuses = []int{429, 0}
	server.retryAfter = "120"
	routes := map[string]string{
		"kws2.one.example.co.uk:443": server.address(),
		"kws2.one.example.co.uk:80":  server.address(),
		"kws2.two.example.co.uk:443": server.address(),
		"kws2.two.example.co.uk:80":  server.address(),
	}
	relay := startRelay(t, Config{
		Endpoints: []string{closedAddress(t)},
		CFDomains: []string{"one.example.co.uk", "two.example.co.uk"},
		TLS:       server.tls(),
		Dial:      routeDial(routes),
	})
	if err := selfTest(t, relay, 2); err != nil {
		t.Fatal(err)
	}
	if status := dcStatus(relay, 2); status.Route != RouteCloudflare {
		t.Fatalf("status %+v", status)
	}
	if remaining := relay.cf.cooldownRemaining("one.example.co.uk", time.Now()); remaining < time.Minute {
		t.Fatalf("cooldown %s", remaining)
	}
	if got := relay.cf.orderedForDC(2)[0]; got != "two.example.co.uk" {
		t.Fatalf("chosen base %s", got)
	}
}

func TestTestDCFallsBackToTestTCPAddress(t *testing.T) {
	echo := outboundEcho(t, nil)
	relay := startRelay(t, Config{
		Endpoints: []string{closedAddress(t)},
		Dial: func(ctx context.Context, _, address string) (net.Conn, error) {
			if !strings.HasPrefix(address, "149.154.167.40:") {
				return nil, io.EOF
			}
			return echo(ctx, address)
		},
	})
	if err := selfTest(t, relay, 10002); err != nil {
		t.Fatal(err)
	}
	if status := dcStatus(relay, 2); status.Route != RouteTCP {
		t.Fatalf("status %+v", status)
	}
}
