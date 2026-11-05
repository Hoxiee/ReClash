package core

import (
	"context"
	"encoding/hex"
	"errors"
	"fmt"
	"net"
	"strconv"
	"strings"
	"sync"
	"time"

	"core/telegram"

	"github.com/metacubex/mihomo/component/dialer"
	"github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/log"
	"github.com/metacubex/mihomo/tunnel"
)

const telegramSelfTestTimeout = 15 * time.Second

type TelegramProxyParams struct {
	Enabled   bool     `json:"enabled"`
	Port      int      `json:"port"`
	Secret    string   `json:"secret"`
	Endpoints []string `json:"endpoints"`
	Outbound  string   `json:"outbound"`
}

type TelegramProxyState struct {
	Running           bool             `json:"running"`
	Error             string           `json:"error,omitempty"`
	OutboundAvailable bool             `json:"outboundAvailable"`
	OutboundName      string           `json:"outboundName,omitempty"`
	Status            *telegram.Status `json:"status,omitempty"`
}

// The relay belongs to the Core's lifetime, not to a run: nothing here reads
// isRunning or the listeners, so it needs neither a profile nor a TUN and
// starting it never touches either.
var telegramProxy struct {
	mu         sync.Mutex
	relay      *telegram.Relay
	listenPort int
	secret     string
	outbound   string
	lastError  string
	appliedSeq uint64
}

func handleSetTelegramProxy(call *MethodCall) (any, error) {
	params, err := decodeArguments[TelegramProxyParams](call)
	if err != nil {
		return nil, err
	}
	return applyTelegramProxy(params, call.seq), nil
}

func applyTelegramProxy(params TelegramProxyParams, seq uint64) TelegramProxyState {
	p := &telegramProxy
	p.mu.Lock()
	defer p.mu.Unlock()
	if seq < p.appliedSeq {
		return telegramProxyStateLocked()
	}
	p.appliedSeq = seq
	p.lastError = ""
	if !params.Enabled {
		stopTelegramProxyLocked()
		return telegramProxyStateLocked()
	}
	secret, err := decodeTelegramSecret(params.Secret)
	if err != nil {
		stopTelegramProxyLocked()
		p.lastError = err.Error()
		return telegramProxyStateLocked()
	}
	if p.relay != nil && p.listenPort == params.Port && p.secret == params.Secret {
		p.relay.SetEndpoints(params.Endpoints)
		if p.outbound != params.Outbound {
			p.outbound = params.Outbound
			p.relay.SetOutbound(dialTelegramOutbound(params.Outbound))
		}
		return telegramProxyStateLocked()
	}
	stopTelegramProxyLocked()
	relay, err := telegram.Start(telegram.Config{
		Listen:    net.JoinHostPort("127.0.0.1", strconv.Itoa(params.Port)),
		Secret:    secret,
		Endpoints: params.Endpoints,
		Dial: func(ctx context.Context, network, address string) (net.Conn, error) {
			return dialer.DialContext(ctx, network, address)
		},
		Outbound: dialTelegramOutbound(params.Outbound),
		Logf: func(format string, args ...any) {
			log.Debugln("[Telegram] "+format, args...)
		},
	})
	if err != nil {
		p.lastError = err.Error()
		return telegramProxyStateLocked()
	}
	p.relay = relay
	p.listenPort = params.Port
	p.secret = params.Secret
	p.outbound = params.Outbound
	return telegramProxyStateLocked()
}

func decodeTelegramSecret(value string) ([]byte, error) {
	secret, err := hex.DecodeString(strings.TrimPrefix(value, "dd"))
	if err != nil || len(secret) != 16 {
		return nil, errors.New("telegram proxy secret must be 32 hex digits")
	}
	return secret, nil
}

func stopTelegramProxyLocked() {
	p := &telegramProxy
	if p.relay == nil {
		return
	}
	p.relay.Stop()
	p.relay = nil
	p.secret = ""
}

func telegramProxyStateLocked() TelegramProxyState {
	p := &telegramProxy
	state := TelegramProxyState{
		Error:             p.lastError,
		OutboundAvailable: len(tunnel.AllProxies()) > 0,
	}
	if p.relay == nil {
		return state
	}
	status := p.relay.Status()
	state.Running = true
	state.Status = &status
	if proxy, err := telegramOutbound(p.outbound, telegramProbeAddress); err == nil {
		state.OutboundName = proxy.Name()
	}
	return state
}

func handleGetTelegramProxy() TelegramProxyState {
	telegramProxy.mu.Lock()
	defer telegramProxy.mu.Unlock()
	return telegramProxyStateLocked()
}

// A call that was still in flight when the host shut the Core down must not
// bring the relay back.
func stopTelegramProxy() {
	p := &telegramProxy
	p.mu.Lock()
	defer p.mu.Unlock()
	p.appliedSeq = methodCallSeq.Load() + 1
	stopTelegramProxyLocked()
}

// Sockets opened before a TUN came up or on a network that is gone would only
// time out; Telegram reconnects at once when they close.
func resetTelegramProxyConnections() {
	telegramProxy.mu.Lock()
	relay := telegramProxy.relay
	telegramProxy.mu.Unlock()
	if relay != nil {
		relay.ResetConnections()
	}
}

// An empty outbound leaves the profile unused, so a relay nobody opted in never
// spends subscription traffic; this value picks the profile's rules, and a name
// that cannot collide with a proxy group keeps both in one setting.
const telegramOutboundRules = "@rules"

// DC 5, one of the DCs that only an outbound reaches: rules that route by IP
// range answer for all of them through this address.
const telegramProbeAddress = "91.108.56.130:443"

func telegramOutbound(name, address string) (constant.Proxy, error) {
	if name == "" || len(tunnel.AllProxies()) == 0 {
		return nil, telegram.ErrNoOutbound
	}
	if name != telegramOutboundRules {
		proxy := lookupProxy(name)
		if proxy == nil {
			return nil, fmt.Errorf("outbound %s is not in the active profile: %w", name, telegram.ErrNoOutbound)
		}
		return proxy, nil
	}
	metadata, err := probeMetadata(address)
	if err != nil {
		return nil, err
	}
	return tunnel.ResolveRoute(metadata)
}

func dialTelegramOutbound(name string) telegram.OutboundFunc {
	if name == "" {
		return nil
	}
	return func(ctx context.Context, address string) (net.Conn, error) {
		proxy, err := telegramOutbound(name, address)
		if err != nil {
			return nil, err
		}
		metadata, err := probeMetadata(address)
		if err != nil {
			return nil, err
		}
		return proxy.DialContext(ctx, metadata)
	}
}

// A full round through the listener, the secret and an upstream, which is what
// Telegram does and what nothing short of a real reply can confirm.
func handleTelegramProxySelfTest(dc int16) string {
	p := &telegramProxy
	p.mu.Lock()
	relay, secretHex := p.relay, p.secret
	p.mu.Unlock()
	if relay == nil {
		return "telegram proxy is not running"
	}
	secret, err := decodeTelegramSecret(secretHex)
	if err != nil {
		return err.Error()
	}
	ctx, cancel := context.WithTimeout(context.Background(), telegramSelfTestTimeout)
	defer cancel()
	address := net.JoinHostPort("127.0.0.1", strconv.Itoa(relay.Port()))
	if _, err := telegram.SelfTest(ctx, address, secret, dc); err != nil {
		return err.Error()
	}
	return ""
}
