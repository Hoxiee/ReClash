package main

import (
	"context"
	"maps"
	"sync"
	"sync/atomic"
	"time"

	"github.com/metacubex/mihomo/adapter"
	"github.com/metacubex/mihomo/adapter/outboundgroup"
	C "github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/tunnel"
)

// mihomo has no hook for a health check moving a URLTest or Fallback pick, so
// the picks are re-read on this timer while the host watches. The readout is
// advisory, so a coarse period keeps the idle wake cheap.
const routePollInterval = 2 * time.Second

type pickableGroup interface {
	outboundgroup.ProxyGroup
	outboundgroup.SelectAble
}

type routeTracker struct {
	mu               sync.Mutex
	epoch            uint64
	picksVersion     uint64
	picks            map[string]string
	providerVersions map[string]uint32
	watched          bool
	watchSeq         uint64
	stopPoll         context.CancelFunc
}

var (
	currentRoute routeTracker

	// A url-test/fallback/load-balance group moves its own pick on a health
	// check with no event to announce it, so only such a config needs the poll;
	// a config of manual selectors changes picks solely through events.
	routeHasAutoGroup atomic.Bool

	publishRoute = func(state RouteState) {
		sendMessage(Message{Type: RouteChangedMessage, Data: state})
	}
)

func routeStateLocked() RouteState {
	picks := currentRoute.picks
	if picks == nil {
		picks = map[string]string{}
	}
	return RouteState{
		CoreEpoch:    currentRoute.epoch,
		PicksVersion: currentRoute.picksVersion,
		Picks:        maps.Clone(picks),
	}
}

func routeStamp() (epoch, picksVersion uint64) {
	currentRoute.mu.Lock()
	defer currentRoute.mu.Unlock()
	return currentRoute.epoch, currentRoute.picksVersion
}

func readPicks() (map[string]string, map[string]uint32) {
	picks := map[string]string{}
	hasAuto := false
	for name, proxy := range tunnel.AllProxies() {
		outbound, ok := proxy.(*adapter.Proxy)
		if !ok {
			continue
		}
		group, ok := outbound.ProxyAdapter.(pickableGroup)
		if !ok {
			continue
		}
		picks[name] = group.Now()
		switch group.Type() {
		case C.URLTest, C.Fallback, C.LoadBalance:
			hasAuto = true
		}
	}
	routeHasAutoGroup.Store(hasAuto)
	providers := tunnel.ProvidersSnapshot()
	versions := make(map[string]uint32, len(providers))
	for name, p := range providers {
		versions[name] = p.Version()
	}
	return picks, versions
}

// A provider that swapped its list is a structural change: the names may
// survive while the servers behind them do not. The caller holds selectMu.
func refreshRouteLocked(structural bool) {
	picks, versions := readPicks()

	currentRoute.mu.Lock()
	if currentRoute.providerVersions != nil && !maps.Equal(versions, currentRoute.providerVersions) {
		structural = true
	}
	currentRoute.providerVersions = versions
	if structural {
		currentRoute.epoch++
	}
	changed := structural
	if !maps.Equal(picks, currentRoute.picks) {
		currentRoute.picks = picks
		currentRoute.picksVersion++
		changed = true
	}
	watched := currentRoute.watched
	// The clone in routeStateLocked is only worth paying for when a watcher
	// will actually receive it; an unchanged tick skips it entirely.
	var state RouteState
	if changed && watched {
		state = routeStateLocked()
	}
	currentRoute.mu.Unlock()

	if changed && watched {
		publishRoute(state)
	}
}

func refreshRoute() {
	selectMu.Lock()
	defer selectMu.Unlock()
	refreshRouteLocked(false)
}

func bumpRouteEpoch() {
	selectMu.Lock()
	defer selectMu.Unlock()
	refreshRouteLocked(true)
}

func handleWatchRoute(watch bool, seq uint64) RouteState {
	refreshRoute()

	currentRoute.mu.Lock()
	defer currentRoute.mu.Unlock()
	if seq < currentRoute.watchSeq {
		return routeStateLocked()
	}
	currentRoute.watchSeq = seq
	currentRoute.watched = watch
	if watch && currentRoute.stopPoll == nil {
		ctx, cancel := context.WithCancel(context.Background())
		currentRoute.stopPoll = cancel
		go pollRoute(ctx)
	}
	if !watch {
		stopRoutePollLocked()
	}
	return routeStateLocked()
}

func stopRouteWatch() {
	currentRoute.mu.Lock()
	defer currentRoute.mu.Unlock()
	currentRoute.watchSeq = max(currentRoute.watchSeq, methodCallSeq.Load())
	currentRoute.watched = false
	stopRoutePollLocked()
}

func stopRoutePollLocked() {
	if currentRoute.stopPoll != nil {
		currentRoute.stopPoll()
		currentRoute.stopPoll = nil
	}
}

// With the listeners down the host pins every probe to DIRECT, so the picks
// do not matter until they come back. A screen-off device says nothing about
// the route either, and polling then is the drain the health check already
// learned to avoid. A manual-selector config moves its picks only through
// events, so the scan there would never see a change and is skipped outright.
func pollRoute(ctx context.Context) {
	ticker := time.NewTicker(routePollInterval)
	defer ticker.Stop()
	for {
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
			if isRunning.Load() && !isScreenOff.Load() && routeHasAutoGroup.Load() {
				refreshRoute()
			}
		}
	}
}
