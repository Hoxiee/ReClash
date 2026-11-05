package telegram

import (
	"bufio"
	"bytes"
	"context"
	"crypto/ecdsa"
	"crypto/elliptic"
	"crypto/rand"
	"crypto/tls"
	"crypto/x509"
	"crypto/x509/pkix"
	"encoding/binary"
	"errors"
	"io"
	"math/big"
	"net"
	"net/http"
	"strings"
	"sync"
	"sync/atomic"
	"testing"
	"time"
)

var testSecret = bytes.Repeat([]byte{0x5a}, secretSize)

// fakeTelegram is a TLS WebSocket endpoint that decodes the relay's header and frames. In its
// default mode it answers req_pq with resPQ and echoes every other packet back as one frame.
type fakeTelegram struct {
	t        *testing.T
	listener net.Listener
	pool     *x509.CertPool

	mu       sync.Mutex
	hosts    []string
	headers  []int16
	frames   []int
	received []byte

	refuseHost string
	silent     bool
	pingFirst  bool
	pongs      atomic.Int32
	accepted   atomic.Int32
}

func newFakeTelegram(t *testing.T, names ...string) *fakeTelegram {
	t.Helper()
	if len(names) == 0 {
		names = []string{"kws2.web.telegram.org", "kws2-1.web.telegram.org", "kws4.web.telegram.org", "kws4-1.web.telegram.org"}
	}
	key, err := ecdsa.GenerateKey(elliptic.P256(), rand.Reader)
	if err != nil {
		t.Fatal(err)
	}
	template := &x509.Certificate{
		SerialNumber: big.NewInt(1), Subject: pkix.Name{CommonName: "fake"}, DNSNames: names,
		NotBefore: time.Now().Add(-time.Hour), NotAfter: time.Now().Add(time.Hour),
		IsCA: true, BasicConstraintsValid: true, KeyUsage: x509.KeyUsageDigitalSignature | x509.KeyUsageCertSign,
	}
	der, err := x509.CreateCertificate(rand.Reader, template, template, key.Public(), key)
	if err != nil {
		t.Fatal(err)
	}
	parsed, _ := x509.ParseCertificate(der)
	pool := x509.NewCertPool()
	pool.AddCert(parsed)
	listener, err := tls.Listen("tcp", "127.0.0.1:0", &tls.Config{
		Certificates: []tls.Certificate{{Certificate: [][]byte{der}, PrivateKey: key}},
		NextProtos:   []string{"http/1.1"},
	})
	if err != nil {
		t.Fatal(err)
	}
	f := &fakeTelegram{t: t, listener: listener, pool: pool}
	t.Cleanup(func() { _ = listener.Close() })
	go func() {
		for {
			conn, err := listener.Accept()
			if err != nil {
				return
			}
			f.accepted.Add(1)
			go f.serve(conn)
		}
	}()
	return f
}

func (f *fakeTelegram) address() string { return f.listener.Addr().String() }

func (f *fakeTelegram) readFrame(reader *bufio.Reader) (byte, []byte, error) {
	var head [2]byte
	if _, err := io.ReadFull(reader, head[:]); err != nil {
		return 0, nil, err
	}
	if head[1]&0x80 == 0 {
		return 0, nil, errors.New("client frame not masked")
	}
	length := uint64(head[1] & 0x7f)
	switch length {
	case 126:
		var extended [2]byte
		_, _ = io.ReadFull(reader, extended[:])
		length = uint64(binary.BigEndian.Uint16(extended[:]))
	case 127:
		var extended [8]byte
		_, _ = io.ReadFull(reader, extended[:])
		length = binary.BigEndian.Uint64(extended[:])
	}
	var mask [4]byte
	if _, err := io.ReadFull(reader, mask[:]); err != nil {
		return 0, nil, err
	}
	payload := make([]byte, length)
	if _, err := io.ReadFull(reader, payload); err != nil {
		return 0, nil, err
	}
	for i := range payload {
		payload[i] ^= mask[i%4]
	}
	return head[0] & 0x0f, payload, nil
}

func serverFrame(opcode byte, payload []byte) []byte {
	frame := []byte{0x80 | opcode}
	switch n := len(payload); {
	case n < 126:
		frame = append(frame, byte(n))
	case n < 1<<16:
		frame = append(frame, 126, byte(n>>8), byte(n))
	default:
		frame = append(frame, 127)
		frame = binary.BigEndian.AppendUint64(frame, uint64(n))
	}
	return append(frame, payload...)
}

func (f *fakeTelegram) serve(conn net.Conn) {
	defer conn.Close()
	reader := bufio.NewReader(conn)
	request, err := http.ReadRequest(reader)
	if err != nil {
		return
	}
	f.mu.Lock()
	f.hosts = append(f.hosts, request.Host)
	f.mu.Unlock()
	if request.Host == f.refuseHost {
		_, _ = io.WriteString(conn, "HTTP/1.1 404 Not Found\r\nContent-Length: 0\r\n\r\n")
		return
	}
	_, _ = io.WriteString(conn, "HTTP/1.1 101 Switching Protocols\r\nConnection: Upgrade\r\nUpgrade: websocket\r\n"+
		"Sec-WebSocket-Protocol: binary\r\nSec-WebSocket-Accept: "+acceptKey(request.Header.Get("Sec-WebSocket-Key"))+"\r\n\r\n")
	_, header, err := f.readFrame(reader)
	if err != nil || len(header) != headerSize {
		return
	}
	peer, tag, index, err := openClientHeader(header, nil)
	if err != nil {
		f.t.Errorf("relay header rejected: %v", err)
		return
	}
	f.mu.Lock()
	f.headers = append(f.headers, index)
	f.mu.Unlock()
	if f.pingFirst {
		_, _ = conn.Write(serverFrame(opPing, []byte("hi")))
	}
	for {
		opcode, payload, err := f.readFrame(reader)
		if err != nil {
			return
		}
		if opcode == opPong {
			if string(payload) != "hi" {
				f.t.Errorf("pong payload %q", payload)
			}
			f.pongs.Add(1)
			continue
		}
		peer.send.XORKeyStream(payload, payload)
		f.mu.Lock()
		f.frames = append(f.frames, len(payload))
		f.received = append(f.received, payload...)
		f.mu.Unlock()
		if f.silent {
			continue
		}
		reply := payload
		if tag != tagAbridged && len(payload) == 4+reqPQLength && binary.LittleEndian.Uint32(payload[24:]) == reqPQMulti {
			reply = make([]byte, 4+64)
			binary.LittleEndian.PutUint32(reply, 64)
			binary.LittleEndian.PutUint32(reply[4+20:], resPQ)
			copy(reply[4+24:], payload[28:44])
		}
		encrypted := make([]byte, len(reply))
		peer.recv.XORKeyStream(encrypted, reply)
		if _, err := conn.Write(serverFrame(opBinary, encrypted)); err != nil {
			return
		}
	}
}

func (f *fakeTelegram) tls() *tls.Config { return &tls.Config{RootCAs: f.pool} }

func (f *fakeTelegram) seenHosts() []string {
	f.mu.Lock()
	defer f.mu.Unlock()
	return append([]string(nil), f.hosts...)
}

func startRelay(t *testing.T, config Config) *Relay {
	t.Helper()
	config.Listen = "127.0.0.1:0"
	config.Secret = testSecret
	if config.holdUnavailable == 0 {
		config.holdUnavailable = -1
	}
	relay, err := Start(config)
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(relay.Stop)
	return relay
}

func (r *Relay) testAddress() string { return r.listener.Addr().String() }

func selfTest(t *testing.T, r *Relay, index int16) error {
	t.Helper()
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	_, err := SelfTest(ctx, r.testAddress(), testSecret, index)
	return err
}

func dcStatus(r *Relay, dc int) DCStatus {
	for _, status := range r.Status().DCs {
		if status.DC == dc {
			return status
		}
	}
	return DCStatus{}
}

func closedAddress(t *testing.T) string {
	t.Helper()
	listener, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatal(err)
	}
	address := listener.Addr().String()
	_ = listener.Close()
	return address
}

func TestRelayCarriesRequestAndReply(t *testing.T) {
	server := newFakeTelegram(t)
	relay := startRelay(t, Config{Endpoints: []string{server.address()}, TLS: server.tls()})
	for _, index := range []int16{2, 4} {
		if err := selfTest(t, relay, index); err != nil {
			t.Fatalf("dc %d: %v", index, err)
		}
	}
	if status := dcStatus(relay, 2); status.Route != RouteWebSocket || status.Connects != 1 || status.BytesDown == 0 || status.BytesUp == 0 {
		t.Fatalf("dc 2 status %+v", status)
	}
	if hosts := server.seenHosts(); len(hosts) != 2 || hosts[0] != "kws2.web.telegram.org" || hosts[1] != "kws4.web.telegram.org" {
		t.Fatalf("hosts %v", hosts)
	}
	if relay.Status().LastTraffic == 0 {
		t.Fatal("no traffic recorded")
	}
}

// Each transport packet has to reach the server as its own frame however the client's writes fall.
func TestRelayFramesEachPacketAndStreamsTheReply(t *testing.T) {
	server := newFakeTelegram(t)
	server.pingFirst = true
	relay := startRelay(t, Config{Endpoints: []string{server.address()}, TLS: server.tls()})

	conn, err := net.Dial("tcp", relay.testAddress())
	if err != nil {
		t.Fatal(err)
	}
	defer conn.Close()
	_ = conn.SetDeadline(time.Now().Add(10 * time.Second))
	header, peer := newHeader(tagPadded, 2, testSecret)
	if _, err := conn.Write(header); err != nil {
		t.Fatal(err)
	}
	sizes := []int{9, 125, 126, 65535, 70000}
	var stream []byte
	for _, size := range sizes {
		packet := intermediate(size)
		_, _ = rand.Read(packet[4:])
		stream = append(stream, packet...)
	}
	encrypted := make([]byte, len(stream))
	peer.send.XORKeyStream(encrypted, stream)
	// Merged at the start, split across the large packets.
	for rest, cut := encrypted, 200; len(rest) > 0; cut = 30000 {
		n := min(cut, len(rest))
		if _, err := conn.Write(rest[:n]); err != nil {
			t.Fatal(err)
		}
		rest = rest[n:]
		time.Sleep(time.Millisecond)
	}
	reply := make([]byte, len(stream))
	if _, err := io.ReadFull(conn, reply); err != nil {
		t.Fatalf("reading reply: %v", err)
	}
	peer.recv.XORKeyStream(reply, reply)
	if !bytes.Equal(reply, stream) {
		t.Fatal("echoed stream differs")
	}
	server.mu.Lock()
	defer server.mu.Unlock()
	if len(server.frames) != len(sizes) {
		t.Fatalf("frames %v for sizes %v", server.frames, sizes)
	}
	for i, size := range sizes {
		if server.frames[i] != size+4 {
			t.Fatalf("frames %v for sizes %v", server.frames, sizes)
		}
	}
	if !bytes.Equal(server.received, stream) {
		t.Fatal("server saw a different stream")
	}
	if server.pongs.Load() != 1 {
		t.Fatalf("pongs %d", server.pongs.Load())
	}
}

func TestRelayCountsWhileTheConnectionIsOpen(t *testing.T) {
	server := newFakeTelegram(t)
	relay := startRelay(t, Config{Endpoints: []string{server.address()}, TLS: server.tls()})
	conn, err := net.Dial("tcp", relay.testAddress())
	if err != nil {
		t.Fatal(err)
	}
	defer conn.Close()
	_ = conn.SetDeadline(time.Now().Add(5 * time.Second))
	header, peer := newHeader(tagIntermediate, 4, testSecret)
	packet := intermediate(1000)
	encrypted := make([]byte, len(packet))
	peer.send.XORKeyStream(encrypted, packet)
	if _, err := conn.Write(append(header, encrypted...)); err != nil {
		t.Fatal(err)
	}
	if _, err := io.ReadFull(conn, make([]byte, len(packet))); err != nil {
		t.Fatal(err)
	}
	status := dcStatus(relay, 4)
	if status.Active != 1 || status.BytesDown != uint64(len(packet)) || status.BytesUp != uint64(len(packet)) {
		t.Fatalf("status %+v", status)
	}
}

func TestMediaFallsBackToTheMainHost(t *testing.T) {
	server := newFakeTelegram(t)
	server.refuseHost = "kws2-1.web.telegram.org"
	relay := startRelay(t, Config{Endpoints: []string{server.address()}, TLS: server.tls()})
	if err := selfTest(t, relay, -2); err != nil {
		t.Fatal(err)
	}
	hosts := server.seenHosts()
	if len(hosts) != 2 || hosts[0] != "kws2-1.web.telegram.org" || hosts[1] != "kws2.web.telegram.org" {
		t.Fatalf("hosts %v", hosts)
	}
	server.mu.Lock()
	defer server.mu.Unlock()
	if server.headers[0] != -2 {
		t.Fatalf("media index not preserved: %d", server.headers[0])
	}
}

func TestCDNDCUsesTheHostOfDCTwo(t *testing.T) {
	server := newFakeTelegram(t)
	relay := startRelay(t, Config{Endpoints: []string{server.address()}, TLS: server.tls()})
	if err := selfTest(t, relay, 203); err != nil {
		t.Fatal(err)
	}
	if hosts := server.seenHosts(); hosts[0] != "kws2.web.telegram.org" {
		t.Fatalf("hosts %v", hosts)
	}
	server.mu.Lock()
	defer server.mu.Unlock()
	if server.headers[0] != 203 {
		t.Fatalf("index %d", server.headers[0])
	}
	if status := dcStatus(relay, 203); status.Connects != 1 {
		t.Fatalf("status %+v", status)
	}
}

func TestWrongSecretNeverReachesTelegram(t *testing.T) {
	server := newFakeTelegram(t)
	relay := startRelay(t, Config{Endpoints: []string{server.address()}, TLS: server.tls()})
	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer cancel()
	if _, err := SelfTest(ctx, relay.testAddress(), bytes.Repeat([]byte{1}, secretSize), 2); err == nil {
		t.Fatal("wrong secret got an answer")
	}
	if server.accepted.Load() != 0 {
		t.Fatal("reached the upstream")
	}
	if relay.Status().BadSecrets != 1 {
		t.Fatalf("badSecrets %d", relay.Status().BadSecrets)
	}
}

// The certificate is what makes an unverifiable address harmless to try.
func TestCertificateIsAlwaysVerified(t *testing.T) {
	wrongName := newFakeTelegram(t, "other.example.org")
	relay := startRelay(t, Config{Endpoints: []string{wrongName.address()}, TLS: wrongName.tls()})
	if err := selfTest(t, relay, 2); err == nil {
		t.Fatal("name mismatch accepted")
	}
	untrusted := newFakeTelegram(t)
	relay = startRelay(t, Config{Endpoints: []string{untrusted.address()}})
	if err := selfTest(t, relay, 2); err == nil {
		t.Fatal("untrusted certificate accepted")
	}
	status := relay.Status().Endpoints[0]
	if status.Healthy || !strings.Contains(status.LastError, "tls") {
		t.Fatalf("status %+v", status)
	}
}

func TestFailsOverWithoutUserAction(t *testing.T) {
	server := newFakeTelegram(t)
	dead := closedAddress(t)
	relay := startRelay(t, Config{Endpoints: []string{dead, server.address()}, TLS: server.tls()})
	if err := selfTest(t, relay, 2); err != nil {
		t.Fatal(err)
	}
	endpoints := relay.Status().Endpoints
	if endpoints[0].Healthy || endpoints[0].Failures == 0 || !endpoints[1].Healthy || endpoints[1].Successes == 0 {
		t.Fatalf("endpoints %+v", endpoints)
	}
	// The dead address now ranks last, so the next connection does not pay for it.
	if first := relay.endpoints.candidates(time.Now())[0].address; first != server.address() {
		t.Fatalf("first candidate %s", first)
	}
	if err := selfTest(t, relay, 2); err != nil {
		t.Fatal(err)
	}
}

func TestRemembersAFailedRouteAndFailsAtOnce(t *testing.T) {
	var dials atomic.Int32
	relay := startRelay(t, Config{
		Endpoints: []string{"192.0.2.1"},
		Dial: func(ctx context.Context, _, _ string) (net.Conn, error) {
			dials.Add(1)
			return nil, errors.New("timed out")
		},
	})
	if err := selfTest(t, relay, 2); err == nil {
		t.Fatal("expected a failure")
	}
	first := dials.Load()
	if first != dialAttempts {
		t.Fatalf("dials %d", first)
	}
	started := time.Now()
	if err := selfTest(t, relay, 2); err == nil {
		t.Fatal("expected a failure")
	}
	if elapsed := time.Since(started); elapsed > time.Second {
		t.Fatalf("doomed attempt took %s", elapsed)
	}
	if dials.Load() != first {
		t.Fatal("dialled inside the window")
	}
	status := dcStatus(relay, 2)
	if status.Route != RouteUnavailable || status.FastFails != 1 || status.Failures != 1 {
		t.Fatalf("status %+v", status)
	}
	relay.ResetConnections()
	if err := selfTest(t, relay, 2); err == nil {
		t.Fatal("expected a failure")
	}
	if dials.Load() != 2*first {
		t.Fatal("reset did not clear the remembered failure")
	}
}

func TestUnavailableClientIsHeldUntilARouteAppears(t *testing.T) {
	server := newFakeTelegram(t)
	relay := startRelay(t, Config{
		Endpoints:       []string{server.address()},
		TLS:             server.tls(),
		holdUnavailable: 200 * time.Millisecond,
	})
	started := time.Now()
	if err := selfTest(t, relay, 1); err == nil {
		t.Fatal("dc 1 answered")
	}
	if elapsed := time.Since(started); elapsed < 200*time.Millisecond {
		t.Fatalf("refused after %s, the client would spin", elapsed)
	}

	relay = startRelay(t, Config{
		Endpoints:       []string{server.address()},
		TLS:             server.tls(),
		holdUnavailable: time.Minute,
	})
	finished := make(chan struct{})
	go func() {
		defer close(finished)
		_ = selfTest(t, relay, 1)
	}()
	for {
		relay.mu.Lock()
		waiting := len(relay.held)
		relay.mu.Unlock()
		if waiting > 0 {
			break
		}
		time.Sleep(time.Millisecond)
	}
	relay.SetOutbound(func(context.Context, string) (net.Conn, error) {
		return nil, errors.New("not used")
	})
	select {
	case <-finished:
	case <-time.After(3 * time.Second):
		t.Fatal("a held client outlived the new route")
	}
}

func TestNoOutboundIsUnavailableWithoutRetryCost(t *testing.T) {
	server := newFakeTelegram(t)
	relay := startRelay(t, Config{Endpoints: []string{server.address()}, TLS: server.tls()})
	for _, index := range []int16{1, -5, 3} {
		started := time.Now()
		if err := selfTest(t, relay, index); err == nil {
			t.Fatalf("dc %d answered", index)
		}
		if elapsed := time.Since(started); elapsed > time.Second {
			t.Fatalf("dc %d took %s", index, elapsed)
		}
	}
	if status := dcStatus(relay, 5); status.Route != RouteUnavailable || status.FastFails != 1 {
		t.Fatalf("dc 5 status %+v", status)
	}
	if server.accepted.Load() != 0 {
		t.Fatal("touched WebSocket for a DC that has none")
	}
	if err := selfTest(t, relay, 2); err != nil {
		t.Fatalf("dc 2 slowed by dc 5: %v", err)
	}
}

// outboundEcho is a TCP Telegram: it speaks the raw obfuscated stream the outbound path carries.
func outboundEcho(t *testing.T, seen chan<- string) OutboundFunc {
	t.Helper()
	return func(_ context.Context, address string) (net.Conn, error) {
		if seen != nil {
			seen <- address
		}
		near, far := net.Pipe()
		go func() {
			defer far.Close()
			header := make([]byte, headerSize)
			if _, err := io.ReadFull(far, header); err != nil {
				return
			}
			peer, _, _, err := openClientHeader(header, nil)
			if err != nil {
				return
			}
			buf := make([]byte, reqPQLength+4)
			if _, err := io.ReadFull(far, buf); err != nil {
				return
			}
			peer.send.XORKeyStream(buf, buf)
			reply := make([]byte, 4+64)
			binary.LittleEndian.PutUint32(reply, 64)
			binary.LittleEndian.PutUint32(reply[4+20:], resPQ)
			copy(reply[4+24:], buf[28:44])
			peer.recv.XORKeyStream(reply, reply)
			_, _ = far.Write(reply)
			_, _ = io.Copy(io.Discard, far)
		}()
		return near, nil
	}
}

func TestOutboundCarriesTheOtherDCs(t *testing.T) {
	seen := make(chan string, 4)
	relay := startRelay(t, Config{Endpoints: []string{closedAddress(t)}, Outbound: outboundEcho(t, seen)})
	if err := selfTest(t, relay, -5); err != nil {
		t.Fatal(err)
	}
	if address := <-seen; address != dcAddresses[5][0] {
		t.Fatalf("address %s", address)
	}
	if status := dcStatus(relay, 5); status.Route != RouteOutbound || status.Connects != 1 {
		t.Fatalf("status %+v", status)
	}
}

func TestWebSocketDCFallsBackToTheOutbound(t *testing.T) {
	relay := startRelay(t, Config{Endpoints: []string{closedAddress(t)}, Outbound: outboundEcho(t, nil)})
	if err := selfTest(t, relay, 4); err != nil {
		t.Fatal(err)
	}
	if status := dcStatus(relay, 4); status.Route != RouteOutbound {
		t.Fatalf("status %+v", status)
	}
	if err := selfTest(t, relay, 4); err != nil {
		t.Fatalf("second connection, WebSocket remembered as failed: %v", err)
	}
}

func TestSilentEndpointLosesRankWithoutClosing(t *testing.T) {
	silent := newFakeTelegram(t)
	silent.silent = true
	relay := startRelay(t, Config{Endpoints: []string{silent.address()}, TLS: silent.tls()})
	var offset atomic.Int64
	relay.now = func() time.Time { return time.Now().Add(time.Duration(offset.Load())) }

	conn, err := net.Dial("tcp", relay.testAddress())
	if err != nil {
		t.Fatal(err)
	}
	header, peer := newHeader(tagPadded, 2, testSecret)
	packet := intermediate(16)
	peer.send.XORKeyStream(packet, packet)
	if _, err := conn.Write(append(header, packet...)); err != nil {
		t.Fatal(err)
	}
	deadline := time.Now().Add(2 * time.Second)
	for dcStatus(relay, 2).BytesUp == 0 && time.Now().Before(deadline) {
		time.Sleep(5 * time.Millisecond)
	}
	offset.Store(int64(time.Minute))
	_ = conn.Close()
	deadline = time.Now().Add(2 * time.Second)
	for relay.Status().Endpoints[0].Healthy && time.Now().Before(deadline) {
		time.Sleep(5 * time.Millisecond)
	}
	if relay.Status().Endpoints[0].Healthy {
		t.Fatal("silent endpoint still healthy")
	}
	if len(relay.endpoints.candidates(time.Now())) != 1 {
		t.Fatal("silent endpoint was closed to new connections")
	}
}

func TestProbeRecordsARealExchange(t *testing.T) {
	good := newFakeTelegram(t)
	silent := newFakeTelegram(t)
	silent.silent = true
	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer cancel()
	if _, err := ProbeEndpoint(ctx, (&net.Dialer{}).DialContext, good.tls(), good.address(), 2); err != nil {
		t.Fatalf("good endpoint: %v", err)
	}
	shortCtx, shortCancel := context.WithTimeout(context.Background(), 300*time.Millisecond)
	defer shortCancel()
	if _, err := ProbeEndpoint(shortCtx, (&net.Dialer{}).DialContext, silent.tls(), silent.address(), 2); err == nil {
		t.Fatal("an upgrade with no MTProto reply passed the probe")
	}
}

func TestResetConnectionsDropsSessionsAndStopFreesThePort(t *testing.T) {
	server := newFakeTelegram(t)
	relay := startRelay(t, Config{Endpoints: []string{server.address()}, TLS: server.tls()})
	conn, err := net.Dial("tcp", relay.testAddress())
	if err != nil {
		t.Fatal(err)
	}
	defer conn.Close()
	header, _ := newHeader(tagPadded, 2, testSecret)
	if _, err := conn.Write(header); err != nil {
		t.Fatal(err)
	}
	deadline := time.Now().Add(2 * time.Second)
	for dcStatus(relay, 2).Active == 0 && time.Now().Before(deadline) {
		time.Sleep(5 * time.Millisecond)
	}
	relay.ResetConnections()
	_ = conn.SetReadDeadline(time.Now().Add(2 * time.Second))
	if _, err := conn.Read(make([]byte, 1)); err == nil || errors.Is(err, context.DeadlineExceeded) {
		t.Fatalf("session survived the reset: %v", err)
	}
	address := relay.testAddress()
	relay.Stop()
	relay.Stop()
	listener, err := net.Listen("tcp4", address)
	if err != nil {
		t.Fatalf("port not released: %v", err)
	}
	_ = listener.Close()
}

func TestStartRefusesAnythingButLoopback(t *testing.T) {
	for _, address := range []string{"0.0.0.0:0", "192.168.1.5:0", ":0", "localhost:0"} {
		if _, err := Start(Config{Listen: address, Secret: testSecret}); err == nil {
			t.Fatalf("%s accepted", address)
		}
	}
	if _, err := Start(Config{Listen: "127.0.0.1:0", Secret: []byte{1}}); err == nil {
		t.Fatal("short secret accepted")
	}
}

func TestStartReportsAnOccupiedPort(t *testing.T) {
	relay := startRelay(t, Config{})
	if _, err := Start(Config{Listen: relay.testAddress(), Secret: testSecret}); err == nil {
		t.Fatal("occupied port accepted")
	}
}

func TestStatusNeverCarriesTheSecret(t *testing.T) {
	server := newFakeTelegram(t)
	var logged bytes.Buffer
	var mu sync.Mutex
	relay := startRelay(t, Config{Endpoints: []string{server.address()}, TLS: server.tls(), Logf: func(format string, args ...any) {
		mu.Lock()
		defer mu.Unlock()
		logged.WriteString(format)
		for _, arg := range args {
			if err, ok := arg.(error); ok {
				logged.WriteString(err.Error())
			}
		}
	}})
	if err := selfTest(t, relay, 2); err != nil {
		t.Fatal(err)
	}
	mu.Lock()
	defer mu.Unlock()
	if bytes.Contains(logged.Bytes(), testSecret) {
		t.Fatal("secret in the log")
	}
}
