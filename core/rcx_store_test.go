package main

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
	snapshot.Picks["w:Home"] = "Amsterdam #3"
	snapshot.Regimes["w:Home"] = rcxRegimeMemory{Terrain: rcxTerrainWhitelist, At: now}
	snapshot.Global["Amsterdam #3"] = &rcxNodeGlobal{Origin: rcxOriginForeign, EverGood: true}
	snapshot.Envs["w:Home"] = map[string]*rcxNodeEnv{
		"Amsterdam #3": {OpenWorld: rcxProofProven, LastGoodAt: now},
	}
	store.Save(snapshot, now, true)

	restored := testStore(storage).Load()

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
			if snapshot.Config.Preset != rcxPresetOff {
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

	store.Save(snapshot, now.Add(rcxFlushDebounce+time.Second), false)
	if storage.writes != 2 {
		t.Errorf("writes = %d, want the write once the window passed", storage.writes)
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
	if len(payload) > 512 {
		t.Errorf("payload = %d bytes for one pick, want the short field names to hold", len(payload))
	}
}
