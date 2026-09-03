package main

type rcxMarker struct {
	URL      string
	Statuses []int
}

// A preset is the whole country-specific surface: censorship differs by region,
// and the ranking tables deliberately stay out of it.
type rcxPreset struct {
	Name                string
	CensorCountries     []string
	CanaryForeign       []string
	CanaryDomestic      []string
	OpenMarkers         []rcxMarker
	DomesticMarkers     []rcxMarker
	DomesticRuleClasses []string
	LatencyBands        []int
	DwellSeconds        int
	WaveWidth           int
	ProbeConcurrency    int
	ProbeStaggerMs      int
	LiveWindowSeconds   int
	FreshWindowSeconds  int
	DegradedBandPenalty uint8
}

const (
	rcxPresetOff      = "off"
	rcxPresetRuMobile = "ru-mobile"
	rcxPresetRuHome   = "ru-home"
	rcxPresetIran     = "ir"
	rcxPresetChina    = "cn"
)

// rcxDefaultsVersion migrates shipped defaults into existing installs; without it
// a corrected marker or canary never reaches anyone who already ran the app.
const rcxDefaultsVersion = 1

type rcxConfig struct {
	Enabled                 bool   `json:"on"`
	Preset                  string `json:"preset"`
	DefaultsVersion         int    `json:"dv"`
	AllowDomesticLastResort bool   `json:"dlr"`
	SaveMobileData          bool   `json:"smd"`
	ManualHoldMinutes       int    `json:"mhm"`
}

func rcxDefaultConfig() rcxConfig {
	return rcxConfig{
		Enabled:                 false,
		Preset:                  rcxPresetOff,
		DefaultsVersion:         rcxDefaultsVersion,
		AllowDomesticLastResort: true,
		SaveMobileData:          true,
		ManualHoldMinutes:       60,
	}
}

func rcxBaseTuning() rcxPreset {
	return rcxPreset{
		LatencyBands:        []int{150, 300, 600, 1200},
		DwellSeconds:        90,
		WaveWidth:           12,
		ProbeConcurrency:    2,
		ProbeStaggerMs:      250,
		LiveWindowSeconds:   60,
		FreshWindowSeconds:  1800,
		DegradedBandPenalty: 2,
	}
}

// Canaries are IP literals on purpose: DNS often answers while transit is dead,
// so a hostname would measure the resolver instead of the network.
var rcxPresets = map[string]rcxPreset{
	rcxPresetRuMobile: rcxRuPreset(rcxPresetRuMobile),
	rcxPresetRuHome:   rcxRuPreset(rcxPresetRuHome),
	rcxPresetIran: {
		Name:            rcxPresetIran,
		CensorCountries: []string{"IR"},
		CanaryForeign:   []string{"1.1.1.1:443", "9.9.9.9:443"},
		CanaryDomestic:  []string{"5.200.200.200:443"},
		OpenMarkers: []rcxMarker{
			{URL: "https://www.gstatic.com/generate_204", Statuses: []int{204}},
		},
		DomesticMarkers: []rcxMarker{
			{URL: "https://www.aparat.com/", Statuses: []int{200, 301, 302}},
		},
		DomesticRuleClasses: []string{"geosite:ir", "geoip:ir"},
	},
	rcxPresetChina: {
		Name:            rcxPresetChina,
		CensorCountries: []string{"CN"},
		CanaryForeign:   []string{"1.1.1.1:443", "9.9.9.9:443"},
		CanaryDomestic:  []string{"223.5.5.5:443"},
		OpenMarkers: []rcxMarker{
			{URL: "https://www.gstatic.com/generate_204", Statuses: []int{204}},
		},
		DomesticMarkers: []rcxMarker{
			{URL: "https://www.baidu.com/", Statuses: []int{200, 301, 302}},
		},
		DomesticRuleClasses: []string{"geosite:cn", "geoip:cn"},
	},
}

func rcxRuPreset(name string) rcxPreset {
	preset := rcxPreset{
		Name:            name,
		CensorCountries: []string{"RU"},
		CanaryForeign:   []string{"1.1.1.1:443", "9.9.9.9:443"},
		CanaryDomestic:  []string{"77.88.8.8:443", "213.180.204.242:443"},
		OpenMarkers: []rcxMarker{
			{URL: "https://www.youtube.com/generate_204", Statuses: []int{204}},
			// Kept non-required: api.telegram.org is unreachable from every Russian
			// egress while Telegram itself works, so demanding it would disqualify
			// exactly the nodes the operator lets through.
			{URL: "https://api.telegram.org/", Statuses: []int{200, 404}},
		},
		DomesticMarkers: []rcxMarker{
			{URL: "https://ya.ru/", Statuses: []int{200, 301, 302}},
		},
		DomesticRuleClasses: []string{"geosite:category-ru", "geoip:ru"},
	}
	if name == rcxPresetRuMobile {
		preset.WaveWidth = 6
	}
	return preset
}

func rcxResolvePreset(name string) (rcxPreset, bool) {
	if name == rcxPresetOff || name == "" {
		return rcxPreset{Name: rcxPresetOff}, false
	}
	preset, ok := rcxPresets[name]
	if !ok {
		return rcxPreset{Name: rcxPresetOff}, false
	}
	base := rcxBaseTuning()
	if preset.LatencyBands == nil {
		preset.LatencyBands = base.LatencyBands
	}
	if preset.DwellSeconds == 0 {
		preset.DwellSeconds = base.DwellSeconds
	}
	if preset.WaveWidth == 0 {
		preset.WaveWidth = base.WaveWidth
	}
	if preset.ProbeConcurrency == 0 {
		preset.ProbeConcurrency = base.ProbeConcurrency
	}
	if preset.ProbeStaggerMs == 0 {
		preset.ProbeStaggerMs = base.ProbeStaggerMs
	}
	if preset.LiveWindowSeconds == 0 {
		preset.LiveWindowSeconds = base.LiveWindowSeconds
	}
	if preset.FreshWindowSeconds == 0 {
		preset.FreshWindowSeconds = base.FreshWindowSeconds
	}
	if preset.DegradedBandPenalty == 0 {
		preset.DegradedBandPenalty = base.DegradedBandPenalty
	}
	return preset, true
}

func (p rcxPreset) policy(config rcxConfig) rcxPolicy {
	return rcxPolicy{
		LatencyBands:        p.LatencyBands,
		AllowDomesticLast:   config.AllowDomesticLastResort,
		DwellSeconds:        p.DwellSeconds,
		DegradedBandPenalty: p.DegradedBandPenalty,
	}
}

func (p rcxPreset) censors(countryCode string) bool {
	for _, code := range p.CensorCountries {
		if code == countryCode {
			return true
		}
	}
	return false
}
