package rcx

import (
	"context"
	"sort"
	"strings"
	"sync"
	"time"
)

// A rescue and a hand-asked sweep answer what the user sees, outside the cap.
type rcxWaveKind uint8

const (
	rcxWaveRoutine rcxWaveKind = iota
	rcxWaveMaintain
	rcxWaveGrant
	rcxWaveRescue
	rcxWaveIncident
	rcxWaveHandoff
	rcxWaveDeep
	rcxWaveDiscover
	rcxWaveQuality
	rcxWaveLocate
)

// A trickle is a rate, so it hangs off the tick: one tick reconsiders often.
func (e *rcxEngine) maintain() {
	if !e.canImprove() || e.probing {
		return
	}
	if e.startImprovement(true) {
		return
	}
	members := e.runtime.Members()
	if len(members) == 0 {
		return
	}
	e.startProbe(e.candidates(members), members, rcxWaveMaintain)
}

func (e *rcxEngine) startDeepScan() {
	if !e.Enabled() || e.probing || e.runtime.Mode() != "rule" {
		return
	}
	members := e.runtime.Members()
	if len(members) == 0 {
		return
	}
	e.deep = true
	e.startProbe(e.candidates(members), members, rcxWaveDeep)
	e.reconsider()
}

func (e *rcxEngine) planWave(
	candidates []rcxCandidate,
	members []rcxMember,
	kind rcxWaveKind,
) []rcxProbeNode {
	if len(e.cfg.OpenMarkers) == 0 {
		return nil
	}
	if kind != rcxWaveDeep && e.terrain.terrain == rcxTerrainOffline {
		return nil
	}
	now := e.runtime.Now()
	if kind == rcxWaveMaintain {
		return e.planMaintenance(candidates, members)
	}
	reactive := kind == rcxWaveHandoff || kind == rcxWaveIncident || kind == rcxWaveRescue
	if reactive {
		e.prepareRescue(members)
		if e.rescueExhausted && !e.rescueAt.IsZero() && now.Sub(e.rescueAt) < rcxRescueRepeat {
			return nil
		}
		if e.rescueExhausted {
			e.resetRescue()
			e.prepareRescue(members)
		}
	}

	halfOpen := map[string]struct{}{}
	if kind == rcxWaveRoutine || kind == rcxWaveMaintain {
		halfOpen = e.circuitHalfOpenMembers(members, now)
	}
	byName := make(map[string]rcxCandidate, len(candidates))
	for _, candidate := range candidates {
		byName[candidate.Name] = candidate
	}
	suspect := ""
	if e.suspected(now) {
		suspect = e.incumbent
	}
	pool := make([]rcxProbeNode, 0, len(members))
	stamps := make(map[string]time.Time, len(members))
	for _, member := range members {
		candidate := byName[member.Name]
		if candidate.Circuit && !reactive && kind != rcxWaveDeep {
			if _, allowed := halfOpen[member.Provider]; !allowed {
				continue
			}
			delete(halfOpen, member.Provider)
		}
		if kind == rcxWaveMaintain {
			if !e.proofDue(member.Name, now) {
				continue
			}
		} else if !reactive && kind != rcxWaveDeep && member.Name != suspect &&
			candidate.Evidence == rcxEvidenceLiveTraffic && !e.openUnverified(candidate) {
			continue
		}
		if kind == rcxWaveRoutine || kind == rcxWaveMaintain {
			if !candidate.CoolUntil.IsZero() && now.Before(candidate.CoolUntil) {
				continue
			}
		}
		if reactive {
			if _, seen := e.rescueSeen[member.Name]; seen {
				continue
			}
		}
		stamps[member.Name] = e.ledger.ProbeAt(member.key(), e.envKey)
		pool = append(pool, rcxProbeNode{
			Name:      member.Name,
			Key:       member.key(),
			Provider:  member.Provider,
			Transport: member.Transport,
			Type:      member.Type,
			Port:      member.Port,
		})
	}
	pool = rcxUniqueProbeNodes(pool, e.incumbent)
	if kind == rcxWaveRoutine {
		sort.SliceStable(pool, func(i, j int) bool { return stamps[pool[i].Name].Before(stamps[pool[j].Name]) })
	}
	if suspect != "" {
		rcxHoistNode(pool, suspect)
	}
	if pin := e.pin(); pin != "" && pin != e.incumbent {
		if candidate, ok := byName[pin]; ok && candidate.Facts.Transit != rcxProofProven {
			rcxHoistNode(pool, pin)
		}
	}

	if kind == rcxWaveMaintain {
		rcxHoistNodes(pool, e.standbyNames())
		rcxHoistNode(pool, e.incumbent)
		if len(pool) > rcxMaintainWidth {
			pool = pool[:rcxMaintainWidth]
		}
		return e.afford(pool, rcxProbeReserve, now)
	}

	width := e.cfg.WaveWidth
	if kind == rcxWaveDeep {
		width = len(pool)
	} else if kind == rcxWaveHandoff && width > rcxHandoffWidth {
		width = rcxHandoffWidth
	}
	var wave []rcxProbeNode
	if reactive {
		wave = e.memoryFirstWave(pool, byName, width, now)
	} else {
		wave = append([]rcxProbeNode(nil), pool[:min(width, len(pool))]...)
	}
	if len(wave) == 0 {
		if reactive {
			e.rescueExhausted = true
			e.rescueAt = now
		}
		return nil
	}
	if reactive {
		for _, node := range wave {
			e.rescueSeen[node.Name] = struct{}{}
		}
		e.rescueExhausted = len(wave) == len(pool)
		if e.rescueExhausted {
			e.rescueAt = now
		}
	}
	e.paidWave = 0
	e.paidWaveGen = e.probeGen
	if kind == rcxWaveRoutine || kind == rcxWaveIncident || kind == rcxWaveHandoff {
		return e.afford(wave, 0, now)
	}
	return wave
}

func (e *rcxEngine) memoryFirstWave(
	pool []rcxProbeNode,
	candidates map[string]rcxCandidate,
	width int,
	now time.Time,
) []rcxProbeNode {
	if width <= 0 {
		return nil
	}
	memoryRank := map[string]int{}
	remember := func(node string, rank int) {
		if node == "" {
			return
		}
		if old, ok := memoryRank[node]; !ok || rank < old {
			memoryRank[node] = rank
		}
	}
	remember(e.incumbent, 0)
	remember(e.pin(), 1)
	if e.snapshot != nil {
		remember(e.nameOf(e.snapshot.Picks[e.envKey]), 2)
	}
	for index, node := range e.standbyNames() {
		remember(node, 3+index)
	}

	const tiers = 6
	grouped := make([][]rcxProbeNode, tiers)
	freshGreen := make(map[string]bool, len(pool))
	green := make(map[string]bool, len(pool))
	for _, node := range pool {
		candidate := candidates[node.Name]
		green[node.Name] = candidate.HostMs > 0 && !candidate.HostDead
		freshGreen[node.Name] = green[node.Name] && !candidate.HostAt.IsZero() &&
			now.Sub(candidate.HostAt) <= time.Duration(rcxFreshWindowSeconds)*time.Second
		tier := 4
		_, remembered := memoryRank[node.Name]
		switch {
		case candidate.HostDead || candidate.Facts.Transit == rcxProofDisproven ||
			(!candidate.CoolUntil.IsZero() && now.Before(candidate.CoolUntil)) ||
			e.ledger.FailStreak(node.Key, e.envKey) > 0:
			tier = 5
		case remembered:
			tier = 0
		case candidate.Facts.OpenWorld == rcxProofProven || candidate.Facts.Domestic == rcxProofProven ||
			candidate.Facts.Transit == rcxProofProven || candidate.Evidence != rcxEvidenceNone ||
			e.ledger.PreviouslyGood(node.Key, e.envKey):
			tier = 1
		case green[node.Name] && candidate.Facts.Origin != rcxOriginDomestic:
			tier = 2
		case green[node.Name]:
			tier = 3
		}
		grouped[tier] = append(grouped[tier], node)
	}

	for tier := range grouped {
		sort.SliceStable(grouped[tier], func(i, j int) bool {
			a, b := grouped[tier][i].Name, grouped[tier][j].Name
			if tier == 0 && memoryRank[a] != memoryRank[b] {
				return memoryRank[a] < memoryRank[b]
			}
			if freshGreen[a] != freshGreen[b] {
				return freshGreen[a]
			}
			if green[a] != green[b] {
				return green[a]
			}
			ca, cb := candidates[a], candidates[b]
			if tier < 4 {
				if ca.Recurrence != cb.Recurrence {
					return ca.Recurrence < cb.Recurrence
				}
				aMs, bMs := rcxDiscoveryLatency(ca), rcxDiscoveryLatency(cb)
				if aMs > 0 && bMs > 0 && aMs != bMs {
					return aMs < bMs
				}
			}
			return false
		})
	}

	wave := make([]rcxProbeNode, 0, width)
	for tier, nodes := range grouped {
		if len(wave) == width {
			break
		}
		ordered := nodes
		if tier == 4 {
			ordered = rcxEmergencyOrder(nodes, width-len(wave))
		}
		left := width - len(wave)
		if len(ordered) > left {
			ordered = ordered[:left]
		}
		wave = append(wave, ordered...)
	}
	return wave
}

type rcxRescueStamp struct {
	terrain rcxTerrain
	env     string
	park    string
}

func (e *rcxEngine) prepareRescue(members []rcxMember) {
	keys := make([]string, 0, len(members))
	for _, member := range members {
		keys = append(keys, member.key())
	}
	sort.Strings(keys)
	stamp := rcxRescueStamp{terrain: e.terrain.terrain, env: e.envKey, park: strings.Join(keys, "\x00")}
	if e.rescueMark == stamp {
		return
	}
	e.resetRescue()
	e.rescueMark = stamp
}

func (e *rcxEngine) resetRescue() {
	e.rescueAt = time.Time{}
	e.rescueMark = rcxRescueStamp{}
	e.rescueSeen = map[string]struct{}{}
	e.rescueExhausted = false
}

func (e *rcxEngine) recoveryWave() bool {
	return e.probeKind == rcxWaveHandoff || e.probeKind == rcxWaveIncident || e.probeKind == rcxWaveRescue
}

// A trickle stops at a reserve, or it starves the waves that answer an event.
func (e *rcxEngine) afford(wave []rcxProbeNode, reserve int, now time.Time) []rcxProbeNode {
	e.paidWave = 0
	e.paidWaveGen = e.probeGen
	spare := e.budget.Remaining(now) - reserve
	if spare <= 0 {
		return nil
	}
	if len(wave) > spare {
		wave = wave[:spare]
	}
	affordable := e.budget.Take(len(wave), now)
	if affordable <= 0 {
		return nil
	}
	e.paidWave = affordable
	e.paidAt = now
	return wave[:affordable]
}

func (e *rcxEngine) exitDue(key string, now time.Time) bool {
	at := e.ledger.ExitAt(key)
	return at.IsZero() || now.Sub(at) >= rcxExitTTL
}

// Half the TTL: a proof expiring between two passes is the gap this closes.
func (e *rcxEngine) proofDue(node string, now time.Time) bool {
	at := e.ledger.OpenAt(e.key(node), e.envKey)
	if at.IsZero() {
		return true
	}
	return now.Sub(at) >= e.ledger.ProofTTL()/2
}

func (e *rcxEngine) startProbe(candidates []rcxCandidate, members []rcxMember, kind rcxWaveKind) {
	if e.wakePending || e.suspended {
		return
	}
	wave := e.planWave(candidates, members, kind)
	if len(wave) == 0 {
		return
	}
	e.startProbeWave(wave, kind, "")
}

func (e *rcxEngine) startProbeWave(wave []rcxProbeNode, kind rcxWaveKind, lane string) {
	targets := e.probeTargets(wave, e.terrainCurrent(), kind)
	e.probeGen++
	e.paidWaveGen = e.probeGen
	if e.receipts == nil {
		e.receipts = map[uint32]rcxWaveReceipt{}
	}
	e.receipts[e.probeGen] = rcxWaveReceipt{
		Paid:        e.paidWave,
		ReservedAt:  e.paidAt,
		Environment: e.envKey,
		Discovery:   kind == rcxWaveDiscover,
		Quality:     kind == rcxWaveQuality,
	}
	if lane != "" {
		e.laneBurst++
	}
	e.probing = true
	e.probeLaunchedAt = e.runtime.Now()
	e.probeKind = kind
	e.probeLane = lane
	e.probeResults = nil
	e.probeStarted = map[string]struct{}{}
	e.probeRecovered = false
	e.probeDecisionClosed = false
	e.probeScreenOff = e.screenOff
	e.probeScreenEpisode = e.screenEpisode
	e.probeIncumbent = e.incumbent
	if lane != "" {
		if state := e.lanes[lane]; state != nil {
			e.probeIncumbent = state.incumbent
		}
	}
	gen := e.probeGen
	configGen := e.configGen
	prober := newRcxProber(e.runtime.Test, e.runtime.Locate)
	window := rcxProbeWave
	if kind == rcxWaveHandoff {
		window = rcxHandoffWave
		prober.concurrency = rcxHandoffParallel
		prober.timeout = rcxHandoffTimeout
	} else if kind == rcxWaveRescue || kind == rcxWaveIncident {
		window = rcxRescueWave
		prober.concurrency = rcxSweepParallel
		prober.timeout = rcxSweepTimeout
	} else if kind == rcxWaveDeep {
		window = rcxDeepProbeWave
		prober.concurrency = rcxSweepParallel
		prober.timeout = rcxSweepTimeout
	}
	quit := e.quit
	ctx, cancel := context.WithTimeout(context.Background(), window)
	e.probeCancel = cancel
	safeGoDetached("rcx probe wave", func() {
		defer cancel()
		var spentMu sync.Mutex
		spent := map[string]bool{}
		prober.Stream(ctx, targets, func(_ int, result rcxProbeResult) {
			if result.Dispatched {
				spentMu.Lock()
				spent[result.Node] = true
				spentMu.Unlock()
			}
			e.sendResult(rcxEvent{Kind: rcxEventProbeResult, Results: []rcxProbeResult{result}, Gen: gen, ConfigGen: configGen, Lane: lane}, quit)
		})
		e.sendResult(rcxEvent{Kind: rcxEventProbeResults, Gen: gen, ConfigGen: configGen, Lane: lane, Accounting: true, Dispatched: len(spent)}, quit)
	})
}

// Off a normal terrain every node is asked both markers, the origin only orders.
func (e *rcxEngine) probeTargets(
	wave []rcxProbeNode,
	terrain rcxTerrain,
	kind rcxWaveKind,
) []rcxProbeTarget {
	if kind == rcxWaveQuality {
		for _, marker := range e.activeMarkers(rcxRoleOpen, e.runtime.Now()) {
			if rcxMarkerID(rcxRoleOpen, marker) == e.quality.Marker {
				targets := make([]rcxProbeTarget, 0, len(wave))
				for _, node := range wave {
					targets = append(targets, rcxProbeTarget{Node: node.Name, Key: node.Key, Role: rcxRoleOpen, Markers: []rcxMarker{marker}})
				}
				return targets
			}
		}
		return nil
	}
	if kind == rcxWaveLocate {
		open := e.activeMarkers(rcxRoleOpen, e.runtime.Now())
		if len(open) == 0 {
			return nil
		}
		local := e.cfg.LocalMarkers
		// The rate-limited country services are worth their cost only here, verifying
		// one suspect; the unlimited IP echo trails them as the fallback.
		verify := append(append([]string{}, e.cfg.CountryEchoes...), e.cfg.EgressEchoes...)
		targets := make([]rcxProbeTarget, 0, 2*len(wave))
		for _, node := range wave {
			targets = append(targets, rcxProbeTarget{Node: node.Name, Key: node.Key, Role: rcxRoleOpen, Markers: open, Echoes: verify})
			if len(local) > 0 {
				targets = append(targets, rcxProbeTarget{Node: node.Name, Key: node.Key, Role: rcxRoleLocal, Markers: local})
			}
		}
		return targets
	}
	paired := kind == rcxWaveRescue || kind == rcxWaveIncident || kind == rcxWaveHandoff || kind == rcxWaveDeep
	now := e.runtime.Now()
	open := rcxProbeTarget{Role: rcxRoleOpen, Markers: e.activeMarkers(rcxRoleOpen, now)}
	both := len(e.cfg.DomesticMarkers) > 0 &&
		(terrain == rcxTerrainWhitelist || terrain == rcxTerrainUnknown)
	// The canaries decide the terrain; asking a second marker here only halves
	// the nodes a handoff can reach inside its window.
	if kind == rcxWaveHandoff && terrain == rcxTerrainUnknown {
		both = false
	}
	home := rcxProbeTarget{Role: rcxRoleDomestic, Markers: e.activeMarkers(rcxRoleDomestic, now)}
	primaries := make([]rcxProbeTarget, 0, len(wave))
	secondaries := make([]rcxProbeTarget, 0, len(wave))
	for _, node := range wave {
		primary, secondary := open, home
		if both && e.ledger.Origin(node.Key) == rcxOriginDomestic {
			primary, secondary = home, open
		}
		primary.Node, primary.Key = node.Name, node.Key
		secondary.Node, secondary.Key = node.Name, node.Key
		if len(e.cfg.EgressEchoes) > 0 && e.exitDue(node.Key, now) {
			if primary.Role == rcxRoleOpen {
				primary.Echoes = e.cfg.EgressEchoes
			} else {
				secondary.Echoes = e.cfg.EgressEchoes
			}
		}
		if len(primary.Markers) > 0 || len(primary.Echoes) > 0 {
			primaries = append(primaries, primary)
		}
		if !both || len(secondary.Markers) == 0 && len(secondary.Echoes) == 0 {
			continue
		}
		if paired {
			primaries = append(primaries, secondary)
		} else {
			secondaries = append(secondaries, secondary)
		}
	}
	return append(primaries, secondaries...)
}

func (e *rcxEngine) startReach() {
	if !e.Enabled() || e.reaching || e.screenOff || e.suspended ||
		len(e.cfg.CanaryForeign) == 0 {
		return
	}
	e.lastReachAt = e.runtime.Now()
	foreign := append([]string(nil), e.cfg.CanaryForeign...)
	domestic := append([]string(nil), e.cfg.CanaryDomestic...)
	e.reaching = true
	if len(e.charged) >= e.escrowQuorum() {
		e.escrowReach = true
	}
	dial := rcxCanaryTimeout
	if e.reachWarm {
		dial = rcxCanaryWarmup
	}
	gen := e.reachGen
	configGen := e.configGen
	quit := e.quit
	ctx, cancel := context.WithCancel(context.Background())
	e.reachCancel = cancel
	safeGoDetached("rcx canary round", func() {
		var (
			domesticRows    []rcxCanaryReport
			domesticOutcome rcxProbeOutcome
		)
		done := make(chan struct{})
		safeGoDetached("rcx canary domestic", func() {
			defer close(done)
			domesticOutcome = e.reachGroup(ctx, domestic, true, dial, &domesticRows)
		})
		foreignRows := make([]rcxCanaryReport, 0, len(foreign))
		foreignOutcome := e.reachGroup(ctx, foreign, false, dial, &foreignRows)
		<-done
		e.sendResult(rcxEvent{
			Kind:      rcxEventTerrainReach,
			Foreign:   foreignOutcome,
			Domestic:  domesticOutcome,
			Canaries:  append(foreignRows, domesticRows...),
			Gen:       gen,
			ConfigGen: configGen,
		}, quit)
	})
}

// Each group owns its deadline, or foreign timeouts spend the domestic dials.
func (e *rcxEngine) reachGroup(
	parent context.Context,
	addresses []string,
	domestic bool,
	dial time.Duration,
	rows *[]rcxCanaryReport,
) rcxProbeOutcome {
	ctx, cancel := context.WithTimeout(parent, dial+2*time.Second)
	defer cancel()
	return e.reachAny(ctx, addresses, domestic, dial, rows)
}

// In order, one black-holed address spends the round the others needed.
func (e *rcxEngine) reachAny(
	ctx context.Context,
	addresses []string,
	domestic bool,
	dial time.Duration,
	rows *[]rcxCanaryReport,
) rcxProbeOutcome {
	if len(addresses) == 0 {
		return rcxProbeOverloaded
	}
	ctx, cancel := context.WithCancel(ctx)
	defer cancel()

	type result struct {
		index   int
		row     rcxCanaryReport
		outcome rcxProbeOutcome
	}
	results := make(chan result, len(addresses))
	for index, address := range addresses {
		index, address := index, address
		safeGoDetached("rcx canary dial", func() {
			started := e.runtime.Now()
			outcome := rcxProbeOverloaded
			defer func() {
				results <- result{
					index: index,
					row: rcxCanaryReport{
						Addr:     address,
						Domestic: domestic,
						Outcome:  rcxOutcomeName(outcome),
						DelayMs:  int(e.runtime.Now().Sub(started) / time.Millisecond),
					},
					outcome: outcome,
				}
			}()
			dialCtx, cancelDial := context.WithTimeout(ctx, dial)
			defer cancelDial()
			outcome = e.runtime.Reach(dialCtx, address, domestic)
		})
	}

	measured := make([]*rcxCanaryReport, len(addresses))
	verdict := rcxProbeOverloaded
	for range addresses {
		got := <-results
		measured[got.index] = &got.row
		if got.outcome == rcxProbeOK {
			verdict = rcxProbeOK
			break
		}
		if got.outcome == rcxProbeFail {
			verdict = rcxProbeFail
		}
	}
	for _, row := range measured {
		if row != nil {
			*rows = append(*rows, *row)
		}
	}
	return verdict
}

func (e *rcxEngine) delayOf(node string) int {
	if node == "" {
		return 0
	}
	return e.ledger.MedianMs(e.key(node), e.envKey, e.runtime.Now(), e.suspendAt, e.suspendTo)
}

func rcxMillis(at time.Time) int64 {
	if at.IsZero() {
		return 0
	}
	return at.UnixMilli()
}
