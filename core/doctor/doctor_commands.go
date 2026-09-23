package doctor

// Exported command surface so the host drives the actor without touching doctorCommand.

func (actor *doctorActor) Start(params doctorStartParams) (doctorSnapshot, error) {
	return actor.request(doctorCommand{kind: doctorStartCommand, start: params})
}

func (actor *doctorActor) Cancel(params doctorCancelParams) (doctorSnapshot, error) {
	return actor.request(doctorCommand{kind: doctorCancelCommand, cancel: params})
}

func (actor *doctorActor) Heal(params doctorHealParams) (doctorSnapshot, error) {
	return actor.request(doctorCommand{kind: doctorHealCommand, heal: params})
}

func (actor *doctorActor) PlatformStatus(status doctorPlatformStatus) (doctorSnapshot, error) {
	return actor.request(doctorCommand{kind: doctorPlatformStatusCommand, platform: status})
}

func (actor *doctorActor) PathStatus(status doctorPathStatus) (doctorSnapshot, error) {
	return actor.request(doctorCommand{kind: doctorPathStatusCommand, pathStatus: status})
}

func (actor *doctorActor) Reset() (doctorSnapshot, error) {
	return actor.request(doctorCommand{kind: doctorResetCommand})
}

func (actor *doctorActor) BumpGeneration(kind doctorGenerationKind) (doctorSnapshot, error) {
	return actor.request(doctorCommand{kind: doctorGenerationCommand, generation: kind})
}

func (actor *doctorActor) BumpGenerations(change doctorGenerationChange) (doctorSnapshot, error) {
	return actor.request(doctorCommand{kind: doctorGenerationCommand, generations: change})
}

func (actor *doctorActor) SetIdentity(identity func(doctorProbeObservation) (doctorProbeObservation, bool)) {
	actor.identity = identity
}
