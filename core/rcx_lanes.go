package main

import (
	"sort"
	"strings"
	"time"
)

type rcxLaneState struct {
	config              rcxLaneConfig
	incumbent           string
	since               time.Time
	switchedAt          time.Time
	reason              rcxReason
	candidates          int
	eligible            int
	screenConfirmedDead string
	screenFailoverUsed  bool
}

func rcxLaneMatches(config rcxLaneConfig, member rcxMember, groups map[string]map[string]struct{}) bool {
	for _, selector := range config.Selectors {
		if selector.Provider != "" && selector.Provider != member.Provider {
			continue
		}
		if selector.NameContains != "" && !strings.Contains(member.Name, selector.NameContains) {
			continue
		}
		if selector.Group != "" {
			set, ok := groups[selector.Group]
			if !ok {
				continue
			}
			if _, in := set[member.Name]; !in {
				continue
			}
		}
		return true
	}
	return false
}

func (e *rcxEngine) laneGroupSets(config rcxLaneConfig) map[string]map[string]struct{} {
	var sets map[string]map[string]struct{}
	for _, selector := range config.Selectors {
		if selector.Group == "" {
			continue
		}
		if sets == nil {
			sets = map[string]map[string]struct{}{}
		}
		if _, done := sets[selector.Group]; done {
			continue
		}
		set := map[string]struct{}{}
		for _, name := range e.runtime.GroupMembers(selector.Group) {
			set[name] = struct{}{}
		}
		sets[selector.Group] = set
	}
	return sets
}

// Gates on the measured egress, never a proof, so an unmeasured node stays probeable.
func rcxLaneRoleAdmits(role string, f rcxFacts) bool {
	switch role {
	case rcxLaneRoleForeign:
		return f.Exit != rcxOriginDomestic
	case rcxLaneRoleDomestic:
		return f.Exit != rcxOriginForeign
	default:
		return true
	}
}

func (e *rcxEngine) laneCandidates(lane *rcxLaneState, members []rcxMember) []rcxCandidate {
	candidates := e.candidatesFor(members, lane.incumbent)
	byName := make(map[string]rcxMember, len(members))
	for _, member := range members {
		byName[member.Name] = member
	}
	groups := e.laneGroupSets(lane.config)
	for i := range candidates {
		member, ok := byName[candidates[i].Name]
		candidates[i].InSkeleton = ok && rcxLaneMatches(lane.config, member, groups) &&
			rcxLaneRoleAdmits(lane.config.Role, candidates[i].Facts)
	}
	return candidates
}

// Only the strategy is per-lane; the rest of the policy stays the park's.
func (e *rcxEngine) lanePolicy(config rcxLaneConfig) rcxPolicy {
	policy := e.cfg.policy()
	if config.Strategy != "" {
		policy.Strategy = config.Strategy
	}
	return policy
}

func (e *rcxEngine) reconsiderLanes(members []rcxMember, now time.Time) {
	for _, config := range e.cfg.Lanes {
		lane := e.lanes[config.ID]
		if lane == nil {
			continue
		}
		if lane.incumbent == "" {
			selected := e.runtime.SelectedIn(config.Group)
			if selected != "REJECT" && selected != rcxGroupNode {
				lane.incumbent = selected
			}
		}
		candidates := e.laneCandidates(lane, members)
		input := rcxDecisionInput{
			Terrain:        e.terrainCurrent(),
			Incumbent:      lane.incumbent,
			IncumbentSince: lane.since,
			Candidates:     candidates,
			Policy:         e.lanePolicy(config),
			Now:            now,
		}
		decision := rcxDecide(input)
		if decision.Reason == rcxReasonQualityConfirming {
			e.queueQuality(decision.Detail)
		}
		if decision.Switch && decision.To != lane.incumbent {
			e.tryAutomaticLaneSelect(lane, decision.To, decision.Reason, now)
		} else if lane.incumbent != "" && e.runtime.SelectedIn(config.Group) != lane.incumbent {
			_ = e.runtime.SelectIn(config.Group, lane.incumbent)
		}
		ranked := rcxRank(input)
		e.rebuildLaneStandbys(lane, ranked)
		lane.candidates = 0
		lane.eligible = 0
		for _, row := range ranked {
			if row.Candidate.InSkeleton {
				lane.candidates++
			}
			if row.Block == rcxBlockNone {
				lane.eligible++
			}
		}
		lane.reason = decision.Reason
		// Index 0 of the skeleton only covers the window before the core speaks:
		// once a lane holds no endpoint the user's own fallback owns the group,
		// whether the specialists are gone or merely unproven so far.
		if !rcxLaneHolds(lane, ranked) && !e.screenOff {
			fallback := "REJECT"
			if config.Fallback == rcxLaneFallbackMain {
				fallback = rcxGroupNode
			}
			if e.runtime.SelectedIn(config.Group) != fallback {
				if err := e.runtime.SelectIn(config.Group, fallback); err != nil {
					continue
				}
			}
			lane.incumbent = ""
			lane.since = time.Time{}
		}
	}
}

// A lane holds its group only while its own endpoint is still selectable: a
// dead or barred incumbent leaves the group to the configured fallback.
func rcxLaneHolds(lane *rcxLaneState, ranked []rcxRanked) bool {
	if lane.incumbent == "" {
		return false
	}
	for _, row := range ranked {
		if row.Candidate.Name == lane.incumbent {
			return row.Block == rcxBlockNone
		}
	}
	return false
}

func (e *rcxEngine) laneStatuses() []rcxLaneStatus {
	statuses := make([]rcxLaneStatus, 0, len(e.cfg.Lanes))
	for _, config := range e.cfg.Lanes {
		lane := e.lanes[config.ID]
		if lane == nil {
			continue
		}
		state := "fallback"
		searching := e.probing && e.probeLane == config.ID
		if lane.incumbent != "" {
			state = "active"
		} else if searching || (lane.candidates > 0 && !e.laneExhausted(config.ID)) {
			state = "searching"
		}
		statuses = append(statuses, rcxLaneStatus{
			ID:         config.ID,
			Group:      config.Group,
			State:      state,
			Node:       lane.incumbent,
			Candidates: lane.candidates,
			Eligible:   lane.eligible,
			Searching:  searching,
			Fallback:   config.Fallback,
			Reason:     string(lane.reason),
			SwitchedAt: rcxMillis(lane.switchedAt),
		})
	}
	return statuses
}

// A lane is exhausted once its rescue episode has measured every match it has;
// until then it is still searching, however its group is routed meanwhile.
func (e *rcxEngine) laneExhausted(id string) bool {
	return !e.laneProbeAt[id].IsZero()
}

func (e *rcxEngine) laneProbeReplacement(lane *rcxLaneState, node string, now time.Time) bool {
	candidates := e.laneCandidates(lane, e.runtime.Members())
	input := rcxDecisionInput{
		Terrain:        e.terrainCurrent(),
		Incumbent:      lane.incumbent,
		IncumbentSince: lane.since,
		Candidates:     candidates,
		Policy:         e.lanePolicy(lane.config),
		Now:            now,
	}
	for _, candidate := range candidates {
		if candidate.Name == node {
			return rcxEligible(candidate, input)
		}
	}
	return false
}

func (e *rcxEngine) queueLaneRecovery() {
	if e.probing {
		return
	}
	if e.laneBurst >= 2 && e.startImprovement(true) {
		return
	}
	members := e.runtime.Members()
	if len(members) == 0 {
		return
	}
	for _, config := range e.cfg.Lanes {
		lane := e.lanes[config.ID]
		if lane == nil || lane.incumbent != "" || lane.candidates == 0 ||
			len(config.Selectors) == 0 {
			continue
		}
		if e.startLaneProbe(lane, members) {
			return
		}
	}
}

func (e *rcxEngine) startLaneProbe(lane *rcxLaneState, members []rcxMember) bool {
	candidates := e.laneCandidates(lane, members)
	byName := make(map[string]rcxCandidate, len(candidates))
	pool := make([]rcxProbeNode, 0, len(candidates))
	seen := e.laneProbeSeen[lane.config.ID]
	if len(seen) > 0 && !e.laneProbeAt[lane.config.ID].IsZero() &&
		e.runtime.Now().Sub(e.laneProbeAt[lane.config.ID]) >= rcxRescueRepeat {
		seen = nil
		delete(e.laneProbeSeen, lane.config.ID)
	}
	if seen == nil {
		seen = map[string]struct{}{}
		e.laneProbeSeen[lane.config.ID] = seen
	}
	for i, candidate := range candidates {
		byName[candidate.Name] = candidate
		if !candidate.InSkeleton {
			continue
		}
		if _, measured := seen[candidate.Name]; measured {
			continue
		}
		member := members[i]
		pool = append(pool, rcxProbeNode{
			Name: candidate.Name, Key: member.key(), Provider: member.Provider,
			Transport: member.Transport, Type: member.Type, Port: member.Port,
		})
	}
	if len(pool) == 0 {
		if e.laneProbeAt[lane.config.ID].IsZero() {
			e.laneProbeAt[lane.config.ID] = e.runtime.Now()
		}
		return false
	}
	width := e.cfg.WaveWidth
	if width > len(pool) {
		width = len(pool)
	}
	rank := map[string]int{}
	if lane.incumbent != "" {
		rank[lane.incumbent] = 0
	}
	if e.snapshot != nil {
		if picks := e.snapshot.LanePicks[lane.config.ID]; picks != nil {
			rank[e.nameOf(picks[e.envKey])] = 1
		}
	}
	for index, node := range e.laneStandbyNames(lane) {
		rank[node] = 2 + index
	}
	sort.SliceStable(pool, func(i, j int) bool {
		ri, iok := rank[pool[i].Name]
		rj, jok := rank[pool[j].Name]
		if iok != jok {
			return iok
		}
		if iok && ri != rj {
			return ri < rj
		}
		return byName[pool[i].Name].Evidence < byName[pool[j].Name].Evidence
	})
	pool = rcxUniqueProbeNodes(pool, lane.incumbent)
	wave := pool[:min(width, len(pool))]
	wave = e.afford(wave, rcxProbeReserve+e.discoveryProtected(e.runtime.Now()), e.runtime.Now())
	if len(wave) == 0 {
		return false
	}
	for _, node := range wave {
		seen[node.Name] = struct{}{}
	}
	e.laneProbeAt[lane.config.ID] = time.Time{}
	e.startProbeWave(wave, rcxWaveRescue, lane.config.ID)
	return true
}
