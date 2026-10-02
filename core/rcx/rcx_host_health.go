package rcx

import "time"

type rcxHostCheck struct {
	key       string
	url       string
	env       string
	configGen uint32
	at        time.Time
	retryAt   time.Time
	pending   bool
	confirmed bool
}

func (e *rcxEngine) hostMissSuperseded(member rcxMember) bool {
	key := member.key()
	for _, at := range []time.Time{e.ledger.TrafficAt(key, e.envKey), e.ledger.ProbeGoodAt(key, e.envKey)} {
		if !at.IsZero() && !at.Before(e.envSince) && at.After(member.HostAt) {
			return true
		}
	}
	return false
}

func (e *rcxEngine) holdsHostMiss(member rcxMember) bool {
	return !e.hostCheck.confirmed && e.hostCheck.key == member.key() && e.hostCheck.env == e.envKey &&
		e.hostCheck.configGen == e.configGen && e.hostCheck.url == e.runtime.TestURL() &&
		e.hostCheck.at.Equal(member.HostAt)
}

func (e *rcxEngine) prepareHostCheck(members []rcxMember, now time.Time) {
	var current rcxMember
	for _, member := range members {
		if member.Name == e.incumbent {
			current = member
			break
		}
	}
	if current.Name == "" || !current.HostDead || current.HostAt.IsZero() ||
		current.HostAt.Before(e.envSince) || e.hostMissSuperseded(current) {
		e.hostCheck = rcxHostCheck{}
		return
	}
	key, url := current.key(), e.runtime.TestURL()
	same := e.hostCheck.key == key && e.hostCheck.url == url &&
		e.hostCheck.env == e.envKey && e.hostCheck.configGen == e.configGen
	if same && e.hostCheck.at.Equal(current.HostAt) {
		return
	}
	if same && e.hostCheck.pending {
		e.hostCheck.at = current.HostAt
		return
	}
	if !e.freshlyOpenProven(key, now) && !e.trafficSince(key, e.envSince, now) {
		e.hostCheck = rcxHostCheck{}
		return
	}
	e.hostCheck = rcxHostCheck{
		key: key, url: url, env: e.envKey, configGen: e.configGen,
		at: current.HostAt, pending: true,
	}
}

func (e *rcxEngine) confirmHostMiss(members []rcxMember, now time.Time) bool {
	if !e.hostCheck.pending || !e.running || !e.Enabled() || e.runtime.Mode() != "rule" ||
		e.screenOff || e.suspended || e.wakePending || e.pendingHandoff || e.pendingGrant ||
		len(e.cfg.OpenMarkers) == 0 || !e.chargesNegative(now) || now.Before(e.hostCheck.retryAt) ||
		e.trafficSince(e.hostCheck.key, e.envSince, now) {
		return false
	}
	if e.probing {
		if !e.improvementWave() {
			return false
		}
		e.supersedeProbe()
	}
	for _, member := range members {
		if member.Name != e.incumbent || !e.holdsHostMiss(member) {
			continue
		}
		wave := e.afford([]rcxProbeNode{{
			Name: member.Name, Key: member.key(), Provider: member.Provider,
			Transport: member.Transport, Type: member.Type, Port: member.Port,
		}}, 0, now)
		e.hostCheck.retryAt = now.Add(rcxTickInterval)
		if len(wave) == 0 {
			return false
		}
		e.startProbeWave(wave, rcxWaveConfirm, "")
		return true
	}
	return false
}

func (e *rcxEngine) settleHostCheck(result rcxProbeResult, now time.Time) {
	if result.Node != e.incumbent || e.hostCheck.key != e.key(result.Node) ||
		e.hostCheck.env != e.envKey || e.hostCheck.configGen != e.configGen {
		return
	}
	facts := e.ledger.Facts(e.hostCheck.key, e.envKey, false, now, e.ledger.ProofTTL())
	negative := result.Outcome == rcxProbeFail || result.Outcome == rcxProbeStatusMismatch
	if result.Outcome == rcxProbeOK || (negative && e.chargesNegative(now) && facts.OpenWorld == rcxProofDisproven) {
		e.hostCheck.pending = false
		e.hostCheck.confirmed = negative
	}
}
