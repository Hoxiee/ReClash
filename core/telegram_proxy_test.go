package core

import (
	"context"
	"core/telegram"
	"errors"
	"net"
	"strconv"
	"strings"
	"testing"
)

const telegramTestSecret = "00112233445566778899aabbccddeeff"

func freeTelegramPort(t *testing.T) int {
	t.Helper()
	listener, err := net.Listen("tcp4", "127.0.0.1:0")
	if err != nil {
		t.Fatal(err)
	}
	defer listener.Close()
	return listener.Addr().(*net.TCPAddr).Port
}

func runningTelegramProxy(t *testing.T) TelegramProxyParams {
	t.Helper()
	t.Cleanup(stopTelegramProxy)
	params := TelegramProxyParams{Enabled: true, Port: freeTelegramPort(t), Secret: telegramTestSecret}
	if state := applyTelegramProxy(params, methodCallSeq.Add(1)); !state.Running || state.Error != "" {
		t.Fatalf("state %+v", state)
	}
	return params
}

func TestTelegramProxyRunsWithoutProfileOrListeners(t *testing.T) {
	params := runningTelegramProxy(t)
	if isRunning.Load() {
		t.Fatal("the relay must not need a run")
	}
	state := handleGetTelegramProxy()
	if !state.Running || state.Status.Port != params.Port {
		t.Fatalf("state %+v", state)
	}
	if state.OutboundAvailable {
		t.Fatal("no profile, so no outbound")
	}
	conn, err := net.Dial("tcp4", net.JoinHostPort("127.0.0.1", strconv.Itoa(params.Port)))
	if err != nil {
		t.Fatal(err)
	}
	conn.Close()
}

func TestTelegramProxyStaleCallLosesToLatestIntent(t *testing.T) {
	params := runningTelegramProxy(t)
	stale := methodCallSeq.Add(1)
	stopped := params
	stopped.Enabled = false
	if state := applyTelegramProxy(stopped, methodCallSeq.Add(1)); state.Running {
		t.Fatalf("still running: %+v", state)
	}
	if state := applyTelegramProxy(params, stale); state.Running {
		t.Fatalf("an older start overrode the stop: %+v", state)
	}
}

func TestTelegramProxyReportsBusyPortAndBadSecret(t *testing.T) {
	t.Cleanup(stopTelegramProxy)
	busy, err := net.Listen("tcp4", "127.0.0.1:0")
	if err != nil {
		t.Fatal(err)
	}
	defer busy.Close()
	state := applyTelegramProxy(TelegramProxyParams{
		Enabled: true,
		Port:    busy.Addr().(*net.TCPAddr).Port,
		Secret:  telegramTestSecret,
	}, methodCallSeq.Add(1))
	if state.Running || state.Error == "" {
		t.Fatalf("state %+v", state)
	}
	state = applyTelegramProxy(TelegramProxyParams{Enabled: true, Port: freeTelegramPort(t), Secret: "zz"}, methodCallSeq.Add(1))
	if state.Running || !strings.Contains(state.Error, "secret") {
		t.Fatalf("state %+v", state)
	}
	if strings.Contains(state.Error, "zz") {
		t.Fatal("the secret reached an error message")
	}
}

func TestTelegramProxySurvivesStartAndStopOfARun(t *testing.T) {
	params := runningTelegramProxy(t)
	oldConfig := currentConfig
	t.Cleanup(func() {
		handleStopListener()
		currentConfig = oldConfig
	})
	currentConfig = nil
	handleStartListener()
	handleStopListener()
	if state := handleGetTelegramProxy(); !state.Running || state.Status.Port != params.Port {
		t.Fatalf("state %+v", state)
	}
}

func TestTelegramProxyStopsWithShutdownAndIgnoresInFlightStart(t *testing.T) {
	params := runningTelegramProxy(t)
	inFlight := methodCallSeq.Add(1)
	stopTelegramProxy()
	if state := applyTelegramProxy(params, inFlight); state.Running {
		t.Fatalf("started after shutdown: %+v", state)
	}
}

func TestTelegramProxyLeavesTheProfileUnusedUntilAsked(t *testing.T) {
	if dialTelegramOutbound("") != nil {
		t.Fatal("an empty outbound must not dial")
	}
	for _, name := range []string{telegramOutboundRules, "group"} {
		dial := dialTelegramOutbound(name)
		if dial == nil {
			t.Fatalf("%q must dial", name)
		}
		if _, err := dial(context.Background(), telegramProbeAddress); !errors.Is(err, telegram.ErrNoOutbound) {
			t.Fatalf("%q without a profile: %v", name, err)
		}
	}
}
