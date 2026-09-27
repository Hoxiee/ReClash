package rcx

import "time"

const rcxStandbyCount = 3

func (e *rcxEngine) rebuildStandbys(ranked []rcxRanked) {
	if e.snapshot == nil || e.envKey == "" {
		return
	}
	e.snapshot.Standbys[e.envKey] = e.pickStandbys(ranked, e.incumbent, nil)
}

// pickStandbys walks the ranked rows twice — first demanding provider/transport
// diversity, then filling the remaining slots — and returns up to
// rcxStandbyCount member keys that are proven open and in transit, skipping the
// incumbent and any last-resort pick. extra rejects rows a caller does not
// want; lanes keep only skeleton members.
func (e *rcxEngine) pickStandbys(ranked []rcxRanked, incumbent string, extra func(rcxCandidate) bool) []string {
	members := e.runtime.Members()
	byName := make(map[string]rcxMember, len(members))
	for _, member := range members {
		byName[member.Name] = member
	}
	selected := make([]string, 0, rcxStandbyCount)
	seen := map[string]struct{}{}
	for _, diverse := range []bool{true, false} {
		for _, row := range ranked {
			candidate := row.Candidate
			if candidate.Name == incumbent || row.Block != rcxBlockNone ||
				row.Key.verdict == rcxVerdictLastResort ||
				candidate.Facts.OpenWorld != rcxProofProven ||
				candidate.Facts.Transit != rcxProofProven {
				continue
			}
			if extra != nil && !extra(candidate) {
				continue
			}
			member, ok := byName[candidate.Name]
			if !ok {
				continue
			}
			bucket := member.Provider + "|" + member.Transport
			if _, duplicate := seen[bucket]; duplicate && diverse {
				continue
			}
			key := member.key()
			already := false
			for _, selectedKey := range selected {
				already = already || selectedKey == key
			}
			if already {
				continue
			}
			selected = append(selected, key)
			seen[bucket] = struct{}{}
			if len(selected) == rcxStandbyCount {
				return selected
			}
		}
	}
	return selected
}

func (e *rcxEngine) standbyNames() []string {
	if e.snapshot == nil {
		return nil
	}
	return e.standbyNamesFrom(e.snapshot.Standbys[e.envKey], e.incumbent)
}

func (e *rcxEngine) standbyNamesFrom(keys []string, incumbent string) []string {
	names := make([]string, 0, len(keys))
	for _, key := range keys {
		if name := e.nameOf(key); name != "" && name != incumbent {
			names = append(names, name)
		}
	}
	return names
}

func (e *rcxEngine) selectWakeStandby(now time.Time) string {
	candidates := e.candidates(e.runtime.Members())
	input := rcxDecisionInput{
		Terrain: e.terrainCurrent(), Incumbent: e.incumbent, Candidates: candidates,
		Policy: e.cfg.policy(), Now: now,
	}
	remembered := map[string]int{}
	for index, name := range e.standbyNames() {
		remembered[name] = index
	}
	best := ""
	bestDelay := 0
	bestOrder := len(remembered)
	for _, candidate := range candidates {
		order, ok := remembered[candidate.Name]
		if !ok || !rcxEligible(candidate, input) || candidate.Facts.OpenWorld != rcxProofProven ||
			candidate.Facts.Transit != rcxProofProven {
			continue
		}
		delay := rcxDiscoveryLatency(candidate)
		if best == "" || (delay > 0 && (bestDelay <= 0 || delay < bestDelay)) || delay == bestDelay && order < bestOrder {
			best = candidate.Name
			bestDelay = delay
			bestOrder = order
		}
	}
	return best
}

func (e *rcxEngine) rebuildLaneStandbys(lane *rcxLaneState, ranked []rcxRanked) {
	if e.snapshot == nil || e.envKey == "" {
		return
	}
	standbys := e.snapshot.LaneStandbys[lane.config.ID]
	if standbys == nil {
		standbys = map[string][]string{}
		e.snapshot.LaneStandbys[lane.config.ID] = standbys
	}
	standbys[e.envKey] = e.pickStandbys(ranked, lane.incumbent, func(c rcxCandidate) bool {
		return c.InSkeleton
	})
}

func (e *rcxEngine) laneStandbyNames(lane *rcxLaneState) []string {
	if e.snapshot == nil || e.snapshot.LaneStandbys[lane.config.ID] == nil {
		return nil
	}
	return e.standbyNamesFrom(e.snapshot.LaneStandbys[lane.config.ID][e.envKey], lane.incumbent)
}

func rcxHoistNodes(pool []rcxProbeNode, names []string) {
	for i := len(names) - 1; i >= 0; i-- {
		rcxHoistNode(pool, names[i])
	}
}
