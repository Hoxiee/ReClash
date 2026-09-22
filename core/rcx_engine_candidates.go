package main

import (
	"time"
)

type rcxMember struct {
	Name             string
	ID               string
	Provider         string
	Transport        string
	Type             string
	Port             int
	SupportsUDP      bool
	HostMs           int
	HostAt           time.Time
	HostDead         bool
	Order            int
	Ingress          string
	ExternalProvider bool
}

func (m rcxMember) key() string {
	if m.ID != "" {
		return m.ID
	}
	return m.Name
}

// Geography is a prior and nothing else: a node whose address resolves inside the
// censoring country still earns its verdict from behaviour.
// The cheap pass only raises Suspect; a later measurement overrides it and never regresses.
func (e *rcxEngine) assessTrust(name, key string, now time.Time) {
	if trust, _ := e.ledger.Trust(key); trust != rcxTrustUnknown {
		return
	}
	verdict := rcxCheapAssess(
		e.ledger.Origin(key), e.ledger.Country(key), name,
		e.cfg.NameHints, len(e.cfg.CensorCountries) > 0, e.cfg.censors,
	)
	if verdict.Trust == rcxTrustSuspect {
		e.ledger.SetTrust(key, rcxTrustSuspect, rcxConfPrior, now)
	}
}

func (e *rcxEngine) originOf(node string) (string, rcxOrigin) {
	code := e.runtime.Country(node)
	if code == "" {
		return "", rcxOriginUnknown
	}
	return code, e.sideOf(code)
}

func (e *rcxEngine) sideOf(code string) rcxOrigin {
	if e.cfg.censors(code) {
		return rcxOriginDomestic
	}
	return rcxOriginForeign
}

func (e *rcxEngine) isMember(node string) bool {
	e.mu.RLock()
	defer e.mu.RUnlock()
	if e.keys == nil {
		return true
	}
	_, ok := e.keys[node]
	return ok
}

func (e *rcxEngine) key(node string) string {
	e.mu.RLock()
	defer e.mu.RUnlock()
	if key, ok := e.keys[node]; ok {
		return key
	}
	return node
}

func (e *rcxEngine) nameOf(key string) string {
	e.mu.RLock()
	defer e.mu.RUnlock()
	if name, ok := e.names[key]; ok {
		return name
	}
	// A snapshot older than endpoint identity, or a collision, stores the name.
	if _, ok := e.keys[key]; ok {
		return key
	}
	return ""
}

// A record written under a name before the park is read is never found again.
func (e *rcxEngine) ensureIdentity() {
	e.mu.RLock()
	known := e.keys != nil
	e.mu.RUnlock()
	if !known {
		e.syncIdentity(e.runtime.Members())
	}
}

func (e *rcxEngine) orderOf(_ string, declared int) int { return declared }

func (e *rcxEngine) syncIdentity(members []rcxMember) {
	keys := make(map[string]string, len(members))
	names := make(map[string]string, len(members))
	for _, member := range members {
		keys[member.Name] = member.key()
		if _, exists := names[member.key()]; !exists || member.Name == e.incumbent || member.Name == e.runtime.Selected() {
			names[member.key()] = member.Name
		}
	}
	e.mu.Lock()
	e.keys = keys
	e.names = names
	e.mu.Unlock()
}

func (e *rcxEngine) candidates(members []rcxMember) []rcxCandidate {
	return e.candidatesFor(members, e.incumbent)
}

func (e *rcxEngine) candidatesFor(members []rcxMember, incumbent string) []rcxCandidate {
	now := e.runtime.Now()
	e.syncIdentity(members)
	live := time.Duration(rcxLiveWindowSeconds) * time.Second
	fresh := time.Duration(rcxFreshWindowSeconds) * time.Second
	proofTTL := rcxScaledProofTTL(e.ledger.ProofTTL(), len(members))
	candidates := make([]rcxCandidate, 0, len(members))
	for _, member := range members {
		key := member.key()
		if e.ledger.Origin(key) == rcxOriginUnknown {
			country, origin := e.originOf(member.Name)
			e.ledger.SetOrigin(key, country, origin)
		}
		e.assessTrust(member.Name, key, now)
		facts := e.ledger.Facts(key, e.envKey, member.SupportsUDP, now, proofTTL)
		facts.Breaker = e.cfg.breaker(member.Name)
		member = e.freshHost(member)
		rule := e.cfg.ruleFor(member.Provider, member.Name, "", e.freshExitCountry(key, now))
		candidates = append(candidates, rcxCandidate{
			Name:             member.Name,
			Order:            e.orderOf(key, member.Order),
			Facts:            facts,
			Evidence:         e.ledger.Evidence(key, e.envKey, now, live, fresh),
			MedianMs:         e.comparableMedian(key, now),
			Recurrence:       e.ledger.Recurrence(key, e.envKey, now),
			QualityConfirmed: e.qualityConfirmed(key, now),
			HostMs:           member.HostMs,
			HostAt:           member.HostAt,
			HostDead:         member.HostDead,
			CoolUntil:        e.ledger.CoolUntil(key, e.envKey, now),
			InSkeleton:       true,
			Degraded:         e.ledger.Degraded(key, e.envKey, now),
			Circuit:          e.providerCircuitOpenFor(member.Provider, member.Name, incumbent, now),
			Ignore:           rule == rcxRuleIgnore,
			AvoidExit:        e.cfg.avoidsCountry(e.ledger.ExitCountry(key)),
			RuleLastResort:   rule == rcxRuleLastResort,
			Prefer:           rule == rcxRulePrefer,
		})
	}
	return candidates
}

// A delay measured on the link before this one says nothing about this one: a
// home-WiFi green survives half an hour of freshness and would otherwise hoist a
// node the new network cannot reach to the front of every ranking and wave.
func (e *rcxEngine) freshHost(member rcxMember) rcxMember {
	if member.HostDead {
		now := e.runtime.Now()
		proof := e.ledger.ProbeGoodAt(member.key(), e.envKey)
		if e.trafficSince(member.key(), member.HostAt, now) ||
			(!proof.IsZero() && proof.After(member.HostAt) && !proof.Before(e.envSince) && now.Sub(proof) <= e.ledger.ProofTTL()) {
			member.HostDead = false
		}
	}
	if e.envSince.IsZero() || member.HostAt.IsZero() || !member.HostAt.Before(e.envSince) {
		return member
	}
	member.HostMs, member.HostAt, member.HostDead = 0, time.Time{}, false
	return member
}

// At 240 probes an hour a 250-node park cannot revisit a node inside half an
// hour, so a fixed TTL there expires every proof the engine owns.
func rcxScaledProofTTL(base time.Duration, park int) time.Duration {
	if park <= 0 {
		return base
	}
	scaled := time.Duration(park) * rcxProbeBudgetWin / rcxProbeBudgetCap
	if scaled < base {
		return base
	}
	if scaled > rcxMaxProofTTL {
		return rcxMaxProofTTL
	}
	return scaled
}
