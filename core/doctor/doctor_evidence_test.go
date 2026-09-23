package doctor

import (
	"encoding/json"
	"net/netip"
	"strings"
	"testing"
	"time"

	C "github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/tunnel"
)

func TestDoctorFlowEvidenceDropsRawIdentifiers(t *testing.T) {
	fact := doctorEvidenceFromFlow(tunnel.FlowEvidence{
		Stage:       tunnel.FlowEvidenceDialFinished,
		At:          time.Now(),
		Network:     C.TCP,
		InboundType: C.TUN,
		InboundName: "private-inbound",
		SourceIP:    netip.MustParseAddr("192.0.2.1"),
		SourcePort:  45123,
		TargetIP:    netip.MustParseAddr("198.51.100.7"),
		TargetPort:  443,
		TargetHost:  "private.example",
		UID:         12345,
		RuleType:    "DOMAIN",
		Outbound:    "private-node",
		Duration:    137 * time.Millisecond,
	})
	encoded, err := json.Marshal(fact)
	if err != nil {
		t.Fatal(err)
	}
	text := string(encoded)
	for _, secret := range []string{"private-inbound", "192.0.2.1", "198.51.100.7", "private.example", "45123", "12345", "private-node"} {
		if strings.Contains(text, secret) {
			t.Errorf("evidence leaked %q: %s", secret, text)
		}
	}
	if fact.Network != "tcp" || fact.Inbound != "tun" || fact.DurationBucketMs != 250 {
		t.Fatalf("normalized fact = %+v", fact)
	}
}

func TestDoctorFlowEvidenceClassifiesDNSRouteFailure(t *testing.T) {
	fact := doctorEvidenceFromFlow(tunnel.FlowEvidence{
		Stage:      tunnel.FlowEvidenceRouteFailed,
		ErrorClass: "dns",
	})

	if fact.Layer != doctorLayerDNS || fact.Code != "destinationDnsFailed" || fact.Outcome != doctorOutcomeFailed {
		t.Fatalf("fact = %+v", fact)
	}
}
