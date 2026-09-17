//go:build !(android && cgo)

package main

func protectedSubscriptionDialer() (*subscriptionDialer, error) {
	return nil, errSubscriptionProtection
}
