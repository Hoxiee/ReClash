package main

import (
	"encoding/json"
	"testing"
	"time"
)

func TestLedgerEvidenceSeparatesPayloadProbeAndHarvest(t *testing.T) {
	ledger, now := rcxTestLedger()
	ledger.NoteProbe("probe", "env", rcxRoleOpen, rcxProbeOK, 50, now)
	ledger.NoteHarvestedProbe("harvest", "env", 40, now)
	ledger.NoteTrafficProgress("traffic", "env", true, now)
	for _, node := range []string{"probe", "harvest"} {
		if got := ledger.Evidence(node, "env", now, time.Minute, time.Hour); got != rcxEvidenceFreshProbe {
			t.Errorf("%s evidence = %v, want fresh probe", node, got)
		}
		if !ledger.TrafficAt(node, "env").IsZero() {
			t.Errorf("%s acquired passive traffic", node)
		}
	}
	if got := ledger.Evidence("traffic", "env", now, time.Minute, time.Hour); got != rcxEvidenceLiveTraffic {
		t.Errorf("traffic evidence = %v", got)
	}
	if ledger.ProbeGoodAt("probe", "env") != now || ledger.HarvestAt("harvest", "env") != now {
		t.Fatal("successful probes lost their separate timestamps")
	}
	ledger.envState("env", "legacy").ProgressAt = now
	if got := ledger.Evidence("legacy", "env", now, time.Minute, time.Hour); got != rcxEvidenceNone {
		t.Errorf("ambiguous legacy timestamp became evidence: %v", got)
	}
}

func TestLedgerProofAndMarkerFailuresExpire(t *testing.T) {
	for _, role := range []rcxRole{rcxRoleOpen, rcxRoleDomestic} {
		ledger, now := rcxTestLedger()
		ledger.NoteProbe("node", "env", role, rcxProbeFail, 0, now)
		facts := ledger.Facts("node", "env", true, now.Add(rcxLedgerProofTTL+time.Second), rcxLedgerProofTTL)
		if facts.OpenWorld != rcxProofUnknown || facts.Domestic != rcxProofUnknown {
			t.Fatalf("negative role proof never expired: %+v", facts)
		}
		ledger.NoteMarkerProbe("node", "env", role, "marker", rcxProbeFail, 0, now)
		ledger.RecomputeRole("node", "env", role, []string{"marker"}, now.Add(rcxLedgerProofTTL+time.Second))
		state := ledger.envState("env", "node")
		if state.OpenWorld != rcxProofUnknown || state.Domestic != rcxProofUnknown {
			t.Fatalf("expired negative marker resurrected: %+v", state)
		}
	}
}

func TestLedgerProofRecomputeCannotRefreshOldSuccessWithNewFailure(t *testing.T) {
	ledger, now := rcxTestLedger()
	ledger.NoteMarkerProbe("node", "env", rcxRoleOpen, "good", rcxProbeOK, 40, now)
	later := now.Add(rcxLedgerProofTTL - time.Second)
	ledger.NoteMarkerProbe("node", "env", rcxRoleOpen, "bad", rcxProbeFail, 0, later)
	ledger.RecomputeRole("node", "env", rcxRoleOpen, []string{"good", "bad"}, later)
	if got := ledger.OpenAt("node", "env"); got != now {
		t.Fatalf("failure refreshed success timestamp to %v", got)
	}
	expired := now.Add(rcxLedgerProofTTL + time.Second)
	ledger.RecomputeRole("node", "env", rcxRoleOpen, []string{"good", "bad"}, expired)
	if got := ledger.Facts("node", "env", true, expired, rcxLedgerProofTTL).OpenWorld; got != rcxProofUnknown {
		t.Fatalf("stale success revived: %v", got)
	}
}

func TestLedgerProofRecomputeRejectsChangedFingerprintAndForgedDelay(t *testing.T) {
	ledger, now := rcxTestLedger()
	ledger.NoteMarkerProbe("node", "env", rcxRoleOpen, "marker", rcxProbeOK, 40, now)
	ledger.SetFingerprints("changed", "legacy")
	ledger.RecomputeRole("node", "env", rcxRoleOpen, []string{"marker"}, now)
	if got := ledger.envState("env", "node").OpenWorld; got != rcxProofUnknown {
		t.Fatalf("old fingerprint proof = %v", got)
	}
	ledger.NoteMarkerProbe("forged", "env", rcxRoleOpen, "marker", rcxProbeOK, 1, now)
	ledger.RecomputeRole("forged", "env", rcxRoleOpen, []string{"marker"}, now)
	if got := ledger.envState("env", "forged").OpenWorld; got != rcxProofUnknown {
		t.Fatalf("forged marker revived through recompute: %v", got)
	}
}

func TestLedgerProofTransitAgesToUnknownNotFailure(t *testing.T) {
	ledger, now := rcxTestLedger()
	ledger.NoteTrafficProgress("node", "env", false, now)
	if got := ledger.Facts("node", "env", true, now.Add(rcxLedgerProofTTL+time.Second), rcxLedgerProofTTL).Transit; got != rcxProofUnknown {
		t.Fatalf("aged transit = %v", got)
	}
}

func TestLedgerRecurrenceSurvivesSuccessAndDecaysOncePerQuietHour(t *testing.T) {
	ledger, now := rcxTestLedger()
	for i := 0; i < 9; i++ {
		at := now.Add(time.Duration(i) * 10 * time.Second)
		ledger.NoteDialFailure("node", "env", rcxTerrainNormal, at)
		ledger.NoteProbe("node", "env", rcxRoleOpen, rcxProbeOK, 40, at.Add(time.Second))
	}
	last := now.Add(80 * time.Second)
	if got := ledger.Recurrence("node", "env", last.Add(time.Second)); got != 6 {
		t.Fatalf("recurrence = %d, want cap 6 despite intervening successes", got)
	}
	if ledger.FailStreak("node", "env") != 0 {
		t.Fatal("success failed to restore immediate availability")
	}
	for hour := 1; hour <= 7; hour++ {
		want := max(6-hour, 0)
		at := last.Add(time.Duration(hour) * time.Hour)
		for repeat := 0; repeat < 2; repeat++ {
			if got := ledger.Recurrence("node", "env", at); got != want {
				t.Fatalf("hour %d recurrence = %d, want %d", hour, got, want)
			}
		}
	}
}

func TestLedgerRecurrenceDeduplicatesMarkersButNotEnvironments(t *testing.T) {
	ledger, now := rcxTestLedger()
	if !ledger.NoteMarkerFailure("node", "env", "one", rcxTerrainNormal, now) {
		t.Fatal("first marker did not charge")
	}
	if ledger.NoteMarkerFailure("node", "env", "two", rcxTerrainNormal, now.Add(time.Second)) {
		t.Fatal("second marker charged the same episode")
	}
	if !ledger.NoteDialFailure("node", "other", rcxTerrainNormal, now) {
		t.Fatal("another environment shared the episode gate")
	}
	if got := ledger.Recurrence("node", "env", now.Add(time.Second)); got != 1 {
		t.Fatalf("recurrence = %d, want 1", got)
	}
	ledger.RollbackMarkerFailures("one", now.Add(2*time.Second))
	if got := ledger.Recurrence("node", "env", now.Add(2*time.Second)); got != 1 {
		t.Fatalf("another marker's failure was refunded: %d", got)
	}
	ledger.RollbackMarkerFailures("two", now.Add(3*time.Second))
	if got := ledger.Recurrence("node", "env", now.Add(3*time.Second)); got != 0 {
		t.Fatalf("quarantined markers left recurrence: %d", got)
	}
}

func TestLedgerRecurrenceRollbackSurvivesSuccessAndClearsMarkerPoison(t *testing.T) {
	ledger, now := rcxTestLedger()
	ledger.NoteDialFailure("node", "env", rcxTerrainNormal, now)
	ledger.NoteMarkerProbe("node", "env", rcxRoleOpen, "marker", rcxProbeFail, 0, now)
	ledger.NoteHarvestedProbe("node", "env", 40, now.Add(time.Second))
	ledger.RollbackFailures("env", map[string]int{"node": 1})
	ledger.RecomputeRole("node", "env", rcxRoleOpen, []string{"marker"}, now.Add(2*time.Second))
	if got := ledger.Recurrence("node", "env", now.Add(2*time.Second)); got != 0 {
		t.Fatalf("success erased the refund obligation: %d", got)
	}
	if got := ledger.envState("env", "node").OpenWorld; got != rcxProofUnknown {
		t.Fatalf("rolled-back failure resurrected: %v", got)
	}
}

func TestLedgerRecurrenceExcludesProvisionalFailuresAndKeepsConfirmedHistory(t *testing.T) {
	ledger, now := rcxTestLedger()
	ledger.NoteDialFailure("node", "env", rcxTerrainNormal, now)
	later := now.Add(20 * time.Second)
	ledger.NoteDialFailure("node", "env", rcxTerrainWhitelist, later)
	ledger.NoteTrafficProgress("node", "env", false, later.Add(time.Second))
	ledger.PromoteTerrainNormal("env")
	if got := ledger.Recurrence("node", "env", later.Add(time.Second)); got != 1 {
		t.Fatalf("provisional failure poisoned confirmed history: %d", got)
	}
}

func TestLedgerRecurrenceMarkerRollbackKeepsIndependentDialFailure(t *testing.T) {
	ledger, now := rcxTestLedger()
	ledger.NoteMarkerFailure("node", "env", "marker", rcxTerrainNormal, now)
	ledger.NoteDialFailure("node", "env", rcxTerrainNormal, now.Add(time.Second))
	ledger.RollbackMarkerFailures("marker", now.Add(2*time.Second))
	if got := ledger.Recurrence("node", "env", now.Add(2*time.Second)); got != 1 {
		t.Fatalf("independent dial accusation erased: %d", got)
	}
}

func TestLedgerRecurrenceImportRetainsEpisodeDeduplication(t *testing.T) {
	ledger, now := rcxTestLedger()
	ledger.NoteDialFailure("node", "env", rcxTerrainNormal, now)
	data, err := json.Marshal(ledger.envs)
	if err != nil {
		t.Fatal(err)
	}
	var restored map[string]map[string]*rcxNodeEnv
	if err := json.Unmarshal(data, &restored); err != nil {
		t.Fatal(err)
	}
	other, _ := rcxTestLedger()
	other.Import(nil, restored)
	if other.NoteDialFailure("node", "env", rcxTerrainNormal, now.Add(time.Second)) {
		t.Fatal("restart multiplied an existing episode")
	}
	if got := other.Recurrence("node", "env", now.Add(time.Second)); got != 1 {
		t.Fatalf("restored recurrence = %d", got)
	}
}

func TestLedgerQualityRejectsMixedRoleMarkerEpochAndOldSamples(t *testing.T) {
	ledger, now := rcxTestLedger()
	ledger.NoteProbe("node", "env", rcxRoleOpen, rcxProbeOK, 5, now)
	ledger.NoteHarvestedProbe("node", "env", 6, now)
	ledger.NoteQualitySample("node", "env", "marker", 7, 80, now.Add(-rcxRankingMedianTTL-time.Second))
	ledger.NoteQualitySample("node", "env", "other", 7, 8, now)
	ledger.NoteQualitySample("node", "env", "marker", 6, 9, now)
	ledger.NoteRoleQualitySample("node", "env", "marker", rcxRoleDomestic, 7, 10, now)
	ledger.NoteQualitySample("node", "env", "marker", 7, 90, now.Add(-rcxRankingMedianTTL+time.Minute))
	ledger.NoteQualitySample("node", "env", "marker", 7, 100, now)
	if ms, count := ledger.QualityMedian("node", "env", "marker", 7, now); ms != 100 || count != 2 {
		t.Fatalf("quality median/count = %d/%d, want 100/2", ms, count)
	}
	latest, ok := ledger.LatestQualitySample("node", "env", "marker", 7, now)
	if !ok || latest.DelayMs != 100 || latest.At != now {
		t.Fatalf("latest comparable sample = %+v, %v", latest, ok)
	}
	ledger.SetFingerprints("changed", "legacy")
	if ms, count := ledger.QualityMedian("node", "env", "marker", 7, now); ms != 0 || count != 0 {
		t.Fatalf("quality survived marker semantics change: %d/%d", ms, count)
	}
}

func TestLedgerQualityDeduplicatesBoundsAndRejectsFutureSamples(t *testing.T) {
	ledger, now := rcxTestLedger()
	for i := 0; i < rcxQualityDepth+4; i++ {
		at := now.Add(-time.Duration(i) * time.Second)
		ledger.NoteQualitySample("node", "env", "marker", 7, 100+i, at)
		ledger.NoteQualitySample("node", "env", "marker", 7, 100+i, at)
	}
	if got := len(ledger.envState("env", "node").QualitySamples); got != rcxQualityDepth {
		t.Fatalf("sample ring = %d, want %d", got, rcxQualityDepth)
	}
	ledger.NoteQualitySample("future", "env", "marker", 7, 100, now.Add(time.Second))
	if _, ok := ledger.LatestQualitySample("future", "env", "marker", 7, now); ok {
		t.Fatal("future sample entered current confirmation")
	}
}

func TestLedgerQualityQuarantineRemovesSamplesAndProofs(t *testing.T) {
	ledger, now := rcxTestLedger()
	ledger.NoteMarkerProbe("node", "env", rcxRoleOpen, "marker", rcxProbeFail, 0, now)
	ledger.NoteMarkerFailure("node", "env", "marker", rcxTerrainNormal, now)
	ledger.NoteQualitySample("node", "env", "marker", 7, 50, now)
	ledger.RollbackMarkerFailures("marker", now.Add(time.Second))
	ledger.RecomputeRole("node", "env", rcxRoleOpen, []string{"marker"}, now.Add(time.Second))
	if ledger.FailStreak("node", "env") != 0 || ledger.Recurrence("node", "env", now.Add(time.Second)) != 0 {
		t.Fatal("marker quarantine left negative reputation")
	}
	if _, ok := ledger.LatestQualitySample("node", "env", "marker", 7, now.Add(time.Second)); ok {
		t.Fatal("quarantined marker retained quality evidence")
	}
	if got := ledger.envState("env", "node").OpenWorld; got != rcxProofUnknown {
		t.Fatalf("quarantined marker retained proof: %v", got)
	}
}

func TestLedgerQualityMigrationMergesRecurrenceAndProvenance(t *testing.T) {
	ledger, now := rcxTestLedger()
	ledger.NoteTrafficProgress("node", "old", false, now)
	ledger.NoteHarvestedProbe("node", "new", 80, now.Add(time.Second))
	ledger.NoteQualitySample("node", "old", "marker", 7, 80, now)
	ledger.NoteQualitySample("node", "new", "marker", 7, 90, now.Add(10*time.Second))
	ledger.NoteDialFailure("node", "old", rcxTerrainNormal, now)
	ledger.NoteDialFailure("node", "new", rcxTerrainNormal, now.Add(10*time.Second))
	ledger.Migrate("old", "new")
	if ledger.TrafficAt("node", "new") != now || ledger.HarvestAt("node", "new") != now.Add(time.Second) {
		t.Fatal("migration lost timestamp provenance")
	}
	if got := ledger.Recurrence("node", "new", now.Add(10*time.Second)); got != 2 {
		t.Fatalf("migration lost recurrence: %d", got)
	}
	if _, count := ledger.QualityMedian("node", "new", "marker", 7, now.Add(10*time.Second)); count != 2 {
		t.Fatalf("migration quality count = %d", count)
	}
}

func TestLedgerRecurrenceProvisionalRefundCannotEraseConfirmedHistory(t *testing.T) {
	ledger, now := rcxTestLedger()
	ledger.NoteDialFailure("node", "env", rcxTerrainNormal, now)
	later := now.Add(20 * time.Second)
	ledger.NoteDialFailure("node", "env", rcxTerrainWhitelist, later)
	ledger.NoteTrafficProgress("node", "env", false, later.Add(time.Second))
	ledger.RollbackFailures("env", map[string]int{"node": 1})
	if got := ledger.Recurrence("node", "env", later.Add(time.Second)); got != 1 {
		t.Fatalf("provisional refund erased confirmed history: %d", got)
	}
}

func TestLedgerRecurrenceRollbackDoesNotApplyDecayTwice(t *testing.T) {
	ledger, now := rcxTestLedger()
	for i := 0; i < 4; i++ {
		ledger.NoteMarkerFailure("node", "env", "marker", rcxTerrainNormal, now.Add(time.Duration(i)*10*time.Second))
	}
	later := now.Add(time.Hour + 30*time.Second)
	if got := ledger.Recurrence("node", "env", later); got != 3 {
		t.Fatalf("initial decay = %d", got)
	}
	ledger.RollbackFailures("env", map[string]int{"node": 1})
	if got := ledger.Recurrence("node", "env", later); got != 2 {
		t.Fatalf("rollback double-counted a quiet hour: %d", got)
	}
}

func TestLedgerQualityInvalidatesOnlyTheEditedDomain(t *testing.T) {
	ledger, now := rcxTestLedger()
	ledger.NoteQualitySample("node", "env", "open", 7, 80, now)
	ledger.NoteRoleQualitySample("node", "env", "home", rcxRoleDomestic, 7, 90, now)
	ledger.Invalidate(true, false, false, false)
	if _, ok := ledger.LatestQualitySample("node", "env", "open", 7, now); ok {
		t.Fatal("invalidated quality sample survived")
	}
	if got := ledger.envState("env", "node").QualitySamples; len(got) != 1 || got[0].Role != rcxRoleDomestic {
		t.Fatalf("invalidation lost the unedited domain: %+v", got)
	}
}
