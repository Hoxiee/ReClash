package core

import (
	"os"
	"runtime"
	"time"

	"github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/constant/features"
	"github.com/metacubex/mihomo/listener"
)

type CoreInfo struct {
	Version          string     `json:"version"`
	GoVersion        string     `json:"goVersion"`
	Platform         string     `json:"platform"`
	Architecture     string     `json:"architecture"`
	BuildTime        *time.Time `json:"buildTime"`
	Tags             []string   `json:"tags"`
	WorkingDirectory string     `json:"workingDirectory"`
	ExecutablePath   string     `json:"executablePath"`
	TunActive        bool       `json:"tunActive"`
}

func handleGetCoreInfo() CoreInfo {
	info := CoreInfo{
		Version:      constant.Version,
		GoVersion:    runtime.Version(),
		Platform:     runtime.GOOS,
		Architecture: runtime.GOARCH,
		BuildTime:    coreBuildTime(constant.BuildTime),
		Tags:         append([]string{}, features.Tags()...),
	}
	if !features.Android {
		info.ExecutablePath, _ = os.Executable()
	}
	configMu.Lock()
	info.TunActive = !features.Android && isRunning.Load() && listener.GetTunConf().Enable
	if isInit.Load() {
		info.WorkingDirectory = constant.Path.HomeDir()
	}
	configMu.Unlock()
	return info
}

func coreBuildTime(value string) *time.Time {
	parsed, err := time.Parse(time.RFC3339Nano, value)
	if err != nil {
		return nil
	}
	utc := parsed.UTC()
	return &utc
}
