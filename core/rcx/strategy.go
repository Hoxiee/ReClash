package rcx

import (
	"errors"
	"fmt"
	"io"
	"slices"
	"strings"
	"time"

	"go.yaml.in/yaml/v3"
)

const MaxStrategies = 128

type StrategyReport struct {
	Source   string `json:"source,omitempty"`
	Offered  bool   `json:"offered,omitempty"`
	Issue    string `json:"issue,omitempty"`
	Empty    bool   `json:"empty,omitempty"`
	Selected string `json:"selected,omitempty"`
}

type Strategy struct {
	Version int             `yaml:"version"`
	Exclude StrategyMatch   `yaml:"exclude,omitempty"`
	Levels  []StrategyLevel `yaml:"levels"`
}

type StrategyMatch struct {
	Members      []string `yaml:"members,omitempty"`
	NameContains string   `yaml:"name-contains,omitempty"`
	Countries    []string `yaml:"countries,omitempty"`
}

func (m StrategyMatch) Empty() bool {
	return len(m.Members) == 0 && m.NameContains == "" && len(m.Countries) == 0
}

func (m StrategyMatch) Matches(name, country string) bool {
	return (len(m.Members) == 0 || slices.Contains(m.Members, name)) &&
		strings.Contains(name, m.NameContains) &&
		(len(m.Countries) == 0 || slices.Contains(m.Countries, country))
}

type StrategyLevel struct {
	Match       StrategyMatch  `yaml:"match,omitempty"`
	Pick        string         `yaml:"pick"`
	Weights     map[string]int `yaml:"weights,omitempty"`
	ReturnAfter time.Duration  `yaml:"return-after,omitempty"`
	Tolerance   int            `yaml:"tolerance-ms,omitempty"`
}

type LocalStrategyGroup struct {
	IncludeAll bool     `json:"includeAll,omitempty"`
	Members    []string `json:"members,omitempty"`
	Providers  []string `json:"providers,omitempty"`
}

func ParseStrategy(source string) (*Strategy, error) {
	if len(source) > 64<<10 {
		return nil, errors.New("strategy exceeds 64 KiB")
	}
	decoder := yaml.NewDecoder(strings.NewReader(source))
	decoder.KnownFields(true)
	var strategy Strategy
	if err := decoder.Decode(&strategy); err != nil {
		return nil, err
	}
	if err := decoder.Decode(new(yaml.Node)); !errors.Is(err, io.EOF) {
		return nil, errors.New("strategy must contain one YAML document")
	}
	if strategy.Version != 1 {
		return nil, fmt.Errorf("unsupported strategy version %d", strategy.Version)
	}
	if len(strategy.Levels) == 0 || len(strategy.Levels) > 16 {
		return nil, errors.New("strategy needs 1–16 levels")
	}
	if err := strategy.Exclude.validate(); err != nil {
		return nil, fmt.Errorf("exclude: %w", err)
	}
	for i, level := range strategy.Levels {
		if err := level.validate(); err != nil {
			return nil, fmt.Errorf("level %d: %w", i+1, err)
		}
	}
	return &strategy, nil
}

func (m StrategyMatch) validate() error {
	if len(m.Members) > 1024 || len(m.Countries) > 250 || len(m.NameContains) > 256 {
		return errors.New("match exceeds size limits")
	}
	for _, country := range m.Countries {
		if len(country) != 2 || country[0] < 'A' || country[0] > 'Z' || country[1] < 'A' || country[1] > 'Z' {
			return fmt.Errorf("invalid country %q", country)
		}
	}
	return nil
}

func (level StrategyLevel) validate() error {
	switch level.Pick {
	case "manual", "first", "hold", "latency", "round-robin", "weighted", "sticky", "sticky-session":
	default:
		return fmt.Errorf("unknown pick %q", level.Pick)
	}
	if level.ReturnAfter < 0 || level.ReturnAfter > time.Hour {
		return errors.New("return-after must be between 0 and 1h")
	}
	if level.Tolerance < 0 || level.Tolerance > 10000 || level.Tolerance > 0 && level.Pick != "latency" {
		return errors.New("tolerance-ms is only available for latency and must be between 0 and 10000")
	}
	if len(level.Weights) > 1024 || len(level.Weights) > 0 && level.Pick != "weighted" && level.Pick != "sticky" && level.Pick != "sticky-session" {
		return errors.New("weights require a weighted or sticky pick")
	}
	for _, weight := range level.Weights {
		if weight < 1 || weight > 1000 {
			return errors.New("weights must be between 1 and 1000")
		}
	}
	return level.Match.validate()
}

func StrategySource(node yaml.Node) (string, error) {
	if node.Kind == yaml.ScalarNode && node.Tag == "!!str" {
		if strings.TrimSpace(node.Value) == "" {
			return "", errors.New("empty strategy")
		}
		return node.Value, nil
	}
	data, err := yaml.Marshal(&node)
	return string(data), err
}
