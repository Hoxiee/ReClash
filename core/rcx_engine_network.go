package main

import (
	"context"
	"strings"
	"time"
)

// A handoff re-arms the canaries, so re-applying one link would re-probe it.
func (e *rcxEngine) sampleLink() {
	if e.hostLinked {
		return
	}
	payload, ok := e.runtime.SampleLink()
	if !ok {
		return
	}
	e.applyNetwork(payload)
}

func (e *rcxEngine) applyNetwork(payload rcxNetworkPayload) {
	payload = normalizedNetworkFacts(payload)
	if !rcxPayloadIdentifies(payload) {
		return
	}
	if e.networkFacts != nil && equalNetworkFacts(*e.networkFacts, payload) {
		return
	}
	e.networkFacts = &payload
	primary, aliases := rcxEnvKeys(payload)
	e.transport = payload.Transport
	e.metered = payload.Metered
	e.validated = payload.Validated
	e.portal = payload.CaptivePortal
	e.terrain.noteValidation(payload.Validated, e.runtime.Now())

	changed := primary != e.envKey
	if changed {
		e.rollbackEscrow()
		e.resetRescue()
		e.supersedeWake()
		e.laneProbeSeen = map[string]map[string]struct{}{}
		e.laneProbeAt = map[string]time.Time{}
		e.pendingHandoff = true
		e.providerFails = map[string]time.Time{}
		e.envKey = primary
		e.envSince = e.runtime.Now()
		e.reachWarm = true
		e.reachBlind = 0
		e.terrain.forget()
		e.migrateEnvironment(aliases, primary)
		e.supersedeProbe()
		e.reachF, e.reachD = rcxProbeOverloaded, rcxProbeOverloaded
		// Carry the working node across the handoff instead of dropping it: a foreign
		// node that opened the world (OpenedOnce is per-marker, not per-env) stays
		// admissible on the new link, so wifi<->cellular verifies rather than re-picks.
		e.incumbent = e.runtime.Selected()
		e.since = e.runtime.Now()
		e.wantPick = e.snapshot.Picks[primary]
		if pin, ok := e.snapshot.Pins[primary]; ok {
			e.wantPick = pin
		}
		for id, lane := range e.lanes {
			lane.incumbent = ""
			lane.since = time.Time{}
			if picks := e.snapshot.LanePicks[id]; picks != nil {
				lane.incumbent = e.nameOf(picks[primary])
			}
		}
	}
	e.classifyTerrain(false)
	e.supersedeReach()
	e.startReach()
	if changed {
		e.startHostSweep()
	}
	e.reconsider()
}

// The host's own delay test is the signal the user reads by eye, and it is the
// only one that covers a whole park inside seconds. Nothing refreshes it on a
// link change, so the engine buys its own round rather than ranking the new
// network by the greens the old one left behind.
func (e *rcxEngine) startHostSweep() {
	if !e.Enabled() {
		e.pendingHandoff = false
		return
	}
	members := e.runtime.Members()
	if len(members) == 0 {
		e.pendingHandoff = false
		return
	}
	nodes := make([]string, 0, len(members))
	for _, member := range members {
		nodes = append(nodes, member.Name)
	}
	e.sweepGen++
	e.sweeping = true
	gen := e.sweepGen
	quit := e.quit
	sweep := e.runtime.Sweep
	safeGoDetached("rcx host sweep", func() {
		ctx, cancel := context.WithTimeout(context.Background(), rcxHostSweepWindow)
		defer cancel()
		sweep(ctx, nodes)
		e.sendResult(rcxEvent{Kind: rcxEventHostSweep, Gen: gen}, quit)
	})
}

// A pick made before the sweep landed was made blind, so the reading that
// arrives may not spend its dwell defending it.
func (e *rcxEngine) applyHostSweep(gen uint32) {
	if gen != e.sweepGen {
		return
	}
	e.sweeping = false
	e.sweptAt = e.runtime.Now()
	if e.incumbent != "" && e.ledger.Facts(
		e.key(e.incumbent), e.envKey, false, e.sweptAt, e.ledger.ProofTTL(),
	).Transit != rcxProofProven {
		e.since = time.Time{}
	}
	e.reconsider()
}

// A wave dispatched before the sweep would order itself by the previous link.
func (e *rcxEngine) awaitsHostSweep(now time.Time) bool {
	return e.sweeping && !e.envSince.IsZero() &&
		now.Sub(e.envSince) < rcxHostSweepWindow
}

// A round in flight was bought by the previous link: the new one cannot use it.
func (e *rcxEngine) supersedeReach() {
	e.reachGen++
	e.escrowReach = false
	if e.reachCancel != nil {
		e.reachCancel()
		e.reachCancel = nil
	}
	e.reaching = false
	e.reachAgain = false
}

// The dials really ran, so the charge stands; only the verdicts go stale.
func (e *rcxEngine) supersedeProbe() {
	if e.probeCancel != nil {
		e.probeCancel()
		e.probeCancel = nil
	}
	e.probeGen++
	e.probing = false
	e.deep = false
	e.probeResults = nil
	e.probeStarted = map[string]struct{}{}
	e.probeRecovered = false
	e.probeDecisionClosed = false
	e.probeLane = ""
	e.paidWave = 0
	e.paidWaveGen = e.probeGen
}

func (e *rcxEngine) supersedeWake() {
	if e.wakeCancel != nil {
		e.wakeCancel()
		e.wakeCancel = nil
	}
	e.wakeGen++
	e.wakePending = false
	e.wakeIncumbent = ""
	e.wakeStandby = ""
}

func (e *rcxEngine) migrateEnvironment(aliases []string, to string) {
	for _, from := range aliases {
		if from == to {
			continue
		}
		e.ledger.Migrate(from, to)
		migrateLatestString(e.snapshot.Picks, from, to)
		migrateLatestString(e.snapshot.Pins, from, to)
		migrateLatestRegime(e.snapshot.Regimes, from, to)
		migrateStandbys(e.snapshot.Standbys, from, to)
		for _, picks := range e.snapshot.LanePicks {
			migrateLatestString(picks, from, to)
		}
		for _, standbys := range e.snapshot.LaneStandbys {
			migrateStandbys(standbys, from, to)
		}
		e.migrateCircuits(from, to)
	}
}

func migrateLatestString(values map[string]string, from, to string) {
	if values[to] == "" && values[from] != "" {
		values[to] = values[from]
	}
	delete(values, from)
}

func migrateLatestRegime(values map[string]rcxRegimeMemory, from, to string) {
	incoming, ok := values[from]
	if !ok {
		return
	}
	if current, exists := values[to]; !exists || incoming.At.After(current.At) {
		values[to] = incoming
	}
	delete(values, from)
}

func migrateStandbys(values map[string][]string, from, to string) {
	incoming, ok := values[from]
	if !ok {
		return
	}
	seen := map[string]struct{}{}
	merged := make([]string, 0, rcxStandbyCount)
	for _, key := range append(append([]string(nil), values[to]...), incoming...) {
		if _, ok := seen[key]; ok || key == "" {
			continue
		}
		seen[key] = struct{}{}
		merged = append(merged, key)
		if len(merged) == rcxStandbyCount {
			break
		}
	}
	values[to] = merged
	delete(values, from)
}

func (e *rcxEngine) migrateCircuits(from, to string) {
	prefix := from + "\x00"
	for key, incoming := range e.snapshot.Circuits {
		if !strings.HasPrefix(key, prefix) {
			continue
		}
		destination := to + key[len(from):]
		if current, ok := e.snapshot.Circuits[destination]; !ok || incoming.OpenedAt.After(current.OpenedAt) {
			e.snapshot.Circuits[destination] = incoming
		}
		delete(e.snapshot.Circuits, key)
	}
}

// The marker answered through the tunnel, so it is evidence about the link the
// canaries are still arguing over, not about the node that carried it.
func (e *rcxEngine) witnessWhitelist(role rcxRole) {
	if role != rcxRoleDomestic || e.reachD != rcxProbeOK || e.reachF == rcxProbeOK {
		return
	}
	if e.terrain.witnessWhitelist() {
		e.classifyTerrain(false)
	}
}

func (e *rcxEngine) classifyTerrain(measured bool) {
	now := e.runtime.Now()
	if e.terrain.portalExpired(now) {
		e.portal = false
	}
	terrain := rcxClassifyTerrain(rcxTerrainFacts{
		Validated:      e.validated,
		CaptivePortal:  e.portal,
		UnvalidatedFor: e.terrain.unvalidatedFor(now),
		ForeignReach:   e.reachF,
		DomesticReach:  e.reachD,
	})
	terrain = e.terrain.settle(terrain, measured)
	if terrain == rcxTerrainOffline {
		e.rollbackEscrow()
	}
	if !e.terrain.observe(terrain, now) {
		return
	}
	e.resetRescue()
	if terrain == rcxTerrainNormal {
		e.ledger.PromoteTerrainNormal(e.envKey)
	}
	if e.envKey != "" {
		e.snapshot.Regimes[e.envKey] = rcxRegimeMemory{Terrain: terrain, At: now}
	}
}

func (e *rcxEngine) applyScreenOff(off bool) {
	if e.screenOff == off {
		return
	}
	e.screenOff = off
	if off && e.improvementWave() {
		e.supersedeProbe()
	}
	if !off {
		e.screenDead = ""
		e.screenFailedOver = false
		if e.probing && e.probeScreenOff {
			e.sealProbeDecision()
		}
		e.startWakeProbe()
		e.startReach()
		return
	}
	e.supersedeReach()
	e.reachAgain = false
	e.supersedeWake()
	e.screenEpisode++
	e.screenDead = ""
	e.screenFailedOver = false
	for _, lane := range e.lanes {
		lane.screenConfirmedDead = ""
		lane.screenFailoverUsed = false
	}
}

func (e *rcxEngine) applySuspend(suspended bool) {
	now := e.runtime.Now()
	e.suspended = suspended
	if suspended {
		e.supersedeProbe()
		e.supersedeWake()
		e.supersedeReach()
		e.reachAgain = false
		e.accountMetrics(now)
		e.closeIncident(now, false)
		e.suspendAt = now
		e.suspendTo = now
		e.accountedAt = time.Time{}
		e.persist(true)
		return
	}
	e.suspendTo = now
	e.accountedAt = now
	e.reachF, e.reachD = rcxProbeOverloaded, rcxProbeOverloaded
	e.supersedeReach()
	if !e.screenOff {
		e.startWakeProbe()
	}
	e.startReach()
	e.reconsider()
}

func (e *rcxEngine) maybeRefreshTerrain() {
	now := e.runtime.Now()
	if e.lastReachAt.IsZero() {
		e.startReach()
		return
	}
	if now.Sub(e.lastReachAt) >= e.reachInterval() {
		e.startReach()
	}
}

// The pair of rounds that confirms a whitelist is the whole latency of the
// verdict, so it runs back to back rather than on the refresh cadence.
func (e *rcxEngine) reachInterval() time.Duration {
	if e.terrain.confirming() {
		return 0
	}
	if e.terrain.terrain == rcxTerrainNormal {
		return rcxReachRefresh
	}
	return rcxReachUrgent
}

// A stale terrain says nothing: unknown keeps the last-resort rows honest.
func (e *rcxEngine) terrainCurrent() rcxTerrain {
	if e.lastReachAt.IsZero() {
		return e.terrain.terrain
	}
	if e.runtime.Now().Sub(e.lastReachAt) > rcxTerrainMaxAge {
		return rcxTerrainUnknown
	}
	return e.terrain.terrain
}
