package main

import (
	"errors"
	"net"
	"testing"
	"time"

	"github.com/metacubex/mihomo/config"
	"github.com/metacubex/mihomo/listener"
	LC "github.com/metacubex/mihomo/listener/config"
)

func preserveTunTestState(t *testing.T) {
	t.Helper()
	running, requested, up, paused := isRunning.Load(), tunRequested.Load(), tunUp.Load(), tunPaused.Load()
	t.Cleanup(func() {
		isRunning.Store(running)
		tunRequested.Store(requested)
		tunUp.Store(up)
		tunPaused.Store(paused)
	})
}

func TestStopListenerClearsStaleTunConfig(t *testing.T) {
	preserveTunTestState(t)
	previous := listener.LastTunConf
	t.Cleanup(func() { listener.LastTunConf = previous })
	listener.LastTunConf = LC.Tun{Enable: true, Device: "reclash-test"}
	listener.StopListener()
	if !listener.GetTunConf().Enable {
		t.Fatal("fixture no longer reproduces the upstream stale config")
	}
	if !handleStopListener() {
		t.Fatal("stop failed")
	}
	isRunning.Store(true)
	syncTunUp()
	if listener.GetTunConf().Enable || tunUp.Load() {
		t.Fatal("stopped listener's saved config was reported as a live TUN")
	}
}

type tunLifecycleFixture struct {
	live, occupied, failCreate bool
	now, releaseAt             time.Time
	creates, closes, reloads   int
	probes                     int
}

func fakeTunLifecycle(t *testing.T) *tunLifecycleFixture {
	t.Helper()
	preserveTunTestState(t)
	oldRecreate, oldLookup, oldNow, oldSleep := recreateTun, tunInterfaceByName, tunNow, tunSleep
	oldConf := listener.LastTunConf
	t.Cleanup(func() {
		recreateTun, tunInterfaceByName, tunNow, tunSleep = oldRecreate, oldLookup, oldNow, oldSleep
		listener.LastTunConf = oldConf
	})
	listener.LastTunConf = LC.Tun{}
	isRunning.Store(false)
	tunRequested.Store(false)
	tunUp.Store(false)
	tunPaused.Store(false)
	f := &tunLifecycleFixture{now: time.Unix(0, 0)}
	tunNow = func() time.Time { return f.now }
	tunSleep = func(wait time.Duration) { f.now = f.now.Add(wait) }
	tunInterfaceByName = func(name string) (*net.Interface, error) {
		f.probes++
		if f.live || f.occupied || f.now.Before(f.releaseAt) {
			return &net.Interface{Name: name}, nil
		}
		return nil, errors.New("no such network interface")
	}
	recreateTun = func(conf LC.Tun) {
		if !conf.Enable {
			if f.live {
				f.live = false
				f.closes++
				f.releaseAt = f.now.Add(500 * time.Millisecond)
			}
		} else if f.live && conf.Equal(listener.LastTunConf) {
			f.reloads++
		} else {
			if f.live || f.occupied || f.now.Before(f.releaseAt) {
				t.Fatal("TUN creation attempted before the previous device released its name")
			}
			f.creates++
			conf.Enable = !f.failCreate
			f.live = conf.Enable
		}
		listener.LastTunConf = conf
	}
	return f
}

func tunLifecycleConfig() *config.Config {
	return &config.Config{General: &config.General{
		Inbound: config.Inbound{Tun: LC.Tun{Enable: true, Device: "reclash-test"}},
	}}
}

func TestTunStartStopStartWaitsForNameRelease(t *testing.T) {
	f := fakeTunLifecycle(t)
	cfg := tunLifecycleConfig()
	withCurrentConfig(t, cfg)
	for i := 0; i < 5; i++ {
		if !handleStartListener() || !f.live || !tunUp.Load() {
			t.Fatalf("start %d did not activate TUN", i)
		}
		if !handleStopListener() || f.live || tunUp.Load() || listener.GetTunConf().Enable {
			t.Fatalf("stop %d retained TUN state", i)
		}
	}
	if f.creates != 5 || f.closes != 5 || f.now.Sub(time.Unix(0, 0)) != 2*time.Second {
		t.Fatalf("unexpected lifecycle: %+v", f)
	}
	if !cfg.General.Tun.Enable {
		t.Fatal("stop changed the requested config")
	}
}

func TestTunPauseResumeWaitsForNameRelease(t *testing.T) {
	f := fakeTunLifecycle(t)
	cfg := tunLifecycleConfig()
	withCurrentConfig(t, cfg)
	if !handleStartListener() || !handlePauseTun() {
		t.Fatal("start or pause failed")
	}
	if f.live || tunUp.Load() || !cfg.General.Tun.Enable || !tunRequested.Load() {
		t.Fatal("pause did not preserve the request while closing TUN")
	}
	if !handleResumeTun() || !f.live || !tunUp.Load() {
		t.Fatal("resume did not recreate TUN")
	}
	if f.creates != 2 || f.closes != 1 || f.now.Sub(time.Unix(0, 0)) != 500*time.Millisecond {
		t.Fatalf("unexpected lifecycle: %+v", f)
	}
}

func TestTunReconfigureWaitsButEqualConfigReuses(t *testing.T) {
	f := fakeTunLifecycle(t)
	cfg := tunLifecycleConfig()
	cfg.General.Tun.DNSHijack = []string{"udp://b:53", "udp://a:53"}
	withCurrentConfig(t, cfg)
	if !handleStartListener() {
		t.Fatal("start failed")
	}
	probes := f.probes
	cfg.General.Tun.DNSHijack = []string{"udp://b:53", "udp://a:53"}
	updateListeners(cfg)
	if f.creates != 1 || f.closes != 0 || f.reloads != 1 || f.probes != probes {
		t.Fatalf("equal config recreated or waited for its own device: %+v", f)
	}
	cfg.General.Tun.MTU = 1400
	updateListeners(cfg)
	if f.creates != 2 || f.closes != 1 || !f.live || !tunUp.Load() || f.now.Sub(time.Unix(0, 0)) != 500*time.Millisecond {
		t.Fatalf("changed config did not close, wait, then recreate: %+v", f)
	}
}

func TestTunConfigurationAndStartOrders(t *testing.T) {
	for _, startFirst := range []bool{false, true} {
		name := "config before start"
		if startFirst {
			name = "start before config"
		}
		t.Run(name, func(t *testing.T) {
			f := fakeTunLifecycle(t)
			withCurrentConfig(t, nil)
			if startFirst && !handleStartListener() {
				t.Fatal("start without config failed")
			}
			currentConfig = tunLifecycleConfig()
			updateListeners(currentConfig)
			if !startFirst && !handleStartListener() {
				t.Fatal("start with config failed")
			}
			if !f.live || !tunUp.Load() || f.creates != 1 || requestedTunError() != nil {
				t.Fatalf("configuration order left TUN inactive: %+v", f)
			}
		})
	}
}

func TestTunOccupiedNameFailsWithinBound(t *testing.T) {
	for _, reconfigure := range []bool{false, true} {
		name := "start"
		if reconfigure {
			name = "reconfigure"
		}
		t.Run(name, func(t *testing.T) {
			f := fakeTunLifecycle(t)
			cfg := tunLifecycleConfig()
			withCurrentConfig(t, cfg)
			if reconfigure {
				if !handleStartListener() {
					t.Fatal("initial start failed")
				}
				cfg.General.Tun.MTU = 1400
			} else {
				listener.LastTunConf = cfg.General.Tun
			}
			f.occupied = true
			before, creates := f.now, f.creates
			if reconfigure {
				updateListeners(cfg)
			} else if handleStartListener() {
				t.Fatal("start accepted an occupied TUN name")
			}
			if f.now.Sub(before) != 8*time.Second || f.creates != creates {
				t.Fatalf("name wait exceeded its budget or attempted creation: %+v", f)
			}
			if f.live || tunUp.Load() || listener.GetTunConf().Enable || !errors.Is(requestedTunError(), errTunNotActive) {
				t.Fatal("failed transition reported stale TUN health")
			}
		})
	}
}

func TestTunFreeNameCreationFailureIsNotRetried(t *testing.T) {
	f := fakeTunLifecycle(t)
	f.failCreate = true
	withCurrentConfig(t, tunLifecycleConfig())
	if handleStartListener() || f.live || tunUp.Load() {
		t.Fatal("failed creation reported success")
	}
	if f.creates != 1 || f.now != time.Unix(0, 0) {
		t.Fatalf("creation failure was retried or delayed: %+v", f)
	}
	f.failCreate = false
	if !handleStartListener() || !tunUp.Load() || f.creates != 2 {
		t.Fatal("explicit retry did not activate TUN")
	}
}

func TestRequestedTunError(t *testing.T) {
	preserveTunTestState(t)
	for _, tt := range []struct {
		name                                   string
		running, requested, up, paused, failed bool
	}{
		{name: "not started", requested: true},
		{name: "proxy only", running: true},
		{name: "active tun", running: true, requested: true, up: true},
		{name: "paused tun", running: true, requested: true, paused: true},
		{name: "failed tun", running: true, requested: true, failed: true},
	} {
		t.Run(tt.name, func(t *testing.T) {
			isRunning.Store(tt.running)
			tunRequested.Store(tt.requested)
			tunUp.Store(tt.up)
			tunPaused.Store(tt.paused)
			if got := requestedTunError(); errors.Is(got, errTunNotActive) != tt.failed {
				t.Fatalf("requestedTunError = %v, want failure %v", got, tt.failed)
			}
		})
	}
}

func TestDoctorPreservesRequestedTunWhenCaptureFailed(t *testing.T) {
	preserveTunTestState(t)
	isRunning.Store(false)
	tunUp.Store(false)
	cfg := &config.Config{General: &config.General{}}
	cfg.General.Tun = LC.Tun{Enable: true}
	updateListeners(cfg)
	path := (coreDoctorRuntime{}).DoctorPathContext()
	if path.PathKind != doctorPathTun || path.CaptureState != doctorCaptureInactive {
		t.Fatalf("path = %+v", path)
	}
	marker := []doctorEvidence{{Layer: doctorLayerMarker, Outcome: doctorOutcomeSucceeded, Confidence: doctorConfirmed, Code: "applicationProbeSucceeded"}}
	for _, requireIngress := range []bool{false, true} {
		verdict := reduceDoctorEvidence(marker, true, path, requireIngress)
		if verdict.Health != doctorBroken || verdict.CauseCode != "tunNotActive" {
			t.Fatalf("verdict = %+v", verdict)
		}
	}
	stages := doctorStages(marker, path, true)
	if stages[0].State != doctorStageFailed || stages[0].Code != "tunNotActive" {
		t.Fatalf("capture stage = %+v", stages[0])
	}
	cfg.General.Tun.Enable = false
	updateListeners(cfg)
	if tunRequested.Load() {
		t.Fatal("disabled config retained TUN request")
	}
}
