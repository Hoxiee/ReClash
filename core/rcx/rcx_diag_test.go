package rcx

import "testing"

func diagDecision(node string) rcxDiagEntry {
	return rcxDiagEntry{
		At:   1,
		Kind: rcxDiagDecision,
		Msg:  "hold",
		Ctx:  &rcxDiagContext{Incumbent: node, Eligible: 1, Candidates: 1},
		Cands: []rcxCandidateReport{
			{Node: node, Order: 0, MedianMs: 10, Current: true},
		},
	}
}

func TestDiagRingGatedWhileOff(t *testing.T) {
	r := newRcxDiagRing()
	r.push(diagDecision("A"))
	if got := r.since(0, 0); len(got.Entries) != 0 || got.Enabled {
		t.Fatalf("off ring captured %d entries, enabled=%v", len(got.Entries), got.Enabled)
	}
}

func TestDiagRingDedupeReemitsWithFreshSeq(t *testing.T) {
	r := newRcxDiagRing()
	r.setEnabled(true)
	r.push(diagDecision("A"))
	r.push(diagDecision("A"))
	r.push(diagDecision("A"))
	batch := r.since(0, 0)
	if len(batch.Entries) != 1 {
		t.Fatalf("expected 1 collapsed entry, got %d", len(batch.Entries))
	}
	if batch.Entries[0].Repeat != 3 {
		t.Fatalf("expected repeat 3, got %d", batch.Entries[0].Repeat)
	}
	// A cursor at the first seq must still surface the re-emitted row.
	if tail := r.since(1, 0); len(tail.Entries) != 1 || tail.Entries[0].Repeat != 3 {
		t.Fatalf("re-emit invisible to cursor: %+v", tail.Entries)
	}
}

func TestDiagRingDistinctCandidatesDoNotDedupe(t *testing.T) {
	r := newRcxDiagRing()
	r.setEnabled(true)
	r.push(diagDecision("A"))
	r.push(diagDecision("B"))
	if batch := r.since(0, 0); len(batch.Entries) != 2 {
		t.Fatalf("expected 2 distinct entries, got %d", len(batch.Entries))
	}
}

func TestDiagRingDropsAndReportsOverflow(t *testing.T) {
	r := newRcxDiagRing()
	r.setEnabled(true)
	total := rcxDiagCapacity + 10
	for i := 0; i < total; i++ {
		e := diagDecision("N")
		e.Msg = "m" + string(rune('a'+i%26)) + string(rune('0'+i/26%10)) + string(rune('0'+i%10))
		r.push(e)
	}
	batch := r.since(0, 0)
	if len(batch.Entries) != rcxDiagCapacity {
		t.Fatalf("expected full ring %d, got %d", rcxDiagCapacity, len(batch.Entries))
	}
	if batch.Dropped != uint64(total-rcxDiagCapacity) {
		t.Fatalf("expected %d dropped, got %d", total-rcxDiagCapacity, batch.Dropped)
	}
}

func TestDiagRingResetsOnReenable(t *testing.T) {
	r := newRcxDiagRing()
	r.setEnabled(true)
	r.push(diagDecision("A"))
	r.setEnabled(false)
	r.setEnabled(true)
	batch := r.since(0, 0)
	if len(batch.Entries) != 0 || batch.Cursor != 0 || batch.Dropped != 0 {
		t.Fatalf("re-enable did not reset: %+v", batch)
	}
}

func TestDiagRingLimitPagesToEOF(t *testing.T) {
	r := newRcxDiagRing()
	r.setEnabled(true)
	for i := 0; i < 5; i++ {
		e := diagDecision("N")
		e.Msg = "m" + string(rune('a'+i))
		r.push(e)
	}
	first := r.since(0, 2)
	if len(first.Entries) != 2 {
		t.Fatalf("expected 2 entries in first page, got %d", len(first.Entries))
	}
	second := r.since(first.Cursor, 2)
	if len(second.Entries) != 2 || second.Entries[0].Seq <= first.Cursor {
		t.Fatalf("second page did not resume: %+v", second.Entries)
	}
	third := r.since(second.Cursor, 2)
	if len(third.Entries) != 1 {
		t.Fatalf("expected trailing page of 1, got %d", len(third.Entries))
	}
	if tail := r.since(third.Cursor, 2); len(tail.Entries) != 0 {
		t.Fatalf("expected EOF, got %d", len(tail.Entries))
	}
}
