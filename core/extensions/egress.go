package extensions

import (
	"context"
	"crypto/rand"
	"crypto/subtle"
	"encoding/base64"
	"errors"
	"fmt"
	"io"
	"net"
	"net/netip"
	"slices"
	"strconv"
	"sync"
	"time"

	N "github.com/metacubex/mihomo/common/net"
	"github.com/metacubex/mihomo/component/dialer"
	"github.com/metacubex/mihomo/component/proxydialer"
	"github.com/metacubex/mihomo/component/resolver"
	C "github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/transport/socks5"
)

const (
	egressHandshakeTimeout = 10 * time.Second
	egressResolveTimeout   = 5 * time.Second
	udpBufferSize          = 64 << 10
	maxUDPDestinations     = 1024
)

// egressIdentity is what one process may do through the egress: its node's dial options and dialer-proxy.
type egressIdentity struct {
	password    string
	key         string
	options     []dialer.Option
	dialerProxy string
}

// egressServer is the loopback SOCKS5 endpoint every extension process sends its protocol traffic through. One
// listener serves all processes; the credentials say which node is dialing.
type egressServer struct {
	m        *Manager
	listener net.Listener

	mu    sync.Mutex
	users map[string]*egressIdentity
}

func newEgressServer(m *Manager) (*egressServer, error) {
	listener, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		return nil, err
	}
	e := &egressServer{m: m, listener: listener, users: map[string]*egressIdentity{}}
	m.cfg.Spawn("extension egress", e.serve)
	return e, nil
}

func (e *egressServer) addr() string {
	return e.listener.Addr().String()
}

func (e *egressServer) close() {
	_ = e.listener.Close()
}

func (e *egressServer) add(identity *egressIdentity) Egress {
	e.mu.Lock()
	defer e.mu.Unlock()
	for {
		user := "e-" + randomToken(6)
		if _, taken := e.users[user]; taken {
			continue
		}
		identity.password = randomToken(24)
		e.users[user] = identity
		return Egress{SOCKS5: e.addr(), Username: user, Password: identity.password}
	}
}

func (e *egressServer) remove(user string) {
	e.mu.Lock()
	defer e.mu.Unlock()
	delete(e.users, user)
}

func (e *egressServer) verify(user, password string) *egressIdentity {
	e.mu.Lock()
	defer e.mu.Unlock()
	identity := e.users[user]
	if identity == nil || subtle.ConstantTimeCompare([]byte(identity.password), []byte(password)) != 1 {
		return nil
	}
	return identity
}

func (e *egressServer) serve() {
	for {
		conn, err := e.listener.Accept()
		if err != nil {
			if errors.Is(err, net.ErrClosed) {
				return
			}
			continue
		}
		e.m.cfg.Spawn("extension egress conn", func() { e.handle(conn) })
	}
}

func (e *egressServer) handle(conn net.Conn) {
	defer conn.Close()
	_ = conn.SetDeadline(time.Now().Add(egressHandshakeTimeout))
	identity, command, target, err := e.handshake(conn)
	if err != nil {
		return
	}
	_ = conn.SetDeadline(time.Time{})
	switch command {
	case socks5.CmdConnect:
		e.connect(conn, identity, target)
	case socks5.CmdUDPAssociate:
		e.associate(conn, identity)
	default:
		_ = writeReply(conn, socks5.ErrCommandNotSupported, nil)
	}
}

// handshake is RFC 1928 with RFC 1929 auth only. mihomo's ServerHandshake answers before the dial and puts its
// TCP address in the UDP ASSOCIATE reply, and the egress needs to do neither.
func (e *egressServer) handshake(conn net.Conn) (*egressIdentity, socks5.Command, socks5.Addr, error) {
	buf := make([]byte, socks5.MaxAddrLen)
	if _, err := io.ReadFull(conn, buf[:2]); err != nil {
		return nil, 0, nil, err
	}
	if buf[0] != 5 {
		return nil, 0, nil, errors.New("not SOCKS5")
	}
	methods := buf[:buf[1]]
	if _, err := io.ReadFull(conn, methods); err != nil {
		return nil, 0, nil, err
	}
	if !slices.Contains(methods, 2) {
		_, _ = conn.Write([]byte{5, 0xff})
		return nil, 0, nil, socks5.ErrAuth
	}
	if _, err := conn.Write([]byte{5, 2}); err != nil {
		return nil, 0, nil, err
	}
	user, err := readAuthField(conn, true)
	if err != nil {
		return nil, 0, nil, err
	}
	password, err := readAuthField(conn, false)
	if err != nil {
		return nil, 0, nil, err
	}
	identity := e.verify(user, password)
	if identity == nil {
		_, _ = conn.Write([]byte{1, 1})
		return nil, 0, nil, socks5.ErrAuth
	}
	if _, err := conn.Write([]byte{1, 0}); err != nil {
		return nil, 0, nil, err
	}
	if _, err := io.ReadFull(conn, buf[:3]); err != nil {
		return nil, 0, nil, err
	}
	command := buf[1]
	target, err := socks5.ReadAddr(conn, buf)
	if err != nil {
		_ = writeReply(conn, socks5.ErrAddressNotSupported, nil)
		return nil, 0, nil, err
	}
	return identity, command, target, nil
}

// readAuthField reads the RFC 1929 VER+ULEN+UNAME (withVersion) or PLEN+PASSWD part.
func readAuthField(conn net.Conn, withVersion bool) (string, error) {
	header := make([]byte, 2)
	if !withVersion {
		header = header[:1]
	}
	if _, err := io.ReadFull(conn, header); err != nil {
		return "", err
	}
	value := make([]byte, header[len(header)-1])
	if _, err := io.ReadFull(conn, value); err != nil {
		return "", err
	}
	return string(value), nil
}

func writeReply(conn net.Conn, code socks5.Error, bound socks5.Addr) error {
	if bound == nil {
		bound = socks5.AddrFromStdAddrPort(netip.AddrPortFrom(netip.IPv4Unspecified(), 0))
	}
	_, err := conn.Write(append([]byte{5, byte(code), 0}, bound...))
	return err
}

func (e *egressServer) dialer(identity *egressIdentity) (C.Dialer, error) {
	if identity.dialerProxy == "" {
		return dialer.NewDialer(identity.options...), nil
	}
	var proxy C.Proxy
	if e.m.cfg.Lookup != nil {
		proxy = e.m.cfg.Lookup(identity.dialerProxy)
	}
	if proxy == nil {
		return nil, fmt.Errorf("dialer-proxy %s not found", identity.dialerProxy)
	}
	if reachesKey(proxy, identity.key) {
		return nil, fmt.Errorf("%w: dialer-proxy %s leads back to the extension node", proxydialer.ErrDialerLoop, identity.dialerProxy)
	}
	return proxydialer.New(proxy, true), nil
}

// reachesKey follows the current selection of nested groups down to the leaf.
func reachesKey(proxy C.Proxy, key string) bool {
	metadata := &C.Metadata{NetWork: C.TCP}
	for range 16 {
		if proxy == nil {
			return false
		}
		if a, ok := unwrapAdapter(proxy); ok && a.key == key {
			return true
		}
		proxy = proxy.Unwrap(metadata, false)
	}
	return false
}

// target turns a requested address into what mihomo should dial. The extension resolves names with the system
// resolver, which under TUN with fake-ip answers from the fake range; dialing that address would come straight
// back into the TUN.
func (e *egressServer) target(addr socks5.Addr) string {
	text := addr.String()
	ap, err := netip.ParseAddrPort(text)
	if err != nil {
		return text
	}
	if host, ok := e.m.hostByFakeIP(ap.Addr().Unmap()); ok {
		return net.JoinHostPort(host, strconv.Itoa(int(ap.Port())))
	}
	return text
}

func (e *egressServer) connect(conn net.Conn, identity *egressIdentity, addr socks5.Addr) {
	d, err := e.dialer(identity)
	if err != nil {
		_ = writeReply(conn, socks5.ErrGeneralFailure, nil)
		return
	}
	ctx, cancel := context.WithTimeout(context.Background(), C.DefaultTCPTimeout)
	remote, err := d.DialContext(ctx, "tcp", e.target(addr))
	cancel()
	if err != nil {
		e.m.logf(LevelDebug, "egress dial %s failed: %v", addr, err)
		_ = writeReply(conn, socks5.ErrHostUnreachable, nil)
		return
	}
	defer remote.Close()
	if writeReply(conn, 0, nil) != nil {
		return
	}
	N.Relay(conn, remote)
}

func (e *egressServer) associate(control net.Conn, identity *egressIdentity) {
	local, err := net.ListenUDP("udp", &net.UDPAddr{IP: net.IPv4(127, 0, 0, 1)})
	if err != nil {
		_ = writeReply(control, socks5.ErrGeneralFailure, nil)
		return
	}
	relay := &udpRelay{e: e, identity: identity, local: local, sent: map[netip.AddrPort]socks5.Addr{}}
	defer relay.close()
	bound := socks5.AddrFromStdAddrPort(local.LocalAddr().(*net.UDPAddr).AddrPort())
	if writeReply(control, 0, bound) != nil {
		return
	}
	e.m.cfg.Spawn("extension egress udp", relay.fromClient)
	// RFC 1928: the association ends with the TCP connection it arrived on.
	_, _ = io.Copy(io.Discard, control)
}

type udpRelay struct {
	e        *egressServer
	identity *egressIdentity
	local    *net.UDPConn

	mu     sync.Mutex
	client netip.AddrPort
	remote net.PacketConn
	sent   map[netip.AddrPort]socks5.Addr
	closed bool
}

func (r *udpRelay) close() {
	r.mu.Lock()
	r.closed = true
	remote := r.remote
	r.mu.Unlock()
	_ = r.local.Close()
	if remote != nil {
		_ = remote.Close()
	}
}

func (r *udpRelay) fromClient() {
	buf := make([]byte, udpBufferSize)
	for {
		n, from, err := r.local.ReadFromUDPAddrPort(buf)
		if err != nil {
			return
		}
		if !from.Addr().Unmap().IsLoopback() || !r.claim(from) {
			continue
		}
		addr, payload, err := socks5.DecodeUDPPacket(buf[:n])
		if err != nil {
			continue
		}
		destination, err := r.resolve(addr)
		if err != nil {
			continue
		}
		remote, err := r.remoteFor(destination)
		if err != nil {
			r.e.m.logf(LevelDebug, "egress udp to %s failed: %v", addr, err)
			continue
		}
		r.mu.Lock()
		if len(r.sent) >= maxUDPDestinations {
			clear(r.sent)
		}
		r.sent[destination] = addr
		r.mu.Unlock()
		_, _ = remote.WriteTo(payload, net.UDPAddrFromAddrPort(destination))
	}
}

// claim binds the association to the first loopback sender, so another local process cannot inject into it.
func (r *udpRelay) claim(from netip.AddrPort) bool {
	r.mu.Lock()
	defer r.mu.Unlock()
	if !r.client.IsValid() {
		r.client = from
	}
	return r.client == from
}

func (r *udpRelay) resolve(addr socks5.Addr) (netip.AddrPort, error) {
	host, portText, err := net.SplitHostPort(r.e.target(addr))
	if err != nil {
		return netip.AddrPort{}, err
	}
	port, err := strconv.ParseUint(portText, 10, 16)
	if err != nil {
		return netip.AddrPort{}, err
	}
	ip, err := netip.ParseAddr(host)
	if err != nil {
		ctx, cancel := context.WithTimeout(context.Background(), egressResolveTimeout)
		ip, err = resolver.ResolveIP(ctx, host)
		cancel()
		if err != nil {
			return netip.AddrPort{}, err
		}
	}
	return netip.AddrPortFrom(ip.Unmap(), uint16(port)), nil
}

func (r *udpRelay) remoteFor(destination netip.AddrPort) (net.PacketConn, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	if r.closed {
		return nil, net.ErrClosed
	}
	if r.remote != nil {
		return r.remote, nil
	}
	d, err := r.e.dialer(r.identity)
	if err != nil {
		return nil, err
	}
	remote, err := d.ListenPacket(context.Background(), "udp", "", destination)
	if err != nil {
		return nil, err
	}
	r.remote = remote
	r.e.m.cfg.Spawn("extension egress udp reply", func() { r.toClient(remote) })
	return remote, nil
}

func (r *udpRelay) toClient(remote net.PacketConn) {
	buf := make([]byte, udpBufferSize)
	for {
		n, from, err := remote.ReadFrom(buf)
		if err != nil {
			return
		}
		source := socks5.ParseAddrToSocksAddr(from)
		if udp, ok := from.(*net.UDPAddr); ok {
			r.mu.Lock()
			if original, ok := r.sent[netip.AddrPortFrom(udp.AddrPort().Addr().Unmap(), udp.AddrPort().Port())]; ok {
				source = original
			}
			r.mu.Unlock()
		}
		packet, err := socks5.EncodeUDPPacket(source, buf[:n])
		if err != nil {
			continue
		}
		r.mu.Lock()
		client := r.client
		r.mu.Unlock()
		_, _ = r.local.WriteToUDPAddrPort(packet, client)
	}
}

func randomToken(size int) string {
	buf := make([]byte, size)
	_, _ = rand.Read(buf)
	return base64.RawURLEncoding.EncodeToString(buf)
}
