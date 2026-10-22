package rcx

import "time"

const journalSize = 200

// JournalEntry is one event the user can read back: a switch, a pin, a
// confirmed failure, a network change.
type JournalEntry struct {
	Seq    uint64    `json:"seq"`
	At     time.Time `json:"at"`
	Group  string    `json:"group,omitempty"`
	Kind   string    `json:"kind"`
	From   string    `json:"from,omitempty"`
	To     string    `json:"to,omitempty"`
	Reason Reason    `json:"reason"`
}

type journal struct {
	Seq     uint64         `json:"seq"`
	Entries []JournalEntry `json:"entries"`
}

func (j *journal) add(entry JournalEntry) {
	j.Seq++
	entry.Seq = j.Seq
	j.Entries = append(j.Entries, entry)
	if over := len(j.Entries) - journalSize; over > 0 {
		j.Entries = append(j.Entries[:0], j.Entries[over:]...)
	}
}

func (j *journal) after(cursor uint64, group string, limit int) []JournalEntry {
	out := []JournalEntry{}
	for _, e := range j.Entries {
		if e.Seq > cursor && (group == "" || e.Group == group || e.Group == "") {
			out = append(out, e)
		}
	}
	if limit > 0 && len(out) > limit {
		out = out[len(out)-limit:]
	}
	return out
}
