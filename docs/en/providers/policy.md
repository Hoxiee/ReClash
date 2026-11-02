# Required safety policy

A versioned `reclash-policy` section in a native Clash subscription that limits GLOBAL traffic to listed nodes and keeps listed Android apps outside the VPN.

The policy is not a routing profile, an app-setting hint or a user-editable rule. Subscriptions without `reclash-policy` are unaffected. Schema: [`provider-policy.schema.json`](../../../provider-policy.schema.json).

## Structure

```yaml
reclash-policy:
  version: 1
  global:
    allow: [de-01]
  apps:
    android:
      exclude: [com.example.bank]
proxies:
  - name: Germany
    reclash-id: de-01
    type: socks5
    server: proxy.example.net
    port: 1080
  - name: Restricted
    reclash-id: restricted-01
    type: socks5
    server: restricted.example.net
    port: 1080
```

| Key | Type | Rules |
| --- | --- | --- |
| `version` | integer | Must be `1`. |
| `global.allow` | list of node IDs | Unique, max 4096. |
| `apps.android.exclude` | list of package names | Unique, max 512. |

Unknown keys are rejected at every level.

## Node IDs

- `reclash-id` on an inline `proxies` entry names the node for the policy.
- Case-sensitive, unique within the subscription, and matching `^[A-Za-z0-9][A-Za-z0-9._:-]{0,63}$`.
- Every ID in `global.allow` must exist.
- A permission binds to the node's full route definition, credentials included, not to its name. Renaming a node keeps its permission; copying the ID onto a different server does not.

## GLOBAL allowlist

- A present `global` section is default-deny: only listed IDs may carry GLOBAL traffic. `allow: []` forbids every node and removes Global mode.
- Without `global`, Global mode is unrestricted, but the [`noglobal`](app-settings.md#restrictions) restriction still removes it.
- A member from a remote proxy provider is denied unless its route definition matches a permitted inline node.
- A group qualifies for GLOBAL only if all its possible members are permitted.
- Every TCP and UDP dial is checked, including fallback, nested selection, health checks and controller changes.
- A denied route never falls back to `DIRECT` or to an unapproved node.

## Android app exclusions

- `apps.android.exclude` is mandatory, unlike the recommended [`reclash-excludeapps`](app-settings.md#android-apps). It overrides apps the user took back, whitelist inclusions and disabled access control, in every routing mode.
- Required entries are locked in Access control with the "Required by provider" tag.
- They also close local proxy ports, so a local listener cannot bypass them ([`androidsecure`](app-settings.md#restrictions)).
- An exclusion is not an Internet block: excluded apps use the direct connection and the real IP. Android lockdown mode can block them instead.

## Enforcement

The Core reads the policy from the original profile, not from user scripts, and keeps the applied policy outside `config.yaml`. Controller reloads and config scripts cannot remove it. Changing the mode or policy closes existing connections.

| Condition | Result |
| --- | --- |
| Not Android, or Android without VPN mode, and the policy has app exclusions | Refused: `provider policy requires Android VPN app exclusions`. |
| The running VPN's app list differs from the required exclusions | Refused until restart: `provider app exclusions are not applied; restart the VPN`. The same after reattaching to a service with unknown options. |
| A connection's application cannot be identified | Blocked: `provider policy could not identify this application`. |
| An excluded app still captured by an old VPN session | Blocked: `provider policy requires this application to remain outside the VPN`. |
| A GLOBAL connection through a node that is not allowed | Blocked. The app asks the user to select an allowed node or use Rule mode. |

The VPN app itself cannot be excluded.

## Lifecycle

- An unknown version or key, a malformed list, or an unknown or duplicate ID rejects the whole import. Automatic negotiation does not try another client preset.
- A failed update leaves the saved subscription and its policy unchanged.
- A successful update without `reclash-policy` withdraws the policy; stale metadata never keeps it.
- Switching profiles applies the new profile's policy.

## Limitations

- Protects against accidental use in a cooperating ReClash client. It is not DRM and not a server-side guarantee: other clients ignore these fields.
- Package exclusions do not cover the same service opened in a browser.
- Version 1 binds IDs on inline `proxies` only.
