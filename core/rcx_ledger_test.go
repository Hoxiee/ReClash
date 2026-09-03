package main

import (
	"strconv"
	"testing"
	"time"
)

func rcxTestLedger() (*rcxLedger, time.Time) {
	return newRcxLedger(rcxDefaultLedgerPolicy()), time.Unix(1_700_000_000, 0)
}

func TestLedgerFoldsRetryAttemptsIntoOneEpisode(t *testing.T) {
	ledger, now := rcxTestLedger()

	opened := 0
	// retry() hands the same connection to the node up to ten times.
	for i := 0; i < 10; i++ {
		if ledger.NoteDialFailure("nl-1", "10.0.0.1:44100", "wifi:home", rcxTerrainNormal, now.Add(time.Duration(i)*50*time.Millisecond)) {
			opened++
		}
	}

	if opened != 1 {
		t.Fatalf("opened %d episodes, want 1: ten attempts are one user connection", opened)
	}
	if got := ledger.envState("wifi:home", "nl-1").FailStreak; got != 1 {
		t.Errorf("failStreak = %d, want 1", got)
	}
}

func TestLedgerCountsDistinctConnectionsSeparately(t *testing.T) {
	ledger, now := rcxTestLedger()

	ledger.NoteDialFailure("nl-1", "10.0.0.1:44100", "wifi:home", rcxTerrainNormal, now)
	ledger.NoteDialFailure("nl-1", "10.0.0.1:44101", "wifi:home", rcxTerrainNormal, now)
	ledger.NoteDialFailure("nl-1", "10.0.0.1:44102", "wifi:home", rcxTerrainNormal, now)

	state := ledger.envState("wifi:home", "nl-1")
	if state.FailStreak != 3 {
		t.Fatalf("failStreak = %d, want 3: distinct source ports are distinct connections", state.FailStreak)
	}
	if state.CoolUntil.IsZero() {
		t.Error("want a cooling window once the streak reaches the threshold")
	}
}

func TestLedgerReopensAnEpisodeAfterTheTTL(t *testing.T) {
	ledger, now := rcxTestLedger()
	policy := rcxDefaultLedgerPolicy()

	ledger.NoteDialFailure("nl-1", "10.0.0.1:44100", "wifi:home", rcxTerrainNormal, now)
	reopened := ledger.NoteDialFailure("nl-1", "10.0.0.1:44100", "wifi:home", rcxTerrainNormal, now.Add(policy.EpisodeTTL+time.Second))

	if !reopened {
		t.Error("a reused source port past the TTL is a new connection and must open a new episode")
	}
}

func TestLedgerRollsBackFailuresRecordedOffNormalTerrain(t *testing.T) {
	ledger, now := rcxTestLedger()

	for i := 0; i < 4; i++ {
		ledger.NoteDialFailure("nl-1", "10.0.0.1:"+strconv.Itoa(44100+i), "lte:mts", rcxTerrainWhitelist, now)
	}
	before := ledger.envState("lte:mts", "nl-1")
	if before.CoolUntil.IsZero() {
		t.Fatal("want the node cooling during the shutdown")
	}

	ledger.PromoteTerrainNormal("lte:mts")

	after := ledger.envState("lte:mts", "nl-1")
	if after.FailStreak != 0 {
		t.Errorf("failStreak = %d, want 0: those failures were the shutdown, not the node", after.FailStreak)
	}
	if !after.CoolUntil.IsZero() {
		t.Error("want cooling lifted so the park is usable the moment the network recovers")
	}
}

func TestLedgerKeepsFailuresRecordedOnNormalTerrain(t *testing.T) {
	ledger, now := rcxTestLedger()

	for i := 0; i < 4; i++ {
		ledger.NoteDialFailure("nl-1", "10.0.0.1:"+strconv.Itoa(44100+i), "wifi:home", rcxTerrainNormal, now)
	}
	ledger.PromoteTerrainNormal("wifi:home")

	if got := ledger.envState("wifi:home", "nl-1").FailStreak; got != 4 {
		t.Errorf("failStreak = %d, want 4 kept: a healthy network blames the node", got)
	}
}

func TestLedgerKeepsStatePerEnvironment(t *testing.T) {
	ledger, now := rcxTestLedger()

	for i := 0; i < 4; i++ {
		ledger.NoteDialFailure("nl-1", "10.0.0.1:"+strconv.Itoa(44100+i), "lte:mts", rcxTerrainWhitelist, now)
	}

	home := ledger.Facts("nl-1", "wifi:home", true, now)
	if home.Transit == rcxProofDisproven {
		t.Error("a shutdown on mobile must not mark the node dead on home wifi")
	}
}

func TestLedgerSuccessClearsCooling(t *testing.T) {
	ledger, now := rcxTestLedger()

	for i := 0; i < 4; i++ {
		ledger.NoteDialFailure("nl-1", "10.0.0.1:"+strconv.Itoa(44100+i), "wifi:home", rcxTerrainNormal, now)
	}
	ledger.NoteDialSuccess("nl-1", "10.0.0.1:44200", "wifi:home", 120*time.Millisecond, now.Add(time.Minute))

	facts := ledger.Facts("nl-1", "wifi:home", true, now.Add(time.Minute))
	if facts.Transit != rcxProofProven {
		t.Errorf("transit = %v, want proven after a real connection succeeded", facts.Transit)
	}
}

func TestLedgerBackoffGrowsAndIsCapped(t *testing.T) {
	ledger, _ := rcxTestLedger()
	policy := rcxDefaultLedgerPolicy()

	first := ledger.backoffLocked(policy.CoolAfterFails)
	second := ledger.backoffLocked(policy.CoolAfterFails + 1)
	huge := ledger.backoffLocked(policy.CoolAfterFails + 40)

	if second != 2*first {
		t.Errorf("backoff went %v then %v, want doubling", first, second)
	}
	if huge != policy.MaxDeadRetry {
		t.Errorf("backoff = %v, want the cap %v", huge, policy.MaxDeadRetry)
	}
}

func TestLedgerHarvestedProbeCannotRaiseAClass(t *testing.T) {
	ledger, now := rcxTestLedger()

	ledger.NoteHarvestedProbe("nl-1", "wifi:home", 80, now)

	if got := ledger.envState("wifi:home", "nl-1").OpenWorld; got != rcxProofUnknown {
		t.Errorf("openWorld = %v, want unknown: a harvested probe carries no verified status", got)
	}
}

func TestLedgerHarvestedFailureLowersAProvenClass(t *testing.T) {
	ledger, now := rcxTestLedger()
	ledger.NoteProbe("nl-1", "wifi:home", rcxRoleOpen, rcxProbeOK, 90, now)

	ledger.NoteHarvestedProbe("nl-1", "wifi:home", 0, now.Add(time.Minute))

	if got := ledger.envState("wifi:home", "nl-1").OpenWorld; got == rcxProofProven {
		t.Error("a zero delay is unambiguous and must drop the proven class")
	}
}

func TestLedgerStatusMismatchDisprovesTheRole(t *testing.T) {
	ledger, now := rcxTestLedger()

	ledger.NoteProbe("nl-1", "wifi:home", rcxRoleOpen, rcxProbeStatusMismatch, 40, now)

	if got := ledger.envState("wifi:home", "nl-1").OpenWorld; got != rcxProofDisproven {
		t.Errorf("openWorld = %v, want disproven: a portal answers 200 to everything", got)
	}
}

func TestLedgerOverloadedProbeIsNoInformation(t *testing.T) {
	ledger, now := rcxTestLedger()
	ledger.NoteProbe("nl-1", "wifi:home", rcxRoleOpen, rcxProbeOK, 90, now)

	ledger.NoteProbe("nl-1", "wifi:home", rcxRoleOpen, rcxProbeOverloaded, 0, now.Add(time.Minute))

	if got := ledger.envState("wifi:home", "nl-1").OpenWorld; got != rcxProofProven {
		t.Errorf("openWorld = %v, want the earlier proof kept: a starved slot is not a failure", got)
	}
}

func TestLedgerMedianIgnoresSamplesFromTheSuspendWindow(t *testing.T) {
	ledger, now := rcxTestLedger()
	asleep := now.Add(time.Minute)

	ledger.NoteProbe("nl-1", "wifi:home", rcxRoleOpen, rcxProbeOK, 100, now)
	ledger.NoteProbe("nl-1", "wifi:home", rcxRoleOpen, rcxProbeOK, 5000, asleep)
	ledger.NoteProbe("nl-1", "wifi:home", rcxRoleOpen, rcxProbeOK, 110, asleep.Add(time.Hour))

	got := ledger.MedianMs("nl-1", "wifi:home", asleep.Add(2*time.Hour), asleep.Add(-time.Second), asleep.Add(time.Second))

	if got != 110 {
		t.Errorf("median = %d, want 110: the 5000ms sample was stamped while the device was parked", got)
	}
}

func TestLedgerMedianIgnoresStaleSamples(t *testing.T) {
	ledger, now := rcxTestLedger()
	policy := rcxDefaultLedgerPolicy()

	ledger.NoteProbe("nl-1", "wifi:home", rcxRoleOpen, rcxProbeOK, 100, now)

	if got := ledger.MedianMs("nl-1", "wifi:home", now.Add(policy.StaleAfter+time.Hour), time.Time{}, time.Time{}); got != 0 {
		t.Errorf("median = %d, want 0 so the node reads as unknown rather than fast", got)
	}
}

func TestLedgerEvidenceDegradesWithAge(t *testing.T) {
	ledger, now := rcxTestLedger()
	live := time.Minute
	fresh := 30 * time.Minute
	ledger.NoteDialSuccess("nl-1", "10.0.0.1:1", "wifi:home", 90*time.Millisecond, now)

	tests := []struct {
		at   time.Time
		want rcxEvidence
	}{
		{at: now.Add(10 * time.Second), want: rcxEvidenceLiveTraffic},
		{at: now.Add(10 * time.Minute), want: rcxEvidenceFreshProbe},
		{at: now.Add(2 * time.Hour), want: rcxEvidenceStaleProbe},
	}
	for _, tc := range tests {
		if got := ledger.Evidence("nl-1", "wifi:home", tc.at, live, fresh); got != tc.want {
			t.Errorf("evidence at %v = %v, want %v", tc.at.Sub(now), got, tc.want)
		}
	}
}

func TestLedgerEvidenceIsNoneForAnUntouchedNode(t *testing.T) {
	ledger, now := rcxTestLedger()

	if got := ledger.Evidence("nl-1", "wifi:home", now, time.Minute, time.Hour); got != rcxEvidenceNone {
		t.Errorf("evidence = %v, want none", got)
	}
}

func TestLedgerPruneKeepsTheMostRecentlyGoodNodes(t *testing.T) {
	ledger, now := rcxTestLedger()
	for i := 0; i < 5; i++ {
		node := "n" + strconv.Itoa(i)
		ledger.NoteDialSuccess(node, "10.0.0.1:1", "wifi:home", 100*time.Millisecond, now.Add(time.Duration(i)*time.Minute))
	}

	ledger.Prune(2, now.Add(time.Hour))

	nodes := ledger.envs["wifi:home"]
	if len(nodes) != 2 {
		t.Fatalf("kept %d nodes, want 2", len(nodes))
	}
	if _, ok := nodes["n4"]; !ok {
		t.Error("want the most recently good node kept")
	}
}
