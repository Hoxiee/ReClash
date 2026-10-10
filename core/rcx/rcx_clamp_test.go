package rcx

import (
	"testing"
	"time"
)

func shapeSample(dead bool, points ...[2]int64) rcxShapeSample {
	sample := rcxShapeSample{Dead: dead}
	for _, point := range points {
		sample.Checkpoints = append(sample.Checkpoints, rcxShapeCheckpoint{
			Bytes: point[0] * 1024,
			Since: time.Duration(point[1]) * time.Millisecond,
		})
	}
	return sample
}

func TestClampShapeVerdicts(t *testing.T) {
	lim := rcxClampLimitsFor(rcxThrottleFloorKBps)
	cases := []struct {
		name   string
		sample rcxShapeSample
		want   rcxClampVerdict
	}{
		{"clean throughput holds above the floor", shapeSample(false, [2]int64{64, 500}, [2]int64{256, 2500}), rcxClampClean},
		{"fast burst then a sub-floor plateau is a clamp", shapeSample(false, [2]int64{64, 100}, [2]int64{128, 10000}), rcxClamped},
		{"slow from the first byte is the node, not a clamp", shapeSample(false, [2]int64{64, 8000}, [2]int64{128, 16000}), rcxClampFloor},
		{"a dead pull is a reachability failure, not a shape", shapeSample(true), rcxClampInconclusive},
		{"a stream that never crosses the allowance cannot be judged", shapeSample(false, [2]int64{16, 200}, [2]int64{32, 400}), rcxClampInconclusive},
		{"too few sustained bytes stays inconclusive", shapeSample(false, [2]int64{64, 500}, [2]int64{70, 600}), rcxClampInconclusive},
		{"too short a sustained window stays inconclusive", shapeSample(false, [2]int64{64, 500}, [2]int64{128, 1000}), rcxClampInconclusive},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			got, _ := rcxClampShape(tc.sample, lim)
			if got != tc.want {
				t.Errorf("got %s, want %s", got, tc.want)
			}
		})
	}
}

func TestClampShapeReportsSustainedRate(t *testing.T) {
	lim := rcxClampLimitsFor(rcxThrottleFloorKBps)
	_, kbps := rcxClampShape(shapeSample(false, [2]int64{64, 500}, [2]int64{256, 2500}), lim)
	if kbps < 90 || kbps > 100 {
		t.Errorf("sustained 192KB over 2s should read ~96 KB/s, got %d", kbps)
	}
}
