package main

import (
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

// Real traffic outranks any probe: a censor can answer a marker, but it cannot
// fake the user's own connection succeeding.
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
	rcxReasonHold           rcxReason = "hold"
	rcxReasonIncumbentDead  rcxReason = "incumbent-dead"
	rcxReasonVerdictGain    rcxReason = "verdict-gain"
	rcxReasonLatencyGain    rcxReason = "latency-gain"
	rcxReasonColdStart      rcxReason = "cold-start"
	rcxReasonTerrainChanged rcxReason = "terrain-changed"
	rcxReasonNoCandidate    rcxReason = "no-candidate"
	rcxReasonStranded       rcxReason = "stranded"
	rcxReasonDwellHold      rcxReason = "dwell-hold"
	rcxReasonManualHold     rcxReason = "manual-hold"
)

type rcxFacts struct {
	Origin      rcxOrigin
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
	foreignPrior    rcxVerdict
	domesticPrior   rcxVerdict
	allowLastResort bool
}

var rcxAdmissionTable = map[rcxTerrain]rcxAdmissionRow{
	rcxTerrainNormal: {
		openWorldProven: rcxVerdictPreferred,
		domesticProven:  rcxVerdictLastResort,
		foreignPrior:    rcxVerdictViable,
		domesticPrior:   rcxVerdictLastResort,
		allowLastResort: false,
	},
	rcxTerrainWhitelist: {
		openWorldProven: rcxVerdictPreferred,
		domesticProven:  rcxVerdictViable,
		foreignPrior:    rcxVerdictViable,
		domesticPrior:   rcxVerdictLastResort,
		allowLastResort: true,
	},
	// A domestic proof outlives the whitelist episode that earned it, so an
	// unmeasured network must not inherit it as viability.
	rcxTerrainUnknown: {
		openWorldProven: rcxVerdictPreferred,
		domesticProven:  rcxVerdictLastResort,
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
	if f.OpenWorld == rcxProofProven {
		return row.openWorldProven
	}
	if f.Domestic == rcxProofProven {
		return row.domesticProven
	}
	if f.Origin == rcxOriginDomestic {
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
	evidence   rcxEvidence
	latBucket  uint8
	challenger bool
	order      uint16
}

// The first component that differs is also the reason a switch happens, so this
// order is the order of the trace vocabulary.
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
	if a.evidence != b.evidence {
		if a.evidence < b.evidence {
			return -1
		}
		return 1
	}
	if a.latBucket != b.latBucket {
		if a.latBucket < b.latBucket {
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

// Bands, not milliseconds: noise narrower than a band cannot move a decision,
// which is a structural flap guard and needs no debounce timer.
func rcxLatBucket(medianMs int, bands []int) uint8 {
	if medianMs <= 0 {
		return uint8(len(bands))
	}
	for i, edge := range bands {
		if medianMs <= edge {
			return uint8(i)
		}
	}
	return uint8(len(bands))
}

type rcxCandidate struct {
	Name       string
	Order      uint16
	Facts      rcxFacts
	Evidence   rcxEvidence
	MedianMs   int
	CoolUntil  time.Time
	InSkeleton bool
	Degraded   bool
}

type rcxPolicy struct {
	LatencyBands        []int
	RequireUDP          bool
	AllowDomesticLast   bool
	DwellSeconds        int
	DegradedBandPenalty uint8
}

type rcxDecisionInput struct {
	Terrain        rcxTerrain
	Incumbent      string
	IncumbentSince time.Time
	ManualHold     bool
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

// A gated node is not a worse candidate, it is not a candidate: folding
// reliability into the ranking is what makes a fast-but-flapping node oscillate.
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
	bands := uint8(len(in.Policy.LatencyBands))
	bucket := rcxLatBucket(c.MedianMs, in.Policy.LatencyBands)
	if c.Degraded {
		bucket = rcxSaturatingAdd(bucket, in.Policy.DegradedBandPenalty, bands)
	}
	return rcxKey{
		verdict:    rcxAdmit(in.Terrain, c.Facts),
		misfit:     rcxMisfit(in.Terrain, c.Facts),
		evidence:   c.Evidence,
		latBucket:  bucket,
		challenger: c.Name != in.Incumbent,
		order:      c.Order,
	}
}

func rcxSaturatingAdd(value, delta, max uint8) uint8 {
	sum := int(value) + int(delta)
	if sum > int(max) {
		return max
	}
	return uint8(sum)
}

func rcxDecide(in rcxDecisionInput) rcxDecision {
	var best *rcxCandidate
	var bestKey rcxKey
	var incumbentKey rcxKey
	incumbentEligible := false

	for i := range in.Candidates {
		c := &in.Candidates[i]
		if !rcxEligible(*c, in) {
			continue
		}
		key := rcxKeyOf(*c, in)
		if c.Name == in.Incumbent {
			incumbentEligible = true
			incumbentKey = key
		}
		if best == nil || rcxCompare(key, bestKey) < 0 {
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
		return rcxDecision{Switch: true, To: best.Name, Reason: rcxReasonColdStart}
	}

	if !incumbentEligible {
		return rcxDecision{
			Switch: true,
			To:     best.Name,
			Reason: rcxReasonIncumbentDead,
			Detail: in.Incumbent,
		}
	}

	if best.Name == in.Incumbent {
		return rcxDecision{Reason: rcxReasonHold, Detail: in.Incumbent}
	}

	if bestKey.verdict > incumbentKey.verdict {
		return rcxDecision{
			Switch: true,
			To:     best.Name,
			Reason: rcxReasonVerdictGain,
			Detail: incumbentKey.verdict.String() + "->" + bestKey.verdict.String(),
		}
	}

	if in.ManualHold {
		return rcxDecision{Reason: rcxReasonManualHold, Detail: in.Incumbent}
	}

	// A verdict gain is a correctness change and never waits; a latency gain is
	// a comfort change, so it waits out the dwell window.
	dwell := time.Duration(in.Policy.DwellSeconds) * time.Second
	if !in.IncumbentSince.IsZero() && in.Now.Sub(in.IncumbentSince) < dwell {
		return rcxDecision{Reason: rcxReasonDwellHold, Detail: in.Incumbent}
	}

	if bestKey.latBucket < incumbentKey.latBucket {
		return rcxDecision{
			Switch: true,
			To:     best.Name,
			Reason: rcxReasonLatencyGain,
			Detail: in.Incumbent,
		}
	}

	return rcxDecision{Reason: rcxReasonHold, Detail: in.Incumbent}
}

type rcxBlock string

const (
	rcxBlockNone         rcxBlock = ""
	rcxBlockAbsent       rcxBlock = "absent"
	rcxBlockNoUDP        rcxBlock = "no-udp"
	rcxBlockCooling      rcxBlock = "cooling"
	rcxBlockDisproven    rcxBlock = "disproven"
	rcxBlockLastResort   rcxBlock = "last-resort-barred"
	rcxBlockTerrainUnfit rcxBlock = "terrain-unfit"
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
		return rcxCompare(a.Key, b.Key) < 0
	})
	return ranked
}
