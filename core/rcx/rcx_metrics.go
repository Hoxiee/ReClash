package rcx

import (
	"time"
)

func (e *rcxEngine) accountMetrics(now time.Time) {
	if e.snapshot == nil {
		return
	}
	if e.accountedAt.IsZero() {
		e.accountedAt = now
		return
	}
	elapsed := now.Sub(e.accountedAt)
	e.accountedAt = now
	if elapsed <= 0 || !e.Enabled() || (!e.suspendAt.IsZero() && e.suspendTo.Equal(e.suspendAt)) {
		return
	}
	e.snapshot.Metrics.EnabledMillis += elapsed.Milliseconds()
	if e.incidentAt.IsZero() {
		e.snapshot.Metrics.AvailableMillis += elapsed.Milliseconds()
	}
	e.snapshot.Dirty = true
}

func (e *rcxEngine) startIncident(now time.Time) {
	if e.snapshot == nil || !e.incidentAt.IsZero() {
		return
	}
	e.accountMetrics(now)
	e.incidentAt = now
	e.snapshot.Metrics.Incidents++
	e.snapshot.Dirty = true
}

func (e *rcxEngine) closeIncident(now time.Time, recovered bool) {
	if e.snapshot == nil || e.incidentAt.IsZero() {
		return
	}
	e.accountMetrics(now)
	outage := now.Sub(e.incidentAt)
	e.incidentAt = time.Time{}
	if recovered && outage >= 0 {
		millis := outage.Milliseconds()
		e.snapshot.Metrics.LastOutageMillis = millis
		e.snapshot.Metrics.TotalOutageMillis += millis
		e.snapshot.Metrics.RecoveredOutages++
		e.odometer.NoteRecovery()
	}
	e.snapshot.Dirty = true
}

func (e *rcxEngine) recordFailover(now time.Time, standby bool) {
	if e.snapshot == nil || e.incidentAt.IsZero() {
		return
	}
	duration := now.Sub(e.incidentAt)
	if duration < 0 {
		duration = 0
	}
	millis := duration.Milliseconds()
	e.snapshot.Metrics.LastFailoverMillis = millis
	e.snapshot.Metrics.FailoverMillis += millis
	e.snapshot.Metrics.Failovers++
	if standby {
		e.snapshot.Metrics.StandbyHits++
	}
	e.closeIncident(now, true)
}

func (e *rcxEngine) metricsReport(now time.Time) rcxMetricsReport {
	e.accountMetrics(now)
	state := e.snapshot.Metrics
	report := rcxMetricsReport{
		EnabledMillis:     state.EnabledMillis,
		AvailableMillis:   state.AvailableMillis,
		Incidents:         state.Incidents,
		StandbyHits:       state.StandbyHits,
		ProviderIncidents: state.ProviderIncidents,
		MarkerIncidents:   state.MarkerIncidents,
		LastFailover:      state.LastFailoverMillis,
		LastOutage:        state.LastOutageMillis,
		ActiveCircuits:    e.activeCircuitReasons(now),
		ActiveMarkers:     e.activeMarkerReasons(now),
	}
	if state.EnabledMillis > 0 {
		report.Availability = int(state.AvailableMillis * 100 / state.EnabledMillis)
	}
	if state.Failovers > 0 {
		report.AverageFailover = state.FailoverMillis / int64(state.Failovers)
	}
	if state.RecoveredOutages > 0 {
		report.AverageOutage = state.TotalOutageMillis / int64(state.RecoveredOutages)
	}
	return report
}
