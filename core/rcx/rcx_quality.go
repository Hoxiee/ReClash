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

func (e *rcxEngine) queueQuality(to string) {
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
	e.quality = rcxQualityCheck{From: e.key(e.incumbent), To: e.key(to), Marker: marker, Env: e.envKey, Epoch: e.envSince.UnixNano(), Config: e.configGen}
}

func (e *rcxEngine) startQualityProbe() bool {
	q := &e.quality
	now := e.runtime.Now()
	if q.To == "" || q.From != e.key(e.incumbent) || q.Env != e.envKey || q.Epoch != e.envSince.UnixNano() || q.Config != e.configGen || e.pin() != "" || e.markerQuarantined(q.Marker, now) {
		return false
	}
	if q.Rounds >= 2 && now.Sub(q.Last) <= 2*time.Minute {
		return false
	}
	if !q.Attempt.IsZero() && now.Sub(q.Attempt) < rcxDiscoveryInterval {
		return false
	}
	d := e.discoveryState()
	if e.discoveryWarm(d, now) && d.Confirmations >= 4 {
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
	if e.budget.Remaining(now) < rcxProbeReserve+2 {
		return false
	}
	wave := e.afford(nodes, rcxProbeReserve, now)
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
	if from <= 0 || to <= 0 || !reliable && !rcxLatencyImproves(e.cfg.Strategy, from, to) {
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

func (e *rcxEngine) comparableMedian(key string, now time.Time) int {
	for _, marker := range e.activeMarkers(rcxRoleOpen, now) {
		if ms, count := e.ledger.QualityMedian(key, e.envKey, rcxMarkerID(rcxRoleOpen, marker), e.qualityEpoch(), now); count > 0 {
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
