package rcx

import (
	"testing"
	"time"
)

var throttleConns = []string{"r0", "r1", "r2"}

// Open a live request set on the node and take the first sample, which has no prior
// to read demand from and lands as healthy progress that sets the full confirm window.
func armThrottleFlow(runtime *fakeRuntime, engine *rcxEngine) {
	for _, key := range throttleConns {
		runtime.openConn(key, "node", "example.org")
	}
	runtime.advance(rcxWatchInterval)
	for _, key := range throttleConns {
		runtime.bumpConn(key, 2000, 2000)
	}
	engine.sampleTraffic()
}

func crawlThrottleFlow(runtime *fakeRuntime, up, down int64) {
	for _, key := range throttleConns {
		runtime.bumpConn(key, up, down)
	}
}

// A trickle under active demand answers just enough to keep the freeze detector
// quiet, so the rate floor is the only thing that can name it a squeeze.
func TestThrottleCondemnsACrawlingIncumbentUnderDemand(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("node")
	engine := newTestEngine(runtime, "ru")
	engine.incumbent = "node"
	key := engine.key("node")

	armThrottleFlow(runtime, engine)

	confirm := engine.confirmWindow(key, "node")
	armed := runtime.Now()
	for runtime.Now().Sub(armed) <= confirm+rcxWatchInterval {
		runtime.advance(rcxWatchInterval)
		crawlThrottleFlow(runtime, 1000, 1000) // ~600 B/s down against a 16 KB/s floor, uplink alive
		engine.sampleTraffic()
	}

	if !engine.ledger.Degraded(key, engine.envKey, runtime.Now()) {
		t.Error("a sustained sub-floor crawl under demand must degrade the node")
	}
	if !engine.ledger.Stalled(key, engine.envKey) {
		t.Error("a throttled incumbent must be marked stalled so the escape can trap it")
	}
	if _, ok := engine.throttled[key]; !ok {
		t.Error("the throttle arm must persist through the crawl, not clear on trickle progress")
	}
}

// No requests going out means no one is waiting on bytes: a quiet link is idle,
// never throttled, however little comes back.
func TestThrottleIgnoresAnIdleLinkWithNoDemand(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("node")
	engine := newTestEngine(runtime, "ru")
	engine.incumbent = "node"
	key := engine.key("node")

	armThrottleFlow(runtime, engine)

	for i := 0; i < 20; i++ {
		runtime.advance(rcxWatchInterval)
		crawlThrottleFlow(runtime, 0, 200) // downlink drips, uplink flat: no demand
		engine.sampleTraffic()
	}

	if engine.ledger.Degraded(key, engine.envKey, runtime.Now()) {
		t.Error("a link with no outgoing demand must never read as throttled")
	}
	if len(engine.throttled) != 0 {
		t.Error("an idle node must not arm the throttle tracker")
	}
}

// One slow endpoint is a slow server, not a squeeze: a squeeze holds the whole
// connection set under the floor at once, so a lone crawling flow is spared.
func TestThrottleSparesALoneCrawlingFlow(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("node")
	engine := newTestEngine(runtime, "ru")
	engine.incumbent = "node"
	key := engine.key("node")

	runtime.openConn("solo", "node", "example.org")
	runtime.advance(rcxWatchInterval)
	runtime.bumpConn("solo", 2000, 2000)
	engine.sampleTraffic()

	for i := 0; i < 20; i++ {
		runtime.advance(rcxWatchInterval)
		runtime.bumpConn("solo", 1000, 1000)
		engine.sampleTraffic()
	}

	if engine.ledger.Degraded(key, engine.envKey, runtime.Now()) {
		t.Error("a single crawling flow is a slow server, not a throttled link")
	}
	if len(engine.throttled) != 0 {
		t.Error("one flow under the floor must not arm the throttle tracker")
	}
}

// A node moving real bytes sits far above the floor; demand or not, it is healthy.
func TestThrottleSparesANodeAboveTheFloor(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("node")
	engine := newTestEngine(runtime, "ru")
	engine.incumbent = "node"
	key := engine.key("node")

	armThrottleFlow(runtime, engine)

	for i := 0; i < 20; i++ {
		runtime.advance(rcxWatchInterval)
		crawlThrottleFlow(runtime, 1000, 1<<20) // well over the floor
		engine.sampleTraffic()
	}

	if engine.ledger.Degraded(key, engine.envKey, runtime.Now()) {
		t.Error("a node pulling bytes over the floor is not throttled")
	}
	if len(engine.throttled) != 0 {
		t.Error("healthy throughput must not arm the throttle tracker")
	}
}

// A sample that spans a park reads a tiny rate over a huge window; the bound keeps
// a resumed engine from condemning a node for the idle it slept through.
func TestThrottleDistrustsASampleThatSpansAPark(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("node")
	engine := newTestEngine(runtime, "ru")
	engine.incumbent = "node"
	key := engine.key("node")

	armThrottleFlow(runtime, engine)

	for i := 0; i < 6; i++ {
		runtime.advance(rcxThrottleMaxSample + time.Minute)
		crawlThrottleFlow(runtime, 1000, 1000)
		engine.sampleTraffic()
	}

	if engine.ledger.Degraded(key, engine.envKey, runtime.Now()) {
		t.Error("a rate measured across a park is not evidence of a squeeze")
	}
	if len(engine.throttled) != 0 {
		t.Error("an out-of-window sample must not arm the throttle tracker")
	}
}

// Only a trusted terrain can identify a bad node; a squeeze read under an unknown
// link would blame the node for the network.
func TestThrottleHoldsWithoutATrustedTerrain(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("node")
	engine := newTestEngine(runtime, "ru")
	engine.incumbent = "node"
	engine.terrain.observe(rcxTerrainPortal, runtime.Now())
	key := engine.key("node")

	armThrottleFlow(runtime, engine)

	for i := 0; i < 20; i++ {
		runtime.advance(rcxWatchInterval)
		crawlThrottleFlow(runtime, 1000, 1000)
		engine.sampleTraffic()
	}

	if engine.ledger.Degraded(key, engine.envKey, runtime.Now()) {
		t.Error("a portal cannot prove a node is throttled")
	}
	if len(engine.throttled) != 0 {
		t.Error("negative evidence must not accrue outside a trusted terrain")
	}
}

// The squeeze lifts: healthy throughput must clear the verdict on its own.
func TestThrottleRecoversWhenThroughputReturns(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("node")
	engine := newTestEngine(runtime, "ru")
	engine.incumbent = "node"
	key := engine.key("node")

	armThrottleFlow(runtime, engine)

	confirm := engine.confirmWindow(key, "node")
	armed := runtime.Now()
	for runtime.Now().Sub(armed) <= confirm+rcxWatchInterval {
		runtime.advance(rcxWatchInterval)
		crawlThrottleFlow(runtime, 1000, 1000)
		engine.sampleTraffic()
	}
	if !engine.ledger.Degraded(key, engine.envKey, runtime.Now()) {
		t.Fatal("precondition: the node should be degraded before recovery")
	}

	runtime.advance(rcxWatchInterval)
	crawlThrottleFlow(runtime, 1000, 1<<20)
	engine.sampleTraffic()

	if engine.ledger.Degraded(key, engine.envKey, runtime.Now()) {
		t.Error("throughput back over the floor must clear the throttle verdict")
	}
	if len(engine.throttled) != 0 {
		t.Error("recovery must release the throttle arm")
	}
}
