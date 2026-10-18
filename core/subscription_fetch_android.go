//go:build android

package core

import (
	"context"
	"errors"
	"net"
	"strings"
	"syscall"
)

type androidSubscriptionConnector struct {
	resolver *net.Resolver
}

func init() {
	protectedSubscriptionConnector = func() (subscriptionConnector, error) {
		th := activeTunHandler.Load()
		if th == nil {
			return nil, errSubscriptionProtectedUnavailable
		}
		th.mu.RLock()
		callbacks := th.callbacks
		th.mu.RUnlock()
		if callbacks == nil {
			return nil, errSubscriptionProtectedUnavailable
		}
		connector := &androidSubscriptionConnector{}
		connector.resolver = &net.Resolver{PreferGo: true, StrictErrors: true, Dial: func(ctx context.Context, network, address string) (net.Conn, error) {
			return (&net.Dialer{Control: connector.control}).DialContext(ctx, network, address)
		}}
		return connector, nil
	}
}

func (d *androidSubscriptionConnector) DialContext(ctx context.Context, network, address string) (net.Conn, error) {
	host, port, err := net.SplitHostPort(address)
	if err != nil {
		return nil, errors.New("invalid protected address")
	}
	if net.ParseIP(strings.Trim(host, "[]")) != nil {
		return (&net.Dialer{Control: d.control}).DialContext(ctx, network, address)
	}
	ips, err := d.resolver.LookupIPAddr(ctx, host)
	if err != nil {
		return nil, err
	}
	var lastErr error
	for _, ip := range ips {
		conn, dialErr := (&net.Dialer{Control: d.control}).DialContext(ctx, network, net.JoinHostPort(ip.IP.String(), port))
		if dialErr == nil {
			return conn, nil
		}
		lastErr = dialErr
	}
	if lastErr == nil {
		lastErr = errSubscriptionProtectedUnavailable
	}
	return nil, lastErr
}

func (d *androidSubscriptionConnector) control(_, _ string, raw syscall.RawConn) error {
	th := activeTunHandler.Load()
	if th == nil {
		return errSubscriptionProtectedUnavailable
	}
	th.mu.RLock()
	defer th.mu.RUnlock()
	if th.callbacks == nil {
		return errSubscriptionProtectedUnavailable
	}
	var protected bool
	if err := raw.Control(func(fd uintptr) { protected = th.callbacks.Protect(int(fd)) }); err != nil {
		return err
	}
	if !protected {
		return errSubscriptionProtectedRefused
	}
	return nil
}
