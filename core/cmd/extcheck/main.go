// extcheck loads a mihomo YAML with extension nodes outside the app and delay-tests its proxies, printing what the
// extension supervisor does. It opens no inbound listener except the loopback egress the extensions dial through.
//
//	extcheck -home <dir> -config <file.yaml> [-url URL] [-timeout 10s] [-proxy a,b] [-rounds 1]
//
// -home holds extensions/<id>/<version>/; use a directory of its own, never the app's home.
package main

import (
	"context"
	"flag"
	"fmt"
	"os"
	"os/signal"
	"path/filepath"
	"strings"
	"syscall"
	"time"

	"core/extensions"

	"github.com/metacubex/mihomo/config"
	C "github.com/metacubex/mihomo/constant"
	// config.ParseRawConfig links against a function the executor provides.
	_ "github.com/metacubex/mihomo/hub/executor"
)

var levelNames = map[extensions.Level]string{
	extensions.LevelDebug:   "debug",
	extensions.LevelInfo:    "info",
	extensions.LevelWarning: "warn",
	extensions.LevelError:   "error",
}

func main() {
	home := flag.String("home", "", "directory with extensions/<id>/<version>/ (required)")
	configPath := flag.String("config", "", "mihomo YAML with the nodes to test (required)")
	url := flag.String("url", "https://www.gstatic.com/generate_204", "delay test URL")
	timeout := flag.Duration("timeout", 20*time.Second, "timeout of one delay test, including the extension start")
	only := flag.String("proxy", "", "comma-separated proxy names; default: every entry of proxies")
	rounds := flag.Int("rounds", 1, "delay tests per proxy")
	flag.Parse()
	if *home == "" || *configPath == "" {
		flag.Usage()
		os.Exit(2)
	}
	os.Exit(run(*home, *configPath, *url, *timeout, *only, *rounds))
}

func logf(level extensions.Level, format string, args ...any) {
	fmt.Fprintf(os.Stderr, "%s %-5s %s\n", time.Now().Format("15:04:05.000"), levelNames[level], fmt.Sprintf(format, args...))
}

func run(home, configPath, url string, timeout time.Duration, only string, rounds int) int {
	home, err := filepath.Abs(home)
	if err != nil {
		logf(extensions.LevelError, "%v", err)
		return 2
	}
	C.SetHomeDir(home)
	data, err := os.ReadFile(configPath)
	if err != nil {
		logf(extensions.LevelError, "%v", err)
		return 2
	}
	var proxies map[string]C.Proxy
	manager := extensions.New(extensions.Config{
		Home:     func() string { return home },
		Logf:     logf,
		Lookup:   func(name string) C.Proxy { return proxies[name] },
		LogLevel: func() string { return "debug" },
	})
	manager.Register()
	defer manager.StopAll()

	raw, err := config.UnmarshalRawConfig(data)
	if err != nil {
		logf(extensions.LevelError, "config: %v", err)
		return 2
	}
	parsed, err := config.ParseRawConfig(raw)
	if err != nil {
		logf(extensions.LevelError, "config: %v", err)
		return 2
	}
	proxies = parsed.Proxies

	names := splitNames(only)
	if len(names) == 0 {
		for _, mapping := range raw.Proxy {
			if name, ok := mapping["name"].(string); ok {
				names = append(names, name)
			}
		}
	}
	for _, entry := range manager.List() {
		logf(extensions.LevelInfo, "installed %s %s verified=%t %s", entry.ID, entry.Version, entry.Verified, entry.LastError)
	}

	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()
	failed := 0
	for round := 1; round <= rounds; round++ {
		for _, name := range names {
			proxy := proxies[name]
			if proxy == nil {
				fmt.Printf("%-32s missing from the config\n", name)
				failed++
				continue
			}
			testCtx, cancel := context.WithTimeout(ctx, timeout)
			delay, err := proxy.URLTest(testCtx, url, nil)
			cancel()
			if err != nil {
				fmt.Printf("%-32s %-10s round %d: FAIL %v\n", name, proxy.Type(), round, err)
				failed++
			} else {
				fmt.Printf("%-32s %-10s round %d: %d ms\n", name, proxy.Type(), round, delay)
			}
			if ctx.Err() != nil {
				return 130
			}
		}
	}
	if failed > 0 {
		return 1
	}
	return 0
}

func splitNames(value string) []string {
	var names []string
	for _, name := range strings.Split(value, ",") {
		if name = strings.TrimSpace(name); name != "" {
			names = append(names, name)
		}
	}
	return names
}
