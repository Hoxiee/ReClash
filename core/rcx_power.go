//go:build !android

package core

import (
	"sync"
	"time"

	"core/rcx"
)

const rcxPowerEvery = 2 * time.Minute

type rcxPowerState struct {
	onBattery bool
	powerSave bool
}

var rcxPowerOnce sync.Once

// Desktop has no power broadcasts: the battery is sampled, and a late tick on the wall clock is a resume.
func rcxWatchPower() {
	rcxPowerOnce.Do(func() { go rcxPowerLoop() })
}

func rcxPowerLoop() {
	var last rcxPowerState
	known, resumed := false, false
	at := time.Now()
	ticker := time.NewTicker(rcxPowerEvery)
	defer ticker.Stop()
	for {
		hints := rcx.Hints{Resumed: resumed}
		if state, ok := readPowerState(); ok && (!known || state != last) {
			last, known = state, true
			hints.OnBattery, hints.PowerSave = &state.onBattery, &state.powerSave
		}
		if e := rcxIfReady(); e != nil && (hints.Resumed || hints.OnBattery != nil) {
			e.SetHints(hints)
		}
		now := <-ticker.C
		resumed = now.Round(0).Sub(at.Round(0)) > 2*rcxPowerEvery
		at = now
	}
}
