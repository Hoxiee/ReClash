package main

import "testing"

func TestConfigFingerprintsSeparateIndependentDomains(t *testing.T) {
	base := testConfig("ru")
	fingerprints := base.fingerprints()

	open := base
	open.OpenMarkers = []rcxMarker{{URL: "https://api.telegram.org/", Statuses: []int{404, 200}}}
	if got := open.fingerprints(); got.Open == fingerprints.Open || got.Domestic != fingerprints.Domestic || got.Canaries != fingerprints.Canaries || got.Countries != fingerprints.Countries {
		t.Fatalf("open edit changed unrelated domains: before=%+v after=%+v", fingerprints, got)
	}

	countries := base
	countries.CensorCountries = []string{"IR"}
	if got := countries.fingerprints(); got.Countries == fingerprints.Countries || got.Open != fingerprints.Open {
		t.Fatalf("country edit did not stay isolated: before=%+v after=%+v", fingerprints, got)
	}
}

func TestMarkerFingerprintKeepsUserPriorityButNormalizesStatuses(t *testing.T) {
	first := []rcxMarker{
		{URL: "https://a.example/", Statuses: []int{404, 200}},
		{URL: "https://b.example/", Statuses: []int{204}},
	}
	statusesReordered := []rcxMarker{
		{URL: "https://a.example/", Statuses: []int{200, 404}},
		{URL: "https://b.example/", Statuses: []int{204}},
	}
	markersReordered := []rcxMarker{first[1], first[0]}

	if rcxMarkersFingerprint(first) != rcxMarkersFingerprint(statusesReordered) {
		t.Error("status order changed marker semantics")
	}
	if rcxMarkersFingerprint(first) == rcxMarkersFingerprint(markersReordered) {
		t.Error("marker priority order disappeared from the fingerprint")
	}
}
