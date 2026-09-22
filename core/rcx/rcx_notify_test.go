package rcx

import (
	"testing"

	"github.com/metacubex/mihomo/tunnel/statistic"
)

// The engine and the Requests page share one notify hook: whichever assignment loses goes dark.
func TestRequestNotifyReachesTheEngine(t *testing.T) {
	engine := newTestEngine(newFakeRuntime(), "ru")
	engine.mu.Lock()
	engine.enabled = true
	engine.openHosts = map[string]struct{}{"marker.example": {}}
	engine.mu.Unlock()

	restore := statistic.DefaultRequestNotify
	statistic.DefaultRequestNotify = engine.NoteTracker
	t.Cleanup(func() { statistic.DefaultRequestNotify = restore })

	statistic.DefaultRequestNotify(newFakeTracker("marker-1", "node-a", "marker.example"))

	engine.mu.RLock()
	sighting, seen := engine.openSeen["marker-1"]
	engine.mu.RUnlock()
	if !seen || sighting.node != "node-a" {
		t.Error("the engine never saw the connection: its side of the hook is gone")
	}
}
