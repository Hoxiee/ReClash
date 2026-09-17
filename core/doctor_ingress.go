package main

import (
	"sync/atomic"
	"time"

	C "github.com/metacubex/mihomo/constant"
)

type doctorIngressGate struct {
	next [7]atomic.Int64
}

func (gate *doctorIngressGate) allow(inbound C.Type, now time.Time) bool {
	index := 6
	switch inbound {
	case C.TUN:
		index = 0
	case C.HTTP, C.HTTPS:
		index = 1
	case C.SOCKS4, C.SOCKS5:
		index = 2
	case C.REDIR:
		index = 3
	case C.TPROXY:
		index = 4
	case C.INNER:
		index = 5
	}
	deadline := &gate.next[index]
	at := now.UnixNano()
	previous := deadline.Load()
	if previous != 0 && at < previous && previous-at <= int64(doctorPassivePublishPeriod) {
		return false
	}
	return deadline.CompareAndSwap(previous, at+int64(doctorPassivePublishPeriod))
}

func (gate *doctorIngressGate) reset() {
	for i := range gate.next {
		gate.next[i].Store(0)
	}
}
