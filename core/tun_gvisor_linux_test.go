//go:build linux && !android && with_gvisor

package main

import (
	"errors"
	"testing"

	"github.com/metacubex/gvisor/pkg/tcpip/stack"
	tun "github.com/metacubex/sing-tun"
)

type recordingTunEndpoint struct {
	stack.LinkEndpoint
	attachments []stack.NetworkDispatcher
}

func (e *recordingTunEndpoint) Attach(dispatcher stack.NetworkDispatcher) {
	e.attachments = append(e.attachments, dispatcher)
}

type recordingTunStack struct {
	tun.Stack
	close func() error
}

func (s *recordingTunStack) Close() error { return s.close() }

type tunDispatcher struct{ stack.NetworkDispatcher }

func TestLinuxGVisorCloseStopsReaderBeforeStack(t *testing.T) {
	raw := &recordingTunEndpoint{}
	endpoint := &linuxTunEndpoint{LinkEndpoint: raw}
	endpoint.Attach(&tunDispatcher{})
	closeCalls := 0
	wantErr := errors.New("close error")
	owned := &linuxGVisorStack{
		device: &linuxGVisorTun{endpoint: endpoint},
		Stack: &recordingTunStack{close: func() error {
			closeCalls++
			if len(raw.attachments) != 2 || raw.attachments[1] != nil {
				t.Fatal("reader was not detached before stack cleanup")
			}
			endpoint.Attach(&tunDispatcher{})
			return wantErr
		}},
	}
	for i := 0; i < 3; i++ {
		if err := owned.Close(); !errors.Is(err, wantErr) {
			t.Fatalf("close result = %v", err)
		}
	}
	if closeCalls != 1 || len(raw.attachments) != 2 {
		t.Fatalf("close calls = %d, attachments = %d", closeCalls, len(raw.attachments))
	}
}

func TestLinuxGVisorCloseBeforeEndpointCreation(t *testing.T) {
	calls := 0
	owned := &linuxGVisorStack{
		device: &linuxGVisorTun{},
		Stack:  &recordingTunStack{close: func() error { calls++; return nil }},
	}
	if err := owned.Close(); err != nil || calls != 1 {
		t.Fatalf("close before start: calls=%d, error=%v", calls, err)
	}
}

func TestLinuxTunEndpointStopIsTerminal(t *testing.T) {
	raw := &recordingTunEndpoint{}
	endpoint := &linuxTunEndpoint{LinkEndpoint: raw}
	endpoint.stop()
	endpoint.stop()
	endpoint.Attach(&tunDispatcher{})
	endpoint.Attach(nil)
	if len(raw.attachments) != 1 || raw.attachments[0] != nil {
		t.Fatalf("attachments after stop: %v", raw.attachments)
	}
}
