# Routing delivery

How a subscription offers auto-routing profiles and scenarios: inline in the config or in a separate routing bundle.

Profile and scenario syntax is in [Profiles](../auto-routing/profiles.md) and [Scenarios](../auto-routing/scenarios.md). Schema: [`rcx-profile.schema.json`](../../../rcx-profile.schema.json), with the bundle in `$defs.bundle`.

## Channels

| Channel | Use when | Keys |
| --- | --- | --- |
| Inline | The provider serves Clash YAML. | Top-level `rcx-profiles`, `rcx-scenarios`, `rcx-scenario`; `rcx` on each `select` group. |
| Bundle | The provider serves a format that cannot hold these keys, or wants to version routing separately. | `reclash-routing` header, or a body comment, pointing to a YAML bundle. |

Vanilla mihomo ignores these keys, so the subscription stays valid for other Clash clients.

## Inline declarations

```yaml
rcx-profiles:
  fast-de:
    rcx: 1
    title: Fast Germany
    prefer:
      - { label: Germany, when: 'country = DE' }
      - { label: Anything, when: 'not dead' }
rcx-scenarios:
  work:
    rcx: 1
    title: Work
    groups:
      $main: { profile: provider/fast-de }
    routes:
      - name: Intranet
        match: [DOMAIN-SUFFIX,corp.example]
        to: DIRECT
rcx-scenario: work
proxy-groups:
  - name: Proxy
    type: select
    include-all: true
    rcx:
      profiles: [fast-de]
      default: fast-de
      chips:
        - { label: Germany, include: 'country = DE' }
```

| Key | Value |
| --- | --- |
| `rcx-profiles` | Map of profile name to profile. |
| `rcx-scenarios` | Map of scenario name to scenario. |
| `rcx-scenario` | Default scenario name. |
| Group `rcx` | Binding for that `select` group, below. |

### Group binding

| Key | Value |
| --- | --- |
| `profiles` | Profile names offered for the group. |
| `default` | Profile used until the user chooses. |
| `chips` | Up to 12 one-tap pools: `{label, include}`, where `include` is a [condition](../auto-routing/conditions.md). |
| `pool` | `{include, exclude}` conditions that narrow the group's servers. |
| `prefer` | Server order replacing the profile's own for this group. A scenario program's `prefer` beats it. |
| `feel` | Switching temper: `calm`, `balanced` or `eager` ([How the engine works](../auto-routing/engine.md)). |
| `energy` | Check budget: `eco`, `balanced` or `precise`. |

A profile is addressed as `provider/<name>`. `extends` may name `builtin/<name>` or another provider profile.

## Routing bundle

```http
reclash-routing: https://example.net/rcx/bundle.yaml
```

```yaml
rcx: 1
profiles:
  fast-de:
    rcx: 1
    title: Fast Germany
    prefer:
      - { label: Germany, when: 'country = DE' }
groups:
  Proxy:
    profiles: [fast-de]
    default: fast-de
scenarios:
  work:
    rcx: 1
    title: Work
    groups:
      $main: { profile: provider/fast-de }
scenario: work
```

| Key | Value |
| --- | --- |
| `rcx` | `1`. |
| `profiles` | Required. Map of profile name to profile. |
| `groups` | Map of proxy-group name to binding. |
| `scenarios` | Map of scenario name to scenario. |
| `scenario` | Default scenario name. |

- The URL must be `https`; `http` is allowed only when the subscription is `http`. No userinfo.
- Fetched after the subscription, with the same request headers. On another origin, only `User-Agent`, `Accept` and `Accept-Language` are sent; the device ID stays home.
- At most 256 KiB, and not empty. Stored beside the profile.
- A failed fetch is logged, and the update continues with the stored bundle. A response without `reclash-routing` also keeps it.
- A bundle that is not valid YAML is ignored as a whole.

## Precedence

Inline declarations win over the bundle by name:

- a group `rcx` replaces the bundle binding of the same group;
- an `rcx-profiles` or `rcx-scenarios` entry replaces the bundle entry of the same name;
- a non-empty `rcx-scenario` replaces `scenario`.

The user's own choices win over both.

## Provider limits

| Limit | Rule |
| --- | --- |
| Pool | A provider binding can only narrow a group's pool. |
| `direct-split` | Ignored from a provider; only the user can turn it on. |
| Size | A profile or scenario is at most 64 KiB. |
| Third-party hosts | A profile or scenario whose checks, diagnostics or echo services contact a host outside the provider's site needs user consent. The provider's site is the registrable domain of the subscription host; built-in profile endpoints are always allowed. Until consent, the group runs `builtin/simple`. |
| Choice | Profiles and scenarios are offers: the user picks a profile per group and a scenario, or turns auto control off. |

## Validation

```sh
dart run tool/rcx.dart lint bundle.yaml
```

The linter accepts a profile, scenario or bundle. In the app, the Core reports an invalid or missing provider profile in the group or scenario status.
