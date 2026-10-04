package main

import (
	"encoding/json"
	"os"
	"reflect"
	"runtime"
	"testing"
	"time"

	"github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/constant/features"
)

func TestCoreInfoUsesRunningBinaryMetadata(t *testing.T) {
	info := handleGetCoreInfo()
	if info.Version != constant.Version || info.GoVersion != runtime.Version() {
		t.Fatalf("unexpected versions: %+v", info)
	}
	if info.RcxVersion != CoreVersion || info.RcxCommit != CoreCommit {
		t.Fatalf("engine identity must come from build metadata: %+v", info)
	}
	if info.Platform != runtime.GOOS || info.Architecture != runtime.GOARCH {
		t.Fatalf("unexpected target: %+v", info)
	}
	if !reflect.DeepEqual(info.Tags, append([]string{}, features.Tags()...)) {
		t.Fatalf("unexpected build flags: %v", info.Tags)
	}
	if !features.Android && info.ExecutablePath == "" {
		t.Fatal("desktop core must identify its own executable")
	}
	if features.Android && info.ExecutablePath != "" {
		t.Fatal("Android must not report the host process as the core binary")
	}
	if methodHandlers[getCoreInfoMethod] == nil {
		t.Fatal("getCoreInfo is not registered")
	}
}

func TestCoreBuildTime(t *testing.T) {
	for _, value := range []string{"", "unknown time", "not a timestamp"} {
		if coreBuildTime(value) != nil {
			t.Fatalf("invented a build time for %q", value)
		}
	}
	parsed := coreBuildTime("2026-10-02T11:05:06.123+03:00")
	want := time.Date(2026, 10, 2, 8, 5, 6, 123000000, time.UTC)
	if parsed == nil || !parsed.Equal(want) || parsed.Location() != time.UTC {
		t.Fatalf("expected UTC timestamp, got %v", parsed)
	}
}

func TestCoreInfoSharedWireFixture(t *testing.T) {
	data, err := os.ReadFile("../test/fixtures/core_info.json")
	if err != nil {
		t.Fatal(err)
	}
	var info CoreInfo
	if err := json.Unmarshal(data, &info); err != nil {
		t.Fatal(err)
	}
	if info.BuildTime == nil || info.Version != "1.19.31-2-gf77b7475" {
		t.Fatalf("incomplete metadata: %+v", info)
	}
	if info.RcxVersion != "0.1.0" || info.RcxCommit != "gf77b7475" {
		t.Fatalf("engine identity must survive the wire: %+v", info)
	}
	encoded, err := (MethodResponse{ID: "core-info", Result: info}).JSON()
	if err != nil {
		t.Fatal(err)
	}
	var response map[string]any
	var fixture map[string]any
	if err := json.Unmarshal(encoded, &response); err != nil {
		t.Fatal(err)
	}
	if err := json.Unmarshal(data, &fixture); err != nil {
		t.Fatal(err)
	}
	if !reflect.DeepEqual(response["result"], fixture) {
		t.Fatalf("metadata must remain a structured result: %s", encoded)
	}
}
