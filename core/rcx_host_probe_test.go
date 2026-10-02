package main

import (
	"context"
	"sync/atomic"
	"testing"
	"time"

	"github.com/metacubex/mihomo/adapter"
	"github.com/metacubex/mihomo/constant"
)

type rcxEpochProbeAdapter struct {
	constant.ProxyAdapter
	calls   atomic.Uint32
	started chan struct{}
	release chan struct{}
}

func (p *rcxEpochProbeAdapter) DialContext(ctx context.Context, metadata *constant.Metadata) (constant.Conn, error) {
	if p.calls.Add(1) == 1 {
		close(p.started)
		select {
		case <-p.release:
		case <-ctx.Done():
			return nil, ctx.Err()
		}
	}
	return p.ProxyAdapter.DialContext(ctx, metadata)
}

func TestHostProbeRejectsLateResultsFromPreviousNetwork(t *testing.T) {
	for _, fail := range []bool{false, true} {
		t.Run(map[bool]string{false: "late success", true: "late failure"}[fail], func(t *testing.T) {
			var generation, harvested atomic.Uint32
			cache := rcxHostProbeCache{
				generation: generation.Load,
				harvest:    func(string, string, int, uint32) { harvested.Add(1) },
			}
			controlled := &rcxEpochProbeAdapter{
				ProxyAdapter: namedProxy("node").(*adapter.Proxy).ProxyAdapter,
				started:      make(chan struct{}),
				release:      make(chan struct{}),
			}
			node := adapter.NewProxy(controlled)
			url := rcxLiveServerURL(t)
			ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
			t.Cleanup(cancel)
			t.Cleanup(settleMessageBatcher)
			done := make(chan error, 1)
			go func() {
				_, err := cache.test(ctx, node, url)
				done <- err
			}()
			select {
			case <-controlled.started:
			case <-ctx.Done():
				t.Fatal("the old-network probe never started")
			}

			generation.Add(1)
			if _, err := cache.test(ctx, node, url); err != nil {
				t.Fatalf("the new network must answer: %v", err)
			}
			_, dead, confirmedAt := cache.info(node, url)
			if dead || confirmedAt.IsZero() {
				t.Fatal("the current-network success was not recorded")
			}
			if fail {
				cancel()
			} else {
				close(controlled.release)
			}
			select {
			case err := <-done:
				if (err != nil) != fail {
					t.Fatalf("old probe error = %v, want failure=%v", err, fail)
				}
			case <-time.After(time.Second):
				t.Fatal("the old-network probe did not finish")
			}
			_, dead, at := cache.info(node, url)
			if dead || !at.Equal(confirmedAt) || harvested.Load() != 1 {
				t.Fatalf("late result changed the current network: dead=%v at=%v harvested=%d", dead, at, harvested.Load())
			}
			if fail && node.AliveForTestUrl(url) {
				t.Fatal("the setup must leave stale failure in mihomo history while RCX stays healthy")
			}
		})
	}
}

func TestHostProbeCacheExpiresAcrossNetworksAndMembership(t *testing.T) {
	var generation atomic.Uint32
	cache := rcxHostProbeCache{generation: generation.Load}
	node := namedProxy("node")
	key := rcxHostProbeKey{node: node, url: "https://probe.example"}
	cache.record(key, rcxHostProbeSample{delay: 70, at: time.Now()})
	generation.Add(1)
	if delay, dead, at := cache.info(node, key.url); delay != 0 || dead || !at.IsZero() {
		t.Fatal("a previous-network sample survived the generation change")
	}
	cache.record(key, rcxHostProbeSample{generation: 1, delay: 70, at: time.Now()})
	if delay, dead, _ := cache.info(node, key.url); delay != 70 || dead {
		t.Fatal("a current-network sample was rejected")
	}
	cache.retain([]constant.Proxy{namedProxy("node")}, key.url)
	if len(cache.samples) != 0 {
		t.Fatal("a replaced endpoint stayed retained by the host cache")
	}
}
