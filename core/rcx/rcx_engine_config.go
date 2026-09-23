package rcx

import (
	"reflect"
	"strings"
	"time"

	"github.com/metacubex/mihomo/adapter/provider"
)

func (e *rcxEngine) applyConfigLocked(config rcxConfig) {
	// The host does not carry this: shipped defaults are the core's to migrate.
	config.DefaultsVersion = rcxDefaultsVersion
	config = config.normalized()
	previous := e.configFP
	next := config.fingerprints()
	hasPrevious := previous != (rcxConfigFingerprints{})
	changed := hasPrevious && previous != next
	if changed {
		e.configGen++
		e.supersedeProbe()
		e.supersedeWake()
		e.laneProbeSeen = map[string]map[string]struct{}{}
		e.laneProbeAt = map[string]time.Time{}
		e.resetRescue()
		e.supersedeReach()
		e.ledger.Invalidate(
			previous.Open != next.Open,
			previous.Domestic != next.Domestic,
			previous.Countries != next.Countries,
			previous.Egress != next.Egress,
		)
		if previous.Canaries != next.Canaries {
			e.reachF, e.reachD = rcxProbeOverloaded, rcxProbeOverloaded
			e.lastReachAt = time.Time{}
		}
	}
	// A toggle must not refill the probe budget, or it becomes a way to farm one.
	if config.Preset != e.cfg.Preset {
		e.budget = newRcxProbeBudget(rcxProbeBudgetCap, rcxProbeBudgetWin)
	}
	// Enabling starts from measurements: one full wave rides outside the cap.
	if config.operable() && (!e.cfg.operable() || config.Strategy != e.cfg.Strategy) {
		e.pendingGrant = true
	}
	e.cfg = config
	e.ledger.SetProofTTL(time.Duration(config.ProofTTLMinutes) * time.Minute)
	e.syncLaneConfigs(config.Lanes)
	e.configFP = next
	e.ledger.SetFingerprints(next.Open, next.Domestic)
	now := e.runtime.Now()
	e.accountMetrics(now)
	e.mu.Lock()
	e.openHosts = rcxMarkerHosts(config.OpenMarkers)
	e.mu.Unlock()
	e.refreshEffectiveEnabled()
	if !config.operable() {
		e.closeIncident(now, false)
	}
	if e.snapshot != nil {
		e.snapshot.Config = config
		e.snapshot.Fingerprints = next
	}
}

func (e *rcxEngine) refreshEffectiveEnabled() {
	want := e.cfg.operable() && e.runtime.TopologyValid(e.cfg)
	e.mu.Lock()
	was := e.enabled
	e.enabled = want
	e.mu.Unlock()
	if was != want {
		// The engine becomes the single prover: pause mihomo's per-provider auto
		// health check so nodes are not probed twice; resume it when RCX steps down.
		provider.SetAutoHealthCheckSuppressed(want)
	}
	if was && !want {
		e.supersedeProbe()
		e.supersedeWake()
		e.supersedeReach()
	}
	if !was && want {
		e.pendingGrant = true
	}
}

func (e *rcxEngine) syncLaneConfigs(configs []rcxLaneConfig) {
	lanes := make(map[string]*rcxLaneState, len(configs))
	for _, config := range configs {
		lane := e.lanes[config.ID]
		if lane == nil {
			lane = &rcxLaneState{}
		}
		if lane.config.ID != "" && !reflect.DeepEqual(lane.config, config) {
			delete(e.laneProbeSeen, config.ID)
			delete(e.laneProbeAt, config.ID)
		}
		if lane.config.Group != "" && lane.config.Group != config.Group {
			lane.incumbent = ""
			lane.since = time.Time{}
		}
		lane.config = config
		lanes[config.ID] = lane
	}
	e.lanes = lanes
	for id := range e.laneProbeSeen {
		if lanes[id] == nil {
			delete(e.laneProbeSeen, id)
			delete(e.laneProbeAt, id)
		}
	}
	if e.snapshot != nil {
		for id := range e.snapshot.LanePicks {
			if lanes[id] == nil {
				delete(e.snapshot.LanePicks, id)
				e.snapshot.Dirty = true
			}
		}
		for id := range e.snapshot.LaneStandbys {
			if lanes[id] == nil {
				delete(e.snapshot.LaneStandbys, id)
				e.snapshot.Dirty = true
			}
		}
	}
}

func rcxMarkerHosts(markers []rcxMarker) map[string]struct{} {
	if len(markers) == 0 {
		return nil
	}
	hosts := make(map[string]struct{}, len(markers))
	for _, marker := range markers {
		if at := strings.Index(marker.URL, "://"); at >= 0 {
			if host := marker.URL[at+3:]; host != "" {
				if slash := strings.IndexAny(host, "/?#"); slash >= 0 {
					host = host[:slash]
				}
				if host != "" {
					hosts[host] = struct{}{}
				}
			}
		}
	}
	return hosts
}
