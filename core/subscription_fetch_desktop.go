//go:build !android

package core

import (
	"context"
	"errors"
	"net"

	"github.com/metacubex/mihomo/component/dialer"
	"github.com/metacubex/mihomo/component/resolver"
)

type desktopSubscriptionConnector struct{}

func init() {
	bypassSubscriptionConnector = func() (subscriptionConnector, error) {
		return desktopSubscriptionConnector{}, nil
	}
}

func (desktopSubscriptionConnector) DialContext(
	ctx context.Context,
	network string,
	address string,
) (net.Conn, error) {
	systemResolver := resolver.SystemResolver
	if systemResolver == nil {
		return nil, errors.New("system DNS resolver unavailable")
	}
	return dialer.DialContext(
		ctx,
		network,
		address,
		dialer.WithFallbackBind(true),
		dialer.WithResolver(systemResolver),
	)
}
