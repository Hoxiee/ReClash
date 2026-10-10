package main

import (
	"testing"
	"time"

	"core/rcx"
)

func TestShapeRecorderClocksFromFirstByte(t *testing.T) {
	base := time.Unix(0, 0)
	ticks := []time.Duration{0, 200 * time.Millisecond, 1200 * time.Millisecond}
	i := 0
	recorder := &rcxShapeRecorder{clock: func() time.Time {
		at := base.Add(ticks[i])
		i++
		return at
	}}
	recorder.observe(32 * 1024)
	recorder.observe(64 * 1024)
	recorder.observe(256 * 1024)

	sample := recorder.sample(true)
	if sample.Dead {
		t.Fatal("a delivered body must not read as Dead")
	}
	if len(sample.Checkpoints) != 3 {
		t.Fatalf("want 3 checkpoints, got %d", len(sample.Checkpoints))
	}
	if sample.Checkpoints[0].Since != 0 {
		t.Errorf("first checkpoint is the baseline, want 0, got %s", sample.Checkpoints[0].Since)
	}
	if sample.Checkpoints[2].Since != 1200*time.Millisecond {
		t.Errorf("last checkpoint should be 1.2s past the first byte, got %s", sample.Checkpoints[2].Since)
	}
}

func TestShapeRecorderDeadWhenUnreachedOrEmpty(t *testing.T) {
	empty := (&rcxShapeRecorder{clock: time.Now}).sample(true)
	if !empty.Dead {
		t.Error("no bytes observed must read as Dead")
	}
	rec := &rcxShapeRecorder{clock: time.Now}
	rec.observe(32 * 1024)
	if got := rec.sample(false); !got.Dead {
		t.Error("a failed pull must read as Dead regardless of bytes seen")
	}
}

func TestShapePayloadBytesIsCanonical(t *testing.T) {
	if rcx.ShapePayloadBytes != 256*1024 {
		t.Errorf("shape payload should be 256KB, got %d", rcx.ShapePayloadBytes)
	}
}
