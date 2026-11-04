package core

import (
	"context"
	"errors"
	"io"
	"math"
	"net/url"
	"slices"
	"strconv"
	"strings"
	"sync"
	"sync/atomic"
	"time"

	"github.com/metacubex/http"
	"github.com/metacubex/http/httptrace"
)

const (
	speedTestSampleInterval = 100 * time.Millisecond
	speedTestPushInterval   = 200 * time.Millisecond
	speedTestLoadedInterval = 400 * time.Millisecond
	speedTestMaxPayload     = 25_000_000
	speedTestSmallResponse  = 4096
	speedTestLibreChunk     = 1024 * 1024
)

var speedTestRequestSerial atomic.Uint64

func speedTestUniqueURL(endpoint string, fields map[string]string) string {
	u, err := url.Parse(endpoint)
	if err != nil {
		return endpoint
	}
	query := u.Query()
	for key, value := range fields {
		query.Set(key, value)
	}
	query.Set("r", strconv.FormatInt(time.Now().UnixNano(), 10)+"-"+strconv.FormatUint(speedTestRequestSerial.Add(1), 10))
	u.RawQuery = query.Encode()
	return u.String()
}

func speedTestPing(ctx context.Context, client *speedTestClient, target *speedTestTarget, budget *speedTestBudget) (float64, *http.Response, error) {
	ctx, cancel := context.WithTimeout(ctx, speedTestLatencyTimeout)
	defer cancel()
	method := target.latencyMethod
	if method == "" {
		method = http.MethodGet
	}
	var reservation *speedTestReservation
	limit := int64(speedTestSmallResponse)
	if budget != nil && method != http.MethodHead {
		reservation = budget.reserve(speedTestProbe, limit, 1)
		if reservation == nil {
			return 0, nil, errSpeedTestBudget
		}
		defer reservation.release()
		limit = reservation.amount
	}
	var mu sync.Mutex
	var wrote, first time.Time
	trace := &httptrace.ClientTrace{
		WroteRequest: func(httptrace.WroteRequestInfo) {
			mu.Lock()
			wrote = time.Now()
			mu.Unlock()
		},
		GotFirstResponseByte: func() {
			mu.Lock()
			first = time.Now()
			mu.Unlock()
		},
	}
	endpoint := target.latencyURL
	if target.backend == "librespeed" {
		endpoint = speedTestUniqueURL(endpoint, nil)
	}
	req, err := newSpeedTestRequest(httptrace.WithClientTrace(ctx, trace), method, endpoint, nil)
	if err != nil {
		return 0, nil, err
	}
	if target.backend == "apple" && method == http.MethodGet {
		req.Header.Set("Range", "bytes=0-0")
	}
	start := time.Now()
	response, err := client.Do(req)
	if err != nil {
		return 0, nil, err
	}
	headers := time.Now()
	defer response.Body.Close()
	if err := checkSpeedTestResponse(response); err != nil {
		return 0, response, err
	}
	if method != http.MethodHead {
		if response.ContentLength > limit {
			return 0, response, errors.New("oversized speed test latency response")
		}
		var count int64
		if reservation == nil {
			body, readErr := readSpeedTestResponse(response.Body, limit)
			count, err = int64(len(body)), readErr
		} else {
			count, err = io.Copy(io.Discard, io.LimitReader(response.Body, limit))
			if consumeErr := reservation.consume(count); consumeErr != nil {
				return 0, response, consumeErr
			}
		}
		if err != nil {
			return 0, response, err
		}
	}
	mu.Lock()
	if wrote.IsZero() {
		wrote = start
	}
	if first.IsZero() {
		first = headers
	}
	rtt := float64(first.Sub(wrote)) / float64(time.Millisecond)
	mu.Unlock()
	if rtt <= 0 {
		rtt = float64(headers.Sub(start)) / float64(time.Millisecond)
	}
	if server := speedTestServerTiming(response.Header.Get("Server-Timing")); server < rtt {
		rtt -= server
	}
	return math.Max(rtt, .001), response, nil
}

func speedTestServerTiming(header string) float64 {
	for metric := range strings.SplitSeq(header, ",") {
		for part := range strings.SplitSeq(metric, ";") {
			key, value, ok := strings.Cut(strings.TrimSpace(part), "=")
			if ok && key == "dur" {
				if duration, err := strconv.ParseFloat(strings.Trim(value, "\""), 64); err == nil && duration >= 0 && !math.IsNaN(duration) && !math.IsInf(duration, 0) {
					return duration
				}
			}
		}
	}
	return 0
}

func (r *speedTestRun) latencyOnce(ctx context.Context, client *speedTestClient, target *speedTestTarget) (float64, *http.Response, error) {
	rtt, response, err := speedTestPing(ctx, client, target, r.budget)
	if errors.Is(err, errSpeedTestBudget) {
		r.limited()
	}
	if err == nil && r.latency != nil {
		r.observeProtocol(response)
	}
	return rtt, response, err
}

func (r *speedTestRun) observeProtocol(response *http.Response) {
	protocol := "h" + strconv.Itoa(response.ProtoMajor)
	r.update(func(state *SpeedTestSnapshot) {
		if response.ProtoMajor >= 1 && response.ProtoMajor <= 3 && protocol < state.Protocol {
			state.Protocol = protocol
		}
		state.ProtocolFallback = state.Protocol != r.params.Protocol
	})
}

func (r *speedTestRun) warmup(target *speedTestTarget) {
	for i := range 2 {
		_, _, _ = r.latencyOnce(r.ctx, r.latency, target)
		r.update(func(state *SpeedTestSnapshot) { state.Progress = .05 + float64(i+1)*.025 })
		if r.ctx.Err() != nil {
			return
		}
	}
	if r.params.Mode == "latencyOnly" {
		return
	}
	for _, upload := range []bool{false, true} {
		direction, unit := speedTestDownload, int64(1)
		if upload {
			direction = speedTestUpload
		} else if target.backend == "librespeed" {
			unit = speedTestLibreChunk
		}
		reservation := r.budget.reserve(direction, max(64*1024, unit), unit)
		if reservation == nil {
			r.limited()
			continue
		}
		_, err := r.transfer(r.ctx, r.load[0], target, reservation, upload, nil, time.Time{})
		if err != nil && r.ctx.Err() == nil {
			r.stageError("warmup")
		}
	}
}

func (r *speedTestRun) measureIdleLatency(target *speedTestTarget) []float64 {
	values := make([]float64, 0, speedTestLatencyCount)
	for index := range speedTestLatencyCount {
		if r.ctx.Err() != nil {
			break
		}
		if rtt, _, err := r.latencyOnce(r.ctx, r.latency, target); err == nil {
			values = append(values, rtt)
		}
		r.update(func(state *SpeedTestSnapshot) {
			state.Latency = speedTestLatencyStats(values)
			state.Progress = .1 + .2*float64(index+1)/speedTestLatencyCount
		})
	}
	return values
}

type speedTestDownloadWriter struct {
	reservation *speedTestReservation
	meter       *speedTestMeter
	start       time.Time
}

func (w speedTestDownloadWriter) Write(data []byte) (int, error) {
	if err := w.reservation.consume(int64(len(data))); err != nil {
		return 0, err
	}
	if w.meter != nil {
		w.meter.add(time.Since(w.start), int64(len(data)))
	}
	return len(data), nil
}

func (r *speedTestRun) transfer(ctx context.Context, client *speedTestClient, target *speedTestTarget, reservation *speedTestReservation, upload bool, meter *speedTestMeter, start time.Time) (int64, error) {
	defer reservation.release()
	ctx, cancel := context.WithTimeout(ctx, speedTestRequestTimeout)
	defer cancel()
	if upload {
		return r.upload(ctx, client, target, reservation, meter, start)
	}
	endpoint := target.downloadURL
	switch target.backend {
	case "cloudflare":
		endpoint = speedTestUniqueURL(endpoint, map[string]string{"bytes": strconv.FormatInt(reservation.amount, 10)})
	case "speedtest":
		endpoint = speedTestUniqueURL(endpoint, map[string]string{"size": strconv.FormatInt(reservation.amount, 10)})
	case "librespeed":
		endpoint = speedTestUniqueURL(endpoint, map[string]string{"ckSize": strconv.FormatInt(reservation.amount/speedTestLibreChunk, 10)})
	}
	req, err := newSpeedTestRequest(ctx, http.MethodGet, endpoint, nil)
	if err != nil {
		return 0, err
	}
	if target.backend == "apple" {
		req.Header.Set("Range", "bytes=0-"+strconv.FormatInt(reservation.amount-1, 10))
	}
	response, err := client.Do(req)
	if err != nil {
		return 0, err
	}
	defer response.Body.Close()
	if err := checkSpeedTestResponse(response); err != nil {
		return 0, err
	}
	r.observeProtocol(response)
	if strings.HasPrefix(strings.ToLower(response.Header.Get("Content-Type")), "text/") || response.ContentLength > reservation.amount {
		return 0, errors.New("unexpected speed test download payload")
	}
	buffer := make([]byte, 64*1024)
	count, err := io.CopyBuffer(speedTestDownloadWriter{reservation: reservation, meter: meter, start: start}, io.LimitReader(response.Body, reservation.amount), buffer)
	if err == nil && count != reservation.amount {
		err = io.ErrUnexpectedEOF
	}
	return count, err
}

func (r *speedTestRun) upload(ctx context.Context, client *speedTestClient, target *speedTestTarget, reservation *speedTestReservation, meter *speedTestMeter, start time.Time) (int64, error) {
	payload, err := speedTestUploadPayload()
	if err != nil {
		return 0, err
	}
	body := &speedTestUploadBody{payload: payload, reservation: reservation}
	defer body.Close()
	endpoint := target.uploadURL
	if target.backend == "librespeed" {
		endpoint = speedTestUniqueURL(endpoint, nil)
	}
	req, err := newSpeedTestRequest(ctx, http.MethodPost, endpoint, body)
	if err != nil {
		return 0, err
	}
	req.ContentLength = reservation.amount
	req.Header.Set("Content-Type", "application/octet-stream")
	began := time.Since(start)
	response, err := client.Do(req)
	if err != nil {
		return body.sentBytes(), err
	}
	defer response.Body.Close()
	if err := checkSpeedTestResponse(response); err != nil {
		return body.sentBytes(), err
	}
	r.observeProtocol(response)
	if _, err := readSpeedTestResponse(response.Body, speedTestSmallResponse); err != nil {
		return body.sentBytes(), err
	}
	_ = body.Close()
	if body.sentBytes() != reservation.amount {
		return body.sentBytes(), io.ErrUnexpectedEOF
	}
	if ctx.Err() != nil {
		return body.sentBytes(), ctx.Err()
	}
	if meter != nil {
		meter.confirm(began, time.Since(start), reservation.amount)
	}
	return reservation.amount, nil
}

func (r *speedTestRun) transferLoop(ctx context.Context, client *speedTestClient, target *speedTestTarget, upload bool, meter *speedTestMeter, start time.Time) error {
	direction, unit, block := speedTestDownload, int64(1), int64(1024*1024)
	if upload {
		direction, block = speedTestUpload, 64*1024
	} else if target.backend == "librespeed" {
		unit = speedTestLibreChunk
	}
	failures := 0
	for ctx.Err() == nil {
		reservation := r.budget.reserve(direction, max(block, unit), unit)
		if reservation == nil {
			return errSpeedTestBudget
		}
		began := time.Now()
		count, err := r.transfer(ctx, client, target, reservation, upload, meter, start)
		if err != nil {
			if ctx.Err() != nil {
				return ctx.Err()
			}
			failures++
			if failures >= 3 {
				return err
			}
			timer := time.NewTimer(speedTestPushInterval)
			select {
			case <-ctx.Done():
				timer.Stop()
				return ctx.Err()
			case <-timer.C:
			}
			continue
		}
		failures = 0
		seconds := time.Since(began).Seconds()
		if seconds > 0 {
			span := 1.0
			if upload {
				span = .5
			}
			block = int64(math.Min(speedTestMaxPayload, math.Max(64*1024, float64(count)*span/seconds)))
		}
	}
	return ctx.Err()
}

func (r *speedTestRun) measureLoad(target *speedTestTarget, upload bool) []float64 {
	ctx, cancel := context.WithTimeout(r.ctx, r.duration)
	start := time.Now()
	meter := newSpeedTestMeter(r.duration)
	results := make(chan error, r.params.Streams)
	loadedDone := make(chan struct{})
	loaded := make([]float64, 0, int(r.duration/speedTestLoadedInterval)+1)
	remaining, failed := 0, false
	joined := false
	join := func() {
		if joined {
			return
		}
		joined = true
		cancel()
		for remaining > 0 {
			err := <-results
			remaining--
			if err != nil && !errors.Is(err, errSpeedTestBudget) && !errors.Is(err, context.Canceled) && !errors.Is(err, context.DeadlineExceeded) {
				failed = true
			}
		}
		<-loadedDone
	}
	defer join()
	safeGo("speedTestLoadedLatency", func() {
		defer close(loadedDone)
		ticker := time.NewTicker(speedTestLoadedInterval)
		defer ticker.Stop()
		for {
			select {
			case <-ctx.Done():
				return
			case <-ticker.C:
				if rtt, _, err := r.latencyOnce(ctx, r.probe, target); err == nil {
					loaded = append(loaded, rtt)
				}
			}
		}
	})
	for _, client := range r.load {
		remaining++
		safeGo("speedTestTransfer", func() {
			var result error
			defer func() {
				if recover() != nil {
					result = errSpeedTestPanic
				}
				results <- result
			}()
			result = r.transferLoop(ctx, client, target, upload, meter, start)
		})
	}
	ticker := time.NewTicker(speedTestPushInterval)
	defer ticker.Stop()
	sampling := true
	for sampling && remaining > 0 {
		select {
		case <-ctx.Done():
			sampling = false
		case err := <-results:
			remaining--
			if err != nil && !errors.Is(err, errSpeedTestBudget) && !errors.Is(err, context.Canceled) && !errors.Is(err, context.DeadlineExceeded) {
				failed = true
			}
		case <-ticker.C:
			r.publishLoad(meter.samples(time.Since(start)), upload, time.Since(start))
		}
	}
	elapsed := min(time.Since(start), r.duration)
	meter.freeze()
	join()
	direction, stage, unit := speedTestDownload, "download", int64(1)
	if upload {
		direction, stage = speedTestUpload, "upload"
	} else if target.backend == "librespeed" {
		unit = speedTestLibreChunk
	}
	if r.budget.available(direction) < unit && elapsed < r.duration {
		r.limited()
	}
	samples := meter.samples(elapsed)
	r.publishLoad(samples, upload, elapsed)
	rate := speedTestStableSpeed(samples)
	if failed || rate <= 0 {
		r.stageError(stage)
	}
	r.update(func(state *SpeedTestSnapshot) {
		latency := speedTestLatencyStats(loaded)
		if upload {
			state.UploadLatency = latency
			if rate > 0 {
				state.UploadMbps = &rate
			}
		} else {
			state.DownloadLatency = latency
			if rate > 0 {
				state.DownloadMbps = &rate
			}
		}
	})
	return loaded
}

func (r *speedTestRun) publishLoad(samples []speedTestByteSample, upload bool, elapsed time.Duration) {
	direction, base := speedTestDownload, .3
	if upload {
		direction, base = speedTestUpload, .65
	}
	progress := math.Min(1, math.Max(float64(elapsed)/float64(r.duration), r.budget.fraction(direction)))
	rate := speedTestWindowSpeed(samples, time.Second)
	curve := make([]SpeedTestSample, 0, min(len(samples)/2+1, speedTestMaxSamples))
	for index := 1; index < len(samples); index++ {
		if index%2 != 0 && index != len(samples)-1 {
			continue
		}
		curve = append(curve, SpeedTestSample{ElapsedMs: samples[index].at.Milliseconds(), Mbps: speedTestWindowSpeed(samples[:index+1], time.Second)})
	}
	if len(curve) > speedTestMaxSamples {
		curve = curve[len(curve)-speedTestMaxSamples:]
	}
	r.update(func(state *SpeedTestSnapshot) {
		state.LiveMbps, state.Progress = &rate, base+.35*progress
		if upload {
			state.UploadSamples = curve
		} else {
			state.DownloadSamples = curve
		}
	})
}

type speedTestByteSample struct {
	at    time.Duration
	bytes int64
}

type speedTestMeter struct {
	mu       sync.Mutex
	bins     []int64
	duration time.Duration
	frozen   bool
}

func newSpeedTestMeter(duration time.Duration) *speedTestMeter {
	duration = min(max(duration, time.Nanosecond), 30*time.Second)
	return &speedTestMeter{duration: duration, bins: make([]int64, int(duration/speedTestSampleInterval)+1)}
}

func (m *speedTestMeter) add(at time.Duration, bytes int64) {
	m.mu.Lock()
	defer m.mu.Unlock()
	if !m.frozen && at >= 0 && at <= m.duration && bytes > 0 {
		m.bins[int(at/speedTestSampleInterval)] += bytes
	}
}

// Acknowledged uploads are spread across their request, not credited as an ACK-time burst.
func (m *speedTestMeter) confirm(start, end time.Duration, bytes int64) {
	m.mu.Lock()
	defer m.mu.Unlock()
	if m.frozen || start < 0 || end > m.duration || end < start || bytes <= 0 {
		return
	}
	if end == start {
		m.bins[int(end/speedTestSampleInterval)] += bytes
		return
	}
	remaining := bytes
	for index := int(start / speedTestSampleInterval); time.Duration(index)*speedTestSampleInterval < end; index++ {
		left := max(start, time.Duration(index)*speedTestSampleInterval)
		right := min(end, time.Duration(index+1)*speedTestSampleInterval)
		share := remaining
		if right != end {
			share = min(remaining, int64(float64(bytes)*float64(right-left)/float64(end-start)))
		}
		m.bins[index] += share
		remaining -= share
	}
}

func (m *speedTestMeter) freeze() {
	m.mu.Lock()
	m.frozen = true
	m.mu.Unlock()
}

func (m *speedTestMeter) samples(elapsed time.Duration) []speedTestByteSample {
	m.mu.Lock()
	defer m.mu.Unlock()
	elapsed = min(max(elapsed, time.Nanosecond), m.duration)
	samples := make([]speedTestByteSample, 1, int(elapsed/speedTestSampleInterval)+2)
	var total int64
	for index, bin := range m.bins {
		left := time.Duration(index) * speedTestSampleInterval
		if left > elapsed {
			break
		}
		total += bin
		at := min(left+speedTestSampleInterval, elapsed)
		if at == samples[len(samples)-1].at {
			samples[len(samples)-1].bytes = total
		} else {
			samples = append(samples, speedTestByteSample{at: at, bytes: total})
		}
	}
	return samples
}

func speedTestWindowSpeed(samples []speedTestByteSample, window time.Duration) float64 {
	if len(samples) < 2 {
		return 0
	}
	last, first := samples[len(samples)-1], samples[0]
	for index := len(samples) - 2; index >= 0; index-- {
		first = samples[index]
		if last.at-first.at >= window {
			break
		}
	}
	if last.at <= first.at {
		return 0
	}
	return math.Max(0, float64(last.bytes-first.bytes)*8/(last.at-first.at).Seconds()/1e6)
}

func speedTestStableSpeed(samples []speedTestByteSample) float64 {
	if len(samples) < 2 {
		return 0
	}
	last, first := samples[len(samples)-1], samples[0]
	cut := time.Duration(float64(last.at) * .3)
	for _, sample := range samples {
		if sample.at >= cut && sample.at < last.at {
			first = sample
			break
		}
	}
	return speedTestWindowSpeed([]speedTestByteSample{first, last}, last.at)
}

func speedTestMedian(values []float64) float64 {
	if len(values) == 0 {
		return 0
	}
	ordered := slices.Clone(values)
	slices.Sort(ordered)
	middle := len(ordered) / 2
	if len(ordered)%2 == 0 {
		return (ordered[middle-1] + ordered[middle]) / 2
	}
	return ordered[middle]
}

func speedTestLatencyStats(values []float64) *SpeedTestLatencySummary {
	valid := make([]float64, 0, len(values))
	for _, value := range values {
		if value >= 0 && !math.IsNaN(value) && !math.IsInf(value, 0) {
			valid = append(valid, value)
		}
	}
	if len(valid) == 0 {
		return nil
	}
	result := &SpeedTestLatencySummary{MedianMs: speedTestMedian(valid), Count: len(valid)}
	if len(valid) > 1 {
		var jitter float64
		for index := 1; index < len(valid); index++ {
			jitter += math.Abs(valid[index] - valid[index-1])
		}
		jitter /= float64(len(valid) - 1)
		result.JitterMs = &jitter
	}
	return result
}

func speedTestRPM(loaded []float64) *int {
	latency := speedTestLatencyStats(loaded)
	if latency == nil || latency.MedianMs <= 0 {
		return nil
	}
	rpm := int(math.Min(math.MaxInt32, 60000/latency.MedianMs))
	return &rpm
}
