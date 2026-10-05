package rcx

import "time"

type rcxQualityCheck struct {
	From, To, Marker, Env string
	Epoch                 int64
	Config                uint32
	Rounds                int
	Last                  time.Time
	Attempt               time.Time
	Reliability           bool
}

func (e *rcxEngine) qualityConfirmed(to string, now time.Time) bool {
	q := e.quality
	return q.To == to && q.From == e.key(e.incumbent) && q.Env == e.envKey && q.Epoch == e.envSince.UnixNano() && q.Config == e.configGen && q.Rounds >= 2 && now.Sub(q.Last) <= 2*time.Minute && !e.markerQuarantined(q.Marker, now)
}

func (e *rcxEngine) queueQuality(to string, candidates []rcxCandidate, policy rcxPolicy) {
	if to == "" || e.key(to) == e.key(e.incumbent) {
		return
	}
	now := e.runtime.Now()
	markers := e.activeMarkers(rcxRoleOpen, now)
	if len(markers) == 0 {
		return
	}
	marker := rcxMarkerID(rcxRoleOpen, markers[0])
	if e.quality.To == e.key(to) && e.quality.From == e.key(e.incumbent) && e.quality.Marker == marker && e.quality.Env == e.envKey && e.quality.Epoch == e.envSince.UnixNano() && e.quality.Config == e.configGen {
		return
	}
	rounds, last := 0, time.Time{}
	// The rank already wants the band, not the name: retargeting inside one
	// band keeps the earned rounds, so three fast nodes stop resetting each
	// other and the slow incumbent they all beat.
	if e.quality.To != "" && e.quality.From == e.key(e.incumbent) && e.quality.Env == e.envKey &&
		e.quality.Epoch == e.envSince.UnixNano() && e.quality.Config == e.configGen &&
		e.quality.Marker == marker && !e.quality.Last.IsZero() &&
		now.Sub(e.quality.Last) <= 2*time.Minute &&
		rcxBandIndex(rcxRankingLatencyOf(candidates, to, policy), policy.LatencyBands) ==
			rcxBandIndex(rcxRankingLatencyOf(candidates, e.nameOf(e.quality.To), policy), policy.LatencyBands) {
		rounds, last = e.quality.Rounds, e.quality.Last
	}
	e.quality = rcxQualityCheck{From: e.key(e.incumbent), To: e.key(to), Marker: marker, Env: e.envKey, Epoch: e.envSince.UnixNano(), Config: e.configGen, Rounds: rounds, Last: last}
}

func rcxRankingLatencyOf(candidates []rcxCandidate, name string, policy rcxPolicy) int {
	for _, c := range candidates {
		if c.Name == name {
			return rcxRankingLatency(c, policy)
		}
	}
	return 0
}

func (e *rcxEngine) startQualityProbe(slowEscape bool) bool {
	q := &e.quality
	now := e.runtime.Now()
	if q.To == "" || q.From != e.key(e.incumbent) || q.Env != e.envKey || q.Epoch != e.envSince.UnixNano() || q.Config != e.configGen || e.pin() != "" {
		return false
	}
	// A quarantined marker must not freeze every latency switch for ten
	// minutes: re-pin to a live one and re-earn the rounds on it.
	if e.markerQuarantined(q.Marker, now) {
		markers := e.activeMarkers(rcxRoleOpen, now)
		if len(markers) == 0 {
			return false
		}
		q.Marker = rcxMarkerID(rcxRoleOpen, markers[0])
		q.Rounds, q.Last = 0, time.Time{}
	}
	if q.Rounds >= 2 && now.Sub(q.Last) <= 2*time.Minute {
		return false
	}
	// A too-slow incumbent is no better than an unavailable one: its escape
	// re-probes briskly instead of waiting out the discovery minute.
	reprobe := rcxDiscoveryInterval
	if slowEscape {
		reprobe = rcxSlowEscapeReprobe
	}
	if !q.Attempt.IsZero() && now.Sub(q.Attempt) < reprobe {
		return false
	}
	d := e.discoveryState()
	if !slowEscape && e.discoveryWarm(d, now) && d.Confirmations >= 4 {
		return false
	}
	nodes := []rcxProbeNode{}
	for _, key := range []string{q.From, q.To} {
		name := e.nameOf(key)
		if name == "" {
			return false
		}
		nodes = append(nodes, rcxProbeNode{Name: name, Key: key})
	}
	if e.budget.Remaining(now) < 2 {
		return false
	}
	// A quality check is two nodes that unblock a switch the rank already wants:
	// it rides on whatever budget is left instead of holding a reserve, or an
	// exhausted hour freezes every latency switch in quality-confirming.
	wave := e.afford(nodes, 0, now)
	if len(wave) != 2 {
		e.budget.Refund(len(wave))
		e.paidWave = 0
		return false
	}
	q.Attempt = now
	e.startProbeWave(wave, rcxWaveQuality, "")
	return true
}

func (e *rcxEngine) finishQuality(now time.Time) {
	q := &e.quality
	if q.From != e.key(e.incumbent) || q.Env != e.envKey || q.Epoch != e.envSince.UnixNano() || q.Config != e.configGen {
		return
	}
	delays := map[string]int{}
	for _, r := range e.probeResults {
		if r.Role == rcxRoleOpen && r.Outcome == rcxProbeOK && r.Fingerprint == q.Marker {
			delays[r.Key] = r.DelayMs
		}
	}
	from, to := delays[q.From], delays[q.To]
	reliable := e.ledger.Recurrence(q.From, e.envKey, now) >= 2 && e.ledger.Recurrence(q.To, e.envKey, now) < 2 || e.ledger.Degraded(q.From, e.envKey, now) && !e.ledger.Degraded(q.To, e.envKey, now)
	// A shakier record does not justify confirming a move onto a measurably
	// slower exit: the just-timed marker RTT overrides the reliability edge, so
	// this collapses to the latency test and refuses the switch.
	if reliable && from > 0 && to > from+rcxLatencyStep {
		reliable = false
	}
	// An unmeasured incumbent (no marker RTT of its own) cannot block a switch:
	// the challenger alone decides. Otherwise a first-pick node that never
	// answered its probe freezes every escape into quality-confirming forever.
	if from <= 0 {
		if to <= 0 {
			return
		}
	} else if to <= 0 {
		// A missed challenger round earns nothing but wipes nothing either: one
		// flaky probe must not zero two earned confirmations.
		return
	} else if !reliable && !rcxLatencyImproves(e.cfg.policy(), from, to) {
		q.Rounds = 0
		return
	}
	if !q.Last.IsZero() && now.Sub(q.Last) < 10*time.Second {
		return
	}
	if now.Sub(q.Last) > 2*time.Minute {
		q.Rounds = 0
	}
	q.Rounds++
	q.Last = now
	q.Reliability = reliable
}

func (e *rcxEngine) qualityEpoch() uint64 { return uint64(e.envSince.UnixNano()) ^ e.sessionEpoch }

func (e *rcxEngine) comparableMedian(key string, now time.Time, proofTTL time.Duration) int {
	for _, marker := range e.activeMarkers(rcxRoleOpen, now) {
		if ms, count := e.ledger.QualityMedian(key, e.envKey, rcxMarkerID(rcxRoleOpen, marker), e.qualityEpoch(), now, proofTTL); count > 0 {
			return ms
		}
	}
	return 0
}

func (e *rcxEngine) freshExitCountry(key string, now time.Time) string {
	at := e.ledger.ExitAt(key)
	if at.IsZero() || now.Sub(at) > rcxExitTTL {
		return ""
	}
	return e.ledger.ExitCountry(key)
}
