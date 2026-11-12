package telegram

import (
	"sync/atomic"
	"testing"
	"time"
)

func (f *fakeTelegram) closeConns() {
	f.mu.Lock()
	defer f.mu.Unlock()
	for _, conn := range f.conns {
		_ = conn.Close()
	}
}

func waitFor(t *testing.T, what string, ok func() bool) {
	t.Helper()
	deadline := time.Now().Add(2 * time.Second)
	for !ok() {
		if time.Now().After(deadline) {
			t.Fatalf("timed out waiting for %s", what)
		}
		time.Sleep(2 * time.Millisecond)
	}
}

func poolRelay(t *testing.T, server *fakeTelegram, config Config) *Relay {
	t.Helper()
	config.Endpoints = []string{server.address()}
	config.TLS = server.tls()
	config.poolSize = poolSize
	relay := startRelay(t, config)
	if err := selfTest(t, relay, 2); err != nil {
		t.Fatal(err)
	}
	waitFor(t, "pool fill", func() bool { return dcStatus(relay, 2).Pooled == poolSize })
	return relay
}

func TestPoolFillsAndServesTheNextConnection(t *testing.T) {
	server := newFakeTelegram(t)
	relay := poolRelay(t, server, Config{})
	if err := selfTest(t, relay, 2); err != nil {
		t.Fatalf("pooled connection: %v", err)
	}
	if hits := relay.pool.hits.Load(); hits != 1 {
		t.Fatalf("pool hits %d", hits)
	}
	waitFor(t, "refill", func() bool { return dcStatus(relay, 2).Pooled == poolSize })
	if status := dcStatus(relay, 2); status.Connects != 2 || status.Route != RouteWebSocket {
		t.Fatalf("status %+v", status)
	}
	if n := server.accepted.Load(); n != 1+poolSize+1 {
		t.Fatalf("accepted %d connections", n)
	}
}

func TestPoolIgnoresSocketsPastMaxAge(t *testing.T) {
	server := newFakeTelegram(t)
	var offset atomic.Int64
	clock := func() time.Time { return time.Now().Add(time.Duration(offset.Load())) }
	relay := poolRelay(t, server, Config{clock: clock})
	offset.Store(int64(poolMaxAge + time.Second))
	if err := selfTest(t, relay, 2); err != nil {
		t.Fatal(err)
	}
	if hits := relay.pool.hits.Load(); hits != 0 {
		t.Fatalf("an expired socket was used: %d hits", hits)
	}
}

func TestResetConnectionsDrainsThePool(t *testing.T) {
	server := newFakeTelegram(t)
	relay := poolRelay(t, server, Config{})
	relay.ResetConnections()
	if n := dcStatus(relay, 2).Pooled; n != 0 {
		t.Fatalf("pooled %d after reset", n)
	}
	waitFor(t, "server side close", func() bool { return server.finished.Load() >= poolSize+1 })
}

func TestPoolSkipsSocketsTheServerClosed(t *testing.T) {
	server := newFakeTelegram(t)
	relay := poolRelay(t, server, Config{})
	server.closeConns()
	time.Sleep(100 * time.Millisecond)
	if err := selfTest(t, relay, 2); err != nil {
		t.Fatalf("connection after dead pool: %v", err)
	}
	if hits := relay.pool.hits.Load(); hits != 0 {
		t.Fatalf("a dead socket was used: %d hits", hits)
	}
}
