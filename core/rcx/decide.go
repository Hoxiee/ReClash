package rcx

import (
	"cmp"
	"slices"
	"time"
)

const (
	ChangeCooldown   = 15 * time.Minute
	betterTierFresh  = 5 * time.Minute
	stabilityPenalty = 300
	episodePenalty   = 50
	unmeasuredScore  = 1 << 20
	needsPerDecision = 2
)

// Node is what the runtime reports about one member of a group.
type Node struct {
	Name     string `json:"name"`
	Provider string `json:"provider,omitempty"`
	Type     string `json:"type"`
	UDP      bool   `json:"udp"`
	Server   string `json:"-"`
	Strong   string `json:"-"`
	Endpoint string `json:"-"`
	// Entry is the country of the node's server address, when it is an IP.
	Entry string `json:"-"`
	// NameCountry is the country the name declares (CountryOfName).
	NameCountry string `json:"-"`
	// Via lists the nested selectors between the group and the node, which
	// must all be set for the group to use it.
	Via []string `json:"-"`
}

type ControlMode string

const (
	AutoMode   ControlMode = "auto"
	PinnedMode ControlMode = "pinned"
	ManualMode ControlMode = "manual"
)

type Control struct {
	Mode    ControlMode `json:"mode"`
	Pin     string      `json:"pin,omitempty"`
	PinName string      `json:"pinName,omitempty"`
	PinEnv  string      `json:"pinEnv,omitempty"`
}

// Member is one candidate as Decide sees it.
type Member struct {
	Node
	Key   string
	Facts *Facts
	Exit  *ExitFact
}

type DecideInput struct {
	Policy       *Policy
	Members      []Member
	Now          string
	Control      Control
	Env          string
	Excluded     map[string]time.Time
	LastSwitch   time.Time
	SwitchesHour int
	Freshness    time.Duration
	At           time.Time
	ForceSwitch  bool
	Net          *NetSubject
	// Paused: the network kind says nothing should be judged now.
	Paused bool
}

type Action string

const (
	HoldAction     Action = "hold"
	SwitchAction   Action = "switch"
	StrandedAction Action = "stranded"
	ManualAction   Action = "manual"
)

// Reason is a code the host renders as a sentence, with its arguments.
type Reason struct {
	Code string         `json:"code"`
	Args map[string]any `json:"args,omitempty"`
}

func reason(code string, args ...any) Reason {
	r := Reason{Code: code}
	for i := 0; i+1 < len(args); i += 2 {
		if r.Args == nil {
			r.Args = map[string]any{}
		}
		r.Args[args[i].(string)] = args[i+1]
	}
	return r
}

type Health string

const (
	AliveHealth   Health = "alive"
	StaleHealth   Health = "stale"
	UnknownHealth Health = "unknown"
	DeadHealth    Health = "dead"
)

// Ranked is one row of the explanation. Rows are in decision order: the first
// eligible row is the best candidate.
type Ranked struct {
	Name      string    `json:"name"`
	Tier      int       `json:"tier"`
	TierLabel string    `json:"tierLabel,omitempty"`
	Health    Health    `json:"health"`
	LatencyMs int       `json:"latencyMs,omitempty"`
	SpreadMs  int       `json:"spreadMs,omitempty"`
	Score     int       `json:"score"`
	Episodes  int       `json:"episodes,omitempty"`
	CheckedAt time.Time `json:"checkedAt,omitzero"`
	Current   bool      `json:"current,omitempty"`
	Excluded  *Reason   `json:"excluded,omitempty"`
	Exit      string    `json:"exit,omitempty"`
	// Checks maps each declared check to pass, fail or soft; unknown ones
	// are absent.
	Checks map[string]string `json:"checks,omitempty"`
	// Pending names a better tier the node may reach once checked.
	Pending     string `json:"pending,omitempty"`
	pendingTier int
	key         string
}

type Decision struct {
	Action  Action   `json:"action"`
	Target  string   `json:"target,omitempty"`
	Reason  Reason   `json:"reason"`
	Tier    string   `json:"tier,omitempty"`
	Until   *Reason  `json:"until,omitempty"`
	Ranking []Ranked `json:"ranking,omitempty"`
	// Needs lists nodes whose fresh check could change the decision; the
	// planner turns them into probes.
	Needs []string `json:"-"`
}

// Decide is pure: the same input always gives the same decision, and the
// ranking it returns is the one it decided on.
func Decide(in DecideInput) Decision {
	p := in.Policy
	if in.Control.Mode == ManualMode {
		return Decision{Action: ManualAction, Target: in.Now, Reason: reason("manual")}
	}
	// A pin is the user's word, so it still beats the scenario's fixed member.
	if p.Fixed != "" && in.Control.Mode != PinnedMode {
		return decideFixed(in)
	}
	rows, byName := rank(in)
	current, hasCurrent := byName[in.Now]
	var best *Ranked
	for i := range rows {
		if rows[i].Excluded == nil {
			best = &rows[i]
			break
		}
	}
	d := Decision{Ranking: rows}
	if in.Paused {
		d.Action, d.Target, d.Reason = HoldAction, in.Now, reason("hold.paused", "kind", in.Net.kind())
		if hasCurrent {
			d.Tier = current.TierLabel
		}
		return d
	}
	d.Needs = pendingNeeds(rows, best, len(p.Tiers))

	if in.Control.Mode == PinnedMode {
		if pin, ok := byName[in.Control.PinName]; ok && pin.Health != DeadHealth && pin.Excluded == nil {
			if in.Now == pin.Name {
				d.Action, d.Target, d.Reason = HoldAction, pin.Name, reason("hold.pinned")
			} else {
				d.Action, d.Target, d.Reason = SwitchAction, pin.Name, reason("switch.pinned", "node", pin.Name)
			}
			d.Tier = pin.TierLabel
			return d
		}
		d.Needs = append(d.Needs, in.Control.PinName)
	}

	if best == nil && hasCurrent && current.Excluded != nil && current.Excluded.Code == "cooldown" {
		d.Action, d.Target, d.Reason = HoldAction, in.Now, reason("hold.no-alternative")
		return d
	}
	if best == nil {
		d.Action, d.Target = StrandedAction, in.Now
		d.Reason = reason("stranded.no-candidates")
		if target := strandedTarget(p.Stranded, in.Members); target != "" && target != in.Now {
			d.Action, d.Target = SwitchAction, target
			d.Reason = reason("switch.stranded", "node", target)
		}
		return d
	}
	pinDown := in.Control.Mode == PinnedMode
	switchTo := func(code string, args ...any) Decision {
		d.Action, d.Target, d.Tier = SwitchAction, best.Name, best.TierLabel
		if pinDown {
			args = append(args, "pin", in.Control.PinName)
		}
		d.Reason = reason(code, args...)
		return d
	}
	hold := func(code string, args ...any) Decision {
		d.Action, d.Target, d.Tier = HoldAction, in.Now, current.TierLabel
		d.Reason = reason(code, args...)
		return d
	}

	switch {
	case !hasCurrent:
		return switchTo("switch.initial")
	case in.ForceSwitch && best.Name != in.Now:
		return switchTo("switch.change-server", "from", in.Now)
	case current.Health == DeadHealth:
		return switchTo("switch.failover", "from", in.Now)
	case current.Excluded != nil && current.Excluded.Code != "cooldown":
		return switchTo("switch.out-of-pool", "from", in.Now, "why", current.Excluded.Code)
	case current.Excluded != nil:
		// Only "Change server" puts the current node on cooldown, and it switches
		// at once, so an incumbent on cooldown here had no better candidate.
		return hold("hold.no-alternative")
	case best.Name == in.Now:
		return hold("hold.best")
	}

	if best.Tier < current.Tier {
		if in.At.Sub(best.CheckedAt) <= betterTierFresh && best.Health == AliveHealth {
			return switchTo("switch.better-tier", "tier", best.TierLabel)
		}
		d.Needs = append(d.Needs, best.Name)
		u := reason("until.check-better-tier", "node", best.Name, "tier", best.TierLabel)
		d = hold("hold.checking")
		d.Until = &u
		return d
	}
	if !p.Improve {
		return hold("hold.working")
	}
	if !current.measured() || !best.measured() {
		return hold("hold.best")
	}
	gain := current.Score - best.Score
	need := max(p.MinGainMs, current.Score*p.MinGainPct/100, p.Tolerance)
	if gain < need {
		return hold("hold.best")
	}
	if wait := p.Dwell - in.At.Sub(in.LastSwitch); wait > 0 {
		d = hold("hold.dwell")
		u := reason("until.dwell", "node", best.Name, "seconds", int(wait.Seconds()), "gainMs", gain)
		d.Until = &u
		return d
	}
	if in.SwitchesHour >= p.MaxPerHour {
		d = hold("hold.flap-limit", "limit", p.MaxPerHour)
		return d
	}
	if confirmed(best, in, p, current.Score-need) < p.Confirm {
		d.Needs = append(d.Needs, best.Name)
		d = hold("hold.confirming")
		u := reason("until.confirm", "node", best.Name, "gainMs", gain)
		d.Until = &u
		return d
	}
	return switchTo("switch.faster", "from", in.Now, "gainMs", gain)
}

func decideFixed(in DecideInput) Decision {
	fixed := in.Policy.Fixed
	switch {
	case in.Now == fixed:
		return Decision{Action: HoldAction, Target: fixed, Reason: reason("hold.fixed", "node", fixed)}
	case slices.ContainsFunc(in.Members, func(m Member) bool { return m.Name == fixed }):
		return Decision{Action: SwitchAction, Target: fixed, Reason: reason("switch.fixed", "node", fixed)}
	}
	return Decision{Action: StrandedAction, Target: in.Now, Reason: reason("fixed.missing", "node", fixed)}
}

func (r *Ranked) measured() bool { return r.Score < unmeasuredScore }

// pendingNeeds picks the nodes whose unknown checks could lift them above the
// best candidate: checking them is what can change the decision.
func pendingNeeds(rows []Ranked, best *Ranked, tiers int) []string {
	bar := tiers
	if best != nil {
		bar = best.Tier
	}
	var picks []*Ranked
	for i := range rows {
		row := &rows[i]
		if row.pendingTier < 0 || row.pendingTier >= bar || row.Health == DeadHealth {
			continue
		}
		if row.Excluded != nil && row.Excluded.Code != "pending" {
			continue
		}
		picks = append(picks, row)
	}
	slices.SortStableFunc(picks, func(a, b *Ranked) int { return cmp.Compare(a.pendingTier, b.pendingTier) })
	var names []string
	for _, row := range picks[:min(len(picks), needsPerDecision)] {
		names = append(names, row.Name)
	}
	return names
}

// confirmed counts the candidate's recent samples that beat the bar, so one
// lucky measurement never moves the group.
func confirmed(best *Ranked, in DecideInput, p *Policy, bar int) int {
	for _, m := range in.Members {
		if m.Name != best.Name || m.Facts == nil {
			continue
		}
		count := 0
		for i := len(m.Facts.Samples) - 1; i >= 0 && count < p.Confirm; i-- {
			s := m.Facts.Samples[i]
			if s.Ms <= 0 || s.Ms > bar || in.At.Sub(s.At) > in.Freshness {
				break
			}
			count++
		}
		return count
	}
	return 0
}

func strandedTarget(stranded string, members []Member) string {
	want := ""
	switch {
	case stranded == "direct":
		want = "DIRECT"
	case len(stranded) > len("group:") && stranded[:len("group:")] == "group:":
		want = stranded[len("group:"):]
	default:
		return ""
	}
	for _, m := range members {
		if m.Name == want {
			return want
		}
	}
	return ""
}

func rank(in DecideInput) ([]Ranked, map[string]*Ranked) {
	p := in.Policy
	rows := make([]Ranked, 0, len(in.Members))
	for _, m := range in.Members {
		facts := m.Facts
		if facts == nil {
			facts = &Facts{}
		}
		subject := subjectOf(m, facts, in)
		for _, tag := range p.Tags {
			if tag.Cond.Eval(&subject) {
				if subject.Tags == nil {
					subject.Tags = map[string]bool{}
				}
				subject.Tags[tag.Name] = true
			}
		}
		row := Ranked{Name: m.Name, Tier: len(p.Tiers), Current: m.Name == in.Now, key: m.Key, CheckedAt: facts.LastSampleAt(), pendingTier: -1}
		row.Exit = subject.Exit
		for id, v := range subject.Checks {
			if label := verdictLabels[v]; label != "" {
				if row.Checks == nil {
					row.Checks = map[string]string{}
				}
				row.Checks[id] = label
			}
		}
		row.Health = healthOf(facts, in)
		row.Episodes = facts.RecentEpisodes(in.At)
		if p50, spread, ok := facts.Latency(in.At); ok {
			row.LatencyMs, row.SpreadMs = p50, spread
		}
		row.Score = score(row, p)
		// A pool rule over a fact not yet known admits the node; the check
		// that settles it rides along with its next probe.
		switch {
		case p.Include.Test(&subject) == triNo:
			row.Excluded = &Reason{Code: "pool.no-match"}
		case p.Exclude != nil && p.Exclude.Eval(&subject):
			row.Excluded = &Reason{Code: "pool.excluded"}
		case isUnroutable(m.Type):
			row.Excluded = &Reason{Code: "pool.unroutable"}
		}
		if until, ok := in.Excluded[m.Key]; ok && until.After(in.At) && row.Excluded == nil {
			r := reason("cooldown", "until", until)
			row.Excluded = &r
		}
		if row.Excluded == nil && row.Health == DeadHealth {
			row.Excluded = &Reason{Code: "dead"}
		}
		if row.Excluded == nil {
			row.Tier = -1
			for i, tier := range p.Tiers {
				v := tier.When.Test(&subject)
				if v == triYes {
					row.Tier, row.TierLabel = i, tier.Label
					break
				}
				if v == triUnknown && row.pendingTier < 0 {
					row.pendingTier, row.Pending = i, tier.Label
				}
			}
			switch {
			case row.Tier < 0 && row.pendingTier >= 0:
				row.Tier = len(p.Tiers)
				row.Excluded = &Reason{Code: "pending"}
			case row.Tier < 0:
				row.Tier = len(p.Tiers)
				row.Excluded = &Reason{Code: "no-tier"}
			}
		}
		rows = append(rows, row)
	}
	healthOrder := map[Health]int{AliveHealth: 0, StaleHealth: 1, UnknownHealth: 2, DeadHealth: 3}
	slices.SortStableFunc(rows, func(a, b Ranked) int {
		if (a.Excluded == nil) != (b.Excluded == nil) {
			if a.Excluded == nil {
				return -1
			}
			return 1
		}
		if c := cmp.Compare(a.Tier, b.Tier); c != 0 {
			return c
		}
		if c := cmp.Compare(healthOrder[a.Health], healthOrder[b.Health]); c != 0 {
			return c
		}
		if c := cmp.Compare(effectiveScore(a, p), effectiveScore(b, p)); c != 0 {
			return c
		}
		return cmp.Compare(a.Name, b.Name)
	})
	byName := make(map[string]*Ranked, len(rows))
	for i := range rows {
		byName[rows[i].Name] = &rows[i]
	}
	return rows, byName
}

func (n *NetSubject) kind() string {
	if n == nil {
		return ""
	}
	return n.Kind
}

var verdictLabels = map[tri]string{triYes: "pass", triNo: "fail", triNeither: "soft"}

func subjectOf(m Member, facts *Facts, in DecideInput) Subject {
	p50, _, measured := facts.Latency(in.At)
	exit := m.Exit.country(in.At)
	var checks map[string]tri
	if ids := in.Policy.CheckIDs; len(ids) > 0 {
		checks = make(map[string]tri, len(ids))
		for _, id := range ids {
			checks[id] = facts.Checks[id].verdict(in.At)
		}
	}
	return Subject{
		Exit:     exit,
		Country:  cmp.Or(exit, m.NameCountry),
		Entry:    m.Entry,
		Checks:   checks,
		Net:      in.Net,
		Name:     m.Name,
		Provider: m.Provider,
		Type:     m.Type,
		Server:   m.Server,
		UDP:      m.UDP,
		Alive:    facts.AliveSince(in.At.Add(-in.Freshness)),
		Dead:     facts.Dead(),
		Measured: measured,
		Current:  m.Name == in.Now,
		Latency:  p50,
	}
}

func healthOf(f *Facts, in DecideInput) Health {
	switch {
	case f.Dead():
		return DeadHealth
	case f.AliveSince(in.At.Add(-in.Freshness)):
		return AliveHealth
	case !f.OKAt.IsZero():
		return StaleHealth
	default:
		return UnknownHealth
	}
}

// The current node is credited the tolerance, so a challenger must beat it by
// more than that to rank first; the order stays transitive.
func effectiveScore(row Ranked, p *Policy) int {
	if row.Current && row.measured() {
		return row.Score - p.Tolerance
	}
	return row.Score
}

func score(row Ranked, p *Policy) int {
	if row.LatencyMs == 0 {
		return unmeasuredScore
	}
	if p.RankBy == "stability" {
		return row.LatencyMs + row.SpreadMs + row.Episodes*stabilityPenalty
	}
	return row.LatencyMs + row.SpreadMs/2 + row.Episodes*episodePenalty
}

func isUnroutable(adapterType string) bool {
	switch adapterType {
	case "Reject", "RejectDrop", "Pass", "Compatible", "Direct", "Dns":
		return true
	}
	return false
}
