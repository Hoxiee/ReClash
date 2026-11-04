package core

import (
	"context"
	"encoding/json"
	"errors"
	"io"
	"net/http"
	"net/http/httptest"
	"slices"
	"strconv"
	"sync"
	"sync/atomic"
	"testing"
	"time"
)

type speedTestFixture struct {
	latencies atomic.Int64
	downloads atomic.Int64
	uploads   atomic.Int64
	posts     atomic.Int64
	downCode  int
	upCode    int
	downWait  time.Duration
	upWait    time.Duration
	onPost    func(context.Context, int64)
}

func (f *speedTestFixture) serve(w http.ResponseWriter, req *http.Request) {
	switch req.URL.Path {
	case "/latency":
		f.latencies.Add(1)
		_, _ = io.WriteString(w, "pong")
	case "/down":
		if f.downCode != 0 {
			w.WriteHeader(f.downCode)
			return
		}
		count, _ := strconv.ParseInt(req.URL.Query().Get("bytes"), 10, 64)
		w.Header().Set("Content-Type", "application/octet-stream")
		w.Header().Set("Content-Length", strconv.FormatInt(count, 10))
		buffer := make([]byte, 16*1024)
		for count > 0 {
			if !speedTestWait(req.Context(), f.downWait) {
				return
			}
			n, err := w.Write(buffer[:min(int64(len(buffer)), count)])
			f.downloads.Add(int64(n))
			count -= int64(n)
			if err != nil {
				return
			}
		}
	case "/up":
		post := f.posts.Add(1)
		count, err := io.Copy(io.Discard, req.Body)
		f.uploads.Add(count)
		if err != nil {
			return
		}
		if f.onPost != nil {
			f.onPost(req.Context(), post)
		}
		if !speedTestWait(req.Context(), f.upWait) {
			return
		}
		if f.upCode != 0 {
			w.WriteHeader(f.upCode)
		}
	default:
		w.WriteHeader(http.StatusNotFound)
	}
}

func speedTestWait(ctx context.Context, duration time.Duration) bool {
	if duration == 0 {
		return ctx.Err() == nil
	}
	timer := time.NewTimer(duration)
	defer timer.Stop()
	select {
	case <-ctx.Done():
		return false
	case <-timer.C:
		return true
	}
}

func speedTestTestParams(t *testing.T, mode string) SpeedTestParams {
	t.Helper()
	params, err := normalizeSpeedTestParams(SpeedTestParams{
		RequestID: t.Name(), BackendID: "cloudflare", DurationSeconds: 1,
		Protocol: "h1", Streams: 2, Mode: mode, ByteLimit: 4 * 1024 * 1024, Direct: true,
	})
	if err != nil {
		t.Fatal(err)
	}
	return params
}

func speedTestLocalTarget(server *httptest.Server) *speedTestTarget {
	return &speedTestTarget{
		backend: "cloudflare", latencyURL: server.URL + "/latency", downloadURL: server.URL + "/down",
		uploadURL: server.URL + "/up", server: SpeedTestServer{ID: "local", Name: "Local test", Host: server.Listener.Addr().String()},
	}
}

func speedTestLocalRun(t *testing.T, mode string, fixture *speedTestFixture) *speedTestRun {
	t.Helper()
	server := httptest.NewServer(http.HandlerFunc(fixture.serve))
	t.Cleanup(server.Close)
	run := newSpeedTestRun(speedTestTestParams(t, mode))
	run.duration = 80 * time.Millisecond
	run.prepare = func(context.Context, *speedTestRun) (*speedTestTarget, error) {
		return speedTestLocalTarget(server), nil
	}
	t.Cleanup(run.cancel)
	return run
}

func awaitSpeedTest(t *testing.T, done <-chan struct{}) {
	t.Helper()
	select {
	case <-done:
	case <-time.After(3 * time.Second):
		t.Fatal("speed test did not stop")
	}
}

func awaitSpeedTestManager(t *testing.T, manager *speedTestManager) {
	t.Helper()
	deadline := time.Now().Add(3 * time.Second)
	for {
		manager.mu.Lock()
		idle := !manager.worker
		manager.mu.Unlock()
		if idle {
			return
		}
		if time.Now().After(deadline) {
			t.Fatal("speed test manager did not become idle")
		}
		<-time.After(time.Millisecond)
	}
}

func TestSpeedTestLatencyOnlyNeverTransfersBulkPayload(t *testing.T) {
	fixture := &speedTestFixture{}
	run := speedTestLocalRun(t, "latencyOnly", fixture)
	run.run()
	state := run.snapshot()
	if state.Phase != "done" || state.Stage != "latency" || state.Progress != 1 || state.Latency == nil || state.Latency.Count != 20 {
		t.Fatalf("latency result = %+v", state)
	}
	if fixture.latencies.Load() != 22 || fixture.downloads.Load() != 0 || fixture.posts.Load() != 0 {
		t.Fatalf("requests: latency=%d download=%d upload=%d", fixture.latencies.Load(), fixture.downloads.Load(), fixture.posts.Load())
	}
	if state.DownloadMbps != nil || state.UploadMbps != nil || len(state.DownloadSamples) != 0 || len(state.UploadSamples) != 0 {
		t.Fatal("latency-only run reported bulk measurements")
	}
	if state.TransferredBytes != fixture.latencies.Load()*4 || state.ViaVPN {
		t.Fatalf("latency accounting = %+v", state)
	}
}

func TestSpeedTestKeepsUploadWhenDownloadFails(t *testing.T) {
	fixture := &speedTestFixture{downCode: http.StatusForbidden}
	run := speedTestLocalRun(t, "complete", fixture)
	run.run()
	state := run.snapshot()
	if state.Phase != "done" || state.DownloadMbps != nil || state.UploadMbps == nil || *state.UploadMbps <= 0 || !slices.Contains(state.Errors, "download") {
		t.Fatalf("partial result = %+v", state)
	}
	if fixture.uploads.Load() == 0 || state.TransferredBytes > state.ByteLimit {
		t.Fatalf("upload=%d transferred=%d limit=%d", fixture.uploads.Load(), state.TransferredBytes, state.ByteLimit)
	}
}

func TestSpeedTestUnacknowledgedUploadsAreNotMeasurements(t *testing.T) {
	fixture := &speedTestFixture{upCode: http.StatusServiceUnavailable}
	run := speedTestLocalRun(t, "complete", fixture)
	run.run()
	state := run.snapshot()
	if state.Phase != "done" || state.DownloadMbps == nil || state.UploadMbps != nil || !slices.Contains(state.Errors, "upload") {
		t.Fatalf("unacknowledged upload = %+v", state)
	}
	if fixture.uploads.Load() == 0 {
		t.Fatal("test did not send any upload payload")
	}
	for _, sample := range state.UploadSamples {
		if sample.Mbps != 0 {
			t.Fatalf("unacknowledged upload was graphed: %+v", sample)
		}
	}
}

func TestSpeedTestBudgetExhaustionRetainsLimitedRates(t *testing.T) {
	fixture := &speedTestFixture{}
	run := speedTestLocalRun(t, "complete", fixture)
	run.run()
	state := run.snapshot()
	if state.Phase != "done" || !state.Limited || state.DownloadMbps == nil || state.UploadMbps == nil {
		t.Fatalf("limited result = %+v", state)
	}
	if state.TransferredBytes > state.ByteLimit || state.TransferredBytes < fixture.uploads.Load() {
		t.Fatalf("accounted=%d uploaded=%d limit=%d", state.TransferredBytes, fixture.uploads.Load(), state.ByteLimit)
	}
	if run.budget.used[speedTestDownload] == 0 || run.budget.used[speedTestUpload] == 0 {
		t.Fatal("download exhausted the upload reservation")
	}
}

func TestSpeedTestMeasuresLoadedLatencyAndRPM(t *testing.T) {
	fixture := &speedTestFixture{downWait: 20 * time.Millisecond, upWait: 350 * time.Millisecond}
	run := speedTestLocalRun(t, "complete", fixture)
	run.duration = 650 * time.Millisecond
	run.run()
	state := run.snapshot()
	if state.DownloadLatency == nil || state.UploadLatency == nil || state.RPM == nil || *state.RPM <= 0 {
		t.Fatalf("loaded latency result = %+v", state)
	}
	if state.DownloadMbps == nil || state.UploadMbps == nil {
		t.Fatalf("loaded run lost usable rates: %+v", state)
	}
}

func TestSpeedTestCancelInterruptsStalledUploadResponse(t *testing.T) {
	entered := make(chan struct{})
	var once sync.Once
	fixture := &speedTestFixture{onPost: func(ctx context.Context, post int64) {
		if post > 1 {
			once.Do(func() { close(entered) })
			<-ctx.Done()
		}
	}}
	run := speedTestLocalRun(t, "complete", fixture)
	run.duration = 10 * time.Second
	safeGo("testSpeedTestCancel", run.run)
	awaitSpeedTest(t, entered)
	start := time.Now()
	run.cancel()
	awaitSpeedTest(t, run.done)
	if time.Since(start) > time.Second {
		t.Fatal("cancelling stalled I/O was not prompt")
	}
	state := run.snapshot()
	if state.Phase != "cancelled" || state.UploadMbps != nil {
		t.Fatalf("cancelled result = %+v", state)
	}
	run.transport.mu.Lock()
	remaining := len(run.transport.clients) + len(run.transport.conns) + len(run.transport.packets)
	run.transport.mu.Unlock()
	if remaining != 0 {
		t.Fatalf("cancel left %d transport resources", remaining)
	}
}

func TestSpeedTestRunPanicAndDeadlineProduceTerminalResults(t *testing.T) {
	for _, deadline := range []bool{false, true} {
		params := speedTestTestParams(t, "latencyOnly")
		run := newSpeedTestRun(params)
		if deadline {
			run.cancel()
			run.ctx, run.cancel = context.WithTimeout(context.Background(), 10*time.Millisecond)
		}
		run.prepare = func(ctx context.Context, _ *speedTestRun) (*speedTestTarget, error) {
			if deadline {
				<-ctx.Done()
				return nil, ctx.Err()
			}
			panic("test panic")
		}
		run.run()
		state := run.snapshot()
		want := "internal_error"
		if deadline {
			want = "timeout"
		}
		if state.Phase != "failed" || state.Failure != want {
			t.Fatalf("terminal result = %+v, want %s", state, want)
		}
		awaitSpeedTest(t, run.done)
	}
}

func TestSpeedTestLatestRunAndOldCancellationAreIsolated(t *testing.T) {
	fixture := &speedTestFixture{}
	server := httptest.NewServer(http.HandlerFunc(fixture.serve))
	defer server.Close()
	started := make(chan struct{})
	runs := map[string]*speedTestRun{}
	manager := &speedTestManager{newRun: func(params SpeedTestParams) *speedTestRun {
		run := newSpeedTestRun(params)
		runs[params.RequestID] = run
		run.prepare = func(ctx context.Context, _ *speedTestRun) (*speedTestTarget, error) {
			if params.RequestID == "old" {
				close(started)
				<-ctx.Done()
				return nil, ctx.Err()
			}
			return speedTestLocalTarget(server), nil
		}
		return run
	}}
	defer manager.stop()
	params := speedTestTestParams(t, "latencyOnly")
	params.RequestID = "old"
	if ok, err := manager.start(params); !ok || err != nil {
		t.Fatalf("old start = %v, %v", ok, err)
	}
	awaitSpeedTest(t, started)
	params.RequestID = "new"
	if ok, err := manager.start(params); !ok || err != nil {
		t.Fatalf("new start = %v, %v", ok, err)
	}
	manager.cancel("old")
	awaitSpeedTest(t, runs["new"].done)
	awaitSpeedTestManager(t, manager)
	if _, err := manager.get("old"); err == nil {
		t.Fatal("old request read the new result")
	}
	state, err := manager.get("new")
	if err != nil || state.Phase != "done" || runs["old"].snapshot().Phase != "cancelled" {
		t.Fatalf("latest result = %+v, %v", state, err)
	}
	if ok, err := manager.start(params); !ok || err != nil || manager.latest != runs["new"] {
		t.Fatal("duplicate start replaced a stable result")
	}
}

func TestSpeedTestCancelBeforeStartAndPendingStartsAreBounded(t *testing.T) {
	manager := &speedTestManager{}
	params := speedTestTestParams(t, "latencyOnly")
	manager.cancel(params.RequestID)
	if ok, err := manager.start(params); ok || err != nil || manager.latest != nil {
		t.Fatalf("cancel-before-start = %v, %v", ok, err)
	}
	for index := range speedTestMaxTombstones * 2 {
		manager.cancel(strconv.Itoa(index))
	}
	if len(manager.cancelled) != speedTestMaxTombstones {
		t.Fatalf("tombstone count = %d", len(manager.cancelled))
	}
	entered, release := make(chan struct{}), make(chan struct{})
	var starts atomic.Int32
	manager.newRun = func(params SpeedTestParams) *speedTestRun {
		run := newSpeedTestRun(params)
		run.prepare = func(ctx context.Context, _ *speedTestRun) (*speedTestTarget, error) {
			if starts.Add(1) == 1 {
				close(entered)
				<-release
			}
			return nil, errors.New("local test")
		}
		return run
	}
	params.RequestID = "active"
	if _, err := manager.start(params); err != nil {
		t.Fatal(err)
	}
	awaitSpeedTest(t, entered)
	for index := range 50 {
		params.RequestID = "pending-" + strconv.Itoa(index)
		if _, err := manager.start(params); err != nil {
			t.Fatal(err)
		}
	}
	if starts.Load() != 1 {
		t.Fatalf("started %d concurrent jobs", starts.Load())
	}
	close(release)
	awaitSpeedTest(t, manager.latest.done)
	awaitSpeedTestManager(t, manager)
	if starts.Load() != 2 {
		t.Fatalf("ran %d jobs instead of active and newest", starts.Load())
	}
	manager.stop()
}

func TestSpeedTestSnapshotsAreIndependentAndTerminalResultsStayStable(t *testing.T) {
	run := newSpeedTestRun(speedTestTestParams(t, "complete"))
	defer run.cancel()
	value, rpm := 10.0, 60
	run.update(func(state *SpeedTestSnapshot) {
		state.DownloadMbps, state.UploadMbps = &value, &value
		state.Latency = &SpeedTestLatencySummary{MedianMs: 10, JitterMs: &value, Count: 20}
		state.DownloadLatency, state.UploadLatency = cloneSpeedTestLatency(state.Latency), cloneSpeedTestLatency(state.Latency)
		state.Server = &SpeedTestServer{Name: "server", LatencyMs: &value}
		state.RPM = &rpm
		state.Chains = []string{"node"}
		state.Errors = []string{"warmup"}
		state.Hits = []RouteHit{{Host: "host", Exit: "node"}}
		state.DownloadSamples = []SpeedTestSample{{ElapsedMs: 100, Mbps: 10}}
		state.UploadSamples = slices.Clone(state.DownloadSamples)
	})
	run.complete(nil)
	before, _ := json.Marshal(run.snapshot())
	copy := run.snapshot()
	*copy.DownloadMbps, *copy.UploadMbps, *copy.Latency.JitterMs = 999, 999, 999
	*copy.DownloadLatency.JitterMs, *copy.UploadLatency.JitterMs, *copy.Server.LatencyMs = 999, 999, 999
	*copy.RPM = 999
	copy.Server.Name, copy.Chains[0], copy.Errors[0], copy.Hits[0].Host = "changed", "changed", "changed", "changed"
	copy.DownloadSamples[0].Mbps, copy.UploadSamples[0].Mbps = 999, 999
	run.cancel()
	after, _ := json.Marshal(run.snapshot())
	if string(before) != string(after) {
		t.Fatalf("snapshot was mutable:\n%s\n%s", before, after)
	}
}
