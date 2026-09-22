package rcx

import (
	"strings"
	"time"

	"github.com/metacubex/mihomo/tunnel/statistic"
)

// An aggregate falls when a connection closes, so it cannot show a freeze.
type rcxConnSample struct {
	Key   string
	Node  string
	Host  string
	Up    int64
	Down  int64
	Start time.Time
}

// The hook fires before a single byte, so a sighting keeps the counter to judge.
type rcxOpenSighting struct {
	node string
	at   time.Time
	info *statistic.TrackerInfo
}

func rcxMarkerRelated(markers map[string]struct{}, host string) bool {
	if host == "" {
		return false
	}
	for marker := range markers {
		if rcxHostRelated(host, marker) {
			return true
		}
	}
	return false
}

func rcxHostRelated(host, marker string) bool {
	return host == marker ||
		strings.HasSuffix(host, "."+marker) ||
		strings.HasSuffix(marker, "."+host)
}

// Evidence is only worth keeping while rules decide the route and only about
// nodes the skeleton actually offers: DIRECT and canary dials go through the same
// hook.
func (e *rcxEngine) drainDials() bool {
	if len(e.dials) == 0 {
		return false
	}
	now := e.runtime.Now()
	terrain := e.terrainCurrent()
	keep := e.Enabled() && e.runtime.Mode() == "rule"
	if keep {
		e.ensureIdentity()
	}
	answered, changed := false, false
drain:
	for {
		select {
		case event := <-e.dials:
			if !keep || !e.isMember(event.Node) {
				continue
			}
			at := event.At
			if at.IsZero() {
				at = now
			}
			if event.Failed {
				if !e.chargesNegative(at) {
					continue
				}
				if e.ledger.NoteDialFailure(e.key(event.Node), e.envKey, terrain, at) {
					changed = true
					e.escrowNegative(event.Node, 1, at)
					e.noteProviderNodeFailure(event.Node, at)
				}
				continue
			}
			valid, refunded := e.ledger.noteDialSuccess(e.key(event.Node), e.envKey, event.Elapsed, at)
			answered = answered || valid
			changed = changed || refunded
		default:
			break drain
		}
	}
	if answered {
		changed = changed || len(e.charged) > 0
		e.noteLinkAlive(now)
	}
	return changed
}

type rcxNodeFlow struct {
	live     int
	stalled  int
	progress bool
	open     bool
}

// Only what comes back proves transit: a black hole absorbs upload unacknowledged.
func (e *rcxEngine) sampleTraffic() {
	now := e.runtime.Now()
	conns := e.runtime.Connections()
	previous := e.conns
	previousUp := e.upConns
	e.conns = make(map[string]int64, len(conns))
	e.upConns = make(map[string]int64, len(conns))
	e.mu.RLock()
	markers := e.openHosts
	e.mu.RUnlock()
	flows := make(map[string]*rcxNodeFlow, len(conns))
	alive := false
	for _, conn := range conns {
		answered := conn.Down > previous[conn.Key]
		_, seen := previous[conn.Key]
		uploading := seen && conn.Up > previousUp[conn.Key]
		alive = alive || answered
		e.conns[conn.Key] = conn.Down
		e.upConns[conn.Key] = conn.Up
		if conn.Node == "" || conn.Node == "DIRECT" {
			continue
		}
		flow := flows[conn.Node]
		if flow == nil {
			flow = &rcxNodeFlow{}
			flows[conn.Node] = flow
		}
		flow.live++
		switch {
		case answered:
			flow.progress = true
			flow.open = flow.open || rcxMarkerRelated(markers, conn.Host)
		// Growing Up is a live link (§1.9); only payload never answered nor still uploading accuses.
		case conn.Down == 0 && conn.Up > 0 && !uploading && now.Sub(conn.Start) >= rcxConnStallAge:
			flow.stalled++
			if conn.Node == e.incumbent {
				e.incidentConns[conn.Key] = struct{}{}
			}
		}
	}
	if alive {
		e.noteLinkAlive(now)
	}
	for node, flow := range flows {
		switch {
		case flow.progress:
			e.notePayload(node, flow.open, now)
			if node == e.incumbent {
				for _, conn := range conns {
					if conn.Node == node && conn.Down > previous[conn.Key] {
						delete(e.incidentConns, conn.Key)
					}
				}
			}
		case flow.stalled*2 > flow.live:
			e.trackFrozenPayload(node, now)
		default:
			delete(e.downFrozen, e.key(node))
		}
	}
	active := make(map[string]struct{}, len(flows))
	for node := range flows {
		active[e.key(node)] = struct{}{}
	}
	for key := range e.downFrozen {
		if _, ok := active[key]; !ok {
			delete(e.downFrozen, key)
		}
	}
	e.harvestOpenSightings(now)
}

// Negative evidence is durable only after the direct path has established its
// regime. Unknown links, portals and dead radios cannot identify a bad node.
func (e *rcxEngine) chargesNegative(now time.Time) bool {
	if !e.suspendTo.IsZero() && now.Sub(e.suspendTo) < rcxWakeGrace {
		return false
	}
	switch e.terrainCurrent() {
	case rcxTerrainNormal, rcxTerrainWhitelist:
		return true
	default:
		return false
	}
}

// The weight is what the fact added to the streak, so a refund gives that back.
func (e *rcxEngine) escrowNegative(node string, weight int, now time.Time) {
	if len(e.charged) == 0 {
		e.chargedAt = now
	}
	e.charged[e.key(node)] += weight
	if len(e.charged) >= e.escrowQuorum() && !e.escrowReach {
		e.supersedeReach()
		e.startReach()
	}
}

// A dead uplink shows on the one node carrying traffic, so a pair never fires.
func (e *rcxEngine) escrowQuorum() int {
	if e.incumbent != "" {
		if _, ok := e.charged[e.key(e.incumbent)]; ok {
			return 1
		}
	}
	return rcxLinkFailQuorum
}

func (e *rcxEngine) noteLinkAlive(now time.Time) {
	if len(e.charged) == 0 {
		return
	}
	if len(e.charged) >= e.escrowQuorum() && now.Sub(e.chargedAt) >= rcxLinkDark {
		e.ledger.RollbackFailures(e.envKey, e.charged)
	}
	e.charged = map[string]int{}
	e.chargedAt = time.Time{}
	e.escrowReach = false
}

// The answer that ends an escrow may never come; a settled dark verdict stands.
func (e *rcxEngine) rollbackEscrow() {
	if len(e.charged) == 0 {
		return
	}
	e.ledger.RollbackFailures(e.envKey, e.charged)
	e.charged = map[string]int{}
	e.chargedAt = time.Time{}
	e.escrowReach = false
}

func (e *rcxEngine) notePayload(node string, openWorld bool, now time.Time) {
	key := e.key(node)
	delete(e.downFrozen, key)
	e.ledger.NoteTrafficProgress(key, e.envKey, openWorld, now)
	e.ledger.ClearDegraded(key, e.envKey)
	if node == e.incumbent {
		e.closeIncident(now, true)
	}
	e.noteProviderSuccess(node)
}

func (e *rcxEngine) confirmWindow(key, node string) time.Duration {
	full := time.Duration(e.cfg.DegradeConfirmSeconds) * time.Second
	if node != e.incumbent {
		return full
	}
	if !e.ledger.ProgressAt(key, e.envKey).IsZero() || !e.ledger.OpenAt(key, e.envKey).IsZero() {
		return full
	}
	cold := rcxColdConfirmSec * time.Second
	if cold < full {
		return cold
	}
	return full
}

func (e *rcxEngine) trackFrozenPayload(node string, now time.Time) {
	if !e.chargesNegative(now) {
		return
	}
	key := e.key(node)
	if now.Before(e.ledger.CoolUntil(key, e.envKey, now)) {
		return
	}
	if e.runtime.Mode() != "rule" || e.runtime.Members() == nil {
		return
	}
	if e.ledger.TrafficAt(key, e.envKey).IsZero() && len(e.ledger.Samples(key, e.envKey)) > 0 {
		return
	}
	frozen := e.downFrozen[key]
	if frozen.IsZero() {
		e.downFrozen[key] = now
		return
	}
	if now.Sub(frozen) < e.confirmWindow(key, node) {
		return
	}
	e.ledger.NoteDegraded(key, e.envKey, now)
	e.escrowNegative(node, 0, now)
	if node == e.incumbent {
		e.ledger.NoteIncumbentStalled(key, e.envKey, now)
	}
}

// Progress beside a sighting is a coincidence: only marker bytes prove it.
func (e *rcxEngine) harvestOpenSightings(now time.Time) {
	answered := make([]string, 0, 2)
	e.mu.Lock()
	for key, sighting := range e.openSeen {
		down := sighting.info.DownloadTotal.Load()
		if down <= 0 && now.Sub(sighting.at) < rcxOpenSightWindow {
			continue
		}
		delete(e.openSeen, key)
		if down > 0 {
			answered = append(answered, sighting.node)
		}
	}
	e.mu.Unlock()
	for _, node := range answered {
		e.notePayload(node, true, now)
	}
}
