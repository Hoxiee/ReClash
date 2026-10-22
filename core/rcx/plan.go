package rcx

import (
	"slices"
	"time"
)

const (
	probeConcurrency  = 2
	probeTimeout      = 5 * time.Second
	probeRepeatGap    = time.Minute
	probeCostBytes    = 6 << 10
	dailyCapBytes     = 20 << 20
	trafficWindow     = 10 * time.Second
	networkWindow     = 30 * time.Second
	wakeDebounce      = 10 * time.Second
	recoverPassSize   = 4
	maintainStandbys  = 2
	discoverPerWindow = 2
	linkWindow        = time.Minute
	diagConfirmGap    = 45 * time.Second
	kindRounds        = 2
)

// After a network change the diagnostics settle: a confirming round, then
// ever rarer rounds while the user is active.
var diagBackoff = []time.Duration{5 * time.Minute, 10 * time.Minute, 30 * time.Minute}

var recoverBackoff = []time.Duration{0, 5 * time.Minute, 10 * time.Minute, 20 * time.Minute, 40 * time.Minute}

type Bucket string

const (
	MaintainBucket Bucket = "maintain"
	DiscoverBucket Bucket = "discover"
	RecoverBucket  Bucket = "recover"
	NetworkBucket  Bucket = "network"
	UserBucket     Bucket = "user"
)

type energyLevel struct {
	rank         int
	maintain     float64
	discover     float64
	recover      float64
	network      float64
	standbyEvery time.Duration
}

// Hourly request allowances. The recover bucket has its own cap so a dead
// network cannot spend the day's budget; user actions are never rationed.
var energyLevels = map[string]energyLevel{
	"eco":      {rank: 0, maintain: 4, discover: 0, recover: 12, network: 8, standbyEvery: 2 * time.Hour},
	"balanced": {rank: 1, maintain: 10, discover: 12, recover: 24, network: 12, standbyEvery: 45 * time.Minute},
	"precise":  {rank: 2, maintain: 20, discover: 40, recover: 40, network: 20, standbyEvery: 30 * time.Minute},
}

type Hints struct {
	Screen     *bool        `json:"screen,omitempty"`
	Foreground *bool        `json:"foreground,omitempty"`
	Doze       *bool        `json:"doze,omitempty"`
	PowerSave  *bool        `json:"powerSave,omitempty"`
	Metered    *bool        `json:"metered,omitempty"`
	BatteryLow *bool        `json:"batteryLow,omitempty"`
	OnBattery  *bool        `json:"onBattery,omitempty"`
	Network    *NetworkHint `json:"network,omitempty"`
	// Resumed is an event, not a state: the device just woke from sleep.
	Resumed bool `json:"resumed,omitempty"`
}

// NetworkHint identifies the network. ID (SSID, carrier, gateway) is hashed
// with the install salt on arrival and never stored as given.
type NetworkHint struct {
	Transport string `json:"transport"`
	ID        string `json:"id,omitempty"`
	Portal    bool   `json:"portal,omitempty"`
}

type Power struct {
	Screen     bool `json:"screen"`
	Foreground bool `json:"foreground"`
	Doze       bool `json:"doze"`
	PowerSave  bool `json:"powerSave"`
	Metered    bool `json:"metered"`
	BatteryLow bool `json:"batteryLow"`
	OnBattery  bool `json:"onBattery"`
}

func (p *Power) apply(h Hints) {
	set := func(target *bool, value *bool) {
		if value != nil {
			*target = *value
		}
	}
	set(&p.Screen, h.Screen)
	set(&p.Foreground, h.Foreground)
	set(&p.Doze, h.Doze)
	set(&p.PowerSave, h.PowerSave)
	set(&p.Metered, h.Metered)
	set(&p.BatteryLow, h.BatteryLow)
	set(&p.OnBattery, h.OnBattery)
}

// Modes from most to least allowed: active may improve the choice, eco keeps
// standbys rarely, background reacts only to real failures, sleep does nothing.
type Mode string

const (
	ActiveMode     Mode = "active"
	IdleMode       Mode = "idle"
	EcoMode        Mode = "eco"
	BackgroundMode Mode = "background"
	SleepMode      Mode = "sleep"
	StoppedMode    Mode = "stopped"
	NormalMode     Mode = "normal"
)

func (p Power) eco() bool { return p.Metered || p.PowerSave || p.BatteryLow || p.OnBattery }

type tokenBucket struct {
	Tokens float64   `json:"tokens"`
	At     time.Time `json:"at"`
}

func (b *tokenBucket) take(rate float64, now time.Time) bool {
	if rate <= 0 {
		return false
	}
	if !b.At.IsZero() {
		b.Tokens += now.Sub(b.At).Hours() * rate
	} else {
		b.Tokens = rate
	}
	b.Tokens = min(b.Tokens, rate)
	b.At = now
	if b.Tokens < 1 {
		return false
	}
	b.Tokens--
	return true
}

type EnergyDay struct {
	Day      string         `json:"day"`
	Requests int            `json:"requests"`
	Bytes    int64          `json:"bytes"`
	ByBucket map[Bucket]int `json:"byBucket,omitempty"`
}

type probeJob struct {
	Group  string
	Node   string
	Key    string
	Bucket Bucket
	Kind   string
	// Checks and Exit ride along with the probe and run only if it succeeds:
	// a check through an unreachable node says nothing about the check.
	Checks map[string]Check
	Exit   *Egress
	// Targets makes it a direct network diagnosis rather than a node probe.
	Targets []Target
	Env     string
}

// probeResult is everything one job learned.
type probeResult struct {
	Ms     int
	Failed bool
	Checks map[string]bool
	Votes  []ExitVote
	Diag   map[string]bool
	// Requests counts what the extras actually sent beyond the first.
	Requests int
}

type budget struct {
	buckets map[Bucket]*tokenBucket
	day     EnergyDay
}

func (b *budget) rate(bucket Bucket, level energyLevel) float64 {
	switch bucket {
	case MaintainBucket:
		return level.maintain
	case DiscoverBucket:
		return level.discover
	case RecoverBucket:
		return level.recover
	case NetworkBucket:
		return level.network
	default:
		return 1 << 20
	}
}

// spend takes one request from the bucket; past the daily byte cap only the
// user and failure recovery may still spend.
func (b *budget) spend(bucket Bucket, level energyLevel, now time.Time) bool {
	day := now.Format(time.DateOnly)
	if b.day.Day != day {
		b.day = EnergyDay{Day: day}
	}
	if b.day.Bytes >= dailyCapBytes && bucket != UserBucket && bucket != RecoverBucket {
		return false
	}
	if b.buckets == nil {
		b.buckets = map[Bucket]*tokenBucket{}
	}
	tb := b.buckets[bucket]
	if tb == nil {
		tb = &tokenBucket{}
		b.buckets[bucket] = tb
	}
	if bucket != UserBucket && !tb.take(b.rate(bucket, level), now) {
		return false
	}
	b.charge(bucket, 1)
	return true
}

// charge books requests already sent, such as echo services asked one by one
// until they agree.
func (b *budget) charge(bucket Bucket, requests int) {
	if requests <= 0 {
		return
	}
	b.day.Requests += requests
	b.day.Bytes += int64(requests) * probeCostBytes
	if b.day.ByBucket == nil {
		b.day.ByBucket = map[Bucket]int{}
	}
	b.day.ByBucket[bucket] += requests
}

func standbyOrder(d Decision) []Ranked {
	var out []Ranked
	for _, row := range d.Ranking {
		if row.Excluded == nil && !row.Current {
			out = append(out, row)
		}
	}
	return out
}

func discoverOrder(d Decision) []Ranked {
	var rows []Ranked
	for _, row := range d.Ranking {
		if row.Excluded == nil || row.Excluded.Code == "cooldown" || row.Excluded.Code == "pending" {
			rows = append(rows, row)
		}
	}
	slices.SortStableFunc(rows, func(a, b Ranked) int { return a.CheckedAt.Compare(b.CheckedAt) })
	return rows
}
