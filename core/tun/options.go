package tun

import (
	"encoding/json"
	"strings"
)

const (
	defaultMTU uint32 = 1500
	minMTU     uint32 = 1280
	maxMTU     uint32 = 65535
)

// Options mirrors the Kotlin VpnOptions.tunOptions payload. The file carries no
// build tag so the normalization stays testable off an Android host.
type Options struct {
	MTU                  uint32 `json:"mtu"`
	CongestionController string `json:"congestion-controller"`
}

func (o Options) NormalizedMTU() uint32 {
	switch {
	case o.MTU == 0:
		return defaultMTU
	case o.MTU < minMTU:
		return minMTU
	case o.MTU > maxMTU:
		return maxMTU
	default:
		return o.MTU
	}
}

// ParseOptions treats an empty payload as zero-value Options; a non-empty but
// malformed payload errors instead of arming a half-parsed configuration.
func ParseOptions(raw string) (Options, error) {
	opts := Options{}
	if strings.TrimSpace(raw) == "" {
		return opts, nil
	}
	if err := json.Unmarshal([]byte(raw), &opts); err != nil {
		return Options{}, err
	}
	return opts, nil
}
