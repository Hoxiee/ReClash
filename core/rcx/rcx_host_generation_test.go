package rcx

import "testing"

func TestHostHarvestCannotCrossANetworkGeneration(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("node")
	engine := newTestEngine(runtime, "ru")
	generation := engine.NetworkGeneration()
	engine.NoteHarvestedProbe(runtime.TestURL(), "node", 80, generation)
	queued := <-engine.events

	engine.SetEnabledForTest(false)
	engine.applyNetwork(rcxNetworkPayload{Transport: "cellular", Carrier: "test-carrier", Validated: true})
	if engine.NetworkGeneration() == generation {
		t.Fatal("changing the network did not invalidate host probes")
	}
	engine.handle(queued)
	facts := engine.ledger.Facts("node", engine.envKey, true, runtime.Now(), engine.ledger.ProofTTL())
	if facts.Transit == rcxProofProven {
		t.Fatal("a queued old-network result proved transit on the new network")
	}

	engine.SetEnabledForTest(true)
	engine.NoteHarvestedProbe(runtime.TestURL(), "node", 80, generation)
	select {
	case event := <-engine.events:
		t.Fatalf("a late old-network result entered the queue: %+v", event)
	default:
	}
	engine.NoteHarvestedProbe(runtime.TestURL(), "node", 80, engine.NetworkGeneration())
	engine.handle(<-engine.events)
	facts = engine.ledger.Facts("node", engine.envKey, true, runtime.Now(), engine.ledger.ProofTTL())
	if facts.Transit != rcxProofProven {
		t.Fatal("a current-network result did not prove transit")
	}
}
