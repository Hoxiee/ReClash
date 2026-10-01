package rcx

import (
	"bytes"
	"encoding/json"
	"math/rand"
	"os"
	"path/filepath"
	"testing"
)

// rcxLadderOracle reproduces the pre-data-driven ranking over a raw key: the
// historical rcxKeyOf floored recurrence at 2 before the fixed if-chain, and the
// lowest-latency strategy zeroed misfit. The data-driven ladder must match it.
func rcxLadderOracle(a, b rcxKey, strategy string) int {
	a.recurrence = rcxRecurrenceFloored(a.recurrence, rcxRecurrenceFloorDefault)
	b.recurrence = rcxRecurrenceFloored(b.recurrence, rcxRecurrenceFloorDefault)
	if strategy == rcxStrategyLatency {
		a.misfit, b.misfit = 0, 0
	}
	return rcxCompare(a, b)
}

func rcxRandomKey(r *rand.Rand) rcxKey {
	latencies := []int{0, 30, 50, 60, 140, 200, 1 << 20}
	orders := []int{0, 1, 5, 1 << 20}
	return rcxKey{
		verdict:    rcxVerdict(r.Intn(4)),
		misfit:     uint8(r.Intn(2)),
		recurrence: r.Intn(6),
		degraded:   r.Intn(2) == 1,
		unproven:   r.Intn(2) == 1,
		evidence:   rcxEvidence(r.Intn(4)),
		homeRisk:   uint8(r.Intn(3)),
		latencyMs:  latencies[r.Intn(len(latencies))],
		challenger: r.Intn(2) == 1,
		order:      orders[r.Intn(len(orders))],
	}
}

func TestLadderMatchesLegacyComparator(t *testing.T) {
	r := rand.New(rand.NewSource(1))
	def := rcxDefaultLadder()
	latency := rcxLadderForStrategy(def, rcxStrategyLatency)
	balanced := rcxLadderForStrategy(def, rcxStrategyBalanced)
	for i := 0; i < 500000; i++ {
		a, b := rcxRandomKey(r), rcxRandomKey(r)
		if got, want := rcxCompareWith(a, b, balanced), rcxLadderOracle(a, b, rcxStrategyBalanced); got != want {
			t.Fatalf("balanced ladder disagrees: got %d want %d for %+v vs %+v", got, want, a, b)
		}
		if got, want := rcxCompareWith(a, b, latency), rcxLadderOracle(a, b, rcxStrategyLatency); got != want {
			t.Fatalf("latency ladder disagrees: got %d want %d for %+v vs %+v", got, want, a, b)
		}
	}
}

func TestLadderRecurrenceFloorTracksSpec(t *testing.T) {
	low := rcxKey{recurrence: 1}
	high := rcxKey{recurrence: 0}
	floored := []rcxRungSpec{{ID: rcxRungRecurrence, Enabled: true, RecurrenceFloor: 2}}
	if got := rcxCompareWith(low, high, floored); got != 0 {
		t.Fatalf("floor 2 should tie recurrence 1 vs 0, got %d", got)
	}
	raw := []rcxRungSpec{{ID: rcxRungRecurrence, Enabled: true, RecurrenceFloor: 0}}
	if got := rcxCompareWith(low, high, raw); got != 1 {
		t.Fatalf("floor 0 should let recurrence 0 beat 1, got %d", got)
	}
}

func TestLadderLatencyToleranceTiesWithinBand(t *testing.T) {
	a := rcxKey{latencyMs: 50}
	b := rcxKey{latencyMs: 60}
	tol := []rcxRungSpec{{ID: rcxRungLatency, Enabled: true, LatencyToleranceMs: 15}}
	if got := rcxCompareWith(a, b, tol); got != 0 {
		t.Fatalf("tolerance 15 should tie 50 vs 60, got %d", got)
	}
	exact := []rcxRungSpec{{ID: rcxRungLatency, Enabled: true, LatencyToleranceMs: 0}}
	if got := rcxCompareWith(a, b, exact); got != -1 {
		t.Fatalf("tolerance 0 should let 50 beat 60, got %d", got)
	}
}

func TestDefaultLadderMatchesGoldenFixture(t *testing.T) {
	got, err := json.MarshalIndent(rcxDefaultLadder(), "", "  ")
	if err != nil {
		t.Fatalf("marshal default ladder: %v", err)
	}
	path := filepath.Join("testdata", "default_ladder.json")
	want, err := os.ReadFile(path)
	if err != nil {
		t.Fatalf("read golden: %v", err)
	}
	if !bytes.Equal(bytes.TrimSpace(got), bytes.TrimSpace(want)) {
		t.Fatalf("default ladder drifted from %s:\n got: %s\nwant: %s", path, got, want)
	}
}

// A literal guard so a reordering never slips through the golden regeneration
// unnoticed; this order is the shipped, safety-reviewed decision ladder.
func TestDefaultLadderHistoricalOrder(t *testing.T) {
	want := []rcxRungID{
		rcxRungVerdict, rcxRungMisfit, rcxRungRecurrence, rcxRungDegraded,
		rcxRungHomeRisk, rcxRungLatency, rcxRungEvidence, rcxRungUnproven,
		rcxRungIncumbent, rcxRungTiebreak,
	}
	ladder := rcxDefaultLadder()
	if len(ladder) != len(want) {
		t.Fatalf("default ladder has %d rungs, want %d", len(ladder), len(want))
	}
	for i, id := range want {
		if ladder[i].ID != id || !ladder[i].Enabled {
			t.Fatalf("rung %d = %v(on=%v), want %v enabled", i, ladder[i].ID, ladder[i].Enabled, id)
		}
	}
}

func TestRungTokenRoundTrip(t *testing.T) {
	for id := rcxRungID(0); id < rcxRungCount; id++ {
		token := id.String()
		if token == "" {
			t.Fatalf("rung %d has empty token", id)
		}
		back, ok := rcxRungByToken(token)
		if !ok || back != id {
			t.Fatalf("token %q round-trips to %v(ok=%v), want %v", token, back, ok, id)
		}
	}
	if _, ok := rcxRungByToken("nope"); ok {
		t.Fatal("unknown token resolved")
	}
}
