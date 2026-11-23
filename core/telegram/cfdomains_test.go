package telegram

import (
	"context"
	"errors"
	"slices"
	"testing"
)

func TestDecodeCFDomain(t *testing.T) {
	if got := decodeCFDomain("virkgj.com"); got != "pclead.co.uk" {
		t.Fatalf("got %s", got)
	}
	if got := decodeCFDomain("plain.co.uk"); got != "plain.co.uk" {
		t.Fatalf("got %s", got)
	}
	for _, d := range builtinCFDomains {
		if !validHostname(d) {
			t.Fatalf("builtin %s is not a hostname", d)
		}
	}
	if len(builtinCFDomains) != 20 {
		t.Fatalf("%d built-in domains", len(builtinCFDomains))
	}
}

func TestParseCFDomainsSkipsCommentsAndJunk(t *testing.T) {
	body := "# list\n\nvirkgj.com\n// note\nplain.co.uk\nnot a host.co.uk\nexample.org\nvmmzovy.com\n"
	want := []string{"pclead.co.uk", "plain.co.uk", "offshor.co.uk"}
	if got := parseCFDomains(body); !slices.Equal(got, want) {
		t.Fatalf("got %v", got)
	}
}

func TestCFListMergesUserThenRefreshedThenBuiltin(t *testing.T) {
	var l cfList
	l.setUser([]string{" Mine.Example.org. ", "pclead.co.uk", "bad host"})
	if err := l.refresh(context.Background(), func(context.Context) (string, error) {
		return "fresh1.co.uk\nfresh2.co.uk\nmine.example.org\nfresh3.co.uk\n", nil
	}); err != nil {
		t.Fatal(err)
	}
	got := l.ordered()
	head := []string{"mine.example.org", "pclead.co.uk", "fresh1.co.uk", "fresh2.co.uk", "fresh3.co.uk"}
	if !slices.Equal(got[:5], head) {
		t.Fatalf("head %v", got[:5])
	}
	if len(got) != 5+len(builtinCFDomains)-1 {
		t.Fatalf("duplicates in %v", got)
	}
	l.markGood(0, "fresh2.co.uk")
	if l.ordered()[0] != "fresh2.co.uk" {
		t.Fatal("last good base is not first")
	}
}

func TestCFListKeepsTheLastGoodRefresh(t *testing.T) {
	var l cfList
	ok := func(context.Context) (string, error) { return "a1.co.uk\na2.co.uk\na3.co.uk\n", nil }
	if err := l.refresh(context.Background(), ok); err != nil {
		t.Fatal(err)
	}
	failures := []CFFetchFunc{
		func(context.Context) (string, error) { return "", errors.New("offline") },
		func(context.Context) (string, error) { return "a1.co.uk\n", nil },
		func(context.Context) (string, error) { return "garbage", nil },
	}
	for _, fetch := range failures {
		if err := l.refresh(context.Background(), fetch); err == nil {
			t.Fatal("a bad refresh succeeded")
		}
	}
	if got := l.ordered(); got[0] != "a1.co.uk" || got[2] != "a3.co.uk" {
		t.Fatalf("last good list lost: %v", got)
	}
}
