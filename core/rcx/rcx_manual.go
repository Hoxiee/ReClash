package rcx

import "time"

type rcxManualPick struct {
	Key         string
	Environment string
	At          time.Time
}

func (e *rcxEngine) holdsManualPick() bool {
	pick := e.manualPick
	return e.cfg.RespectPick && pick.Key != "" && pick.Environment == e.envKey &&
		e.pin() == e.incumbent && e.key(e.incumbent) == pick.Key &&
		!e.ledger.LastFailureAt(pick.Key, e.envKey).After(pick.At)
}

func (e *rcxEngine) verifyManualPick(members []rcxMember, now time.Time) {
	if e.probing || e.screenOff || e.suspended ||
		(!e.pinWaveAt.IsZero() && now.Sub(e.pinWaveAt) < rcxPinWaveRetry) {
		return
	}
	for _, member := range members {
		if member.Name != e.incumbent {
			continue
		}
		wave := e.afford([]rcxProbeNode{{Name: member.Name, Key: member.key()}}, 0, now)
		if len(wave) > 0 {
			e.pinWaveAt = now
			e.startProbeWave(wave, rcxWaveRoutine, "")
		}
		return
	}
}
