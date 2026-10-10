package rcx

import (
	"fmt"
	"time"
)

var (
	rcxBuiltInProfile    rcxDecisionProfile
	rcxDwellSeconds      int
	rcxWaveWidth         int
	rcxProofTTLMinutes   int
	rcxDegradeConfirmSec int
	rcxAbsCeilingMs      int
	rcxThrottleFloorKBps int
	rcxProbeConcurrency  int
	rcxProbeStaggerMs    int
	rcxProbeBudgetCap    int
	rcxProbeReserve      int
)

func init() {
	profile, err := rcxLoadBuiltInProfile(rcxDefaultProfileYAML)
	if err != nil {
		panic(fmt.Sprintf("rcx: invalid embedded policy: %v", err))
	}
	rcxBuiltInProfile = profile
	rcxStrategyProfiles = profile.Strategies
	rcxAdmitRulesDefault = rcxDefaultAdmitRules()
	rcxAdmissionTable = rcxBaselineAdmission(profile)
	settings := profile.Settings.config()
	rcxDwellSeconds = settings.DwellSeconds
	rcxWaveWidth = settings.WaveWidth
	rcxProofTTLMinutes = settings.ProofTTLMinutes
	rcxLedgerProofTTL = time.Duration(rcxProofTTLMinutes) * time.Minute
	rcxDegradeConfirmSec = settings.DegradeConfirmSeconds
	rcxAbsCeilingMs = settings.AbsCeilingMs
	rcxThrottleFloorKBps = settings.ThrottleFloorKBps
	rcxProbeConcurrency = profile.Probe.Concurrency
	rcxProbeStaggerMs = profile.Probe.StaggerMs
	rcxProbeBudgetCap = profile.Probe.BudgetPerHour
	rcxProbeReserve = profile.Probe.Reserve
	for _, rung := range profile.Ladder {
		if rung.ID == rcxRungRecurrence {
			rcxRecurrenceFloorDefault = rung.RecurrenceFloor
		}
	}
}

func rcxBaselineAdmission(profile rcxDecisionProfile) map[rcxTerrain]rcxAdmissionRow {
	rows := make(map[rcxTerrain]rcxAdmissionRow)
	for kind := rcxTerrainUnknown; kind <= rcxTerrainOffline; kind++ {
		if row := profile.Terrain.States[kind.String()].Admission; row != nil {
			rows[kind] = *row
		}
	}
	return rows
}
