package sitelock

import (
	"net"
	"slices"
	"strconv"
	"strings"

	C "github.com/metacubex/mihomo/constant"
)

// Candidate is a server the config can offer as an exit; proxies with one
// definition under several names are one candidate.
type Candidate struct {
	Exit
	Names []string `json:"names"`
}

func Candidates(all map[string]C.Proxy) []Candidate {
	byExit := map[Exit][]string{}
	for name, proxy := range all {
		if proxy.Type() < C.Shadowsocks {
			continue
		}
		host, port, err := net.SplitHostPort(proxy.Addr())
		number, convErr := strconv.Atoi(port)
		if err != nil || convErr != nil || host == "" {
			continue
		}
		exit := Exit{
			Type:   normalType(proxy.Type().String()),
			Server: strings.ToLower(host),
			Port:   number,
			Route:  routeOf(proxy),
		}
		byExit[exit] = append(byExit[exit], name)
	}
	found := make([]Candidate, 0, len(byExit))
	for exit, names := range byExit {
		slices.Sort(names)
		exit.Name = names[0]
		found = append(found, Candidate{Exit: exit, Names: names})
	}
	slices.SortFunc(found, func(a, b Candidate) int { return strings.Compare(a.Names[0], b.Names[0]) })
	return found
}
