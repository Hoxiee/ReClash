package tun

import "testing"

func TestParseOptionsEmptyIsZeroValue(t *testing.T) {
	for _, raw := range []string{"", "   ", "\n\t"} {
		opts, err := ParseOptions(raw)
		if err != nil {
			t.Fatalf("ParseOptions(%q) error: %v", raw, err)
		}
		if opts.MTU != 0 || opts.CongestionController != "" {
			t.Fatalf("ParseOptions(%q) = %+v, want zero value", raw, opts)
		}
	}
}

func TestParseOptionsDecodesPayload(t *testing.T) {
	opts, err := ParseOptions(`{"mtu":1500,"congestion-controller":"bbr3"}`)
	if err != nil {
		t.Fatalf("ParseOptions error: %v", err)
	}
	if opts.MTU != 1500 {
		t.Errorf("MTU = %d, want 1500", opts.MTU)
	}
	if opts.CongestionController != "bbr3" {
		t.Errorf("CongestionController = %q, want bbr3", opts.CongestionController)
	}
}

func TestParseOptionsRejectsMalformedPayload(t *testing.T) {
	opts, err := ParseOptions(`{"mtu":`)
	if err == nil {
		t.Fatal("ParseOptions accepted a malformed payload")
	}
	if opts != (Options{}) {
		t.Errorf("Options = %+v, want zero value on error", opts)
	}
}

func TestNormalizedMTU(t *testing.T) {
	cases := []struct {
		in   uint32
		want uint32
	}{
		{0, 1500},
		{1279, 1280},
		{1280, 1280},
		{1500, 1500},
		{9000, 9000},
		{65535, 65535},
		{70000, 65535},
	}
	for _, c := range cases {
		got := Options{MTU: c.in}.NormalizedMTU()
		if got != c.want {
			t.Errorf("NormalizedMTU(%d) = %d, want %d", c.in, got, c.want)
		}
	}
}
