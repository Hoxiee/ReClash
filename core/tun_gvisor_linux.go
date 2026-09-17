//go:build linux && !android && with_gvisor

package main

import (
	"sync"

	"github.com/metacubex/gvisor/pkg/tcpip/stack"
	"github.com/metacubex/mihomo/listener/sing_tun"
	tun "github.com/metacubex/sing-tun"
)

func init() {
	sing_tun.NewStack = newLinuxTunStack
}

func newLinuxTunStack(name string, options tun.StackOptions) (tun.Stack, error) {
	device, ok := options.Tun.(tun.GVisorTun)
	if name != "gvisor" || !ok {
		return tun.NewStack(name, options)
	}
	owned := &linuxGVisorTun{GVisorTun: device}
	options.Tun = owned
	inner, err := tun.NewStack(name, options)
	if err != nil {
		return nil, err
	}
	return &linuxGVisorStack{Stack: inner, device: owned}, nil
}

type linuxGVisorTun struct {
	tun.GVisorTun
	endpoint *linuxTunEndpoint
}

func (t *linuxGVisorTun) NewEndpoint() (stack.LinkEndpoint, stack.NICOptions, error) {
	endpoint, options, err := t.GVisorTun.NewEndpoint()
	if err != nil {
		return nil, options, err
	}
	t.endpoint = &linuxTunEndpoint{LinkEndpoint: endpoint}
	return t.endpoint, options, nil
}

type linuxTunEndpoint struct {
	stack.LinkEndpoint
	mu      sync.Mutex
	stopped bool
}

func (e *linuxTunEndpoint) Attach(dispatcher stack.NetworkDispatcher) {
	e.mu.Lock()
	defer e.mu.Unlock()
	if !e.stopped {
		e.LinkEndpoint.Attach(dispatcher)
	}
}

func (e *linuxTunEndpoint) stop() {
	e.mu.Lock()
	defer e.mu.Unlock()
	if e.stopped {
		return
	}
	e.stopped = true
	e.LinkEndpoint.Attach(nil)
}

type linuxGVisorStack struct {
	tun.Stack
	device   *linuxGVisorTun
	once     sync.Once
	closeErr error
}

func (s *linuxGVisorStack) Close() error {
	s.once.Do(func() {
		// sing-tun's filter wraps Attach(nil), preventing the reader from stopping.
		if s.device.endpoint != nil {
			s.device.endpoint.stop()
		}
		s.closeErr = s.Stack.Close()
	})
	return s.closeErr
}
