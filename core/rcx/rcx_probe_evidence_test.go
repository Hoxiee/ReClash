package rcx

import (
	"context"
	"errors"
	"testing"
	"time"
)

func TestProbeCancellationCannotRefuteAWorkingIncumbent(t *testing.T) {
	for _, tc := range []struct {
		name      string
		kind      rcxWaveKind
		live      bool
		cancelled bool
		refuted   bool
	}{
		{name: "routine idle cancellation", kind: rcxWaveRoutine, cancelled: true},
		{name: "routine live cancellation", kind: rcxWaveRoutine, live: true, cancelled: true},
		{name: "incident idle cancellation", kind: rcxWaveIncident, cancelled: true},
		{name: "incident live cancellation", kind: rcxWaveIncident, live: true, cancelled: true},
		{name: "completed routine failure", kind: rcxWaveRoutine},
		{name: "completed incident with live traffic", kind: rcxWaveIncident, live: true},
		{name: "completed incident confirms failure", kind: rcxWaveIncident, refuted: true},
	} {
		t.Run(tc.name, func(t *testing.T) {
			runtime := newFakeRuntime()
			runtime.members = foreignMembers("current", "standby")
			engine := newTestEngine(runtime, "ru")
			defer engine.supersedeProbe()
			defer engine.supersedeReach()
			engine.cfg.OpenMarkers = append(engine.cfg.OpenMarkers, rcxMarker{
				URL: "https://second.example/204", Statuses: []int{204},
			})
			engine.incumbent, runtime.selected = "current", "current"
			engine.since = runtime.Now().Add(-time.Hour)
			engine.syncIdentity(runtime.members)
			markers := engine.cfg.OpenMarkers
			ids := engine.markerIDs(rcxRoleOpen, runtime.Now())
			engine.ledger.NoteMarkerProbe("current", engine.envKey, rcxRoleOpen, ids[1], rcxProbeFail, 0, runtime.Now().Add(-time.Minute))
			engine.ledger.NoteMarkerProbe("current", engine.envKey, rcxRoleOpen, ids[0], rcxProbeOK, 50, runtime.Now())
			engine.ledger.RecomputeRole("current", engine.envKey, rcxRoleOpen, ids, runtime.Now())
			engine.ledger.NoteProbe("standby", engine.envKey, rcxRoleOpen, rcxProbeOK, 100, runtime.Now())
			engine.probing, engine.probeKind = true, tc.kind
			engine.probeStarted = map[string]struct{}{}
			engine.probeLaunchedAt = runtime.Now()
			runtime.advance(time.Second)
			if tc.live {
				engine.ledger.NoteTrafficProgress("current", engine.envKey, true, runtime.Now())
			}
			parent, cancel := context.WithCancel(context.Background())
			defer cancel()
			prober := newRcxProber(func(ctx context.Context, _ string, marker rcxMarker) (int, bool, error) {
				if tc.cancelled && marker.URL == markers[1].URL {
					cancel()
					return 0, false, ctx.Err()
				}
				return 0, false, errors.New("temporary read timeout")
			}, nil)
			result := prober.probe(parent, rcxProbeTarget{
				Node: "current", Key: "current", Role: rcxRoleOpen, Markers: markers,
			})
			if tc.cancelled && result.Outcome != rcxProbeOverloaded {
				t.Fatalf("outcome = %v, want an inconclusive partial probe", result.Outcome)
			}
			engine.applyProbeResult(rcxEvent{
				Gen: engine.probeGen, ConfigGen: engine.configGen, Results: []rcxProbeResult{result},
			})
			engine.reconsider()

			wantProof, wantNode := rcxProofProven, "current"
			if tc.refuted {
				wantProof, wantNode = rcxProofDisproven, "standby"
			}
			facts := engine.ledger.Facts("current", engine.envKey, true, runtime.Now(), engine.ledger.ProofTTL())
			if facts.OpenWorld != wantProof || runtime.selected != wantNode {
				t.Fatalf("open = %v, selected = %q, reason = %q; want %v, %q", facts.OpenWorld, runtime.selected, runtime.lastStatus().Reason, wantProof, wantNode)
			}
			if tc.refuted && runtime.lastStatus().Reason != string(rcxReasonIncumbentDead) {
				t.Fatalf("reason = %q, want confirmed death", runtime.lastStatus().Reason)
			}
		})
	}
}
