package rcx

import (
	"encoding/json"
	"fmt"
)

// rcxRungID identifies one comparison rung. The token strings returned by
// String() are a cross-language contract with the Dart RoutingRung enum and the
// committed golden ladder fixture: renaming one means moving the fixture and both
// label vocabularies in lockstep.
type rcxRungID uint8

const (
	rcxRungVerdict rcxRungID = iota
	rcxRungMisfit
	rcxRungRecurrence
	rcxRungDegraded
	rcxRungHomeRisk
	rcxRungLatency
	rcxRungEvidence
	rcxRungUnproven
	rcxRungIncumbent
	rcxRungTiebreak
	rcxRungCount
)

// rcxRungInvalid marks a token no build knows; it survives decode so an unknown
// rung fails ladder validation and falls back to the default rather than aborting
// the whole config parse.
const rcxRungInvalid rcxRungID = 255

const rcxRecurrenceFloorDefault = 2

func (id rcxRungID) String() string {
	switch id {
	case rcxRungVerdict:
		return "verdict"
	case rcxRungMisfit:
		return "misfit"
	case rcxRungRecurrence:
		return "recurrence"
	case rcxRungDegraded:
		return "degraded"
	case rcxRungHomeRisk:
		return "homeRisk"
	case rcxRungLatency:
		return "latency"
	case rcxRungEvidence:
		return "evidence"
	case rcxRungUnproven:
		return "unproven"
	case rcxRungIncumbent:
		return "incumbent"
	case rcxRungTiebreak:
		return "tiebreak"
	}
	return ""
}

func rcxRungByToken(token string) (rcxRungID, bool) {
	for id := rcxRungID(0); id < rcxRungCount; id++ {
		if id.String() == token {
			return id, true
		}
	}
	return rcxRungInvalid, false
}

func (id rcxRungID) known() bool { return id < rcxRungCount }

func (id rcxRungID) MarshalJSON() ([]byte, error) {
	token := id.String()
	if token == "" {
		return nil, fmt.Errorf("rcx: unmarshalable rung id %d", uint8(id))
	}
	return json.Marshal(token)
}

func (id *rcxRungID) UnmarshalJSON(data []byte) error {
	var token string
	if err := json.Unmarshal(data, &token); err != nil {
		return err
	}
	parsed, _ := rcxRungByToken(token)
	*id = parsed
	return nil
}

// rcxRungSpec is one editable rung: which criterion, whether it participates, and
// its two tunable thresholds. Direction ("faster wins") is intrinsic to ID and is
// never stored, so a mis-edited spec cannot invert a safety-critical ordering.
type rcxRungSpec struct {
	ID                 rcxRungID `json:"id"`
	Enabled            bool      `json:"on"`
	RecurrenceFloor    int       `json:"rf,omitempty"`
	LatencyToleranceMs int       `json:"lt,omitempty"`
}

func rcxDefaultLadder() []rcxRungSpec {
	return []rcxRungSpec{
		{ID: rcxRungVerdict, Enabled: true},
		{ID: rcxRungMisfit, Enabled: true},
		{ID: rcxRungRecurrence, Enabled: true, RecurrenceFloor: rcxRecurrenceFloorDefault},
		{ID: rcxRungDegraded, Enabled: true},
		{ID: rcxRungHomeRisk, Enabled: true},
		{ID: rcxRungLatency, Enabled: true},
		{ID: rcxRungEvidence, Enabled: true},
		{ID: rcxRungUnproven, Enabled: true},
		{ID: rcxRungIncumbent, Enabled: true},
		{ID: rcxRungTiebreak, Enabled: true},
	}
}

type rcxRungCompareFunc func(a, b rcxKey, spec rcxRungSpec) int

// rcxRungComparators is the criterion catalog: adding a rung is a registry entry
// plus a token. Each fn carries its own intrinsic direction and reads any tunable
// threshold from spec.
var rcxRungComparators = map[rcxRungID]rcxRungCompareFunc{
	rcxRungVerdict:    rcxRungCompareVerdict,
	rcxRungMisfit:     rcxRungCompareMisfit,
	rcxRungRecurrence: rcxRungCompareRecurrence,
	rcxRungDegraded:   rcxRungCompareDegraded,
	rcxRungHomeRisk:   rcxRungCompareHomeRisk,
	rcxRungLatency:    rcxRungCompareLatency,
	rcxRungEvidence:   rcxRungCompareEvidence,
	rcxRungUnproven:   rcxRungCompareUnproven,
	rcxRungIncumbent:  rcxRungCompareIncumbent,
	rcxRungTiebreak:   rcxRungCompareTiebreak,
}

func rcxCmpBoolPrefersFalse(a, b bool) int {
	if a == b {
		return 0
	}
	if !a {
		return -1
	}
	return 1
}

func rcxRecurrenceFloored(recurrence, floor int) int {
	if recurrence < floor {
		return 0
	}
	return recurrence
}

func rcxRungCompareVerdict(a, b rcxKey, _ rcxRungSpec) int {
	if a.verdict == b.verdict {
		return 0
	}
	if a.verdict > b.verdict {
		return -1
	}
	return 1
}

func rcxRungCompareMisfit(a, b rcxKey, _ rcxRungSpec) int {
	switch {
	case a.misfit < b.misfit:
		return -1
	case a.misfit > b.misfit:
		return 1
	}
	return 0
}

func rcxRungCompareRecurrence(a, b rcxKey, spec rcxRungSpec) int {
	ra := rcxRecurrenceFloored(a.recurrence, spec.RecurrenceFloor)
	rb := rcxRecurrenceFloored(b.recurrence, spec.RecurrenceFloor)
	switch {
	case ra < rb:
		return -1
	case ra > rb:
		return 1
	}
	return 0
}

func rcxRungCompareDegraded(a, b rcxKey, _ rcxRungSpec) int {
	return rcxCmpBoolPrefersFalse(a.degraded, b.degraded)
}

func rcxRungCompareHomeRisk(a, b rcxKey, _ rcxRungSpec) int {
	switch {
	case a.homeRisk < b.homeRisk:
		return -1
	case a.homeRisk > b.homeRisk:
		return 1
	}
	return 0
}

// A tolerance band lets the user call latencies within N ms a tie so a lower rung
// (evidence, incumbency) breaks it; the shipped 0 keeps the exact comparison.
func rcxRungCompareLatency(a, b rcxKey, spec rcxRungSpec) int {
	diff := a.latencyMs - b.latencyMs
	if diff < 0 {
		diff = -diff
	}
	if diff <= spec.LatencyToleranceMs {
		return 0
	}
	if a.latencyMs < b.latencyMs {
		return -1
	}
	return 1
}

func rcxRungCompareEvidence(a, b rcxKey, _ rcxRungSpec) int {
	switch {
	case a.evidence < b.evidence:
		return -1
	case a.evidence > b.evidence:
		return 1
	}
	return 0
}

func rcxRungCompareUnproven(a, b rcxKey, _ rcxRungSpec) int {
	return rcxCmpBoolPrefersFalse(a.unproven, b.unproven)
}

func rcxRungCompareIncumbent(a, b rcxKey, _ rcxRungSpec) int {
	return rcxCmpBoolPrefersFalse(a.challenger, b.challenger)
}

func rcxRungCompareTiebreak(a, b rcxKey, _ rcxRungSpec) int {
	switch {
	case a.order < b.order:
		return -1
	case a.order > b.order:
		return 1
	}
	return 0
}

// rcxCompareWith walks the active ladder in order and returns the first rung that
// separates the two keys; disabled or unknown rungs are skipped.
func rcxCompareWith(a, b rcxKey, ladder []rcxRungSpec) int {
	for _, spec := range ladder {
		if !spec.Enabled {
			continue
		}
		fn, ok := rcxRungComparators[spec.ID]
		if !ok {
			continue
		}
		if result := fn(a, b, spec); result != 0 {
			return result
		}
	}
	return 0
}

// rcxLadderForStrategy applies the strategy flavor: lowest-latency drops the misfit
// rung (the specialist bias only a whitelist wants), matching rcxCompareLatency;
// every other strategy runs the ladder as configured.
func rcxLadderForStrategy(ladder []rcxRungSpec, strategy string) []rcxRungSpec {
	if strategy != rcxStrategyLatency {
		return ladder
	}
	out := make([]rcxRungSpec, 0, len(ladder))
	for _, spec := range ladder {
		if spec.ID == rcxRungMisfit {
			continue
		}
		out = append(out, spec)
	}
	return out
}
