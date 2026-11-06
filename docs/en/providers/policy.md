# Safety policy

What a provider can enforce in ReClash so that the user cannot undo it.

A policy has up to two parts. The **rule** sits in the subscription body as plain mihomo config, so every client honors it. The **switch** sits in the manifest's `policy` section and makes ReClash enforce the rule.

| You want | Subscription body | Manifest |
| --- | --- | --- |
| [Global mode only through chosen nodes](#only-listed-nodes-in-global) | A `GLOBAL` group that lists them | `global: listed` |
| [No Global mode at all](#no-global) | Nothing | `global: off` |
| [Android apps always outside the VPN](#apps-that-must-stay-outside-the-vpn) | `tun.exclude-package` | `apps: required` |
| [No local proxy ports on Android](#no-local-proxy-ports) | Nothing | `local-ports: closed` |
| [No dashboard editing](#locked-dashboard) | Nothing | `dashboard: locked` |

Every key is optional. A key you leave out restricts nothing.

```yaml
policy:
  global: listed       # any (default) | listed | off
  apps: required       # recommended (default) | required
  local-ports: closed  # open (default) | closed
  dashboard: locked    # editable (default) | locked
```

## Only listed nodes in Global

Rule mode stays free: your `rules` decide. In Global mode, traffic may leave only through nodes reachable from the `GLOBAL` group.

The simplest form is mihomo's native `filter`. Say the fleet has nodes named `Germany`, `Poland LTE`, `Russia LTE` and `Streaming`, and Global mode may use only the LTE ones.

Subscription body:

```yaml
proxy-groups:
  - name: GLOBAL
    type: select
    include-all-proxies: true
    filter: '\bLTE\b'
    remnawave: { include-proxies: false }
```

Manifest:

```yaml
policy:
  global: listed
```

Result:

| Mode and node | Result |
| --- | --- |
| Rule mode, any node, `Streaming` included | Works. |
| Global, `Poland LTE` | Works. |
| Global, `Russia LTE` | Works. |
| Global, `Germany` | Blocked. The app asks the user to pick an allowed node or use Rule mode. |
| Global, `DIRECT` | Blocked. A denied route never falls back to a direct connection. |

What to write:

| You want | `GLOBAL` group |
| --- | --- |
| Nodes that carry a marker in the name | `include-all-proxies: true` and `filter: '\bLTE\b'`. |
| Everything except some nodes | `include-all-proxies: true` and `exclude-filter: Streaming`. |
| An exact short list | Hand-listed `proxies`. A host the user lacks makes the config fail, see below. |

- `filter` matches node names only. It narrows only `include-all-proxies` (or `include-all`) members, never explicit `proxies`.
- A backtick separates alternatives. `(?i)` ignores case.
- Prefer `\bLTE\b` to `lte`: the unanchored `lte` also matches `Malte`.
- `exclude-filter` and `exclude-type` remove members from every group, explicit `proxies` included.
- The marker must be in the node name. Remnawave host `tags` do not reach the mihomo config.
- New matching nodes join by themselves, and a user whose tariff lacks some matching hosts still gets a config that loads. This suits large fleets.
- Hand-listed `proxies` that name a host the user lacks make mihomo fail with `GLOBAL: 'Poland LTE' not found`. The profile update still succeeds and the failure appears only when the config is applied. With `global: listed` the profile is blocked and refuses all traffic.

What counts as listed:

| Case | Result |
| --- | --- |
| A node in the body's `proxies`, reachable through `GLOBAL` | Allowed. |
| A node that `GLOBAL` resolves to through `filter` | Allowed. |
| The node is renamed | Stays allowed: permission follows the server, port and credentials, not the name. |
| Another server takes an allowed node's name | Denied. |
| A node from a `proxy-providers` source | Denied, unless its definition matches an allowed inline node exactly. |
| `DIRECT` or `REJECT` listed in `GLOBAL` | Adds nothing. |
| `filter` matches no node | The group resolves to `COMPATIBLE` (or its `empty-fallback`), and Global mode is removed. |
| No `GLOBAL` group, or it reaches no inline node | Global mode is removed, same as `global: off`. |

> [!WARNING]
> A panel can add nodes to your groups when it generates the body. Remnawave appends all hosts to the `proxies` of a group that lacks `remnawave: { include-proxies: false }` ([how](rollout.md#policy-in-the-mihomo-template)), which bypasses `filter`. Then everything is allowed, and the Subscription inspector shows `policy.global is listed, but GLOBAL reaches every inline node of the body, so the lock restricts nothing`. The warning is suppressed when the body has remote providers or a single route. Check the body the client actually receives.

Global mode only. In Rule mode, ordinary groups and rules decide.

## No Global

```yaml
policy:
  global: off
```

The app hides Global mode and the Core refuses it. A profile in Global mode switches to Rule. The body needs nothing.

## Apps that must stay outside the VPN

Subscription body:

```yaml
tun:
  exclude-package: [com.example.bank, com.example.gov]
```

Manifest:

```yaml
policy:
  apps: required
```

| Behavior | `recommended` (default) | `required` |
| --- | --- | --- |
| Source of the list | `tun.exclude-package` and `apps.exclude` | `tun.exclude-package` only |
| User can take an app back | Yes | No: locked, tagged "Required by provider" |
| Whitelist mode, or Access control off | The user's mode decides | Still excluded |
| Local proxy ports on Android | Open | Closed |
| Desktop | Ignored | Ignored |
| Android without VPN mode | Ignored | **The profile refuses to connect** |

`apps: required` works only on Android, in VPN mode; desktop ignores it.

Excluded apps use the direct connection and the real IP. An exclusion is not a block: to block them, use Android lockdown mode. The VPN app itself cannot be excluded.

Errors the user can see:

| Message | Cause | Fix |
| --- | --- | --- |
| `provider policy requires Android VPN app exclusions` | Android without VPN mode | Use Android VPN mode. |
| `provider app exclusions are not applied; restart the VPN` | The running VPN started with a different list | Restart the VPN. |
| `provider policy could not identify this application` | The connection's app is unknown | The connection stays blocked. |
| `provider policy requires this application to remain outside the VPN` | A listed app is still captured by an old VPN session | Restart the VPN. |

## No local proxy ports

```yaml
policy:
  local-ports: closed
```

Android only. Closes the mixed, HTTP, SOCKS, redir and TProxy ports, makes the web dashboard unavailable, and sends the app's own requests directly. `apps: required` turns this on as well.

## Locked dashboard

```yaml
policy:
  dashboard: locked
```

Removes editing on both dashboards. The layout you set in [`widgets`](manifest.md#widgets) stays.

## When a lock applies

| Event | Result |
| --- | --- |
| A new valid manifest omits a key | That lock is withdrawn with the next update. |
| A `policy` value is invalid | The whole section is withdrawn; the [inspector](rollout.md#subscription-inspector) shows a warning. |
| The manifest fetch fails | The last valid copy keeps its locks. |
| The subscription update fails | Nothing changes. |
| The response no longer has `reclash-config`, or the manifest was never fetched | No locks. The body's rules work as plain mihomo config. |
| The user switches profile | The new profile's policy applies. |
| The mode or the lock changes | Open connections are closed. |

Scripts, overrides and controller reloads cannot remove a lock: the Core derives it from the original profile file and keeps it outside `config.yaml`.

## Limits

- This protects a cooperating client, not your network. A client that does not read the manifest honors only the body's rules, and a modified one can ignore both. Enforce what must never happen on the server.
- Excluding a package does not cover the same service opened in a browser.
