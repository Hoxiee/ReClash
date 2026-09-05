//go:build !linux

package main

// No portable route table or resolver list: the interface addresses alone still
// separate one network from another, which is what the fingerprint is for.
func rcxLinkGateways([]string) []string { return nil }

func rcxLinkResolvers() []string { return nil }
