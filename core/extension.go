package core

import (
	"core/extensions"

	"github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/log"
	"github.com/metacubex/mihomo/tunnel"
)

var extensionManager = extensions.New(extensions.Config{
	Home: func() string {
		if !isInit.Load() {
			return ""
		}
		return constant.Path.HomeDir()
	},
	Spawn:    safeGo,
	Logf:     logExtension,
	Lookup:   lookupProxy,
	Proxies:  tunnel.AllProxies,
	LogLevel: func() string { return log.Level().String() },
})

func init() {
	extensionManager.Register()
}

func logExtension(level extensions.Level, format string, args ...any) {
	switch level {
	case extensions.LevelDebug:
		log.Debugln(format, args...)
	case extensions.LevelInfo:
		log.Infoln(format, args...)
	case extensions.LevelWarning:
		log.Warnln(format, args...)
	default:
		log.Errorln(format, args...)
	}
}

func handleGetExtensions() []extensions.Installed {
	return extensionManager.List()
}
