package rcx

import "time"

// The clamp probe pulls a sized stream through one node and reads its shape, not
// its mean: operators pass a short burst at line speed, then pin the rest to a
// video-grade floor. An early cliff into a sub-floor plateau is that signature; a
// stream slow from the first byte is a far or tired server, not a squeeze. This
// is what the passive detector (rcx_traffic.go) cannot see on a standby node.

type rcxClampVerdict uint8

const (
	rcxClampInconclusive rcxClampVerdict = iota
	rcxClampClean
	rcxClamped
	rcxClampFloor
)

func (v rcxClampVerdict) String() string {
	switch v {
	case rcxClampClean:
		return "clean"
	case rcxClamped:
		return "clamp"
	case rcxClampFloor:
		return "floor"
	default:
		return "inconclusive"
	}
}

const (
	// The free burst passed before the clamp bites — the "16" the probe is named
	// for; the sustained read is everything past it.
	rcxClampAllowanceKB    = 64
	rcxClampPayloadKB      = 256
	rcxClampMinSustainedKB = 64
	rcxClampMinSample      = 2 * time.Second
	rcxClampRatioNum       = 4
)

type rcxShapeCheckpoint struct {
	Bytes int64
	Since time.Duration
}

type rcxShapeSample struct {
	Checkpoints []rcxShapeCheckpoint
	// No usable stream (dial failed, reset, empty body): a reachability failure
	// the dial path owns, not a shape verdict.
	Dead bool
}

type rcxClampLimits struct {
	AllowanceBytes    int64
	FloorBytesPerSec  float64
	MinSustainedBytes int64
	RatioNum          int
}

func rcxClampLimitsFor(floorKBps int) rcxClampLimits {
	return rcxClampLimits{
		AllowanceBytes:    rcxClampAllowanceKB * 1024,
		FloorBytesPerSec:  float64(floorKBps) * 1024,
		MinSustainedBytes: rcxClampMinSustainedKB * 1024,
		RatioNum:          rcxClampRatioNum,
	}
}

// rcxClampShape reduces a streamed pull to a verdict and the sustained KB/s it
// measured. Anything it cannot separate cleanly stays inconclusive, never an
// accusation.
func rcxClampShape(sample rcxShapeSample, lim rcxClampLimits) (rcxClampVerdict, int) {
	if sample.Dead || lim.FloorBytesPerSec <= 0 || len(sample.Checkpoints) == 0 {
		return rcxClampInconclusive, 0
	}
	var boundary rcxShapeCheckpoint
	crossed := false
	for _, point := range sample.Checkpoints {
		if point.Bytes >= lim.AllowanceBytes {
			boundary = point
			crossed = true
			break
		}
	}
	if !crossed {
		return rcxClampInconclusive, 0
	}
	total := sample.Checkpoints[len(sample.Checkpoints)-1]
	sustainedBytes := total.Bytes - boundary.Bytes
	sustainedFor := total.Since - boundary.Since
	if sustainedBytes < lim.MinSustainedBytes || sustainedFor < rcxClampMinSample || boundary.Since <= 0 {
		return rcxClampInconclusive, 0
	}
	sustainedRate := float64(sustainedBytes) / sustainedFor.Seconds()
	kbps := int(sustainedRate / 1024)
	if sustainedRate >= lim.FloorBytesPerSec {
		return rcxClampClean, kbps
	}
	// Under the floor: a cliff off a fast burst is a clamp (the network's doing);
	// a stream always this slow is the node's own.
	earlyRate := float64(boundary.Bytes) / boundary.Since.Seconds()
	if earlyRate >= sustainedRate*float64(lim.RatioNum) {
		return rcxClamped, kbps
	}
	return rcxClampFloor, kbps
}
