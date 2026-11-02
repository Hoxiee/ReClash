# Sharing

Bundles, export and import, `reclash://routing` links, provider delivery, consent, rcxlint and the JSON schema.

## Bundles

A bundle carries a profile or scenario plus the non-built-in profiles it needs. Limit: 256 KiB.

```yaml title="split-bundle.rcx.yaml"
rcx: 1
kind: bundle
title: Split with Norway
scenarios:
  split-with-norway:
    rcx: 1
    title: Split with Norway
    groups:
      $main: { profile: user/norway }
profiles:
  norway:
    rcx: 1
    title: Norway
    prefer:
      - { label: Norway, when: 'country = NO' }
      - { label: Any, when: 'not dead', last-resort: true }
```

| Key | Description |
| --- | --- |
| `kind: bundle` | Marks a bundle; without it, a file is one profile or scenario. |
| `title` | Title of the main item. |
| `scenarios` | Map name → scenario. |
| `profiles` | Map name → profile. |

A bundle needs at least one profile or scenario (`bundle holds no profiles or scenarios`); every entry must be a mapping.
In a bundle, `user/<key>` refers to its own profile `<key>`.

Without `kind: bundle`, a file is a scenario if it has a top-level `groups`, `mode` or `routes` key, otherwise a profile.

## Export

Export starts from a library entry. If the entry references only built-in profiles, the plain document is exported.
Otherwise it becomes a bundle holding the item and every profile reachable through `extends`, `profile` in programs,
`on.<kind>.groups` or routes, at any depth.

Bundle names come from titles: lowercase, each run of characters outside `a-z0-9` becomes `-`, trimmed, with `-2`, `-3`, …
on collision. An empty result uses the last segment of the id. References become `user/<name>`.

| Format | Content |
| --- | --- |
| **Export to clipboard** | YAML text. |
| **Copy link** | A `reclash://routing?p=…` link. |
| **Export file** | `<name>.rcx.yaml`. |

## Import

Import accepts a file, the clipboard or a link. The review shows errors, warnings, the hosts the import would contact, and
what a profile would select now in a chosen group. Checking needs the core running. **Add to my library** saves each item
as a user profile or scenario; nothing starts running.

Plain documents are named from their title. Bundle items are named from their keys, profiles first, avoiding taken names;
`user/<key>` references are rewritten to the saved names. An import never replaces an existing entry.

## Links

| Form | Content |
| --- | --- |
| `reclash://routing?p=<payload>` | The document, raw DEFLATE-compressed and unpadded base64url-encoded. Payload at most 128 KiB; decoded text at most 64 KiB. |
| `reclash://routing?url=https://…` | The app fetches the document from the HTTPS URL; at most 64 KiB. |

The link carries exactly one of `p` or `url`, with no path or fragment. Opening it starts the import review.

## Provider delivery

A subscription serves RCX through one of two channels. What the subscription file declares wins over the bundle.

| Channel | Content |
| --- | --- |
| Subscription config | `rcx:` bindings on `proxy-groups`, top-level `rcx-profiles`, `rcx-scenarios` and `rcx-scenario`. |
| Routing bundle | A YAML file at the URL in the `reclash-routing` subscription field, with `profiles`, `groups` (bindings by group name), `scenarios` and `scenario`; at most 256 KiB. |

Provider profiles and scenarios get the ids `provider/<name>`. Field syntax and delivery details are in
[Routing delivery](../providers/routing.md).

## Consent

A provider profile or scenario may contact hosts through checks, diagnostics and echo services. These hosts are allowed
without asking:

- the default echo services and every endpoint of the built-in profiles;
- the provider's registrable domain, from the subscription URL and the routing bundle URL;
- hosts the user already allowed for this subscription.

Any other host holds the item back until the user allows it; the problem `profile.consent` lists those hosts. A group with
such a profile runs `builtin/simple`; such a scenario drives no group. For a profile, every provider entry in its `extends`
chain is checked. User profiles and scenarios never need consent.

## rcxlint

`rcxlint` checks profiles, scenarios and bundles with the same validation the app uses.

```sh
cd core
go run ./rcx/cmd/rcxlint profile.rcx.yaml scenario.rcx.yaml
dart run tool/rcx.dart lint profile.rcx.yaml
```

| Input | Detected by | Checked as |
| --- | --- | --- |
| Shared bundle | `kind: bundle` | Its profiles as `user/<key>` |
| Provider bundle | Top-level `profiles` or `scenarios` | `provider/<name>`; also checks that `scenario`, and each group's `default` and `profiles`, are defined |
| Scenario | Top-level `groups`, `routes` or `mode` | `provider/<file name>` |
| Profile | Anything else | `provider/<file name>` |

The file name drops `.yaml` and `.rcx`. Output lines:

```text
file:line: error: [profile X: | scenario X: ]message
file:line: warning: [profile X: | scenario X: ]message
file: note: [profile X: ]contacts third-party host H (use); the user must allow it
```

Exit status: 0 without errors, 1 with any error, 2 on wrong usage.

### Warnings

| Warning | Meaning |
| --- | --- |
| `tag X is never used` | No condition references the tag. |
| `check X is never used, so it never runs` | No condition references the check. |
| `tier A repeats the condition of B, so nothing lands in it` | Two tiers share a condition; the later is unreachable. |
| `the pool admits no server of G` | In the app, against a running group. |
| `no server of G is in T right now` | In the app, against a running group. |
| `this config has no group G` | In the app, for a scenario target. |

## JSON schema

`rcx-profile.schema.json` at the repository root validates a profile at its root; `$defs.scenario` and `$defs.bundle` cover
the other documents. It checks structure and value shapes, not conditions.

```json title=".vscode/settings.json"
{
  "yaml.schemas": {
    "./rcx-profile.schema.json": "*.rcx.yaml"
  }
}
```
