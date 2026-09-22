package rcx

import (
	"crypto/rand"
	"encoding/binary"
	"encoding/json"
	"sync"
	"time"

	"github.com/metacubex/mihomo/component/profile/cachefile"
	"github.com/metacubex/mihomo/log"
)

const (
	rcxStoreKey      = "rcx.v2"
	rcxStoreVersion  = 2
	rcxFlushDebounce = 30 * time.Second
)

// One key, not one per network: SetStorage cursor-scans and decodes the whole
// bucket on every write, so key count costs more than payload size.
type rcxSnapshot struct {
	Version      int                               `json:"v"`
	Config       rcxConfig                         `json:"cfg"`
	Global       map[string]*rcxNodeGlobal         `json:"g"`
	Envs         map[string]map[string]*rcxNodeEnv `json:"e"`
	Picks        map[string]string                 `json:"p"`
	Pins         map[string]string                 `json:"pn"`
	LanePicks    map[string]map[string]string      `json:"lp"`
	LaneStandbys map[string]map[string][]string    `json:"ls"`
	IdentitySalt []byte                            `json:"identitySalt,omitempty"`
	Seed         uint64                            `json:"sd"`
	Regimes      map[string]rcxRegimeMemory        `json:"r"`
	Circuits     map[string]rcxProviderCircuit     `json:"pc"`
	Standbys     map[string][]string               `json:"sb"`
	Quarantines  map[string]rcxMarkerQuarantine    `json:"mq"`
	Fingerprints rcxConfigFingerprints             `json:"fp"`
	Metrics      rcxMetricsState                   `json:"mt"`
	Dirty        bool                              `json:"d"`
}

type rcxRegimeMemory struct {
	Terrain rcxTerrain `json:"t"`
	At      time.Time  `json:"a"`
}

type rcxMetricsState struct {
	EnabledMillis      int64 `json:"e,omitempty"`
	AvailableMillis    int64 `json:"a,omitempty"`
	Incidents          int   `json:"i,omitempty"`
	StandbyHits        int   `json:"s,omitempty"`
	ProviderIncidents  int   `json:"p,omitempty"`
	MarkerIncidents    int   `json:"m,omitempty"`
	FailoverMillis     int64 `json:"f,omitempty"`
	Failovers          int   `json:"n,omitempty"`
	LastFailoverMillis int64 `json:"x,omitempty"`
	LastOutageMillis   int64 `json:"l,omitempty"`
	TotalOutageMillis  int64 `json:"o,omitempty"`
	RecoveredOutages   int   `json:"r,omitempty"`
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
	var header struct {
		Version int `json:"v"`
	}
	if err := json.Unmarshal(raw, &header); err != nil {
		log.Warnln("[RCX] discarding unreadable state: %s", err.Error())
		return rcxEmptySnapshot()
	}
	if header.Version != 1 && header.Version != rcxStoreVersion {
		log.Infoln("[RCX] discarding state from schema v%d", header.Version)
		return rcxEmptySnapshot()
	}
	snapshot := &rcxSnapshot{}
	if err := json.Unmarshal(raw, snapshot); err != nil {
		log.Warnln("[RCX] discarding unreadable state: %s", err.Error())
		return rcxEmptySnapshot()
	}
	if header.Version == 1 {
		snapshot.Global = nil
		snapshot.Envs = nil
		snapshot.Standbys = nil
		snapshot.LaneStandbys = nil
		snapshot.Circuits = nil
		snapshot.Quarantines = nil
		snapshot.Dirty = true
	}
	snapshot.Version = rcxStoreVersion
	snapshot.Config.DefaultsVersion = rcxDefaultsVersion
	snapshot.Config = snapshot.Config.normalized()
	rcxFillSnapshot(snapshot)
	return snapshot
}

func rcxEmptySnapshot() *rcxSnapshot {
	snapshot := &rcxSnapshot{Version: rcxStoreVersion, Config: rcxDefaultConfig()}
	snapshot.Fingerprints = snapshot.Config.fingerprints()
	rcxFillSnapshot(snapshot)
	return snapshot
}

func rcxFillSnapshot(snapshot *rcxSnapshot) {
	if len(snapshot.IdentitySalt) != 32 {
		snapshot.IdentitySalt = make([]byte, 32)
		if _, err := rand.Read(snapshot.IdentitySalt); err != nil {
			snapshot.IdentitySalt = nil
		}
	}
	if snapshot.Global == nil {
		snapshot.Global = map[string]*rcxNodeGlobal{}
	}
	if snapshot.Envs == nil {
		snapshot.Envs = map[string]map[string]*rcxNodeEnv{}
	}
	if snapshot.Picks == nil {
		snapshot.Picks = map[string]string{}
	}
	if snapshot.Pins == nil {
		snapshot.Pins = map[string]string{}
	}
	if snapshot.LanePicks == nil {
		snapshot.LanePicks = map[string]map[string]string{}
	}
	if snapshot.LaneStandbys == nil {
		snapshot.LaneStandbys = map[string]map[string][]string{}
	}
	if snapshot.Seed == 0 {
		snapshot.Seed = rcxNewSeed()
	}
	if snapshot.Regimes == nil {
		snapshot.Regimes = map[string]rcxRegimeMemory{}
	}
	if snapshot.Circuits == nil {
		snapshot.Circuits = map[string]rcxProviderCircuit{}
	}
	if snapshot.Standbys == nil {
		snapshot.Standbys = map[string][]string{}
	}
	if snapshot.Quarantines == nil {
		snapshot.Quarantines = map[string]rcxMarkerQuarantine{}
	}
	delete(snapshot.Regimes, "")
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

// Per install, so the last tie-break is not the same answer for everyone.
func rcxNewSeed() uint64 {
	var buf [8]byte
	if _, err := rand.Read(buf[:]); err != nil {
		return uint64(time.Now().UnixNano()) | 1
	}
	return binary.LittleEndian.Uint64(buf[:]) | 1
}
