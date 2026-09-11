package main

import "sync"

// The event channel streams and drops, and a park-wide delay test is what fills
// it: control intents are latest-wins, so they wait in slots instead of a queue.
type rcxControl struct {
	mu        sync.Mutex
	config    *rcxConfig
	enabled   *bool
	network   *rcxNetworkPayload
	screenOff bool
	screenOn  bool
	frozen    bool
	thawed    bool
	pick      *rcxEvent
	deep      bool
	wake      chan struct{}
}

func newRcxControl() *rcxControl {
	return &rcxControl{wake: make(chan struct{}, 1)}
}

func (c *rcxControl) signal() {
	select {
	case c.wake <- struct{}{}:
	default:
	}
}

// A whole config carries the flag, so it supersedes a toggle waiting beside it.
func (c *rcxControl) Configure(config rcxConfig) {
	c.mu.Lock()
	c.config = &config
	c.enabled = nil
	c.mu.Unlock()
	c.signal()
}

func (c *rcxControl) SetEnabled(enabled bool) {
	c.mu.Lock()
	c.enabled = &enabled
	c.mu.Unlock()
	c.signal()
}

func (c *rcxControl) Network(payload rcxNetworkPayload) {
	c.mu.Lock()
	c.network = &payload
	c.mu.Unlock()
	c.signal()
}

func (c *rcxControl) ScreenOff(off bool) {
	c.mu.Lock()
	if off {
		c.screenOff = true
	} else {
		c.screenOn = true
	}
	c.mu.Unlock()
	c.signal()
}

// A pair of edges, not a state: collapsing loses the window or the recovery probe.
func (c *rcxControl) Suspend(suspended bool) {
	c.mu.Lock()
	if suspended {
		c.frozen = true
	} else {
		c.thawed = true
	}
	c.mu.Unlock()
	c.signal()
}

func (c *rcxControl) Pick(event rcxEvent) {
	c.mu.Lock()
	c.pick = &event
	c.mu.Unlock()
	c.signal()
}

func (c *rcxControl) DeepScan() {
	c.mu.Lock()
	c.deep = true
	c.mu.Unlock()
	c.signal()
}

// Fixed order: a pick is stored under the environment key, so a handoff precedes it.
func (c *rcxControl) take() []rcxEvent {
	c.mu.Lock()
	defer c.mu.Unlock()

	events := make([]rcxEvent, 0, 9)
	if c.config != nil {
		events = append(events, rcxEvent{Kind: rcxEventConfigure, Config: *c.config})
		c.config = nil
	}
	if c.enabled != nil {
		events = append(events, rcxEvent{Kind: rcxEventSetEnabled, Flag: *c.enabled})
		c.enabled = nil
	}
	if c.network != nil {
		events = append(events, rcxEvent{Kind: rcxEventNetwork, Payload: *c.network})
		c.network = nil
	}
	if c.screenOff {
		events = append(events, rcxEvent{Kind: rcxEventScreenOff, Flag: true})
		c.screenOff = false
	}
	if c.frozen {
		events = append(events, rcxEvent{Kind: rcxEventSuspend, Flag: true})
		c.frozen = false
	}
	if c.thawed {
		events = append(events, rcxEvent{Kind: rcxEventSuspend, Flag: false})
		c.thawed = false
	}
	if c.screenOn {
		events = append(events, rcxEvent{Kind: rcxEventScreenOff, Flag: false})
		c.screenOn = false
	}
	if c.pick != nil {
		events = append(events, *c.pick)
		c.pick = nil
	}
	if c.deep {
		events = append(events, rcxEvent{Kind: rcxEventDeepScan})
		c.deep = false
	}
	return events
}
