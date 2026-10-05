package rcx

import (
	"testing"
	"time"
)

func TestPublishedStatusCarriesLinkOutcomes(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("a")
	engine := newTestEngine(runtime, "ru")
	engine.reachF, engine.reachD, engine.reachS = rcxProbeOK, rcxProbeOK, rcxProbeFail
	engine.reconsider()
	got := runtime.lastStatus()
	if got.Link.Foreign != "ok" || got.Link.Domestic != "ok" || got.Link.SNI != "fail" {
		t.Fatalf("link = %+v, want the canary outcomes on the pushed status", got.Link)
	}
}

func TestShortHintsDemandWholeToken(t *testing.T) {
	for _, tc := range []struct {
		name, needle string
		want         bool
	}{
		{"rus-1", "rus", true},
		{"rus", "rus", true},
		{"ruse", "rus", false},
		{"ruslan", "rus", false},
		{"brussels", "rus", false},
		{"de-ru", "ru", true},
		{"ru-1", "ru", true},
		{"surf", "ru", false},
		{"permask", "rf", false},
		{"lte-1", "lte", true},
		{"volte", "lte", false},
		{"bolted", "lte", false},
		{"russia", "russia", true},
		{"russian relay", "russia", true},
		{"москва 3", "москва", true},
		{"spb-2", "spb", true},
		{"spb", "spb", true},
	} {
		if got := rcxTokenContains(tc.name, tc.needle); got != tc.want {
			t.Errorf("tokenContains(%q, %q) = %v, want %v", tc.name, tc.needle, got, tc.want)
		}
	}
}

func TestNameHomeCapsPreferredAtLastResort(t *testing.T) {
	for _, terrain := range []rcxTerrain{rcxTerrainNormal, rcxTerrainWhitelist, rcxTerrainUnknown} {
		facts := foreignProven()
		facts.NameHome = true
		if got := rcxAdmit(terrain, facts); got != rcxVerdictLastResort {
			t.Errorf("terrain %v verdict = %v, want last-resort: a filtered home node competes last", terrain, got)
		}
	}
	branded := foreignProven()
	branded.Trust = rcxTrustBranded
	branded.NameHome = true
	if got := rcxAdmit(rcxTerrainWhitelist, branded); got != rcxVerdictReject {
		t.Errorf("branded verdict = %v, want reject: the brand still outranks the filter", got)
	}
}

func TestDisplayCountryPrefersFilterOverMmdb(t *testing.T) {
	ledger := newRcxLedger(rcxDefaultLedgerPolicy())
	ledger.SetOrigin("n", "ES", rcxOriginForeign)
	if got := ledger.DisplayCountry("n"); got != "ES" {
		t.Fatalf("display = %q, want the mmdb ES tag before any filter verdict", got)
	}
	ledger.SetNameHome("n", "RU")
	if got := ledger.DisplayCountry("n"); got != "RU" {
		t.Fatalf("display = %q, want the filter RU tag, not the mmdb ES guess", got)
	}
	if got := ledger.Country("n"); got != "ES" {
		t.Fatalf("country = %q, want the raw mmdb tag kept for suspicion logic", got)
	}
	ledger.SetNameHome("n", "DE")
	if got := ledger.DisplayCountry("n"); got != "RU" {
		t.Fatalf("display = %q, want first verdict wins: no flapping between filters", got)
	}
}

func TestAssessTrustRecordsFilterHome(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("rus-1", "nl-1")
	engine := newTestEngine(runtime, "ru")
	engine.cfg.NameHints = []string{"rus"}
	engine.candidates(runtime.Members())
	if !engine.ledger.NameHome(engine.key("rus-1")) {
		t.Fatal("rus-1 is not filter-home: the hint must stick beyond the trust verdict")
	}
	if got := engine.ledger.DisplayCountry(engine.key("rus-1")); got != "RU" {
		t.Fatalf("display = %q, want the RU filter code instead of an empty mmdb tag", got)
	}
	if engine.ledger.NameHome(engine.key("nl-1")) {
		t.Fatal("nl-1 is filter-home: a clean name must not be named")
	}
}

func TestColdStartPrefersClosestHostPing(t *testing.T) {
	far := rcxNode("far", foreignProven())
	far.MedianMs, far.HostMs, far.Order = 100, 200, 0
	near := rcxNode("near", foreignProven())
	near.MedianMs, near.HostMs, near.Order = 100, 40, 1
	got := rcxDecideAt(rcxDecisionInput{Candidates: []rcxCandidate{far, near}})
	if !got.Switch || got.To != "near" || got.Reason != rcxReasonColdStart {
		t.Fatalf("decision = %+v, want the closer entry ping, not subscription order", got)
	}
	near.HostDead = true
	got = rcxDecideAt(rcxDecisionInput{Candidates: []rcxCandidate{far, near}})
	if !got.Switch || got.To != "far" {
		t.Fatalf("decision = %+v, want a dead entry ping skipped", got)
	}
}

func TestEscapeAtCeilingBoundary(t *testing.T) {
	policy := rcxPolicy{LatencyBands: []int{80, 120, 180, 320}, AbsCeilingMs: 300}
	slow := rcxNode("slow", foreignProven())
	fast := rcxNode("fast", foreignProven())
	fast.MedianMs = 60
	slow.MedianMs = 300
	if !rcxEscapesSlowIncumbent(policy, slow, fast) {
		t.Fatal("300ms does not escape a 300ms ceiling: at-ceiling is too slow, not usable")
	}
	slow.MedianMs = 299
	if rcxEscapesSlowIncumbent(policy, slow, fast) {
		t.Fatal("299ms escapes a 300ms ceiling: under-ceiling keeps its dwell")
	}
}

func qualityEngine(t *testing.T, from, to string) (*rcxEngine, string, string) {
	t.Helper()
	runtime := newFakeRuntime()
	runtime.members = foreignMembers(from, to)
	engine := newTestEngine(runtime, "ru")
	engine.syncIdentity(runtime.members)
	engine.incumbent = from
	return engine, engine.key(from), engine.key(to)
}

func TestFinishQualityMissKeepsRounds(t *testing.T) {
	engine, fromKey, toKey := qualityEngine(t, "a", "b")
	now := time.Unix(1_700_000_000, 0)
	engine.quality = rcxQualityCheck{
		From: fromKey, To: toKey, Marker: "m", Env: engine.envKey,
		Epoch: engine.envSince.UnixNano(), Config: engine.configGen,
		Rounds: 1, Last: now.Add(-time.Minute),
	}
	engine.probeResults = []rcxProbeResult{
		{Node: "a", Key: fromKey, Role: rcxRoleOpen, Outcome: rcxProbeOK, Fingerprint: "m", DelayMs: 300},
	}
	engine.finishQuality(now)
	if engine.quality.Rounds != 1 {
		t.Fatalf("rounds = %d, want 1: a missed challenger round earns nothing but wipes nothing", engine.quality.Rounds)
	}

	engine.probeResults = nil
	engine.finishQuality(now)
	if engine.quality.Rounds != 1 {
		t.Fatalf("rounds = %d, want 1: an empty wave must not zero earned rounds", engine.quality.Rounds)
	}

	engine.probeResults = []rcxProbeResult{
		{Node: "a", Key: fromKey, Role: rcxRoleOpen, Outcome: rcxProbeOK, Fingerprint: "m", DelayMs: 60},
		{Node: "b", Key: toKey, Role: rcxRoleOpen, Outcome: rcxProbeOK, Fingerprint: "m", DelayMs: 300},
	}
	engine.finishQuality(now)
	if engine.quality.Rounds != 0 {
		t.Fatalf("rounds = %d, want 0: a measured slower challenger refutes the escape", engine.quality.Rounds)
	}
}

func TestQueueQualityCarriesRoundsInsideBand(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("cur", "old", "new", "far")
	engine := newTestEngine(runtime, "ru")
	engine.syncIdentity(runtime.members)
	engine.incumbent = "cur"
	now := runtime.Now()
	marker := rcxMarkerID(rcxRoleOpen, engine.cfg.OpenMarkers[0])
	engine.quality = rcxQualityCheck{
		From: engine.key("cur"), To: engine.key("old"), Marker: marker, Env: engine.envKey,
		Epoch: engine.envSince.UnixNano(), Config: engine.configGen,
		Rounds: 1, Last: now,
	}
	old := rcxNode("old", foreignProven())
	old.MedianMs = 60
	same := rcxNode("new", foreignProven())
	same.MedianMs = 70
	far := rcxNode("far", foreignProven())
	far.MedianMs = 200
	candidates := []rcxCandidate{old, same, far}
	policy := engine.cfg.policy()

	engine.queueQuality("new", candidates, policy)
	if engine.quality.To != engine.key("new") || engine.quality.Rounds != 1 {
		t.Fatalf("quality = %+v, want retarget inside the band with rounds kept", engine.quality)
	}
	engine.queueQuality("far", candidates, policy)
	if engine.quality.To != engine.key("far") || engine.quality.Rounds != 0 {
		t.Fatalf("quality = %+v, want a fresh check across bands", engine.quality)
	}
}

func TestQualityRepinOnQuarantine(t *testing.T) {
	engine, fromKey, toKey := qualityEngine(t, "a", "b")
	now := time.Unix(1_700_000_000, 0)
	engine.quality = rcxQualityCheck{
		From: fromKey, To: toKey, Marker: "dead-marker", Env: engine.envKey,
		Epoch: engine.envSince.UnixNano(), Config: engine.configGen,
		Rounds: 1, Last: now,
	}
	engine.snapshot.Quarantines["dead-marker"] = rcxMarkerQuarantine{Until: now.Add(10 * time.Minute)}
	if !engine.startQualityProbe(false) {
		t.Fatal("quality refused to start: a quarantined marker must re-pin, not freeze the escape")
	}
	if engine.markerQuarantined(engine.quality.Marker, now) {
		t.Fatalf("marker = %q, want a live one", engine.quality.Marker)
	}
	if engine.quality.Rounds != 0 {
		t.Fatalf("rounds = %d, want 0: rounds belong to the old marker", engine.quality.Rounds)
	}
	if !engine.probing {
		t.Fatal("no wave started after the re-pin")
	}
}

func TestSuspectCheckBatchesAfterIncumbent(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("a", "b", "c", "d", "e", "f")
	engine := newTestEngine(runtime, "ru")
	engine.cfg.CountryEchoes = []string{"https://echo.example/"}
	engine.incumbent = "a"
	if !engine.startSuspectCheck() {
		t.Fatal("incumbent without a measured exit must be verified first")
	}
	if len(engine.locateAt) != 1 || engine.locateAt[engine.key("a")].IsZero() {
		t.Fatalf("locateAt = %v, want the incumbent alone first", engine.locateAt)
	}
	engine.probing = false
	if !engine.startSuspectCheck() {
		t.Fatal("park verification must continue in batches")
	}
	if len(engine.locateAt) != 1+rcxLocateBatch {
		t.Fatalf("locateAt covers %d nodes, want 1 incumbent + %d batched", len(engine.locateAt), rcxLocateBatch)
	}
	if _, ok := engine.locateAt[engine.key("f")]; ok {
		t.Fatalf("locateAt = %v, want the tail left for the next turn", engine.locateAt)
	}
}

func TestImprovementDiscoversWhileSuspected(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("a", "b", "c", "d", "e")
	engine := newTestEngine(runtime, "ru")
	engine.incumbent = "a"
	engine.ledger.NoteDegraded(engine.key("a"), engine.envKey, runtime.Now())
	if !engine.startImprovement(true) {
		t.Fatal("a stalling incumbent must not pause learning")
	}
	if !engine.probing || engine.probeKind != rcxWaveDiscover {
		t.Fatalf("probing = %v kind = %v, want a narrow discovery wave", engine.probing, engine.probeKind)
	}
	if got := len(engine.discoveryState().Deferred); got != rcxSuspectedDiscoveryWidth {
		t.Fatalf("deferred = %d, want %d unseen nodes, not the stalled incumbent", got, rcxSuspectedDiscoveryWidth)
	}
}

func TestSlowEscapeNeeded(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("slow", "fast")
	engine := newTestEngine(runtime, "ru")
	engine.syncIdentity(runtime.members)
	engine.incumbent = "slow"
	now := runtime.Now()
	marker := rcxMarkerID(rcxRoleOpen, engine.cfg.OpenMarkers[0])
	engine.ledger.NoteQualitySample(engine.key("slow"), engine.envKey, marker, engine.qualityEpoch(), 400, now)
	if !engine.slowEscapeNeeded(runtime.members, now) {
		t.Fatal("a 400ms median past the ceiling must escape briskly")
	}
	other := newFakeRuntime()
	other.members = foreignMembers("slow", "fast")
	calm := newTestEngine(other, "ru")
	calm.syncIdentity(other.members)
	calm.incumbent = "slow"
	calm.ledger.NoteQualitySample(calm.key("slow"), calm.envKey, marker, calm.qualityEpoch(), 100, other.Now())
	if calm.slowEscapeNeeded(other.members, other.Now()) {
		t.Fatal("a 100ms median is not a slow escape")
	}
	runtime.members[0].HostMs = 400
	if !engine.slowEscapeNeeded(runtime.members, now) {
		t.Fatal("an unmeasured 400ms entry ping must escape briskly too")
	}
	engine.incumbent = ""
	if engine.slowEscapeNeeded(runtime.members, now) {
		t.Fatal("no incumbent means no escape")
	}
}
