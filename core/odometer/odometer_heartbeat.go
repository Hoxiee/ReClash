package odometer

import (
	"sync"
	"time"
)

var odometerHeartbeat sync.Once

var (
	odoScreenMu   sync.Mutex
	odoScreenWake = make(chan struct{})
)

func signalOdometerWake() {
	odoScreenMu.Lock()
	defer odoScreenMu.Unlock()
	close(odoScreenWake)
	odoScreenWake = make(chan struct{})
}

func odometerScreenWakeCh() <-chan struct{} {
	odoScreenMu.Lock()
	defer odoScreenMu.Unlock()
	return odoScreenWake
}

func startOdometerHeartbeat() {
	odometerHeartbeat.Do(func() {
		go func() {
			ticker := time.NewTicker(odoTickInterval)
			defer ticker.Stop()
			for {
				// BOOTTIME accrual is exact across any gap, so parking a screen-off
				// phone until wake loses no coverage; read the channel first so the wake is unmissable.
				wake := odometerScreenWakeCh()
				if screenOff() {
					<-wake
					continue
				}
				select {
				case <-ticker.C:
					odometerInstance.Tick(time.Now())
				case <-wake:
				}
			}
		}()
	})
}
