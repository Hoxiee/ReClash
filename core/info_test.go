package core

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
	if info.Platform != runtime.GOOS || info.Architecture != runtime.GOARCH {
		t.Fatalf("unexpected target: %+v", info)
	}
	if !reflect.DeepEqual(info.Tags, append([]string{}, features.Tags()...)) {
		t.Fatalf("unexpected build tags: %v", info.Tags)
	}
	if !features.Android && info.ExecutablePath == "" {
		t.Fatal("desktop Core must identify its executable")
	}
	if features.Android && info.ExecutablePath != "" {
		t.Fatal("Android must not report the host process as the Core executable")
	}
	if methodHandlers[getCoreInfoMethod] == nil {
		t.Fatal("getCoreInfo is not registered")
	}
}

func TestCoreInfoSharedWireFixture(t *testing.T) {
	data, err := os.ReadFile("../test/fixtures/core_info.json")
	if err != nil {
		t.Fatal(err)
	}
	var fixture map[string]any
	if err := json.Unmarshal(data, &fixture); err != nil {
		t.Fatal(err)
	}
	encoded, err := json.Marshal(fixture)
	if err != nil {
		t.Fatal(err)
	}
	var info CoreInfo
	if err := json.Unmarshal(encoded, &info); err != nil {
		t.Fatal(err)
	}
	result, err := json.Marshal(info)
	if err != nil {
		t.Fatal(err)
	}
	var actual map[string]any
	if err := json.Unmarshal(result, &actual); err != nil {
		t.Fatal(err)
	}
	if !reflect.DeepEqual(actual, fixture) {
		t.Fatalf("CoreInfo wire fields changed: %s", result)
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
