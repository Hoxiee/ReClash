package extensions

import (
	"context"
	"fmt"
	"reflect"

	"github.com/metacubex/mihomo/adapter/outbound"
	"github.com/metacubex/mihomo/common/structure"
	C "github.com/metacubex/mihomo/constant"
)

type nodeOption struct {
	outbound.BasicOption
	Name      string `proxy:"name"`
	Extension string `proxy:"extension,omitempty"`
	Link      string `proxy:"link,omitempty"`
	UDP       bool   `proxy:"udp,omitempty"`
}

// Adapter is the mihomo outbound of an extension node. It always parses; a node that cannot run answers every
// dial with the reason instead, so a profile loads before and after its extension is installed.
type Adapter struct {
	*outbound.Base
	m           *Manager
	id          string
	link        string
	key         string
	dialerProxy string
	invalid     string
}

func (m *Manager) parse(mapping map[string]any, basic outbound.BasicOption) (outbound.ProxyAdapter, error) {
	decoder := structure.NewDecoder(structure.Option{TagName: "proxy", WeaklyTypedInput: true, KeyReplacer: structure.DefaultKeyReplacer})
	option := nodeOption{BasicOption: basic}
	if err := decoder.Decode(mapping, &option); err != nil {
		return nil, err
	}
	a := &Adapter{
		Base: outbound.NewBase(outbound.BaseOption{
			Name:         option.Name,
			Type:         C.Extension,
			ProviderName: option.ProviderName,
			Diversity:    option.Diversity,
			UDP:          option.UDP,
			TFO:          option.TFO,
			MPTCP:        option.MPTCP,
			Interface:    option.Interface,
			RoutingMark:  option.RoutingMark,
			Prefer:       option.IPVersion,
		}),
		m:           m,
		id:          option.Extension,
		link:        option.Link,
		dialerProxy: option.DialerProxy,
	}
	switch {
	case a.id == "":
		a.invalid = "the node names no extension"
	case !validID.MatchString(a.id):
		a.invalid = "invalid extension id"
	case a.link == "":
		a.invalid = "the node has no link"
	}
	a.key = fmt.Sprintf("%s\x00%s\x00%s|%s|%d|%d|%t|%t", a.id, a.link, option.DialerProxy, option.Interface,
		option.RoutingMark, option.IPVersion, option.TFO, option.MPTCP)
	if a.invalid == "" {
		m.mu.Lock()
		m.seen[a.key] = struct{}{}
		m.mu.Unlock()
	}
	return a, nil
}

func (a *Adapter) DialContext(ctx context.Context, metadata *C.Metadata) (C.Conn, error) {
	front, err := a.front(ctx)
	if err != nil {
		return nil, err
	}
	return front.DialContext(ctx, metadata)
}

func (a *Adapter) ListenPacketContext(ctx context.Context, metadata *C.Metadata) (C.PacketConn, error) {
	if !a.SupportUDP() {
		return nil, C.ErrNotSupport
	}
	p, err := a.m.acquire(ctx, a)
	if err != nil {
		return nil, err
	}
	if !p.udp() {
		return nil, fmt.Errorf("extension %s does not serve UDP for this node", a.id)
	}
	front, err := p.frontFor(a.Name())
	if err != nil {
		return nil, err
	}
	return front.ListenPacketContext(ctx, metadata)
}

func (a *Adapter) front(ctx context.Context) (*outbound.Socks5, error) {
	p, err := a.m.acquire(ctx, a)
	if err != nil {
		return nil, err
	}
	return p.frontFor(a.Name())
}

func (a *Adapter) ProxyInfo() C.ProxyInfo {
	info := a.Base.ProxyInfo()
	info.DialerProxy = a.dialerProxy
	return info
}

// unwrapAdapter finds the Adapter inside a tunnel proxy. mihomo wraps parsed adapters in types of its own that
// embed the wrapped one as an exported ProxyAdapter field but have no accessor for it.
func unwrapAdapter(proxy C.Proxy) (*Adapter, bool) {
	if proxy == nil || proxy.Type() != C.Extension {
		return nil, false
	}
	var current any = proxy
	for range 4 {
		switch value := current.(type) {
		case *Adapter:
			return value, true
		case interface{ Adapter() C.ProxyAdapter }:
			current = value.Adapter()
			continue
		}
		v := reflect.ValueOf(current)
		if v.Kind() != reflect.Pointer || v.Elem().Kind() != reflect.Struct {
			return nil, false
		}
		field := v.Elem().FieldByName("ProxyAdapter")
		if !field.IsValid() || !field.CanInterface() {
			return nil, false
		}
		current = field.Interface()
	}
	return nil, false
}
