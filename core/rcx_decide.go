package main

import (
	"encoding/binary"
	"hash/fnv"
	"sort"
	"time"
)

type rcxTerrain uint8

const (
	rcxTerrainUnknown rcxTerrain = iota
	rcxTerrainNormal
	rcxTerrainWhitelist
	rcxTerrainPortal
	rcxTerrainOffline
)

func (t rcxTerrain) String() string {
	switch t {
	case rcxTerrainNormal:
		return "normal"
	case rcxTerrainWhitelist:
		return "whitelist"
	case rcxTerrainPortal:
		return "portal"
	case rcxTerrainOffline:
		return "offline"
	default:
		return "unknown"
	}
}

// A CDN-fronted subscription reports the wrong country, so geography is only a
// prior for ordering: it must never reject a node on its own.
type rcxOrigin uint8

const (
	rcxOriginUnknown rcxOrigin = iota
	rcxOriginForeign
	rcxOriginDomestic
)

func (o rcxOrigin) String() string {
	switch o {
	case rcxOriginForeign:
		return "foreign"
	case rcxOriginDomestic:
		return "domestic"
	default:
		return "unknown"
	}
}

type rcxProof uint8

const (
	rcxProofUnknown rcxProof = iota
	rcxProofProven
	rcxProofDisproven
)

type rcxVerdict uint8

const (
	rcxVerdictReject rcxVerdict = iota
	rcxVerdictLastResort
	rcxVerdictViable
	rcxVerdictPreferred
)

func (v rcxVerdict) String() string {
	switch v {
	case rcxVerdictLastResort:
		return "last-resort"
	case rcxVerdictViable:
		return "viable"
	case rcxVerdictPreferred:
		return "preferred"
	default:
		return "reject"
	}
}

type rcxEvidence uint8

const (
	rcxEvidenceLiveTraffic rcxEvidence = iota
	rcxEvidenceFreshProbe
	rcxEvidenceStaleProbe
	rcxEvidenceNone
)

func (e rcxEvidence) String() string {
	switch e {
	case rcxEvidenceLiveTraffic:
		return "live"
	case rcxEvidenceFreshProbe:
		return "fresh"
	case rcxEvidenceStaleProbe:
		return "stale"
	default:
		return "none"
	}
}

type rcxReason string

const (
	rcxReasonHold              rcxReason = "hold"
	rcxReasonIncumbentDead     rcxReason = "incumbent-dead"
	rcxReasonVerdictGain       rcxReason = "verdict-gain"
	rcxReasonDegraded          rcxReason = "degraded"
	rcxReasonLatencyGain       rcxReason = "latency-gain"
	rcxReasonReliabilityGain   rcxReason = "reliability-gain"
	rcxReasonQualityConfirming rcxReason = "quality-confirming"
	rcxReasonColdStart         rcxReason = "cold-start"
	rcxReasonTerrainChanged    rcxReason = "terrain-changed"
	rcxReasonNoCandidate       rcxReason = "no-candidate"
	rcxReasonStranded          rcxReason = "stranded"
	rcxReasonDwellHold         rcxReason = "dwell-hold"
	rcxReasonMeasuring         rcxReason = "measuring"
	rcxReasonManualHold        rcxReason = "manual-hold"
	rcxReasonPinReturn         rcxReason = "pin-return"
)

type rcxFacts struct {
	Origin      rcxOrigin
	Exit        rcxOrigin
	OpenedOnce  bool
	OpenWorld   rcxProof
	Domestic    rcxProof
	Transit     rcxProof
	SupportsUDP bool
	Breaker     bool
}

// Ranking, never filtering: an open network spends a specialist for nothing, but
// it still wins when it is alone.
func rcxMisfit(terrain rcxTerrain, f rcxFacts) uint8 {
	if terrain == rcxTerrainWhitelist {
		if f.Breaker {
			return 0
		}
		return 1
	}
	if f.Breaker {
		return 1
	}
	return 0
}

// These rows are the entire domestic-node asymmetry: what a domestic node is
// worth, and whether a last-resort pick may be selected at all in this terrain.
type rcxAdmissionRow struct {
	openWorldProven rcxVerdict
	domesticProven  rcxVerdict
	breakerProven   rcxVerdict
	foreignPrior    rcxVerdict
	domesticPrior   rcxVerdict
	allowLastResort bool
}

var rcxAdmissionTable = map[rcxTerrain]rcxAdmissionRow{
	rcxTerrainNormal: {
		openWorldProven: rcxVerdictPreferred,
		domesticProven:  rcxVerdictLastResort,
		breakerProven:   rcxVerdictViable,
		foreignPrior:    rcxVerdictViable,
		domesticPrior:   rcxVerdictLastResort,
		allowLastResort: false,
	},
	rcxTerrainWhitelist: {
		openWorldProven: rcxVerdictPreferred,
		domesticProven:  rcxVerdictViable,
		breakerProven:   rcxVerdictPreferred,
		foreignPrior:    rcxVerdictViable,
		domesticPrior:   rcxVerdictLastResort,
		allowLastResort: true,
	},
	// A domestic proof outlives the whitelist episode that earned it, so an
	// unmeasured network must not inherit it as viability.
	rcxTerrainUnknown: {
		openWorldProven: rcxVerdictPreferred,
		domesticProven:  rcxVerdictLastResort,
		breakerProven:   rcxVerdictViable,
		foreignPrior:    rcxVerdictViable,
		domesticPrior:   rcxVerdictLastResort,
		allowLastResort: true,
	},
}

func rcxAdmit(terrain rcxTerrain, f rcxFacts) rcxVerdict {
	row, ok := rcxAdmissionTable[terrain]
	if !ok {
		return rcxVerdictReject
	}
	if f.Transit == rcxProofDisproven {
		return rcxVerdictReject
	}
	if f.OpenWorld == rcxProofDisproven && f.Domestic != rcxProofProven {
		return rcxVerdictReject
	}
	if f.Exit == rcxOriginDomestic {
		if f.Domestic == rcxProofProven {
			return row.domesticProven
		}
		return row.domesticPrior
	}
	if f.OpenWorld == rcxProofProven {
		if f.Breaker {
			return row.breakerProven
		}
		return row.openWorldProven
	}
	if f.Domestic == rcxProofProven {
		return row.domesticProven
	}
	if f.Exit == rcxOriginUnknown && f.Origin == rcxOriginDomestic && !f.OpenedOnce {
		return row.domesticPrior
	}
	return row.foreignPrior
}

func rcxAllowsLastResort(terrain rcxTerrain, presetAllows bool) bool {
	row, ok := rcxAdmissionTable[terrain]
	if !ok {
		return false
	}
	return row.allowLastResort && presetAllows
}

type rcxKey struct {
	verdict    rcxVerdict
	misfit     uint8
	recurrence int
	degraded   bool
	unproven   bool
	evidence   rcxEvidence
	homeRisk   uint8
	latencyMs  int
	latBucket  uint8
	challenger bool
	order      int
}

func rcxCompare(a, b rcxKey) int {
	if a.verdict != b.verdict {
		if a.verdict > b.verdict {
			return -1
		}
		return 1
	}
	if a.misfit != b.misfit {
		if a.misfit < b.misfit {
			return -1
		}
		return 1
	}
	if a.recurrence != b.recurrence {
		if a.recurrence < b.recurrence {
			return -1
		}
		return 1
	}
	if a.degraded != b.degraded {
		if !a.degraded {
			return -1
		}
		return 1
	}
	if a.unproven != b.unproven {
		if !a.unproven {
			return -1
		}
		return 1
	}
	if a.evidence != b.evidence {
		if a.evidence < b.evidence {
			return -1
		}
		return 1
	}
	if a.homeRisk != b.homeRisk {
		if a.homeRisk < b.homeRisk {
			return -1
		}
		return 1
	}
	if a.latencyMs != b.latencyMs {
		if a.latencyMs < b.latencyMs {
			return -1
		}
		return 1
	}
	if a.challenger != b.challenger {
		if !a.challenger {
			return -1
		}
		return 1
	}
	if a.order != b.order {
		if a.order < b.order {
			return -1
		}
		return 1
	}
	return 0
}

func rcxLatBucket(medianMs int, bands []int) uint8 {
	if medianMs <= 0 {
		return uint8(len(bands) / 2)
	}
	for i, edge := range bands {
		if medianMs <= edge {
			return uint8(i)
		}
	}
	return uint8(len(bands))
}

type rcxCandidate struct {
	Name             string
	Order            int
	Facts            rcxFacts
	Evidence         rcxEvidence
	MedianMs         int
	HostMs           int
	HostAt           time.Time
	HostDead         bool
	CoolUntil        time.Time
	InSkeleton       bool
	Degraded         bool
	Recurrence       int
	QualityConfirmed bool
	Circuit          bool
}

type rcxPolicy struct {
	LatencyBands        []int
	Strategy            string
	RequireUDP          bool
	AllowDomesticLast   bool
	Censoring           bool
	DwellSeconds        int
	DegradedBandPenalty uint8
}

type rcxDecisionInput struct {
	Terrain        rcxTerrain
	Incumbent      string
	IncumbentSince time.Time
	Pin            string
	Candidates     []rcxCandidate
	Policy         rcxPolicy
	Now            time.Time
}

type rcxDecision struct {
	Switch bool
	To     string
	Reason rcxReason
	Detail string
}

func rcxEligible(c rcxCandidate, in rcxDecisionInput) bool {
	if !c.InSkeleton {
		return false
	}
	if in.Policy.RequireUDP && !c.Facts.SupportsUDP {
		return false
	}
	if !c.CoolUntil.IsZero() && in.Now.Before(c.CoolUntil) {
		return false
	}
	if c.HostDead {
		return false
	}
	if c.Circuit && c.Facts.Transit != rcxProofProven {
		return false
	}
	verdict := rcxAdmit(in.Terrain, c.Facts)
	if verdict == rcxVerdictReject {
		return false
	}
	if verdict == rcxVerdictLastResort &&
		!rcxAllowsLastResort(in.Terrain, in.Policy.AllowDomesticLast) {
		return false
	}
	return true
}

func rcxKeyOf(c rcxCandidate, in rcxDecisionInput) rcxKey {
	evidence := c.Evidence
	if evidence == rcxEvidenceFreshProbe {
		evidence = rcxEvidenceLiveTraffic
	}
	recurrence := c.Recurrence
	if recurrence < 2 {
		recurrence = 0
	}
	latencyMs := rcxDiscoveryLatency(c)
	if latencyMs <= 0 {
		latencyMs = int(^uint(0) >> 1)
	}
	return rcxKey{
		verdict:    rcxAdmit(in.Terrain, c.Facts),
		misfit:     rcxMisfit(in.Terrain, c.Facts),
		recurrence: recurrence,
		degraded:   c.Degraded,
		unproven:   c.Facts.Transit != rcxProofProven,
		evidence:   evidence,
		homeRisk:   rcxHomeRisk(in.Policy, c.Facts),
		latencyMs:  latencyMs,
		latBucket:  rcxLatencyBucket(c, in.Policy.LatencyBands),
		challenger: c.Name != in.Incumbent,
		order:      c.Order,
	}
}

func rcxDiscoveryLatency(c rcxCandidate) int {
	if c.MedianMs > 0 {
		return c.MedianMs
	}
	if c.HostMs > 0 && !c.HostDead {
		return c.HostMs
	}
	return 0
}

// Host-ping favours home, so an unmeasured domestic node would latch on latency before a probe exposes it; rank by egress-in-country instead.
func rcxHomeRisk(policy rcxPolicy, f rcxFacts) uint8 {
	if !policy.Censoring {
		return 0
	}
	if f.Transit == rcxProofProven || f.OpenWorld == rcxProofProven {
		return 0
	}
	if f.Exit == rcxOriginForeign {
		return 0
	}
	if f.Exit == rcxOriginDomestic || f.Origin == rcxOriginDomestic {
		return 2
	}
	return 1
}

func rcxLatencyImproves(strategy string, incumbent, challenger int) bool {
	if incumbent <= 0 || challenger <= 0 || challenger >= incumbent {
		return false
	}
	absolute, percent := 30, 20
	if strategy == rcxStrategyStable || strategy == rcxStrategySaver {
		absolute, percent = 50, 30
	}
	gain := incumbent - challenger
	required := incumbent/100*percent + (incumbent%100*percent+99)/100
	return gain >= absolute && gain >= required
}

func rcxLatencyBucket(c rcxCandidate, bands []int) uint8 {
	if c.MedianMs > 0 {
		return rcxLatBucket(c.MedianMs, bands)
	}
	if c.HostDead {
		return uint8(len(bands))
	}
	return rcxLatBucket(c.HostMs, bands)
}

func rcxDecide(in rcxDecisionInput) rcxDecision {
	var best *rcxCandidate
	var bestKey rcxKey
	var incumbentKey rcxKey
	incumbentEligible := false
	var incumbent rcxCandidate
	pinEligible := false
	compare := rcxCompareFor(in.Policy.Strategy)
	for i := range in.Candidates {
		c := &in.Candidates[i]
		if !rcxEligible(*c, in) {
			continue
		}
		key := rcxKeyOf(*c, in)
		if c.Name == in.Pin {
			pinEligible = true
		}
		if c.Name == in.Incumbent {
			incumbentEligible = true
			incumbentKey = key
			incumbent = *c
		}
		if best == nil || compare(key, bestKey) < 0 {
			best = c
			bestKey = key
		}
	}

	if best == nil {
		// A black hole is no worse than routing nowhere and is not an exposure
		// event, while falling back to DIRECT would put real SNI on the wire.
		if in.Incumbent != "" {
			return rcxDecision{Reason: rcxReasonStranded, Detail: in.Incumbent}
		}
		return rcxDecision{Reason: rcxReasonNoCandidate}
	}

	if in.Incumbent == "" {
		to := best.Name
		if pinEligible {
			to = in.Pin
		}
		return rcxDecision{Switch: true, To: to, Reason: rcxReasonColdStart}
	}

	if pinEligible && in.Pin != in.Incumbent {
		return rcxDecision{
			Switch: true,
			To:     in.Pin,
			Reason: rcxReasonPinReturn,
			Detail: in.Incumbent,
		}
	}

	if !incumbentEligible {
		return rcxDecision{
			Switch: true,
			To:     best.Name,
			Reason: rcxReasonIncumbentDead,
			Detail: in.Incumbent,
		}
	}

	if in.Pin == in.Incumbent {
		return rcxDecision{Reason: rcxReasonManualHold, Detail: in.Incumbent}
	}

	if best.Name == in.Incumbent {
		return rcxDecision{Reason: rcxReasonHold, Detail: in.Incumbent}
	}

	// A verdict gain escapes at once only when the incumbent cannot itself reach
	// the open world; one that still can but merely lost tier (a terrain or
	// breaker rerank) is a comfort move and waits out the dwell like any other.
	if bestKey.verdict > incumbentKey.verdict && incumbent.Facts.OpenWorld != rcxProofProven {
		return rcxDecision{
			Switch: true,
			To:     best.Name,
			Reason: rcxReasonVerdictGain,
			Detail: incumbentKey.verdict.String() + "->" + bestKey.verdict.String(),
		}
	}

	// A verdict gain is a correctness change and never waits; a latency gain is
	// a comfort change, so it waits out the dwell window.
	dwell := time.Duration(in.Policy.DwellSeconds) * time.Second
	if !in.IncumbentSince.IsZero() && in.Now.Sub(in.IncumbentSince) < dwell {
		return rcxDecision{Reason: rcxReasonDwellHold, Detail: in.Incumbent}
	}

	reason := rcxReasonHold
	if bestKey.recurrence < incumbentKey.recurrence ||
		bestKey.recurrence == incumbentKey.recurrence && incumbentKey.degraded && !bestKey.degraded {
		reason = rcxReasonReliabilityGain
	} else if rcxLatencyImproves(in.Policy.Strategy, rcxDiscoveryLatency(incumbent), rcxDiscoveryLatency(*best)) {
		reason = rcxReasonLatencyGain
	}
	if reason != rcxReasonHold {
		if !best.QualityConfirmed {
			return rcxDecision{Reason: rcxReasonQualityConfirming, Detail: best.Name}
		}
		return rcxDecision{Switch: true, To: best.Name, Reason: reason, Detail: in.Incumbent}
	}

	return rcxDecision{Reason: rcxReasonHold, Detail: in.Incumbent}
}

func rcxOrderOf(seed uint64, key string) uint16 {
	digest := fnv.New64a()
	var buf [8]byte
	binary.LittleEndian.PutUint64(buf[:], seed)
	// Key first: FNV spreads only the rounds after the last write over the word.
	_, _ = digest.Write([]byte(key))
	_, _ = digest.Write(buf[:])
	return uint16(digest.Sum64() >> 16)
}

func rcxCompareLatency(a, b rcxKey) int {
	a.misfit, b.misfit = 0, 0
	return rcxCompare(a, b)
}

func rcxCompareStable(a, b rcxKey) int {
	return rcxCompare(a, b)
}

func rcxCompareFor(strategy string) func(a, b rcxKey) int {
	switch strategy {
	case rcxStrategyLatency:
		return rcxCompareLatency
	case rcxStrategyStable, rcxStrategySaver:
		return rcxCompareStable
	}
	return rcxCompare
}

type rcxBlock string

const (
	rcxBlockNone            rcxBlock = ""
	rcxBlockAbsent          rcxBlock = "absent"
	rcxBlockNoUDP           rcxBlock = "no-udp"
	rcxBlockCooling         rcxBlock = "cooling"
	rcxBlockProviderCircuit rcxBlock = "provider-circuit"
	rcxBlockDisproven       rcxBlock = "disproven"
	rcxBlockLastResort      rcxBlock = "last-resort-barred"
	rcxBlockTerrainUnfit    rcxBlock = "terrain-unfit"
)

func rcxBlockOf(c rcxCandidate, in rcxDecisionInput) rcxBlock {
	if !c.InSkeleton {
		return rcxBlockAbsent
	}
	if in.Policy.RequireUDP && !c.Facts.SupportsUDP {
		return rcxBlockNoUDP
	}
	if !c.CoolUntil.IsZero() && in.Now.Before(c.CoolUntil) {
		return rcxBlockCooling
	}
	if c.HostDead {
		return rcxBlockDisproven
	}
	if c.Circuit && c.Facts.Transit != rcxProofProven {
		return rcxBlockProviderCircuit
	}
	switch rcxAdmit(in.Terrain, c.Facts) {
	case rcxVerdictReject:
		if _, ok := rcxAdmissionTable[in.Terrain]; !ok {
			return rcxBlockTerrainUnfit
		}
		return rcxBlockDisproven
	case rcxVerdictLastResort:
		if !rcxAllowsLastResort(in.Terrain, in.Policy.AllowDomesticLast) {
			return rcxBlockLastResort
		}
	}
	return rcxBlockNone
}

type rcxRanked struct {
	Candidate rcxCandidate
	Key       rcxKey
	Block     rcxBlock
}

// The decision's own key and order: a second ordering would drift from it.
func rcxRank(in rcxDecisionInput) []rcxRanked {
	compare := rcxCompareFor(in.Policy.Strategy)
	ranked := make([]rcxRanked, 0, len(in.Candidates))
	for _, c := range in.Candidates {
		ranked = append(ranked, rcxRanked{
			Candidate: c,
			Key:       rcxKeyOf(c, in),
			Block:     rcxBlockOf(c, in),
		})
	}
	sort.SliceStable(ranked, func(i, j int) bool {
		a, b := ranked[i], ranked[j]
		if (a.Block == rcxBlockNone) != (b.Block == rcxBlockNone) {
			return a.Block == rcxBlockNone
		}
		return compare(a.Key, b.Key) < 0
	})
	return ranked
}
