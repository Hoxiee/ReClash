package main

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

func rcxHoistNodes(pool []rcxProbeNode, names []string) {
	for i := len(names) - 1; i >= 0; i-- {
		rcxHoistNode(pool, names[i])
	}
}
