package rcx

import (
	"cmp"
	"crypto/rand"
	"errors"
	"maps"
	"slices"
	"time"
)

// Runtime is the engine's view of the core: selection, measurement and
// provider control. The core implements it over mihomo.
type Runtime interface {
	Select(group string, via []string, node string) error
	CloseConnections(group, node string)
	SuppressHealthChecks(providers []string)
	// ApplyMode sets the tunnel mode a scenario wants; empty gives it back
	// to the user's own.
	ApplyMode(mode string)
}

// GroupTopology is one select group of the active config.
type GroupTopology struct {
	Name    string
	Now     string
	Members []Node
}

type Topology struct {
	Groups       []GroupTopology
	Subscription SubscriptionLayer
	// Main is the select group the final MATCH rule routes to, if any.
	Main string
	// Providers maps each member name to the providers that serve it.
	Providers map[string][]string
}

type controlRecord struct {
	Control
	Excluded   map[string]time.Time `json:"excluded,omitempty"`
	Switches   []time.Time          `json:"switches,omitempty"`
	LastSwitch time.Time            `json:"lastSwitch,omitzero"`
}

type groupState struct {
	name      string
	source    string
	offered   []string
	binding   Binding
	profileID string
	policy    *Policy
	problem   *Reason
	members   []Member
	byName    map[string]int
	now       string
	decision  Decision
	force     bool

	suspect      bool
	confirm      *confirmation
	recoverPass  int
	recoverAt    time.Time
	recoverArmed bool
	maintainAt   time.Time

	kindState
	// program is the scenario's key for the group while it names it.
	program string
}

// kindState is the confirmed network kind; kindNext waits for kindRounds
// agreeing classifications before it replaces it.
type kindState struct {
	kind      string
	kindNext  string
	kindVotes int
	netSeq    int
}

// scenarioState is the active auto control; c is nil when it is off or
// cannot run.
type scenarioState struct {
	kindState
	id      string
	c       *compiledScenario
	problem *Reason
	// groups maps each group the scenario names now to its program key.
	groups      map[string]string
	appliedKind string
}

// active is the policy in force on the current network kind.
func (g *groupState) active() *Policy { return g.policy.forKind(g.kind) }

type machine struct {
	rt         Runtime
	libraryGen uint64
	salt       []byte
	ids        IdentityIndex
	evidence   Evidence
	controls   map[string]*controlRecord
	journal    journal
	budget     budget

	topology Topology
	user     UserLayer
	library  *Library
	scn      scenarioState
	// userMode is the tunnel mode the user set; modeWish the one the
	// scenario holds now, published to the runtime.
	userMode string
	modeWish string
	groups   map[string]*groupState
	order    []string
	keyNames map[string][]string

	running     bool
	power       Power
	envKey      string
	envLabel    string
	windowUntil time.Time
	wakeAt      time.Time
	transport   string
	portal      bool

	// netSeq counts new network inputs (a diagnosis, a hint); each group
	// classifies once per input, so a vote is never counted twice.
	netSeq     int
	diagNext   time.Time
	diagStep   int
	diagBusy   bool
	diagForced bool
	split      string

	inflight  map[string]probeJob
	lastProbe map[string]time.Time
	linkOKAt  time.Time

	dirty       bool
	statusDirty bool
}

func newMachine(rt Runtime) *machine {
	m := &machine{
		rt:        rt,
		controls:  map[string]*controlRecord{},
		groups:    map[string]*groupState{},
		inflight:  map[string]probeJob{},
		lastProbe: map[string]time.Time{},
		keyNames:  map[string][]string{},
		power:     Power{Screen: true},
		envKey:    "default",
		envLabel:  "default",
	}
	m.library = NewLibrary(SubscriptionLayer{}, UserLayer{})
	return m
}

func (m *machine) ensureSalt() {
	if len(m.salt) == 0 {
		m.salt = make([]byte, 32)
		_, _ = rand.Read(m.salt)
		m.dirty = true
	}
}

func (m *machine) env(now time.Time) *Environment {
	return m.evidence.env(m.envKey, now)
}

func (m *machine) level() energyLevel {
	best := energyLevels["eco"]
	for _, g := range m.groups {
		if g.policy == nil {
			continue
		}
		if level := energyLevels[g.policy.Energy]; level.rank > best.rank {
			best = level
		}
	}
	if m.power.eco() {
		return energyLevels["eco"]
	}
	return best
}

func (m *machine) mode(now time.Time) Mode {
	switch {
	case !m.running:
		return StoppedMode
	case m.power.Doze:
		return SleepMode
	case !m.power.Screen:
		return BackgroundMode
	case m.power.eco():
		return EcoMode
	case now.Before(m.windowUntil):
		return ActiveMode
	default:
		return IdleMode
	}
}

func (m *machine) openWindow(now time.Time, length time.Duration) {
	if until := now.Add(length); until.After(m.windowUntil) {
		m.windowUntil = until
	}
}

// rebuild recomputes every group from the topology and both layers. It runs
// on config, provider and user-layer changes only, never per tick, so HMACs
// and compiled policies are cached per generation.
func (m *machine) rebuild(now time.Time) {
	m.ensureSalt()
	m.library = NewLibrary(m.topology.Subscription, m.user)
	m.libraryGen++
	m.loadScenario(now)
	bound := map[string]Binding{}
	sources := map[string]string{}
	for name, b := range m.topology.Subscription.Groups {
		b.DirectSplit = false
		bound[name], sources[name] = b, SubscriptionSource
	}
	for name, b := range m.user.Groups {
		merged := bound[name]
		merged.Profile, merged.Pool, merged.Feel, merged.Energy = b.Profile, b.Pool, b.Feel, b.Energy
		merged.DirectSplit = b.DirectSplit
		merged.Chips = append(slices.Clip(merged.Chips), b.Chips...)
		if _, fromSub := sources[name]; !fromSub {
			sources[name] = UserSource
		}
		bound[name] = merged
	}
	topo := map[string]GroupTopology{}
	for _, g := range m.topology.Groups {
		topo[g.Name] = g
	}
	m.applyScenario(bound, sources)

	var all []Node
	for _, name := range slices.Sorted(maps.Keys(bound)) {
		if g, ok := topo[name]; ok {
			all = append(all, g.Members...)
		}
	}
	keys, _ := m.ids.Resolve(m.salt, all, now)
	m.evidence.prune(m.ids.Known())
	m.keyNames = map[string][]string{}

	previous := m.groups
	m.groups = map[string]*groupState{}
	m.order = m.order[:0]
	index := 0
	for _, name := range slices.Sorted(maps.Keys(bound)) {
		b := bound[name]
		g := previous[name]
		if g == nil {
			g = &groupState{name: name}
		}
		g.source, g.binding, g.offered = sources[name], b, b.Profiles
		g.program = m.scn.groups[name]
		g.problem = nil
		g.profileID = CanonicalID(b.Profile)
		if g.profileID == "" || !m.library.Has(g.profileID) {
			if b.Profile != "" {
				g.problem = &Reason{Code: "profile.missing", Args: map[string]any{"profile": b.Profile}}
			}
			g.profileID = CanonicalID(b.Default)
		}
		if g.profileID == "" || !m.library.Has(g.profileID) {
			g.profileID = DefaultProfile
		}
		policy, err := m.library.Compile(g.profileID, b)
		previousID := ""
		if g.policy != nil {
			previousID = g.policy.ID
		}
		var consent *ConsentError
		if errors.As(err, &consent) {
			// Until the user answers, the group still works on the profile
			// that contacts nobody.
			g.problem = &Reason{Code: "profile.consent", Args: map[string]any{"profile": g.profileID, "hosts": consent.Hosts}}
			policy, err = m.library.Compile(DefaultProfile, b)
		}
		if err != nil {
			g.policy = nil
			g.problem = &Reason{Code: "profile.invalid", Args: map[string]any{"profile": g.profileID, "error": err.Error()}}
		} else {
			g.policy = policy
		}
		if g.policy == nil || g.policy.ID != previousID {
			m.recallKind(g, now)
		}
		g.binding.Chips = usableChips(b.Chips, g.policy)
		t, exists := topo[name]
		g.members = g.members[:0]
		g.byName = map[string]int{}
		if !exists {
			g.problem = &Reason{Code: "group.unavailable", Args: map[string]any{"group": name}}
			g.now = ""
		} else {
			g.now = t.Now
			for range t.Members {
				node := all[index]
				member := Member{Node: node, Key: keys[index]}
				g.byName[node.Name] = len(g.members)
				g.members = append(g.members, member)
				m.keyNames[member.Key] = append(m.keyNames[member.Key], node.Name)
				index++
			}
			if len(g.members) == 0 {
				g.problem = &Reason{Code: "group.empty"}
			}
		}
		if m.controls[name] == nil {
			m.controls[name] = &controlRecord{Control: Control{Mode: AutoMode}}
		}
		m.groups[name] = g
		m.order = append(m.order, name)
	}
	m.suppressProviders()
	m.statusDirty, m.dirty = true, true
}

// loadScenario compiles the auto control the user picked, else the
// subscription's default; a scenario that cannot run leaves the groups on
// their own bindings and says why.
func (m *machine) loadScenario(now time.Time) {
	id := ""
	if !m.user.ScenarioOff {
		id = cmp.Or(CanonicalID(m.user.Scenario), CanonicalID(m.topology.Subscription.Scenario))
	}
	previous := m.scn.id
	m.scn.id, m.scn.c, m.scn.problem = id, nil, nil
	if id != previous {
		m.recall(&m.scn.kindState, scenarioKey(id), now)
	}
	if id == "" {
		return
	}
	c, err := m.library.CompileScenario(id)
	var consent *ConsentError
	switch {
	case errors.As(err, &consent):
		m.scn.problem = &Reason{Code: "profile.consent", Args: map[string]any{"profile": id, "hosts": consent.Hosts}}
	case err != nil:
		m.scn.problem = &Reason{Code: "profile.invalid", Args: map[string]any{"profile": id, "error": err.Error()}}
	default:
		m.scn.c = c
	}
}

// applyScenario lays the programs of the current network kind over the
// bindings: a profile replaces the group's own, a pool narrows it, a fixed
// member holds it.
func (m *machine) applyScenario(bound map[string]Binding, sources map[string]string) {
	m.scn.groups = map[string]string{}
	m.scn.appliedKind = m.scn.kind
	if m.scn.c == nil {
		return
	}
	names := make([]string, 0, len(m.topology.Groups))
	for _, g := range m.topology.Groups {
		names = append(names, g.Name)
	}
	for name, a := range m.scn.c.targets(m.scn.kind, names, m.topology.Main) {
		b := bound[name]
		if a.Profile != "" {
			b.Profile = a.Profile
		}
		b.fixed, b.extra, b.tags = a.To, a.Pool, m.scn.c.tags
		bound[name] = b
		if _, ok := sources[name]; !ok {
			sources[name] = "scenario"
		}
		m.scn.groups[name] = a.Key
	}
}

// applyMode publishes the tunnel mode the scenario holds on this network,
// unless the user took the mode over.
func (m *machine) applyMode(now time.Time) {
	wish := ""
	if m.scn.c != nil && !m.user.ManualMode {
		wish = m.scn.c.modeFor(m.scn.kind)
	}
	if wish == m.modeWish {
		return
	}
	from := m.tunnelMode()
	m.modeWish = wish
	if m.rt != nil {
		m.rt.ApplyMode(wish)
	}
	if to := m.tunnelMode(); to != from {
		m.journal.add(JournalEntry{At: now, Kind: "mode", From: from, To: to, Reason: reason("mode.scenario")})
		m.suppressProviders()
	}
	m.dirty, m.statusDirty = true, true
}

func (m *machine) tunnelMode() string { return cmp.Or(m.modeWish, m.userMode, "rule") }

// idle: the tunnel mode routes nothing through the group, so it is neither
// decided nor checked.
func (m *machine) idle(g *groupState) bool {
	switch m.tunnelMode() {
	case "global":
		return g.name != GlobalTarget
	case "direct":
		return true
	}
	return g.name == GlobalTarget
}

// suppressProviders hands the auto health check of every provider serving a
// smart group to the engine; other providers keep theirs.
func (m *machine) suppressProviders() {
	set := map[string]bool{}
	for _, g := range m.groups {
		if g.policy == nil || m.controls[g.name].Mode == ManualMode || m.idle(g) {
			continue
		}
		for _, member := range g.members {
			for _, provider := range m.topology.Providers[member.Name] {
				set[provider] = true
			}
		}
	}
	if m.rt != nil {
		m.rt.SuppressHealthChecks(slices.Sorted(maps.Keys(set)))
	}
}

func (m *machine) facts(key string, now time.Time) *Facts {
	return m.env(now).facts(key)
}

// recallKind starts a group on what this network was last confirmed to be,
// and asks for a fresh classification.
func (m *machine) recallKind(g *groupState, now time.Time) {
	id := ""
	if g.policy != nil {
		id = g.policy.ID
	}
	m.recall(&g.kindState, id, now)
}

func (m *machine) recall(ks *kindState, memory string, now time.Time) {
	*ks = kindState{netSeq: -1}
	if memory != "" {
		ks.kind = m.env(now).Kinds[memory]
	}
}

func (m *machine) netSubject(kind string, policy *Policy, now time.Time) *NetSubject {
	n := &NetSubject{Kind: kind, Transport: m.transport, Portal: m.portal, Metered: m.power.Metered}
	if len(policy.Diagnostics) > 0 {
		env := m.env(now)
		n.Diag = make(map[string]tri, len(policy.Diagnostics))
		for name, targets := range policy.Diagnostics {
			n.Diag[name] = env.diagnosis(targets)
		}
	}
	return n
}

// classify is first match over the profile's kinds; a kind behind a rule
// that cannot be evaluated yet stays undecided rather than guessed. Decided
// with no kind means no rule holds.
func (p *Policy) classify(n *NetSubject) (kind string, decided bool) {
	s := &Subject{Net: n}
	for _, rule := range p.Kinds {
		switch rule.When.Test(s) {
		case triYes:
			return rule.Kind, true
		case triUnknown:
			return "", false
		}
	}
	return "", true
}

func (m *machine) classify(g *groupState, now time.Time) {
	if g.policy != nil && m.classifyKind(&g.kindState, g.policy, g.policy.ID, g.name, now) {
		g.maintainAt = now
	}
}

// classifyKind counts one classification per network input and reports
// whether the confirmed kind changed; memory keys what this network is
// remembered as.
func (m *machine) classifyKind(ks *kindState, policy *Policy, memory, group string, now time.Time) bool {
	if len(policy.Kinds) == 0 || ks.netSeq == m.netSeq {
		return false
	}
	ks.netSeq = m.netSeq
	kind, decided := policy.classify(m.netSubject(ks.kind, policy, now))
	if !decided || kind == ks.kind {
		ks.kindNext, ks.kindVotes = "", 0
		return false
	}
	if kind == ks.kindNext {
		ks.kindVotes++
	} else {
		ks.kindNext, ks.kindVotes = kind, 1
	}
	if (ks.kind != "" || kind == "") && ks.kindVotes < kindRounds {
		m.diagNext, m.diagForced = earliest(m.diagNext, now.Add(diagConfirmGap)), true
		return false
	}
	from := ks.kind
	ks.kind, ks.kindNext, ks.kindVotes = kind, "", 0
	env := m.env(now)
	if env.Kinds == nil {
		env.Kinds = map[string]string{}
	}
	env.Kinds[memory] = kind
	if kind == "" {
		delete(env.Kinds, memory)
	}
	m.journal.add(JournalEntry{At: now, Group: group, Kind: "network", From: from, To: kind, Reason: reason("network.kind", "kind", kind)})
	m.dirty, m.statusDirty = true, true
	return true
}

func (m *machine) paused(g *groupState) bool {
	return g.policy != nil && g.policy.pauses(g.kind)
}

func (m *machine) decideGroup(g *groupState, now time.Time) Decision {
	return m.decideWith(g, g.active(), now)
}

// decideWith decides for the group under any policy from the same evidence;
// the profile editor compares a draft this way.
func (m *machine) decideWith(g *groupState, policy *Policy, now time.Time) Decision {
	ctl := m.controls[g.name]
	env := m.env(now)
	members := make([]Member, len(g.members))
	for i, member := range g.members {
		member.Facts = env.Nodes[member.Key]
		members[i] = member
	}
	control := ctl.Control
	if control.Mode == PinnedMode && control.PinEnv != "" && control.PinEnv != m.envKey {
		control.Mode = AutoMode
	}
	for i := range members {
		members[i].Exit = m.evidence.Exits[members[i].Key]
	}
	return Decide(DecideInput{
		Policy:       policy,
		Members:      members,
		Now:          g.now,
		Control:      control,
		Env:          m.envKey,
		Excluded:     ctl.Excluded,
		LastSwitch:   ctl.LastSwitch,
		SwitchesHour: ctl.switchesSince(now.Add(-time.Hour)),
		Freshness:    env.Freshness(now),
		At:           now,
		ForceSwitch:  g.force,
		Net:          m.netSubject(g.kind, g.policy, now),
		Paused:       m.paused(g),
	})
}

func (c *controlRecord) switchesSince(cutoff time.Time) int {
	count := 0
	for _, at := range c.Switches {
		if at.After(cutoff) {
			count++
		}
	}
	return count
}

// settle decides every group and applies switches. Selection happens only
// while the core routes, and never in manual mode.
func (m *machine) settle(now time.Time) {
	if m.scn.c != nil {
		m.classifyKind(&m.scn.kindState, m.scn.c.net, scenarioKey(m.scn.id), "", now)
	}
	// The scenario's programs follow its network kind.
	if m.scn.kind != m.scn.appliedKind {
		m.rebuild(now)
	}
	m.applyMode(now)
	for _, name := range m.order {
		g := m.groups[name]
		if g.policy == nil || len(g.members) == 0 {
			continue
		}
		if m.idle(g) {
			d := Decision{Action: HoldAction, Target: g.now, Reason: reason("hold.idle", "mode", m.tunnelMode())}
			if !sameDecision(g.decision, d) {
				m.statusDirty = true
			}
			g.decision = d
			continue
		}
		m.classify(g, now)
		d := m.decideGroup(g, now)
		g.force = false
		if d.Action == SwitchAction && m.running && d.Target != g.now {
			from := g.now
			if err := m.rt.Select(g.name, g.via(d.Target), d.Target); err != nil {
				d.Action = StrandedAction
				d.Reason = Reason{Code: "select.failed", Args: map[string]any{"error": err.Error()}}
			} else {
				g.now = d.Target
				// The ranking was made before the move; the planner reads it
				// next, and it must see the node now in use as current.
				for i := range d.Ranking {
					d.Ranking[i].Current = d.Ranking[i].Name == g.now
				}
				ctl := m.controls[name]
				ctl.LastSwitch = now
				ctl.Switches = append(trimTimes(ctl.Switches, now.Add(-time.Hour)), now)
				g.suspect = false
				if d.Reason.Code == "switch.failover" && from != "" {
					m.rt.CloseConnections(g.name, from)
				}
				m.journal.add(JournalEntry{At: now, Group: name, Kind: "switch", From: from, To: d.Target, Reason: d.Reason})
				m.dirty = true
			}
		}
		if !sameDecision(g.decision, d) {
			if d.Action == StrandedAction && g.decision.Action != StrandedAction {
				m.journal.add(JournalEntry{At: now, Group: name, Kind: "stranded", From: g.now, Reason: d.Reason})
			}
			m.statusDirty = true
		}
		g.decision = d
	}
	m.updateSplit(now)
}

// updateSplit picks the group DIRECT rules go through: the first one whose
// user turned direct-split on and whose network condition holds now.
func (m *machine) updateSplit(now time.Time) {
	target := ""
	for _, name := range m.order {
		g := m.groups[name]
		if m.splitState(g, now) == "active" {
			target = name
			break
		}
	}
	if target == m.split {
		return
	}
	entry := JournalEntry{At: now, Group: target, Kind: "split", Reason: reason("split.on")}
	if target == "" {
		entry.Group, entry.Reason = m.split, reason("split.off")
	}
	m.journal.add(entry)
	m.split = target
	m.statusDirty = true
}

func (m *machine) splitState(g *groupState, now time.Time) string {
	switch {
	case g.policy == nil || g.policy.DirectSplit == nil:
		return ""
	case !g.binding.DirectSplit:
		return "off"
	case !m.running || len(g.members) == 0 || m.controls[g.name].Mode == ManualMode || m.paused(g):
		return "standby"
	case g.policy.DirectSplit.Test(&Subject{Net: m.netSubject(g.kind, g.policy, now)}) == triYes:
		return "active"
	default:
		return "standby"
	}
}

func sameDecision(a, b Decision) bool {
	if a.Action != b.Action || a.Target != b.Target || a.Reason.Code != b.Reason.Code || a.Tier != b.Tier {
		return false
	}
	if (a.Until == nil) != (b.Until == nil) {
		return false
	}
	return a.Until == nil || a.Until.Code == b.Until.Code
}

func trimTimes(times []time.Time, cutoff time.Time) []time.Time {
	kept := times[:0]
	for _, t := range times {
		if t.After(cutoff) {
			kept = append(kept, t)
		}
	}
	return kept
}

// linkProven reports whether anything got through recently. A failure is
// held in escrow until then: it is recorded but condemns no node, because
// with the link down every node fails alike.
func (m *machine) linkProven(now time.Time) bool {
	return !m.linkOKAt.IsZero() && now.Sub(m.linkOKAt) <= linkWindow
}

func (m *machine) groupOf(key string) []*groupState {
	var out []*groupState
	for _, name := range m.order {
		g := m.groups[name]
		for _, member := range g.members {
			if member.Key == key {
				out = append(out, g)
				break
			}
		}
	}
	return out
}

func (m *machine) currentOf(key string) bool {
	for _, g := range m.groupOf(key) {
		if i, ok := g.byName[g.now]; ok && g.members[i].Key == key {
			return true
		}
	}
	return false
}

func (m *machine) keyOf(group, node string) (string, bool) {
	g := m.groups[group]
	if g == nil {
		return "", false
	}
	i, ok := g.byName[node]
	if !ok {
		return "", false
	}
	return g.members[i].Key, true
}

// keysOf resolves a node name reported by mihomo to every key it carries
// across smart groups.
func (m *machine) keysOf(node string) []string {
	var keys []string
	for _, name := range m.order {
		if key, ok := m.keyOf(name, node); ok && !slices.Contains(keys, key) {
			keys = append(keys, key)
		}
	}
	return keys
}

func (m *machine) onProbeResult(job probeJob, res probeResult, now time.Time) {
	m.budget.charge(job.Bucket, res.Requests)
	if job.Targets != nil {
		m.onDiagnosis(job, res, now)
		return
	}
	delete(m.inflight, job.Key)
	f := m.facts(job.Key, now)
	failed := res.Failed || res.Ms <= 0
	if !failed {
		f.noteSample(now, res.Ms, ProbeSource)
		m.linkOKAt = now
		m.resetRecover(job.Key)
		for id, ok := range res.Checks {
			f.noteCheck(id, now, ok, job.Checks[id].Optional)
		}
		if job.Exit != nil {
			country, sources := exitVerdict(res.Votes, job.Exit.Agree)
			if m.evidence.Exits == nil {
				m.evidence.Exits = map[string]*ExitFact{}
			}
			m.evidence.Exits[job.Key] = &ExitFact{Country: country, At: now, Sources: sources}
		}
	} else {
		f.noteProbeFail(now)
	}
	if g := m.groups[job.Group]; g != nil && g.confirm != nil && (job.Kind == "confirm" || job.Kind == "confirm-standby") {
		g.confirm.record(job, failed)
		if g.confirm.done() {
			m.resolveConfirm(g, now)
		}
	} else if failed && m.linkProven(now) && f.FailRun >= 2 {
		f.markDead(now)
	}
	m.dirty, m.statusDirty = true, true
}

// confirmation pairs the check of a suspect current node with one of its best
// standby, sent together, and judges them together.
type confirmation struct {
	key, standby        string
	pending             int
	failed, standbyDown bool
}

func (c *confirmation) record(job probeJob, failed bool) {
	c.pending--
	if job.Kind == "confirm" {
		c.failed = failed
	} else {
		c.standbyDown = failed
	}
}

func (c *confirmation) done() bool { return c.pending <= 0 }

func (m *machine) resolveConfirm(g *groupState, now time.Time) {
	c := g.confirm
	g.confirm, g.suspect, g.recoverArmed = nil, false, false
	switch {
	case !c.failed:
	case c.standby != "" && c.standbyDown, c.standby == "" && !m.linkProven(now):
		m.journal.add(JournalEntry{At: now, Group: g.name, Kind: "network", Reason: reason("network.suspect")})
		g.recoverPass++
		g.recoverAt = now.Add(recoverBackoff[min(g.recoverPass, len(recoverBackoff)-1)])
	default:
		m.facts(c.key, now).markDead(now)
		name := ""
		for _, member := range g.members {
			if member.Key == c.key {
				name = member.Name
			}
		}
		m.journal.add(JournalEntry{At: now, Group: g.name, Kind: "failure", From: name, Reason: reason("failure.confirmed")})
	}
}

// onDiagnosis keeps results only for the network they were taken on.
func (m *machine) onDiagnosis(job probeJob, res probeResult, now time.Time) {
	m.diagBusy = false
	if job.Env != m.envKey {
		return
	}
	env := m.env(now)
	if env.Diag == nil {
		env.Diag = map[string]DiagFact{}
	}
	for target, ok := range res.Diag {
		env.Diag[target] = DiagFact{At: now, OK: ok}
	}
	m.diagNext = now.Add(diagBackoff[min(m.diagStep, len(diagBackoff)-1)])
	m.diagStep++
	m.diagForced = false
	m.netSeq++
	m.dirty, m.statusDirty = true, true
}

func (m *machine) resetRecover(key string) {
	for _, g := range m.groupOf(key) {
		g.recoverPass, g.recoverAt = 0, time.Time{}
	}
}

func (m *machine) onURLTest(node string, ms int, now time.Time) {
	for _, key := range m.keysOf(node) {
		if _, probing := m.inflight[key]; probing {
			continue
		}
		f := m.facts(key, now)
		if ms > 0 {
			f.noteSample(now, ms, TestSource)
			m.linkOKAt = now
		} else {
			f.noteProbeFail(now)
		}
		m.dirty, m.statusDirty = true, true
	}
}

// onTraffic records that real traffic moved through a node, the strongest
// evidence there is, and that the radio is up.
func (m *machine) onTraffic(nodes map[string]int, now time.Time) {
	m.openWindow(now, trafficWindow)
	for node := range nodes {
		for _, key := range m.keysOf(node) {
			f := m.facts(key, now)
			wasDead := f.Dead()
			f.noteOK(now, TrafficSource)
			m.linkOKAt = now
			if wasDead {
				m.statusDirty = true
			}
		}
	}
}

// onDialFailures marks a group's current node suspect when real dials keep
// failing; the planner then buys one confirming check.
func (m *machine) onDialFailures(nodes map[string]int, now time.Time) {
	for node, count := range nodes {
		for _, key := range m.keysOf(node) {
			f := m.facts(key, now)
			suspect := false
			for range count {
				suspect = f.noteDialFail(now) || suspect
			}
			if !suspect {
				continue
			}
			for _, g := range m.groupOf(key) {
				if i, ok := g.byName[g.now]; ok && g.members[i].Key == key && !g.suspect {
					g.suspect = true
					g.recoverArmed = true
					m.statusDirty = true
				}
			}
		}
	}
}

func (m *machine) onHints(h Hints, now time.Time) {
	wasScreen, wasDoze, wasMetered := m.power.Screen, m.power.Doze, m.power.Metered
	m.power.apply(h)
	if m.power.Metered != wasMetered {
		m.netSeq++
	}
	if h.Network != nil {
		if h.Network.Transport != m.transport || h.Network.Portal != m.portal {
			m.transport, m.portal = h.Network.Transport, h.Network.Portal
			m.netSeq++
			m.diagNext, m.diagForced = now, true
			m.openWindow(now, networkWindow)
		}
		key := "default"
		if h.Network.Transport != "" || h.Network.ID != "" {
			key = h.Network.Transport + ":" + digest(m.salt, "net", h.Network.ID)
		}
		if key != m.envKey {
			m.envKey, m.envLabel = key, h.Network.Transport
			if m.envLabel == "" {
				m.envLabel = "default"
			}
			m.linkOKAt = time.Time{}
			m.openWindow(now, networkWindow)
			for _, g := range m.groups {
				g.maintainAt, g.recoverPass, g.recoverAt = now, 0, time.Time{}
				m.recallKind(g, now)
			}
			m.recall(&m.scn.kindState, scenarioKey(m.scn.id), now)
			m.diagNext, m.diagStep, m.diagForced = now, 0, true
			m.netSeq++
			m.journal.add(JournalEntry{At: now, Kind: "network", Reason: reason("network.changed", "transport", m.envLabel)})
			m.dirty = true
		}
	}
	// A glance at the screen is not a reason to check anything; the wake
	// window only opens once traffic confirms the user is doing something.
	if (!wasScreen && m.power.Screen) || (wasDoze && !m.power.Doze) || h.Resumed {
		m.wakeAt = now.Add(wakeDebounce)
	}
	// A laptop may wake on another network: failures wait until traffic proves the link.
	if h.Resumed {
		m.linkOKAt = time.Time{}
	}
	m.statusDirty = true
}

func (m *machine) onManualPick(group, node string, now time.Time) {
	g := m.groups[group]
	if g == nil {
		return
	}
	g.now = node
	ctl := m.controls[group]
	if ctl.Mode == ManualMode {
		return
	}
	ctl.Mode, ctl.PinName, ctl.PinEnv = PinnedMode, node, ""
	if key, ok := m.keyOf(group, node); ok {
		ctl.Pin = key
	}
	m.journal.add(JournalEntry{At: now, Group: group, Kind: "pin", To: node, Reason: reason("pin.manual")})
	m.dirty, m.statusDirty = true, true
}

// plan returns the checks worth buying now. Each one must be able to change a
// decision; the mode decides which kinds are allowed at all.
func (m *machine) plan(now time.Time) []probeJob {
	mode := m.mode(now)
	if mode == StoppedMode || mode == SleepMode {
		return nil
	}
	level := m.level()
	var jobs []probeJob
	if job, ok := m.planDiagnosis(mode, level, now); ok {
		jobs = append(jobs, job)
	}
	free := probeConcurrency - len(m.inflight)
	add := func(g *groupState, row Ranked, bucket Bucket, kind string) bool {
		if free <= 0 {
			return false
		}
		key, ok := m.keyOf(g.name, row.Name)
		if !ok {
			return false
		}
		if _, busy := m.inflight[key]; busy {
			return false
		}
		if last, ok := m.lastProbe[key]; ok && now.Sub(last) < probeRepeatGap && kind != "confirm" {
			return false
		}
		if !m.budget.spend(bucket, level, now) {
			return false
		}
		job := probeJob{Group: g.name, Node: row.Name, Key: key, Bucket: bucket, Kind: kind}
		if kind != "confirm" && kind != "confirm-standby" {
			m.attachExtras(&job, g.active(), level, now)
		}
		m.inflight[key] = job
		m.lastProbe[key] = now
		jobs = append(jobs, job)
		free--
		m.dirty, m.statusDirty = true, true
		return true
	}

	for _, name := range m.order {
		g := m.groups[name]
		if g.policy == nil || m.controls[name].Mode == ManualMode || m.paused(g) || m.idle(g) || g.active().Fixed != "" {
			continue
		}
		rows := g.decision.Ranking
		// A suspect current node gets one confirming check, together with the
		// best standby: if both fail, the link is down, not the node.
		if g.suspect {
			// While the network itself looks down, suspicion waits out the
			// same backoff as recovery instead of re-checking every episode.
			if g.confirm != nil || now.Before(g.recoverAt) {
				continue
			}
			if row, ok := rowOf(rows, g.now); ok && add(g, row, RecoverBucket, "confirm") {
				g.confirm = &confirmation{key: jobs[len(jobs)-1].Key, pending: 1}
				if standby := standbyOrder(g.decision); len(standby) > 0 && add(g, standby[0], RecoverBucket, "confirm-standby") {
					g.confirm.standby = jobs[len(jobs)-1].Key
					g.confirm.pending++
				}
			}
			continue
		}
		if g.needsRecovery() && now.After(g.recoverAt) && (mode != BackgroundMode || g.recoverArmed) {
			sent := 0
			for _, row := range recoverOrder(rows) {
				if sent < recoverPassSize && add(g, row, RecoverBucket, "recover") {
					sent++
				}
			}
			if sent > 0 {
				g.recoverPass++
				g.recoverAt = now.Add(recoverBackoff[min(g.recoverPass, len(recoverBackoff)-1)])
				g.recoverArmed = false
			}
			continue
		}
		inWindow := now.Before(m.windowUntil)
		if mode == BackgroundMode || mode == IdleMode || !inWindow || now.Before(m.wakeAt) {
			continue
		}
		for _, need := range g.decision.Needs {
			if row, ok := rowOf(rows, need); ok {
				add(g, row, DiscoverBucket, "confirm-better")
			}
		}
		if now.After(g.maintainAt) {
			sent := 0
			// Checks the current node's tier rests on go stale like its
			// latency; keep them fresh even when the profile never improves.
			if g.policy.Improve || g.active().checksNode() {
				if row, ok := rowOf(rows, g.now); ok && (stale(row, now, m.env(now).Freshness(now)) || m.extrasDue(g.active(), m.keyFor(g, row.Name), now)) {
					add(g, row, MaintainBucket, "maintain")
				}
			}
			for _, row := range standbyOrder(g.decision) {
				if sent >= maintainStandbys {
					break
				}
				if !stale(row, now, m.env(now).Freshness(now)) {
					sent++
					continue
				}
				if add(g, row, MaintainBucket, "maintain") {
					sent++
				}
			}
			g.maintainAt = now.Add(level.standbyEvery)
		}
		if g.policy.Improve && mode == ActiveMode {
			sent := 0
			servers := map[string]bool{}
			for _, row := range discoverOrder(g.decision) {
				if sent >= discoverPerWindow {
					break
				}
				server := g.members[g.byName[row.Name]].Server
				if servers[server] || !stale(row, now, m.env(now).Freshness(now)) {
					continue
				}
				if add(g, row, DiscoverBucket, "discover") {
					servers[server] = true
					sent++
				}
			}
		}
	}
	return jobs
}

// needsRecovery: the group has nothing known to work, so it is worth paying
// to find something that does.
func (g *groupState) via(node string) []string {
	if i, ok := g.byName[node]; ok {
		return g.members[i].Via
	}
	return nil
}

func (g *groupState) needsRecovery() bool {
	if g.decision.Action == StrandedAction {
		return true
	}
	for _, row := range g.decision.Ranking {
		if row.Excluded == nil && row.Health != DeadHealth && (row.Health == AliveHealth || row.Current) {
			return false
		}
	}
	return len(g.decision.Ranking) > 0
}

func recoverOrder(rows []Ranked) []Ranked {
	var out []Ranked
	for _, row := range rows {
		if row.Excluded == nil || row.Excluded.Code == "dead" || row.Excluded.Code == "pending" {
			out = append(out, row)
		}
	}
	return out
}

func rowOf(rows []Ranked, name string) (Ranked, bool) {
	for _, row := range rows {
		if row.Name == name {
			return row, true
		}
	}
	return Ranked{}, false
}

func stale(row Ranked, now time.Time, freshness time.Duration) bool {
	return row.CheckedAt.IsZero() || now.Sub(row.CheckedAt) > freshness
}

// nextDue is the one moment the engine must wake on its own; every other
// wake-up is an event.
func (m *machine) nextDue(now time.Time) time.Time {
	mode := m.mode(now)
	if mode == StoppedMode || mode == SleepMode {
		return time.Time{}
	}
	var due time.Time
	consider := func(t time.Time) {
		if t.After(now) && (due.IsZero() || t.Before(due)) {
			due = t
		}
	}
	for _, name := range m.order {
		g := m.groups[name]
		ctl := m.controls[name]
		for _, until := range ctl.Excluded {
			consider(until)
		}
		if g.suspect && g.confirm == nil {
			consider(latest(now.Add(probeRepeatGap), g.recoverAt))
		}
		if g.needsRecovery() && (mode != BackgroundMode || g.recoverArmed) {
			consider(g.recoverAt)
		}
		if g.decision.Until != nil && g.decision.Until.Code == "until.dwell" {
			consider(ctl.LastSwitch.Add(g.policy.Dwell))
		}
		if (mode == ActiveMode || mode == EcoMode) && now.Before(m.windowUntil) {
			consider(g.maintainAt)
		}
	}
	if now.Before(m.windowUntil) {
		consider(m.wakeAt)
		if m.diagAllowed(mode) && !m.diagBusy && len(m.diagTargets()) > 0 {
			consider(m.diagNext)
		}
	}
	return due
}

func (p *Policy) checksNode() bool { return len(p.CheckIDs) > 0 || p.UsesExit }

func (m *machine) keyFor(g *groupState, node string) string {
	key, _ := m.keyOf(g.name, node)
	return key
}

// extrasDue reports whether the node's checks or exit country need a new
// measurement: missing, stale, or a failure not yet confirmed.
func (m *machine) extrasDue(p *Policy, key string, now time.Time) bool {
	checks, exit := m.extras(p, key, now)
	return len(checks) > 0 || exit
}

func (m *machine) extras(p *Policy, key string, now time.Time) ([]string, bool) {
	var due []string
	env := m.env(now)
	facts := env.Nodes[key]
	for _, id := range p.CheckIDs {
		var c *CheckFact
		if facts != nil {
			c = facts.Checks[id]
		}
		if c == nil || now.Sub(c.At) > env.Freshness(now) || c.verdict(now) == triUnknown {
			due = append(due, id)
		}
	}
	return due, p.UsesExit && m.evidence.Exits[key].due(now)
}

// attachExtras adds what is due to a probe, as far as the bucket pays for it.
func (m *machine) attachExtras(job *probeJob, p *Policy, level energyLevel, now time.Time) {
	checks, exit := m.extras(p, job.Key, now)
	if job.Bucket == UserBucket {
		checks, exit = p.CheckIDs, p.UsesExit
	}
	for _, id := range checks {
		if !m.budget.spend(job.Bucket, level, now) {
			return
		}
		if job.Checks == nil {
			job.Checks = map[string]Check{}
		}
		job.Checks[id] = p.Checks[id]
	}
	if exit && m.budget.spend(job.Bucket, level, now) {
		egress := p.Egress
		job.Exit = &egress
	}
}

func (m *machine) diagAllowed(mode Mode) bool {
	return mode == ActiveMode || mode == EcoMode && m.diagForced
}

// diagTargets is the union of every smart group's diagnostics: profiles
// naming the same endpoint share one request.
func (m *machine) diagTargets() []Target {
	seen := map[string]bool{}
	var out []Target
	add := func(diagnostics map[string][]Target) {
		for _, diag := range slices.Sorted(maps.Keys(diagnostics)) {
			for _, target := range diagnostics[diag] {
				if !seen[target.String()] {
					seen[target.String()] = true
					out = append(out, target)
				}
			}
		}
	}
	if m.scn.c != nil {
		add(m.scn.c.net.Diagnostics)
	}
	for _, name := range m.order {
		g := m.groups[name]
		if g.policy == nil || m.controls[name].Mode == ManualMode || m.idle(g) {
			continue
		}
		add(g.policy.Diagnostics)
	}
	return out
}

// planDiagnosis runs the direct network diagnostics only while the user is
// active, or once after a network change in eco; never with the screen off.
func (m *machine) planDiagnosis(mode Mode, level energyLevel, now time.Time) (probeJob, bool) {
	if m.diagBusy || now.Before(m.diagNext) || !now.Before(m.windowUntil) || !m.diagAllowed(mode) {
		return probeJob{}, false
	}
	var targets []Target
	for _, target := range m.diagTargets() {
		if !m.budget.spend(NetworkBucket, level, now) {
			break
		}
		targets = append(targets, target)
	}
	if len(targets) == 0 {
		return probeJob{}, false
	}
	m.diagBusy = true
	m.dirty, m.statusDirty = true, true
	return probeJob{Kind: "diagnose", Bucket: NetworkBucket, Targets: targets, Env: m.envKey}, true
}

func (m *machine) expireCooldowns(now time.Time) {
	for _, ctl := range m.controls {
		for key, until := range ctl.Excluded {
			if !until.After(now) {
				delete(ctl.Excluded, key)
				m.statusDirty = true
			}
		}
	}
}

func latest(a, b time.Time) time.Time {
	if a.After(b) {
		return a
	}
	return b
}
