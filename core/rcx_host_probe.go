package main

import (
	"context"
	"sync"
	"time"

	"github.com/metacubex/mihomo/constant"
)

type rcxHostProbeKey struct {
	node constant.Proxy
	url  string
}

type rcxHostProbeSample struct {
	generation uint32
	delay      uint16
	dead       bool
	at         time.Time
}

type rcxHostProbeCache struct {
	mu         sync.Mutex
	samples    map[rcxHostProbeKey]rcxHostProbeSample
	generation func() uint32
	harvest    func(string, string, int, uint32)
}

var rcxHostProbes = rcxHostProbeCache{
	generation: func() uint32 { return rcxEngineInstance.NetworkGeneration() },
	harvest: func(url, node string, delay int, generation uint32) {
		rcxEngineInstance.NoteHarvestedProbe(url, node, delay, generation)
	},
}

func (c *rcxHostProbeCache) test(ctx context.Context, node constant.Proxy, url string) (uint16, error) {
	generation := c.generation()
	delay, err := node.URLTest(ctx, url, anyDelayTestStatus)
	c.record(rcxHostProbeKey{node: node, url: url}, rcxHostProbeSample{
		generation: generation, delay: delay, dead: err != nil, at: time.Now(),
	})
	return delay, err
}

func (c *rcxHostProbeCache) record(key rcxHostProbeKey, sample rcxHostProbeSample) {
	c.mu.Lock()
	if sample.generation != c.generation() {
		c.mu.Unlock()
		return
	}
	if c.samples == nil {
		c.samples = make(map[rcxHostProbeKey]rcxHostProbeSample)
	}
	c.samples[key] = sample
	c.mu.Unlock()
	if c.harvest != nil {
		delay := int(sample.delay)
		if sample.dead {
			delay = 0
		}
		c.harvest(key.url, key.node.Name(), delay, sample.generation)
	}
}

func (c *rcxHostProbeCache) info(node constant.Proxy, url string) (int, bool, time.Time) {
	c.mu.Lock()
	defer c.mu.Unlock()
	sample, ok := c.samples[rcxHostProbeKey{node: node, url: url}]
	if !ok || sample.generation != c.generation() {
		return 0, false, time.Time{}
	}
	if sample.dead {
		return 0, true, sample.at
	}
	delay, _ := rcxHostDelayValue(sample.delay)
	return delay, false, sample.at
}

func (c *rcxHostProbeCache) retain(nodes []constant.Proxy, url string) {
	active := make(map[constant.Proxy]struct{}, len(nodes))
	for _, node := range nodes {
		active[node] = struct{}{}
	}
	c.mu.Lock()
	defer c.mu.Unlock()
	generation := c.generation()
	for key, sample := range c.samples {
		_, present := active[key.node]
		if !present || key.url != url || sample.generation != generation {
			delete(c.samples, key)
		}
	}
}
