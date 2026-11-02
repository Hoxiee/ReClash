package core

import (
	"context"
	"errors"
	"net/http"
	"net/http/httptest"
	"runtime"
	"sync"
	"sync/atomic"
	"testing"
	"time"

	"github.com/metacubex/mihomo/adapter"
	"github.com/metacubex/mihomo/adapter/outbound"
	"github.com/metacubex/mihomo/common/utils"
	"github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/tunnel"
)

type delayGatedAdapter struct {
	constant.ProxyAdapter
	gate func(context.Context) error
}

func (a delayGatedAdapter) DialContext(ctx context.Context, metadata *constant.Metadata) (constant.Conn, error) {
	if err := a.gate(ctx); err != nil {
		return nil, err
	}
	return a.ProxyAdapter.DialContext(ctx, metadata)
}

func delayGatedProxy(name string, gate func(context.Context) error) constant.Proxy {
	return adapter.NewProxy(delayGatedAdapter{
		ProxyAdapter: outbound.NewDirectWithOption(outbound.DirectOption{Name: name}),
		gate:         gate,
	})
}

func delayUnavailableProxy(name string) constant.Proxy {
	return delayGatedProxy(name, func(ctx context.Context) error {
		<-ctx.Done()
		return ctx.Err()
	})
}

func installDelayProxy(t *testing.T, proxy constant.Proxy) {
	t.Helper()
	tunnel.UpdateProxies(map[string]constant.Proxy{proxy.Name(): proxy}, nil)
	t.Cleanup(func() {
		for deadline := time.Now().Add(3 * time.Second); len(delayTestSlots) > 0; time.Sleep(time.Millisecond) {
			if time.Now().After(deadline) {
				t.Fatal("delay probes still hold slots after their deadlines")
			}
		}
		tunnel.UpdateProxies(nil, nil)
		settleMessageBatcher()
	})
}

func delayTestServer(t *testing.T) *httptest.Server {
	t.Helper()
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		time.Sleep(time.Millisecond)
		w.WriteHeader(http.StatusNoContent)
	}))
	t.Cleanup(server.Close)
	return server
}

func TestBalancerDelayReturnsWhileAnotherMemberIsUnavailable(t *testing.T) {
	server := delayTestServer(t)
	installDelayProxy(t, balanceOver(t, "Balance", delayUnavailableProxy("down"), namedProxy("up")))

	started := time.Now()
	result := handleTestDelay(&TestDelayParams{ProxyName: "Balance", TestUrl: server.URL, Timeout: 1000})

	if result == nil || result.Value <= 0 || result.Name != "Balance" || result.Url != server.URL {
		t.Fatalf("delay = %+v, want the available member's result under the requested group", result)
	}
	if elapsed := time.Since(started); elapsed > 500*time.Millisecond {
		t.Errorf("answer took %v, want it before the unavailable member times out", elapsed)
	}
}

func TestBalancerDelayDoesNotCancelAnAlreadyStartedMember(t *testing.T) {
	server := delayTestServer(t)
	started := make(chan struct{})
	release := make(chan struct{})
	unblock := sync.OnceFunc(func() { close(release) })
	slow := delayGatedProxy("slow", func(ctx context.Context) error {
		close(started)
		select {
		case <-release:
			return nil
		case <-ctx.Done():
			return ctx.Err()
		}
	})
	fast := delayGatedProxy("fast", func(ctx context.Context) error {
		select {
		case <-started:
			return nil
		case <-ctx.Done():
			return ctx.Err()
		}
	})
	installDelayProxy(t, balanceOver(t, "Balance", fast, slow))
	t.Cleanup(unblock)

	result := handleTestDelay(&TestDelayParams{ProxyName: "Balance", TestUrl: server.URL, Timeout: 2000})
	if result == nil || result.Value <= 0 {
		t.Fatalf("delay = %+v, want the faster member's result", result)
	}
	if len(slow.DelayHistory()) != 0 {
		t.Fatal("slower member completed before it was released")
	}
	unblock()
	for deadline := time.Now().Add(time.Second); len(slow.DelayHistory()) == 0; time.Sleep(time.Millisecond) {
		if time.Now().After(deadline) {
			t.Fatal("slower member never completed its own health check")
		}
	}
	if !slow.AliveForTestUrl(server.URL) {
		t.Fatal("slower member was recorded as unavailable after the first success")
	}
}

func TestBalancerDelayUnwrapsSelectorsAndNestedBalances(t *testing.T) {
	server := delayTestServer(t)
	inner := balanceOver(t, "Inner", delayUnavailableProxy("down"), namedProxy("up"))
	outer := balanceOver(t, "Outer", selectorOver(t, "Pick", inner))
	installDelayProxy(t, selectorOver(t, "Requested", outer))

	result := handleTestDelay(&TestDelayParams{ProxyName: "Requested", TestUrl: server.URL, Timeout: 1000})
	if result == nil || result.Value <= 0 {
		t.Fatalf("delay = %+v, want the live member under nested selectors and balances", result)
	}
}

func TestBalancerDelayKeepsDifferentObjectsWithTheSameName(t *testing.T) {
	server := delayTestServer(t)
	installDelayProxy(t, balanceOver(t, "Balance", delayUnavailableProxy("same"), namedProxy("same")))

	result := handleTestDelay(&TestDelayParams{ProxyName: "Balance", TestUrl: server.URL, Timeout: 1000})
	if result == nil || result.Value <= 0 {
		t.Fatalf("delay = %+v, want the available member despite duplicate names", result)
	}
}

func TestBalancerDelayDeduplicatesSharedNestedMembers(t *testing.T) {
	counts := make(map[string]*atomic.Int32)
	down := func(name string) constant.Proxy {
		count := &atomic.Int32{}
		counts[name] = count
		return delayGatedProxy(name, func(context.Context) error {
			count.Add(1)
			return errors.New("unavailable")
		})
	}
	a, b := down("a"), down("b")
	shared := balanceOver(t, "Shared", a, b)
	installDelayProxy(t, balanceOver(t, "Balance",
		balanceOver(t, "Left", shared, a),
		balanceOver(t, "Right", shared, b),
		selectorOver(t, "Pick", shared),
	))

	result := handleTestDelay(&TestDelayParams{ProxyName: "Balance", TestUrl: "http://127.0.0.1:1", Timeout: 1000})
	if result == nil || result.Value != delayFailed {
		t.Fatalf("delay = %+v, want a failed measurement", result)
	}
	for name, count := range counts {
		if got := count.Load(); got != 1 {
			t.Errorf("member %s was tested %d times, want once", name, got)
		}
	}
}

func TestBalancerDelayReturnsTimeoutWhenAllMembersTimeOut(t *testing.T) {
	installDelayProxy(t, balanceOver(t, "Balance", delayUnavailableProxy("a"), delayUnavailableProxy("b")))

	result := handleTestDelay(&TestDelayParams{ProxyName: "Balance", TestUrl: "http://127.0.0.1:1", Timeout: 40})
	if result == nil || result.Value != delayTimedOut {
		t.Fatalf("delay = %+v, want a timeout measurement", result)
	}
}

func TestBalancerDelayReturnsNoVerdictWhenNoMemberGetsASlot(t *testing.T) {
	installDelayProxy(t, balanceOver(t, "Balance", namedProxy("a"), namedProxy("b")))
	for range cap(delayTestSlots) {
		delayTestSlots <- struct{}{}
	}
	t.Cleanup(func() {
		for range cap(delayTestSlots) {
			delayTestSlots.release()
		}
	})

	result := handleTestDelay(&TestDelayParams{ProxyName: "Balance", TestUrl: "http://127.0.0.1:1", Timeout: 20})
	if result != nil {
		t.Fatalf("delay = %+v, want no verdict when every member only waited for a slot", result)
	}
}

func TestBalancerDelayCountsEachMemberAgainstTheSharedSlots(t *testing.T) {
	server := delayTestServer(t)
	entered := make(chan struct{}, 2)
	release := make(chan struct{})
	unblock := sync.OnceFunc(func() { close(release) })
	hold := func(ctx context.Context) error {
		entered <- struct{}{}
		select {
		case <-release:
			return nil
		case <-ctx.Done():
			return ctx.Err()
		}
	}
	installDelayProxy(t, balanceOver(t, "Balance", delayGatedProxy("a", hold), delayGatedProxy("b", hold)))
	t.Cleanup(unblock)
	done := make(chan *Delay, 1)
	go func() {
		done <- handleTestDelay(&TestDelayParams{ProxyName: "Balance", TestUrl: server.URL, Timeout: 2000})
	}()
	for range 2 {
		select {
		case <-entered:
		case <-time.After(time.Second):
			t.Fatal("both member probes did not start")
		}
	}
	if held := len(delayTestSlots); held != 2 {
		t.Fatalf("held slots = %d, want one per member", held)
	}
	unblock()
	if result := <-done; result == nil || result.Value <= 0 {
		t.Fatalf("delay = %+v, want a successful measurement", result)
	}
}

func TestBalancerDelayDoesNotHangAfterAMemberPanics(t *testing.T) {
	installDelayProxy(t, balanceOver(t, "Balance",
		delayGatedProxy("panic", func(context.Context) error { panic("probe") }),
		delayGatedProxy("failed", func(context.Context) error { return errors.New("unavailable") }),
	))
	done := make(chan *Delay, 1)
	go func() {
		done <- handleTestDelay(&TestDelayParams{ProxyName: "Balance", TestUrl: "http://127.0.0.1:1", Timeout: 1000})
	}()
	select {
	case result := <-done:
		if result != nil {
			t.Fatalf("delay = %+v, want no verdict after an unfinished member probe", result)
		}
	case <-time.After(time.Second):
		t.Fatal("balancer did not finish after a member panicked")
	}
}

type cyclicDelayProxy struct {
	constant.Proxy
	next constant.Proxy
}

func (p *cyclicDelayProxy) Type() constant.AdapterType { return constant.Selector }

func (p *cyclicDelayProxy) Unwrap(*constant.Metadata, bool) constant.Proxy { return p.next }

func TestBalancerDelaySkipsCyclicMembers(t *testing.T) {
	cycle := &cyclicDelayProxy{Proxy: namedProxy("cycle")}
	cycle.next = cycle
	live := namedProxy("live")
	group := balanceOver(t, "Balance", cycle, live)

	nodes, balanced := balanceDelayNodes(group)
	if !balanced || len(nodes) != 1 || nodes[0] != live {
		t.Fatalf("balanced = %v, nodes = %v, want only the non-cyclic leaf", balanced, nodes)
	}
}

func TestBalancerDelayEmptyCollectionFailsWithoutAProbe(t *testing.T) {
	value, tested := testBalancerDelay(nil, "http://127.0.0.1:1", time.Second)
	if !tested || value != delayFailed {
		t.Fatalf("value = %d, tested = %v, want a failed empty group", value, tested)
	}
}

func TestBalancerDelayPreservesTheRequestedGroupsURLTestHook(t *testing.T) {
	server := delayTestServer(t)
	hooked := make(chan *Delay, 1)
	var leafCalls atomic.Int32
	previous := adapter.UrlTestHook
	adapter.UrlTestHook = func(url, name string, delay uint16, timedOut bool) {
		if name == "Balance" {
			hooked <- &Delay{Name: name, Url: url, Value: delayValue(delay, timedOut)}
		} else {
			leafCalls.Add(1)
		}
	}
	t.Cleanup(func() { adapter.UrlTestHook = previous })
	installDelayProxy(t, balanceOver(t, "Balance", namedProxy("leaf")))

	result := handleTestDelay(&TestDelayParams{ProxyName: "Balance", TestUrl: server.URL, Timeout: 1000})
	if result == nil || result.Value <= 0 {
		t.Fatalf("delay = %+v, want the available member's result", result)
	}
	select {
	case event := <-hooked:
		if *event != *result {
			t.Errorf("hook event = %+v, want requested group result %+v", event, result)
		}
	default:
		t.Fatal("aggregate result did not reach the existing URLTestHook")
	}
	if leafCalls.Load() != 1 {
		t.Fatal("member's own health check did not retain its hook")
	}
}

type countedDelayProxy struct {
	constant.Proxy
	probe func(context.Context) (uint16, error)
}

func (p *countedDelayProxy) URLTest(ctx context.Context, _ string, _ utils.IntRanges[uint16]) (uint16, error) {
	return p.probe(ctx)
}

func TestBalancerDelayUsesBoundedWorkersAndLeavesQueuedMembersUntested(t *testing.T) {
	workers := cap(delayTestSlots)
	entered := make(chan struct{}, workers)
	winner, others := make(chan struct{}), make(chan struct{})
	releaseWinner := sync.OnceFunc(func() { close(winner) })
	releaseOthers := sync.OnceFunc(func() { close(others) })
	var calls, canceled atomic.Int32
	proxy := &countedDelayProxy{
		Proxy: namedProxy("member"),
		probe: func(ctx context.Context) (uint16, error) {
			gate := others
			if calls.Add(1) == 1 {
				gate = winner
			}
			entered <- struct{}{}
			select {
			case <-gate:
				return 10, nil
			case <-ctx.Done():
				canceled.Add(1)
				return 0, ctx.Err()
			}
		},
	}
	nodes := make([]constant.Proxy, 5000)
	for index := range nodes {
		nodes[index] = proxy
	}
	t.Cleanup(func() {
		releaseWinner()
		releaseOthers()
		for deadline := time.Now().Add(4 * time.Second); len(delayTestSlots) > 0; time.Sleep(time.Millisecond) {
			if time.Now().After(deadline) {
				t.Fatal("worker probes did not finish after release")
			}
		}
	})
	type answer struct {
		value  int32
		tested bool
	}
	done := make(chan answer, 1)
	before := runtime.NumGoroutine()
	go func() {
		value, tested := testBalancerDelay(nodes, "http://unused.test", 3*time.Second)
		done <- answer{value: value, tested: tested}
	}()
	for range workers {
		select {
		case <-entered:
		case <-time.After(time.Second):
			t.Fatal("bounded workers did not start")
		}
	}
	if started := runtime.NumGoroutine() - before; started > workers*4 {
		t.Fatalf("5000 members started %d goroutines for %d slots", started, workers)
	}
	releaseWinner()
	select {
	case result := <-done:
		if !result.tested || result.value != 10 {
			t.Fatalf("answer = %+v, want the successful member's result", result)
		}
	case <-time.After(time.Second):
		t.Fatal("first success did not complete the group test")
	}
	if got := calls.Load(); got != int32(workers) {
		t.Errorf("started %d probes, want only the %d running workers", got, workers)
	}
	if canceled.Load() != 0 {
		t.Fatal("first success canceled a probe that already held a slot")
	}
}
