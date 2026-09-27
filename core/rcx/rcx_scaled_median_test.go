package rcx

import (
	"strconv"
	"testing"
	"time"
)

// Revert-verified: pass base l.policy.ProofTTL to comparableMedian and the large-park case blanks to 0.
func TestComparableMedianRidesScaledProofTTL(t *testing.T) {
	aged := rcxLedgerProofTTL + 10*time.Minute
	medianForPark := func(park int) rcxCandidate {
		names := make([]string, park)
		for i := range names {
			names[i] = "n" + strconv.Itoa(i)
		}
		runtime := newFakeRuntime()
		runtime.members = foreignMembers(names...)
		engine := newTestEngine(runtime, "ru")
		marker := rcxMarkerID(rcxRoleOpen, engine.cfg.OpenMarkers[0])
		engine.ledger.NoteQualitySample("n0", engine.envKey, marker, engine.qualityEpoch(), 200, runtime.Now().Add(-aged))
		for _, cand := range engine.candidates(runtime.members) {
			if cand.Name == "n0" {
				return cand
			}
		}
		t.Fatalf("candidate n0 missing from %d-node park", park)
		return rcxCandidate{}
	}

	if got := medianForPark(200).MedianMs; got != 200 {
		t.Errorf("large park scaled TTL keeps the aged sample fresh: MedianMs = %d, want 200", got)
	}
	if got := medianForPark(2).MedianMs; got != 0 {
		t.Errorf("small park base TTL expires the aged sample: MedianMs = %d, want 0", got)
	}
}
