package telegram

import (
	"context"
	"fmt"
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestQueryDoHReadsAnAddress(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Query().Get("type") != "A" || r.URL.Query().Get("name") != "example.org" {
			t.Errorf("query %s", r.URL.RawQuery)
		}
		_, _ = fmt.Fprint(w, `{"Answer":[{"type":5,"data":"alias.example.org"},{"type":1,"data":"192.0.2.7"}]}`)
	}))
	defer server.Close()
	if got := queryDoH(context.Background(), server.URL, "example.org"); got != "192.0.2.7" {
		t.Fatalf("address %q", got)
	}
}
