package rcx

import "testing"

// legacyAdmitTier is the pre-data-driven if-chain, kept verbatim as the oracle the
// data-driven rules must match byte-for-byte over the whole fact space.
func legacyAdmitTier(terrain rcxTerrain, f rcxFacts) rcxVerdict {
	row, ok := rcxAdmissionTable[terrain]
	if !ok {
		return rcxVerdictReject
	}
	if f.Transit == rcxProofDisproven {
		return rcxVerdictReject
	}
	if f.Trust == rcxTrustBranded {
		return rcxVerdictReject
	}
	if f.OpenWorld == rcxProofDisproven && f.Domestic != rcxProofProven {
		return rcxVerdictReject
	}
	if f.Exit == rcxOriginDomestic {
		if f.Domestic == rcxProofProven {
			return row.domesticProven
		}
		return row.domesticPrior
	}
	if f.OpenWorld == rcxProofProven {
		if f.Breaker {
			return row.breakerProven
		}
		if f.Trust == rcxTrustSuspect && f.Exit == rcxOriginUnknown {
			return rcxVerdictLastResort
		}
		return row.openWorldProven
	}
	if f.OpenedOnce && f.OpenWorld != rcxProofDisproven && !f.OpenLapsed && f.Origin != rcxOriginDomestic {
		if f.Breaker {
			return row.breakerProven
		}
		return row.openWorldProven
	}
	if f.Domestic == rcxProofProven {
		return row.domesticProven
	}
	if f.Exit == rcxOriginUnknown && f.Origin == rcxOriginDomestic && !f.OpenedOnce {
		return row.domesticPrior
	}
	return row.foreignPrior
}

func legacyAdmit(terrain rcxTerrain, f rcxFacts) rcxVerdict {
	verdict := legacyAdmitTier(terrain, f)
	if f.NameHome && verdict > rcxVerdictLastResort {
		return rcxVerdictLastResort
	}
	return verdict
}

func TestAdmitRulesMatchLegacyExhaustive(t *testing.T) {
	proofs := []rcxProof{rcxProofUnknown, rcxProofProven, rcxProofDisproven}
	origins := []rcxOrigin{rcxOriginUnknown, rcxOriginForeign, rcxOriginDomestic}
	trusts := []rcxTrust{rcxTrustUnknown, rcxTrustSuspect, rcxTrusted, rcxTrustBranded}
	bools := []bool{false, true}
	terrains := []rcxTerrain{
		rcxTerrainUnknown, rcxTerrainNormal, rcxTerrainWhitelist, rcxTerrainPortal, rcxTerrainOffline,
	}
	cases := 0
	for _, terrain := range terrains {
		for _, origin := range origins {
			for _, exit := range origins {
				for _, openWorld := range proofs {
					for _, domestic := range proofs {
						for _, transit := range proofs {
							for _, trust := range trusts {
								for _, breaker := range bools {
									for _, openedOnce := range bools {
										for _, openLapsed := range bools {
											for _, nameHome := range bools {
												f := rcxFacts{
													Origin:     origin,
													Exit:       exit,
													OpenedOnce: openedOnce,
													OpenWorld:  openWorld,
													OpenLapsed: openLapsed,
													Domestic:   domestic,
													Transit:    transit,
													Breaker:    breaker,
													Trust:      trust,
													NameHome:   nameHome,
												}
												if got, want := rcxAdmit(terrain, f), legacyAdmit(terrain, f); got != want {
													t.Fatalf("admit %v %+v: got %v want %v", terrain, f, got, want)
												}
												cases++
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
	if cases == 0 {
		t.Fatal("no cases enumerated")
	}
}

// The three leading rejects are the safety floor: they must hold whatever the
// terrain row says, so a future terrain or profile edit cannot admit a branded or
// transit-disproven node.
func TestAdmitSafetyFloorRejectsRegardlessOfTerrain(t *testing.T) {
	floors := []rcxFacts{
		{Transit: rcxProofDisproven, OpenWorld: rcxProofProven},
		{Trust: rcxTrustBranded, OpenWorld: rcxProofProven, Exit: rcxOriginForeign},
		{OpenWorld: rcxProofDisproven, Domestic: rcxProofUnknown},
	}
	for _, terrain := range []rcxTerrain{rcxTerrainNormal, rcxTerrainWhitelist, rcxTerrainUnknown} {
		for _, f := range floors {
			if got := rcxAdmit(terrain, f); got != rcxVerdictReject {
				t.Fatalf("safety floor %v %+v: got %v want reject", terrain, f, got)
			}
		}
	}
}
