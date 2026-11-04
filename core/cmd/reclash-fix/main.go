// Command reclash-fix signs ReClash support fix links for VPN providers.
package main

import (
	"bytes"
	"crypto/ed25519"
	"crypto/rand"
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"io"
	"os"
	"strings"
	"time"
)

const usage = `usage: reclash-fix <command> [flags]

  keygen [-out key.txt]            new key; prints header line and kid
  header -key key.txt              print the reclash-support-key header line
  sign -key key.txt -report RC-XXXX-XXXX [-ttl 48h] <action>...
                                   print a link (ttl <= 168h)
  verify -header 'ed25519:...' <link>

actions: profile.update profile.activate proxy.select:group=G,node=N
  connections.reset core.restart overrides.reset config.freePort
  config.ruleMode dns.ignoreSystemHosts proxy.clearOwn
  tunnel.freeDeviceName tunnel.restart
`

func main() {
	if err := run(os.Args[1:], os.Stdout, os.Stderr); err != nil {
		if !errors.Is(err, flag.ErrHelp) {
			fmt.Fprintln(os.Stderr, "reclash-fix:", err)
		}
		os.Exit(1)
	}
}

func run(args []string, out, errw io.Writer) error {
	if len(args) == 0 {
		fmt.Fprint(errw, usage)
		return errors.New("missing command")
	}
	fs := flag.NewFlagSet(args[0], flag.ContinueOnError)
	fs.SetOutput(errw)
	fs.Usage = func() { fmt.Fprint(errw, usage) }
	switch args[0] {
	case "-h", "-help", "--help", "help":
		fmt.Fprint(errw, usage)
		return nil
	case "keygen":
		path := fs.String("out", "key.txt", "private key file")
		if err := fs.Parse(args[1:]); err != nil {
			return err
		}
		_, priv, err := ed25519.GenerateKey(rand.Reader)
		if err != nil {
			return err
		}
		f, err := os.OpenFile(*path, os.O_WRONLY|os.O_CREATE|os.O_EXCL, 0o600)
		if err != nil {
			return err
		}
		_, err = f.WriteString(enc.EncodeToString(priv) + "\n")
		if cerr := f.Close(); err == nil {
			err = cerr
		}
		if err != nil {
			return err
		}
		pub := priv.Public().(ed25519.PublicKey)
		fmt.Fprintf(out, "reclash-support-key: %s\nkid: %s\n", headerValue(pub), keyID(pub))
		return nil
	case "header":
		path := fs.String("key", "", "private key file")
		if err := fs.Parse(args[1:]); err != nil {
			return err
		}
		priv, err := readKey(*path)
		if err != nil {
			return err
		}
		fmt.Fprintf(out, "reclash-support-key: %s\n", headerValue(priv.Public().(ed25519.PublicKey)))
		return nil
	case "sign":
		path := fs.String("key", "", "private key file")
		rid := fs.String("report", "", "report id")
		ttl := fs.Duration("ttl", 48*time.Hour, "validity")
		if err := fs.Parse(args[1:]); err != nil {
			return err
		}
		priv, err := readKey(*path)
		if err != nil {
			return err
		}
		link, exp, err := sign(priv, *rid, *ttl, fs.Args())
		if err != nil {
			return err
		}
		fmt.Fprintln(out, link)
		fmt.Fprintf(errw, "expires %s\n", exp.UTC().Format(time.RFC3339))
		return nil
	case "verify":
		header := fs.String("header", "", "ed25519:<key>[,<key>]")
		if err := fs.Parse(args[1:]); err != nil {
			return err
		}
		if fs.NArg() != 1 {
			return errors.New("verify takes one link")
		}
		p, raw, err := verifyLink(*header, fs.Arg(0))
		if raw != nil {
			var b bytes.Buffer
			if json.Indent(&b, raw, "", "  ") == nil {
				fmt.Fprintln(out, b.String())
			}
		}
		if err != nil {
			fmt.Fprintln(out, "invalid:", err)
			return errors.New("verification failed")
		}
		exp := time.Unix(p.Exp, 0).UTC()
		if time.Now().After(exp) {
			fmt.Fprintln(out, "valid signature, but expired", exp.Format(time.RFC3339))
			return nil
		}
		fmt.Fprintln(out, "valid, expires", exp.Format(time.RFC3339))
		return nil
	}
	fmt.Fprint(errw, usage)
	return fmt.Errorf("unknown command %q", args[0])
}

func readKey(path string) (ed25519.PrivateKey, error) {
	if path == "" {
		return nil, errors.New("-key is required")
	}
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}
	b, err := enc.DecodeString(strings.TrimSpace(string(data)))
	if err != nil || len(b) != ed25519.PrivateKeySize {
		return nil, errors.New("key file is not a base64url 64-byte ed25519 private key")
	}
	return ed25519.PrivateKey(b), nil
}
