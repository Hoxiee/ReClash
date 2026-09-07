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

func TestEngineAdoptsTheLinkItSampledItself(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.linked = true
	runtime.link = rcxNetworkPayload{
		Transport:  "wifi",
		Gateways:   []string{"192.168.31.1"},
		DNSServers: []string{"192.168.31.1"},
		IPv4:       []string{"192.168.31.44"},
		Validated:  true,
	}
	engine := newTestEngine(runtime, "ru")
	engine.envKey = ""

	engine.sampleLink()

	want, _ := rcxEnvKeys(runtime.link)
	if got := engine.envKey; got != want {
		t.Errorf("envKey = %q, want %q: a desktop link has to name its own bucket", got, want)
	}
}

func TestEngineKeepsItsEnvWhenNothingCanBeSampled(t *testing.T) {
	engine := newTestEngine(newFakeRuntime(), "ru")

	engine.sampleLink()

	if got := engine.envKey; got != "w:Home" {
		t.Errorf("envKey = %q, want the known env to survive a link nobody could read", got)
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

// The host is the better witness where it exists: an SSID separates two cafes a
// fingerprint would merge, and a sampled key would fight it every tick.
func TestEngineStopsSamplingOnceTheHostReportsTheLink(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.linked = true
	runtime.link = rcxNetworkPayload{Transport: "wifi", IPv4: []string{"192.168.31.44"}, Validated: true}
	engine := newTestEngine(runtime, "ru")

	payload := rcxNetworkPayload{
		Transport: "wifi",
		SSID:      "Home",
		Validated: true,
	}
	engine.handle(rcxEvent{Kind: rcxEventNetwork, Payload: payload})
	engine.sampleLink()
	want, _ := rcxEnvKeys(payload)

	if got := engine.envKey; got != want {
		t.Errorf("envKey = %q, want %q for the host-reported link", got, want)
	}
}

// Re-applying a link re-arms the canaries, so an unchanged sample must be a
// no-op or the five-minute round becomes a thirty-second one.
func TestEngineIgnoresASampleOfTheLinkItIsAlreadyOn(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.linked = true
	runtime.link = rcxNetworkPayload{Transport: "wifi", IPv4: []string{"192.168.31.44"}, Validated: true}
	engine := newTestEngine(runtime, "ru")
	engine.cfg.CanaryForeign = []string{"1.1.1.1:443"}
	engine.quit = make(chan struct{})
	engine.envKey = ""
	engine.sampleLink()
	before := engine.reachGen

	engine.sampleLink()

	if got := engine.reachGen; got != before {
		t.Errorf("reachGen went %d->%d: the same link must not buy another canary round", before, got)
	}
}
