package main

import (
	"strings"
	"time"
)

// A name or flag only triggers a re-measure here; the verdict is a measurement's alone.
type rcxConfidence uint8

const (
	rcxConfNone       rcxConfidence = iota // nothing observed
	rcxConfPrior                           // mmdb origin or the node's own name
	rcxConfMeasured                        // egress echo saw the real exit IP
	rcxConfBehavioral                      // blocked-vs-local reachability agreed
)

func (c rcxConfidence) String() string {
	switch c {
	case rcxConfPrior:
		return "prior"
	case rcxConfMeasured:
		return "measured"
	case rcxConfBehavioral:
		return "behavioral"
	default:
		return "none"
	}
}

type rcxTrust uint8

const (
	rcxTrustUnknown rcxTrust = iota
	rcxTrustSuspect          // cheap signals disagree; owes a heavy check before trust
	rcxTrusted               // measured foreign exit
	rcxTrustBranded          // measured on the censored side; its opinion is dropped
)

func (t rcxTrust) String() string {
	switch t {
	case rcxTrustSuspect:
		return "suspect"
	case rcxTrusted:
		return "trusted"
	case rcxTrustBranded:
		return "branded"
	default:
		return "unknown"
	}
}

type rcxLocatorVerdict struct {
	Country         string
	Side            rcxOrigin
	Confidence      rcxConfidence
	Trust           rcxTrust
	NeedsHeavyCheck bool
}

// The first regional-indicator pair anywhere in the name wins (🇷🇺 -> "RU").
func rcxFlagCountry(name string) string {
	const base = 0x1F1E6
	var first rune
	for _, r := range name {
		if r < base || r > base+25 {
			first = 0
			continue
		}
		letter := rune('A' + (r - base))
		if first == 0 {
			first = letter
			continue
		}
		return string([]rune{first, letter})
	}
	return ""
}

// rcxNameSide reads the flag the label carries, then any strategy keyword it contains.
func rcxNameSide(name string, hints []string, censors func(string) bool) (string, rcxOrigin) {
	if code := rcxFlagCountry(name); code != "" {
		if censors(code) {
			return code, rcxOriginDomestic
		}
		return code, rcxOriginForeign
	}
	lower := strings.ToLower(name)
	for _, hint := range hints {
		if hint != "" && strings.Contains(lower, hint) {
			return "", rcxOriginDomestic
		}
	}
	return "", rcxOriginUnknown
}

// finishLocate reads a locate wave's two legs per node: an open marker that
// answered proves escape (Trusted); a blocked open with a reachable local-only
// service is a node stuck on the censored side (Branded). Both failing says nothing.
func (e *rcxEngine) finishLocate(now time.Time) {
	type legs struct{ openOK, openFailed, localOK bool }
	byNode := map[string]*legs{}
	for _, r := range e.probeResults {
		leg := byNode[r.Key]
		if leg == nil {
			leg = &legs{}
			byNode[r.Key] = leg
		}
		switch r.Role {
		case rcxRoleOpen:
			leg.openOK = leg.openOK || r.Outcome == rcxProbeOK
			leg.openFailed = leg.openFailed ||
				r.Outcome == rcxProbeFail || r.Outcome == rcxProbeStatusMismatch
		case rcxRoleLocal:
			leg.localOK = leg.localOK || r.Outcome == rcxProbeOK
		}
	}
	for key, leg := range byNode {
		suspect := false
		if trust, _ := e.ledger.Trust(key); trust == rcxTrustSuspect {
			suspect = true
		}
		switch {
		case leg.openOK:
			e.ledger.SetTrust(key, rcxTrusted, rcxConfBehavioral, now)
		case leg.openFailed && (suspect || leg.localOK):
			// A definite open FAIL brands a suspect node (or one a home-only marker answered); overloaded never brands.
			e.ledger.SetTrust(key, rcxTrustBranded, rcxConfBehavioral, now)
		}
	}
}

func (e *rcxEngine) wantsLocate(name string, now time.Time) bool {
	if name == "" || len(e.cfg.OpenMarkers) == 0 {
		return false
	}
	key := e.key(name)
	if trust, _ := e.ledger.Trust(key); trust != rcxTrustSuspect {
		return false
	}
	last := e.locateAt[key]
	return last.IsZero() || now.Sub(last) >= rcxDiscoveryInterval
}

func (e *rcxEngine) startSuspectCheck() bool {
	if e.probing || len(e.cfg.OpenMarkers) == 0 {
		return false
	}
	now := e.runtime.Now()
	for _, member := range e.runtime.Members() {
		if member.Name != e.incumbent && e.wantsLocate(member.Name, now) {
			return e.startLocate(member.Name, now)
		}
	}
	return false
}

func (e *rcxEngine) startLocate(name string, now time.Time) bool {
	if e.probing {
		return false
	}
	node := rcxProbeNode{Name: name, Key: e.key(name)}
	if e.budget.Remaining(now) < rcxProbeReserve+2 {
		return false
	}
	wave := e.afford([]rcxProbeNode{node}, rcxProbeReserve, now)
	if len(wave) != 1 {
		e.budget.Refund(len(wave))
		e.paidWave = 0
		return false
	}
	e.locateAt[node.Key] = now
	e.startProbeWave(wave, rcxWaveLocate, "")
	return e.probing
}

// rcxCheapAssess fuses the zero-cost signals; it can only raise Suspect, never grant trust.
func rcxCheapAssess(
	mmdbSide rcxOrigin,
	mmdbCode string,
	name string,
	hints []string,
	censoring bool,
	censors func(string) bool,
) rcxLocatorVerdict {
	nameCode, nameSide := rcxNameSide(name, hints, censors)
	verdict := rcxLocatorVerdict{Country: mmdbCode, Side: mmdbSide}
	if mmdbSide != rcxOriginUnknown || nameSide != rcxOriginUnknown {
		verdict.Confidence = rcxConfPrior
	}
	if verdict.Country == "" {
		verdict.Country = nameCode
	}
	if !censoring {
		return verdict
	}
	disagrees := nameSide != rcxOriginUnknown && mmdbSide != rcxOriginUnknown && nameSide != mmdbSide
	homeHinted := nameSide == rcxOriginDomestic || mmdbSide == rcxOriginDomestic
	if disagrees || homeHinted {
		verdict.Trust = rcxTrustSuspect
		verdict.NeedsHeavyCheck = true
	}
	return verdict
}
