package telegram

import (
	"bytes"
	"context"
	"encoding/binary"
	"encoding/hex"
	"errors"
	"net"
	"sync/atomic"
	"testing"
	"time"
)

func mustHex(t *testing.T, value string) []byte {
	t.Helper()
	decoded, err := hex.DecodeString(value)
	if err != nil {
		t.Fatal(err)
	}
	return decoded
}

// The vectors come from openssl's aes-256-ctr and Python's hashlib, not from this package.
func TestClientHeaderKnownAnswer(t *testing.T) {
	secret := mustHex(t, "101112131415161718191a1b1c1d1e1f")
	header := mustHex(t, "404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f"+
		"606162636465666768696a6b6c6d6e6f707172737475767786225a2e3da1d883")

	client, tag, index, err := openClientHeader(header, secret)
	if err != nil {
		t.Fatal(err)
	}
	if tag != tagPadded || index != -2 {
		t.Fatalf("tag %08x index %d", tag, index)
	}
	got := make([]byte, 16)
	client.send.XORKeyStream(got, got)
	if want := mustHex(t, "60297a64bb83cfac8b7719eb416dedf7"); !bytes.Equal(got, want) {
		t.Fatalf("decrypt stream past the header = %x, want %x", got, want)
	}
	got = make([]byte, 16)
	client.recv.XORKeyStream(got, got)
	if want := mustHex(t, "8a506909267def78f185e2b2b39ccbdb"); !bytes.Equal(got, want) {
		t.Fatalf("encrypt stream = %x, want %x", got, want)
	}

	if _, _, _, err := openClientHeader(header, make([]byte, secretSize)); !errors.Is(err, errBadSecret) {
		t.Fatalf("wrong secret: %v", err)
	}
}

func TestUpstreamStreamsUseTheRawKey(t *testing.T) {
	header := mustHex(t, "404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f"+
		"606162636465666768696a6b6c6d6e6f707172737475767786225a2e3da1d883")
	peer := headerStreams(header, nil)
	got := make([]byte, 16)
	peer.send.XORKeyStream(got, got)
	if want := mustHex(t, "1ec2369321d9b5a5682185a23d157dbf"); !bytes.Equal(got, want) {
		t.Fatalf("send = %x, want %x", got, want)
	}
	got = make([]byte, 16)
	peer.recv.XORKeyStream(got, got)
	if want := mustHex(t, "7f76ceb8adcd9d58d7b6e56f4a5ddc9b"); !bytes.Equal(got, want) {
		t.Fatalf("recv = %x, want %x", got, want)
	}
}

func TestNewHeaderIsAcceptedAndContinuesItsStream(t *testing.T) {
	secret := bytes.Repeat([]byte{7}, secretSize)
	for _, tag := range []uint32{tagAbridged, tagIntermediate, tagPadded} {
		for range 200 {
			header, peer := newHeader(tag, -4, secret)
			if reservedHeader(header) {
				t.Fatalf("reserved prefix %x", header[:8])
			}
			server, gotTag, index, err := openClientHeader(header, secret)
			if err != nil || gotTag != tag || index != -4 {
				t.Fatalf("tag %08x index %d err %v", gotTag, index, err)
			}
			message := []byte("hello")
			encrypted := make([]byte, len(message))
			peer.send.XORKeyStream(encrypted, message)
			server.send.XORKeyStream(encrypted, encrypted)
			if !bytes.Equal(encrypted, message) {
				t.Fatal("uplink stream desynchronised after the header")
			}
		}
	}
}

func TestReservedHeaderPrefixes(t *testing.T) {
	base := func() []byte {
		header := make([]byte, headerSize)
		copy(header, []byte{1, 2, 3, 4, 5, 6, 7, 8})
		return header
	}
	if reservedHeader(base()) {
		t.Fatal("ordinary header rejected")
	}
	for _, prefix := range []string{"HEAD", "POST", "GET ", "OPTI", "\xee\xee\xee\xee", "\xdd\xdd\xdd\xdd", "\x16\x03\x01\x02", "\xef..."} {
		header := base()
		copy(header, prefix)
		if !reservedHeader(header) {
			t.Fatalf("%q accepted", prefix)
		}
	}
	header := base()
	copy(header[4:8], []byte{0, 0, 0, 0})
	if !reservedHeader(header) {
		t.Fatal("zero second word accepted")
	}
}

func TestResolveTarget(t *testing.T) {
	for _, test := range []struct {
		index  int16
		ok     bool
		dc     int
		host   int
		media  bool
		viaWeb bool
	}{
		{2, true, 2, 2, false, true},
		{-4, true, 4, 4, true, true},
		{1, true, 1, 1, false, false},
		{-5, true, 5, 5, true, false},
		{203, true, 203, 2, false, true},
		{-203, true, 203, 2, true, true},
		{0, false, 0, 0, false, false},
		{6, false, 0, 0, false, false},
		{10002, false, 0, 0, false, false},
		{-32768, false, 0, 0, false, false},
	} {
		got, ok := resolveTarget(test.index)
		if ok != test.ok {
			t.Fatalf("%d: ok=%v", test.index, ok)
		}
		if ok && (got.dc != test.dc || got.hostDC != test.host || got.media != test.media || got.overWebSocket() != test.viaWeb) {
			t.Fatalf("%d: %+v", test.index, got)
		}
	}
}

func abridged(size int) []byte {
	words := size / 4
	if words < 0x7f {
		return append([]byte{byte(words)}, make([]byte, size)...)
	}
	return append([]byte{0x7f, byte(words), byte(words >> 8), byte(words >> 16)}, make([]byte, size)...)
}

func intermediate(size int) []byte {
	packet := make([]byte, 4+size)
	binary.LittleEndian.PutUint32(packet, uint32(size))
	return packet
}

func TestSplitterFindsBoundaries(t *testing.T) {
	for _, test := range []struct {
		name    string
		tag     uint32
		packets [][]byte
	}{
		{"abridged", tagAbridged, [][]byte{abridged(4), abridged(0x7e * 4), abridged(0x7f * 4), abridged(4000)}},
		{"intermediate", tagIntermediate, [][]byte{intermediate(1), intermediate(300), intermediate(70000)}},
		{"padded", tagPadded, [][]byte{intermediate(17), intermediate(131), intermediate(66000)}},
	} {
		var stream []byte
		var want []int
		for i, packet := range test.packets {
			copy(packet[len(packet)-1:], []byte{byte(i + 1)})
			stream = append(stream, packet...)
			want = append(want, len(packet))
		}
		for _, chunk := range []int{1, 3, 7, 4096, len(stream)} {
			var got []int
			var joined []byte
			s := splitter{tag: test.tag}
			for rest := stream; len(rest) > 0; {
				n := min(chunk, len(rest))
				// A new read buffer each time: a packet must not point into an old one.
				s.feed(bytes.Clone(rest[:n]), func(packet []byte) {
					got = append(got, len(packet))
					joined = append(joined, packet...)
				})
				rest = rest[n:]
			}
			if !bytes.Equal(joined, stream) {
				t.Fatalf("%s chunk %d: stream changed", test.name, chunk)
			}
			if len(got) != len(want) {
				t.Fatalf("%s chunk %d: sizes %v, want %v", test.name, chunk, got, want)
			}
			for i := range got {
				if got[i] != want[i] {
					t.Fatalf("%s chunk %d: sizes %v, want %v", test.name, chunk, got, want)
				}
			}
		}
	}
}

func TestSplitterHonoursQuickAckBits(t *testing.T) {
	var got []int
	s := splitter{tag: tagAbridged}
	s.feed(append([]byte{0x81}, make([]byte, 4)...), func(p []byte) { got = append(got, len(p)) })
	big := intermediate(8)
	binary.LittleEndian.PutUint32(big, 8|1<<31)
	i := splitter{tag: tagIntermediate}
	i.feed(big, func(p []byte) { got = append(got, len(p)) })
	if len(got) != 2 || got[0] != 5 || got[1] != 12 {
		t.Fatalf("sizes %v", got)
	}
}

func TestSplitterPassesThroughAfterUnusableLength(t *testing.T) {
	for _, test := range []struct {
		name   string
		tag    uint32
		stream []byte
	}{
		{"zero abridged", tagAbridged, []byte{0, 9, 9, 9}},
		{"zero intermediate", tagIntermediate, []byte{0, 0, 0, 0, 9, 9}},
		{"oversized", tagPadded, []byte{0xff, 0xff, 0xff, 0x7f, 9, 9}},
	} {
		s := splitter{tag: test.tag}
		var joined []byte
		for _, b := range test.stream {
			s.feed([]byte{b}, func(p []byte) { joined = append(joined, p...) })
		}
		s.feed([]byte{1, 2, 3}, func(p []byte) { joined = append(joined, p...) })
		if !s.disabled {
			t.Fatalf("%s: still splitting", test.name)
		}
		if want := append(bytes.Clone(test.stream), 1, 2, 3); !bytes.Equal(joined, want) {
			t.Fatalf("%s: %v, want %v", test.name, joined, want)
		}
	}
}

func TestAppendFrameLengthBoundaries(t *testing.T) {
	for _, size := range []int{0, 1, 7, 8, 125, 126, 127, 65535, 65536, 70001} {
		payload := make([]byte, size)
		for i := range payload {
			payload[i] = byte(i*31 + 5)
		}
		original := bytes.Clone(payload)
		frame := appendFrame(nil, opBinary, payload)
		if !bytes.Equal(payload, original) {
			t.Fatal("source buffer modified")
		}
		if frame[0] != 0x82 || frame[1]&0x80 == 0 {
			t.Fatalf("size %d: head %x", size, frame[:2])
		}
		length, offset := int(frame[1]&0x7f), 2
		switch {
		case size < 126:
			if length != size {
				t.Fatalf("size %d: length %d", size, length)
			}
		case size < 65536:
			if length != 126 || int(binary.BigEndian.Uint16(frame[2:])) != size {
				t.Fatalf("size %d: bad 16-bit length", size)
			}
			offset = 4
		default:
			if length != 127 || int(binary.BigEndian.Uint64(frame[2:])) != size {
				t.Fatalf("size %d: bad 64-bit length", size)
			}
			offset = 10
		}
		mask := frame[offset : offset+4]
		body := bytes.Clone(frame[offset+4:])
		for i := range body {
			body[i] ^= mask[i%4]
		}
		if !bytes.Equal(body, original) {
			t.Fatalf("size %d: unmasked payload differs", size)
		}
	}
}

func TestBackoffGivesOneTrialAfterTheWindow(t *testing.T) {
	var b backoff
	now := time.Unix(1000, 0)
	if !b.allow(now) {
		t.Fatal("fresh route refused")
	}
	b.fail(now, backoffMax)
	if b.allow(now.Add(backoffBase - time.Millisecond)) {
		t.Fatal("allowed inside the window")
	}
	trial := now.Add(backoffBase)
	if !b.allow(trial) {
		t.Fatal("no trial after the window")
	}
	if b.allow(trial) {
		t.Fatal("second caller got the same trial")
	}
	b.fail(trial, backoffMax)
	if b.allow(trial.Add(2*backoffBase - time.Millisecond)) {
		t.Fatal("window did not grow")
	}
	for range 40 {
		b.fail(trial, backoffMax)
	}
	if !b.until.Equal(trial.Add(backoffMax)) {
		t.Fatalf("window not capped: %s", b.until.Sub(trial))
	}
	b.succeed()
	if !b.allow(trial) {
		t.Fatal("success did not clear the route")
	}
}

func TestEndpointRanking(t *testing.T) {
	now := time.Unix(1000, 0)
	set := newEndpointSet([]string{"a", "b", "c"})
	if first := set.candidates(now)[0].address; first != "a" {
		t.Fatalf("unmeasured order: %s", first)
	}
	entries := set.candidates(now)
	set.reportFailure(entries[0], now, errors.New("down"))
	got := set.candidates(now)
	if len(got) != 2 || got[0].address != "b" {
		t.Fatalf("failed endpoint still first: %+v", got)
	}
	set.reportSuccess(got[1], 100*time.Millisecond)
	set.reportSuccess(got[0], 900*time.Millisecond)
	if first := set.candidates(now)[0].address; first != "c" {
		t.Fatalf("faster endpoint not first: %s", first)
	}
	set.clearBackoff()
	if size := len(set.candidates(now)); size != 3 {
		t.Fatalf("after reset: %d candidates", size)
	}
	set.replace([]string{"c", "d"})
	status := set.snapshot()
	if len(status) != 2 || status[0].Successes != 1 || status[1].Address != "d" {
		t.Fatalf("replace lost history: %+v", status)
	}
}

func TestDialHedgedStaggersAndKeepsTheFirstSuccess(t *testing.T) {
	var calls atomic.Int32
	left, right := net.Pipe()
	defer right.Close()
	dial := func(ctx context.Context, _, _ string) (net.Conn, error) {
		if calls.Add(1) < 3 {
			<-ctx.Done()
			return nil, ctx.Err()
		}
		return left, nil
	}
	conn, try, err := dialHedged(context.Background(), dial, "x", 6, 5*time.Millisecond)
	if err != nil {
		t.Fatal(err)
	}
	defer conn.Close()
	if try != 3 {
		t.Fatalf("won by attempt %d", try)
	}
}

func TestDialHedgedFailsFastWhenEveryAttemptIsRefused(t *testing.T) {
	var calls atomic.Int32
	refused := errors.New("refused")
	dial := func(context.Context, string, string) (net.Conn, error) {
		calls.Add(1)
		return nil, refused
	}
	started := time.Now()
	_, _, err := dialHedged(context.Background(), dial, "x", 6, time.Hour)
	if !errors.Is(err, refused) {
		t.Fatalf("err %v", err)
	}
	if calls.Load() != 6 || time.Since(started) > time.Second {
		t.Fatalf("%d calls in %s", calls.Load(), time.Since(started))
	}
}

func TestDialHedgedClosesLateWinners(t *testing.T) {
	release := make(chan struct{})
	closed := make(chan struct{}, 1)
	winner, peer := net.Pipe()
	defer peer.Close()
	var calls atomic.Int32
	dial := func(context.Context, string, string) (net.Conn, error) {
		if calls.Add(1) == 1 {
			<-release
			return &closeSignal{Conn: nil, closed: closed}, nil
		}
		return winner, nil
	}
	conn, _, err := dialHedged(context.Background(), dial, "x", 2, time.Millisecond)
	if err != nil {
		t.Fatal(err)
	}
	defer conn.Close()
	close(release)
	select {
	case <-closed:
	case <-time.After(2 * time.Second):
		t.Fatal("late connection leaked")
	}
}

type closeSignal struct {
	net.Conn
	closed chan struct{}
}

func (c *closeSignal) Close() error {
	c.closed <- struct{}{}
	return nil
}
