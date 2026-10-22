package rcx

import (
	"cmp"
	"maps"
	"slices"
	"time"
)

type Status struct {
	Running  bool          `json:"running"`
	Mode     Mode          `json:"mode"`
	Network  string        `json:"network"`
	Groups   []GroupStatus `json:"groups"`
	Energy   EnergyStatus  `json:"energy"`
	Problems []Reason      `json:"problems,omitempty"`
	// Split names the group DIRECT rules go through now, if any.
	Split string `json:"split,omitempty"`
	// Library changes whenever the profile library is rebuilt, so the UI
	// knows when to ask for it again.
	Library  uint64          `json:"library"`
	Scenario *ScenarioStatus `json:"scenario,omitempty"`
	// TunnelMode is the mode in force: the scenario's, else the user's.
	TunnelMode string `json:"tunnelMode"`
}

// ScenarioStatus is the auto control in force. Mode is what it holds on
// this network, empty when it leaves the mode to the user.
type ScenarioStatus struct {
	ID      string        `json:"id"`
	Title   string        `json:"title"`
	Source  string        `json:"source"`
	Problem *Reason       `json:"problem,omitempty"`
	Network *GroupNetwork `json:"network,omitempty"`
	Mode    string        `json:"mode,omitempty"`
	Manual  bool          `json:"manual,omitempty"`
	// HoldsMode: the scenario sets the mode on some network, so the mode
	// switch offers Auto.
	HoldsMode bool `json:"holdsMode,omitempty"`
	// Groups maps each group it names now to the key that named it
	// ($main, * or the group's name).
	Groups map[string]string `json:"groups,omitempty"`
}

type GroupStatus struct {
	Name         string   `json:"name"`
	Source       string   `json:"source"`
	Profile      string   `json:"profile"`
	ProfileTitle string   `json:"profileTitle"`
	Level        string   `json:"level"`
	Offered      []string `json:"offered,omitempty"`
	Binding      Binding  `json:"binding"`
	// Program is the scenario key that names the group now, if any;
	// Fixed the member it holds the group on.
	Program      string         `json:"program,omitempty"`
	Fixed        string         `json:"fixed,omitempty"`
	Idle         bool           `json:"idle,omitempty"`
	Control      Control        `json:"control"`
	Now          string         `json:"now"`
	Via          []string       `json:"via,omitempty"`
	Decision     Decision       `json:"decision"`
	Problem      *Reason        `json:"problem,omitempty"`
	Members      int            `json:"members"`
	Candidates   int            `json:"candidates"`
	Excluded     []ExcludedNode `json:"excluded,omitempty"`
	SwitchesHour int            `json:"switchesHour"`
	MaxPerHour   int            `json:"maxPerHour"`
	Improve      bool           `json:"improve"`
	Health       map[Health]int `json:"health,omitempty"`
	Current      *CurrentNode   `json:"current,omitempty"`
	Network      *GroupNetwork  `json:"network,omitempty"`
	// DirectSplit is empty when the profile cannot split, else off,
	// standby or active.
	DirectSplit string `json:"directSplit,omitempty"`
}

// GroupNetwork is the kind the group's profile sees the network as. Kind is
// empty until the diagnostics decide; Next is a kind awaiting confirmation.
type GroupNetwork struct {
	Kind   string   `json:"kind,omitempty"`
	Next   string   `json:"next,omitempty"`
	Paused bool     `json:"paused,omitempty"`
	Kinds  []string `json:"kinds"`
}

type CurrentNode struct {
	Name      string    `json:"name"`
	LatencyMs int       `json:"latencyMs,omitempty"`
	Health    Health    `json:"health"`
	Since     time.Time `json:"since,omitzero"`
	Exit      string    `json:"exit,omitempty"`
}

type ExcludedNode struct {
	Name  string    `json:"name"`
	Until time.Time `json:"until"`
}

type EnergyStatus struct {
	Level        string         `json:"level"`
	Day          string         `json:"day"`
	Requests     int            `json:"requests"`
	Bytes        int64          `json:"bytes"`
	CapBytes     int64          `json:"capBytes"`
	ByBucket     map[Bucket]int `json:"byBucket,omitempty"`
	HourlyLimits map[Bucket]int `json:"hourlyLimits"`
}

// Explanation answers "why this server": the decision with every member's
// row, in the order the decision used.
type Explanation struct {
	Group     string    `json:"group"`
	Profile   string    `json:"profile"`
	Decision  Decision  `json:"decision"`
	Freshness int       `json:"freshnessSeconds"`
	At        time.Time `json:"at"`
}

func (m *machine) levelName() string {
	level := m.level()
	for name, l := range energyLevels {
		if l.rank == level.rank {
			return name
		}
	}
	return "balanced"
}

func (m *machine) status(now time.Time) Status {
	mode := m.mode(now)
	// The activity window opens and closes with every burst of traffic; the
	// host only needs to know that checks are allowed.
	if mode == ActiveMode || mode == IdleMode {
		mode = NormalMode
	}
	level := m.level()
	day := m.budget.day
	if day.Day != now.Format(time.DateOnly) {
		day = EnergyDay{Day: now.Format(time.DateOnly)}
	}
	s := Status{
		Running: m.running,
		Mode:    mode,
		Network: m.envLabel,
		Groups:  []GroupStatus{},
		Library: m.libraryGen,
		Energy: EnergyStatus{
			Level:    m.levelName(),
			Day:      day.Day,
			Requests: day.Requests,
			Bytes:    day.Bytes,
			CapBytes: dailyCapBytes,
			ByBucket: maps.Clone(day.ByBucket),
			HourlyLimits: map[Bucket]int{
				MaintainBucket: int(level.maintain),
				DiscoverBucket: int(level.discover),
				RecoverBucket:  int(level.recover),
				NetworkBucket:  int(level.network),
			},
		},
		Split:      m.split,
		TunnelMode: m.tunnelMode(),
	}
	if m.scn.id != "" {
		scn := &ScenarioStatus{ID: m.scn.id, Title: m.scn.id, Problem: m.scn.problem, Groups: m.scn.groups, Manual: m.user.ManualMode}
		if info, ok := m.library.ScenarioInfo(m.scn.id); ok {
			scn.Title, scn.Source = info.Title, info.Source
		}
		if c := m.scn.c; c != nil {
			scn.Mode = c.modeFor(m.scn.kind)
			scn.HoldsMode = c.holdsMode()
			if len(c.kinds()) > 0 {
				scn.Network = &GroupNetwork{Kind: m.scn.kind, Next: m.scn.kindNext}
				for _, rule := range c.kinds() {
					scn.Network.Kinds = append(scn.Network.Kinds, rule.Kind)
				}
			}
		}
		s.Scenario = scn
	}
	for _, name := range m.order {
		g := m.groups[name]
		ctl := m.controls[name]
		gs := GroupStatus{
			Name:         name,
			Source:       g.source,
			Profile:      g.profileID,
			Offered:      g.offered,
			Binding:      g.binding,
			Control:      ctl.Control,
			Now:          g.now,
			Via:          g.via(g.now),
			Decision:     g.decision,
			Problem:      g.problem,
			Program:      g.program,
			Idle:         m.idle(g),
			Members:      len(g.members),
			SwitchesHour: ctl.switchesSince(now.Add(-time.Hour)),
			Health:       map[Health]int{},
		}
		gs.Decision.Ranking = nil
		if g.policy != nil {
			active := g.active()
			gs.Level = g.policy.Level
			if info, ok := m.library.Info(g.profileID); ok {
				gs.ProfileTitle, gs.Level = info.Title, cmp.Or(info.Level, gs.Level)
			}
			gs.MaxPerHour, gs.Improve = active.MaxPerHour, active.Improve
			gs.Fixed = active.Fixed
			gs.DirectSplit = m.splitState(g, now)
			if len(g.policy.Kinds) > 0 {
				gs.Network = &GroupNetwork{Kind: g.kind, Next: g.kindNext, Paused: m.paused(g)}
				for _, rule := range g.policy.Kinds {
					gs.Network.Kinds = append(gs.Network.Kinds, rule.Kind)
				}
			}
		}
		for _, row := range g.decision.Ranking {
			if row.Excluded == nil {
				gs.Candidates++
			}
			gs.Health[row.Health]++
			if row.Name == g.now {
				gs.Current = &CurrentNode{Name: row.Name, LatencyMs: row.LatencyMs, Health: row.Health, Since: ctl.LastSwitch, Exit: row.Exit}
			}
		}
		for _, key := range slices.Sorted(maps.Keys(ctl.Excluded)) {
			for _, nodeName := range m.keyNames[key] {
				if _, inGroup := g.byName[nodeName]; inGroup {
					gs.Excluded = append(gs.Excluded, ExcludedNode{Name: nodeName, Until: ctl.Excluded[key]})
				}
			}
		}
		s.Groups = append(s.Groups, gs)
	}
	return s
}
