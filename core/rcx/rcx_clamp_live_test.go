package rcx

import (
	"reflect"
	"strings"
	"testing"
	"time"
)

const rcxShapeTestTarget = "https://probe.invalid/payload"

func shapeStandbyEngine(t *testing.T) (*fakeRuntime, *rcxEngine) {
	t.Helper()
	runtime := newFakeRuntime()
	runtime.members = []rcxMember{
		{Name: "inc", Provider: "p", Transport: "ws", SupportsUDP: true},
		{Name: "standby", Provider: "p", Transport: "ws", SupportsUDP: true},
	}
	engine := newTestEngine(runtime, "ru")
	engine.quit = make(chan struct{})
	engine.syncIdentity(runtime.members)
	engine.incumbent = "inc"
	engine.snapshot.Standbys[engine.envKey] = []string{"inc", "standby"}
	engine.cfg.probePacing.ShapeTarget = rcxShapeTestTarget
	return runtime, engine
}

func drainShapeEvent(t *testing.T, engine *rcxEngine) rcxEvent {
	t.Helper()
	select {
	case event := <-engine.events:
		return event
	case <-time.After(time.Second):
		t.Fatal("shape probe did not report")
		return rcxEvent{}
	}
}

func clampCurve() rcxShapeSample {
	return shapeSample(false, [2]int64{64, 100}, [2]int64{128, 10000})
}

func TestShapeProbeDispatchesToDueStandby(t *testing.T) {
	runtime, engine := shapeStandbyEngine(t)
	defer close(engine.quit)
	runtime.shapes = map[string]rcxShapeSample{"standby": clampCurve()}
	engine.maybeShapeStandby()
	if !engine.shaping {
		t.Fatal("dispatch did not take the in-flight guard")
	}
	event := drainShapeEvent(t, engine)
	if event.Node != "standby" || event.Shape != rcxClamped {
		t.Fatalf("probe hit the wrong node or verdict: %s/%s", event.Node, event.Shape)
	}
	if len(runtime.shaped) != 1 || runtime.shaped[0] != "standby" {
		t.Fatalf("the incumbent or a stale node was shaped: %v", runtime.shaped)
	}
	engine.applyShapeResult(event)
	if engine.shaping {
		t.Fatal("landing a result did not release the in-flight guard")
	}
	key := engine.key("standby")
	if engine.shapeClamp[key] != 1 || engine.ledger.Degraded(key, engine.envKey, runtime.Now()) {
		t.Fatal("a single clamp read demoted the standby before confirmation")
	}
}

func TestShapeConfirmedClampDemotesStandbyEndToEnd(t *testing.T) {
	runtime, engine := shapeStandbyEngine(t)
	defer close(engine.quit)
	runtime.shapes = map[string]rcxShapeSample{"standby": clampCurve()}
	key := engine.key("standby")
	engine.maybeShapeStandby()
	engine.applyShapeResult(drainShapeEvent(t, engine))
	if engine.ledger.Degraded(key, engine.envKey, runtime.Now()) {
		t.Fatal("first clamp demoted without a confirming read")
	}
	runtime.advance(rcxShapeInterval)
	engine.maybeShapeStandby()
	engine.applyShapeResult(drainShapeEvent(t, engine))
	if !engine.ledger.Degraded(key, engine.envKey, runtime.Now()) {
		t.Fatal("a confirmed clamp did not demote the standby")
	}
}

func TestShapeCleanReadKeepsAPassiveMark(t *testing.T) {
	runtime, engine := shapeStandbyEngine(t)
	defer close(engine.quit)
	key := engine.key("standby")
	engine.ledger.NoteDegraded(key, engine.envKey, runtime.Now())
	engine.shapeClamp[key] = 1
	engine.applyShapeResult(rcxEvent{Kind: rcxEventShapeResult, Node: "standby", Shape: rcxClampClean, Gen: engine.shapeGen, ConfigGen: engine.configGen})
	if !engine.ledger.Degraded(key, engine.envKey, runtime.Now()) {
		t.Fatal("a clean shape read erased a mark it did not set")
	}
	if engine.shapeClamp[key] != 0 {
		t.Fatal("a clean read did not reset the clamp streak")
	}
}

func TestShapePolicyChangeFreesGuardButDropsVerdict(t *testing.T) {
	runtime, engine := shapeStandbyEngine(t)
	defer close(engine.quit)
	key := engine.key("standby")
	engine.shaping = true
	stale := rcxEvent{Kind: rcxEventShapeResult, Node: "standby", Shape: rcxClamped, Gen: engine.shapeGen, ConfigGen: engine.configGen - 1}
	engine.applyShapeResult(stale)
	if engine.shaping {
		t.Fatal("the in-flight probe completed but the guard stayed taken")
	}
	if engine.ledger.Degraded(key, engine.envKey, runtime.Now()) || engine.shapeClamp[key] != 0 {
		t.Fatal("a verdict from a superseded policy was counted")
	}
}

func TestShapeSupersedeFreesAStuckGuard(t *testing.T) {
	_, engine := shapeStandbyEngine(t)
	defer close(engine.quit)
	engine.shaping = true
	engine.shapeCancel = func() {}
	engine.supersedeShape()
	if engine.shaping || engine.shapeCancel != nil {
		t.Fatal("supersede did not release the in-flight guard")
	}
	late := rcxEvent{Kind: rcxEventShapeResult, Node: "standby", Shape: rcxClamped, Gen: engine.shapeGen - 1, ConfigGen: engine.configGen}
	engine.shaping = true
	engine.applyShapeResult(late)
	if !engine.shaping {
		t.Fatal("a superseded late result freed a newer probe's guard")
	}
}

func TestShapeDueStandbySkipsIncumbentAndRespectsInterval(t *testing.T) {
	runtime, engine := shapeStandbyEngine(t)
	defer close(engine.quit)
	if due := engine.dueShapeStandby(); due != "standby" {
		t.Fatalf("due standby skipped the incumbent? got %q", due)
	}
	engine.shapedAt[engine.key("standby")] = runtime.Now()
	if due := engine.dueShapeStandby(); due != "" {
		t.Fatalf("a freshly shaped standby was re-selected: %q", due)
	}
	runtime.advance(rcxShapeInterval)
	if due := engine.dueShapeStandby(); due != "standby" {
		t.Fatal("a standby past the interval was not re-selected")
	}
}

func TestShapeSkipsWithoutTargetOrOnMeteredLink(t *testing.T) {
	runtime, engine := shapeStandbyEngine(t)
	defer close(engine.quit)
	runtime.shapes = map[string]rcxShapeSample{"standby": clampCurve()}
	engine.cfg.probePacing.ShapeTarget = ""
	engine.maybeShapeStandby()
	if engine.shaping || len(runtime.shaped) != 0 {
		t.Fatal("an unset target still spent a shape probe")
	}
	engine.cfg.probePacing.ShapeTarget = rcxShapeTestTarget
	engine.metered = true
	engine.maybeShapeStandby()
	if engine.shaping || len(runtime.shaped) != 0 {
		t.Fatal("a metered link still spent a shape probe")
	}
}

func TestProfileV2ShapeTargetRoundTrips(t *testing.T) {
	config := compiledProfileConfig(t, "schema: 2\nprobe: {shapeTarget: \"https://cdn.example/256k\"}\n")
	if config.probe().ShapeTarget != "https://cdn.example/256k" {
		t.Fatalf("shape target lost on parse: %q", config.probe().ShapeTarget)
	}
	data, err := config.effectiveProfile().marshalYAML()
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(string(data), "shapeTarget: https://cdn.example/256k") {
		t.Fatalf("shape target not exported: %s", data)
	}
	loaded := compiledProfileConfig(t, string(data))
	if !reflect.DeepEqual(config.probe(), loaded.probe()) {
		t.Fatal("shape target changed across a round-trip")
	}
}
