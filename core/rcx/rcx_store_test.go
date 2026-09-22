package rcx

import (
	"encoding/json"
	"testing"
	"time"
)

type fakeStorage struct {
	values map[string][]byte
	writes int
}

func newFakeStorage() *fakeStorage {
	return &fakeStorage{values: map[string][]byte{}}
}

func (s *fakeStorage) Get(key string) []byte { return s.values[key] }

func (s *fakeStorage) Set(key string, value []byte) {
	s.values[key] = value
	s.writes++
}

func testStore(storage rcxStorage) *rcxStore {
	return &rcxStore{storage: storage}
}

func TestStoreRoundTripsWhatTheEngineOwns(t *testing.T) {
	storage := newFakeStorage()
	store := testStore(storage)
	now := time.Unix(1_700_000_000, 0)

	snapshot := store.Load()
	snapshot.Config.Strategy = "invented"
	snapshot.Config.DefaultsVersion = 0
	snapshot.Config.DwellSeconds = 0
	fingerprints := snapshot.Fingerprints
	snapshot.Picks["w:Home"] = "Amsterdam #3"
	snapshot.Regimes["w:Home"] = rcxRegimeMemory{Terrain: rcxTerrainWhitelist, At: now}
	snapshot.Global["Amsterdam #3"] = &rcxNodeGlobal{Origin: rcxOriginForeign, EverGood: true}
	snapshot.Standbys["w:Home"] = []string{"endpoint-de-1", "endpoint-us-1"}
	snapshot.LanePicks["service:telegram"] = map[string]string{
		"w:Home": "endpoint-nl-1",
	}
	snapshot.LaneStandbys["service:telegram"] = map[string][]string{
		"w:Home": {"endpoint-de-1", "endpoint-us-1"},
	}
	snapshot.Quarantines["open:telegram"] = rcxMarkerQuarantine{
		Until:    now.Add(10 * time.Minute),
		Failures: []rcxMarkerFailure{{Bucket: "provider-a", At: now}},
	}
	snapshot.Metrics = rcxMetricsState{
		EnabledMillis:      60_000,
		AvailableMillis:    55_000,
		Incidents:          2,
		StandbyHits:        1,
		LastFailoverMillis: 2_300,
		LastOutageMillis:   3_100,
	}
	snapshot.Envs["w:Home"] = map[string]*rcxNodeEnv{
		"Amsterdam #3": {OpenWorld: rcxProofProven, LastGoodAt: now},
	}
	store.Save(snapshot, now, true)

	restored := testStore(storage).Load()

	if restored.Config.DefaultsVersion != rcxDefaultsVersion || restored.Config.Strategy != rcxStrategyBalanced || restored.Config.DwellSeconds != rcxDwellSeconds {
		t.Errorf("config = %+v, want current defaults and normalized values", restored.Config)
	}
	if restored.Fingerprints != fingerprints {
		t.Errorf("fingerprints = %+v, want stored %+v", restored.Fingerprints, fingerprints)
	}
	if got := restored.Picks["w:Home"]; got != "Amsterdam #3" {
		t.Errorf("pick = %q, want the remembered node: a cold start must not re-search", got)
	}
	if got := restored.Regimes["w:Home"].Terrain; got != rcxTerrainWhitelist {
		t.Errorf("terrain = %s, want whitelist", got)
	}
	if !restored.Global["Amsterdam #3"].EverGood {
		t.Error("global reputation was lost")
	}
	if restored.Envs["w:Home"]["Amsterdam #3"].OpenWorld != rcxProofProven {
		t.Error("per-network proof was lost")
	}
	if got := restored.Standbys["w:Home"]; len(got) != 2 || got[0] != "endpoint-de-1" {
		t.Errorf("standbys = %v, want the warm replacement order preserved", got)
	}
	if got := restored.LanePicks["service:telegram"]["w:Home"]; got != "endpoint-nl-1" {
		t.Errorf("lane pick = %q, want the capability-specific node preserved", got)
	}
	if got := restored.LaneStandbys["service:telegram"]["w:Home"]; len(got) != 2 || got[0] != "endpoint-de-1" {
		t.Errorf("lane standbys = %v, want the capability-specific order preserved", got)
	}
	quarantine := restored.Quarantines["open:telegram"]
	if !quarantine.Until.Equal(now.Add(10*time.Minute)) || len(quarantine.Failures) != 1 {
		t.Errorf("quarantine = %+v, want its expiry and bounded evidence preserved", quarantine)
	}
	if got := restored.Metrics; got.EnabledMillis != 60_000 || got.AvailableMillis != 55_000 || got.Incidents != 2 || got.StandbyHits != 1 || got.LastFailoverMillis != 2_300 || got.LastOutageMillis != 3_100 {
		t.Errorf("metrics = %+v, want local availability and incident counters preserved", got)
	}
}

func TestStoreIgnoresTheOldNamespace(t *testing.T) {
	storage := newFakeStorage()
	storage.values["rcx.v1"] = []byte(`{"v":1,"p":{"w:Home":"legacy"}}`)

	snapshot := testStore(storage).Load()

	if len(snapshot.Picks) != 0 {
		t.Errorf("picks = %v, want the old namespace ignored", snapshot.Picks)
	}
	if _, readNewNamespace := storage.values[rcxStoreKey]; readNewNamespace {
		t.Error("loading must not eagerly write the new namespace")
	}
}

func TestStoreDiscardsStateItCannotTrust(t *testing.T) {
	tests := []struct {
		name string
		raw  []byte
	}{
		{name: "truncated file", raw: []byte(`{"v":1,"p":{"a":`)},
		{name: "another schema", raw: []byte(`{"v":99,"p":{"w:Home":"gone"}}`)},
	}

	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			storage := newFakeStorage()
			storage.values[rcxStoreKey] = tc.raw

			snapshot := testStore(storage).Load()

			if len(snapshot.Picks) != 0 {
				t.Errorf("picks = %v, want an empty snapshot", snapshot.Picks)
			}
			if snapshot.Version != rcxStoreVersion {
				t.Errorf("version = %d, want the current schema", snapshot.Version)
			}
			if snapshot.Config.Preset != "off" {
				t.Errorf("preset = %q, want the shipped default", snapshot.Config.Preset)
			}
		})
	}
}

func TestStoreDebouncesWritesAndForcesOnDemand(t *testing.T) {
	storage := newFakeStorage()
	store := testStore(storage)
	now := time.Unix(1_700_000_000, 0)
	snapshot := store.Load()

	store.Save(snapshot, now, true)
	store.Save(snapshot, now.Add(time.Second), false)

	if storage.writes != 1 {
		t.Fatalf("writes = %d, want the second one debounced", storage.writes)
	}
	if !store.Pending() {
		t.Error("a debounced save must stay pending")
	}

	store.Save(snapshot, now.Add(2*time.Second), true)
	if storage.writes != 2 {
		t.Errorf("writes = %d, want a forced flush inside the debounce window", storage.writes)
	}
	if store.Pending() {
		t.Error("a forced flush must clear the pending flag")
	}

	store.Save(snapshot, now.Add(3*time.Second), false)
	store.Save(snapshot, now.Add(rcxFlushDebounce+3*time.Second), false)
	if storage.writes != 3 {
		t.Errorf("writes = %d, want the pending write once the window passed", storage.writes)
	}
	if store.Pending() {
		t.Error("a completed save must clear the pending flag")
	}
}

func TestStoreIgnoresSavesBeforeTheHomeDirIsKnown(t *testing.T) {
	storage := newFakeStorage()
	store := testStore(storage)

	store.Save(rcxEmptySnapshot(), time.Unix(1_700_000_000, 0), true)

	if storage.writes != 0 {
		t.Error("saving before Load would write into whatever bbolt path was bound first")
	}
}

func TestSnapshotStaysCompact(t *testing.T) {
	snapshot := rcxEmptySnapshot()
	snapshot.Picks["w:Home"] = "Amsterdam #3"

	payload, err := json.Marshal(snapshot)
	if err != nil {
		t.Fatalf("marshal: %v", err)
	}

	// One key holds everything because SetStorage cursor-scans the whole bucket
	// on every write, so payload size costs far less than key count.
	if len(payload) > 640 {
		t.Errorf("payload = %d bytes for one pick, want the short field names to hold", len(payload))
	}
}

func TestStoreKeepsTheTieBreakSeedItHandedOut(t *testing.T) {
	storage := newFakeStorage()
	store := testStore(storage)

	first := store.Load()
	if first.Seed == 0 {
		t.Fatal("no seed: the order tie-break falls back to the subscription's own index for everyone")
	}
	first.Pins["w:Home"] = "endpoint-nl-1"
	store.Save(first, time.Unix(1_700_000_000, 0), true)

	if got := testStore(storage).Load(); got.Seed != first.Seed {
		t.Errorf("seed = %d, want %d: a reshuffle on every start is a reshuffle of the park", got.Seed, first.Seed)
	}
	if got := testStore(storage).Load().Pins["w:Home"]; got != "endpoint-nl-1" {
		t.Errorf("pin = %q, want it to survive the round trip", got)
	}
}
