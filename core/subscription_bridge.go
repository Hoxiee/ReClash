package main

import (
	"errors"

	"core/subscription"
)

type SubscriptionFetchParams = subscription.FetchParams
type SubscriptionFetchResult = subscription.FetchResult

type subscriptionDialer = subscription.Dialer
type subscriptionConnector = subscription.Connector

var newSubscriptionDialer = subscription.NewDialer
var cancelSubscriptionFetches = subscription.CancelFetches
var fetchSubscription = subscription.Fetch

var errSubscriptionProtection = subscription.ErrProtection
var errSubscriptionTooLarge = subscription.ErrTooLarge

func handleFetchSubscription(params *SubscriptionFetchParams, response MethodResponse) {
	dialer, err := protectedSubscriptionDialer()
	if err != nil {
		response.failure("subscription_protection", "Protected subscription transport unavailable", nil)
		return
	}
	result, err := fetchSubscription(params, dialer)
	if err != nil {
		code := "subscription_transport"
		if errors.Is(err, errSubscriptionProtection) {
			code = "subscription_protection"
		}
		if errors.Is(err, errSubscriptionTooLarge) {
			code = "subscription_too_large"
		}
		response.failure(code, "Subscription download failed", nil)
		return
	}
	response.success(result)
}
