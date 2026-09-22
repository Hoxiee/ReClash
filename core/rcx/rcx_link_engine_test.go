package rcx

import "testing"

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

// A readable host SSID separates two cafes a fingerprint would merge.
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

// Re-applying an unchanged link must stay a no-op, or it re-arms the canaries.
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
