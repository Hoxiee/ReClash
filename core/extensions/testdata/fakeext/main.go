// fakeext is the extension the supervisor tests build and run. Its link picks the behaviour: fake://ok,
// fake://crash, fake://slow-ready, fake://fatal, fake://stubborn (ignores the stop request). A path after the mode
// only makes links distinct. It reaches targets only through the egress it is given.
package main

import (
	"bufio"
	"crypto/rand"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"io"
	"net"
	"net/netip"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"sync"

	"github.com/metacubex/mihomo/component/auth"
	"github.com/metacubex/mihomo/transport/socks5"
)

type egress struct {
	SOCKS5   string `json:"socks5"`
	Username string `json:"username"`
	Password string `json:"password"`
}

type runRequest struct {
	Protocol int    `json:"protocol"`
	Link     string `json:"link"`
	Listen   string `json:"listen"`
	Egress   egress `json:"egress"`
	DataDir  string `json:"dataDir"`
	LogLevel string `json:"logLevel"`
}

func main() {
	switch os.Args[1] {
	case "version":
		emit(map[string]any{"id": "fake", "version": "1.0.0", "protocol": []int{1}})
	case "describe":
		var request struct {
			Links []string `json:"links"`
		}
		_ = json.NewDecoder(os.Stdin).Decode(&request)
		nodes := []map[string]any{}
		for _, link := range request.Links {
			nodes = append(nodes, map[string]any{"name": link, "server": "127.0.0.1", "udp": true, "error": ""})
		}
		emit(map[string]any{"nodes": nodes})
	case "run":
		run()
	}
}

func emit(value any) {
	data, _ := json.Marshal(value)
	fmt.Println(string(data))
}

func run() {
	var request runRequest
	reader := bufio.NewReader(os.Stdin)
	line, err := reader.ReadBytes('\n')
	if err != nil || json.Unmarshal(line, &request) != nil {
		os.Exit(9)
	}
	mode, _, _ := strings.Cut(strings.TrimPrefix(request.Link, "fake://"), "/")
	_ = os.WriteFile(filepath.Join(request.DataDir, "pid"), []byte(strconv.Itoa(os.Getpid())), 0o600)
	if status, err := os.ReadFile("/proc/self/status"); err == nil {
		_ = os.WriteFile(filepath.Join(request.DataDir, "status"), status, 0o600)
	}
	fmt.Fprintf(os.Stderr, "starting %s with egress %s\n", request.Link, request.Egress.Password)

	if mode != "stubborn" {
		go func() {
			_, _ = io.Copy(io.Discard, reader)
			os.Exit(0)
		}()
	}
	switch mode {
	case "crash":
		os.Exit(2)
	case "fatal":
		emit(map[string]any{"event": "fatal", "message": "link: unsupported mode"})
		os.Exit(1)
	case "slow-ready":
		select {}
	}
	front := newFront(request.Egress)
	emit(map[string]any{"event": "ready", "socks5": front.addr, "username": front.user, "password": front.pass, "udp": true})
	select {}
}

type front struct {
	egress     egress
	addr       string
	user, pass string
	udp        *net.UDPConn

	mu     sync.Mutex
	client netip.AddrPort
	relay  *net.UDPConn
}

func newFront(e egress) *front {
	listener, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		os.Exit(3)
	}
	// mihomo's ServerHandshake answers UDP ASSOCIATE with the TCP address, so UDP shares the port.
	udp, err := net.ListenUDP("udp", net.UDPAddrFromAddrPort(listener.Addr().(*net.TCPAddr).AddrPort()))
	if err != nil {
		os.Exit(4)
	}
	f := &front{egress: e, addr: listener.Addr().String(), user: "f-" + token(), pass: token(), udp: udp}
	go f.serveUDP()
	go func() {
		for {
			conn, err := listener.Accept()
			if err != nil {
				return
			}
			go f.handle(conn)
		}
	}()
	return f
}

func token() string {
	buf := make([]byte, 12)
	_, _ = rand.Read(buf)
	return hex.EncodeToString(buf)
}

func (f *front) handle(conn net.Conn) {
	defer conn.Close()
	authenticator := auth.NewAuthenticator([]auth.AuthUser{{User: f.user, Pass: f.pass}})
	target, command, _, err := socks5.ServerHandshake(conn, authenticator)
	if err != nil {
		return
	}
	switch command {
	case socks5.CmdConnect:
		remote, _, err := f.dialEgress(target, socks5.CmdConnect)
		if err != nil {
			return
		}
		defer remote.Close()
		go func() {
			_, _ = io.Copy(remote, conn)
			remote.Close()
		}()
		_, _ = io.Copy(conn, remote)
	case socks5.CmdUDPAssociate:
		control, bound, err := f.dialEgress(socks5.AddrFromStdAddrPort(netip.AddrPortFrom(netip.IPv4Unspecified(), 0)), socks5.CmdUDPAssociate)
		if err != nil {
			return
		}
		defer control.Close()
		relay, err := net.DialUDP("udp", nil, bound.UDPAddr())
		if err != nil {
			return
		}
		defer relay.Close()
		f.mu.Lock()
		f.relay = relay
		f.mu.Unlock()
		go f.fromEgress(relay)
		_, _ = io.Copy(io.Discard, conn)
	}
}

func (f *front) dialEgress(target socks5.Addr, command socks5.Command) (net.Conn, socks5.Addr, error) {
	conn, err := net.Dial("tcp", f.egress.SOCKS5)
	if err != nil {
		return nil, nil, err
	}
	bound, err := socks5.ClientHandshake(conn, target, command, &socks5.User{Username: f.egress.Username, Password: f.egress.Password})
	if err != nil {
		conn.Close()
		return nil, nil, err
	}
	return conn, bound, nil
}

// Packets keep their SOCKS5 UDP header both ways: the front and the egress speak the same encapsulation.
func (f *front) serveUDP() {
	buf := make([]byte, 65535)
	for {
		n, from, err := f.udp.ReadFromUDPAddrPort(buf)
		if err != nil {
			return
		}
		f.mu.Lock()
		f.client = from
		relay := f.relay
		f.mu.Unlock()
		if relay != nil {
			_, _ = relay.Write(buf[:n])
		}
	}
}

func (f *front) fromEgress(relay *net.UDPConn) {
	buf := make([]byte, 65535)
	for {
		n, err := relay.Read(buf)
		if err != nil {
			return
		}
		f.mu.Lock()
		client := f.client
		f.mu.Unlock()
		_, _ = f.udp.WriteToUDPAddrPort(buf[:n], client)
	}
}
