package rcx

import "time"

const rcxStandbyCount = 3

func (e *rcxEngine) rebuildStandbys(ranked []rcxRanked) {
	if e.snapshot == nil || e.envKey == "" {
		return
	}
	e.snapshot.Standbys[e.envKey] = e.pickStandbys(ranked, e.incumbent, nil)
}

func rcxStandbyQuality(key rcxKey) rcxKey {
	if key.latencyMs != int(^uint(0)>>1) {
		key.latencyMs = 0
	}
	key.order = 0
	key.challenger = false
	return key
}

func (e *rcxEngine) pickStandbys(ranked []rcxRanked, incumbent string, extra func(rcxCandidate) bool) []string {
	members := e.runtime.Members()
	byName := make(map[string]rcxMember, len(members))
	for _, member := range members {
		byName[member.Name] = member
	}
	selected := make([]string, 0, rcxStandbyCount)
	seen := map[string]struct{}{}
	for start := 0; start < len(ranked); {
		quality := rcxStandbyQuality(ranked[start].Key)
		end := start + 1
		for end < len(ranked) && rcxStandbyQuality(ranked[end].Key) == quality {
			end++
		}
		for _, diverse := range []bool{true, false} {
			for _, row := range ranked[start:end] {
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
		start = end
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
	standbys := e.pickStandbys(rcxRank(input), e.incumbent, nil)
	if len(standbys) == 0 {
		return ""
	}
	return e.nameOf(standbys[0])
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
