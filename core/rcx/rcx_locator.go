package rcx

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
// Hints match whole name tokens by prefix, never raw substrings: "rus" must
// catch "RUS-1" but not "Brussels" or "Belarus", the same token rule breaker
// patterns use.
func rcxNameSide(name string, hints []string, censors func(string) bool) (string, rcxOrigin) {
	if code := rcxFlagCountry(name); code != "" {
		if censors(code) {
			return code, rcxOriginDomestic
		}
		return code, rcxOriginForeign
	}
	lower := strings.ToLower(name)
	for _, hint := range hints {
		if hint != "" && rcxTokenContains(lower, strings.ToLower(hint)) {
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
			// The marker leg alone never clears suspicion: telegram answers
			// natively inside RU, so a suspect owes the echo leg's measured
			// exit first. Until the echo answers the node keeps its Suspect
			// and its heavy-check debt (wantsLocate stays true); a measured
			// foreign exit promotes through SetExit instead.
			if !suspect || e.freshExitCountry(key, now) != "" {
				e.ledger.SetTrust(key, rcxTrusted, rcxConfBehavioral, now)
			}
		case leg.openFailed && (suspect || leg.localOK):
			// A definite open FAIL brands a suspect node (or one a home-only marker answered); overloaded never brands.
			e.ledger.SetTrust(key, rcxTrustBranded, rcxConfBehavioral, now)
		}
	}
}

// One locate wave verifies this many nodes: the per-node cost is an echo set,
// and the wave window fits a handful, so the park verifies in batches.
const rcxLocateBatch = 4

func (e *rcxEngine) wantsLocate(name string, now time.Time) bool {
	if name == "" || len(e.cfg.OpenMarkers) == 0 {
		return false
	}
	key := e.key(name)
	if last := e.locateAt[key]; !last.IsZero() && now.Sub(last) < rcxDiscoveryInterval {
		return false
	}
	if trust, _ := e.ledger.Trust(key); trust == rcxTrustSuspect {
		return true
	}
	// A winner the mmdb only guessed gets one quick country-service check before it
	// carries traffic; once its egress is measured it rides its speed uncontested.
	return len(e.cfg.CensorCountries) > 0 && len(e.cfg.CountryEchoes) > 0 &&
		e.freshExitCountry(key, now) == ""
}

func (e *rcxEngine) startSuspectCheck() bool {
	if e.probing || len(e.cfg.OpenMarkers) == 0 {
		return false
	}
	now := e.runtime.Now()
	// The incumbent is verified too, and first: a node carrying traffic on an
	// unmeasured exit can be dead behind a live entry, and only a marker probe
	// disproves it so the engine can hand off instead of coasting on entry transit.
	if e.incumbent != "" && e.wantsLocate(e.incumbent, now) {
		return e.startLocate(e.incumbent, now)
	}
	batch := make([]string, 0, rcxLocateBatch)
	for _, member := range e.runtime.Members() {
		if member.Name == e.incumbent || !e.wantsLocate(member.Name, now) {
			continue
		}
		batch = append(batch, member.Name)
		if len(batch) >= rcxLocateBatch {
			break
		}
	}
	return e.startLocateBatch(batch, now)
}

func (e *rcxEngine) startLocate(name string, now time.Time) bool {
	return e.startLocateBatch([]string{name}, now)
}

// A locate wave carries several nodes: the per-node cost is one echo set, and
// the wave window fits it, so the park verifies in handfuls, not one by one.
func (e *rcxEngine) startLocateBatch(names []string, now time.Time) bool {
	seen := map[string]struct{}{}
	wave := make([]rcxProbeNode, 0, len(names))
	for _, name := range names {
		if name == "" {
			continue
		}
		if _, dup := seen[name]; dup {
			continue
		}
		seen[name] = struct{}{}
		wave = append(wave, rcxProbeNode{Name: name, Key: e.key(name)})
	}
	if e.probing || len(wave) == 0 {
		return false
	}
	if e.budget.Remaining(now) < rcxProbeReserve+len(wave) {
		return false
	}
	wave = e.afford(wave, rcxProbeReserve, now)
	if len(wave) == 0 {
		return false
	}
	for _, node := range wave {
		e.locateAt[node.Key] = now
	}
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
