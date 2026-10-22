package core

import (
	"github.com/metacubex/mihomo/constant"
	"testing"
)

func TestActiveNotificationServerResolvesNestedLiveSelections(t *testing.T) {
	proxies := map[string]constant.Proxy{
		"Root": selectorGroup(t, "Root", "Auto"),
		"Auto": selectorGroup(t, "Auto", "Node"),
		"Node": namedProxy("Node"),
	}
	if got := activeNotificationServer("Root", proxies); got != "Node" {
		t.Fatalf("got %q, want Node", got)
	}
	if got := activeNotificationServer("missing", proxies); got != "" {
		t.Fatalf("missing group resolved to %q", got)
	}
	delete(proxies, "Node")
	if got := activeNotificationServer("Root", proxies); got != "" {
		t.Fatalf("missing node resolved to %q", got)
	}
}

func TestActiveNotificationServerStopsCycles(t *testing.T) {
	proxies := map[string]constant.Proxy{
		"Root": selectorGroup(t, "Root", "Auto"),
		"Auto": selectorGroup(t, "Auto", "Root"),
	}
	if got := activeNotificationServer("Root", proxies); got != "" {
		t.Fatalf("cycle resolved to %q", got)
	}
}
