package rcx

import (
	"bytes"
	"fmt"
	"reflect"
	"sort"
	"strings"

	yaml "go.yaml.in/yaml/v3"
)

type rcxSettingsPatch struct {
	value  rcxConfig
	fields []int
}

var rcxSettingsFields = func() map[string]int {
	out := map[string]int{}
	typ := reflect.TypeOf(rcxConfig{})
	for i := 0; i < typ.NumField(); i++ {
		field := typ.Field(i)
		name := strings.Split(field.Tag.Get("yaml"), ",")[0]
		if field.IsExported() && name != "" && name != "-" {
			out[name] = i
		}
	}
	return out
}()

func rcxDecodeNode(node *yaml.Node, out any) error {
	data, err := yaml.Marshal(node)
	if err != nil {
		return err
	}
	decoder := yaml.NewDecoder(bytes.NewReader(data))
	decoder.KnownFields(true)
	return decoder.Decode(out)
}

func (p *rcxSettingsPatch) UnmarshalYAML(node *yaml.Node) error {
	if node.Kind != yaml.MappingNode {
		return fmt.Errorf("rcx: settings must be a mapping")
	}
	var value rcxConfig
	if err := rcxDecodeNode(node, &value); err != nil {
		return err
	}
	fields := make([]int, 0, len(node.Content)/2)
	for i := 0; i < len(node.Content); i += 2 {
		name := node.Content[i].Value
		index, ok := rcxSettingsFields[name]
		if !ok || node.Content[i+1].Tag == "!!null" {
			return fmt.Errorf("rcx: invalid setting %q", name)
		}
		fields = append(fields, index)
	}
	sort.Ints(fields)
	*p = rcxSettingsPatch{value: value, fields: fields}
	p.value = p.config()
	return nil
}

func (p rcxSettingsPatch) MarshalYAML() (any, error) {
	node := &yaml.Node{Kind: yaml.MappingNode, Tag: "!!map"}
	value := reflect.ValueOf(p.value)
	for _, index := range p.fields {
		key := value.Type().Field(index).Tag.Get("yaml")
		encoded := &yaml.Node{}
		if err := encoded.Encode(value.Field(index).Interface()); err != nil {
			return nil, err
		}
		node.Content = append(node.Content, &yaml.Node{Kind: yaml.ScalarNode, Value: key}, encoded)
	}
	return node, nil
}

func (p *rcxSettingsPatch) apply(c rcxConfig) rcxConfig {
	if p == nil {
		return c
	}
	dst, src := reflect.ValueOf(&c).Elem(), reflect.ValueOf(p.value)
	for _, index := range p.fields {
		dst.Field(index).Set(rcxCopySetting(src.Field(index)))
	}
	return c
}

func rcxCopySetting(value reflect.Value) reflect.Value {
	switch value.Kind() {
	case reflect.Slice:
		if value.Len() == 0 {
			return reflect.Zero(value.Type())
		}
		out := reflect.MakeSlice(value.Type(), value.Len(), value.Len())
		for i := 0; i < value.Len(); i++ {
			out.Index(i).Set(rcxCopySetting(value.Index(i)))
		}
		return out
	case reflect.Struct:
		out := reflect.New(value.Type()).Elem()
		for i := 0; i < value.NumField(); i++ {
			out.Field(i).Set(rcxCopySetting(value.Field(i)))
		}
		return out
	default:
		return value
	}
}

func (p *rcxSettingsPatch) config() rcxConfig { return p.apply(rcxConfig{}) }

func rcxAllSettings(c rcxConfig) *rcxSettingsPatch {
	fields := make([]int, 0, len(rcxSettingsFields))
	for _, index := range rcxSettingsFields {
		fields = append(fields, index)
	}
	sort.Ints(fields)
	p := &rcxSettingsPatch{value: c, fields: fields}
	p.value = p.config()
	return p
}

func (p *rcxSettingsPatch) changes(name string) bool {
	if p == nil {
		return false
	}
	index := rcxSettingsFields[name]
	for _, field := range p.fields {
		if field == index {
			return true
		}
	}
	return false
}

func rcxCountryFloor(requested, floor []string) []string {
	out := append([]string(nil), requested...)
	for _, country := range floor {
		found := false
		for _, existing := range out {
			if strings.EqualFold(existing, country) {
				found = true
				break
			}
		}
		if !found {
			out = append(out, country)
		}
	}
	return out
}
