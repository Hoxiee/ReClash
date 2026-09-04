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

func TestWavePlanStopsScheduledWavesOnAMeteredLink(t *testing.T) {
	config := rcxDefaultConfig()
	config.WaveWidth = 6
	config.SaveMobileData = true

	if _, ok := rcxWavePlan(config, true, false); ok {
		t.Error("a scheduled wave must not run on a metered link while saving data")
	}

	width, ok := rcxWavePlan(config, true, true)
	if !ok || width != 3 {
		t.Errorf("on-demand wave = (%d, %v), want a narrow one", width, ok)
	}

	config.SaveMobileData = false
	width, ok = rcxWavePlan(config, true, false)
	if !ok || width != config.WaveWidth {
		t.Errorf("wave = (%d, %v), want the configured width when the user opted out", width, ok)
	}
}
