//go:build android && cgo

package main

import (
	"net/netip"
	"strings"
	"sync"
	"syscall"
)

var subscriptionDNS = struct {
	sync.RWMutex
	servers []string
}{}

func updateSubscriptionDNS(value string) {
	servers := []string{}
	for _, server := range strings.Split(value, ",") {
		if address, err := netip.ParseAddrPort(server); err == nil && !address.Addr().IsUnspecified() {
			servers = append(servers, address.String())
		}
	}
	subscriptionDNS.Lock()
	subscriptionDNS.servers = servers
	subscriptionDNS.Unlock()
}

func protectedSubscriptionDialer() (*subscriptionDialer, error) {
	handler := activeTunHandler.Load()
	if handler == nil {
		return nil, errSubscriptionProtection
	}
	subscriptionDNS.RLock()
	servers := append([]string(nil), subscriptionDNS.servers...)
	subscriptionDNS.RUnlock()
	if len(servers) == 0 {
		return nil, errSubscriptionProtection
	}
	control := func(_, _ string, connection syscall.RawConn) error {
		handler.mu.RLock()
		defer handler.mu.RUnlock()
		if activeTunHandler.Load() != handler || handler.closing || handler.callback == nil || handler.listener == nil {
			return errSubscriptionProtection
		}
		accepted := false
		if err := connection.Control(func(fd uintptr) {
			accepted = protectSubscription(handler.callback, int(fd))
		}); err != nil {
			return err
		}
		if !accepted {
			return errSubscriptionProtection
		}
		return nil
	}
	return newSubscriptionDialer(control, servers), nil
}
