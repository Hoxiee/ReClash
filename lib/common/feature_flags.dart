/// Build-time gates for features held back from the public pre-release until
/// each finishes hardening. Flip a flag to true to expose it in a later build;
/// gating is compile-time, so release artifacts tree-shake the hidden surfaces
/// while the code and its tests stay in the tree.
const bool kEnableSmartRouting = false;

const bool kEnableDeviceCompanion = false;

const bool kEnableSubscriptionConverter = false;
