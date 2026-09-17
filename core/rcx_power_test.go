package main

import (
	"testing"
	"time"
)

func TestDialWakeSkipsIrrelevantAndUnchangedEvidence(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("node")
	engine := newTestEngine(runtime, "ru")
	engine.screenOff = true
	for _, node := range []string{"", "DIRECT"} {
		engine.NoteDial(node, true, time.Second, runtime.Now())
	}
	if len(engine.dials) != 0 || len(engine.wake) != 0 || engine.drainDials() {
		t.Fatal("irrelevant dial queued work")
	}
	engine.NoteDial("outside", true, time.Second, runtime.Now())
	if engine.drainDials() {
		t.Fatal("nonmember requested reconsideration")
	}
	engine.NoteDial("node", false, time.Second, runtime.Now())
	if engine.drainDials() {
		t.Fatal("healthy dial without debt requested reconsideration")
	}
	engine.NoteDial("node", true, time.Second, runtime.Now())
	if !engine.drainDials() {
		t.Fatal("first failure did not request reconsideration")
	}
	engine.NoteDial("node", true, time.Second, runtime.Now())
	if engine.drainDials() {
		t.Fatal("duplicate failure requested reconsideration")
	}
	engine.NoteDial("node", false, time.Second, runtime.Now())
	if !engine.drainDials() || len(engine.charged) != 0 {
		t.Fatal("success did not refund failure and clear escrow")
	}
	engine.NoteDial("node", false, time.Second, runtime.Now())
	if engine.drainDials() {
		t.Fatal("repeated success requested reconsideration")
	}
	runtime.now = runtime.now.Add(rcxRecurrenceDecay)
	engine.NoteDial("node", false, time.Second, runtime.Now())
	if !engine.drainDials() {
		t.Fatal("decayed recurrence did not request reconsideration")
	}
}

func TestNetworkDuplicatesPreserveReachGeneration(t *testing.T) {
	runtime := newFakeRuntime()
	engine := newTestEngine(runtime, "ru")
	engine.screenOff = true
	payload := rcxNetworkPayload{Transport: "wifi", SSID: "Home", Validated: true,
		DNSServers: []string{"1.1.1.1", "8.8.8.8"}}
	engine.applyNetwork(payload)
	gen, reads := engine.reachGen, runtime.memberReads
	payload.Transport = " WiFi "
	payload.DNSServers = []string{"8.8.8.8", "1.1.1.1", " 1.1.1.1 "}
	engine.applyNetwork(payload)
	if engine.reachGen != gen || runtime.memberReads != reads {
		t.Fatal("semantic duplicate restarted reach or rebuilt candidates")
	}
	for _, change := range []func(*rcxNetworkPayload){
		func(p *rcxNetworkPayload) { p.Validated = false },
		func(p *rcxNetworkPayload) { p.CaptivePortal = true },
		func(p *rcxNetworkPayload) { p.Metered = true },
		func(p *rcxNetworkPayload) { p.DNSServers = []string{"9.9.9.9"} },
		func(p *rcxNetworkPayload) { p.IPv4 = []string{"192.0.2.2"} },
	} {
		change(&payload)
		engine.applyNetwork(payload)
		if engine.reachGen == gen {
			t.Fatal("changed facts did not supersede reach")
		}
		gen = engine.reachGen
	}
	engine.networkFacts = nil
	engine.applyNetwork(payload)
	if engine.reachGen == gen {
		t.Fatal("first replay after reset was suppressed")
	}
}

func TestEscrowReachIsNotRestartedByRepeatedEvidence(t *testing.T) {
	runtime := newFakeRuntime()
	engine := newTestEngine(runtime, "ru")
	engine.quit = make(chan struct{})
	t.Cleanup(func() { engine.supersedeReach(); close(engine.quit) })
	engine.incumbent = "node"
	engine.startReach()
	before := engine.reachGen
	engine.escrowNegative("node", 0, runtime.Now())
	if engine.reachGen != before+1 || !engine.reaching || !engine.escrowReach {
		t.Fatal("first quorum did not replace the pre-incident round")
	}
	gen := engine.reachGen
	for i := 0; i < 100; i++ {
		engine.escrowNegative("node", i%2, runtime.Now())
	}
	if engine.reachGen != gen || engine.charged[engine.key("node")] != 50 {
		t.Fatal("repeated evidence restarted reach or lost refund accounting")
	}
	engine.reaching = false
	engine.escrowNegative("node", 0, runtime.Now())
	if engine.reachGen != gen {
		t.Fatal("completed incident round was restarted by the same escrow")
	}
	engine.noteLinkAlive(runtime.Now())
	engine.escrowNegative("node", 1, runtime.Now())
	if engine.reachGen != gen+1 {
		t.Fatal("new incident did not immediately restart reach")
	}
	engine.supersedeReach()
	gen = engine.reachGen
	engine.startReach()
	engine.escrowNegative("node", 0, runtime.Now())
	if engine.reachGen != gen || !engine.escrowReach {
		t.Fatal("post-change round was not adopted by the existing escrow")
	}
}

func TestEscrowReachDefersWithoutClaimingRound(t *testing.T) {
	engine := newTestEngine(newFakeRuntime(), "ru")
	engine.quit = make(chan struct{})
	t.Cleanup(func() { engine.supersedeReach(); close(engine.quit) })
	engine.incumbent = "node"
	engine.screenOff = true
	engine.escrowNegative("node", 0, engine.runtime.Now())
	if engine.escrowReach || engine.reaching {
		t.Fatal("screen-off escrow claimed a round that did not start")
	}
	engine.screenOff = false
	engine.startReach()
	gen := engine.reachGen
	engine.escrowNegative("node", 0, engine.runtime.Now())
	if !engine.escrowReach || engine.reachGen != gen {
		t.Fatal("wake round was immediately cancelled by existing evidence")
	}
}

func TestNonRecoveryProbeAvoidsRecoveryCandidateRead(t *testing.T) {
	for _, closed := range []bool{false, true} {
		runtime := newFakeRuntime()
		runtime.members = foreignMembers("node")
		engine := newTestEngine(runtime, "ru")
		engine.probeKind = rcxWaveQuality
		if closed {
			engine.probeKind = rcxWaveIncident
		}
		engine.probeDecisionClosed = closed
		engine.applyProbeResult(rcxEvent{Gen: engine.probeGen, Results: []rcxProbeResult{{
			Node: "node", Role: rcxRoleOpen, Outcome: rcxProbeOK, DelayMs: 100,
		}}})
		if runtime.memberReads != 2 {
			t.Fatalf("closed=%v: member reads=%d, want identity and provider checks only", closed, runtime.memberReads)
		}
	}
}

func BenchmarkDirectDialIgnored(b *testing.B) {
	engine := newTestEngine(newFakeRuntime(), "ru")
	now := engine.runtime.Now()
	b.ReportAllocs()
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		engine.NoteDial("DIRECT", false, time.Second, now)
	}
}
