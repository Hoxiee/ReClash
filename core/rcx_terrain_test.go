package main

import (
	"testing"
	"time"
)

func TestEnvKeysSeparateNetworksSharingASubnet(t *testing.T) {
	home := rcxNetworkPayload{
		Transport:  "wifi",
		Gateways:   []string{"192.168.1.1"},
		DHCPServer: "192.168.1.1",
		DNSServers: []string{"192.168.1.1"},
		IPv4:       []string{"192.168.1.55"},
	}
	cafe := rcxNetworkPayload{
		Transport:  "wifi",
		Gateways:   []string{"192.168.1.254"},
		DHCPServer: "192.168.1.254",
		DNSServers: []string{"8.8.8.8"},
		IPv4:       []string{"192.168.1.77"},
	}

	homeKey, _ := rcxEnvKeys(home)
	cafeKey, _ := rcxEnvKeys(cafe)

	if homeKey == cafeKey {
		t.Errorf("both networks keyed %s: a shared /24 must not merge two memories", homeKey)
	}
}

func TestEnvKeysPreferTheSsidButKeepAMigrationKey(t *testing.T) {
	payload := rcxNetworkPayload{
		Transport:  "wifi",
		SSID:       "Home",
		Gateways:   []string{"192.168.1.1"},
		DHCPServer: "192.168.1.1",
		IPv4:       []string{"192.168.1.55"},
	}

	primary, secondary := rcxEnvKeys(payload)
	if primary != "w:Home" {
		t.Errorf("primary = %s, want the SSID when it is readable", primary)
	}

	payload.SSID = ""
	withoutPermission, _ := rcxEnvKeys(payload)
	if withoutPermission != secondary {
		t.Errorf("permission-free key = %s, want %s so the record can be migrated", withoutPermission, secondary)
	}
}

func TestEnvKeysAreStableAcrossAddressChangesWithinASubnet(t *testing.T) {
	first := rcxNetworkPayload{
		Transport:  "wifi",
		Gateways:   []string{"192.168.1.1"},
		DHCPServer: "192.168.1.1",
		IPv4:       []string{"192.168.1.55"},
	}
	second := first
	second.IPv4 = []string{"192.168.1.91"}

	firstKey, _ := rcxEnvKeys(first)
	secondKey, _ := rcxEnvKeys(second)

	if firstKey != secondKey {
		t.Error("a new DHCP lease inside the same subnet must not look like a new network")
	}
}

func TestEnvKeysUseTheCarrierOnCellular(t *testing.T) {
	payload := rcxNetworkPayload{Transport: "cellular", Carrier: "25001", IPv4: []string{"10.132.7.9"}}

	primary, _ := rcxEnvKeys(payload)

	if primary != "c:25001" {
		t.Errorf("primary = %s, want the carrier: a mobile address changes every attach", primary)
	}
}

func TestClassifyTerrainHoldsBackDuringTheValidationWindow(t *testing.T) {
	got := rcxClassifyTerrain(rcxTerrainFacts{
		Validated:      false,
		UnvalidatedFor: time.Second,
		ForeignReach:   rcxProbeFail,
		DomesticReach:  rcxProbeFail,
	})

	if got != rcxTerrainUnknown {
		t.Errorf("terrain = %s, want unknown: Android has not finished its own probe yet", got)
	}
}

func TestClassifyTerrainEntersPortalOnlyOnRealEvidence(t *testing.T) {
	tests := []struct {
		name  string
		facts rcxTerrainFacts
		want  rcxTerrain
	}{
		{
			name:  "capability bit",
			facts: rcxTerrainFacts{CaptivePortal: true, Validated: true},
			want:  rcxTerrainPortal,
		},
		{
			name:  "marker answered with the wrong status",
			facts: rcxTerrainFacts{PortalMarker: true, Validated: true},
			want:  rcxTerrainPortal,
		},
		{
			name: "merely unvalidated for a long time while foreign IPs answer",
			facts: rcxTerrainFacts{
				Validated:      false,
				UnvalidatedFor: time.Minute,
				ForeignReach:   rcxProbeOK,
			},
			want: rcxTerrainNormal,
		},
	}

	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			if got := rcxClassifyTerrain(tc.facts); got != tc.want {
				t.Errorf("terrain = %s, want %s", got, tc.want)
			}
		})
	}
}

func TestClassifyTerrainSeparatesWhitelistFromOffline(t *testing.T) {
	whitelist := rcxClassifyTerrain(rcxTerrainFacts{
		Validated:     true,
		ForeignReach:  rcxProbeFail,
		DomesticReach: rcxProbeOK,
	})
	offline := rcxClassifyTerrain(rcxTerrainFacts{
		Validated:     true,
		ForeignReach:  rcxProbeFail,
		DomesticReach: rcxProbeFail,
	})

	if whitelist != rcxTerrainWhitelist {
		t.Errorf("terrain = %s, want whitelist when only domestic addresses answer", whitelist)
	}
	if offline != rcxTerrainOffline {
		t.Errorf("terrain = %s, want offline when nothing answers", offline)
	}
}

func TestClassifyTerrainTreatsASaturatedProbeAsNoInformation(t *testing.T) {
	got := rcxClassifyTerrain(rcxTerrainFacts{
		Validated:     true,
		ForeignReach:  rcxProbeOverloaded,
		DomesticReach: rcxProbeOK,
	})

	if got != rcxTerrainUnknown {
		t.Errorf("terrain = %s, want unknown: a starved probe slot proves nothing about the network", got)
	}
}

func TestClassifyTerrainDoesNotCallADeadRadioAWhitelist(t *testing.T) {
	// A tunnel in the metro fails every canary, foreign and domestic alike.
	got := rcxClassifyTerrain(rcxTerrainFacts{
		Validated:      false,
		UnvalidatedFor: time.Minute,
		ForeignReach:   rcxProbeFail,
		DomesticReach:  rcxProbeFail,
	})

	if got == rcxTerrainWhitelist {
		t.Error("a dead radio must not prove a shutdown: that would cool the whole park")
	}
	if got != rcxTerrainOffline {
		t.Errorf("terrain = %s, want offline", got)
	}
}

func TestTerrainStateGivesPortalADeadline(t *testing.T) {
	state := &rcxTerrainState{}
	now := time.Unix(1_700_000_000, 0)

	state.observe(rcxTerrainPortal, now)

	if state.portalExpired(now.Add(time.Second)) {
		t.Error("the grace window must not expire immediately")
	}
	if !state.portalExpired(now.Add(rcxPortalGrace + time.Second)) {
		t.Error("portal must expire: Android validates against hosts throttled in the censoring country")
	}
}

func TestTerrainStateClearsThePortalDeadlineOnRecovery(t *testing.T) {
	state := &rcxTerrainState{}
	now := time.Unix(1_700_000_000, 0)
	state.observe(rcxTerrainPortal, now)

	state.observe(rcxTerrainNormal, now.Add(time.Second))

	if state.portalExpired(now.Add(time.Hour)) {
		t.Error("a recovered terrain must not report a stale portal deadline")
	}
}

func TestTerrainStateTracksTheUnvalidatedWindow(t *testing.T) {
	state := &rcxTerrainState{}
	now := time.Unix(1_700_000_000, 0)

	state.noteValidation(false, now)
	if got := state.unvalidatedFor(now.Add(5 * time.Second)); got != 5*time.Second {
		t.Errorf("unvalidatedFor = %v, want 5s", got)
	}

	state.noteValidation(true, now.Add(6*time.Second))
	if got := state.unvalidatedFor(now.Add(10 * time.Second)); got != 0 {
		t.Errorf("unvalidatedFor = %v, want it reset once the network validated", got)
	}
}

func TestTerrainStateReportsOnlyRealTransitions(t *testing.T) {
	state := &rcxTerrainState{}
	now := time.Unix(1_700_000_000, 0)

	if !state.observe(rcxTerrainNormal, now) {
		t.Error("the first classification is a transition")
	}
	if state.observe(rcxTerrainNormal, now.Add(time.Minute)) {
		t.Error("re-observing the same terrain must not look like a change")
	}
}
