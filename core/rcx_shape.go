package main

import (
	"context"
	"time"

	"core/rcx"

	"github.com/metacubex/http"
)

// A clamp verdict needs the arrival curve of a sized pull, not its mean, so the
// shape probe streams a fixed payload through one node and timestamps the running
// byte total. The engine judges the curve (rcx_clamp.go); this only measures it.
const rcxShapeTimeout = 20 * time.Second

// rcxShapeRecorder turns the probe's cumulative-byte callbacks into checkpoints
// clocked from the first byte, so time-to-first-byte never counts against the
// transfer rate the verdict reads.
type rcxShapeRecorder struct {
	clock    func() time.Time
	baseline time.Time
	points   []rcx.ShapeCheckpoint
}

func (r *rcxShapeRecorder) observe(total int64) {
	now := r.clock()
	if r.baseline.IsZero() {
		r.baseline = now
	}
	r.points = append(r.points, rcx.ShapeCheckpoint{
		Bytes: total,
		Since: now.Sub(r.baseline),
	})
}

func (r *rcxShapeRecorder) sample(reached bool) rcx.ShapeSample {
	if !reached || len(r.points) == 0 {
		return rcx.ShapeSample{Dead: true}
	}
	return rcx.ShapeSample{Checkpoints: r.points}
}

// rcxShapeProbe pulls payloadBytes of target through node and returns the shape
// of its arrival. A dial that never delivered a body is Dead -- a reachability
// failure the dial path owns, never a shape verdict.
func rcxShapeProbe(ctx context.Context, node, target string, payloadBytes int64) rcx.ShapeSample {
	recorder := &rcxShapeRecorder{clock: time.Now}
	result := runProbe(ctx, probeRequest{
		method:    http.MethodGet,
		url:       target,
		proxyName: node,
		headers:   map[string]string{"User-Agent": browserUserAgent},
		timeout:   rcxShapeTimeout,
		maxBody:   payloadBytes,
		onChunk:   recorder.observe,
	})
	return recorder.sample(result != nil && result.Error == "")
}
