package main

import (
	"testing"
	"time"
)

func TestFlagCountryReadsRegionalIndicators(t *testing.T) {
	cases := map[string]string{
		"🇷🇺 Москва":         "RU",
		"🇸🇪 Sweden | relay": "SE",
		"fast 🇩🇪 #2":        "DE",
		"no flag here":      "",
		"single 🇦":          "",
		"plain ⭐ premium":   "",
	}
	for name, want := range cases {
		if got := rcxFlagCountry(name); got != want {
			t.Errorf("rcxFlagCountry(%q) = %q, want %q", name, got, want)
		}
	}
}

func TestCheapAssessSuspectsTheCensoredSide(t *testing.T) {
	censorsRU := func(code string) bool { return code == "RU" }
	hints := []string{"россия", "russia", "москва"}

	// mmdb says US but the name flies the home flag: disagreement owes a check.
	fronted := rcxCheapAssess(rcxOriginForeign, "US", "🇷🇺 Home relay", hints, true, censorsRU)
	if fronted.Trust != rcxTrustSuspect || !fronted.NeedsHeavyCheck {
		t.Fatalf("fronted node = %+v, want suspect needing a heavy check", fronted)
	}

	clean := rcxCheapAssess(rcxOriginForeign, "SE", "🇸🇪 Stockholm", hints, true, censorsRU)
	if clean.NeedsHeavyCheck || clean.Trust != rcxTrustUnknown {
		t.Fatalf("clean node = %+v, want no heavy check queued", clean)
	}
	if clean.Confidence != rcxConfPrior {
		t.Fatalf("clean confidence = %v, want a prior from mmdb+name", clean.Confidence)
	}

	// A bare keyword with no mmdb answer still raises suspicion under censorship.
	named := rcxCheapAssess(rcxOriginUnknown, "", "Москва #3", hints, true, censorsRU)
	if named.Trust != rcxTrustSuspect || !named.NeedsHeavyCheck {
		t.Fatalf("named node = %+v, want suspect from the keyword", named)
	}
}

func TestCheapAssessStandsDownOffCensorship(t *testing.T) {
	censorsRU := func(code string) bool { return code == "RU" }
	v := rcxCheapAssess(rcxOriginDomestic, "RU", "🇷🇺 Moscow", nil, false, censorsRU)
	if v.NeedsHeavyCheck || v.Trust != rcxTrustUnknown {
		t.Fatalf("off censorship = %+v, want geography left as a bare prior", v)
	}
}

func TestBrandedNodeIsRejectedHoweverFast(t *testing.T) {
	facts := foreignProven()
	facts.Trust = rcxTrustBranded
	if got := rcxAdmit(rcxTerrainNormal, facts); got != rcxVerdictReject {
		t.Fatalf("branded verdict = %v, want reject even for a proven-fast node", got)
	}
}

func TestSetTrustKeepsMeasuredOverPrior(t *testing.T) {
	ledger := newRcxLedger(rcxDefaultLedgerPolicy())
	now := time.Now()
	ledger.SetTrust("node", rcxTrustBranded, rcxConfBehavioral, now)
	ledger.SetTrust("node", rcxTrustSuspect, rcxConfPrior, now)
	if trust, conf := ledger.Trust("node"); trust != rcxTrustBranded || conf != rcxConfBehavioral {
		t.Fatalf("trust = %v/%v, want a prior never to un-brand a measured node", trust, conf)
	}
}

func TestFinishLocateReadsBothLegs(t *testing.T) {
	runtime := newFakeRuntime()
	runtime.members = foreignMembers("escapes", "stuck", "dead")
	engine := newTestEngine(runtime, "ru")
	engine.cfg.LocalMarkers = []rcxMarker{{URL: "https://local.example/", Statuses: []int{200}}}
	now := runtime.Now()
	engine.probeResults = []rcxProbeResult{
		{Node: "escapes", Key: engine.key("escapes"), Role: rcxRoleOpen, Outcome: rcxProbeOK},
		{Node: "escapes", Key: engine.key("escapes"), Role: rcxRoleLocal, Outcome: rcxProbeOK},
		{Node: "stuck", Key: engine.key("stuck"), Role: rcxRoleOpen, Outcome: rcxProbeFail},
		{Node: "stuck", Key: engine.key("stuck"), Role: rcxRoleLocal, Outcome: rcxProbeOK},
		{Node: "dead", Key: engine.key("dead"), Role: rcxRoleOpen, Outcome: rcxProbeFail},
		{Node: "dead", Key: engine.key("dead"), Role: rcxRoleLocal, Outcome: rcxProbeFail},
	}
	engine.finishLocate(now)

	if trust, _ := engine.ledger.Trust(engine.key("escapes")); trust != rcxTrusted {
		t.Fatalf("escapes trust = %v, want trusted", trust)
	}
	if trust, _ := engine.ledger.Trust(engine.key("stuck")); trust != rcxTrustBranded {
		t.Fatalf("stuck trust = %v, want branded (blocked fail + local pass)", trust)
	}
	if trust, _ := engine.ledger.Trust(engine.key("dead")); trust != rcxTrustUnknown {
		t.Fatalf("dead trust = %v, want unknown (both legs failed proves nothing)", trust)
	}
}
