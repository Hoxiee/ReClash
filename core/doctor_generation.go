package main

func doctorGenerationForUpdate(params *UpdateParams) doctorGenerationChange {
	if params == nil {
		return doctorGenerationChange{}
	}
	config := params.Tun != nil || params.AllowLan != nil || params.MixedPort != nil ||
		params.FindProcessMode != nil || params.Mode != nil || params.IPv6 != nil ||
		params.TCPConcurrent != nil || params.ExternalController != nil ||
		params.UnifiedDelay != nil || params.Authentication != nil
	routing := params.Mode != nil || params.FindProcessMode != nil || params.IPv6 != nil ||
		params.TCPConcurrent != nil
	return doctorGenerationChange{Config: config, Routing: routing}
}
