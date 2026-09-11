package main

import "time"

const rcxStandbyCount = 3

func (e *rcxEngine) rebuildStandbys(ranked []rcxRanked) {
	if e.snapshot == nil || e.envKey == "" {
		return
	}
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
			if candidate.Name == e.incumbent || row.Block != rcxBlockNone ||
				row.Key.verdict == rcxVerdictLastResort ||
				candidate.Facts.OpenWorld != rcxProofProven ||
				candidate.Facts.Transit != rcxProofProven {
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
			already := false
			for _, key := range selected {
				already = already || key == member.key()
			}
			if already {
				continue
			}
			selected = append(selected, member.key())
			seen[bucket] = struct{}{}
			if len(selected) == rcxStandbyCount {
				e.snapshot.Standbys[e.envKey] = selected
				return
			}
		}
	}
	e.snapshot.Standbys[e.envKey] = selected
}

func (e *rcxEngine) standbyNames() []string {
	if e.snapshot == nil {
		return nil
	}
	names := make([]string, 0, len(e.snapshot.Standbys[e.envKey]))
	for _, key := range e.snapshot.Standbys[e.envKey] {
		if name := e.nameOf(key); name != "" && name != e.incumbent {
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
		delay := candidate.MedianMs
		if delay <= 0 {
			delay = candidate.HostMs
		}
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
			if !candidate.InSkeleton || candidate.Name == lane.incumbent || row.Block != rcxBlockNone ||
				candidate.Facts.OpenWorld != rcxProofProven || candidate.Facts.Transit != rcxProofProven {
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
				break
			}
		}
		if len(selected) == rcxStandbyCount {
			break
		}
	}
	standbys := e.snapshot.LaneStandbys[lane.config.ID]
	if standbys == nil {
		standbys = map[string][]string{}
		e.snapshot.LaneStandbys[lane.config.ID] = standbys
	}
	standbys[e.envKey] = selected
}

func (e *rcxEngine) laneStandbyNames(lane *rcxLaneState) []string {
	if e.snapshot == nil || e.snapshot.LaneStandbys[lane.config.ID] == nil {
		return nil
	}
	keys := e.snapshot.LaneStandbys[lane.config.ID][e.envKey]
	names := make([]string, 0, len(keys))
	for _, key := range keys {
		if name := e.nameOf(key); name != "" && name != lane.incumbent {
			names = append(names, name)
		}
	}
	return names
}

func rcxHoistNodes(pool []rcxProbeNode, names []string) {
	for i := len(names) - 1; i >= 0; i-- {
		rcxHoistNode(pool, names[i])
	}
}
