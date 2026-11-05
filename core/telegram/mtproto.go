// Package telegram is a local MTProto proxy that carries Telegram's traffic over WebSocket to
// Telegram's own web endpoints. It depends on no profile, TUN or listener state of the Core.
package telegram

import (
	"crypto/aes"
	"crypto/cipher"
	"crypto/rand"
	"crypto/sha256"
	"encoding/binary"
	"errors"
)

const (
	headerSize = 64
	secretSize = 16

	tagAbridged     uint32 = 0xefefefef
	tagIntermediate uint32 = 0xeeeeeeee
	tagPadded       uint32 = 0xdddddddd
)

var errBadSecret = errors.New("telegram: wrong secret or unknown transport")

// streams holds one peer's view of an obfuscated connection: send encrypts what it writes and
// recv decrypts what it reads. The two directions use independent keys from the same header.
type streams struct {
	send, recv cipher.Stream
}

func newCTR(key, iv []byte) cipher.Stream {
	block, err := aes.NewCipher(key)
	if err != nil {
		panic(err)
	}
	return cipher.NewCTR(block, iv)
}

// With a secret the key is SHA256(prekey + secret); the proxy to Telegram leg has no secret and
// uses the prekey itself.
func deriveKey(prekey, secret []byte) []byte {
	if len(secret) == 0 {
		return prekey
	}
	hash := sha256.New()
	hash.Write(prekey)
	hash.Write(secret)
	return hash.Sum(nil)
}

func headerStreams(header, secret []byte) streams {
	var reversed [48]byte
	for i, b := range header[8:56] {
		reversed[47-i] = b
	}
	return streams{
		send: newCTR(deriveKey(header[8:40], secret), header[40:56]),
		recv: newCTR(deriveKey(reversed[:32], secret), reversed[32:48]),
	}
}

// openClientHeader authenticates a client's header. The returned streams are from the client's
// point of view, so the proxy decrypts with send and encrypts with recv.
func openClientHeader(header, secret []byte) (client streams, tag uint32, dcIndex int16, err error) {
	client = headerStreams(header, secret)
	var plain [headerSize]byte
	client.send.XORKeyStream(plain[:], header[:headerSize])
	tag = binary.LittleEndian.Uint32(plain[56:60])
	if tag != tagAbridged && tag != tagIntermediate && tag != tagPadded {
		return streams{}, 0, 0, errBadSecret
	}
	return client, tag, int16(binary.LittleEndian.Uint16(plain[60:62])), nil
}

// Telegram's servers tell obfuscated traffic from their other protocols by these prefixes.
func reservedHeader(header []byte) bool {
	if header[0] == 0xef || binary.LittleEndian.Uint32(header[4:8]) == 0 {
		return true
	}
	switch binary.LittleEndian.Uint32(header[:4]) {
	case 0x44414548, 0x54534f50, 0x20544547, 0x4954504f, 0x02010316, tagIntermediate, tagPadded:
		return true
	}
	return false
}

// newHeader builds a fresh obfuscated header. send is already past the 64 header bytes.
func newHeader(tag uint32, dcIndex int16, secret []byte) ([]byte, streams) {
	header := make([]byte, headerSize)
	for {
		if _, err := rand.Read(header); err != nil {
			panic(err)
		}
		if !reservedHeader(header) {
			break
		}
	}
	peer := headerStreams(header, secret)
	binary.LittleEndian.PutUint32(header[56:60], tag)
	binary.LittleEndian.PutUint16(header[60:62], uint16(dcIndex))
	var encrypted [headerSize]byte
	peer.send.XORKeyStream(encrypted[:], header)
	copy(header[56:], encrypted[56:])
	return header, peer
}

// target is where a client asked to go. Header index is passed upstream unchanged.
type target struct {
	index int16
	dc    int
	media bool
	// hostDC names the kws host; CDN DC 203 is served by DC 2's.
	hostDC int
}

func resolveTarget(index int16) (target, bool) {
	dc := int(index)
	media := dc < 0
	if media {
		dc = -dc
	}
	t := target{index: index, dc: dc, media: media, hostDC: dc}
	switch dc {
	case 1, 2, 3, 4, 5:
	case 203:
		t.hostDC = 2
	default:
		return target{}, false
	}
	return t, true
}

func (t target) overWebSocket() bool {
	return t.hostDC == 2 || t.hostDC == 4
}

// The WebSocket request names the DC by host; a TCP path has to name it by address. Telegram's
// clients ship these same addresses, and DC 203 is a CDN with its own.
var dcAddresses = map[int][]string{
	1:   {"149.154.175.50:443", "149.154.175.53:443"},
	2:   {"149.154.167.51:443"},
	3:   {"149.154.175.100:443"},
	4:   {"149.154.167.91:443"},
	5:   {"149.154.171.5:443", "91.108.56.130:443"},
	203: {"91.105.192.100:443"},
}
