package main

import (
	"context"
	"crypto/rand"
	"encoding/binary"
	"errors"
	"net/netip"
	"net/url"
	"strconv"
	"time"
)

const (
	doctorProbeSchemaVersion  = 1
	doctorProbeBindAttempts   = 2
	doctorProbeAddressLimit   = 2
	doctorProbeConnectTimeout = 3 * time.Second
	doctorProbeReadTimeout    = time.Second
	doctorProbeIdentityWait   = 500 * time.Millisecond
	doctorProbeByteBudget     = 1024
	doctorProbePortBase       = 49152
	doctorProbePortCount      = 65536 - doctorProbePortBase
)

type doctorPlatformProbeOutcome string

const (
	doctorPlatformProbeCompleted     doctorPlatformProbeOutcome = "completed"
	doctorPlatformProbeBindCollision doctorPlatformProbeOutcome = "bindCollision"
	doctorPlatformProbeTimeout       doctorPlatformProbeOutcome = "timeout"
	doctorPlatformProbeIOError       doctorPlatformProbeOutcome = "ioError"
	doctorPlatformProbeUnsupported   doctorPlatformProbeOutcome = "unsupported"
	doctorPlatformProbeCancelled     doctorPlatformProbeOutcome = "cancelled"
)

type doctorPlatformProbeRequest struct {
	SchemaVersion        int    `json:"schemaVersion"`
	ExamID               string `json:"examId"`
	ProbeID              string `json:"probeId"`
	Protocol             string `json:"protocol"`
	DestinationIP        string `json:"destinationIp"`
	DestinationPort      uint16 `json:"destinationPort"`
	SourcePort           uint16 `json:"sourcePort"`
	ConnectTimeoutMillis int64  `json:"connectTimeoutMillis"`
	ReadTimeoutMillis    int64  `json:"readTimeoutMillis"`
	ByteBudget           int    `json:"byteBudget"`
}

type doctorPlatformProbeResult struct {
	ProbeID          string                     `json:"probeId"`
	Outcome          doctorPlatformProbeOutcome `json:"outcome"`
	ErrorCode        string                     `json:"errorCode,omitempty"`
	DurationBucketMs int64                      `json:"durationBucketMs,omitempty"`
}

type doctorPlatformProbeRunner func(context.Context, doctorPlatformProbeRequest) (doctorPlatformProbeResult, error)

func (result doctorPlatformProbeResult) validFor(request doctorPlatformProbeRequest) bool {
	if result.ProbeID != request.ProbeID {
		return false
	}
	switch result.Outcome {
	case doctorPlatformProbeCompleted, doctorPlatformProbeBindCollision,
		doctorPlatformProbeTimeout, doctorPlatformProbeIOError,
		doctorPlatformProbeUnsupported, doctorPlatformProbeCancelled:
		return true
	default:
		return false
	}
}

func doctorProbeDestination(target string) (string, uint16, error) {
	parsed, err := url.Parse(target)
	if err != nil || parsed.Hostname() == "" {
		return "", 0, errors.New("invalid probe target")
	}
	port := parsed.Port()
	if port == "" {
		switch parsed.Scheme {
		case "http":
			port = "80"
		case "https":
			port = "443"
		default:
			return "", 0, errors.New("unsupported probe scheme")
		}
	}
	value, err := strconv.ParseUint(port, 10, 16)
	if err != nil || value == 0 {
		return "", 0, errors.New("invalid probe port")
	}
	return parsed.Hostname(), uint16(value), nil
}

func randomDoctorProbePort() (uint16, error) {
	var value [2]byte
	if _, err := rand.Read(value[:]); err != nil {
		return 0, err
	}
	return doctorProbePortBase + binary.BigEndian.Uint16(value[:])%doctorProbePortCount, nil
}

func doctorProbeAddresses(addresses []netip.Addr) []netip.Addr {
	result := make([]netip.Addr, 0, doctorProbeAddressLimit)
	seen := make(map[netip.Addr]struct{}, doctorProbeAddressLimit)
	for _, address := range addresses {
		if !address.IsValid() {
			continue
		}
		address = address.Unmap()
		if _, exists := seen[address]; exists {
			continue
		}
		seen[address] = struct{}{}
		result = append(result, address)
		if len(result) == doctorProbeAddressLimit {
			break
		}
	}
	return result
}
