package core

import (
	"context"
	"errors"
	"fmt"
	"slices"
	"strings"
	"sync"
	"time"

	"github.com/metacubex/mihomo/constant"
)

const (
	speedTestDeadline       = 150 * time.Second
	speedTestDiscoveryLimit = 15 * time.Second
	speedTestRequestTimeout = 8 * time.Second
	speedTestLatencyTimeout = 3 * time.Second
	speedTestLatencyCount   = 20
	speedTestMaxStreams     = 16
	speedTestMaxSamples     = 160
	speedTestMaxServers     = 30
	speedTestMaxResponse    = 512 * 1024
	speedTestMaxHits        = 64
	speedTestMaxTombstones  = 128
	speedTestDefaultBytes   = 100 * 1024 * 1024
	speedTestMaxBytes       = 1024 * 1024 * 1024
)

var (
	errSpeedTestBudget      = errors.New("speed test data limit reached")
	errSpeedTestUnavailable = errors.New("speed test unavailable")
	errSpeedTestRejected    = errors.New("speed test proxy rejected")
	errSpeedTestPanic       = errors.New("speed test worker failed")
	currentSpeedTests       speedTestManager
)

type SpeedTestParams struct {
	RequestID       string           `json:"requestId"`
	BackendID       string           `json:"backendId"`
	DurationSeconds int              `json:"durationSeconds"`
	Streams         int              `json:"streams"`
	Protocol        string           `json:"protocol"`
	Mode            string           `json:"mode"`
	ByteLimit       int64            `json:"byteLimit"`
	ProxyName       string           `json:"proxyName"`
	Direct          bool             `json:"direct"`
	UseSystemDNS    bool             `json:"useSystemDns"`
	Server          *SpeedTestServer `json:"server,omitempty"`
}

type SpeedTestRequest struct {
	RequestID string `json:"requestId"`
}

type SpeedTestServersParams struct {
	RequestID    string `json:"requestId"`
	ProxyName    string `json:"proxyName"`
	Direct       bool   `json:"direct"`
	UseSystemDNS bool   `json:"useSystemDns"`
	Search       string `json:"search"`
}

type SpeedTestServer struct {
	ID        string   `json:"id"`
	Name      string   `json:"name"`
	Host      string   `json:"host"`
	Country   string   `json:"country"`
	Sponsor   string   `json:"sponsor"`
	LatencyMs *float64 `json:"latencyMs"`
}

type SpeedTestLatencySummary struct {
	MedianMs float64  `json:"medianMs"`
	JitterMs *float64 `json:"jitterMs"`
	Count    int      `json:"count"`
}

type SpeedTestSample struct {
	ElapsedMs int64   `json:"elapsedMs"`
	Mbps      float64 `json:"mbps"`
}

type SpeedTestSnapshot struct {
	RequestID        string                   `json:"requestId"`
	BackendID        string                   `json:"backendId"`
	Phase            string                   `json:"phase"`
	Stage            string                   `json:"stage"`
	DownloadMbps     *float64                 `json:"downloadMbps"`
	UploadMbps       *float64                 `json:"uploadMbps"`
	LiveMbps         *float64                 `json:"liveMbps"`
	Latency          *SpeedTestLatencySummary `json:"latency"`
	DownloadLatency  *SpeedTestLatencySummary `json:"downloadLatency"`
	UploadLatency    *SpeedTestLatencySummary `json:"uploadLatency"`
	RPM              *int                     `json:"rpm"`
	TransferredBytes int64                    `json:"transferredBytes"`
	ByteLimit        int64                    `json:"byteLimit"`
	ElapsedMs        int64                    `json:"elapsedMs"`
	Progress         float64                  `json:"progress"`
	ViaVPN           bool                     `json:"viaVpn"`
	ProxyName        string                   `json:"proxyName"`
	Chains           []string                 `json:"chains"`
	Server           *SpeedTestServer         `json:"server"`
	Protocol         string                   `json:"protocol"`
	ProtocolFallback bool                     `json:"protocolFallback"`
	Limited          bool                     `json:"limited"`
	Errors           []string                 `json:"errors"`
	Failure          string                   `json:"failure,omitempty"`
	DownloadSamples  []SpeedTestSample        `json:"downloadSamples"`
	UploadSamples    []SpeedTestSample        `json:"uploadSamples"`
	CoreEpoch        uint64                   `json:"coreEpoch"`
	RouteVersion     uint64                   `json:"routeVersion"`
	Hits             []RouteHit               `json:"hits"`
}

func speedTestCopy[T any](value *T) *T {
	if value == nil {
		return nil
	}
	copy := *value
	return &copy
}

func cloneSpeedTestServer(server *SpeedTestServer) *SpeedTestServer {
	copy := speedTestCopy(server)
	if copy != nil {
		copy.LatencyMs = speedTestCopy(copy.LatencyMs)
	}
	return copy
}

func cloneSpeedTestLatency(summary *SpeedTestLatencySummary) *SpeedTestLatencySummary {
	copy := speedTestCopy(summary)
	if copy != nil {
		copy.JitterMs = speedTestCopy(copy.JitterMs)
	}
	return copy
}

func (s SpeedTestSnapshot) clone() *SpeedTestSnapshot {
	s.DownloadMbps = speedTestCopy(s.DownloadMbps)
	s.UploadMbps = speedTestCopy(s.UploadMbps)
	s.LiveMbps = speedTestCopy(s.LiveMbps)
	s.Latency = cloneSpeedTestLatency(s.Latency)
	s.DownloadLatency = cloneSpeedTestLatency(s.DownloadLatency)
	s.UploadLatency = cloneSpeedTestLatency(s.UploadLatency)
	s.RPM = speedTestCopy(s.RPM)
	s.Server = cloneSpeedTestServer(s.Server)
	s.Chains = slices.Clone(s.Chains)
	s.Errors = slices.Clone(s.Errors)
	s.Hits = slices.Clone(s.Hits)
	s.DownloadSamples = slices.Clone(s.DownloadSamples)
	s.UploadSamples = slices.Clone(s.UploadSamples)
	return &s
}

func validSpeedTestID(id string) bool {
	return strings.TrimSpace(id) != "" && len(id) <= 128
}

func normalizeSpeedTestParams(params SpeedTestParams) (SpeedTestParams, error) {
	if !validSpeedTestID(params.RequestID) || len(params.ProxyName) > 1024 {
		return params, errors.New("invalid speed test request")
	}
	if params.BackendID == "" {
		params.BackendID = "cloudflare"
	}
	switch params.BackendID {
	case "cloudflare", "apple", "speedtest", "librespeed":
	default:
		return params, errors.New("unknown speed test backend")
	}
	if params.Protocol == "" {
		params.Protocol = "h2"
	}
	if params.Protocol != "h1" && params.Protocol != "h2" && params.Protocol != "h3" {
		return params, errors.New("invalid speed test protocol")
	}
	if params.Mode == "" {
		params.Mode = "complete"
	}
	if params.Mode != "complete" && params.Mode != "latencyOnly" {
		return params, errors.New("invalid speed test mode")
	}
	if params.DurationSeconds <= 0 {
		params.DurationSeconds = 10
	}
	params.DurationSeconds = min(params.DurationSeconds, 30)
	if params.Streams <= 0 {
		params.Streams = 8
	}
	params.Streams = min(params.Streams, speedTestMaxStreams)
	if params.ByteLimit <= 0 {
		params.ByteLimit = speedTestDefaultBytes
	}
	params.ByteLimit = min(params.ByteLimit, speedTestMaxBytes)
	params.UseSystemDNS = params.Direct && params.UseSystemDNS
	params.Server = cloneSpeedTestServer(params.Server)
	if params.Server != nil {
		if err := validateSpeedTestServer(*params.Server); err != nil {
			return params, err
		}
	}
	return params, validateSpeedTestProxy(params.ProxyName)
}

func validateSpeedTestProxy(name string) error {
	if name == "" {
		return nil
	}
	proxy := lookupProxy(name)
	if proxy == nil {
		return fmt.Errorf("proxy %q is not part of the applied config", name)
	}
	if proxy.Type() == constant.Reject || proxy.Type() == constant.RejectDrop {
		return errSpeedTestRejected
	}
	return nil
}

type speedTestTombstone struct {
	id string
	at time.Time
}

type speedTestDiscovery struct {
	id     string
	ctx    context.Context
	cancel context.CancelFunc
}

type speedTestManager struct {
	mu        sync.Mutex
	latest    *speedTestRun
	pending   *speedTestRun
	running   *speedTestRun
	worker    bool
	discovery *speedTestDiscovery
	cancelled []speedTestTombstone
	newRun    func(SpeedTestParams) *speedTestRun
}

func (m *speedTestManager) cancelledLocked(id string) bool {
	cutoff := time.Now().Add(-2 * speedTestDeadline)
	m.cancelled = slices.DeleteFunc(m.cancelled, func(item speedTestTombstone) bool {
		return item.at.Before(cutoff)
	})
	return slices.ContainsFunc(m.cancelled, func(item speedTestTombstone) bool { return item.id == id })
}

func (m *speedTestManager) rememberCancelLocked(id string) {
	if !m.cancelledLocked(id) {
		if len(m.cancelled) == speedTestMaxTombstones {
			m.cancelled = m.cancelled[1:]
		}
		m.cancelled = append(m.cancelled, speedTestTombstone{id: id, at: time.Now()})
	}
}

func (m *speedTestManager) start(params SpeedTestParams) (bool, error) {
	params, err := normalizeSpeedTestParams(params)
	if err != nil {
		return false, err
	}
	m.mu.Lock()
	defer m.mu.Unlock()
	if m.cancelledLocked(params.RequestID) {
		return false, nil
	}
	if m.latest != nil && m.latest.params.RequestID == params.RequestID {
		return true, nil
	}
	if m.latest != nil {
		m.latest.cancel()
		m.rememberCancelLocked(m.latest.params.RequestID)
	}
	if m.pending != nil {
		m.pending.complete(context.Canceled)
	}
	if m.discovery != nil {
		m.discovery.cancel()
	}
	makeRun := m.newRun
	if makeRun == nil {
		makeRun = newSpeedTestRun
	}
	m.latest = makeRun(params)
	m.pending = m.latest
	if !m.worker {
		m.worker = true
		safeGo("speedTest", m.work)
	}
	return true, nil
}

// Coalescing pending starts bounds work even when RPC calls arrive faster than cleanup.
func (m *speedTestManager) work() {
	for {
		m.mu.Lock()
		run := m.pending
		if run == nil {
			m.worker = false
			m.mu.Unlock()
			return
		}
		m.pending = nil
		m.running = run
		m.mu.Unlock()
		run.run()
		m.mu.Lock()
		m.running = nil
		m.mu.Unlock()
	}
}

func (m *speedTestManager) get(id string) (*SpeedTestSnapshot, error) {
	m.mu.Lock()
	run := m.latest
	m.mu.Unlock()
	if run == nil || run.params.RequestID != id {
		return nil, errors.New("speed test request not found")
	}
	return run.snapshot(), nil
}

func (m *speedTestManager) cancel(id string) bool {
	if !validSpeedTestID(id) {
		return false
	}
	m.mu.Lock()
	defer m.mu.Unlock()
	m.rememberCancelLocked(id)
	matched := false
	if m.latest != nil && m.latest.params.RequestID == id {
		m.latest.cancel()
		matched = true
	}
	if m.discovery != nil && m.discovery.id == id {
		m.discovery.cancel()
		matched = true
	}
	return matched
}

func (m *speedTestManager) stop() {
	m.mu.Lock()
	defer m.mu.Unlock()
	if m.latest != nil {
		m.latest.cancel()
		m.rememberCancelLocked(m.latest.params.RequestID)
	}
	if m.running != nil {
		m.running.cancel()
	}
	if m.discovery != nil {
		m.discovery.cancel()
		m.rememberCancelLocked(m.discovery.id)
	}
}

func handleStartSpeedTest(params SpeedTestParams) (bool, error) {
	return currentSpeedTests.start(params)
}

func handleGetSpeedTest(params SpeedTestRequest) (*SpeedTestSnapshot, error) {
	return currentSpeedTests.get(params.RequestID)
}

func handleCancelSpeedTest(params SpeedTestRequest) bool {
	return currentSpeedTests.cancel(params.RequestID)
}

func cancelSpeedTests() {
	currentSpeedTests.stop()
}

func handleSpeedTestServers(params SpeedTestServersParams) ([]SpeedTestServer, error) {
	if !validSpeedTestID(params.RequestID) || len(params.Search) > 256 || len(params.ProxyName) > 1024 {
		return nil, errors.New("invalid speed test server request")
	}
	if err := validateSpeedTestProxy(params.ProxyName); err != nil {
		return nil, err
	}
	ctx, cancel := context.WithTimeout(context.Background(), speedTestDiscoveryLimit)
	defer cancel()
	discovery := &speedTestDiscovery{id: params.RequestID, ctx: ctx, cancel: cancel}
	currentSpeedTests.mu.Lock()
	if currentSpeedTests.cancelledLocked(params.RequestID) {
		currentSpeedTests.mu.Unlock()
		return nil, context.Canceled
	}
	if currentSpeedTests.discovery != nil {
		currentSpeedTests.discovery.cancel()
	}
	currentSpeedTests.discovery = discovery
	currentSpeedTests.mu.Unlock()
	defer func() {
		currentSpeedTests.mu.Lock()
		if currentSpeedTests.discovery == discovery {
			currentSpeedTests.discovery = nil
		}
		currentSpeedTests.mu.Unlock()
	}()
	transport, err := newSpeedTestTransport(ctx, SpeedTestParams{
		ProxyName: params.ProxyName, Direct: params.Direct, UseSystemDNS: params.UseSystemDNS,
	})
	if err != nil {
		return nil, err
	}
	defer transport.close()
	return discoverSpeedTestServers(ctx, transport, params.Search, nil)
}

type speedTestRun struct {
	params    SpeedTestParams
	ctx       context.Context
	cancel    context.CancelFunc
	done      chan struct{}
	completed sync.Once
	started   time.Time
	budget    *speedTestBudget
	duration  time.Duration
	prepare   func(context.Context, *speedTestRun) (*speedTestTarget, error)

	mu        sync.Mutex
	state     SpeedTestSnapshot
	transport *speedTestTransport
	latency   *speedTestClient
	probe     *speedTestClient
	load      []*speedTestClient
}

func newSpeedTestRun(params SpeedTestParams) *speedTestRun {
	ctx, cancel := context.WithTimeout(context.Background(), speedTestDeadline)
	epoch, version := routeStamp()
	return &speedTestRun{
		params: params, ctx: ctx, cancel: cancel, done: make(chan struct{}), started: time.Now(),
		budget: newSpeedTestBudget(params.ByteLimit), duration: time.Duration(params.DurationSeconds) * time.Second,
		prepare: prepareSpeedTest,
		state: SpeedTestSnapshot{
			RequestID: params.RequestID, BackendID: params.BackendID, Phase: "running", Stage: "warmup",
			ByteLimit: params.ByteLimit, ViaVPN: !params.Direct, ProxyName: params.ProxyName,
			Protocol: "h1", Chains: []string{}, Errors: []string{}, Hits: []RouteHit{},
			DownloadSamples: []SpeedTestSample{}, UploadSamples: []SpeedTestSample{},
			CoreEpoch: epoch, RouteVersion: version,
		},
	}
}

func (r *speedTestRun) update(update func(*SpeedTestSnapshot)) {
	r.mu.Lock()
	defer r.mu.Unlock()
	if r.state.Phase == "running" {
		update(&r.state)
	}
}

func (r *speedTestRun) snapshot() *SpeedTestSnapshot {
	r.mu.Lock()
	state := r.state.clone()
	transport := r.transport
	r.mu.Unlock()
	if state.Phase == "running" {
		state.ElapsedMs = time.Since(r.started).Milliseconds()
		state.TransferredBytes = r.budget.spent()
		if transport != nil {
			state.Chains, state.Hits = transport.evidence()
		}
	}
	return state
}

func (r *speedTestRun) setStage(stage string, progress float64) {
	r.update(func(state *SpeedTestSnapshot) {
		state.Stage, state.Progress, state.LiveMbps = stage, progress, nil
	})
}

func (r *speedTestRun) stageError(stage string) {
	r.update(func(state *SpeedTestSnapshot) {
		if !slices.Contains(state.Errors, stage) {
			state.Errors = append(state.Errors, stage)
		}
	})
}

func (r *speedTestRun) limited() {
	r.update(func(state *SpeedTestSnapshot) { state.Limited = true })
}

func (r *speedTestRun) complete(err error) {
	r.completed.Do(func() {
		r.mu.Lock()
		defer r.mu.Unlock()
		r.state.ElapsedMs = time.Since(r.started).Milliseconds()
		r.state.TransferredBytes = r.budget.spent()
		r.state.LiveMbps = nil
		if r.transport != nil {
			r.state.Chains, r.state.Hits = r.transport.evidence()
		}
		switch {
		case errors.Is(err, context.Canceled):
			r.state.Phase = "cancelled"
		case err != nil:
			r.state.Phase = "failed"
			r.state.Failure = "unavailable"
			if errors.Is(err, context.DeadlineExceeded) {
				r.state.Failure = "timeout"
			} else if errors.Is(err, errSpeedTestRejected) {
				r.state.Failure = "rejected"
			} else if errors.Is(err, errSpeedTestPanic) {
				r.state.Failure = "internal_error"
			}
		case r.state.Latency == nil && r.state.DownloadMbps == nil && r.state.UploadMbps == nil:
			r.state.Phase, r.state.Failure = "failed", "unavailable"
		default:
			r.state.Phase, r.state.Progress = "done", 1
		}
		close(r.done)
	})
}

func (r *speedTestRun) run() {
	var err error
	defer func() {
		if recover() != nil {
			err = errSpeedTestPanic
		}
		if r.ctx.Err() != nil {
			err = r.ctx.Err()
		}
		r.cancel()
		if r.transport != nil {
			r.transport.close()
		}
		r.complete(err)
	}()
	if err = r.ctx.Err(); err != nil {
		return
	}
	transport, createErr := newSpeedTestTransport(r.ctx, r.params)
	if createErr != nil {
		err = createErr
		return
	}
	r.mu.Lock()
	r.transport = transport
	r.mu.Unlock()
	err = r.execute()
}

func (r *speedTestRun) execute() error {
	target, err := r.prepare(r.ctx, r)
	if err != nil {
		r.stageError("warmup")
		return err
	}
	r.update(func(state *SpeedTestSnapshot) { state.Server = cloneSpeedTestServer(&target.server) })
	if err := r.setupProtocol(target); err != nil {
		return err
	}
	r.warmup(target)
	if err := r.ctx.Err(); err != nil {
		return err
	}
	r.setStage("latency", .1)
	latencies := r.measureIdleLatency(target)
	r.update(func(state *SpeedTestSnapshot) { state.Latency = speedTestLatencyStats(latencies) })
	if len(latencies) < 2 {
		r.stageError("latency")
	}
	if r.params.Mode == "latencyOnly" || r.ctx.Err() != nil {
		return r.ctx.Err()
	}
	r.setStage("download", .3)
	downloadLoaded := r.measureLoad(target, false)
	if r.ctx.Err() != nil {
		return r.ctx.Err()
	}
	r.setStage("upload", .65)
	uploadLoaded := r.measureLoad(target, true)
	r.update(func(state *SpeedTestSnapshot) {
		state.RPM = speedTestRPM(append(downloadLoaded, uploadLoaded...))
	})
	return r.ctx.Err()
}
