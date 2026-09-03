package main

import (
	"encoding/json"
	"sync"
	"time"

	"github.com/metacubex/mihomo/component/profile/cachefile"
	"github.com/metacubex/mihomo/log"
)

const (
	rcxStoreKey      = "rcx.v1"
	rcxStoreVersion  = 1
	rcxFlushDebounce = 30 * time.Second
)

// One key, not one per network: SetStorage cursor-scans and decodes the whole
// bucket on every write, so key count costs more than payload size.
type rcxSnapshot struct {
	Version int                               `json:"v"`
	Config  rcxConfig                         `json:"cfg"`
	Global  map[string]*rcxNodeGlobal         `json:"g"`
	Envs    map[string]map[string]*rcxNodeEnv `json:"e"`
	Picks   map[string]string                 `json:"p"`
	Regimes map[string]rcxRegimeMemory        `json:"r"`
	Dirty   bool                              `json:"d"`
}

type rcxRegimeMemory struct {
	Terrain rcxTerrain `json:"t"`
	At      time.Time  `json:"a"`
}

type rcxStorage interface {
	Get(key string) []byte
	Set(key string, value []byte)
}

type rcxCacheStorage struct{}

func (rcxCacheStorage) Get(key string) []byte {
	return cachefile.Cache().GetStorage(key)
}

func (rcxCacheStorage) Set(key string, value []byte) {
	cachefile.Cache().SetStorage(key, value)
}

type rcxStore struct {
	mu       sync.Mutex
	storage  rcxStorage
	pending  bool
	lastSave time.Time
	loaded   bool
}

func newRcxStore() *rcxStore {
	return &rcxStore{storage: rcxCacheStorage{}}
}

// Must not run before handleInitClash sets the home dir: cachefile.Cache() binds
// its bbolt path through a sync.Once and would latch onto the wrong location.
func (s *rcxStore) Load() *rcxSnapshot {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.loaded = true

	return rcxDecodeSnapshot(s.storage.Get(rcxStoreKey))
}

func rcxDecodeSnapshot(raw []byte) *rcxSnapshot {
	if len(raw) == 0 {
		return rcxEmptySnapshot()
	}
	snapshot := &rcxSnapshot{}
	if err := json.Unmarshal(raw, snapshot); err != nil {
		log.Warnln("[RCX] discarding unreadable state: %s", err.Error())
		return rcxEmptySnapshot()
	}
	if snapshot.Version != rcxStoreVersion {
		log.Infoln("[RCX] discarding state from schema v%d", snapshot.Version)
		return rcxEmptySnapshot()
	}
	rcxFillSnapshot(snapshot)
	return snapshot
}

func rcxEmptySnapshot() *rcxSnapshot {
	snapshot := &rcxSnapshot{Version: rcxStoreVersion, Config: rcxDefaultConfig()}
	rcxFillSnapshot(snapshot)
	return snapshot
}

func rcxFillSnapshot(snapshot *rcxSnapshot) {
	if snapshot.Global == nil {
		snapshot.Global = map[string]*rcxNodeGlobal{}
	}
	if snapshot.Envs == nil {
		snapshot.Envs = map[string]map[string]*rcxNodeEnv{}
	}
	if snapshot.Picks == nil {
		snapshot.Picks = map[string]string{}
	}
	if snapshot.Regimes == nil {
		snapshot.Regimes = map[string]rcxRegimeMemory{}
	}
}

func (s *rcxStore) Save(snapshot *rcxSnapshot, now time.Time, force bool) {
	s.mu.Lock()
	defer s.mu.Unlock()

	if !s.loaded {
		return
	}
	if !force && now.Sub(s.lastSave) < rcxFlushDebounce {
		s.pending = true
		return
	}
	snapshot.Version = rcxStoreVersion
	payload, err := json.Marshal(snapshot)
	if err != nil {
		log.Warnln("[RCX] state encode failed: %s", err.Error())
		return
	}
	s.storage.Set(rcxStoreKey, payload)
	s.pending = false
	s.lastSave = now
	snapshot.Dirty = false
}

func (s *rcxStore) Pending() bool {
	s.mu.Lock()
	defer s.mu.Unlock()
	return s.pending
}
