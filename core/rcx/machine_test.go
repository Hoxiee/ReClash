package rcx

import (
	"fmt"
	"testing"
	"time"
)

type simRuntime struct {
	selects    []string
	closed     []string
	suppressed []string
	modes      []string
}

func (r *simRuntime) Select(group string, via []string, node string) error {
	r.selects = append(r.selects, node)
	return nil
}
func (r *simRuntime) CloseConnections(group, node string) { r.closed = append(r.closed, node) }
func (r *simRuntime) SuppressHealthChecks(p []string)     { r.suppressed = p }
func (r *simRuntime) ApplyMode(mode string)               { r.modes = append(r.modes, mode) }

// sim drives the machine on virtual time. It steps more often than the real
// engine wakes, so the request counts it asserts are upper bounds.
type sim struct {
	t       *testing.T
	rt      *simRuntime
	m       *machine
	now     time.Time
	latency map[string]int
	linkUp  bool
	probes  map[int]int
	// What the network answers directly, which nodes fail the declared
	// checks, and where each node exits (default: open, passing, DE).
	diag     map[string]bool
	blocked  map[string]bool
	exits    map[string]string
	nodeJobs int
}

func newSim(t *testing.T, profile string, nodes int) *sim {
	s := &sim{t: t, rt: &simRuntime{}, now: t0, latency: map[string]int{}, linkUp: true, probes: map[int]int{}}
	s.m = newMachine(s.rt)
	var members []Node
	for i := range nodes {
		name := fmt.Sprintf("n%d", i)
		members = append(members, Node{Name: name, Type: "Vless", Provider: "main", Server: fmt.Sprintf("s%d", i/3), Strong: name})
		s.latency[name] = 60 + i
	}
	s.m.topology = Topology{
		Groups:       []GroupTopology{{Name: "G", Now: "n5", Members: members}},
		Subscription: SubscriptionLayer{Groups: map[string]Binding{"G": {Default: profile}}},
		Providers:    map[string][]string{"n0": {"main"}},
	}
	s.m.running = true
	s.m.rebuild(s.now)
	return s
}

func (s *sim) group() *groupState { return s.m.groups["G"] }

func (s *sim) step() {
	for range 64 {
		s.m.expireCooldowns(s.now)
		s.m.settle(s.now)
		jobs := s.m.plan(s.now)
		if len(jobs) == 0 {
			return
		}
		for _, job := range jobs {
			res, requests := s.answer(job)
			s.probes[int(s.now.Sub(t0).Hours())] += requests
			s.m.onProbeResult(job, res, s.now)
		}
	}
	s.t.Fatal("planner did not settle")
}

func (s *sim) answer(job probeJob) (probeResult, int) {
	if job.Targets != nil {
		res := probeResult{Diag: map[string]bool{}}
		for _, target := range job.Targets {
			ok, set := s.diag[target.String()]
			res.Diag[target.String()] = s.linkUp && (ok || !set)
		}
		return res, len(job.Targets)
	}
	s.nodeJobs++
	ms := s.latency[job.Node]
	res := probeResult{Ms: ms, Failed: !s.linkUp || ms == 0}
	for id := range job.Checks {
		if res.Checks == nil {
			res.Checks = map[string]bool{}
		}
		res.Checks[id] = !s.blocked[job.Node]
	}
	requests := 1 + len(job.Checks)
	if job.Exit != nil {
		country := s.exits[job.Node]
		if country == "" {
			country = "DE"
		}
		res.Votes = []ExitVote{{Source: "echo", Country: country}, {Source: "mmdb", Country: country}}
		requests++
	}
	return res, requests
}

func (s *sim) traffic() {
	if s.linkUp && s.latency[s.group().now] > 0 {
		s.m.onTraffic(map[string]int{s.group().now: 1}, s.now)
	} else {
		s.m.onDialFailures(map[string]int{s.group().now: 3}, s.now)
	}
}

func (s *sim) run(d, every time.Duration, each func()) {
	for end := s.now.Add(d); s.now.Before(end); s.now = s.now.Add(every) {
		if each != nil {
			each()
		}
		s.step()
	}
}

func (s *sim) maxPerHour() int {
	most := 0
	for _, n := range s.probes {
		most = max(most, n)
	}
	return most
}

func (s *sim) total() int {
	total := 0
	for _, n := range s.probes {
		total += n
	}
	return total
}

func TestEnergySimpleProfilesStayWithinTarget(t *testing.T) {
	for _, profile := range []string{"builtin/simple", "builtin/fastest", "builtin/stable"} {
		s := newSim(t, profile, 250)
		s.run(24*time.Hour, 30*time.Second, s.traffic)
		if most := s.maxPerHour(); most > 30 {
			t.Errorf("%s: %d requests in one hour, target is 30", profile, most)
		}
		if bytes := s.maxPerHour() * probeCostBytes; bytes > 300<<10 {
			t.Errorf("%s: %d bytes in one hour", profile, bytes)
		}
	}
}

func TestEnergyNothingWithoutUse(t *testing.T) {
	cases := map[string]Hints{
		"screen off": {Screen: ptr(false)},
		"doze":       {Screen: ptr(false), Doze: ptr(true)},
		"idle":       {},
	}
	for name, hints := range cases {
		s := newSim(t, "builtin/fastest", 50)
		s.m.onHints(hints, s.now)
		var each func()
		if name != "idle" {
			each = s.traffic
		}
		s.run(24*time.Hour, time.Minute, each)
		if total := s.total(); total != 0 {
			t.Errorf("%s: %d requests with nothing failing", name, total)
		}
	}
}

func TestFailoverOnRealTrafficFailure(t *testing.T) {
	s := newSim(t, "builtin/simple", 20)
	s.run(10*time.Minute, 30*time.Second, s.traffic)
	s.latency["n5"] = 0
	s.traffic()
	s.step()
	g := s.group()
	if g.now == "n5" {
		t.Fatalf("still on the dead node: %+v", g.decision)
	}
	if len(s.rt.closed) != 1 || s.rt.closed[0] != "n5" {
		t.Fatalf("connections of the dead node not closed: %v", s.rt.closed)
	}
	if facts := s.m.facts(g.members[g.byName[g.now]].Key, s.now); facts.Dead() {
		t.Fatal("failed over to a dead node")
	}
}

func TestLaptopOnBatterySpendsLessAndResumeHoldsEvidence(t *testing.T) {
	spent := map[bool]int{}
	for _, onBattery := range []bool{false, true} {
		s := newSim(t, "builtin/fastest", 250)
		s.m.onHints(Hints{OnBattery: ptr(onBattery)}, s.now)
		s.run(6*time.Hour, 30*time.Second, s.traffic)
		spent[onBattery] = s.total()
		if onBattery && s.m.mode(s.now) != EcoMode {
			t.Fatalf("on battery the mode is %s", s.m.mode(s.now))
		}
	}
	if spent[true] >= spent[false] {
		t.Fatalf("on battery spent %d requests, on AC %d", spent[true], spent[false])
	}

	s := newSim(t, "builtin/simple", 20)
	s.run(10*time.Minute, 30*time.Second, s.traffic)
	s.m.onHints(Hints{Resumed: true}, s.now)
	if s.m.linkProven(s.now) || !s.now.Before(s.m.wakeAt) {
		t.Fatal("a resume neither held failures in escrow nor debounced the wake")
	}
}

func TestScreenOffReactsOnlyToRealFailure(t *testing.T) {
	s := newSim(t, "builtin/simple", 20)
	s.run(10*time.Minute, 30*time.Second, s.traffic)
	s.m.onHints(Hints{Screen: ptr(false)}, s.now)
	before := s.total()
	s.latency["n5"] = 0
	s.traffic()
	s.step()
	if s.group().now == "n5" {
		t.Fatal("a real failure with the screen off was ignored")
	}
	if spent := s.total() - before; spent > 2 {
		t.Fatalf("screen-off failure reaction spent %d requests", spent)
	}
}

func TestOfflineCondemnsNoNodeAndBacksOff(t *testing.T) {
	s := newSim(t, "builtin/simple", 30)
	s.run(10*time.Minute, 30*time.Second, s.traffic)
	s.linkUp = false
	s.probes = map[int]int{}
	s.run(6*time.Hour, 30*time.Second, s.traffic)
	dead := 0
	for _, member := range s.group().members {
		if s.m.facts(member.Key, s.now).Dead() {
			dead++
		}
	}
	if dead > 1 {
		t.Fatalf("%d nodes condemned while the link was down", dead)
	}
	if most := s.maxPerHour(); most > 30 {
		t.Fatalf("offline spent %d requests in one hour", most)
	}
	s.linkUp = true
	s.run(5*time.Minute, 30*time.Second, s.traffic)
	if d := s.group().decision; d.Action == StrandedAction {
		t.Fatalf("did not recover once the link returned: %+v", d)
	}
}

func TestEnergyNetworkChangesStayBounded(t *testing.T) {
	s := newSim(t, "builtin/fastest", 250)
	i := 0
	s.run(24*time.Hour, 30*time.Second, func() {
		i++
		if i%20 == 0 {
			s.m.onHints(Hints{Network: &NetworkHint{Transport: "wifi", ID: fmt.Sprint(i % 7)}}, s.now)
		}
		s.traffic()
	})
	if most := s.maxPerHour(); most > 80 {
		t.Fatalf("network changes every 10 min cost %d requests in one hour", most)
	}
}

func TestFastestFindsAFasterNodeWithoutFlapping(t *testing.T) {
	s := newSim(t, "builtin/fastest", 12)
	s.latency["n5"] = 300
	s.latency["n9"] = 40
	switches := 0
	s.run(6*time.Hour, 30*time.Second, func() {
		s.traffic()
		// Noise of ±15 ms must not move a group that has settled.
		for name, ms := range s.latency {
			if ms > 0 && name != "n9" && name != "n5" {
				s.latency[name] = 100 + int(s.now.Unix()/30%3)*15
			}
		}
	})
	switches = len(s.rt.selects)
	if s.group().now != "n9" {
		t.Fatalf("fastest did not reach the fastest node: now %s, %+v", s.group().now, s.group().decision)
	}
	if switches > 3 {
		t.Fatalf("%d switches for one improvement", switches)
	}
}

func TestChangeServerAndPinLifecycle(t *testing.T) {
	s := newSim(t, "builtin/simple", 5)
	s.run(time.Minute, 30*time.Second, s.traffic)
	s.m.onManualPick("G", "n3", s.now)
	s.step()
	if s.group().now != "n3" || s.m.controls["G"].Mode != PinnedMode {
		t.Fatal("a manual pick did not pin")
	}
	s.latency["n3"] = 0
	s.traffic()
	s.step()
	if s.group().now == "n3" {
		t.Fatal("a dead pin was kept")
	}
	s.latency["n3"] = 70
	s.run(2*time.Hour, 30*time.Second, s.traffic)
	if s.group().now != "n3" {
		t.Fatalf("did not return to the recovered pin: %+v", s.group().decision)
	}
}

func TestIdentitySurvivesCredentialRotationAndRenames(t *testing.T) {
	salt := []byte("salt")
	var ix IdentityIndex
	nodes := []Node{
		{Name: "DE-1", Provider: "p", Server: "a", Strong: "s1", Endpoint: "e1"},
		{Name: "DE-2", Provider: "p", Server: "b", Strong: "s2", Endpoint: "e2"},
		{Name: "dup", Provider: "p", Server: "c", Strong: "s3", Endpoint: "e3"},
		{Name: "dup", Provider: "q", Server: "c", Strong: "s3", Endpoint: "e3"},
	}
	keys, _ := ix.Resolve(salt, nodes, t0)
	if keys[2] == keys[3] {
		t.Fatal("identical nodes from two providers share a key")
	}
	rotated := []Node{
		{Name: "DE-1", Provider: "p", Server: "a", Strong: "s1-rotated", Endpoint: "e1"},
		{Name: "Germany 2", Provider: "p", Server: "b", Strong: "s2", Endpoint: "e2"},
		{Name: "DE-3", Provider: "p", Server: "d", Strong: "s9", Endpoint: "e9"},
	}
	again, matches := ix.Resolve(salt, rotated, t0.Add(time.Hour))
	if again[0] != keys[0] || matches[0] != MatchedEndpoint {
		t.Fatalf("credential rotation lost history: %v %v", again, matches)
	}
	if again[1] != keys[1] || matches[1] != MatchedStrong {
		t.Fatalf("a rename lost history: %v %v", again, matches)
	}
	if matches[2] != MatchedNew {
		t.Fatalf("a new node matched an old one: %v", matches)
	}
	for _, e := range ix.Entries {
		if e.Strong == "s1-rotated" || e.Server == "a" {
			t.Fatal("fingerprints stored in the clear")
		}
	}
}

func ptr[T any](v T) *T { return &v }
