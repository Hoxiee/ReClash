package rcx

import (
	"context"
	"sync"
	"testing"
)

type memStore struct {
	mu   sync.Mutex
	data []byte
}

func (s *memStore) Load() ([]byte, error) { s.mu.Lock(); defer s.mu.Unlock(); return s.data, nil }
func (s *memStore) Save(d []byte) error   { s.mu.Lock(); defer s.mu.Unlock(); s.data = d; return nil }

type fixedProber struct{}

func (fixedProber) Probe(context.Context, string) (int, error) { return 80, nil }
func (fixedProber) Check(context.Context, string, Check) error { return nil }
func (fixedProber) Diagnose(context.Context, Target) error     { return nil }
func (fixedProber) Exit(context.Context, string, Egress) ([]ExitVote, int, error) {
	return []ExitVote{{Source: "echo", Country: "DE"}, {Source: "mmdb", Country: "de"}}, 1, nil
}

type lockedRuntime struct {
	mu sync.Mutex
	simRuntime
}

func (r *lockedRuntime) Select(group string, via []string, node string) error {
	r.mu.Lock()
	defer r.mu.Unlock()
	return r.simRuntime.Select(group, via, node)
}

func engineTopology() Topology {
	return Topology{
		Groups:       []GroupTopology{{Name: "G", Now: "a", Members: []Node{{Name: "a", Type: "Vless", Strong: "a"}, {Name: "b", Type: "Vless", Strong: "b"}}}},
		Subscription: SubscriptionLayer{Groups: map[string]Binding{"G": {Profiles: []string{"builtin/simple", "builtin/fastest"}, Default: "builtin/simple"}}},
	}
}

func TestEngineActionsAndSnapshotRoundTrip(t *testing.T) {
	store := &memStore{}
	rt := &lockedRuntime{}
	e := NewEngine(rt, fixedProber{}, store, nil)
	e.SetRunning(true)
	e.SetTopology(engineTopology())

	if _, err := e.Act(ActionRequest{Group: "G", Action: "change"}); err != nil {
		t.Fatal(err)
	}
	status := e.Status()
	if status.Groups[0].Now != "b" || len(status.Groups[0].Excluded) != 1 || status.Groups[0].Excluded[0].Name != "a" {
		t.Fatalf("change server: %+v", status.Groups[0])
	}
	if _, err := e.Act(ActionRequest{Group: "G", Action: "pin", Node: "a", Here: true}); err != nil {
		t.Fatal(err)
	}
	if _, err := e.Act(ActionRequest{Group: "nope", Action: "auto"}); err == nil {
		t.Fatal("an action on an unknown group succeeded")
	}
	e.SetUserLayer(UserLayer{Groups: map[string]Binding{"G": {Profile: "builtin/fastest"}}})
	if got := e.Status().Groups[0].Profile; got != "builtin/fastest" {
		t.Fatalf("user choice ignored: %s", got)
	}
	e.Close()

	restored := NewEngine(&lockedRuntime{}, fixedProber{}, store, nil)
	restored.SetTopology(engineTopology())
	group := restored.Status().Groups[0]
	if group.Control.Mode != PinnedMode || group.Control.PinName != "a" || group.Control.PinEnv == "" {
		t.Fatalf("pin did not survive a restart: %+v", group.Control)
	}
	if len(restored.Journal(0, "G", 0)) < 2 {
		t.Fatal("journal did not survive a restart")
	}
	restored.Close()
}

func TestEngineReportsInvalidProfiles(t *testing.T) {
	e := NewEngine(&lockedRuntime{}, fixedProber{}, nil, nil)
	topo := engineTopology()
	topo.Subscription.Profiles = map[string]any{"broken": map[string]any{"prefer": []any{map[string]any{"label": "x", "when": "nmae = 1"}}}}
	topo.Subscription.Groups["G"] = Binding{Default: "broken"}
	topo.Subscription.Groups["Gone"] = Binding{Default: "builtin/simple"}
	e.SetTopology(topo)
	problems := map[string]string{}
	for _, g := range e.Status().Groups {
		if g.Problem != nil {
			problems[g.Name] = g.Problem.Code
		}
	}
	if problems["G"] != "profile.invalid" || problems["Gone"] != "group.unavailable" {
		t.Fatalf("problems not visible: %v", problems)
	}
	e.Close()
}

func TestChangeServerSpendsNoCheck(t *testing.T) {
	e := NewEngine(&lockedRuntime{}, fixedProber{}, nil, nil)
	e.SetRunning(true)
	e.SetTopology(engineTopology())
	if _, err := e.Act(ActionRequest{Group: "G", Action: "change"}); err != nil {
		t.Fatal(err)
	}
	status := e.Status()
	if status.Energy.Requests != 0 {
		t.Fatalf("change server bought %d checks", status.Energy.Requests)
	}
	if current := status.Groups[0].Current; current == nil || current.Name != "b" {
		t.Fatalf("status reports the old node as current: %+v", current)
	}
	e.Close()
}

func TestChipsMergeLayersAndDropBrokenPools(t *testing.T) {
	e := NewEngine(&lockedRuntime{}, fixedProber{}, nil, nil)
	topo := engineTopology()
	topo.Subscription.Groups["G"] = Binding{Default: "builtin/simple", Chips: []Chip{
		{Label: "DE", Include: `name ~ /de/i`},
		{Label: "Broken", Include: `nmae = 1`},
		{Label: "", Include: `name = "a"`},
	}}
	e.SetTopology(topo)
	e.SetUserLayer(UserLayer{Groups: map[string]Binding{"G": {Chips: []Chip{
		{Label: "Mine", Include: `name = "b"`},
		{Label: "DE again", Include: `name ~ /de/i`},
		{Label: "🇩🇪", Include: `name ~ /🇩🇪/i`},
	}}}})
	var labels []string
	for _, chip := range e.Status().Groups[0].Binding.Chips {
		labels = append(labels, chip.Label)
	}
	if len(labels) != 3 || labels[0] != "DE" || labels[1] != "Mine" || labels[2] != "🇩🇪" {
		t.Fatalf("chips: %v", labels)
	}
	e.Close()
}
