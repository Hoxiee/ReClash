package core

import (
	"github.com/metacubex/mihomo/constant"
)

func activeNotificationServer(name string, proxies map[string]constant.Proxy) string {
	seen := make(map[string]bool)
	for depth := 0; depth < 32; depth++ {
		if name == "" || seen[name] {
			return ""
		}
		seen[name] = true
		proxy := proxies[name]
		if proxy == nil {
			return ""
		}
		if scripted := scriptedGroupOf(proxy); scripted != nil && scripted.state.Load() != nil {
			if selected := scripted.Now(); selected != "" {
				name = selected
				continue
			}
			return name
		}
		group, ok := proxyGroupOf(proxy)
		if !ok {
			return name
		}
		if proxy.Type() == constant.LoadBalance || proxy.Type() == constant.Relay {
			return name
		}
		name = group.Now()
	}
	return ""
}
