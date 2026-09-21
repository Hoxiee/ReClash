package main

import (
	"sort"
	"time"
)

const (
	rcxMarkerFailureWindow = 90 * time.Second
	rcxMarkerQuarantineTTL = 10 * time.Minute
	rcxMarkerFailQuorum    = 3
)

type rcxMarkerFailure struct {
	Bucket string    `json:"b"`
	At     time.Time `json:"a"`
}

type rcxMarkerQuarantine struct {
	Until    time.Time          `json:"u"`
	Failures []rcxMarkerFailure `json:"f,omitempty"`
}

func (e *rcxEngine) markerQuarantined(markerID string, now time.Time) bool {
	if e.snapshot == nil {
		return false
	}
	quarantine, ok := e.snapshot.Quarantines[markerID]
	if !ok {
		return false
	}
	if quarantine.Until.IsZero() {
		return false
	}
	if !now.Before(quarantine.Until) {
		delete(e.snapshot.Quarantines, markerID)
		e.recomputeMarkerRole(markerID, now)
		return false
	}
	return true
}

func (e *rcxEngine) noteMarkerFailure(markerID, node string, now time.Time) {
	member, ok := e.memberByName(node)
	if !ok || markerID == "" || e.snapshot == nil ||
		!e.ledger.PreviouslyGood(member.key(), e.envKey) {
		return
	}
	// A node that does not measurably egress abroad cannot testify that the
	// foreign open marker is down: its failure is the expected domestic signal,
	// not marker breakage. Only a proven-foreign node quarantines the open marker,
	// so a park of home-country nodes can never blind the engine to itself.
	if role, known := e.markerRole(markerID); known && role == rcxRoleOpen &&
		e.ledger.Exit(member.key(), now) != rcxOriginForeign {
		return
	}
	if e.ledger.MarkerFreshlyPassing(e.envKey, markerID, now) {
		return
	}
	bucket := rcxFailureBucket(member)
	quarantine := e.snapshot.Quarantines[markerID]
	failures := quarantine.Failures[:0]
	seen := false
	for _, failure := range quarantine.Failures {
		if now.Sub(failure.At) > rcxMarkerFailureWindow {
			continue
		}
		seen = seen || failure.Bucket == bucket
		failures = append(failures, failure)
	}
	if !seen {
		failures = append(failures, rcxMarkerFailure{Bucket: bucket, At: now})
	}
	quarantine.Failures = failures
	if len(failures) >= rcxMarkerFailQuorum {
		quarantine.Until = now.Add(rcxMarkerQuarantineTTL)
		quarantine.Failures = nil
		e.snapshot.Quarantines[markerID] = quarantine
		e.snapshot.Metrics.MarkerIncidents++
		e.snapshot.Dirty = true
		e.ledger.RollbackMarkerFailures(markerID, now)
		e.recomputeMarkerRole(markerID, now)
		return
	}
	e.snapshot.Quarantines[markerID] = quarantine
}

func (e *rcxEngine) activeMarkerReasons(now time.Time) []string {
	if e.snapshot == nil {
		return nil
	}
	reasons := make([]string, 0)
	for _, role := range []rcxRole{rcxRoleOpen, rcxRoleDomestic} {
		for _, marker := range e.configMarkers(role) {
			id := rcxMarkerID(role, marker)
			quarantine, ok := e.snapshot.Quarantines[id]
			if ok && quarantine.Until.After(now) {
				reasons = append(reasons, marker.URL)
			}
		}
	}
	sort.Strings(reasons)
	return reasons
}

func (e *rcxEngine) recomputeMarkerRole(markerID string, now time.Time) {
	role, ok := e.markerRole(markerID)
	if !ok {
		return
	}
	ids := e.markerIDsForConfig(role, now, "")
	for envKey, nodes := range e.snapshot.Envs {
		for key := range nodes {
			// A quarantine sweep off other nodes' failures must not strip the
			// proven incumbent's open proof; the traffic detector owns its death.
			if envKey == e.envKey && role == rcxRoleOpen && e.incumbentHoldsFreshOpen(key, now) {
				continue
			}
			e.ledger.RecomputeRole(key, envKey, role, ids, now)
		}
	}
}

func (e *rcxEngine) markerRole(markerID string) (rcxRole, bool) {
	for _, role := range []rcxRole{rcxRoleOpen, rcxRoleDomestic} {
		for _, marker := range e.configMarkers(role) {
			if rcxMarkerID(role, marker) == markerID {
				return role, true
			}
		}
	}
	return rcxRoleOpen, false
}

func (e *rcxEngine) configMarkers(role rcxRole) []rcxMarker {
	switch role {
	case rcxRoleDomestic:
		return e.cfg.DomesticMarkers
	case rcxRoleLocal:
		return e.cfg.LocalMarkers
	}
	return e.cfg.OpenMarkers
}

func (e *rcxEngine) markerIDsForConfig(role rcxRole, now time.Time, exclude string) []string {
	ids := make([]string, 0, len(e.configMarkers(role)))
	for _, marker := range e.configMarkers(role) {
		id := rcxMarkerID(role, marker)
		if id != exclude && !e.markerQuarantined(id, now) {
			ids = append(ids, id)
		}
	}
	return ids
}

func (e *rcxEngine) activeMarkers(role rcxRole, now time.Time) []rcxMarker {
	markers := e.configMarkers(role)
	active := make([]rcxMarker, 0, len(markers))
	for _, marker := range markers {
		if !e.markerQuarantined(rcxMarkerID(role, marker), now) {
			active = append(active, marker)
		}
	}
	// Quarantining every open marker blinds the engine into one collapsed tier; keep the nearest-to-expiry one live rather than go dark.
	if len(active) == 0 && len(markers) > 0 && role == rcxRoleOpen {
		if fallback, ok := e.soonestMarker(role); ok {
			active = append(active, fallback)
		}
	}
	return active
}

func (e *rcxEngine) soonestMarker(role rcxRole) (rcxMarker, bool) {
	var best rcxMarker
	var bestUntil time.Time
	found := false
	for _, marker := range e.configMarkers(role) {
		quarantine, ok := e.snapshot.Quarantines[rcxMarkerID(role, marker)]
		if !ok {
			return marker, true
		}
		if !found || quarantine.Until.Before(bestUntil) {
			best, bestUntil, found = marker, quarantine.Until, true
		}
	}
	return best, found
}

func (e *rcxEngine) markerIDs(role rcxRole, now time.Time) []string {
	markers := e.activeMarkers(role, now)
	ids := make([]string, 0, len(markers))
	for _, marker := range markers {
		ids = append(ids, rcxMarkerID(role, marker))
	}
	return ids
}
