package odometer

import (
	"testing"
	"time"
)

func TestOdometerBootClockIncludesSuspendAndClipsClockChanges(t *testing.T) {
	o, clock := newTestOdometer(newOdoMemStorage())
	boot := time.Hour
	o.monotonic = func() time.Duration { return boot }
	o.NoteUp(clock.at, "")
	boot += 8 * time.Hour
	clock.at = clock.at.Add(8 * time.Hour)
	o.Tick(clock.at)
	if got := o.Report().TotalCoveredMillis; got != (8 * time.Hour).Milliseconds() {
		t.Fatalf("coverage after suspend = %d", got)
	}
	boot += time.Second
	clock.at = clock.at.Add(24 * time.Hour)
	o.Tick(clock.at)
	want := (8*time.Hour + time.Second).Milliseconds()
	if got := o.Report().TotalCoveredMillis; got != want {
		t.Fatalf("forward wall jump inflated coverage: %d != %d", got, want)
	}
	boot += time.Second
	clock.at = clock.at.Add(-24 * time.Hour)
	o.Tick(clock.at)
	if got := o.Report().TotalCoveredMillis; got != want {
		t.Fatalf("backward wall jump inflated coverage: %d != %d", got, want)
	}
}
