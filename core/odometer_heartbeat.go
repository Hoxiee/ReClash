package main

import (
	"sync"
	"time"
)

var odometerHeartbeat sync.Once

func startOdometerHeartbeat() {
	odometerHeartbeat.Do(func() {
		go func() {
			ticker := time.NewTicker(odoTickInterval)
			defer ticker.Stop()
			for range ticker.C {
				odometerInstance.Tick(time.Now())
			}
		}()
	})
}
