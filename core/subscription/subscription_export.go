package subscription

var Fetch = fetchSubscription
var CancelFetches = cancelSubscriptionFetches
var NewDialer = newSubscriptionDialer

type Dialer = subscriptionDialer
type Connector = subscriptionConnector

var ErrProtection = errSubscriptionProtection
var ErrTooLarge = errSubscriptionTooLarge
