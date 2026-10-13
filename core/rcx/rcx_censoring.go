package rcx

type rcxCensorSource uint8

const (
	rcxCensorOff rcxCensorSource = iota
	rcxCensorConfigured
	rcxCensorMeasured
	rcxCensorBoth
)

func (s rcxCensorSource) String() string {
	switch s {
	case rcxCensorConfigured:
		return "configured"
	case rcxCensorMeasured:
		return "measured"
	case rcxCensorBoth:
		return "both"
	}
	return "off"
}

func rcxCensorSourceOf(configured, measured bool) rcxCensorSource {
	switch {
	case configured && measured:
		return rcxCensorBoth
	case configured:
		return rcxCensorConfigured
	case measured:
		return rcxCensorMeasured
	}
	return rcxCensorOff
}

// Each switch still derives from the one flag it replaces, so decisions stay
// byte-for-byte; the names let a decision report which behaviour bit it.
type rcxCensorPolicy struct {
	Source                       rcxCensorSource
	UnprovenHasNoLatency         bool
	HomeRiskRung                 bool
	DistrustEntryPingAtColdStart bool
	StrandRatherThanDomestic     bool
	NameHomeStamp                bool
	KeepProbingUnproven          bool
	VerifyWinnerCountry          bool
}

func rcxCensorPolicyFor(source rcxCensorSource) rcxCensorPolicy {
	armed := source != rcxCensorOff
	return rcxCensorPolicy{
		Source:                       source,
		UnprovenHasNoLatency:         armed,
		HomeRiskRung:                 armed,
		DistrustEntryPingAtColdStart: armed,
		// A measured whitelist alone must not strand: with no author list, domestic stays a last resort.
		StrandRatherThanDomestic: source == rcxCensorConfigured || source == rcxCensorBoth,
		NameHomeStamp:            armed,
		KeepProbingUnproven:      armed,
		VerifyWinnerCountry:      armed,
	}
}

func (p rcxCensorPolicy) armed() bool {
	return p.Source != rcxCensorOff
}

func (p rcxCensorPolicy) configured() bool {
	return p.Source == rcxCensorConfigured || p.Source == rcxCensorBoth
}
