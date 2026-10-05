package rcx

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
	Origin     rcxOrigin
	Exit       rcxOrigin
	OpenedOnce bool
	OpenWorld  rcxProof
	// OpenWorld was disproven under the current markers and that disproof has since
	// aged to Unknown: the node failed and no fresh probe overturned it, so it is
	// distinct from a node whose success merely aged.
	OpenLapsed  bool
	Domestic    rcxProof
	Transit     rcxProof
	SupportsUDP bool
	Breaker     bool
	Trust       rcxTrust
	// A measured domestic egress that survives an open proof and the Exit TTL.
	HomeEgress bool
	// The name filters place the node home-side: it competes last and shows
	// the filter's country, however the databases geolocate its addresses.
	NameHome bool
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
	verdict := rcxAdmitTier(terrain, f)
	// A filter-named home node competes last however fast it pings: the brand
	// still rejects outright, but nothing promotes it above last resort.
	if f.NameHome && verdict > rcxVerdictLastResort {
		return rcxVerdictLastResort
	}
	return verdict
}

func rcxAdmitTier(terrain rcxTerrain, f rcxFacts) rcxVerdict {
	row, ok := rcxAdmissionTable[terrain]
	if !ok {
		return rcxVerdictReject
	}
	if f.Transit == rcxProofDisproven {
		return rcxVerdictReject
	}
	// A measured censored-side exit is a durable fact about the node, not a stale
	// probe, so a branded node is dropped outright however fast it pings.
	if f.Trust == rcxTrustBranded {
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
		// Suspicion caps a marker-only open at last-resort until the heavy echo
		// check places the exit: a home node telegram-opens natively inside RU.
		if f.Trust == rcxTrustSuspect && f.Exit == rcxOriginUnknown {
			return rcxVerdictLastResort
		}
		return row.openWorldProven
	}
	// An aged proof is not a dead one: a foreign node that already opened the
	// censored world on this network keeps its tier until a probe disproves it, so
	// latency decides between working foreign nodes, not proof-freshness roulette.
	// Restricted to foreign origin so a fronted domestic node stays a mere prior.
	// OpenLapsed excludes a node whose proof aged out of a disproof, not a success:
	// it failed and must re-earn Preferred by a fresh probe, not latch back on a clock.
	if f.OpenedOnce && f.OpenWorld != rcxProofDisproven && !f.OpenLapsed && f.Origin != rcxOriginDomestic {
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

// Test oracle for the plain ranking shape; production uses rcxCompareFor.
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
	if a.homeRisk != b.homeRisk {
		if a.homeRisk < b.homeRisk {
			return -1
		}
		return 1
	}
	// Latency outranks "who is carrying bytes right now": inside one verdict tier
	// the faster node wins, so a busy 200ms node no longer beats an idle 50ms one.
	if a.latencyMs != b.latencyMs {
		if a.latencyMs < b.latencyMs {
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
	if a.unproven != b.unproven {
		if !a.unproven {
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

// Buckets latency for ranking/gates: unmeasured is the slowest band, not mid-table.
func rcxBandIndex(ms int, bands []int) int {
	if ms <= 0 {
		return len(bands)
	}
	for i, edge := range bands {
		if ms <= edge {
			return i
		}
	}
	return len(bands)
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
	Stalled          bool
	// User-rule outcomes, resolved against a candidate's attributes and measured
	// egress before ranking. Ignore/AvoidExit block; LastResort caps the verdict;
	// Prefer only breaks a tie in the node's favour.
	Ignore         bool
	AvoidExit      bool
	RuleLastResort bool
	Prefer         bool
}

type rcxPolicy struct {
	LatencyBands      []int
	Ladder            []rcxRungSpec
	Strategy          string
	RequireUDP        bool
	AllowDomesticLast bool
	Censoring         bool
	DwellSeconds      int
	AbsCeilingMs      int
	SwitchImproveMs   int
	SwitchImprovePct  int
	LatencyStepMs     int
}

func (p rcxPolicy) ladderOrDefault() []rcxRungSpec {
	if len(p.Ladder) == 0 {
		return rcxDefaultLadder()
	}
	return p.Ladder
}

// latencyStep is the rounding/near-tie granularity for latency comparisons; a
// zero (older host, unset config) falls back to the shipped 30ms.
func (p rcxPolicy) latencyStep() int {
	if p.LatencyStepMs > 0 {
		return p.LatencyStepMs
	}
	return rcxLatencyStep
}

// switchThresholds is how much faster a challenger must be to trigger a latency
// switch. Explicit config wins; else the strategy sets the shipped defaults.
func (p rcxPolicy) switchThresholds() (absolute, percent int) {
	absolute, percent = 30, 20
	switch p.Strategy {
	case rcxStrategyLatency:
		absolute, percent = 15, 10
	case rcxStrategyStable, rcxStrategySaver:
		absolute, percent = 50, 30
	}
	if p.SwitchImproveMs > 0 {
		absolute = p.SwitchImproveMs
	}
	if p.SwitchImprovePct > 0 {
		percent = p.SwitchImprovePct
	}
	return absolute, percent
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

func rcxCandidateVerdict(c rcxCandidate, terrain rcxTerrain) rcxVerdict {
	verdict := rcxAdmit(terrain, c.Facts)
	if c.RuleLastResort && verdict > rcxVerdictLastResort {
		return rcxVerdictLastResort
	}
	return verdict
}

func rcxEligible(c rcxCandidate, in rcxDecisionInput) bool {
	if !c.InSkeleton {
		return false
	}
	if c.Ignore || c.AvoidExit {
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
	verdict := rcxCandidateVerdict(c, in.Terrain)
	if verdict == rcxVerdictReject {
		return false
	}
	if verdict == rcxVerdictLastResort &&
		!rcxAllowsLastResort(in.Terrain, in.Policy.AllowDomesticLast) {
		return false
	}
	return true
}

// eligibleInScreen reports whether node, as built into candidates, clears the
// decision input's eligibility gate. requireOpen additionally demands proof the
// node reaches the open world; every screen wants that except lane probe
// replacement, which only needs the node routable.
func eligibleInScreen(candidates []rcxCandidate, in rcxDecisionInput, node string, requireOpen bool) bool {
	for _, candidate := range candidates {
		if candidate.Name == node {
			return rcxEligible(candidate, in) &&
				(!requireOpen || candidate.Facts.OpenWorld == rcxProofProven)
		}
	}
	return false
}

func rcxKeyOf(c rcxCandidate, in rcxDecisionInput) rcxKey {
	evidence := c.Evidence
	if evidence == rcxEvidenceFreshProbe {
		evidence = rcxEvidenceLiveTraffic
	}
	latencyMs := rcxRankingLatency(c, in.Policy)
	if latencyMs <= 0 {
		latencyMs = int(^uint(0) >> 1)
	}
	order := c.Order
	if c.Prefer {
		order -= rcxPreferOrderBoost
	}
	return rcxKey{
		verdict:    rcxCandidateVerdict(c, in.Terrain),
		misfit:     rcxMisfit(in.Terrain, c.Facts),
		recurrence: c.Recurrence,
		degraded:   c.Degraded,
		unproven:   c.Facts.Transit != rcxProofProven,
		evidence:   evidence,
		homeRisk:   rcxHomeRisk(in.Policy, c.Facts),
		latencyMs:  latencyMs,
		latBucket:  rcxLatencyBucket(latencyMs, in.Policy.LatencyBands),
		challenger: c.Name != in.Incumbent,
		order:      order,
	}
}

const rcxPreferOrderBoost = 1 << 20

func rcxDiscoveryLatency(c rcxCandidate) int {
	if c.MedianMs > 0 {
		return c.MedianMs
	}
	if c.HostMs > 0 && !c.HostDead {
		return c.HostMs
	}
	return 0
}

// A measured median ranks truthfully; an unmeasured host-ping (to the entry, not
// the egress) must never outrank it, and rounds to 30ms steps so real gaps
// (50 vs 140) still order while jitter (45 vs 55) ties.
const (
	rcxUnmeasuredLatencyBase = 1 << 20
	rcxLatencyStep           = 30
)

func rcxRankingLatency(c rcxCandidate, policy rcxPolicy) int {
	if c.MedianMs > 0 {
		return c.MedianMs
	}
	unproven := c.Facts.Transit != rcxProofProven && c.Facts.OpenWorld != rcxProofProven
	if policy.Censoring && unproven {
		return 0
	}
	host := rcxDiscoveryLatency(c)
	if host <= 0 {
		return 0
	}
	step := policy.latencyStep()
	// Only a node with proven egress competes on its 30ms-rounded entry ping; entry
	// transit alone no longer crowns the fast band, so a dead exit behind a live
	// entry sinks beneath every measured node instead of winning on host-ping.
	if rcxProvenEgressEver(c.Facts) {
		return host/step*step + step/2
	}
	return rcxUnmeasuredLatencyBase + host/step
}

// True when the node has ever demonstrated a working exit, not merely moved entry
// bytes: an open-world proof, a measured exit country, a home egress, or an aged
// open latch that never lapsed. Stale entry transit does not qualify.
func rcxProvenEgressEver(f rcxFacts) bool {
	return f.OpenWorld == rcxProofProven || f.HomeEgress ||
		f.Exit != rcxOriginUnknown || (f.OpenedOnce && !f.OpenLapsed)
}

func rcxExitsDomestic(f rcxFacts) bool {
	if f.Exit == rcxOriginForeign {
		return false
	}
	return f.HomeEgress || f.Exit == rcxOriginDomestic || f.Origin == rcxOriginDomestic
}

// True when a pin is dialable and only an open-world verdict rejects it, not an operational death.
func rcxPinHoldsThroughBlip(c rcxCandidate, in rcxDecisionInput) bool {
	if c.HostDead || c.Facts.Transit == rcxProofDisproven {
		return false
	}
	if in.Policy.RequireUDP && !c.Facts.SupportsUDP {
		return false
	}
	if !c.CoolUntil.IsZero() && in.Now.Before(c.CoolUntil) {
		return false
	}
	if c.Circuit && c.Facts.Transit != rcxProofProven {
		return false
	}
	// A pin blipping open-world rides the grace only if it ever proved an exit; one
	// measured dead with no working history (never opened, no measured exit) is
	// released so the disproof hands off instead of latching a dead egress forever.
	if c.Facts.OpenWorld == rcxProofDisproven && !rcxProvenEgressEver(c.Facts) {
		return false
	}
	return !c.Ignore && !c.AvoidExit
}

// A fronted home node can open the censored world yet egress in-country, so a
// measured home egress or a suspect flag sinks it before the proven-reaches
// exemption; only a measured foreign egress clears it outright.
func rcxHomeRisk(policy rcxPolicy, f rcxFacts) uint8 {
	if !policy.Censoring {
		return 0
	}
	if f.Exit == rcxOriginForeign {
		return 0
	}
	if f.HomeEgress || f.Trust == rcxTrustSuspect {
		return 2
	}
	if f.Exit == rcxOriginDomestic || f.Origin == rcxOriginDomestic {
		return 2
	}
	if f.Transit == rcxProofProven || f.OpenWorld == rcxProofProven {
		return 0
	}
	return 1
}

// A band crossing is a switch (200->60 yes, 70->60 no); edges are the strategy's.
// An unmeasured incumbent yields to any measured challenger.
func rcxBandImproves(p rcxPolicy, incumbent, best rcxCandidate) bool {
	bands := p.LatencyBands
	if len(bands) == 0 {
		return false
	}
	inc := rcxRankingLatency(incumbent, p)
	alt := rcxRankingLatency(best, p)
	if alt <= 0 {
		return false
	}
	if inc <= 0 {
		return true
	}
	return rcxBandIndex(alt, bands) < rcxBandIndex(inc, bands)
}

// The lower of the absolute ceiling and the slowest band.
func rcxEffectiveCeiling(p rcxPolicy) int {
	ceiling := p.AbsCeilingMs
	if len(p.LatencyBands) > 0 {
		last := p.LatencyBands[len(p.LatencyBands)-1]
		if last > 0 && (ceiling <= 0 || last < ceiling) {
			ceiling = last
		}
	}
	return ceiling
}

// An incumbent at or past the slowest band yields to any node inside the bands
// without the comfort dwell; QualityConfirmed downstream keeps it fast-and-stable.
func rcxEscapesSlowIncumbent(policy rcxPolicy, incumbent, best rcxCandidate) bool {
	ceiling := rcxEffectiveCeiling(policy)
	inc := rcxDiscoveryLatency(incumbent)
	fast := rcxDiscoveryLatency(best)
	return ceiling > 0 && inc >= ceiling && fast > 0 && fast <= ceiling
}

func rcxLatencyImproves(p rcxPolicy, incumbent, challenger int) bool {
	if incumbent <= 0 || challenger <= 0 || challenger >= incumbent {
		return false
	}
	absolute, percent := p.switchThresholds()
	gain := incumbent - challenger
	required := incumbent/100*percent + (incumbent%100*percent+99)/100
	return gain >= absolute && gain >= required
}

// Fail-open on missing data, fail-closed on a real trade-down, compared on the
// ranking latency the order uses (not raw medians that ignore host-ping).
func rcxTradesDown(p rcxPolicy, incumbent, best rcxCandidate) bool {
	inc := rcxRankingLatency(incumbent, p)
	alt := rcxRankingLatency(best, p)
	if inc <= 0 {
		return false
	}
	if alt <= 0 {
		return true
	}
	return alt > inc+p.latencyStep()
}

// Buckets the ranking latency the order uses; unmeasured lands in the slowest band.
func rcxLatencyBucket(rankMs int, bands []int) uint8 {
	return uint8(rcxBandIndex(rankMs, bands))
}

// A confirmed whitelist terrain is itself a censorship signal that arms the full posture.
func rcxEffectiveCensoring(in rcxDecisionInput) bool {
	return in.Policy.Censoring || in.Terrain == rcxTerrainWhitelist
}

func rcxDecide(in rcxDecisionInput) rcxDecision {
	configuredCensoring := in.Policy.Censoring
	in.Policy.Censoring = rcxEffectiveCensoring(in)
	var best *rcxCandidate
	var bestKey rcxKey
	var incumbentKey rcxKey
	incumbentEligible := false
	incumbentPresent := false
	var incumbent rcxCandidate
	var incumbentCand rcxCandidate
	pinEligible := false
	compare := rcxCompareFor(in.Policy)
	for i := range in.Candidates {
		c := &in.Candidates[i]
		if c.Name == in.Incumbent {
			incumbentPresent = true
			incumbentCand = *c
		}
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
		// With no measurements off a censored network, prefer the closest entry
		// ping; under censorship order stands, as a small ping may be a fronted home.
		if !in.Policy.Censoring {
			withoutOrder := func(key rcxKey) rcxKey { key.order = 0; return key }
			bestBare := withoutOrder(bestKey)
			for i := range in.Candidates {
				c := &in.Candidates[i]
				if !rcxEligible(*c, in) || c.HostDead || c.HostMs <= 0 {
					continue
				}
				if compare(withoutOrder(rcxKeyOf(*c, in)), bestBare) != 0 {
					continue
				}
				if best.HostMs <= 0 || best.HostDead || c.HostMs < best.HostMs {
					best = c
					to = c.Name
				}
			}
		}
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

	// A manual pin holds across an open-world blip on its own node instead of auto-
	// switching to a worse egress; an operationally dead pin falls through below.
	if in.Pin == in.Incumbent && incumbentPresent && rcxPinHoldsThroughBlip(incumbentCand, in) {
		return rcxDecision{Reason: rcxReasonManualHold, Detail: in.Incumbent}
	}

	if !incumbentEligible {
		// Only a configured home censor punishes real traffic surfaced at home; a
		// merely measured whitelist leaves a domestic node as a valid last resort.
		if configuredCensoring && incumbentPresent &&
			!rcxExitsDomestic(incumbentCand.Facts) && rcxExitsDomestic(best.Facts) {
			return rcxDecision{Reason: rcxReasonStranded, Detail: in.Incumbent}
		}
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

	// Escape the dwell only when the incumbent truly cannot reach now; live transit
	// or an un-lapsed open latch count as reaching, so a working node that lost tier waits.
	incumbentReaches := incumbent.Facts.OpenWorld == rcxProofProven ||
		incumbent.Facts.Transit == rcxProofProven ||
		incumbent.Facts.OpenedOnce && !incumbent.Facts.OpenLapsed
	if bestKey.verdict > incumbentKey.verdict && !incumbentReaches {
		return rcxDecision{
			Switch: true,
			To:     best.Name,
			Reason: rcxReasonVerdictGain,
			Detail: incumbentKey.verdict.String() + "->" + bestKey.verdict.String(),
		}
	}

	dwell := time.Duration(in.Policy.DwellSeconds) * time.Second
	if !rcxEscapesSlowIncumbent(in.Policy, incumbent, *best) &&
		!in.IncumbentSince.IsZero() && in.Now.Sub(in.IncumbentSince) < dwell {
		return rcxDecision{Reason: rcxReasonDwellHold, Detail: in.Incumbent}
	}

	reason := rcxReasonHold
	// Floor recurrence like the ranking rung, else rank and reason disagree.
	recFloor, recCounts := rcxRecurrenceFloorOf(in.Policy.ladderOrDefault())
	incRecurrence := rcxRecurrenceFloored(incumbentKey.recurrence, recFloor)
	bestRecurrence := rcxRecurrenceFloored(bestKey.recurrence, recFloor)
	reliabilityGain := recCounts && (bestRecurrence < incRecurrence ||
		bestRecurrence == incRecurrence && incumbentKey.degraded && !bestKey.degraded)
	// Escape a degraded incumbent only when trapped — unmeasured egress or stalled payload.
	degradedEscape := incumbentKey.degraded && !bestKey.degraded &&
		(incumbent.MedianMs <= 0 || incumbent.Stalled)
	if reliabilityGain && incumbentReaches && !degradedEscape && rcxTradesDown(in.Policy, incumbent, *best) {
		reliabilityGain = false
	}
	// Past the dwell, a better verdict dislodges even a still-open incumbent.
	verdictGain := bestKey.verdict > incumbentKey.verdict
	if verdictGain {
		reason = rcxReasonVerdictGain
	} else if reliabilityGain {
		reason = rcxReasonReliabilityGain
	} else if rcxBandImproves(in.Policy, incumbent, *best) ||
		best.MedianMs > 0 && rcxLatencyImproves(in.Policy, rcxDiscoveryLatency(incumbent), rcxDiscoveryLatency(*best)) {
		// A measured gain past the thresholds switches inside one band too.
		reason = rcxReasonLatencyGain
	}
	// A live, reaching session is never flipped onto a home or distrusted egress,
	// whatever the gain (incl. a verdict escape); a clean foreign target still passes.
	if reason != rcxReasonHold && incumbentReaches &&
		incumbent.Evidence == rcxEvidenceLiveTraffic && rcxRiskyEgress(best.Facts) {
		reason = rcxReasonHold
	}
	if reason != rcxReasonHold {
		if !best.QualityConfirmed {
			return rcxDecision{Reason: rcxReasonQualityConfirming, Detail: best.Name}
		}
		return rcxDecision{Switch: true, To: best.Name, Reason: reason, Detail: in.Incumbent}
	}

	return rcxDecision{Reason: rcxReasonHold, Detail: in.Incumbent}
}

// A target whose exit changes the apparent country or is distrusted.
func rcxRiskyEgress(f rcxFacts) bool {
	return f.HomeEgress || f.Exit == rcxOriginDomestic || f.NameHome ||
		f.Trust == rcxTrustSuspect
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

// rcxCompareFor builds the active comparator from policy: the configured ladder
// (default when unset) flavored by the strategy.
func rcxCompareFor(p rcxPolicy) func(a, b rcxKey) int {
	ladder := rcxLadderForStrategy(p.ladderOrDefault(), p.Strategy)
	return func(a, b rcxKey) int {
		return rcxCompareWith(a, b, ladder)
	}
}

type rcxBlock string

const (
	rcxBlockNone            rcxBlock = ""
	rcxBlockAbsent          rcxBlock = "absent"
	rcxBlockIgnored         rcxBlock = "ignored"
	rcxBlockAvoidExit       rcxBlock = "avoid-exit"
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
	if c.AvoidExit {
		return rcxBlockAvoidExit
	}
	if c.Ignore {
		return rcxBlockIgnored
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
	switch rcxCandidateVerdict(c, in.Terrain) {
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
	in.Policy.Censoring = rcxEffectiveCensoring(in)
	compare := rcxCompareFor(in.Policy)
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
