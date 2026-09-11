package main

import (
	"strconv"
	"testing"
	"time"
)

func rcxTestLedger() (*rcxLedger, time.Time) {
	return newRcxLedger(rcxDefaultLedgerPolicy()), time.Unix(1_700_000_000, 0)
}

// Failures land one per episode window, the way an outage that outlasts a minute
// does, and returns the last charge so the caller can reason from it.
func rcxChargeFailures(
	ledger *rcxLedger,
	node, env string,
	terrain rcxTerrain,
	first time.Time,
	count int,
) time.Time {
	step := rcxDefaultLedgerPolicy().EpisodeTTL + time.Second
	last := first
	for i := 0; i < count; i++ {
		last = first.Add(time.Duration(i) * step)
		ledger.NoteDialFailure(node, env, terrain, last)
	}
	return last
}

func TestLedgerFoldsRetryAttemptsIntoOneEpisode(t *testing.T) {
	ledger, now := rcxTestLedger()

	opened := 0
	// retry() hands the same connection to the node up to ten times.
	for i := 0; i < 10; i++ {
		if ledger.NoteDialFailure("nl-1", "wifi:home", rcxTerrainNormal, now.Add(time.Duration(i)*50*time.Millisecond)) {
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

func TestLedgerFoldsAnOutageBurstIntoOneEpisode(t *testing.T) {
	ledger, now := rcxTestLedger()

	// A dark uplink fails every socket the app opens, each from a fresh port.
	for i := 0; i < 3; i++ {
		ledger.NoteDialFailure("nl-1", "wifi:home", rcxTerrainNormal, now.Add(time.Duration(i)*time.Second))
	}

	state := ledger.envState("wifi:home", "nl-1")
	if state.FailStreak != 1 {
		t.Fatalf("failStreak = %d, want 1: three sockets in three seconds are one outage", state.FailStreak)
	}
	if !state.CoolUntil.IsZero() {
		t.Error("want no cooling window: a single dark second must not ban a node")
	}
}

func TestLedgerCapsAFailStreak(t *testing.T) {
	ledger, now := rcxTestLedger()
	policy := rcxDefaultLedgerPolicy()

	last := rcxChargeFailures(ledger, "nl-1", "wifi:home", rcxTerrainNormal, now, 20)

	state := ledger.envState("wifi:home", "nl-1")
	if state.FailStreak != policy.MaxFailStreak {
		t.Fatalf("failStreak = %d, want the cap %d", state.FailStreak, policy.MaxFailStreak)
	}
	quiet := last.Add(time.Duration(policy.MaxFailStreak) * policy.FailDecay)
	if got := ledger.CoolUntil("nl-1", "wifi:home", quiet); !got.IsZero() {
		t.Errorf("cooling = %v, want a bad minute paid off within the streak cap", got)
	}
}

func TestLedgerIgnoresADialTooFastToBeRemote(t *testing.T) {
	ledger, now := rcxTestLedger()

	if ledger.NoteDialSuccess("nl-1", "wifi:home", time.Millisecond, now) {
		t.Fatal("a dial answered inside a millisecond opened a local socket, not a tunnel")
	}
	if got := ledger.Facts("nl-1", "wifi:home", true, now, rcxLedgerProofTTL).Transit; got == rcxProofProven {
		t.Errorf("transit = %v, want it unproven: a mux stream opens against a dead node too", got)
	}
}

func TestLedgerDropsAHarvestFasterThanAnyRemoteExchange(t *testing.T) {
	ledger, now := rcxTestLedger()

	ledger.NoteHarvestedProbe("nl-1", "wifi:home", 1, now)

	if got := ledger.MedianMs("nl-1", "wifi:home", now, time.Time{}, time.Time{}); got != 0 {
		t.Errorf("median = %d, want 0: a middlebox answering for the node is not the node's latency", got)
	}
}

func TestLedgerSamplesAHarvestTheAppYardstickMeasured(t *testing.T) {
	ledger, now := rcxTestLedger()

	ledger.NoteHarvestedProbe("nl-1", "wifi:home", 120, now)

	if got := ledger.MedianMs("nl-1", "wifi:home", now, time.Time{}, time.Time{}); got != 120 {
		t.Errorf("median = %d, want 120: a plausible hand test is the only park-wide measurement there is", got)
	}
}

func TestLedgerHarvestProvesTransportWithoutOpenWorld(t *testing.T) {
	ledger, now := rcxTestLedger()
	last := rcxChargeFailures(ledger, "nl-1", "wifi:home", rcxTerrainNormal, now, 4)
	at := last.Add(time.Minute)
	ledger.NoteHarvestedProbe("nl-1", "wifi:home", 120, at)

	state := ledger.envState("wifi:home", "nl-1")
	if state.FailStreak != 0 || !state.CoolUntil.IsZero() || state.ProofStall {
		t.Fatalf("harvest left failure state: %+v", state)
	}
	facts := ledger.Facts("nl-1", "wifi:home", true, at, rcxLedgerProofTTL)
	if facts.Transit != rcxProofProven {
		t.Errorf("transit = %v, want proven by returned payload", facts.Transit)
	}
	if facts.OpenWorld == rcxProofProven {
		t.Error("an arbitrary HTTP status must not prove the open-world marker")
	}
}

func TestLedgerRefusesAProbeFasterThanAnyRemoteExchange(t *testing.T) {
	ledger, now := rcxTestLedger()

	ledger.NoteProbe("nl-1", "wifi:home", rcxRoleOpen, rcxProbeOK, 1, now)

	facts := ledger.Facts("nl-1", "wifi:home", true, now, rcxLedgerProofTTL)
	if facts.OpenWorld == rcxProofProven {
		t.Error("an exchange faster than any remote RTT never left the local path: it proves no open world")
	}
	if got := ledger.MedianMs("nl-1", "wifi:home", now, time.Time{}, time.Time{}); got != 0 {
		t.Errorf("median = %d, want 0: the forged answer must not become the fastest node in the park", got)
	}
	if ledger.ProbeAt("nl-1", "wifi:home").IsZero() {
		t.Error("the rotation must still advance, or the node is probed forever")
	}
}

func TestLedgerDialSuccessNeverFeedsTheMedian(t *testing.T) {
	ledger, now := rcxTestLedger()

	ledger.NoteDialSuccess("nl-1", "wifi:home", 120*time.Millisecond, now)

	if got := ledger.MedianMs("nl-1", "wifi:home", now, time.Time{}, time.Time{}); got != 0 {
		t.Errorf("median = %d, want 0: the hook times a local handshake for anything multiplexed", got)
	}
}

func TestLedgerReopensAnEpisodeAfterTheTTL(t *testing.T) {
	ledger, now := rcxTestLedger()
	policy := rcxDefaultLedgerPolicy()

	ledger.NoteDialFailure("nl-1", "wifi:home", rcxTerrainNormal, now)
	reopened := ledger.NoteDialFailure("nl-1", "wifi:home", rcxTerrainNormal, now.Add(policy.EpisodeTTL+time.Second))

	if !reopened {
		t.Error("a failure past the TTL is a new outage and must open a new episode")
	}
}

func TestLedgerRollsBackFailuresRecordedOffNormalTerrain(t *testing.T) {
	ledger, now := rcxTestLedger()

	rcxChargeFailures(ledger, "nl-1", "lte:mts", rcxTerrainWhitelist, now, 4)
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

	rcxChargeFailures(ledger, "nl-1", "wifi:home", rcxTerrainNormal, now, 4)
	ledger.PromoteTerrainNormal("wifi:home")

	if got := ledger.envState("wifi:home", "nl-1").FailStreak; got != 4 {
		t.Errorf("failStreak = %d, want 4 kept: a healthy network blames the node", got)
	}
}

func TestLedgerKeepsStatePerEnvironment(t *testing.T) {
	ledger, now := rcxTestLedger()

	rcxChargeFailures(ledger, "nl-1", "lte:mts", rcxTerrainWhitelist, now, 4)

	home := ledger.Facts("nl-1", "wifi:home", true, now, rcxLedgerProofTTL)
	if home.Transit == rcxProofDisproven {
		t.Error("a shutdown on mobile must not mark the node dead on home wifi")
	}
}

func TestLedgerDialSuccessPaysBackOneCharge(t *testing.T) {
	ledger, now := rcxTestLedger()

	last := rcxChargeFailures(ledger, "nl-1", "wifi:home", rcxTerrainNormal, now, 4)
	at := last.Add(time.Minute)
	ledger.NoteDialSuccess("nl-1", "wifi:home", 120*time.Millisecond, at)

	state := ledger.envState("wifi:home", "nl-1")
	if state.FailStreak != 3 {
		t.Errorf("fail streak = %d, want 3: a handshake refutes exactly one charge", state.FailStreak)
	}
	if state.CoolUntil.IsZero() || !at.Before(state.CoolUntil) {
		t.Error("a dial must shorten the backoff, not erase the cooling it cannot re-earn")
	}
	if got := ledger.Facts("nl-1", "wifi:home", true, at, rcxLedgerProofTTL).Transit; got != rcxProofDisproven {
		t.Errorf("transit = %v, want disproven: the dial proved the session, not the delivery", got)
	}
}

func TestLedgerDialSuccessDecaysQuietTimeFirst(t *testing.T) {
	ledger, now := rcxTestLedger()
	policy := rcxDefaultLedgerPolicy()

	last := rcxChargeFailures(ledger, "nl-1", "wifi:home", rcxTerrainNormal, now, 6)
	quiet := time.Duration(policy.MaxFailStreak-1) * policy.FailDecay
	ledger.NoteDialSuccess("nl-1", "wifi:home", 120*time.Millisecond, last.Add(quiet))

	if got := ledger.envState("wifi:home", "nl-1").FailStreak; got != 0 {
		t.Errorf("fail streak = %d, want 0: quiet time pays its credits before the handshake's one", got)
	}
}

func TestLedgerDialSuccessIsNotBeingGood(t *testing.T) {
	ledger, now := rcxTestLedger()

	ledger.NoteTrafficProgress("payload", "wifi:home", false, now)
	ledger.NoteDialSuccess("handshake", "wifi:home", 120*time.Millisecond, now.Add(time.Minute))

	ledger.Prune(map[string]struct{}{"payload": {}}, nil, now.Add(time.Hour))

	if _, ok := ledger.envs["wifi:home"]["payload"]; !ok {
		t.Error("want the node that carried payload kept: a handshake is never more recently good")
	}
}

func TestLedgerDialSuccessDoesNotProveTransit(t *testing.T) {
	ledger, now := rcxTestLedger()

	ledger.NoteDialSuccess("nl-1", "wifi:home", 120*time.Millisecond, now)
	if got := ledger.Facts("nl-1", "wifi:home", true, now, rcxLedgerProofTTL).Transit; got != rcxProofUnknown {
		t.Errorf("transit = %v, want unknown: a handshake is a session, not a delivery", got)
	}

	ledger.NoteTrafficProgress("nl-1", "wifi:home", false, now)
	if got := ledger.Facts("nl-1", "wifi:home", true, now, rcxLedgerProofTTL).Transit; got != rcxProofProven {
		t.Errorf("transit = %v, want proven once payload answered", got)
	}
}

func TestLedgerDowngradesTransitAfterTheBanExpires(t *testing.T) {
	ledger, now := rcxTestLedger()
	policy := rcxDefaultLedgerPolicy()

	ledger.NoteTrafficProgress("nl-1", "wifi:home", false, now)
	last := rcxChargeFailures(ledger, "nl-1", "wifi:home", rcxTerrainNormal, now.Add(time.Minute), 4)
	if got := ledger.Facts("nl-1", "wifi:home", true, last, rcxLedgerProofTTL).Transit; got != rcxProofDisproven {
		t.Fatalf("transit = %v, want disproven while the ban stands", got)
	}

	expired := last.Add(2*policy.DeadRetry + time.Minute)
	if got := ledger.Facts("nl-1", "wifi:home", true, expired, rcxLedgerProofTTL).Transit; got != rcxProofUnknown {
		t.Errorf("transit = %v, want unknown after the ban: worth a retry, not a proven rank", got)
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

func TestLedgerDecaysAFailStreakWithTime(t *testing.T) {
	ledger, now := rcxTestLedger()
	policy := rcxDefaultLedgerPolicy()

	last := rcxChargeFailures(ledger, "nl-1", "wifi:home", rcxTerrainNormal, now, 4)
	if ledger.CoolUntil("nl-1", "wifi:home", last).IsZero() {
		t.Fatal("want a cooling window before the decay has anything to give back")
	}

	quiet := last.Add(2 * policy.FailDecay)
	if got := ledger.CoolUntil("nl-1", "wifi:home", quiet); !got.IsZero() {
		t.Errorf("cooling = %v, want it lifted: a cooling node is never dialled and so can never earn the success that clears it", got)
	}
	if got := ledger.envState("wifi:home", "nl-1").FailStreak; got != 2 {
		t.Errorf("failStreak = %d, want 2 after two quiet hours", got)
	}
}

func TestLedgerDecayNeverExtendsACoolingWindow(t *testing.T) {
	ledger, now := rcxTestLedger()
	policy := rcxDefaultLedgerPolicy()

	last := rcxChargeFailures(ledger, "nl-1", "wifi:home", rcxTerrainNormal, now, 10)
	banned := ledger.CoolUntil("nl-1", "wifi:home", last)
	if banned.Sub(last) != policy.MaxDeadRetry {
		t.Fatalf("cooling = %v, want the capped ban %v", banned.Sub(last), policy.MaxDeadRetry)
	}

	got := ledger.CoolUntil("nl-1", "wifi:home", last.Add(policy.FailDecay))
	if got.After(banned) {
		t.Errorf("cooling = %v, want a paid-off credit never to push the release past %v", got, banned)
	}
}

func TestLedgerRefundsWhatALinkEventCharged(t *testing.T) {
	ledger, now := rcxTestLedger()

	last := rcxChargeFailures(ledger, "nl-1", "wifi:home", rcxTerrainNormal, now, 3)
	ledger.NoteProbe("nl-1", "wifi:home", rcxRoleOpen, rcxProbeFail, 0, last)

	ledger.RollbackFailures("wifi:home", map[string]int{"nl-1": 3})

	state := ledger.envState("wifi:home", "nl-1")
	if state.FailStreak != 0 || !state.CoolUntil.IsZero() {
		t.Errorf("streak %d cooling %v, want both given back", state.FailStreak, state.CoolUntil)
	}
	if state.OpenWorld != rcxProofUnknown {
		t.Errorf("openWorld = %v, want unknown: a marker unreachable through a dead link disproves nothing", state.OpenWorld)
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
	ledger.NoteDialSuccess("nl-1", "wifi:home", 90*time.Millisecond, now)
	ledger.NoteTrafficProgress("nl-1", "wifi:home", false, now)

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

func TestLedgerPruneKeepsEveryActiveMemberInALargePark(t *testing.T) {
	ledger, now := rcxTestLedger()
	active := make(map[string]struct{}, 300)
	for i := 0; i < 300; i++ {
		node := "n" + strconv.Itoa(i)
		active[node] = struct{}{}
		ledger.NoteTrafficProgress(node, "wifi:home", false, now.Add(time.Duration(i)*time.Second))
	}

	ledger.Prune(active, nil, now.Add(time.Hour))

	if got := len(ledger.envs["wifi:home"]); got != len(active) {
		t.Fatalf("kept %d nodes, want all %d active members", got, len(active))
	}
}

func TestLedgerPruneBoundsRemovedHistoryWithoutDroppingProtectedNodes(t *testing.T) {
	ledger, now := rcxTestLedger()
	for i := 0; i < 80; i++ {
		node := "gone-" + strconv.Itoa(i)
		ledger.NoteTrafficProgress(node, "wifi:home", false, now.Add(time.Duration(i)*time.Minute))
	}
	protected := map[string]struct{}{"gone-0": {}}

	ledger.Prune(nil, protected, now.Add(2*time.Hour))

	nodes := ledger.envs["wifi:home"]
	if _, ok := nodes["gone-0"]; !ok {
		t.Fatal("protected node was removed")
	}
	if got := len(nodes); got != rcxRemovedKeepPerEnv+1 {
		t.Fatalf("kept %d nodes, want %d removed plus one protected", got, rcxRemovedKeepPerEnv+1)
	}
}

func TestLedgerKeepsTheOpenWorldFalsificationAfterTheProofAges(t *testing.T) {
	ledger, now := rcxTestLedger()
	ledger.SetOrigin("nl-1", "RU", rcxOriginDomestic)
	ledger.NoteTrafficProgress("nl-1", "wifi:home", true, now)

	if got := ledger.Facts("nl-1", "wifi:home", true, now, rcxLedgerProofTTL); got.OpenWorld != rcxProofProven {
		t.Fatalf("proof = %v, want proven: the payload reached a host no domestic egress can", got.OpenWorld)
	}
	aged := ledger.Facts("nl-1", "wifi:home", true, now.Add(rcxLedgerProofTTL+time.Minute), rcxLedgerProofTTL)

	if aged.OpenWorld != rcxProofUnknown {
		t.Errorf("aged proof = %v, want unknown: one lucky pass must not rank it for life", aged.OpenWorld)
	}
	if !aged.OpenedOnce {
		t.Error("the measurement that falsified mmdb expired with the proof: geography decides again")
	}
}

func TestLedgerRejectsProofFromAnotherMarkerEpoch(t *testing.T) {
	ledger, now := rcxTestLedger()
	ledger.SetFingerprints("open-v1", "home-v1")
	ledger.NoteProbe("nl-1", "wifi:home", rcxRoleOpen, rcxProbeOK, 90, now)
	if got := ledger.Facts("nl-1", "wifi:home", true, now, rcxLedgerProofTTL).OpenWorld; got != rcxProofProven {
		t.Fatalf("proof = %v, want proven in its own epoch", got)
	}

	ledger.SetFingerprints("open-v2", "home-v1")
	if got := ledger.Facts("nl-1", "wifi:home", true, now, rcxLedgerProofTTL); got.OpenWorld != rcxProofUnknown || got.OpenedOnce {
		t.Fatalf("stale marker proof survived: %+v", got)
	}
}

func TestLedgerDisprovesARoleOnlyAfterEveryMarkerFails(t *testing.T) {
	ledger, now := rcxTestLedger()
	first, second := "open:first", "open:second"
	ledger.NoteMarkerProbe("node", "wifi:home", rcxRoleOpen, first, rcxProbeFail, 0, now)
	ledger.RecomputeRole("node", "wifi:home", rcxRoleOpen, []string{first, second}, now)

	if got := ledger.Facts("node", "wifi:home", true, now, rcxLedgerProofTTL).OpenWorld; got != rcxProofUnknown {
		t.Fatalf("proof = %v, want unknown while a fallback marker is unmeasured", got)
	}

	ledger.NoteMarkerProbe("node", "wifi:home", rcxRoleOpen, second, rcxProbeStatusMismatch, 40, now)
	ledger.RecomputeRole("node", "wifi:home", rcxRoleOpen, []string{first, second}, now)
	if got := ledger.Facts("node", "wifi:home", true, now, rcxLedgerProofTTL).OpenWorld; got != rcxProofDisproven {
		t.Fatalf("proof = %v, want disproven after the whole chain failed", got)
	}
}

func TestLedgerLetsOneMarkerProveTheRole(t *testing.T) {
	ledger, now := rcxTestLedger()
	first, second := "open:first", "open:second"
	ledger.NoteMarkerProbe("node", "wifi:home", rcxRoleOpen, first, rcxProbeFail, 0, now)
	ledger.NoteMarkerProbe("node", "wifi:home", rcxRoleOpen, second, rcxProbeOK, 50, now)
	ledger.RecomputeRole("node", "wifi:home", rcxRoleOpen, []string{first, second}, now)

	if got := ledger.Facts("node", "wifi:home", true, now, rcxLedgerProofTTL).OpenWorld; got != rcxProofProven {
		t.Fatalf("proof = %v, want the successful fallback to win", got)
	}
}

func TestLedgerMigrationMergesFreshFieldsAndKeepsPolicyDepth(t *testing.T) {
	policy := rcxDefaultLedgerPolicy()
	policy.SampleDepth = 2
	ledger := newRcxLedger(policy)
	now := time.Unix(1_700_000_000, 0)
	current := ledger.envState("new", "node")
	current.OpenWorld = rcxProofProven
	current.OpenAt = now.Add(time.Minute)
	current.LastFailAt = now
	current.Samples = []rcxSample{{DelayMs: 90, At: now.Add(time.Minute)}}
	incoming := ledger.envState("old", "node")
	incoming.OpenWorld = rcxProofDisproven
	incoming.OpenAt = now
	incoming.LastGoodAt = now.Add(2 * time.Minute)
	incoming.Samples = []rcxSample{
		{DelayMs: 80, At: now},
		{DelayMs: 70, At: now.Add(2 * time.Minute)},
	}

	ledger.Migrate("old", "new")

	merged := ledger.envState("new", "node")
	if merged.OpenWorld != rcxProofProven || merged.LastGoodAt != incoming.LastGoodAt {
		t.Fatalf("merged = %+v, want fresh values from each evidence domain", merged)
	}
	if len(merged.Samples) != 2 || merged.Samples[0].DelayMs != 90 || merged.Samples[1].DelayMs != 70 {
		t.Fatalf("samples = %v, want the newest two under the active policy", merged.Samples)
	}
	if _, exists := ledger.envs["old"]; exists {
		t.Error("the migrated alias was retained")
	}
}

func TestLedgerInvalidatesOnlyTheEditedProofDomain(t *testing.T) {
	ledger, now := rcxTestLedger()
	ledger.SetFingerprints("open-v1", "home-v1")
	ledger.NoteProbe("nl-1", "wifi:home", rcxRoleOpen, rcxProbeOK, 90, now)
	ledger.NoteProbe("nl-1", "wifi:home", rcxRoleDomestic, rcxProbeOK, 90, now)

	ledger.Invalidate(true, false, false, false)
	ledger.SetFingerprints("open-v2", "home-v1")
	facts := ledger.Facts("nl-1", "wifi:home", true, now, rcxLedgerProofTTL)
	if facts.OpenWorld != rcxProofUnknown || facts.Domestic != rcxProofProven || facts.Transit != rcxProofProven {
		t.Fatalf("selective invalidation crossed domains: %+v", facts)
	}
}

func TestLedgerKeepsAnEgressTheMarkerProofCannotSee(t *testing.T) {
	ledger, now := rcxTestLedger()
	ledger.SetOrigin("spb", "US", rcxOriginForeign)
	ledger.SetExit("spb", "RU", rcxOriginDomestic, now)
	ledger.NoteProbe("spb", "wifi:home", rcxRoleOpen, rcxProbeOK, 59, now)

	facts := ledger.Facts("spb", "wifi:home", true, now, rcxLedgerProofTTL)
	if facts.OpenWorld != rcxProofProven {
		t.Fatalf("open proof = %v, want proven: the marker did answer", facts.OpenWorld)
	}
	if facts.Exit != rcxOriginDomestic {
		t.Errorf("exit = %v, want domestic: the probe it fooled must not clear it", facts.Exit)
	}

	aged := ledger.Facts("spb", "wifi:home", true, now.Add(rcxExitTTL+time.Minute), rcxLedgerProofTTL)
	if aged.Exit != rcxOriginUnknown {
		t.Errorf("aged exit = %v, want unknown: an endpoint can be re-homed", aged.Exit)
	}
}

func TestLedgerDropsMeasuredEgressWhenTheEchoSetChanges(t *testing.T) {
	ledger, now := rcxTestLedger()
	ledger.SetExit("spb", "RU", rcxOriginDomestic, now)

	ledger.Invalidate(true, true, false, false)
	if got := ledger.Facts("spb", "wifi:home", true, now, rcxLedgerProofTTL).Exit; got != rcxOriginDomestic {
		t.Fatalf("exit = %v, want domestic: a marker edit says nothing about the egress", got)
	}

	ledger.Invalidate(false, false, false, true)
	if got := ledger.Facts("spb", "wifi:home", true, now, rcxLedgerProofTTL).Exit; got != rcxOriginUnknown {
		t.Errorf("exit = %v, want unknown: another echo may read another address", got)
	}
}
