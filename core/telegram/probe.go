package telegram

import (
	"context"
	"crypto/rand"
	"crypto/tls"
	"encoding/binary"
	"errors"
	"fmt"
	"io"
	"net"
	"slices"
	"sync"
	"time"
)

const (
	reqPQMulti     uint32 = 0xbe7e8ef1
	resPQ          uint32 = 0x05162463
	reqPQLength           = 40
	minResPQLength        = 24 + 16
	maxResPQLength        = 4096
)

// reqPQPacket is one unauthenticated padded-intermediate transport packet and its nonce.
func reqPQPacket() (packet, nonce []byte) {
	packet = make([]byte, 4+reqPQLength)
	binary.LittleEndian.PutUint32(packet, reqPQLength)
	binary.LittleEndian.PutUint64(packet[12:], uint64(time.Now().Unix())<<32)
	binary.LittleEndian.PutUint32(packet[20:], 20)
	binary.LittleEndian.PutUint32(packet[24:], reqPQMulti)
	if _, err := rand.Read(packet[28:]); err != nil {
		panic(err)
	}
	return packet, slices.Clone(packet[28:44])
}

// readResPQ checks that a real MTProto server answered: the constructor and our own nonce.
func readResPQ(reader io.Reader, decrypt func(dst, src []byte), nonce []byte) error {
	var head [4]byte
	if _, err := io.ReadFull(reader, head[:]); err != nil {
		return err
	}
	decrypt(head[:], head[:])
	length := binary.LittleEndian.Uint32(head[:]) &^ (1 << 31)
	if length < minResPQLength || length > maxResPQLength {
		return fmt.Errorf("telegram: implausible reply length %d", length)
	}
	body := make([]byte, length)
	if _, err := io.ReadFull(reader, body); err != nil {
		return err
	}
	decrypt(body, body)
	if binary.LittleEndian.Uint32(body[20:]) != resPQ {
		return errors.New("telegram: reply is not resPQ")
	}
	for i, b := range nonce {
		if body[24+i] != b {
			return errors.New("telegram: reply carries another nonce")
		}
	}
	return nil
}

type upstreamReader struct{ up upstream }

func (u *upstreamReader) Read(p []byte) (int, error) { return u.up.recv(p) }

// ProbeEndpoint runs a real req_pq/resPQ exchange against one address. A completed upgrade alone
// proves little: the thing that matters is that MTProto traffic comes back.
func ProbeEndpoint(ctx context.Context, dial DialFunc, tlsConfig *tls.Config, address string, dc int) (time.Duration, error) {
	started := time.Now()
	raw, _, err := dialHedged(ctx, dial, address, dialAttempts, dialStagger)
	if err != nil {
		return 0, fmt.Errorf("tcp: %w", err)
	}
	defer raw.Close()
	host := fmt.Sprintf("kws%d.web.telegram.org", dc)
	ws, err := upgradeWebSocket(ctx, raw, host, tlsConfig)
	if err != nil {
		return 0, err
	}
	if deadline, ok := ctx.Deadline(); ok {
		ws.setDeadline(deadline)
	}
	header, peer := newHeader(tagPadded, int16(dc), nil)
	ws.add(header)
	packet, nonce := reqPQPacket()
	peer.send.XORKeyStream(packet, packet)
	ws.add(packet)
	if err := ws.flush(); err != nil {
		return 0, err
	}
	if err := readResPQ(&upstreamReader{up: ws}, peer.recv.XORKeyStream, nonce); err != nil {
		return 0, err
	}
	return time.Since(started), nil
}

// SelfTest drives a running relay the way a client does and returns when resPQ came back.
func SelfTest(ctx context.Context, proxyAddress string, secret []byte, dcIndex int16) (time.Duration, error) {
	started := time.Now()
	var dialer net.Dialer
	conn, err := dialer.DialContext(ctx, "tcp", proxyAddress)
	if err != nil {
		return 0, err
	}
	defer conn.Close()
	if deadline, ok := ctx.Deadline(); ok {
		_ = conn.SetDeadline(deadline)
	}
	header, peer := newHeader(tagPadded, dcIndex, secret)
	packet, nonce := reqPQPacket()
	peer.send.XORKeyStream(packet, packet)
	if _, err := conn.Write(append(header, packet...)); err != nil {
		return 0, err
	}
	if err := readResPQ(conn, peer.recv.XORKeyStream, nonce); err != nil {
		return 0, err
	}
	return time.Since(started), nil
}

// ProbeAll scores every endpoint with a real exchange. Latency recorded here competes with the
// latency of real connections, which include the same TCP and TLS work plus one round trip.
func (r *Relay) ProbeAll(ctx context.Context) {
	addresses := r.endpoints.snapshot()
	var wg sync.WaitGroup
	for _, status := range addresses {
		wg.Go(func() {
			probeCtx, cancel := context.WithTimeout(ctx, probeTimeout)
			defer cancel()
			latency, err := ProbeEndpoint(probeCtx, r.config.Dial, r.config.TLS, status.Address, 2)
			r.endpoints.report(status.Address, latency, r.now(), err)
			if err != nil {
				r.config.Logf("probe %s: %v", status.Address, err)
			} else {
				r.config.Logf("probe %s: resPQ in %dms", status.Address, latency.Milliseconds())
			}
		})
	}
	wg.Wait()
}

// With one address there is nothing to fail over to, and probing it only burns the battery.
func (r *Relay) reprobeSoon() {
	if r.endpoints.size() < 2 {
		return
	}
	now := r.now().UnixMilli()
	last := r.lastProbe.Load()
	if now-last < reprobeInterval.Milliseconds() || !r.lastProbe.CompareAndSwap(last, now) {
		return
	}
	if !r.probing.CompareAndSwap(false, true) {
		return
	}
	r.wg.Go(func() {
		defer r.probing.Store(false)
		r.ProbeAll(r.ctx)
	})
}
