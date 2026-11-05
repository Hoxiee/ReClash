package telegram

import "encoding/binary"

// A packet longer than this is not a real transport packet: Telegram's largest payload is an
// upload part of 512 KB. Buffering a bogus length would hold the stream back forever.
const maxPacketSize = 4 << 20

// splitter finds transport packet boundaries in the client's plaintext, because the WebSocket
// endpoint needs each packet in its own frame. Once a length cannot be parsed it stops splitting
// for good and passes bytes through.
type splitter struct {
	tag      uint32
	partial  []byte
	disabled bool
}

// packetSize returns the size of the packet starting at b, 0 when the header is still incomplete,
// and -1 when the length is unusable.
func (s *splitter) packetSize(b []byte) int {
	var size int
	if s.tag == tagAbridged {
		if len(b) < 1 {
			return 0
		}
		first := b[0] &^ 0x80
		switch first {
		case 0:
			return -1
		case 0x7f:
			if len(b) < 4 {
				return 0
			}
			size = 4 + (int(b[1])|int(b[2])<<8|int(b[3])<<16)*4
			if size == 4 {
				return -1
			}
		default:
			size = 1 + int(first)*4
		}
	} else {
		if len(b) < 4 {
			return 0
		}
		length := binary.LittleEndian.Uint32(b) &^ (1 << 31)
		if length == 0 || length > maxPacketSize {
			return -1
		}
		size = 4 + int(length)
	}
	if size > maxPacketSize {
		return -1
	}
	return size
}

// feed hands each complete packet to emit. A packet is only valid during the call.
func (s *splitter) feed(plain []byte, emit func(packet []byte)) {
	if s.disabled {
		if len(plain) > 0 {
			emit(plain)
		}
		return
	}
	for len(s.partial) > 0 && len(plain) > 0 {
		size := s.packetSize(s.partial)
		if size == 0 {
			s.partial = append(s.partial, plain[0])
			plain = plain[1:]
			continue
		}
		if size < 0 {
			s.passThrough(plain, emit)
			return
		}
		take := min(size-len(s.partial), len(plain))
		s.partial = append(s.partial, plain[:take]...)
		plain = plain[take:]
		if len(s.partial) == size {
			emit(s.partial)
			s.releasePartial()
		}
	}
	for len(plain) > 0 {
		size := s.packetSize(plain)
		if size < 0 {
			s.passThrough(plain, emit)
			return
		}
		if size == 0 || len(plain) < size {
			s.partial = append(s.partial[:0], plain...)
			return
		}
		emit(plain[:size])
		plain = plain[size:]
	}
}

func (s *splitter) passThrough(plain []byte, emit func(packet []byte)) {
	s.disabled = true
	if len(s.partial) > 0 {
		emit(s.partial)
		s.partial = nil
	}
	if len(plain) > 0 {
		emit(plain)
	}
}

// One large upload must not pin its buffer to a connection that then idles for hours.
func (s *splitter) releasePartial() {
	if cap(s.partial) > 64<<10 {
		s.partial = nil
		return
	}
	s.partial = s.partial[:0]
}
