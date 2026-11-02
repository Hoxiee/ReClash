package core

import (
	"context"
	"sync"
	"sync/atomic"
	"time"

	"github.com/metacubex/mihomo/adapter"
	"github.com/metacubex/mihomo/adapter/outboundgroup"
	"github.com/metacubex/mihomo/common/utils"
	"github.com/metacubex/mihomo/constant"
)

const (
	delayTestConcurrency    = 50
	defaultTestURL          = "https://www.gstatic.com/generate_204"
	defaultDelayTestTimeout = 5 * time.Second
)

var (
	delayTestSlots     = make(slots, delayTestConcurrency)
	anyDelayTestStatus utils.IntRanges[uint16]

	testURL                 atomic.Pointer[string]
	missingDelayTestProxyAt atomic.Int64
)

func setTestURL(url string) {
	if url == "" {
		return
	}
	constant.DefaultTestURL = url
	testURL.Store(&url)
}

func currentTestURL() string {
	if url := testURL.Load(); url != nil && *url != "" {
		return *url
	}
	return defaultTestURL
}

const (
	delayTimedOut int32 = -1
	delayFailed   int32 = -2
)

func delayValue(delay uint16, timedOut bool) int32 {
	switch {
	case delay > 0:
		return int32(delay)
	case timedOut:
		return delayTimedOut
	default:
		return delayFailed
	}
}

// A name the tunnel does not know is what an apply that fell back to the
// default config looks like: every node of the profile fails its test. Say so
// once a second, not once per node, so the log names the real failure.
func reportMissingDelayTestProxy(name string) {
	now := time.Now().UnixNano()
	last := missingDelayTestProxyAt.Load()
	if last != 0 && now-last < int64(time.Second) {
		return
	}
	if !missingDelayTestProxyAt.CompareAndSwap(last, now) {
		return
	}
	logError("delay test: %q is not part of the applied config", name)
}

// A nil answer means the test never got a slot, which says nothing about the proxy.
func handleTestDelay(params *TestDelayParams) *Delay {
	url := params.TestUrl
	if url == "" {
		url = currentTestURL()
	}
	result := &Delay{Name: params.ProxyName, Url: url, Value: delayFailed}

	proxy := lookupProxy(params.ProxyName)
	if proxy == nil {
		reportMissingDelayTestProxy(params.ProxyName)
		return result
	}

	timeout := timeoutFromMillis(params.Timeout, defaultDelayTestTimeout)
	nodes, balanced := balanceDelayNodes(proxy)
	var value int32
	var tested bool
	if balanced {
		value, tested = testBalancerDelay(nodes, url, timeout)
	} else {
		value, tested = testProxyDelay(context.Background(), proxy, url, timeout)
	}
	if !tested {
		return nil
	}
	if balanced && adapter.UrlTestHook != nil {
		var measured uint16
		if value > 0 {
			measured = uint16(value)
		}
		adapter.UrlTestHook(url, proxy.Name(), measured, value == delayTimedOut)
	}
	result.Value = value
	return result
}

func testProxyDelay(wait context.Context, proxy constant.Proxy, url string, timeout time.Duration) (int32, bool) {
	if !delayTestSlots.acquireWithin(wait, timeout) {
		return 0, false
	}
	defer delayTestSlots.release()

	// A successful sibling can cancel the wait, never a started health check:
	// mihomo records a canceled probe as a failure of that node.
	ctx, cancel := context.WithTimeout(context.Background(), timeout)
	defer cancel()
	delay, err := proxy.URLTest(ctx, url, anyDelayTestStatus)
	if err != nil {
		delay = 0
	}
	return delayValue(delay, ctx.Err() != nil), true
}

func testBalancerDelay(nodes []constant.Proxy, url string, timeout time.Duration) (int32, bool) {
	type nodeDelay struct {
		value  int32
		tested bool
	}
	wait, stopWaiting := context.WithTimeout(context.Background(), timeout)
	defer stopWaiting()
	answered, stopSending := context.WithCancel(context.Background())
	defer stopSending()
	workers := min(len(nodes), cap(delayTestSlots))
	results := make(chan nodeDelay, workers)
	var next atomic.Int64
	var running sync.WaitGroup
	for range workers {
		running.Add(1)
		safeGo("balancer delay test", func() {
			defer running.Done()
			for wait.Err() == nil {
				index := int(next.Add(1)) - 1
				if index >= len(nodes) {
					return
				}
				value, tested := testProxyDelay(wait, nodes[index], url, timeout)
				if value > 0 {
					stopWaiting()
				}
				select {
				case results <- nodeDelay{value: value, tested: tested}:
				case <-answered.Done():
					return
				}
			}
		})
	}
	safeGo("balancer delay completion", func() {
		running.Wait()
		close(results)
	})
	value, complete, received := delayFailed, true, 0
	for result := range results {
		received++
		if result.value > 0 {
			return result.value, true
		}
		complete = complete && result.tested
		value = max(value, result.value)
	}
	return value, complete && received == len(nodes)
}

func balanceDelayNodes(proxy constant.Proxy) (nodes []constant.Proxy, balanced bool) {
	pending := []constant.Proxy{proxy}
	seen := map[constant.Proxy]bool{}
	for len(pending) > 0 {
		proxy = pending[len(pending)-1]
		pending = pending[:len(pending)-1]
		if proxy == nil || seen[proxy] {
			continue
		}
		seen[proxy] = true
		if group, ok := adapterAs[*outboundgroup.LoadBalance](proxy); ok {
			balanced = true
			pending = append(pending, group.GetProxies(false)...)
			continue
		}
		if proxy.Type() == constant.Selector || proxy.Type() == constant.URLTest || proxy.Type() == constant.Fallback {
			if selected := proxy.Unwrap(nil, false); selected != nil {
				pending = append(pending, selected)
				continue
			}
		}
		nodes = append(nodes, proxy)
	}
	return nodes, balanced
}
