package main

import (
	"testing"

	"github.com/metacubex/mihomo/log"
	"github.com/metacubex/mihomo/tunnel"
)

func TestDoctorGenerationIgnoresOperationalUpdateSettings(t *testing.T) {
	level := log.INFO
	if got := doctorGenerationForUpdate(&UpdateParams{LogLevel: &level}); got != (doctorGenerationChange{}) {
		t.Fatalf("log level generation = %+v", got)
	}
	interval := 24
	if got := doctorGenerationForUpdate(&UpdateParams{GeoUpdateInterval: &interval}); got != (doctorGenerationChange{}) {
		t.Fatalf("geo interval generation = %+v", got)
	}
}

func TestDoctorGenerationClassifiesConfigAndRoutingChanges(t *testing.T) {
	allowLan := true
	if got := doctorGenerationForUpdate(&UpdateParams{AllowLan: &allowLan}); !got.Config || got.Routing {
		t.Fatalf("allow-lan generation = %+v", got)
	}
	mode := tunnel.Global
	if got := doctorGenerationForUpdate(&UpdateParams{Mode: &mode}); !got.Config || !got.Routing {
		t.Fatalf("mode generation = %+v", got)
	}
}

func TestDoctorActorBatchesGenerationChangesIntoOneRevision(t *testing.T) {
	actor := newDoctorActor(&fakeDoctorRuntime{}, nil)
	before := actor.Snapshot()
	after, _ := actor.request(doctorCommand{
		kind:        doctorGenerationCommand,
		generations: doctorGenerationChange{Config: true, Routing: true},
	})
	if after.Revision != before.Revision+1 || after.Generations.Config != 1 || after.Generations.Routing != 1 {
		t.Fatalf("before = %+v, after = %+v", before, after)
	}
}
