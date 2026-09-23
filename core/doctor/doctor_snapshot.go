package doctor

func (actor *doctorActor) storeView() {
	copy := actor.copySnapshot()
	actor.view.Store(&copy)
}

func (actor *doctorActor) copySnapshot() doctorSnapshot {
	copy := actor.snapshot
	copy.Evidence = append([]doctorEvidence(nil), actor.snapshot.Evidence...)
	copy.Actions = append([]doctorAction(nil), actor.snapshot.Actions...)
	copy.HealAudit = append([]doctorHealAudit(nil), actor.snapshot.HealAudit...)
	copy.Incidents = append([]doctorIncident(nil), actor.snapshot.Incidents...)
	copy.Stages = append([]doctorStage(nil), actor.snapshot.Stages...)
	return copy
}

func (actor *doctorActor) pathContext() doctorPathContext {
	return doctorPathContext{PathKind: actor.snapshot.PathKind, CaptureState: actor.snapshot.CaptureState}
}

func (actor *doctorActor) applyRuntimePathContext() {
	if provider, ok := actor.runtime.(doctorPathContextProvider); ok {
		actor.setPathContext(provider.DoctorPathContext())
	}
}

func (actor *doctorActor) setPathContext(path doctorPathContext) {
	if path.PathKind == "" {
		path.PathKind = doctorPathUnknown
	}
	if path.CaptureState == "" {
		path.CaptureState = doctorCaptureUnknown
	}
	actor.snapshot.PathKind = path.PathKind
	actor.snapshot.CaptureState = path.CaptureState
}

func (actor *doctorActor) applyPathStatus(status doctorPathStatus) {
	generationChanged := status.Generation != 0
	if generationChanged && status.Generation <= actor.lastPathGeneration {
		return
	}
	if generationChanged {
		actor.lastPathGeneration = status.Generation
		doctorAndroidPathStatus.Store(status)
	}
	before := actor.pathContext()
	actor.setPathContext(doctorPathContextForStatus(status, doctorTunActive()))
	if !generationChanged && before == actor.pathContext() {
		return
	}
	actor.bumpGeneration(doctorTunGeneration)
}

func (actor *doctorActor) Snapshot() doctorSnapshot {
	stored := actor.view.Load()
	if stored == nil {
		return doctorSnapshot{}
	}
	copy := *stored
	copy.Evidence = append([]doctorEvidence(nil), stored.Evidence...)
	copy.Actions = append([]doctorAction(nil), stored.Actions...)
	copy.HealAudit = append([]doctorHealAudit(nil), stored.HealAudit...)
	copy.Incidents = append([]doctorIncident(nil), stored.Incidents...)
	copy.Stages = append([]doctorStage(nil), stored.Stages...)
	if copy.State != doctorExamining && copy.FreshUntil != 0 && actor.now().UnixMilli() >= copy.FreshUntil {
		copy.Health = doctorUnknown
		copy.Confidence = doctorInsufficient
		copy.Severity = doctorSeverityInfo
		copy.CauseCode = "staleEvidence"
		copy.Layer = ""
		copy.Actions = doctorActionsFor(copy)
	}
	return copy
}
