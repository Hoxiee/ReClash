package rcx

import (
	"net"
	"strings"
	"time"
)

// Seam between the engine and its host adapter (package main): the aliases below
// are the only names the host binds to, so main imports rcx and never the reverse.

const (
	rcxGroupPrefix = "RCX-"
	rcxGroupNode   = "RCX-NODE"
	rcxGroupFinal  = "RCX-FINAL"
	rcxGroupDirect = "RCX-DIRECT"
)

const rcxLocateTimeout = 6 * time.Second

func rcxHostOf(address string) string {
	host, _, err := net.SplitHostPort(address)
	if err != nil {
		return strings.TrimSpace(address)
	}
	return host
}

// The canonical network payload lives here; the host aliases onto it.
type NetworkPayload struct {
	Transport     string   `json:"transport"`
	SSID          string   `json:"ssid"`
	Carrier       string   `json:"carrier"`
	Gateways      []string `json:"gateways"`
	DHCPServer    string   `json:"dhcp"`
	DNSServers    []string `json:"dns"`
	IPv4          []string `json:"ipv4"`
	Validated     bool     `json:"validated"`
	CaptivePortal bool     `json:"portal"`
	Metered       bool     `json:"metered"`
}

type rcxNetworkPayload = NetworkPayload

// Cosmetics counter injected by the host; a nil odometer falls back to no-op.
type Odometer interface {
	NoteRecovery()
	NoteAutoDecision()
	NoteCountry(country string)
}

type rcxNoopOdometer struct{}

func (rcxNoopOdometer) NoteRecovery()        {}
func (rcxNoopOdometer) NoteAutoDecision()    {}
func (rcxNoopOdometer) NoteCountry(_ string) {}

type (
	Engine       = rcxEngine
	Runtime      = rcxRuntime
	Config       = rcxConfig
	Member       = rcxMember
	Marker       = rcxMarker
	Status       = rcxStatus
	Report       = rcxReport
	ProbeOutcome = rcxProbeOutcome
	ConnSample   = rcxConnSample
	LaneConfig   = rcxLaneConfig
	Storage      = rcxStorage
	CacheStorage = rcxCacheStorage
	DiagQuery    = rcxDiagQuery
	DiagBatch    = rcxDiagBatch
)

const (
	GroupPrefix = rcxGroupPrefix
	GroupNode   = rcxGroupNode
	GroupFinal  = rcxGroupFinal
	GroupDirect = rcxGroupDirect

	LaneReject       = rcxLaneReject
	LaneFallbackMain = rcxLaneFallbackMain

	ProbeOK             = rcxProbeOK
	ProbeStatusMismatch = rcxProbeStatusMismatch
	ProbeFail           = rcxProbeFail
	ProbeOverloaded     = rcxProbeOverloaded

	HarvestFloorMs = rcxHarvestFloorMs
	LocateTimeout  = rcxLocateTimeout
)

var (
	NewEngine     = newRcxEngine
	DefaultConfig = rcxDefaultConfig
	OutcomeName   = rcxOutcomeName
	HostOf        = rcxHostOf

	CloneNetworkFacts     = cloneNetworkFacts
	NormalizeNetworkFacts = normalizedNetworkFacts
	EqualNetworkFacts     = equalNetworkFacts
)
