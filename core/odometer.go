package main

import (
	"encoding/json"
	"sort"
	"sync"
	"time"

	"github.com/metacubex/mihomo/log"
	"github.com/metacubex/mihomo/tunnel/statistic"
)

const (
	odoStoreKey      = "odo.v1"
	odoStoreVersion  = 1
	odoFlushDebounce = 30 * time.Second
	odoTickInterval  = 20 * time.Second

	// A technical handoff (service restart, config re-apply) is invisible to the
	// user, so it is stitched without asking the exit reason.
	odoStitchWindow       = 90 * time.Second
	odoUpdateAmnesty      = 6 * time.Hour
	odoCrashAmnesty       = 30 * time.Minute
	odoStitchBudgetPeriod = 30 * 24 * time.Hour
	odoStitchBudgetCount  = 8
	odoStitchBudgetMillis = int64(4 * 60 * 60 * 1000)

	odoCleanDayMinCoverage = time.Hour
	odoMaxCountries        = 64
)

type odoState struct {
	Version int `json:"v"`

	FirstRunMillis int64 `json:"fr,omitempty"`

	StreakStartMillis   int64 `json:"ss,omitempty"`
	StreakCoveredMillis int64 `json:"sc,omitempty"`
	BestStreakMillis    int64 `json:"sb,omitempty"`
	StitchCount         int   `json:"sn,omitempty"`
	StitchedMillis      int64 `json:"sm,omitempty"`

	TotalCoveredMillis int64 `json:"tc,omitempty"`
	Sessions           int   `json:"sx,omitempty"`

	LastTickMillis int64 `json:"lt,omitempty"`
	Active         bool  `json:"ac,omitempty"`
	UserStopped    bool  `json:"us,omitempty"`

	UpBytes   int64 `json:"ub,omitempty"`
	DownBytes int64 `json:"db,omitempty"`

	Exams      int `json:"de,omitempty"`
	ExamsClean int `json:"dc,omitempty"`

	AutoDecisions    int   `json:"ad,omitempty"`
	ManualSwitches   int   `json:"ms,omitempty"`
	LastManualMillis int64 `json:"mm,omitempty"`

	LadderTop       int      `json:"lr,omitempty"`
	LadderCompleted bool     `json:"lc,omitempty"`
	Countries       []string `json:"cn,omitempty"`
	Recoveries      int      `json:"rv,omitempty"`

	DayKey           int   `json:"dk,omitempty"`
	DayCoveredMillis int64 `json:"dv,omitempty"`
	DayIncidents     int   `json:"di,omitempty"`
	CleanDayRun      int   `json:"cr,omitempty"`
	BestCleanDayRun  int   `json:"cb,omitempty"`
}

type odoReport struct {
	FirstRunMillis     int64    `json:"firstRunMillis"`
	StreakMillis       int64    `json:"streakMillis"`
	BestStreakMillis   int64    `json:"bestStreakMillis"`
	TotalCoveredMillis int64    `json:"totalCoveredMillis"`
	StitchCount        int      `json:"stitchCount"`
	Sessions           int      `json:"sessions"`
	UpBytes            int64    `json:"upBytes"`
	DownBytes          int64    `json:"downBytes"`
	Exams              int      `json:"exams"`
	ExamsClean         int      `json:"examsClean"`
	AutoDecisions      int      `json:"autoDecisions"`
	ManualSwitches     int      `json:"manualSwitches"`
	QuietManualMillis  int64    `json:"quietManualMillis"`
	LadderTop          int      `json:"ladderTop"`
	LadderCompleted    bool     `json:"ladderCompleted"`
	Countries          []string `json:"countries"`
	Recoveries         int      `json:"recoveries"`
	CleanDayRun        int      `json:"cleanDayRun"`
	BestCleanDayRun    int      `json:"bestCleanDayRun"`
}

type odoTrafficSource interface {
	TotalTraffic(onlyStatisticsProxy bool) (int64, int64)
}

type odoManagerTraffic struct{}

func (odoManagerTraffic) TotalTraffic(onlyStatisticsProxy bool) (int64, int64) {
	return statistic.DefaultManager.TotalTraffic(onlyStatisticsProxy)
}

type odometer struct {
	mu      sync.Mutex
	storage rcxStorage
	traffic odoTrafficSource

	state         *odoState
	loaded        bool
	runtimeActive bool
	lastTick      time.Time
	lastSave      time.Time
	flushTimer    *time.Timer

	trafficPrimed bool
	lastUp        int64
	lastDown      int64

	now           func() time.Time
	monotonic     func() time.Duration
	lastMonotonic time.Duration
}

var odometerInstance = &odometer{
	storage:   rcxCacheStorage{},
	traffic:   odoManagerTraffic{},
	now:       time.Now,
	monotonic: odoElapsedRealtime,
}

// Must not run before handleInitClash sets the home dir: cachefile.Cache() binds
// its bbolt path through a sync.Once and would latch onto the wrong location.
func (o *odometer) ensureLoaded(now time.Time) {
	if o.loaded {
		return
	}
	o.loaded = true
	o.state = odoDecodeState(o.storage.Get(odoStoreKey))
	if o.state.FirstRunMillis == 0 {
		o.state.FirstRunMillis = now.UnixMilli()
	}
}

func odoDecodeState(raw []byte) *odoState {
	empty := &odoState{Version: odoStoreVersion}
	if len(raw) == 0 {
		return empty
	}
	var header struct {
		Version int `json:"v"`
	}
	if err := json.Unmarshal(raw, &header); err != nil || header.Version != odoStoreVersion {
		return empty
	}
	state := &odoState{}
	if err := json.Unmarshal(raw, state); err != nil {
		log.Warnln("[ODO] discarding unreadable state: %s", err.Error())
		return empty
	}
	state.Version = odoStoreVersion
	return state
}

func (o *odometer) save(now time.Time, force bool) {
	if !o.loaded {
		return
	}
	remaining := odoFlushDebounce - now.Sub(o.lastSave)
	if !force && remaining > 0 {
		if o.flushTimer == nil {
			o.flushTimer = time.AfterFunc(remaining, o.flushPending)
		}
		return
	}
	if o.flushTimer != nil {
		o.flushTimer.Stop()
		o.flushTimer = nil
	}
	o.state.Version = odoStoreVersion
	payload, err := json.Marshal(o.state)
	if err != nil {
		log.Warnln("[ODO] state encode failed: %s", err.Error())
		return
	}
	o.storage.Set(odoStoreKey, payload)
	o.lastSave = now
}

func (o *odometer) flushPending() {
	o.mu.Lock()
	defer o.mu.Unlock()
	o.flushTimer = nil
	o.save(o.now(), true)
}

func odoAmnestyWindow(reason string) (time.Duration, bool) {
	switch reason {
	case "update":
		return odoUpdateAmnesty, true
	case "crash", "lowMemory", "reboot":
		return odoCrashAmnesty, true
	default:
		return 0, false
	}
}

func (o *odometer) canStitch(gap int64, reason string) bool {
	if gap > odoStitchWindow.Milliseconds() {
		window, ok := odoAmnestyWindow(reason)
		if !ok || gap > window.Milliseconds() {
			return false
		}
	}
	units := 1 + o.state.StreakCoveredMillis/odoStitchBudgetPeriod.Milliseconds()
	if int64(o.state.StitchCount)+1 > odoStitchBudgetCount*units {
		return false
	}
	return o.state.StitchedMillis+gap <= odoStitchBudgetMillis*units
}

func (o *odometer) restartStreak(wall int64) {
	o.state.StreakStartMillis = wall
	o.state.StreakCoveredMillis = 0
	o.state.StitchCount = 0
	o.state.StitchedMillis = 0
}

func (o *odometer) NoteUp(now time.Time, reason string) {
	o.mu.Lock()
	o.ensureLoaded(now)
	s := o.state
	if o.runtimeActive {
		o.mu.Unlock()
		o.startHeartbeat()
		return
	}
	wall := now.UnixMilli()
	s.Sessions++
	switch {
	case s.StreakStartMillis == 0 || s.UserStopped:
		o.restartStreak(wall)
	default:
		gap := wall - s.LastTickMillis
		if gap < 0 {
			gap = 0
		}
		if o.canStitch(gap, reason) {
			s.StitchCount++
			s.StitchedMillis += gap
			o.addCoverage(gap)
		} else {
			o.restartStreak(wall)
		}
	}
	s.UserStopped = false
	s.Active = true
	o.runtimeActive = true
	s.LastTickMillis = wall
	o.lastTick = now
	if o.monotonic != nil {
		o.lastMonotonic = o.monotonic()
	}
	o.trafficPrimed = false
	o.sampleTraffic()
	o.rollDay(now)
	o.save(now, true)
	o.mu.Unlock()
	o.startHeartbeat()
}

func (o *odometer) NoteDown(now time.Time, userRequested bool) {
	o.mu.Lock()
	defer o.mu.Unlock()
	o.ensureLoaded(now)
	if !o.runtimeActive {
		return
	}
	o.accrue(now)
	o.runtimeActive = false
	o.state.Active = false
	o.state.UserStopped = userRequested
	o.save(now, true)
}

func (o *odometer) addCoverage(elapsed int64) {
	s := o.state
	s.StreakCoveredMillis += elapsed
	s.TotalCoveredMillis += elapsed
	s.DayCoveredMillis += elapsed
	if s.StreakCoveredMillis > s.BestStreakMillis {
		s.BestStreakMillis = s.StreakCoveredMillis
	}
}

// Wall and monotonic disagree whenever the clock is nudged or the device
// suspends; the smaller reading is the one that cannot be inflated on purpose.
func (o *odometer) accrue(now time.Time) {
	if o.lastTick.IsZero() {
		o.lastTick = now
		return
	}
	elapsed := now.Sub(o.lastTick)
	if o.monotonic != nil {
		current := o.monotonic()
		elapsed = current - o.lastMonotonic
		o.lastMonotonic = current
	}
	if wall := max(int64(0), now.UnixMilli()-o.state.LastTickMillis); wall < elapsed.Milliseconds() {
		elapsed = time.Duration(wall) * time.Millisecond
	}
	if elapsed > 0 {
		o.addCoverage(elapsed.Milliseconds())
	}
	o.lastTick = now
	o.state.LastTickMillis = now.UnixMilli()
}

func odoDayKey(now time.Time) int {
	year, month, day := now.Date()
	return year*10000 + int(month)*100 + day
}

func (o *odometer) rollDay(now time.Time) {
	s := o.state
	key := odoDayKey(now)
	if s.DayKey == 0 {
		s.DayKey = key
		return
	}
	if key == s.DayKey {
		return
	}
	switch {
	case s.DayIncidents > 0:
		s.CleanDayRun = 0
	case s.DayCoveredMillis >= odoCleanDayMinCoverage.Milliseconds():
		s.CleanDayRun++
		if s.CleanDayRun > s.BestCleanDayRun {
			s.BestCleanDayRun = s.CleanDayRun
		}
	}
	s.DayKey = key
	s.DayCoveredMillis = 0
	s.DayIncidents = 0
}

func (o *odometer) sampleTraffic() {
	up, down := o.traffic.TotalTraffic(false)
	if !o.trafficPrimed {
		o.trafficPrimed = true
		o.lastUp, o.lastDown = up, down
		return
	}
	if up < o.lastUp {
		o.lastUp = 0
	}
	if down < o.lastDown {
		o.lastDown = 0
	}
	o.state.UpBytes += up - o.lastUp
	o.state.DownBytes += down - o.lastDown
	o.lastUp, o.lastDown = up, down
}

func (o *odometer) Tick(now time.Time) {
	o.mu.Lock()
	defer o.mu.Unlock()
	if !o.loaded || !o.runtimeActive {
		return
	}
	o.accrue(now)
	o.rollDay(now)
	o.sampleTraffic()
	o.save(now, false)
}

func (o *odometer) startHeartbeat() {
	startOdometerHeartbeat()
}

func (o *odometer) mutate(mutate func(s *odoState)) {
	now := o.now()
	o.mu.Lock()
	defer o.mu.Unlock()
	o.ensureLoaded(now)
	mutate(o.state)
	o.save(now, !o.runtimeActive)
}

func (o *odometer) Flush() {
	o.mu.Lock()
	defer o.mu.Unlock()
	o.save(o.now(), true)
}

func (o *odometer) NoteExam(healthy bool) {
	o.mutate(func(s *odoState) {
		s.Exams++
		if healthy {
			s.ExamsClean++
			return
		}
		s.DayIncidents++
	})
}

func (o *odometer) NoteAutoDecision() {
	o.mutate(func(s *odoState) {
		s.AutoDecisions++
	})
}

func (o *odometer) NoteCountry(country string) {
	o.mutate(func(s *odoState) {
		odoAddCountry(s, country)
	})
}

func (o *odometer) NoteManualSwitch(now time.Time) {
	o.mutate(func(s *odoState) {
		s.ManualSwitches++
		s.LastManualMillis = now.UnixMilli()
	})
}

func (o *odometer) NoteRecovery() {
	o.mutate(func(s *odoState) {
		s.Recoveries++
		s.DayIncidents++
	})
}

func (o *odometer) NoteLadder(step int, completed bool) {
	o.mutate(func(s *odoState) {
		if step > s.LadderTop {
			s.LadderTop = step
		}
		if completed && step > 0 {
			s.LadderCompleted = true
		}
	})
}

func odoAddCountry(s *odoState, country string) {
	if len(country) != 2 || len(s.Countries) >= odoMaxCountries {
		return
	}
	index := sort.SearchStrings(s.Countries, country)
	if index < len(s.Countries) && s.Countries[index] == country {
		return
	}
	s.Countries = append(s.Countries, "")
	copy(s.Countries[index+1:], s.Countries[index:])
	s.Countries[index] = country
}

func (o *odometer) Report() odoReport {
	now := o.now()
	o.mu.Lock()
	defer o.mu.Unlock()
	o.ensureLoaded(now)
	if o.runtimeActive {
		o.accrue(now)
		o.rollDay(now)
	}
	s := o.state
	quiet := int64(0)
	if s.LastManualMillis > 0 {
		quiet = now.UnixMilli() - s.LastManualMillis
	} else if s.FirstRunMillis > 0 {
		quiet = now.UnixMilli() - s.FirstRunMillis
	}
	if quiet < 0 {
		quiet = 0
	}
	return odoReport{
		FirstRunMillis:     s.FirstRunMillis,
		StreakMillis:       s.StreakCoveredMillis,
		BestStreakMillis:   s.BestStreakMillis,
		TotalCoveredMillis: s.TotalCoveredMillis,
		StitchCount:        s.StitchCount,
		Sessions:           s.Sessions,
		UpBytes:            s.UpBytes,
		DownBytes:          s.DownBytes,
		Exams:              s.Exams,
		ExamsClean:         s.ExamsClean,
		AutoDecisions:      s.AutoDecisions,
		ManualSwitches:     s.ManualSwitches,
		QuietManualMillis:  quiet,
		LadderTop:          s.LadderTop,
		LadderCompleted:    s.LadderCompleted,
		Countries:          append([]string{}, s.Countries...),
		Recoveries:         s.Recoveries,
		CleanDayRun:        s.CleanDayRun,
		BestCleanDayRun:    s.BestCleanDayRun,
	}
}
