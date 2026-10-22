package rcx

import (
	"encoding/json"
	"os"
	"reflect"
	"slices"
	"strings"
	"testing"
)

func yamlKeys(t reflect.Type) []string {
	var keys []string
	for i := range t.NumField() {
		name, _, _ := strings.Cut(t.Field(i).Tag.Get("yaml"), ",")
		if name != "" && name != "-" {
			keys = append(keys, name)
		}
	}
	slices.Sort(keys)
	return keys
}

func TestSchemaMatchesProfileTypes(t *testing.T) {
	data, err := os.ReadFile("../../rcx-profile.schema.json")
	if err != nil {
		t.Fatal(err)
	}
	var schema struct {
		Defs map[string]struct {
			Properties map[string]json.RawMessage `json:"properties"`
		} `json:"$defs"`
	}
	if err := json.Unmarshal(data, &schema); err != nil {
		t.Fatal(err)
	}
	types := map[string]reflect.Type{
		"profile":    reflect.TypeFor[Profile](),
		"pool":       reflect.TypeFor[Pool](),
		"tier":       reflect.TypeFor[TierSpec](),
		"rank":       reflect.TypeFor[RankSpec](),
		"switch":     reflect.TypeFor[SwitchSpec](),
		"check":      reflect.TypeFor[Check](),
		"network":    reflect.TypeFor[NetworkSpec](),
		"diagnostic": reflect.TypeFor[Diagnostic](),
		"kind":       reflect.TypeFor[KindSpec](),
		"layer":      reflect.TypeFor[Layer](),
		"egress":     reflect.TypeFor[Egress](),
		"binding":    reflect.TypeFor[Binding](),
		"chip":       reflect.TypeFor[Chip](),

		"scenario":      reflect.TypeFor[Scenario](),
		"scenarioLayer": reflect.TypeFor[ScenarioLayer](),
		"program":       reflect.TypeFor[Program](),
	}
	for name, typ := range types {
		def, ok := schema.Defs[name]
		if !ok {
			t.Errorf("schema has no $defs.%s", name)
			continue
		}
		var got []string
		for key := range def.Properties {
			got = append(got, key)
		}
		slices.Sort(got)
		if want := yamlKeys(typ); !slices.Equal(got, want) {
			t.Errorf("$defs.%s properties = %v, Go %s keys = %v", name, got, typ.Name(), want)
		}
	}
}

func TestBuiltinProfilesParse(t *testing.T) {
	files, err := builtinFiles.ReadDir("builtin")
	if err != nil || len(files) == 0 {
		t.Fatalf("no built-in profiles: %v", err)
	}
	for _, file := range files {
		if file.IsDir() {
			continue
		}
		data, err := builtinFiles.ReadFile("builtin/" + file.Name())
		if err != nil {
			t.Fatal(err)
		}
		if _, err := ParseProfile(data); err != nil {
			t.Errorf("%s: %v", file.Name(), err)
		}
	}
}
