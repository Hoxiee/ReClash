package telegram

import (
	"bytes"
	"context"
	"crypto/hmac"
	"crypto/rand"
	"crypto/sha256"
	"encoding/binary"
	"io"
	"net"
	"strings"
	"testing"
	"time"
)

// fakeTLSClientHello builds the record a Telegram client sends for an ee secret.
func fakeTLSClientHello(t *testing.T, secret []byte) []byte {
	t.Helper()
	body := make([]byte, 200)
	body[0] = 0x01
	body[1] = 0x00
	binary.BigEndian.PutUint16(body[2:], uint16(len(body)-4))
	binary.BigEndian.PutUint16(body[4:], 0x0303)
	if _, err := rand.Read(body[6:38]); err != nil {
		t.Fatal(err)
	}
	body[38] = tlsSessionLen
	if _, err := rand.Read(body[39:71]); err != nil {
		t.Fatal(err)
	}
	hello := make([]byte, 5+len(body))
	hello[0], hello[1], hello[2] = tlsRecordHandshake, 0x03, 0x01
	binary.BigEndian.PutUint16(hello[3:], uint16(len(body)))
	copy(hello[5:], body)
	clear(hello[tlsRandomOffset : tlsRandomOffset+tlsRandomLen])
	mac := hmac.New(sha256.New, secret)
	mac.Write(hello)
	expected := mac.Sum(nil)
	copy(hello[tlsRandomOffset:], expected[:28])
	timestamp := uint32(time.Now().Unix())
	for i := range 4 {
		hello[tlsRandomOffset+28+i] = byte(timestamp>>(8*i)) ^ expected[28+i]
	}
	return hello
}

func TestFakeTLSCarriesMTProtoAfterHandshake(t *testing.T) {
	server := newFakeTelegram(t)
	relay := startRelay(t, Config{
		Endpoints:     []string{server.address()},
		TLS:           server.tls(),
		FakeTLSDomain: "mask.example.org",
	})
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	if _, err := SelfTestFakeTLS(ctx, relay.testAddress(), testSecret, 2); err != nil {
		t.Fatal(err)
	}
	server.mu.Lock()
	defer server.mu.Unlock()
	if len(server.headers) != 1 || server.headers[0] != 2 {
		t.Fatalf("headers %v", server.headers)
	}
}

func TestFakeTLSRedirectsPlainConnections(t *testing.T) {
	relay := startRelay(t, Config{FakeTLSDomain: "mask.example.org"})
	conn, err := net.Dial("tcp", relay.testAddress())
	if err != nil {
		t.Fatal(err)
	}
	defer conn.Close()
	_ = conn.SetDeadline(time.Now().Add(2 * time.Second))
	if _, err := io.WriteString(conn, "GET / HTTP/1.1\r\nHost: mask.example.org\r\n\r\n"); err != nil {
		t.Fatal(err)
	}
	reply, err := io.ReadAll(conn)
	if err != nil && len(reply) == 0 {
		t.Fatal(err)
	}
	if !strings.HasPrefix(string(reply), "HTTP/1.1 301") ||
		!strings.Contains(string(reply), "Location: https://mask.example.org/") {
		t.Fatalf("reply %q", reply)
	}
}

func TestFakeTLSMasksAnUnauthenticatedHandshake(t *testing.T) {
	mask, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatal(err)
	}
	defer mask.Close()
	seen := make(chan []byte, 1)
	go func() {
		conn, err := mask.Accept()
		if err != nil {
			return
		}
		defer conn.Close()
		hello := make([]byte, 200)
		if _, err := io.ReadFull(conn, hello); err != nil {
			return
		}
		seen <- hello
		_, _ = conn.Write(hello)
	}()
	relay := startRelay(t, Config{
		FakeTLSDomain: "mask.example.org",
		Dial: func(ctx context.Context, network, address string) (net.Conn, error) {
			if address != "mask.example.org:443" {
				return nil, io.EOF
			}
			return (&net.Dialer{}).DialContext(ctx, network, mask.Addr().String())
		},
	})
	conn, err := net.Dial("tcp", relay.testAddress())
	if err != nil {
		t.Fatal(err)
	}
	defer conn.Close()
	_ = conn.SetDeadline(time.Now().Add(2 * time.Second))
	hello := make([]byte, 200)
	hello[0], hello[1], hello[2] = tlsRecordHandshake, 0x03, 0x01
	binary.BigEndian.PutUint16(hello[3:], 195)
	if _, err := conn.Write(hello); err != nil {
		t.Fatal(err)
	}
	select {
	case got := <-seen:
		if !bytes.Equal(got, hello) {
			t.Fatal("masking server saw a different handshake")
		}
	case <-time.After(2 * time.Second):
		t.Fatal("handshake was not forwarded to the masking domain")
	}
	if relay.Status().Masked != 1 {
		t.Fatalf("masked %d", relay.Status().Masked)
	}
}

func TestVerifyClientHelloRejectsStaleTimestamp(t *testing.T) {
	hello := fakeTLSClientHello(t, testSecret)
	zeroed := append([]byte(nil), hello...)
	clear(zeroed[tlsRandomOffset : tlsRandomOffset+tlsRandomLen])
	mac := hmac.New(sha256.New, testSecret)
	mac.Write(zeroed)
	expected := mac.Sum(nil)
	timestamp := uint32(time.Now().Add(-time.Hour).Unix())
	for i := range 4 {
		hello[tlsRandomOffset+28+i] = byte(timestamp>>(8*i)) ^ expected[28+i]
	}
	if _, _, err := verifyClientHello(hello, testSecret); err == nil {
		t.Fatal("stale timestamp accepted")
	}
}
