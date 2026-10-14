package rcx

import (
	"context"
	"time"
)

// The passive detector (rcx_traffic.go) only judges nodes under live demand; a
// standby carries none, so a squeeze on it stays invisible until a switch lands on
// it. The shape probe reads one standby's arrival curve (rcx_clamp.go) to close that
// gap. It rides the maintain tick (no new ticker), one standby per tick at most.
const (
	rcxShapeInterval = 5 * time.Minute
	rcxShapeTimeout  = 20 * time.Second
	rcxShapeWindow   = rcxShapeTimeout + 2*time.Second
	rcxShapeConfirm  = 2
)

type rcxShapeReading struct {
	verdict rcxClampVerdict
	kbps    int
	at      time.Time
}

// Empty until the standby is actually measured, so the report omits the column for
// nodes the probe never reached rather than defaulting them to "inconclusive".
func (r rcxShapeReading) label() string {
	if r.at.IsZero() {
		return ""
	}
	return r.verdict.String()
}

// The configured sized target, not a connectivity marker, is the pull: a marker
// is a short body that could only ever read inconclusive. Empty keeps the probe
// dormant, so no endpoint is contacted until a profile opts in.
func (e *rcxEngine) maybeShapeStandby() {
	if e.shaping || e.metered || e.screenOff || e.suspended || e.pendingHandoff || !e.Enabled() || e.runtime.Mode() != "rule" {
		return
	}
	if t := e.terrainCurrent(); t == rcxTerrainOffline || t == rcxTerrainPortal {
		return
	}
	target := e.effectiveProbe().ShapeTarget
	if target == "" {
		return
	}
	node := e.dueShapeStandby()
	if node == "" {
		return
	}
	now := e.runtime.Now()
	e.shapedAt[e.key(node)] = now
	e.shapeGen++
	e.shaping = true
	floor := e.cfg.ThrottleFloorKBps
	gen := e.shapeGen
	configGen := e.configGen
	quit := e.quit
	ctx, cancel := context.WithTimeout(context.Background(), rcxShapeWindow)
	e.shapeCancel = cancel
	safeGoDetached("rcx shape probe", func() {
		defer cancel()
		sample := e.runtime.ShapeProbe(ctx, node, target, ShapePayloadBytes)
		verdict, kbps := rcxClampShape(sample, rcxClampLimitsFor(floor))
		e.sendResult(rcxEvent{Kind: rcxEventShapeResult, Node: node, Shape: verdict, ShapeKBps: kbps, Gen: gen, ConfigGen: configGen}, quit)
	})
}

func (e *rcxEngine) dueShapeStandby() string {
	now := e.runtime.Now()
	for _, node := range e.standbyNames() {
		if node == "" || node == e.incumbent {
			continue
		}
		at := e.shapedAt[e.key(node)]
		if at.IsZero() || now.Sub(at) >= rcxShapeInterval {
			return node
		}
	}
	return ""
}

// supersedeShape drops an in-flight probe so a stop, disable or reconfigure cannot
// leave the single-flight guard stuck true for the rest of the process; the gen
// bump makes any late result land as superseded rather than free the next probe.
func (e *rcxEngine) supersedeShape() {
	if e.shapeCancel != nil {
		e.shapeCancel()
		e.shapeCancel = nil
	}
	e.shapeGen++
	e.shaping = false
}

// A confirmed clamp (twice in a row, like the passive detector's hysteresis) demotes
// the standby through the same degraded mark, so it ranks below clean standbys and
// recovers on the mark's own expiry. A non-clamp read never clears the mark: that
// would erase a passive accusation standing on the same node.
func (e *rcxEngine) applyShapeResult(event rcxEvent) {
	if event.Gen != e.shapeGen {
		return
	}
	e.shaping = false
	e.shapeCancel = nil
	if event.ConfigGen != e.configGen {
		return
	}
	key := e.key(event.Node)
	now := e.runtime.Now()
	e.shapeReading[key] = rcxShapeReading{verdict: event.Shape, kbps: event.ShapeKBps, at: now}
	if event.Shape != rcxClamped {
		e.shapeClamp[key] = 0
		return
	}
	e.shapeClamp[key]++
	if e.shapeClamp[key] >= rcxShapeConfirm {
		e.ledger.NoteDegraded(key, e.envKey, now)
	}
}
