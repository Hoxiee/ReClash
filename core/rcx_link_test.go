package main

import "testing"

func TestVirtualLinksAreLeftOutOfTheFingerprint(t *testing.T) {
	cases := map[string]bool{
		"ReClash":         true,
		"tun0":            true,
		"docker0":         true,
		"br-7025f5912b81": true,
		"vEthernet (WSL)": true,
		"wlp7s0":          false,
		"eth0":            false,
		"Wi-Fi":           false,
	}
	for device, virtual := range cases {
		if got := rcxVirtualLink(device, "reclash"); got != virtual {
			t.Errorf("virtual(%q) = %v, want %v", device, got, virtual)
		}
	}
}

func TestLinkTransportReadsTheInterfaceName(t *testing.T) {
	cases := map[string]string{
		"wlp7s0":   "wifi",
		"Wi-Fi":    "wifi",
		"eth0":     "ethernet",
		"Ethernet": "ethernet",
		"ppp0":     "",
	}
	for device, transport := range cases {
		if got := rcxLinkTransport(device); got != transport {
			t.Errorf("transport(%q) = %q, want %q", device, got, transport)
		}
	}
}

// An unvalidated link parks the terrain in the debounce that waits for the host
// to change its mind, and on desktop no host ever will.
func TestSampledLinkClaimsItsOwnValidation(t *testing.T) {
	payload, ok := rcxSampleLink()
	if !ok {
		t.Skip("no physical link on this machine")
	}
	if !payload.Validated {
		t.Error("sampled link is unvalidated, want it to stand on its own")
	}
	if len(payload.IPv4) == 0 {
		t.Error("sampled link has no address, want the fingerprint to have something to hash")
	}
}
