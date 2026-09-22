package main

import (
	"sync"

	"core/rcx"
)

type networkFactsPayload = rcx.NetworkPayload

type networkFactsFanout struct {
	mu      sync.Mutex
	current networkFactsPayload
	has     bool
	bump    func()
	network func(networkFactsPayload)
}

func (fanout *networkFactsFanout) Snapshot() (networkFactsPayload, bool) {
	fanout.mu.Lock()
	defer fanout.mu.Unlock()
	return rcx.CloneNetworkFacts(fanout.current), fanout.has
}

func (fanout *networkFactsFanout) Update(payload networkFactsPayload) {
	changed := fanout.changed(payload)
	if changed && fanout.bump != nil {
		fanout.bump()
	}
	if fanout.network != nil {
		fanout.network(payload)
	}
}

func (fanout *networkFactsFanout) changed(payload networkFactsPayload) bool {
	normalized := rcx.NormalizeNetworkFacts(payload)
	fanout.mu.Lock()
	defer fanout.mu.Unlock()
	if fanout.has && rcx.EqualNetworkFacts(fanout.current, normalized) {
		return false
	}
	fanout.current = rcx.CloneNetworkFacts(normalized)
	fanout.has = true
	return true
}

var coreNetworkFacts = networkFactsFanout{
	bump: func() {
		doctorBumpGeneration(doctorEnvironmentGeneration)
	},
	network: func(payload networkFactsPayload) {
		rcxEngineInstance.Network(payload)
	},
}
