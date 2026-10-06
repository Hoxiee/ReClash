package rcx

// rcxProfileSchema versions the data-driven decision profile wire (ladder,
// strategy profiles, admission rules). A bump rebuilds a stored profile from
// shipped defaults, the way rcxDefaultsVersion invalidates learned facts.
const rcxProfileSchema = 1

// rcxFactField names a node fact an admission condition can read. New signals
// extend the enum plus the reader table below; a token no build knows fails the
// condition closed rather than aborting the walk.
type rcxFactField uint8

const (
	rcxFactTransit rcxFactField = iota
	rcxFactTrust
	rcxFactOpenWorld
	rcxFactDomestic
	rcxFactExit
	rcxFactOrigin
	rcxFactBreaker
	rcxFactOpenedOnce
	rcxFactOpenLapsed
	rcxFactFieldCount
)

func rcxBoolU8(b bool) uint8 {
	if b {
		return 1
	}
	return 0
}

// rcxFactReaders erases each fact to a uint8 so one condition triplet compares any
// enum or bool field. Indexed by field for an allocation-free, hash-free read.
var rcxFactReaders = [rcxFactFieldCount]func(rcxFacts) uint8{
	rcxFactTransit:    func(f rcxFacts) uint8 { return uint8(f.Transit) },
	rcxFactTrust:      func(f rcxFacts) uint8 { return uint8(f.Trust) },
	rcxFactOpenWorld:  func(f rcxFacts) uint8 { return uint8(f.OpenWorld) },
	rcxFactDomestic:   func(f rcxFacts) uint8 { return uint8(f.Domestic) },
	rcxFactExit:       func(f rcxFacts) uint8 { return uint8(f.Exit) },
	rcxFactOrigin:     func(f rcxFacts) uint8 { return uint8(f.Origin) },
	rcxFactBreaker:    func(f rcxFacts) uint8 { return rcxBoolU8(f.Breaker) },
	rcxFactOpenedOnce: func(f rcxFacts) uint8 { return rcxBoolU8(f.OpenedOnce) },
	rcxFactOpenLapsed: func(f rcxFacts) uint8 { return rcxBoolU8(f.OpenLapsed) },
}

type rcxFactOp uint8

const (
	rcxOpIs rcxFactOp = iota
	rcxOpIsNot
)

// rcxAdmitCond is one closed triplet: a field read, an op, and a literal. There is
// no expression tree — a rule's conjunction is its stack of conditions.
type rcxAdmitCond struct {
	Field rcxFactField
	Op    rcxFactOp
	Value uint8
}

func (c rcxAdmitCond) holds(f rcxFacts) bool {
	if c.Field >= rcxFactFieldCount || rcxFactReaders[c.Field] == nil {
		return false
	}
	got := rcxFactReaders[c.Field](f)
	if c.Op == rcxOpIsNot {
		return got != c.Value
	}
	return got == c.Value
}

// rcxAdmitColumn selects one verdict from the active terrain's admission row, so
// the terrain-independent selection logic reuses the per-terrain column values.
type rcxAdmitColumn uint8

const (
	rcxColOpenWorldProven rcxAdmitColumn = iota
	rcxColDomesticProven
	rcxColBreakerProven
	rcxColForeignPrior
	rcxColDomesticPrior
)

func (c rcxAdmitColumn) of(row rcxAdmissionRow) rcxVerdict {
	switch c {
	case rcxColDomesticProven:
		return row.domesticProven
	case rcxColBreakerProven:
		return row.breakerProven
	case rcxColForeignPrior:
		return row.foreignPrior
	case rcxColDomesticPrior:
		return row.domesticPrior
	default:
		return row.openWorldProven
	}
}

// rcxAdmitOutcome is either a fixed verdict (a hard reject or last-resort cap) or a
// reference to a terrain-row column resolved at evaluation.
type rcxAdmitOutcome struct {
	Verdict    rcxVerdict
	Column     rcxAdmitColumn
	FromColumn bool
}

func (o rcxAdmitOutcome) resolve(row rcxAdmissionRow) rcxVerdict {
	if o.FromColumn {
		return o.Column.of(row)
	}
	return o.Verdict
}

type rcxAdmitRule struct {
	When    []rcxAdmitCond
	Outcome rcxAdmitOutcome
}

func (r rcxAdmitRule) matches(f rcxFacts) bool {
	for _, cond := range r.When {
		if !cond.holds(f) {
			return false
		}
	}
	return true
}

func rcxAdmitIs(field rcxFactField, value uint8) rcxAdmitCond {
	return rcxAdmitCond{Field: field, Op: rcxOpIs, Value: value}
}

func rcxAdmitIsNot(field rcxFactField, value uint8) rcxAdmitCond {
	return rcxAdmitCond{Field: field, Op: rcxOpIsNot, Value: value}
}

func rcxAdmitVerdict(v rcxVerdict) rcxAdmitOutcome { return rcxAdmitOutcome{Verdict: v} }

func rcxAdmitFromColumn(c rcxAdmitColumn) rcxAdmitOutcome {
	return rcxAdmitOutcome{Column: c, FromColumn: true}
}

// rcxDefaultAdmitRules is the shipped admission ladder as data: the first matching
// rule wins. The three leading rejects are the safety floor (branded, transit- and
// open-disproven) that no terrain or profile relaxes; the rest resolve a tier from
// the active terrain's row. It reproduces the historical rcxAdmitTier if-chain
// one-to-one, exhaustively locked by the legacy oracle test.
func rcxDefaultAdmitRules() []rcxAdmitRule {
	return []rcxAdmitRule{
		{When: []rcxAdmitCond{rcxAdmitIs(rcxFactTransit, uint8(rcxProofDisproven))}, Outcome: rcxAdmitVerdict(rcxVerdictReject)},
		{When: []rcxAdmitCond{rcxAdmitIs(rcxFactTrust, uint8(rcxTrustBranded))}, Outcome: rcxAdmitVerdict(rcxVerdictReject)},
		{When: []rcxAdmitCond{rcxAdmitIs(rcxFactOpenWorld, uint8(rcxProofDisproven)), rcxAdmitIsNot(rcxFactDomestic, uint8(rcxProofProven))}, Outcome: rcxAdmitVerdict(rcxVerdictReject)},
		{When: []rcxAdmitCond{rcxAdmitIs(rcxFactExit, uint8(rcxOriginDomestic)), rcxAdmitIs(rcxFactDomestic, uint8(rcxProofProven))}, Outcome: rcxAdmitFromColumn(rcxColDomesticProven)},
		{When: []rcxAdmitCond{rcxAdmitIs(rcxFactExit, uint8(rcxOriginDomestic))}, Outcome: rcxAdmitFromColumn(rcxColDomesticPrior)},
		{When: []rcxAdmitCond{rcxAdmitIs(rcxFactOpenWorld, uint8(rcxProofProven)), rcxAdmitIs(rcxFactBreaker, 1)}, Outcome: rcxAdmitFromColumn(rcxColBreakerProven)},
		{When: []rcxAdmitCond{rcxAdmitIs(rcxFactOpenWorld, uint8(rcxProofProven)), rcxAdmitIs(rcxFactTrust, uint8(rcxTrustSuspect)), rcxAdmitIs(rcxFactExit, uint8(rcxOriginUnknown))}, Outcome: rcxAdmitVerdict(rcxVerdictLastResort)},
		{When: []rcxAdmitCond{rcxAdmitIs(rcxFactOpenWorld, uint8(rcxProofProven))}, Outcome: rcxAdmitFromColumn(rcxColOpenWorldProven)},
		{When: []rcxAdmitCond{rcxAdmitIs(rcxFactOpenedOnce, 1), rcxAdmitIsNot(rcxFactOpenWorld, uint8(rcxProofDisproven)), rcxAdmitIs(rcxFactOpenLapsed, 0), rcxAdmitIsNot(rcxFactOrigin, uint8(rcxOriginDomestic)), rcxAdmitIs(rcxFactBreaker, 1)}, Outcome: rcxAdmitFromColumn(rcxColBreakerProven)},
		{When: []rcxAdmitCond{rcxAdmitIs(rcxFactOpenedOnce, 1), rcxAdmitIsNot(rcxFactOpenWorld, uint8(rcxProofDisproven)), rcxAdmitIs(rcxFactOpenLapsed, 0), rcxAdmitIsNot(rcxFactOrigin, uint8(rcxOriginDomestic))}, Outcome: rcxAdmitFromColumn(rcxColOpenWorldProven)},
		{When: []rcxAdmitCond{rcxAdmitIs(rcxFactDomestic, uint8(rcxProofProven))}, Outcome: rcxAdmitFromColumn(rcxColDomesticProven)},
		{When: []rcxAdmitCond{rcxAdmitIs(rcxFactExit, uint8(rcxOriginUnknown)), rcxAdmitIs(rcxFactOrigin, uint8(rcxOriginDomestic)), rcxAdmitIs(rcxFactOpenedOnce, 0)}, Outcome: rcxAdmitFromColumn(rcxColDomesticPrior)},
		{When: nil, Outcome: rcxAdmitFromColumn(rcxColForeignPrior)},
	}
}

var rcxAdmitRulesDefault = rcxDefaultAdmitRules()

// rcxAdmitByRules walks the rules first-match over the active terrain's row. A
// terrain with no row rejects outright, as before any fact is read.
func rcxAdmitByRules(terrain rcxTerrain, f rcxFacts, rules []rcxAdmitRule) rcxVerdict {
	row, ok := rcxAdmissionTable[terrain]
	if !ok {
		return rcxVerdictReject
	}
	for _, rule := range rules {
		if rule.matches(f) {
			return rule.Outcome.resolve(row)
		}
	}
	return rcxVerdictReject
}
