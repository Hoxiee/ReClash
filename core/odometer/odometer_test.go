package odometer

import (
	"strconv"
	"sync"
	"testing"
	"time"

	"core/rcx"
)

type odoMemStorage struct {
	values map[string][]byte
}

func newOdoMemStorage() *odoMemStorage {
	return &odoMemStorage{values: map[string][]byte{}}
}

func (s *odoMemStorage) Get(key string) []byte { return s.values[key] }

func (s *odoMemStorage) Set(key string, value []byte) {
	s.values[key] = append([]byte{}, value...)
}

type odoFakeTraffic struct {
	up   int64
	down int64
}

func (t *odoFakeTraffic) TotalTraffic(bool) (int64, int64) { return t.up, t.down }

type odoClock struct{ at time.Time }

func (c *odoClock) now() time.Time { return c.at }

func newTestOdometer(storage rcx.Storage) (*odometer, *odoClock) {
	clock := &odoClock{at: time.Date(2026, 3, 1, 10, 0, 0, 0, time.UTC)}
	return &odometer{storage: storage, traffic: &odoFakeTraffic{}, now: clock.now}, clock
}

func odoRun(o *odometer, clock *odoClock, span, step time.Duration) {
	for elapsed := time.Duration(0); elapsed < span; elapsed += step {
		clock.at = clock.at.Add(step)
		o.Tick(clock.at)
	}
}

func TestCoverageAccrualFollowsTheTunnelNotTheWallClock(t *testing.T) {
	o, clock := newTestOdometer(newOdoMemStorage())
	o.NoteUp(clock.at, "")
	odoRun(o, clock, 4*time.Hour, odoTickInterval)
	o.NoteDown(clock.at, true)

	if got := o.Report().StreakMillis; got < (4*time.Hour).Milliseconds()-1000 {
		t.Fatalf("streak = %dms, want about four hours of coverage", got)
	}
}

func TestATechnicalHandoffKeepsTheStreakWhole(t *testing.T) {
	storage := newOdoMemStorage()
	o, clock := newTestOdometer(storage)
	o.NoteUp(clock.at, "")
	odoRun(o, clock, time.Hour, odoTickInterval)
	o.NoteDown(clock.at, false)

	restarted, resumed := newTestOdometer(storage)
	resumed.at = clock.at.Add(30 * time.Second)
	restarted.NoteUp(resumed.at, "")
	report := restarted.Report()

	if report.StitchCount != 1 {
		t.Fatalf("stitches = %d, want the short gap stitched once", report.StitchCount)
	}
	if report.StreakMillis < time.Hour.Milliseconds() {
		t.Errorf("streak = %dms, want the hour before the handoff carried over", report.StreakMillis)
	}
}

func TestAnExplicitStopEndsTheStreakEvenWhenTheGapIsShort(t *testing.T) {
	storage := newOdoMemStorage()
	o, clock := newTestOdometer(storage)
	o.NoteUp(clock.at, "")
	odoRun(o, clock, time.Hour, odoTickInterval)
	o.NoteDown(clock.at, true)

	restarted, resumed := newTestOdometer(storage)
	resumed.at = clock.at.Add(5 * time.Second)
	restarted.NoteUp(resumed.at, "")
	report := restarted.Report()

	if report.StreakMillis != 0 {
		t.Fatalf("streak = %dms, want a fresh start after the user pulled the plug", report.StreakMillis)
	}
	if report.BestStreakMillis < time.Hour.Milliseconds() {
		t.Errorf("best = %dms, want the finished hour remembered", report.BestStreakMillis)
	}
}

func TestAnUpdateGetsAmnestyAndAnUnexplainedNightDoesNot(t *testing.T) {
	for _, testCase := range []struct {
		name     string
		reason   string
		gap      time.Duration
		stitched bool
	}{
		{name: "update inside its window", reason: "update", gap: 4 * time.Hour, stitched: true},
		{name: "update past its window", reason: "update", gap: 9 * time.Hour},
		{name: "crash inside its window", reason: "crash", gap: 20 * time.Minute, stitched: true},
		{name: "crash past its window", reason: "crash", gap: 2 * time.Hour},
		{name: "silence with no reason", reason: "", gap: 20 * time.Minute},
	} {
		t.Run(testCase.name, func(t *testing.T) {
			storage := newOdoMemStorage()
			o, clock := newTestOdometer(storage)
			o.NoteUp(clock.at, "")
			odoRun(o, clock, time.Hour, odoTickInterval)

			restarted, resumed := newTestOdometer(storage)
			resumed.at = clock.at.Add(testCase.gap)
			restarted.NoteUp(resumed.at, testCase.reason)
			if got := restarted.Report().StitchCount > 0; got != testCase.stitched {
				t.Fatalf("stitched = %v, want %v", got, testCase.stitched)
			}
		})
	}
}

func TestStitchingRunsOutOfBudget(t *testing.T) {
	storage := newOdoMemStorage()
	o, clock := newTestOdometer(storage)
	o.NoteUp(clock.at, "")

	for attempt := 0; attempt < odoStitchBudgetCount+2; attempt++ {
		odoRun(o, clock, time.Minute, odoTickInterval)
		at := clock.at.Add(30 * time.Second)
		o, clock = newTestOdometer(storage)
		clock.at = at
		o.NoteUp(at, "")
	}

	if got := o.Report().StitchCount; got > odoStitchBudgetCount {
		t.Fatalf("stitches = %d, want the budget to cap at %d", got, odoStitchBudgetCount)
	}
}

func TestCoverageIsClippedByTheSlowerOfTheTwoClocks(t *testing.T) {
	o, clock := newTestOdometer(newOdoMemStorage())
	start := clock.at
	o.NoteUp(start, "")
	clock.at = start.Add(odoTickInterval)
	o.Tick(clock.at)

	o.mu.Lock()
	o.lastTick = start
	o.mu.Unlock()
	clock.at = start.Add(odoTickInterval + time.Second)
	o.Tick(clock.at)

	if got := o.Report().StreakMillis; got > (odoTickInterval + 2*time.Second).Milliseconds() {
		t.Fatalf("streak = %dms, want the wall clock to cap a long monotonic reading", got)
	}
}

func TestCleanDaysNeedCoverageAndSurviveNothingGoingWrong(t *testing.T) {
	o, clock := newTestOdometer(newOdoMemStorage())
	clock.at = time.Date(2026, 3, 1, 0, 0, 0, 0, time.UTC)
	o.NoteUp(clock.at, "")
	for day := 0; day < 3; day++ {
		odoRun(o, clock, 2*time.Hour, 10*time.Minute)
		clock.at = clock.at.Add(22 * time.Hour)
		o.Tick(clock.at)
	}
	if got := o.Report().CleanDayRun; got != 3 {
		t.Fatalf("clean days = %d, want three quiet days counted", got)
	}

	o.NoteExam(false)
	odoRun(o, clock, 2*time.Hour, 10*time.Minute)
	clock.at = clock.at.Add(22 * time.Hour)
	o.Tick(clock.at)
	if got := o.Report().CleanDayRun; got != 0 {
		t.Fatalf("clean days = %d, want a broken exam to end the run", got)
	}
	if got := o.Report().BestCleanDayRun; got != 3 {
		t.Errorf("best clean days = %d, want the earlier run remembered", got)
	}
}

func TestCountriesAreCollectedOnceAndSorted(t *testing.T) {
	o, _ := newTestOdometer(newOdoMemStorage())
	for _, country := range []string{"NL", "DE", "NL", "", "SINGAPORE", "AM"} {
		o.NoteAutoDecision()
		o.NoteCountry(country)
	}
	got := o.Report().Countries
	want := []string{"AM", "DE", "NL"}
	if len(got) != len(want) {
		t.Fatalf("countries = %v, want %v", got, want)
	}
	for index := range want {
		if got[index] != want[index] {
			t.Fatalf("countries = %v, want %v", got, want)
		}
	}
	if decisions := o.Report().AutoDecisions; decisions != 6 {
		t.Errorf("decisions = %d, want every switch counted even without a country", decisions)
	}
}

func TestTrafficIgnoresTheResetThatEveryStartPerforms(t *testing.T) {
	traffic := &odoFakeTraffic{}
	o, clock := newTestOdometer(newOdoMemStorage())
	o.traffic = traffic
	o.NoteUp(clock.at, "")

	traffic.up, traffic.down = 1000, 4000
	clock.at = clock.at.Add(odoTickInterval)
	o.Tick(clock.at)
	traffic.up, traffic.down = 3000, 9000
	clock.at = clock.at.Add(odoTickInterval)
	o.Tick(clock.at)

	traffic.up, traffic.down = 500, 100
	clock.at = clock.at.Add(odoTickInterval)
	o.Tick(clock.at)

	report := o.Report()
	if report.UpBytes != 3500 || report.DownBytes != 9100 {
		t.Fatalf("traffic = %d/%d, want 3500/9100 with the reset read as a fresh count",
			report.UpBytes, report.DownBytes)
	}
}

func TestStateSurvivesAnUnreadablePayload(t *testing.T) {
	storage := newOdoMemStorage()
	storage.values[odoStoreKey] = []byte("{not json")
	o, clock := newTestOdometer(storage)
	o.NoteUp(clock.at, "")
	if got := o.Report().FirstRunMillis; got != clock.at.UnixMilli() {
		t.Fatalf("first run = %d, want the corrupt state replaced by a fresh one", got)
	}
}

func TestLadderRemembersItsDeepestStep(t *testing.T) {
	o, _ := newTestOdometer(newOdoMemStorage())
	o.NoteLadder(3, false)
	o.NoteLadder(1, true)
	if got := o.Report().LadderTop; got != 3 {
		t.Fatalf("ladder = %d, want the deepest step kept", got)
	}
	if !o.Report().LadderCompleted {
		t.Fatal("completed ladder was not remembered")
	}
}

func TestInactiveCountersAreSavedImmediately(t *testing.T) {
	storage := newOdoMemStorage()
	o, _ := newTestOdometer(storage)
	o.NoteRecovery()

	reloaded, _ := newTestOdometer(storage)
	if got := reloaded.Report().Recoveries; got != 1 {
		t.Fatalf("recoveries = %d, want inactive mutation persisted", got)
	}
}

func TestLongDeferredTickKeepsCoverage(t *testing.T) {
	o, clock := newTestOdometer(newOdoMemStorage())
	o.NoteUp(clock.at, "")
	clock.at = clock.at.Add(4 * time.Hour)
	o.Tick(clock.at)

	if got := o.Report().StreakMillis; got != (4 * time.Hour).Milliseconds() {
		t.Fatalf("streak = %dms, want deferred four-hour tick retained", got)
	}
}

func TestConcurrentStartReasonIsConsumedWithoutRaces(t *testing.T) {
	const workers = 32
	var wait sync.WaitGroup
	wait.Add(workers)
	for index := 0; index < workers; index++ {
		go func(index int) {
			defer wait.Done()
			setOdoStartReason(strconv.Itoa(index))
			_ = takeOdoStartReason()
		}(index)
	}
	wait.Wait()
}

func TestStartReasonIsTakenOnce(t *testing.T) {
	setOdoStartReason("update")
	if got := takeOdoStartReason(); got != "update" {
		t.Fatalf("reason = %q, want update", got)
	}
	if got := takeOdoStartReason(); got != "" {
		t.Fatalf("second reason = %q, want it consumed", got)
	}
}

func TestOdometerNoteExamCountsCleanAndBroken(t *testing.T) {
	o, _ := newTestOdometer(newOdoMemStorage())
	o.NoteExam(true)
	o.NoteExam(false)
	if report := o.Report(); report.Exams != 2 || report.ExamsClean != 1 {
		t.Fatalf("exam counters = %d/%d, want 2/1", report.Exams, report.ExamsClean)
	}
}
