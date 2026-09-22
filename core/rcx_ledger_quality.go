package main

import (
	"sort"
	"time"
)

const (
	rcxRecurrenceLimit = 6
	rcxRecurrenceDecay = time.Hour
	rcxQualityDepth    = 16
	rcxQualityTTL      = 2 * time.Minute
	// Ranking keeps a median as long as the open proof it rode in on: the tick
	// re-proves the warm pool far slower than the 2-min confirm window, so a
	// tighter TTL would blank MedianMs between probes and drop ranking to host-ping.
	rcxRankingMedianTTL   = time.Duration(rcxProofTTLMinutes) * time.Minute
	rcxQualityOriginProbe = "probe"
)

type rcxQualitySample struct {
	Origin  string    `json:"o"`
	DelayMs int       `json:"d"`
	At      time.Time `json:"t"`
	Marker  string    `json:"m"`
	Role    rcxRole   `json:"r"`
	Epoch   uint64    `json:"e"`
	Under   string    `json:"u"`
}

type rcxFailureEpisode struct {
	At      time.Time `json:"a"`
	Dial    bool      `json:"d,omitempty"`
	Markers []string  `json:"m,omitempty"`
}

func rcxFreshAt(at, now time.Time, ttl time.Duration) bool {
	return !at.IsZero() && !at.After(now) && now.Sub(at) <= ttl
}

func (l *rcxLedger) TrafficAt(node, envKey string) time.Time {
	l.mu.Lock()
	defer l.mu.Unlock()
	return l.envState(envKey, node).TrafficAt
}

func (l *rcxLedger) ProbeGoodAt(node, envKey string) time.Time {
	l.mu.Lock()
	defer l.mu.Unlock()
	return l.envState(envKey, node).ProbeGoodAt
}

func (l *rcxLedger) HarvestAt(node, envKey string) time.Time {
	l.mu.Lock()
	defer l.mu.Unlock()
	return l.envState(envKey, node).HarvestAt
}

func (l *rcxLedger) NoteQualitySample(node, envKey, marker string, epoch uint64, delay int, now time.Time) {
	l.NoteRoleQualitySample(node, envKey, marker, rcxRoleOpen, epoch, delay, now)
}

func (l *rcxLedger) NoteRoleQualitySample(node, envKey, marker string, role rcxRole, epoch uint64, delay int, now time.Time) {
	if marker == "" || delay <= 0 || rcxImplausibleDelay(delay) || now.IsZero() {
		return
	}
	l.mu.Lock()
	defer l.mu.Unlock()
	under := l.openFingerprint
	if role == rcxRoleDomestic {
		under = l.homeFingerprint
	}
	state := l.envState(envKey, node)
	sample := rcxQualitySample{Origin: rcxQualityOriginProbe, DelayMs: delay, At: now, Marker: marker, Role: role, Epoch: epoch, Under: under}
	state.QualitySamples = mergeQualitySamples(state.QualitySamples, []rcxQualitySample{sample})
}

func (l *rcxLedger) QualityMedian(node, envKey, marker string, epoch uint64, now time.Time) (ms, count int) {
	l.mu.Lock()
	defer l.mu.Unlock()
	fresh := l.qualitySamplesLocked(node, envKey, marker, epoch, now, rcxRankingMedianTTL)
	if len(fresh) == 0 {
		return 0, 0
	}
	sort.Slice(fresh, func(i, j int) bool { return fresh[i].DelayMs < fresh[j].DelayMs })
	return fresh[len(fresh)/2].DelayMs, len(fresh)
}

func (l *rcxLedger) LatestQualitySample(node, envKey, marker string, epoch uint64, now time.Time) (rcxQualitySample, bool) {
	l.mu.Lock()
	defer l.mu.Unlock()
	fresh := l.qualitySamplesLocked(node, envKey, marker, epoch, now, rcxQualityTTL)
	if len(fresh) == 0 {
		return rcxQualitySample{}, false
	}
	latest := fresh[0]
	for _, sample := range fresh[1:] {
		if sample.At.After(latest.At) {
			latest = sample
		}
	}
	return latest, true
}

func (l *rcxLedger) qualitySamplesLocked(node, envKey, marker string, epoch uint64, now time.Time, ttl time.Duration) []rcxQualitySample {
	var fresh []rcxQualitySample
	for _, sample := range l.envState(envKey, node).QualitySamples {
		if sample.Origin == rcxQualityOriginProbe && sample.Marker == marker && sample.Role == rcxRoleOpen && sample.Epoch == epoch &&
			sample.Under == l.openFingerprint && sample.DelayMs >= rcxHarvestFloorMs && rcxFreshAt(sample.At, now, ttl) {
			fresh = append(fresh, sample)
		}
	}
	return fresh
}

func mergeQualitySamples(current, incoming []rcxQualitySample) []rcxQualitySample {
	merged := append(append([]rcxQualitySample(nil), current...), incoming...)
	sort.SliceStable(merged, func(i, j int) bool { return merged[i].At.Before(merged[j].At) })
	unique := merged[:0]
	for _, sample := range merged {
		duplicate := false
		for _, known := range unique {
			if known.Origin == sample.Origin && known.At.Equal(sample.At) && known.Marker == sample.Marker && known.Role == sample.Role && known.Epoch == sample.Epoch && known.Under == sample.Under {
				duplicate = true
				break
			}
		}
		if !duplicate {
			unique = append(unique, sample)
		}
	}
	if len(unique) > rcxQualityDepth {
		unique = unique[len(unique)-rcxQualityDepth:]
	}
	return unique
}

func (l *rcxLedger) Recurrence(node, envKey string, now time.Time) int {
	l.mu.Lock()
	defer l.mu.Unlock()
	state := l.envState(envKey, node)
	l.decayRecurrenceLocked(state, now)
	return len(state.RecurrenceEvents)
}

func (l *rcxLedger) NoteMarkerFailure(node, envKey, marker string, terrain rcxTerrain, now time.Time) bool {
	if marker == "" {
		return false
	}
	l.mu.Lock()
	defer l.mu.Unlock()
	return l.noteFailureLocked(node, envKey, marker, terrain, now)
}

func (l *rcxLedger) noteRecurrenceLocked(state *rcxNodeEnv, marker string, now time.Time) {
	state.RecurrenceEvents = append(state.RecurrenceEvents, rcxFailureEpisode{At: now})
	if len(state.RecurrenceEvents) > rcxRecurrenceLimit {
		state.RecurrenceEvents = state.RecurrenceEvents[len(state.RecurrenceEvents)-rcxRecurrenceLimit:]
	}
	state.RecurrenceAt = now
	l.attachFailureSourceLocked(state, marker, now)
}

func (l *rcxLedger) attachFailureSourceLocked(state *rcxNodeEnv, marker string, at time.Time) {
	for i := range state.RecurrenceEvents {
		episode := &state.RecurrenceEvents[i]
		if !episode.At.Equal(at) {
			continue
		}
		if marker == "" {
			episode.Dial = true
			return
		}
		for _, known := range episode.Markers {
			if known == marker {
				return
			}
		}
		episode.Markers = append(episode.Markers, marker)
		return
	}
}

func (l *rcxLedger) decayRecurrenceLocked(state *rcxNodeEnv, now time.Time) {
	decayRecurrence(state, now)
}

func decayRecurrence(state *rcxNodeEnv, now time.Time) {
	if len(state.RecurrenceEvents) == 0 || state.RecurrenceAt.IsZero() {
		return
	}
	credits := int(now.Sub(state.RecurrenceAt) / rcxRecurrenceDecay)
	if credits <= 0 {
		return
	}
	state.RecurrenceAt = state.RecurrenceAt.Add(time.Duration(credits) * rcxRecurrenceDecay)
	if credits >= len(state.RecurrenceEvents) {
		state.RecurrenceEvents = nil
	} else {
		state.RecurrenceEvents = state.RecurrenceEvents[credits:]
	}
}

func (l *rcxLedger) rollbackRecurrenceLocked(state *rcxNodeEnv, count int) {
	if count <= 0 {
		return
	}
	previous := latestRecurrenceAt(state)
	start := max(len(state.failureCharges)-count, 0)
	refunded := state.failureCharges[start:]
	kept := state.RecurrenceEvents[:0]
	for _, episode := range state.RecurrenceEvents {
		remove := false
		for _, at := range refunded {
			remove = remove || episode.At.Equal(at)
		}
		if !remove {
			kept = append(kept, episode)
		}
	}
	state.RecurrenceEvents = kept
	state.failureCharges = state.failureCharges[:start]
	resetRecurrenceAnchor(state, previous)
}

func latestRecurrenceAt(state *rcxNodeEnv) time.Time {
	if len(state.RecurrenceEvents) == 0 {
		return time.Time{}
	}
	return state.RecurrenceEvents[len(state.RecurrenceEvents)-1].At
}

func resetRecurrenceAnchor(state *rcxNodeEnv, previous time.Time) {
	latest := latestRecurrenceAt(state)
	if latest.IsZero() {
		state.RecurrenceAt = time.Time{}
	} else if !previous.IsZero() {
		state.RecurrenceAt = state.RecurrenceAt.Add(latest.Sub(previous))
	}
}

func (l *rcxLedger) RollbackMarkerFailures(marker string, now time.Time) {
	l.mu.Lock()
	defer l.mu.Unlock()
	for _, nodes := range l.envs {
		for _, state := range nodes {
			l.decayRecurrenceLocked(state, now)
			previous := latestRecurrenceAt(state)
			kept := state.RecurrenceEvents[:0]
			refund := 0
			for _, episode := range state.RecurrenceEvents {
				markers := make([]string, 0, len(episode.Markers))
				removed := false
				for _, id := range episode.Markers {
					if id == marker {
						removed = true
					} else {
						markers = append(markers, id)
					}
				}
				episode.Markers = markers
				if removed && !episode.Dial && len(markers) == 0 {
					refund++
					continue
				}
				kept = append(kept, episode)
			}
			state.RecurrenceEvents = kept
			if refund > 0 {
				resetRecurrenceAnchor(state, previous)
				l.refundLocked(state, refund)
			}
			if evidence, ok := state.Markers[marker]; ok {
				delete(state.Markers, marker)
				if evidence.Role == rcxRoleOpen {
					state.OpenWorld, state.OpenAt = rcxProofUnknown, time.Time{}
				} else {
					state.Domestic, state.DomesticAt = rcxProofUnknown, time.Time{}
				}
			}
			quality := state.QualitySamples[:0]
			for _, sample := range state.QualitySamples {
				if sample.Marker != marker {
					quality = append(quality, sample)
				}
			}
			state.QualitySamples = quality
		}
	}
}

func mergeQualityState(current, incoming *rcxNodeEnv) {
	if incoming.TrafficAt.After(current.TrafficAt) {
		current.TrafficAt = incoming.TrafficAt
	}
	if incoming.ProbeGoodAt.After(current.ProbeGoodAt) {
		current.ProbeGoodAt = incoming.ProbeGoodAt
	}
	if incoming.HarvestAt.After(current.HarvestAt) {
		current.HarvestAt = incoming.HarvestAt
	}
	current.QualitySamples = mergeQualitySamples(current.QualitySamples, incoming.QualitySamples)
	mergeRecurrenceState(current, incoming)
	charges := append(append([]time.Time(nil), current.failureCharges...), incoming.failureCharges...)
	sort.Slice(charges, func(i, j int) bool { return charges[i].Before(charges[j]) })
	unique := charges[:0]
	for _, at := range charges {
		if len(unique) == 0 || !unique[len(unique)-1].Equal(at) {
			unique = append(unique, at)
		}
	}
	if len(unique) > rcxRecurrenceLimit {
		unique = unique[len(unique)-rcxRecurrenceLimit:]
	}
	current.failureCharges = unique
}

func mergeRecurrenceState(current, incoming *rcxNodeEnv) {
	anchor := current.RecurrenceAt
	if incoming.RecurrenceAt.After(anchor) {
		anchor = incoming.RecurrenceAt
	}
	decayRecurrence(current, anchor)
	other := *incoming
	decayRecurrence(&other, anchor)
	merged := append(append([]rcxFailureEpisode(nil), current.RecurrenceEvents...), other.RecurrenceEvents...)
	sort.SliceStable(merged, func(i, j int) bool { return merged[i].At.Before(merged[j].At) })
	unique := make([]rcxFailureEpisode, 0, len(merged))
	for _, episode := range merged {
		if len(unique) == 0 || episode.At.Sub(unique[len(unique)-1].At) >= 10*time.Second {
			episode.Markers = append([]string(nil), episode.Markers...)
			unique = append(unique, episode)
			continue
		}
		known := &unique[len(unique)-1]
		known.Dial = known.Dial || episode.Dial
		for _, marker := range episode.Markers {
			found := false
			for _, existing := range known.Markers {
				found = found || existing == marker
			}
			if !found {
				known.Markers = append(known.Markers, marker)
			}
		}
	}
	if len(unique) > rcxRecurrenceLimit {
		unique = unique[len(unique)-rcxRecurrenceLimit:]
	}
	current.RecurrenceEvents = unique
	current.RecurrenceAt = anchor
}
