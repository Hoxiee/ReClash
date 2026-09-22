package rcx

import (
	"sort"
	"time"
)

const (
	rcxProviderFailureWindow = 90 * time.Second
	rcxProviderCircuitTTL    = 5 * time.Minute
	rcxProviderHalfOpenAfter = time.Minute
	rcxProviderFailQuorum    = 2
)

type rcxProviderFailure struct {
	Bucket string    `json:"b"`
	At     time.Time `json:"a"`
}

type rcxProviderCircuit struct {
	OpenedAt time.Time            `json:"o"`
	Until    time.Time            `json:"u"`
	HalfAt   time.Time            `json:"h"`
	Members  map[string]struct{}  `json:"m,omitempty"`
	Failures []rcxProviderFailure `json:"f,omitempty"`
}

func rcxCircuitKey(env, provider string) string {
	return env + "\x00" + provider
}

func rcxFailureBucket(member rcxMember) string {
	ingress := member.Ingress
	if ingress == "" {
		ingress = member.key()
	}
	return member.Provider + "\x00" + ingress
}

func (e *rcxEngine) reconcileCircuits(members []rcxMember, now time.Time) {
	if e.snapshot == nil {
		return
	}
	membership := make(map[string]map[string]struct{})
	for _, member := range members {
		if member.Provider == "" {
			continue
		}
		set := membership[member.Provider]
		if set == nil {
			set = map[string]struct{}{}
			membership[member.Provider] = set
		}
		set[member.key()] = struct{}{}
	}
	for key, circuit := range e.snapshot.Circuits {
		if !circuit.Until.After(now) {
			delete(e.snapshot.Circuits, key)
			continue
		}
		if circuitEnvironment(key) != e.envKey {
			continue
		}
		provider := circuitProvider(key)
		current := membership[provider]
		if !sameMemberSet(circuit.Members, current) {
			delete(e.snapshot.Circuits, key)
		}
	}
}

func circuitEnvironment(key string) string {
	for i := len(key) - 1; i >= 0; i-- {
		if key[i] == 0 {
			return key[:i]
		}
	}
	return ""
}

func circuitProvider(key string) string {
	for i := len(key) - 1; i >= 0; i-- {
		if key[i] == 0 {
			return key[i+1:]
		}
	}
	return key
}

func sameMemberSet(left, right map[string]struct{}) bool {
	if len(left) != len(right) {
		return false
	}
	for key := range left {
		if _, ok := right[key]; !ok {
			return false
		}
	}
	return true
}

func (e *rcxEngine) noteProviderFailure(member rcxMember, now time.Time) {
	if e.snapshot == nil || member.Provider == "" || !member.ExternalProvider {
		return
	}
	key := rcxCircuitKey(e.envKey, member.Provider)
	circuit := e.snapshot.Circuits[key]
	if circuit.Until.After(now) {
		return
	}
	kept := circuit.Failures[:0]
	for _, failure := range circuit.Failures {
		if now.Sub(failure.At) < rcxProviderFailureWindow {
			kept = append(kept, failure)
		}
	}
	bucket := rcxFailureBucket(member)
	for _, failure := range kept {
		if failure.Bucket == bucket {
			circuit.Failures = kept
			e.snapshot.Circuits[key] = circuit
			return
		}
	}
	circuit.Failures = append(kept, rcxProviderFailure{Bucket: bucket, At: now})
	if len(circuit.Failures) >= rcxProviderFailQuorum {
		circuit.OpenedAt = now
		circuit.Until = now.Add(rcxProviderCircuitTTL)
		circuit.HalfAt = now.Add(rcxProviderHalfOpenAfter)
		circuit.Members = e.providerMembers(member.Provider)
		e.snapshot.Metrics.ProviderIncidents++
		e.snapshot.Dirty = true
	}
	e.snapshot.Circuits[key] = circuit
}

func (e *rcxEngine) activeCircuitReasons(now time.Time) []string {
	if e.snapshot == nil {
		return nil
	}
	reasons := make([]string, 0)
	for key, circuit := range e.snapshot.Circuits {
		if circuitEnvironment(key) == e.envKey && circuit.Until.After(now) {
			reasons = append(reasons, circuitProvider(key))
		}
	}
	sort.Strings(reasons)
	return reasons
}

func (e *rcxEngine) providerMembers(provider string) map[string]struct{} {
	members := map[string]struct{}{}
	for _, member := range e.runtime.Members() {
		if member.Provider == provider {
			members[member.key()] = struct{}{}
		}
	}
	return members
}

func (e *rcxEngine) clearProviderCircuit(provider string) {
	if e.snapshot == nil || provider == "" {
		return
	}
	delete(e.snapshot.Circuits, rcxCircuitKey(e.envKey, provider))
}

func (e *rcxEngine) memberByName(node string) (rcxMember, bool) {
	for _, member := range e.runtime.Members() {
		if member.Name == node {
			return member, true
		}
	}
	return rcxMember{}, false
}

func (e *rcxEngine) noteProviderSuccess(node string) {
	member, ok := e.memberByName(node)
	if !ok {
		return
	}
	e.clearProviderCircuit(member.Provider)
	prefix := member.Provider + "\x00"
	for bucket := range e.providerFails {
		if len(bucket) >= len(prefix) && bucket[:len(prefix)] == prefix {
			delete(e.providerFails, bucket)
		}
	}
}

func (e *rcxEngine) noteProviderNodeFailure(node string, now time.Time) {
	member, ok := e.memberByName(node)
	if !ok {
		return
	}
	bucket := rcxFailureBucket(member)
	for known, at := range e.providerFails {
		if now.Sub(at) >= rcxProviderFailureWindow {
			delete(e.providerFails, known)
		}
	}
	if _, duplicate := e.providerFails[bucket]; duplicate {
		return
	}
	e.providerFails[bucket] = now
	e.noteProviderFailure(member, now)
}

func (e *rcxEngine) providerCircuitOpen(provider, node string, now time.Time) bool {
	return e.providerCircuitOpenFor(provider, node, e.incumbent, now)
}

func (e *rcxEngine) providerCircuitOpenFor(provider, node, incumbent string, now time.Time) bool {
	if e.snapshot == nil || provider == "" || node == incumbent {
		return false
	}
	circuit, ok := e.snapshot.Circuits[rcxCircuitKey(e.envKey, provider)]
	return ok && circuit.Until.After(now)
}

func (e *rcxEngine) providerHalfOpen(provider string, now time.Time) bool {
	if e.snapshot == nil || provider == "" {
		return false
	}
	key := rcxCircuitKey(e.envKey, provider)
	circuit, ok := e.snapshot.Circuits[key]
	if !ok || !circuit.Until.After(now) || now.Before(circuit.HalfAt) {
		return false
	}
	circuit.HalfAt = now.Add(rcxProviderHalfOpenAfter)
	e.snapshot.Circuits[key] = circuit
	return true
}

func (e *rcxEngine) circuitHalfOpenMembers(members []rcxMember, now time.Time) map[string]struct{} {
	chosen := map[string]struct{}{}
	for _, member := range members {
		if _, exists := chosen[member.Provider]; exists {
			continue
		}
		if e.providerHalfOpen(member.Provider, now) {
			chosen[member.Provider] = struct{}{}
		}
	}
	return chosen
}

func (e *rcxEngine) discoverySentinelDue(provider string, now time.Time) bool {
	return e.sentinels == nil || now.Sub(e.sentinels[rcxCircuitKey(e.envKey, provider)]) >= rcxProviderFailureWindow
}

func (e *rcxEngine) noteDiscoverySentinel(provider string, now time.Time) {
	if e.sentinels == nil {
		e.sentinels = map[string]time.Time{}
	}
	for key, at := range e.sentinels {
		if now.Sub(at) > rcxProviderCircuitTTL {
			delete(e.sentinels, key)
		}
	}
	e.sentinels[rcxCircuitKey(e.envKey, provider)] = now
}
