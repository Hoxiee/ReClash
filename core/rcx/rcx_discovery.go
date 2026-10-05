package rcx

import (
	"sort"
	"time"
)

const (
	rcxDiscoveryLimit    = 48
	rcxDiscoveryBatch    = 8
	rcxDiscoveryWindow   = 2 * time.Minute
	rcxDiscoveryRepeat   = 10 * time.Minute
	rcxDiscoveryInterval = time.Minute
	rcxDiscoveryReserve  = 40
	// Discovery keeps learning while the incumbent stalls: incident waves own
	// the suspect, so two unseen nodes per turn is enough to outpace starvation.
	rcxSuspectedDiscoveryWidth = 2
)

type rcxDiscoveryState struct {
	Seen          map[string]time.Time
	Deferred      map[string]time.Time
	Started       time.Time
	Epoch         int64
	LastPeriodic  time.Time
	LastUsed      time.Time
	Attempts      int
	Confirmations int
	Reason        string
}

type rcxDiscoveryReport struct {
	Covered       int    `json:"covered"`
	Pending       int    `json:"pending"`
	Attempts      int    `json:"attempts"`
	Confirmations int    `json:"confirmations"`
	State         string `json:"state"`
}

type rcxWaveReceipt struct {
	Paid        int
	ReservedAt  time.Time
	Environment string
	Discovery   bool
	Quality     bool
}

func (e *rcxEngine) discoveryState() *rcxDiscoveryState {
	if e.discovery == nil {
		e.discovery = map[string]*rcxDiscoveryState{}
	}
	d := e.discovery[e.envKey]
	now := e.runtime.Now()
	if d == nil {
		if len(e.discovery) >= 16 {
			oldest := ""
			var at time.Time
			for key, state := range e.discovery {
				if oldest == "" || state.LastUsed.Before(at) {
					oldest, at = key, state.LastUsed
				}
			}
			delete(e.discovery, oldest)
		}
		d = &rcxDiscoveryState{Seen: map[string]time.Time{}, Deferred: map[string]time.Time{}}
		e.discovery[e.envKey] = d
	}
	if d.Started.IsZero() || d.Epoch != e.envSince.UnixNano() && now.Sub(d.Started) >= rcxDiscoveryRepeat {
		d.Started = now
		d.Epoch = e.envSince.UnixNano()
		d.Attempts = 0
		d.Confirmations = 0
	}
	d.LastUsed = now
	return d
}

func (e *rcxEngine) canImprove() bool {
	return e.Enabled() && !e.screenOff && !e.suspended && !e.pendingHandoff && !e.sweeping && e.runtime.Mode() == "rule" && e.terrainCurrent() != rcxTerrainOffline && e.terrainCurrent() != rcxTerrainPortal
}

func (e *rcxEngine) discoveryWarm(d *rcxDiscoveryState, now time.Time) bool {
	return d.Attempts < rcxDiscoveryLimit && now.Sub(d.Started) < rcxDiscoveryWindow
}

func (e *rcxEngine) discoveryNodes(members []rcxMember, limit int) []rcxProbeNode {
	d := e.discoveryState()
	now := e.runtime.Now()
	live := map[string]bool{}
	for _, m := range members {
		live[m.key()] = true
	}
	for key := range d.Seen {
		if !live[key] {
			delete(d.Seen, key)
		}
	}
	for key := range d.Deferred {
		if !live[key] {
			delete(d.Deferred, key)
		}
	}
	pool := make([]rcxProbeNode, 0, limit)
	host := make(map[string]rcxMember, len(members))
	providers := map[string]bool{}
	for _, m := range members {
		key := m.key()
		if _, seen := d.Seen[key]; seen || now.Before(d.Deferred[key]) {
			continue
		}
		if !e.ledger.CoolUntil(key, e.envKey, now).IsZero() && now.Before(e.ledger.CoolUntil(key, e.envKey, now)) {
			continue
		}
		if e.providerCircuitOpen(m.Provider, m.Name, now) {
			if providers[m.Provider] || !e.discoverySentinelDue(m.Provider, now) {
				continue
			}
			providers[m.Provider] = true
		}
		if _, dup := host[key]; !dup {
			host[key] = m
		}
		pool = append(pool, rcxProbeNode{Name: m.Name, Key: key, Provider: m.Provider, Transport: m.Transport, Type: m.Type, Port: m.Port})
	}
	pool = rcxUniqueProbeNodes(pool, e.incumbent)
	// Probe the closer entries first: a live host ping is a cheap distance prior,
	// so the fast band fills before far nodes monopolize the proven set. Unpinged
	// nodes keep subscription order, preserving round-robin coverage.
	sort.SliceStable(pool, func(i, j int) bool {
		a, b := host[pool[i].Key], host[pool[j].Key]
		aLive := a.HostMs > 0 && !a.HostDead
		bLive := b.HostMs > 0 && !b.HostDead
		if aLive != bLive {
			return aLive
		}
		if aLive && a.HostMs != b.HostMs {
			return a.HostMs < b.HostMs
		}
		return false
	})
	if len(pool) > limit {
		pool = pool[:limit]
	}
	return pool
}

func (e *rcxEngine) startImprovement(periodic bool) bool {
	if !e.canImprove() || e.probing || e.incumbent == "" {
		return false
	}
	now := e.runtime.Now()
	members := e.runtime.Members()
	if e.suspected(now) {
		// A stalling incumbent must not pause learning: incident waves own it,
		// while a narrow discovery keeps measuring unseen nodes so a slow
		// incumbent cannot starve its own replacement.
		wave := e.discoveryNodes(members, rcxSuspectedDiscoveryWidth)
		if len(wave) == 0 {
			return false
		}
		wave = e.afford(wave, rcxProbeReserve, now)
		if len(wave) == 0 {
			return false
		}
		d := e.discoveryState()
		for _, node := range wave {
			d.Deferred[node.Key] = now.Add(rcxDiscoveryInterval)
		}
		e.laneBurst = 0
		e.startProbeWave(wave, rcxWaveDiscover, "")
		return true
	}
	if e.startQualityProbe(e.slowEscapeNeeded(members, now)) {
		return true
	}
	if e.startSuspectCheck() {
		return true
	}
	d := e.discoveryState()
	warm := e.discoveryWarm(d, now)
	if !warm && (!periodic || !d.LastPeriodic.IsZero() && now.Sub(d.LastPeriodic) < rcxDiscoveryInterval) {
		return false
	}
	limit := 1
	if warm {
		limit = min(e.cfg.WaveWidth, rcxDiscoveryBatch, rcxDiscoveryLimit-d.Attempts)
	}
	wave := e.discoveryNodes(members, limit)
	if len(wave) == 0 {
		d.Reason = "covered"
		return false
	}
	wave = e.afford(wave, rcxProbeReserve, now)
	if len(wave) == 0 {
		d.Reason = "budget"
		return false
	}
	for _, node := range wave {
		d.Deferred[node.Key] = now.Add(rcxDiscoveryInterval)
		if e.providerCircuitOpen(node.Provider, node.Name, now) {
			e.noteDiscoverySentinel(node.Provider, now)
		}
	}
	d.Reason = "probing"
	e.laneBurst = 0
	e.startProbeWave(wave, rcxWaveDiscover, "")
	return true
}

// A too-slow incumbent is escaped briskly: past the effective ceiling by median
// or, unmeasured, by entry ping, its quality checks re-probe without the wait.
func (e *rcxEngine) slowEscapeNeeded(members []rcxMember, now time.Time) bool {
	if e.incumbent == "" {
		return false
	}
	policy := e.cfg.policy()
	ceiling := rcxEffectiveCeiling(policy)
	if ceiling <= 0 {
		return false
	}
	if median := e.comparableMedian(e.key(e.incumbent), now, rcxScaledProofTTL(e.ledger.ProofTTL(), len(members))); median > 0 {
		return median >= ceiling
	}
	for _, member := range members {
		if member.Name == e.incumbent {
			return !member.HostDead && member.HostMs >= ceiling
		}
	}
	return false
}

func (e *rcxEngine) markDiscoveryResult(result rcxProbeResult, now time.Time) {
	if result.Outcome == rcxProbeOverloaded && result.ExitCountry == "" {
		return
	}
	d := e.discoveryState()
	key := result.Key
	if key == "" {
		key = e.key(result.Node)
	}
	d.Seen[key] = now
	delete(d.Deferred, key)
}

func (e *rcxEngine) discoveryReport() rcxDiscoveryReport {
	d := e.discoveryState()
	now := e.runtime.Now()
	keys := map[string]bool{}
	for _, m := range e.runtime.Members() {
		keys[m.key()] = true
	}
	covered := 0
	for key := range keys {
		if _, ok := d.Seen[key]; ok {
			covered++
		}
	}
	reason := d.Reason
	switch {
	case !e.canImprove():
		reason = "paused"
	case e.budget.Remaining(now) <= rcxProbeReserve:
		reason = "budget"
	case covered == len(keys):
		reason = "covered"
	case !e.discoveryWarm(d, now):
		reason = "periodic"
	}
	return rcxDiscoveryReport{Covered: covered, Pending: len(keys) - covered, Attempts: d.Attempts, Confirmations: d.Confirmations, State: reason}
}

// The tick re-proves only this handful; the slow, far, or dead tail is covered
// once by discovery and thereafter reached solely by the reactive waves.
func (e *rcxEngine) warmPool(candidates []rcxCandidate, now time.Time) map[string]struct{} {
	input := rcxDecisionInput{
		Terrain: e.terrainCurrent(), Incumbent: e.incumbent, Pin: e.pin(),
		Policy: e.cfg.policy(), Now: now,
	}
	input.Policy.Censoring = rcxEffectiveCensoring(input)
	compare := rcxCompareFor(input.Policy)
	type rankedNode struct {
		name string
		key  rcxKey
	}
	proven := make([]rankedNode, 0, len(candidates))
	for _, c := range candidates {
		if !rcxEligible(c, input) ||
			(c.Facts.OpenWorld != rcxProofProven && c.Facts.Transit != rcxProofProven) {
			continue
		}
		key := rcxKeyOf(c, input)
		if key.verdict == rcxVerdictLastResort {
			continue
		}
		proven = append(proven, rankedNode{c.Name, key})
	}
	sort.SliceStable(proven, func(i, j int) bool {
		return compare(proven[i].key, proven[j].key) < 0
	})
	warm := make(map[string]struct{}, rcxWarmPoolCap+rcxStandbyCount+2)
	for i, r := range proven {
		if i >= rcxWarmPoolCap {
			break
		}
		warm[r.name] = struct{}{}
	}
	for _, name := range e.standbyNames() {
		warm[name] = struct{}{}
	}
	if e.incumbent != "" {
		warm[e.incumbent] = struct{}{}
	}
	if pin := e.pin(); pin != "" {
		warm[pin] = struct{}{}
	}
	return warm
}

func (e *rcxEngine) planMaintenance(candidates []rcxCandidate, members []rcxMember) []rcxProbeNode {
	now := e.runtime.Now()
	byName := map[string]rcxCandidate{}
	for _, c := range candidates {
		byName[c.Name] = c
	}
	warm := e.warmPool(candidates, now)
	pool := []rcxProbeNode{}
	for _, m := range members {
		c := byName[m.Name]
		if _, ok := warm[m.Name]; !ok {
			continue
		}
		if (!e.proofDue(m.Name, now) && !e.latencyStale(c, now)) || c.Circuit || now.Before(c.CoolUntil) {
			continue
		}
		pool = append(pool, rcxProbeNode{Name: m.Name, Key: m.key(), Provider: m.Provider, Transport: m.Transport, Type: m.Type, Port: m.Port})
	}
	sort.SliceStable(pool, func(i, j int) bool {
		return e.ledger.ProbeAt(pool[i].Key, e.envKey).Before(e.ledger.ProbeAt(pool[j].Key, e.envKey))
	})
	rcxHoistNodes(pool, e.standbyNames())
	rcxHoistNode(pool, e.incumbent)
	pool = rcxUniqueProbeNodes(pool, e.incumbent)
	if len(pool) > rcxMaintainWidth {
		pool = pool[:rcxMaintainWidth]
	}
	return e.afford(pool, rcxProbeReserve+e.discoveryProtected(now), now)
}

func (e *rcxEngine) discoveryProtected(now time.Time) int {
	spent := 0
	kept := e.discoverySpent[:0]
	for _, at := range e.discoverySpent {
		if now.Sub(at) < rcxProbeBudgetWin {
			kept = append(kept, at)
			spent++
		}
	}
	e.discoverySpent = kept
	return max(rcxDiscoveryReserve-spent, 0)
}

func (e *rcxEngine) improvementWave() bool {
	return e.probing && (e.probeKind == rcxWaveDiscover || e.probeKind == rcxWaveQuality || e.probeKind == rcxWaveMaintain)
}

func (e *rcxEngine) settleWaveReceipt(gen uint32, dispatched int) {
	receipt, ok := e.receipts[gen]
	if !ok {
		return
	}
	delete(e.receipts, gen)
	dispatched = min(max(dispatched, 0), receipt.Paid)
	e.budget.RefundAt(receipt.Paid-dispatched, receipt.ReservedAt)
	if receipt.Environment == e.envKey {
		d := e.discoveryState()
		if receipt.Discovery {
			d.Attempts += dispatched
			if dispatched > 0 {
				d.LastPeriodic = receipt.ReservedAt
			}
			for i := 0; i < dispatched; i++ {
				e.discoverySpent = append(e.discoverySpent, receipt.ReservedAt)
			}
		}
		if receipt.Quality {
			d.Confirmations += dispatched
		}
	}
	if e.paidWaveGen == gen {
		e.paidWave = 0
	}
}

func rcxEmergencyOrder(nodes []rcxProbeNode, width int) []rcxProbeNode {
	if width < 4 || len(nodes) <= width {
		return nodes
	}
	front := width - width/4
	result := append([]rcxProbeNode(nil), nodes[:front]...)
	seen := map[string]bool{}
	bucket := func(n rcxProbeNode) string { return n.Provider + "|" + n.Transport + "|" + n.Type }
	for _, n := range result {
		seen[bucket(n)] = true
	}
	chosen := map[string]bool{}
	for _, n := range nodes[front:] {
		if !seen[bucket(n)] && len(result) < width {
			result = append(result, n)
			seen[bucket(n)] = true
			chosen[n.Name] = true
		}
	}
	for _, n := range nodes[front:] {
		if !chosen[n.Name] {
			result = append(result, n)
		}
	}
	return result
}
