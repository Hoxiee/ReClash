package extensions

import (
	"bytes"
	"encoding/json"
	"os"
	"reflect"
	"testing"
)

func TestSharedProtocolFixtureDecodesIntoWireTypes(t *testing.T) {
	data, err := os.ReadFile("testdata/protocol.json")
	if err != nil {
		t.Fatal(err)
	}
	var fixture struct {
		Protocol int      `json:"protocol"`
		Manifest Manifest `json:"manifest"`
		Run      struct {
			Argv    []string   `json:"argv"`
			Request RunRequest `json:"request"`
			Events  []Event    `json:"events"`
		} `json:"run"`
		Describe struct {
			Argv     []string         `json:"argv"`
			Request  DescribeRequest  `json:"request"`
			Response DescribeResponse `json:"response"`
		} `json:"describe"`
		Version struct {
			Argv     []string        `json:"argv"`
			Response VersionResponse `json:"response"`
		} `json:"version"`
	}
	decoder := json.NewDecoder(bytes.NewReader(data))
	decoder.DisallowUnknownFields()
	if err := decoder.Decode(&fixture); err != nil {
		t.Fatal(err)
	}
	if fixture.Protocol != ProtocolVersion || fixture.Run.Argv[0] != CommandRun ||
		fixture.Describe.Argv[0] != CommandDescribe || fixture.Version.Argv[0] != CommandVersion {
		t.Fatalf("fixture commands drifted: %+v", fixture)
	}
	encoded, err := json.Marshal(fixture)
	if err != nil {
		t.Fatal(err)
	}
	roundTrip := reflect.New(reflect.TypeOf(fixture))
	if err := json.Unmarshal(encoded, roundTrip.Interface()); err != nil {
		t.Fatal(err)
	}
	if !reflect.DeepEqual(fixture, roundTrip.Elem().Interface()) {
		t.Fatalf("wire types do not round trip:\n%s", encoded)
	}
}
