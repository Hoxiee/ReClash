package main

import (
	"context"
	"errors"
	"sync"
	"testing"
	"time"
)

func testProber(test rcxTestFunc) *rcxProber {
	return &rcxProber{
		test:        test,
		concurrency: 2,
		staggerMs:   0,
		timeout:     time.Second,
		sleep:       func(ctx context.Context, _ time.Duration) bool { return ctx.Err() == nil },
	}
}

func TestRunLeavesUnstartedTargetsOverloaded(t *testing.T) {
	ctx, cancel := context.WithCancel(context.Background())
	started := 0
	prober := testProber(func(context.Context, string, rcxMarker) (int, bool, error) {
		started++
		return 40, true, nil
	})
	prober.staggerMs = 100
	// The link dies while the wave is still being dispatched.
	prober.sleep = func(context.Context, time.Duration) bool {
		cancel()
		return false
	}

	results := prober.Run(ctx, []rcxProbeTarget{
		{Node: "a"},
		{Node: "b"},
		{Node: "c"},
	})

	if started != 1 {
		t.Fatalf("started %d probes, want 1 before the wave was cut short", started)
	}
	if results[0].Outcome != rcxProbeOK {
		t.Errorf("first outcome = %d, want ok", results[0].Outcome)
	}
	for _, result := range results[1:] {
		if result.Outcome != rcxProbeOverloaded {
			t.Errorf("%s outcome = %d, want overloaded: it never ran", result.Node, result.Outcome)
		}
	}
}

func TestRunKeepsAtMostConcurrencyInFlight(t *testing.T) {
	var mu sync.Mutex
	inFlight, peak := 0, 0
	prober := testProber(func(context.Context, string, rcxMarker) (int, bool, error) {
		mu.Lock()
		inFlight++
		if inFlight > peak {
			peak = inFlight
		}
		mu.Unlock()
		time.Sleep(20 * time.Millisecond)
		mu.Lock()
		inFlight--
		mu.Unlock()
		return 50, true, nil
	})

	targets := make([]rcxProbeTarget, 6)
	for i := range targets {
		targets[i] = rcxProbeTarget{Node: string(rune('a' + i))}
	}
	prober.Run(context.Background(), targets)

	if peak > 2 {
		t.Errorf("peak in flight = %d, want at most 2: a burst spends the radio budget at once", peak)
	}
}

func TestProbeSeparatesTheThreeWaysAMeasurementCanEnd(t *testing.T) {
	tests := []struct {
		name      string
		delay     int
		satisfied bool
		err       error
		want      rcxProbeOutcome
		wantDelay int
	}{
		{name: "answered as expected", delay: 80, satisfied: true, want: rcxProbeOK, wantDelay: 80},
		{name: "answered with another status", delay: 80, want: rcxProbeStatusMismatch, wantDelay: 80},
		{name: "never answered", err: errors.New("timeout"), want: rcxProbeFail},
	}

	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			prober := testProber(func(context.Context, string, rcxMarker) (int, bool, error) {
				return tc.delay, tc.satisfied, tc.err
			})

			got := prober.probe(context.Background(), rcxProbeTarget{Node: "a"})

			if got.Outcome != tc.want {
				t.Errorf("outcome = %d, want %d", got.Outcome, tc.want)
			}
			if got.DelayMs != tc.wantDelay {
				t.Errorf("delay = %d, want %d", got.DelayMs, tc.wantDelay)
			}
		})
	}
}

func TestProbeBlamesTheWaveNotTheNodeWhenTheParentIsCancelled(t *testing.T) {
	ctx, cancel := context.WithCancel(context.Background())
	prober := testProber(func(context.Context, string, rcxMarker) (int, bool, error) {
		cancel()
		return 0, false, errors.New("context canceled")
	})

	got := prober.probe(ctx, rcxProbeTarget{Node: "a"})

	if got.Outcome != rcxProbeOverloaded {
		t.Errorf("outcome = %d, want overloaded: our own cancellation is not evidence", got.Outcome)
	}
}

func TestStaggerStaysInsideTheJitterSpread(t *testing.T) {
	prober := testProber(nil)
	prober.staggerMs = 250
	prober.jitter = func(spread int) int { return 0 }

	if got := prober.stagger(); got != 125*time.Millisecond {
		t.Errorf("stagger = %v, want the lower edge 125ms", got)
	}

	prober.jitter = func(spread int) int { return spread }
	if got := prober.stagger(); got != 375*time.Millisecond {
		t.Errorf("stagger = %v, want the upper edge 375ms", got)
	}
}

func TestDiverseWaveTakesOneFromEachBucketBeforeASecond(t *testing.T) {
	nodes := []rcxProbeNode{
		{Name: "vless-a", Type: "Vless", Port: 443, HasServerName: true},
		{Name: "vless-b", Type: "Vless", Port: 443, HasServerName: true},
		{Name: "vless-c", Type: "Vless", Port: 443, HasServerName: true},
		{Name: "ss-a", Type: "Shadowsocks", Port: 8388},
		{Name: "vless-cdn", Type: "Vless", Port: 2053, HasServerName: true},
	}

	wave := rcxDiverseWave(nodes, 3)

	got := []string{wave[0].Name, wave[1].Name, wave[2].Name}
	want := []string{"vless-a", "ss-a", "vless-cdn"}
	for i := range want {
		if got[i] != want[i] {
			t.Fatalf("wave = %v, want one per bucket first: %v", got, want)
		}
	}
}

func TestDiverseWaveFallsBackToOneBucket(t *testing.T) {
	nodes := []rcxProbeNode{
		{Name: "a", Type: "Vless", Port: 443},
		{Name: "b", Type: "Vless", Port: 443},
	}

	wave := rcxDiverseWave(nodes, 5)

	if len(wave) != 2 {
		t.Errorf("wave size = %d, want every node when there is nothing to diversify", len(wave))
	}
}

func TestHoistNodeGivesTheSuspectTheSeatEveryWaveTakes(t *testing.T) {
	nodes := []rcxProbeNode{
		{Name: "a", Type: "Vless", Port: 443},
		{Name: "b", Type: "Vless", Port: 443},
		{Name: "suspect", Type: "Vless", Port: 443},
	}

	rcxHoistNode(nodes, "suspect")

	got := []string{nodes[0].Name, nodes[1].Name, nodes[2].Name}
	want := []string{"suspect", "a", "b"}
	for i := range want {
		if got[i] != want[i] {
			t.Fatalf("pool = %v, want the suspect first and the rest in order: %v", got, want)
		}
	}
	if wave := rcxDiverseWave(nodes, 1); wave[0].Name != "suspect" {
		t.Errorf("wave = %v, want even the narrowest wave to measure the suspect", wave)
	}

	rcxHoistNode(nodes, "gone")
	if nodes[0].Name != "suspect" {
		t.Error("a name outside the pool must leave the order alone")
	}
}

func TestProbeBudgetGrantsWhatIsLeftAndRecoversWithTheWindow(t *testing.T) {
	budget := newRcxProbeBudget(4, time.Hour)
	now := time.Unix(1_700_000_000, 0)

	if got := budget.Take(3, now); got != 3 {
		t.Fatalf("first take = %d, want 3", got)
	}
	if got := budget.Take(3, now); got != 1 {
		t.Errorf("second take = %d, want the single remaining slot", got)
	}
	if got := budget.Take(1, now); got != 0 {
		t.Errorf("third take = %d, want nothing", got)
	}
	if got := budget.Remaining(now.Add(time.Hour + time.Second)); got != 4 {
		t.Errorf("remaining after the window = %d, want the full budget back", got)
	}
}

func TestBudgetGivesBackWhatMeasuredNothing(t *testing.T) {
	budget := newRcxProbeBudget(4, time.Hour)
	now := time.Now()

	budget.Take(4, now)
	budget.Refund(3)

	if got := budget.Remaining(now); got != 3 {
		t.Errorf("remaining = %d, want the three unmeasured probes back", got)
	}
	budget.Refund(9)
	if got := budget.Remaining(now); got != 4 {
		t.Errorf("remaining = %d, want a refund clamped to what was spent", got)
	}
}

func TestProberEndsTheWaveOnceItHasLearnedEnough(t *testing.T) {
	var mu sync.Mutex
	asked := 0
	prober := newRcxProber(func(ctx context.Context, node string, _ rcxMarker) (int, bool, error) {
		mu.Lock()
		asked++
		mu.Unlock()
		if node == "alive" {
			return 40, true, nil
		}
		<-ctx.Done()
		return 0, false, ctx.Err()
	})
	prober.staggerMs = 0
	prober.timeout = time.Second
	prober.enough = func(result rcxProbeResult) bool { return result.Outcome == rcxProbeOK }

	targets := []rcxProbeTarget{{Node: "alive"}}
	for i := 0; i < 8; i++ {
		targets = append(targets, rcxProbeTarget{Node: "dead"})
	}
	results := prober.Run(context.Background(), targets)

	if results[0].Outcome != rcxProbeOK {
		t.Fatalf("first result = %v, want the working node measured", results[0].Outcome)
	}
	mu.Lock()
	defer mu.Unlock()
	if asked > 3 {
		t.Errorf("asked %d nodes, want the sweep to stop at the one that works", asked)
	}
}

// A contained panic must mark its slot: an empty one reads as a pass.
func TestRunContainsAPanickingProbe(t *testing.T) {
	prober := testProber(func(_ context.Context, node string, _ rcxMarker) (int, bool, error) {
		if node == "boom" {
			panic("probe exploded")
		}
		return 40, true, nil
	})

	results := prober.Run(context.Background(), []rcxProbeTarget{
		{Node: "boom", Role: rcxRoleOpen},
		{Node: "fine", Role: rcxRoleOpen},
	})

	if got := results[0]; got.Outcome != rcxProbeOverloaded || got.Node != "boom" {
		t.Errorf("result = %+v, want boom unmeasured", got)
	}
	if got := results[1].Outcome; got != rcxProbeOK {
		t.Errorf("outcome = %s, want ok: one bad target must not cost the wave",
			rcxOutcomeName(got))
	}
}
