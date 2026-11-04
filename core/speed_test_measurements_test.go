package core

import (
	"bytes"
	"context"
	"encoding/json"
	"io"
	"math"
	"slices"
	"sync"
	"testing"
	"time"
)

func TestSpeedTestRatesUseMegabitsAndDiscardTheRamp(t *testing.T) {
	samples := []speedTestByteSample{{at: 0}, {at: time.Second, bytes: 1_000_000}, {at: 2 * time.Second, bytes: 3_000_000}}
	if got := speedTestWindowSpeed(samples[:2], time.Second); got != 8 {
		t.Fatalf("one megabyte per second = %g, want 8 Mbps", got)
	}
	if got := speedTestStableSpeed(samples); got != 16 {
		t.Fatalf("stable speed = %g, want 16 Mbps after ramp-up", got)
	}
	short := []speedTestByteSample{{at: 0}, {at: 10 * time.Millisecond, bytes: 10_000}}
	if got := speedTestStableSpeed(short); got != 8 {
		t.Fatalf("limited short run = %g, want 8 Mbps", got)
	}
	if speedTestStableSpeed(nil) != 0 || speedTestWindowSpeed(samples[:1], time.Second) != 0 {
		t.Fatal("empty measurements produced a rate")
	}
}

func TestSpeedTestJitterAndRPMMatchReferenceAlgorithms(t *testing.T) {
	values := []float64{20, 10, 30, 40}
	copy := slices.Clone(values)
	stats := speedTestLatencyStats(values)
	if stats == nil || stats.Count != 4 || stats.MedianMs != 25 || stats.JitterMs == nil || math.Abs(*stats.JitterMs-40.0/3) > 1e-9 {
		t.Fatalf("latency statistics = %+v", stats)
	}
	if !slices.Equal(values, copy) {
		t.Fatal("latency statistics reordered the caller's samples")
	}
	if rpm := speedTestRPM([]float64{100, 200, 300}); rpm == nil || *rpm != 300 {
		t.Fatalf("RPM = %v, want 60000 / 200", rpm)
	}
	if speedTestRPM(nil) != nil || speedTestRPM([]float64{0}) != nil || speedTestLatencyStats([]float64{math.NaN(), math.Inf(1)}) != nil {
		t.Fatal("invalid latency data produced a measurement")
	}
	if only := speedTestLatencyStats([]float64{1}); only == nil || only.JitterMs != nil {
		t.Fatal("one probe manufactured jitter")
	}
	for header, want := range map[string]float64{
		"cfRequestDuration;dur=12.5":   12.5,
		"cache;desc=hit, origin;dur=3": 3,
		"request;dur=NaN":              0,
		"request;dur=-2":               0,
	} {
		if got := speedTestServerTiming(header); got != want {
			t.Fatalf("server timing %q = %g, want %g", header, got, want)
		}
	}
}

func TestSpeedTestConcurrentReservationsNeverExceedTheSharedLimit(t *testing.T) {
	const limit = 123457
	budget := newSpeedTestBudget(limit)
	var workers sync.WaitGroup
	errors := make(chan error, 64)
	for index := range 64 {
		workers.Add(1)
		safeGo("testSpeedTestBudget", func() {
			defer workers.Done()
			for {
				reservation := budget.reserve(speedTestDirection(index%3), 257, 1)
				if reservation == nil {
					return
				}
				if err := reservation.consume(max(1, reservation.amount/2)); err != nil {
					errors <- err
					return
				}
				reservation.release()
				if spent := budget.spent(); spent > limit {
					t.Errorf("spent %d beyond %d", spent, limit)
				}
			}
		})
	}
	workers.Wait()
	close(errors)
	for err := range errors {
		t.Error(err)
	}
	if budget.spent() != limit {
		t.Fatalf("spent %d, want all %d bytes admitted once", budget.spent(), limit)
	}
	for direction := speedTestProbe; direction <= speedTestUpload; direction++ {
		if budget.reserved[direction] != 0 || budget.used[direction] != budget.limits[direction] {
			t.Fatalf("direction %d: used=%d reserved=%d limit=%d", direction, budget.used[direction], budget.reserved[direction], budget.limits[direction])
		}
	}
}

func TestSpeedTestReservesUploadAndProbeTrafficBeforeDownloading(t *testing.T) {
	budget := newSpeedTestBudget(1024)
	down := budget.reserve(speedTestDownload, 1024, 1)
	if down == nil || down.amount != 480 {
		t.Fatalf("download reservation = %+v", down)
	}
	if err := down.consume(down.amount); err != nil {
		t.Fatal(err)
	}
	down.release()
	if budget.reserve(speedTestDownload, 1, 1) != nil {
		t.Fatal("download stole another direction's bytes")
	}
	up := budget.reserve(speedTestUpload, 1024, 1)
	probe := budget.reserve(speedTestProbe, 1024, 1)
	if up == nil || up.amount != 480 || probe == nil || probe.amount != 64 {
		t.Fatalf("protected reservations: upload=%+v probe=%+v", up, probe)
	}
	if err := up.consume(100); err != nil {
		t.Fatal(err)
	}
	up.release()
	up.release()
	probe.release()
	if budget.available(speedTestUpload) != 380 || budget.spent() != 580 {
		t.Fatal("unused reservation was not refunded exactly once")
	}
	if err := up.consume(1); err == nil {
		t.Fatal("a released reservation admitted new bytes")
	}
}

func TestSpeedTestUploadReaderCountsAttemptedBytesWithoutCreditingAMeter(t *testing.T) {
	budget := newSpeedTestBudget(1000)
	reservation := budget.reserve(speedTestUpload, 300, 1)
	body := &speedTestUploadBody{payload: []byte{1, 2, 3}, reservation: reservation}
	buffer := make([]byte, 100)
	if count, err := body.Read(buffer); count != 100 || err != nil || body.sentBytes() != 100 || budget.spent() != 100 {
		t.Fatalf("upload read count=%d err=%v spent=%d", count, err, budget.spent())
	}
	for index, value := range buffer {
		if value != byte(index%3+1) {
			t.Fatal("upload payload was not repeated locally")
		}
	}
	_ = body.Close()
	reservation.release()
	if _, err := body.Read(buffer); err != io.EOF {
		t.Fatalf("closed upload reader = %v", err)
	}
	if budget.spent() != 100 {
		t.Fatal("closing a failed upload refunded attempted payload")
	}
}

func TestSpeedTestConfirmedUploadMeterSpreadsAcknowledgements(t *testing.T) {
	meter := newSpeedTestMeter(4 * time.Second)
	if speedTestStableSpeed(meter.samples(3*time.Second)) != 0 {
		t.Fatal("unconfirmed traffic produced a rate")
	}
	meter.confirm(0, 4*time.Second, 8_000_000)
	samples := meter.samples(4 * time.Second)
	if math.Abs(speedTestStableSpeed(samples)-16) > 1e-9 || samples[len(samples)-1].bytes != 8_000_000 {
		t.Fatalf("confirmed upload speed=%g bytes=%d", speedTestStableSpeed(samples), samples[len(samples)-1].bytes)
	}
	meter.freeze()
	meter.confirm(0, time.Second, 100)
	meter.add(time.Second, 100)
	if after := meter.samples(4 * time.Second); after[len(after)-1].bytes != 8_000_000 {
		t.Fatal("finished meter changed")
	}
}

func TestSpeedTestSnapshotSamplesAndWireValuesStayBounded(t *testing.T) {
	run := newSpeedTestRun(speedTestTestParams(t, "complete"))
	defer run.cancel()
	run.duration = 30 * time.Second
	meter := newSpeedTestMeter(run.duration)
	meter.confirm(0, run.duration, 30_000_000)
	samples := meter.samples(run.duration)
	run.publishLoad(samples, false, run.duration)
	run.publishLoad(samples, true, run.duration)
	state := run.snapshot()
	for _, direction := range [][]SpeedTestSample{state.DownloadSamples, state.UploadSamples} {
		if len(direction) == 0 || len(direction) > speedTestMaxSamples || direction[len(direction)-1].ElapsedMs != 30_000 {
			t.Fatalf("invalid sample bounds: %d", len(direction))
		}
		for index, sample := range direction {
			if sample.Mbps < 0 || math.IsInf(sample.Mbps, 0) || math.IsNaN(sample.Mbps) || (index > 0 && sample.ElapsedMs <= direction[index-1].ElapsedMs) {
				t.Fatalf("invalid sample %+v", sample)
			}
		}
	}
	body, err := json.Marshal(state)
	if err != nil || len(body) > speedTestMaxResponse {
		t.Fatalf("snapshot encoding: bytes=%d err=%v", len(body), err)
	}
	var wire map[string]any
	if err := json.Unmarshal(body, &wire); err != nil {
		t.Fatal(err)
	}
	for _, key := range []string{"requestId", "backendId", "downloadMbps", "uploadMbps", "elapsedMs", "coreEpoch", "routeVersion", "hits", "protocolFallback", "downloadSamples", "uploadSamples"} {
		if _, present := wire[key]; !present {
			t.Fatalf("wire field %s is absent", key)
		}
	}
	if state.Progress < 0 || state.Progress > 1 {
		t.Fatalf("progress = %g", state.Progress)
	}
}

func TestSpeedTestNormalizesLimitsAndRejectsInvalidInputs(t *testing.T) {
	params, err := normalizeSpeedTestParams(SpeedTestParams{RequestID: "normalize", DurationSeconds: 99, Streams: 99, ByteLimit: 2 * speedTestMaxBytes})
	if err != nil || params.DurationSeconds != 30 || params.Streams != 16 || params.ByteLimit != speedTestMaxBytes || params.Protocol != "h2" || params.Mode != "complete" {
		t.Fatalf("normalization = %+v, %v", params, err)
	}
	run := newSpeedTestRun(params)
	defer run.cancel()
	deadline, bounded := run.ctx.Deadline()
	if !bounded || time.Until(deadline) > speedTestDeadline {
		t.Fatal("run has no hard deadline")
	}
	for _, invalid := range []SpeedTestParams{
		{}, {RequestID: "bad", BackendID: "unknown"}, {RequestID: "bad", Protocol: "udp"}, {RequestID: "bad", Mode: "full"},
	} {
		if _, err := normalizeSpeedTestParams(invalid); err == nil {
			t.Fatalf("accepted invalid params %+v", invalid)
		}
	}
	if _, err := readSpeedTestResponse(bytes.NewReader(make([]byte, speedTestMaxResponse+1)), speedTestMaxResponse); err == nil {
		t.Fatal("accepted an oversized provider response")
	}
	if _, err := readSpeedTestResponse(bytes.NewReader(make([]byte, speedTestMaxResponse)), speedTestMaxResponse); err != nil {
		t.Fatal(err)
	}
	ctx, cancel := context.WithCancel(context.Background())
	cancel()
	if speedTestWait(ctx, 0) {
		t.Fatal("cancelled context was treated as active")
	}
}

func TestSpeedTestUsesOneOrEightIndependentTransferClients(t *testing.T) {
	for _, streams := range []int{1, 8} {
		fixture := &speedTestFixture{}
		run := speedTestLocalRun(t, "complete", fixture)
		run.params.Streams = streams
		run.run()
		if len(run.load) != streams || run.snapshot().Phase != "done" {
			t.Fatalf("streams=%d clients=%d result=%+v", streams, len(run.load), run.snapshot())
		}
	}
}
