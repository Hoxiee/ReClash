// tgrelay drives the Telegram relay without the app, for live measurements on a device.
//
//	tgrelay run [-listen 127.0.0.1:1443] [-secret hex] [-endpoints a,b] [-workers a,b]
//	            [-fake-tls-domain host] [-targets 2:ip,-4:ip] [-proxy-protocol] [-test-dc]
//	tgrelay selftest [-listen addr] -secret hex [-fake-tls-domain host] [-dcs 2,4,-2,-4]
//	tgrelay probe [-dc 2] addr...
package main

import (
	"context"
	"encoding/hex"
	"encoding/json"
	"flag"
	"fmt"
	"log"
	"net"
	"os"
	"os/signal"
	"strconv"
	"strings"
	"syscall"
	"time"

	"core/telegram"
)

func main() {
	if len(os.Args) < 2 {
		log.Fatal("usage: tgrelay run|selftest|probe")
	}
	command, args := os.Args[1], os.Args[2:]
	flags := flag.NewFlagSet(command, flag.ExitOnError)
	listen := flags.String("listen", "127.0.0.1:1443", "listen address")
	secretHex := flags.String("secret", "", "32 hex digits")
	endpoints := flags.String("endpoints", "", "comma-separated addresses")
	workers := flags.String("workers", "", "comma-separated Cloudflare Worker domains")
	fakeTLSDomain := flags.String("fake-tls-domain", "", "FakeTLS masking domain")
	targets := flags.String("targets", "", "dc:host overrides, comma-separated")
	proxyProtocol := flags.Bool("proxy-protocol", false, "read PROXY protocol v1")
	disableSecure := flags.Bool("disable-secure", false, "prefer port 80 for Cloudflare and workers")
	testDC := flags.Bool("test-dc", false, "send every DC to Telegram's test environment")
	every := flags.Duration("every", time.Second, "counter sample interval")
	dcs := flags.String("dcs", "2,4,-2,-4", "DC indexes for selftest")
	dc := flags.Int("dc", 2, "DC for probe")
	_ = flags.Parse(args)

	switch command {
	case "run":
		run(telegram.Config{
			Listen:          *listen,
			Secret:          decodeSecret(*secretHex),
			Endpoints:       splitList(*endpoints),
			CFWorkerDomains: splitList(*workers),
			FakeTLSDomain:   *fakeTLSDomain,
			ProxyProtocol:   *proxyProtocol,
			Targets:         parseTargets(*targets),
			DisableSecure:   *disableSecure,
			TestDC:          *testDC,
			Logf:            log.Printf,
		}, *every)
	case "selftest":
		selfTest(*listen, decodeSecret(*secretHex), *fakeTLSDomain, *dcs)
	case "probe":
		probe(flags.Args(), *dc)
	default:
		log.Fatalf("unknown command %s", command)
	}
}

func splitList(value string) []string {
	if value == "" {
		return nil
	}
	return strings.Split(value, ",")
}

func parseTargets(value string) map[int]string {
	if value == "" {
		return nil
	}
	targets := make(map[int]string)
	for _, entry := range strings.Split(value, ",") {
		number, address, ok := strings.Cut(entry, ":")
		if !ok {
			log.Fatalf("bad target %q, want dc:host", entry)
		}
		dc, err := strconv.Atoi(number)
		if err != nil {
			log.Fatalf("bad target %q: %v", entry, err)
		}
		targets[dc] = address
	}
	return targets
}

func decodeSecret(value string) []byte {
	value = strings.TrimPrefix(value, "dd")
	if strings.HasPrefix(value, "ee") && len(value) >= 34 {
		value = value[2:34]
	}
	secret, err := hex.DecodeString(value)
	if err != nil || len(secret) != 16 {
		log.Fatal("-secret must be 32 hex digits")
	}
	return secret
}

func run(config telegram.Config, every time.Duration) {
	relay, err := telegram.Start(config)
	if err != nil {
		log.Fatal(err)
	}
	log.Printf("listening on port %d", relay.Port())
	sigs := make(chan os.Signal, 1)
	signal.Notify(sigs, os.Interrupt, syscall.SIGTERM)
	ticker := time.NewTicker(every)
	defer ticker.Stop()
	var lastDown, lastUp uint64
	var peak float64
	for {
		select {
		case <-sigs:
			relay.Stop()
			dump(relay.Status())
			return
		case <-ticker.C:
			status := relay.Status()
			down := float64(status.BytesDown-lastDown) / every.Seconds()
			up := float64(status.BytesUp-lastUp) / every.Seconds()
			lastDown, lastUp = status.BytesDown, status.BytesUp
			peak = max(peak, down)
			if down > 0 || up > 0 {
				log.Printf("rate down=%.0fKB/s up=%.0fKB/s peak=%.0fKB/s total down=%d up=%d clients=%d",
					down/1024, up/1024, peak/1024, status.BytesDown, status.BytesUp, status.Clients)
			}
		}
	}
}

func dump(status telegram.Status) {
	encoded, _ := json.MarshalIndent(status, "", "  ")
	fmt.Println(string(encoded))
}

func selfTest(listen string, secret []byte, fakeTLSDomain, dcs string) {
	for _, field := range strings.Split(dcs, ",") {
		index, err := strconv.Atoi(field)
		if err != nil {
			log.Fatal(err)
		}
		ctx, cancel := context.WithTimeout(context.Background(), 25*time.Second)
		var latency time.Duration
		if fakeTLSDomain != "" {
			latency, err = telegram.SelfTestFakeTLS(ctx, listen, secret, int16(index))
		} else {
			latency, err = telegram.SelfTest(ctx, listen, secret, int16(index))
		}
		cancel()
		if err != nil {
			fmt.Printf("dc=%d FAIL: %v\n", index, err)
			continue
		}
		fmt.Printf("dc=%d OK resPQ in %dms\n", index, latency.Milliseconds())
	}
}

func probe(addresses []string, dc int) {
	dial := (&net.Dialer{}).DialContext
	for _, address := range addresses {
		if _, _, err := net.SplitHostPort(address); err != nil {
			address = net.JoinHostPort(address, "443")
		}
		ctx, cancel := context.WithTimeout(context.Background(), 12*time.Second)
		latency, err := telegram.ProbeEndpoint(ctx, dial, nil, address, dc)
		cancel()
		if err != nil {
			fmt.Printf("%s dc=%d FAIL: %v\n", address, dc, err)
			continue
		}
		fmt.Printf("%s dc=%d OK resPQ in %dms\n", address, dc, latency.Milliseconds())
	}
}
