package core

import (
	"net/http"
	"testing"

	"github.com/metacubex/mihomo/log"
)

func TestNormalizeControllerLog(t *testing.T) {
	closed := "External controller serve error: " + http.ErrServerClosed.Error()
	cases := []struct {
		name  string
		event log.Event
		want  log.Event
	}{
		{
			name:  "normal controller close",
			event: log.Event{LogLevel: log.ERROR, Payload: closed},
			want:  log.Event{LogLevel: log.INFO, Payload: closed},
		},
		{
			name:  "real controller failure",
			event: log.Event{LogLevel: log.ERROR, Payload: "External controller serve error: listen tcp: address already in use"},
			want:  log.Event{LogLevel: log.ERROR, Payload: "External controller serve error: listen tcp: address already in use"},
		},
		{
			name:  "unrelated server close",
			event: log.Event{LogLevel: log.ERROR, Payload: "Provider request failed: " + http.ErrServerClosed.Error()},
			want:  log.Event{LogLevel: log.ERROR, Payload: "Provider request failed: " + http.ErrServerClosed.Error()},
		},
		{
			name:  "bare server close",
			event: log.Event{LogLevel: log.ERROR, Payload: http.ErrServerClosed.Error()},
			want:  log.Event{LogLevel: log.ERROR, Payload: http.ErrServerClosed.Error()},
		},
		{
			name:  "wrapped controller message",
			event: log.Event{LogLevel: log.ERROR, Payload: "Request failed: " + closed},
			want:  log.Event{LogLevel: log.ERROR, Payload: "Request failed: " + closed},
		},
		{
			name:  "controller message with additional failure",
			event: log.Event{LogLevel: log.ERROR, Payload: closed + "; restart failed"},
			want:  log.Event{LogLevel: log.ERROR, Payload: closed + "; restart failed"},
		},
		{
			name:  "info level remains info",
			event: log.Event{LogLevel: log.INFO, Payload: closed},
			want:  log.Event{LogLevel: log.INFO, Payload: closed},
		},
		{
			name:  "debug level remains debug",
			event: log.Event{LogLevel: log.DEBUG, Payload: closed},
			want:  log.Event{LogLevel: log.DEBUG, Payload: closed},
		},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			if got := normalizeControllerLog(tc.event); got != tc.want {
				t.Fatalf("normalizeControllerLog(%#v) = %#v, want %#v", tc.event, got, tc.want)
			}
		})
	}
}
