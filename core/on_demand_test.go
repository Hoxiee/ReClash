package core

import (
	"net"
	"strconv"
	"testing"
	"time"

	"github.com/metacubex/mihomo/config"
	"github.com/metacubex/mihomo/listener"
)

func TestOnDemandPauseRetainsListenersAndFullStopRestoresThem(t *testing.T) {
	oldConfig, oldRunning := currentConfig, isRunning.Load()
	oldPaused, oldFullStop := onDemandPaused.Load(), onDemandFullStop.Load()
	t.Cleanup(func() {
		listener.StopListener()
		currentConfig = oldConfig
		isRunning.Store(oldRunning)
		onDemandPaused.Store(oldPaused)
		onDemandFullStop.Store(oldFullStop)
	})
	reservation, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatal(err)
	}
	port := reservation.Addr().(*net.TCPAddr).Port
	reservation.Close()
	cfg, err := config.Parse([]byte("mixed-port: " + strconv.Itoa(port) + "\nallow-lan: false\ntun:\n  enable: false\n"))
	if err != nil {
		t.Fatal(err)
	}
	currentConfig = cfg
	isRunning.Store(true)
	onDemandPaused.Store(false)
	updateListeners(cfg)
	address := net.JoinHostPort("127.0.0.1", strconv.Itoa(port))
	checkListener := func(want bool) {
		t.Helper()
		conn, err := net.DialTimeout("tcp", address, time.Second)
		if conn != nil {
			conn.Close()
		}
		if (err == nil) != want {
			t.Fatalf("listener present = %v, want %v: %v", err == nil, want, err)
		}
	}
	checkListener(true)
	handleSetOnDemandPaused(&OnDemandPauseParams{Paused: true})
	stopListenersAfterTunClose()
	checkListener(true)
	cfg.General.Tun.Enable = true
	updateListeners(cfg)
	if !cfg.General.Tun.Enable || listener.GetTunConf().Enable {
		t.Fatal("pause changed saved TUN or enabled runtime TUN")
	}
	cfg.General.Tun.Enable = false
	handleSetOnDemandPaused(&OnDemandPauseParams{Paused: true, FullStop: true})
	checkListener(false)
	if listener.GetTunConf().Enable {
		t.Fatal("full stop reports an active TUN")
	}
	if !isRunning.Load() {
		t.Fatal("pause ended the logical run")
	}
	handleSetOnDemandPaused(&OnDemandPauseParams{})
	checkListener(true)
	handleStopListener()
	handleSetOnDemandPaused(&OnDemandPauseParams{Paused: true})
	if onDemandPaused.Load() {
		t.Fatal("a pause resurrected a stopped run")
	}
	checkListener(false)
}
