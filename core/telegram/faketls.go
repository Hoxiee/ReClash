package telegram

import (
	"context"
	"crypto/hmac"
	"crypto/rand"
	"crypto/sha256"
	"encoding/binary"
	"errors"
	"fmt"
	"io"
	"net"
	"sync"
	"time"
)

const (
	tlsRecordHandshake = 0x16
	tlsRecordCCS       = 0x14
	tlsRecordAppData   = 0x17

	tlsRandomOffset  = 11
	tlsRandomLen     = 32
	tlsSessionOffset = 44
	tlsSessionLen    = 32

	fakeTLSTolerance = 120
	tlsAppDataMax    = 16384
	maskDialTimeout  = 10 * time.Second
)

var errFakeTLS = errors.New("telegram: not a fake tls handshake")

// serverHello is a TLS 1.3 ServerHello carrying a random key share. Telegram's client checks
// only that the server answered its HMAC, not that the key is usable: no TLS follow-up happens
// after the fabricated handshake.
func serverHello() []byte {
	hello := make([]byte, 0, 128)
	hello = append(hello, 0x16, 0x03, 0x03, 0x00, 0x7b)
	hello = append(hello, 0x02, 0x00, 0x00, 0x77)
	hello = append(hello, 0x03, 0x03)
	hello = append(hello, make([]byte, tlsRandomLen)...)
	hello = append(hello, 0x20)
	hello = append(hello, make([]byte, tlsSessionLen)...)
	hello = append(hello, 0x13, 0x01, 0x00)
	hello = append(hello, 0x00, 0x2e, 0x00)
	hello = append(hello, 0x00, 0x33, 0x00, 0x24, 0x00, 0x1d, 0x00, 0x20)
	hello = append(hello, make([]byte, 32)...)
	hello = append(hello, 0x00, 0x2b, 0x00, 0x02, 0x03, 0x04)
	return hello
}

// verifyClientHello authenticates the client the way the ee secret defines it: the first 28
// random bytes are HMAC-SHA256(secret, hello with a zeroed random), and the last four carry the
// timestamp XORed with the matching MAC bytes.
func verifyClientHello(hello, secret []byte) (random [tlsRandomLen]byte, session [tlsSessionLen]byte, err error) {
	if len(hello) < 43 || hello[0] != tlsRecordHandshake || hello[5] != 0x01 {
		return random, session, errFakeTLS
	}
	copy(random[:], hello[tlsRandomOffset:tlsRandomOffset+tlsRandomLen])
	zeroed := append([]byte(nil), hello...)
	clear(zeroed[tlsRandomOffset : tlsRandomOffset+tlsRandomLen])
	mac := hmac.New(sha256.New, secret)
	mac.Write(zeroed)
	expected := mac.Sum(nil)
	if !hmac.Equal(expected[:28], random[:28]) {
		return random, session, errFakeTLS
	}
	var timestamp [4]byte
	for i := range timestamp {
		timestamp[i] = random[28+i] ^ expected[28+i]
	}
	delta := time.Now().Unix() - int64(binary.LittleEndian.Uint32(timestamp[:]))
	if delta < -fakeTLSTolerance || delta > fakeTLSTolerance {
		return random, session, errFakeTLS
	}
	if len(hello) >= tlsSessionOffset+tlsSessionLen && hello[43] == tlsSessionLen {
		copy(session[:], hello[tlsSessionOffset:tlsSessionOffset+tlsSessionLen])
	}
	return random, session, nil
}

func buildServerHello(secret []byte, clientRandom, session [tlsRandomLen]byte) []byte {
	hello := serverHello()
	copy(hello[tlsSessionOffset:tlsSessionOffset+tlsSessionLen], session[:])
	if _, err := rand.Read(hello[90 : 90+32]); err != nil {
		panic(err)
	}
	response := hello
	response = append(response, tlsRecordCCS, 0x03, 0x03, 0x00, 0x01, 0x01)
	size := 1900 + int(time.Now().UnixNano()%201)
	response = append(response, tlsRecordAppData, 0x03, 0x03, byte(size>>8), byte(size))
	payload := make([]byte, size)
	if _, err := rand.Read(payload); err != nil {
		panic(err)
	}
	response = append(response, payload...)
	mac := hmac.New(sha256.New, secret)
	mac.Write(clientRandom[:])
	mac.Write(response)
	copy(response[tlsRandomOffset:tlsRandomOffset+tlsRandomLen], mac.Sum(nil))
	return response
}

// fakeTLSConn exposes the plaintext inside TLS application-data records. The bytes inside are
// MTProto, so the TLS layer is presentation only and carries no keys.
type fakeTLSConn struct {
	conn    net.Conn
	writeMu sync.Mutex
	buf     []byte
}

func (c *fakeTLSConn) Read(p []byte) (int, error) {
	for len(c.buf) == 0 {
		payload, err := readTLSRecord(c.conn)
		if err != nil {
			return 0, err
		}
		c.buf = payload
	}
	n := copy(p, c.buf)
	c.buf = c.buf[n:]
	return n, nil
}

func (c *fakeTLSConn) Write(p []byte) (int, error) {
	c.writeMu.Lock()
	defer c.writeMu.Unlock()
	written := 0
	for len(p) > 0 {
		chunk := p[:min(len(p), tlsAppDataMax)]
		var header [5]byte
		header[0], header[1], header[2] = tlsRecordAppData, 0x03, 0x03
		binary.BigEndian.PutUint16(header[3:], uint16(len(chunk)))
		if _, err := c.conn.Write(header[:]); err != nil {
			return written, err
		}
		if _, err := c.conn.Write(chunk); err != nil {
			return written, err
		}
		written += len(chunk)
		p = p[len(chunk):]
	}
	return written, nil
}

func (c *fakeTLSConn) Close() error                       { return c.conn.Close() }
func (c *fakeTLSConn) LocalAddr() net.Addr                { return c.conn.LocalAddr() }
func (c *fakeTLSConn) RemoteAddr() net.Addr               { return c.conn.RemoteAddr() }
func (c *fakeTLSConn) SetDeadline(t time.Time) error      { return c.conn.SetDeadline(t) }
func (c *fakeTLSConn) SetReadDeadline(t time.Time) error  { return c.conn.SetReadDeadline(t) }
func (c *fakeTLSConn) SetWriteDeadline(t time.Time) error { return c.conn.SetWriteDeadline(t) }

func readTLSRecord(conn net.Conn) ([]byte, error) {
	for {
		var header [5]byte
		if _, err := io.ReadFull(conn, header[:]); err != nil {
			return nil, err
		}
		length := int(binary.BigEndian.Uint16(header[3:]))
		switch header[0] {
		case tlsRecordCCS:
			if length > 0 {
				if _, err := io.CopyN(io.Discard, conn, int64(length)); err != nil {
					return nil, err
				}
			}
		case tlsRecordAppData:
			if length == 0 {
				continue
			}
			payload := make([]byte, length)
			if _, err := io.ReadFull(conn, payload); err != nil {
				return nil, err
			}
			return payload, nil
		default:
			return nil, fmt.Errorf("telegram: unexpected tls record %#x", header[0])
		}
	}
}

// clientHello builds the record Telegram sends for an ee secret. It is used by the self-test,
// which has to look like a Telegram client behind a TLS middlebox.
func clientHello(secret []byte) []byte {
	body := make([]byte, 200)
	body[0] = 0x01
	binary.BigEndian.PutUint16(body[2:], uint16(len(body)-4))
	binary.BigEndian.PutUint16(body[4:], 0x0303)
	if _, err := rand.Read(body[6:38]); err != nil {
		panic(err)
	}
	body[38] = tlsSessionLen
	if _, err := rand.Read(body[39:71]); err != nil {
		panic(err)
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

func consumeServerHello(conn net.Conn) error {
	var header [5]byte
	if _, err := io.ReadFull(conn, header[:]); err != nil {
		return err
	}
	if header[0] != tlsRecordHandshake {
		return fmt.Errorf("telegram: server hello record %#x", header[0])
	}
	if _, err := io.CopyN(io.Discard, conn, int64(binary.BigEndian.Uint16(header[3:]))); err != nil {
		return err
	}
	var ccs [6]byte
	if _, err := io.ReadFull(conn, ccs[:]); err != nil {
		return err
	}
	if ccs[0] != tlsRecordCCS {
		return fmt.Errorf("telegram: expected change cipher spec, got %#x", ccs[0])
	}
	if _, err := io.ReadFull(conn, header[:]); err != nil {
		return err
	}
	if header[0] != tlsRecordAppData {
		return fmt.Errorf("telegram: expected application data, got %#x", header[0])
	}
	_, err := io.CopyN(io.Discard, conn, int64(binary.BigEndian.Uint16(header[3:])))
	return err
}

// serveFakeTLS consumes the ClientHello and returns the connection that carries the MTProto
// header, or false when the connection was masking traffic and needs no relay.
func (r *Relay) serveFakeTLS(client net.Conn, first byte) (net.Conn, bool) {
	_ = client.SetDeadline(time.Now().Add(clientHeaderTimeout))
	var rest [4]byte
	if _, err := io.ReadFull(client, rest[:]); err != nil {
		return nil, false
	}
	length := int(binary.BigEndian.Uint16(rest[2:]))
	if length <= 0 || length > 64<<10 {
		return nil, false
	}
	hello := make([]byte, 5+length)
	hello[0] = first
	copy(hello[1:5], rest[:])
	if _, err := io.ReadFull(client, hello[5:]); err != nil {
		return nil, false
	}
	random, session, err := verifyClientHello(hello, r.config.Secret)
	if err != nil {
		r.maskFakeTLS(client, hello)
		return nil, false
	}
	if _, err := client.Write(buildServerHello(r.config.Secret, random, session)); err != nil {
		return nil, false
	}
	_ = client.SetDeadline(time.Time{})
	return &fakeTLSConn{conn: client}, true
}

// maskFakeTLS forwards an unauthenticated handshake to the masking domain, so the client sees
// the TLS site it asked for instead of a closed port.
func (r *Relay) maskFakeTLS(client net.Conn, hello []byte) {
	r.masked.Add(1)
	dial := r.config.Dial
	if dial == nil {
		dial = (&net.Dialer{}).DialContext
	}
	ctx, cancel := context.WithTimeout(r.ctx, maskDialTimeout)
	defer cancel()
	upstream, err := dial(ctx, "tcp", net.JoinHostPort(r.config.FakeTLSDomain, "443"))
	if err != nil {
		r.config.Logf("fake tls masking %s: %v", r.config.FakeTLSDomain, err)
		return
	}
	defer upstream.Close()
	if _, err := upstream.Write(hello); err != nil {
		return
	}
	_ = client.SetDeadline(time.Time{})
	done := make(chan struct{}, 2)
	go func() { _, _ = io.Copy(upstream, client); done <- struct{}{} }()
	go func() { _, _ = io.Copy(client, upstream); done <- struct{}{} }()
	<-done
	_ = client.Close()
	<-done
}
