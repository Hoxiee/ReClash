package telegram

import (
	"bufio"
	"context"
	"crypto/rand"
	"crypto/sha1"
	"crypto/tls"
	"encoding/base64"
	"encoding/binary"
	"errors"
	"fmt"
	"io"
	"math/bits"
	mathrand "math/rand/v2"
	"net"
	"net/http"
	"sync"
	"time"
)

const (
	opContinuation = 0x0
	opBinary       = 0x2
	opClose        = 0x8
	opPing         = 0x9
	opPong         = 0xa

	upstreamWriteTimeout = 30 * time.Second
	flushThreshold       = 64 << 10
)

// upstream is Telegram's side of a session. add buffers one encrypted transport packet, flush
// sends what add collected, and recv returns the next piece of the downlink byte stream.
type upstream interface {
	add(packet []byte)
	flush() error
	recv(buf []byte) (int, error)
	setDeadline(time.Time)
	Close() error
}

// handshakeError marks a failure after TCP connected: the address is alive, but it does not serve
// this host. Another host on the same address can still work.
type handshakeError struct{ err error }

func (e *handshakeError) Error() string { return e.err.Error() }
func (e *handshakeError) Unwrap() error { return e.err }

// appendFrame appends a masked client frame. Masking runs a word at a time: this is the only
// per-byte work of the uplink besides AES.
func appendFrame(out []byte, opcode byte, payload []byte) []byte {
	out = append(out, 0x80|opcode)
	switch n := len(payload); {
	case n < 126:
		out = append(out, 0x80|byte(n))
	case n < 1<<16:
		out = append(out, 0x80|126, byte(n>>8), byte(n))
	default:
		out = append(out, 0x80|127)
		out = binary.BigEndian.AppendUint64(out, uint64(n))
	}
	mask := mathrand.Uint32()
	out = binary.BigEndian.AppendUint32(out, mask)
	start := len(out)
	out = append(out, payload...)
	body := out[start:]
	word := bits.ReverseBytes64(uint64(mask)<<32 | uint64(mask))
	for len(body) >= 8 {
		binary.LittleEndian.PutUint64(body, binary.LittleEndian.Uint64(body)^word)
		body = body[8:]
	}
	maskBytes := [4]byte{byte(mask >> 24), byte(mask >> 16), byte(mask >> 8), byte(mask)}
	for i := range body {
		body[i] ^= maskBytes[i%4]
	}
	return out
}

type webSocket struct {
	conn   net.Conn
	reader *bufio.Reader

	writeMu sync.Mutex
	out     []byte

	remaining uint64
	control   [125]byte
}

func (w *webSocket) add(packet []byte) {
	w.out = appendFrame(w.out, opBinary, packet)
}

func (w *webSocket) flush() error {
	w.writeMu.Lock()
	defer w.writeMu.Unlock()
	return w.flushLocked()
}

func (w *webSocket) flushLocked() error {
	if len(w.out) == 0 {
		return nil
	}
	_ = w.conn.SetWriteDeadline(time.Now().Add(upstreamWriteTimeout))
	_, err := w.conn.Write(w.out)
	if cap(w.out) > flushThreshold {
		w.out = nil
	} else {
		w.out = w.out[:0]
	}
	return err
}

// writeControl runs on the downlink goroutine and must not mix with a frame add has half built,
// so it writes on its own.
func (w *webSocket) writeControl(opcode byte, payload []byte) error {
	frame := appendFrame(make([]byte, 0, len(payload)+6), opcode, payload)
	w.writeMu.Lock()
	defer w.writeMu.Unlock()
	_ = w.conn.SetWriteDeadline(time.Now().Add(upstreamWriteTimeout))
	_, err := w.conn.Write(frame)
	return err
}

// recv returns payload bytes. The downlink is a byte stream, so a large frame comes back over
// several calls and nothing has to hold a whole frame in memory.
func (w *webSocket) recv(buf []byte) (int, error) {
	for w.remaining == 0 {
		if err := w.readFrameHeader(); err != nil {
			return 0, err
		}
	}
	n, err := w.reader.Read(buf[:min(uint64(len(buf)), w.remaining)])
	w.remaining -= uint64(n)
	return n, err
}

func (w *webSocket) readFrameHeader() error {
	var head [2]byte
	if _, err := io.ReadFull(w.reader, head[:]); err != nil {
		return err
	}
	if head[0]&0x70 != 0 || head[1]&0x80 != 0 {
		return errors.New("telegram: malformed frame from server")
	}
	opcode, length := head[0]&0x0f, uint64(head[1]&0x7f)
	switch length {
	case 126:
		var extended [2]byte
		if _, err := io.ReadFull(w.reader, extended[:]); err != nil {
			return err
		}
		length = uint64(binary.BigEndian.Uint16(extended[:]))
	case 127:
		var extended [8]byte
		if _, err := io.ReadFull(w.reader, extended[:]); err != nil {
			return err
		}
		length = binary.BigEndian.Uint64(extended[:])
	}
	switch opcode {
	case opContinuation, opBinary:
		w.remaining = length
		return nil
	case opClose, opPing, opPong:
		if length > uint64(len(w.control)) {
			return errors.New("telegram: oversized control frame")
		}
		payload := w.control[:length]
		if _, err := io.ReadFull(w.reader, payload); err != nil {
			return err
		}
		switch opcode {
		case opClose:
			_ = w.writeControl(opClose, payload)
			return io.EOF
		case opPing:
			return w.writeControl(opPong, payload)
		}
		return nil
	}
	return fmt.Errorf("telegram: unexpected opcode %d", opcode)
}

func (w *webSocket) setDeadline(t time.Time) { _ = w.conn.SetDeadline(t) }
func (w *webSocket) Close() error            { return w.conn.Close() }

// upgradeWebSocket runs TLS and the HTTP upgrade over an established TCP connection. The server's
// certificate is always verified against host.
func upgradeWebSocket(ctx context.Context, raw net.Conn, host string, base *tls.Config) (*webSocket, error) {
	config := &tls.Config{}
	if base != nil {
		config = base.Clone()
	}
	config.ServerName = host
	config.NextProtos = []string{"http/1.1"}
	conn := tls.Client(raw, config)
	if deadline, ok := ctx.Deadline(); ok {
		_ = raw.SetDeadline(deadline)
	}
	if err := conn.HandshakeContext(ctx); err != nil {
		return nil, &handshakeError{fmt.Errorf("tls %s: %w", host, err)}
	}
	var keyBytes [16]byte
	if _, err := rand.Read(keyBytes[:]); err != nil {
		return nil, err
	}
	key := base64.StdEncoding.EncodeToString(keyBytes[:])
	request := "GET /apiws HTTP/1.1\r\nHost: " + host + "\r\nConnection: Upgrade\r\nUpgrade: websocket\r\n" +
		"Sec-WebSocket-Version: 13\r\nSec-WebSocket-Key: " + key + "\r\nSec-WebSocket-Protocol: binary\r\n\r\n"
	if _, err := io.WriteString(conn, request); err != nil {
		return nil, &handshakeError{fmt.Errorf("upgrade %s: %w", host, err)}
	}
	reader := bufio.NewReaderSize(conn, 32<<10)
	response, err := http.ReadResponse(reader, &http.Request{Method: http.MethodGet})
	if err != nil {
		return nil, &handshakeError{fmt.Errorf("upgrade %s: %w", host, err)}
	}
	if response.StatusCode != http.StatusSwitchingProtocols {
		return nil, &handshakeError{fmt.Errorf("upgrade %s: status %d", host, response.StatusCode)}
	}
	if response.Header.Get("Sec-WebSocket-Accept") != acceptKey(key) {
		return nil, &handshakeError{fmt.Errorf("upgrade %s: bad accept key", host)}
	}
	_ = raw.SetDeadline(time.Time{})
	return &webSocket{conn: conn, reader: reader}, nil
}

func acceptKey(key string) string {
	sum := sha1.Sum([]byte(key + "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"))
	return base64.StdEncoding.EncodeToString(sum[:])
}

// tcpUpstream carries an unframed stream, used by the outbound path.
type tcpUpstream struct {
	conn net.Conn
	out  []byte
}

func (t *tcpUpstream) add(packet []byte) { t.out = append(t.out, packet...) }

func (t *tcpUpstream) flush() error {
	if len(t.out) == 0 {
		return nil
	}
	_ = t.conn.SetWriteDeadline(time.Now().Add(upstreamWriteTimeout))
	_, err := t.conn.Write(t.out)
	if cap(t.out) > flushThreshold {
		t.out = nil
	} else {
		t.out = t.out[:0]
	}
	return err
}

func (t *tcpUpstream) recv(buf []byte) (int, error) { return t.conn.Read(buf) }
func (t *tcpUpstream) setDeadline(d time.Time)      { _ = t.conn.SetDeadline(d) }
func (t *tcpUpstream) Close() error                 { return t.conn.Close() }
