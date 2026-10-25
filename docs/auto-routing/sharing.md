# Sharing and delivery

How a profile or scenario travels: from you to a friend, from a provider to every subscriber, and through the
validator before either. For the buttons in the app see the [editor sharing guide](editor/sharing.md).

Contents: [bundles](#bundles) · [export](#export) · [import and unpack](#import-and-unpack) ·
[provider delivery](#provider-delivery) · [rcx links](#rcx-links) · [JSON schema](#json-schema-and-editors) ·
[the rcxlint tool](#the-rcxlint-tool)

## Bundles

A **bundle** is one YAML file that carries several profiles and scenarios together. It exists because a scenario
usually refers to profiles, and a scenario without its profiles is useless on another device.

```yaml
rcx: 1
kind: bundle
title: Streaming
scenarios:
  streaming:
    rcx: 1
    title: Streaming
    groups:
      $main: { profile: user/streaming-fast }
profiles:
  streaming-fast:
    rcx: 1
    title: Streaming fast
    extends: builtin/fastest
    prefer:
      - label: Germany
        when: country = DE
      - label: Anything
        when: not dead
```

| Key | Meaning |
| --- | --- |
| `rcx` | Format version, `1`. |
| `kind: bundle` | Marks the document as a bundle. Without it, the file is read as a single profile or scenario. |
| `title` | Shown on import. |
| `scenarios` | Map name → scenario. |
| `profiles` | Map name → profile. |

A bundle is at most 256 KiB, UTF-8. It must hold at least one profile or scenario, and each entry must be a mapping.

A bundle exported by the app names its profiles `user/<name>`; `rcxlint` and the import review check it in that form,
as it is.

## Export

Exporting a profile or scenario produces:

- the document itself, when it needs only built-in profiles;
- otherwise a bundle that includes every non-built-in profile it reaches, following `extends` and program
  references to any depth.

References are rewritten while exporting. Every non-built-in profile in the closure becomes a *user* profile
named from its title (lower-case, runs of other characters turned into `-`), and every reference in the exported
documents is changed to `user/<new-name>`. Built-in references (`builtin/...`) are left alone. Name clashes get a
numeric suffix (`-2`, `-3`).

This is the `bundle` guarantee: an exported setup carries every non-built-in profile it references.

## Import and unpack

When the app reads a document it first decides whether it is a bundle (`kind: bundle`). A plain profile or scenario
is imported as one item and named from its title (or, lacking one, `profile` or `scenario`).

For a bundle, every item is **renamed** to a name that is free in the user's library, starting from its key in the bundle (made lower-case, with runs of other characters turned into `-`),
with a numeric suffix if needed. References between the items are rewritten to the new names, so the imported scenario
points at the imported copy of its profiles.

Importing never replaces a profile the user already has: if `streaming-fast` exists, the new one becomes
`streaming-fast-2`, and the scenario is updated to match. The studio lints the whole bundle against its own profiles, as they will be once imported under the same names.

The v3 design calls for a round-trip test (export, then unpack) that reproduces the documents.

## Provider delivery

A provider can ship profiles and scenarios inside the subscription. Everything below is described in full in
[PROVIDER_FEATURES.md](../../PROVIDER_FEATURES.md); this is the summary.

### Profiles

| Channel | Form |
| --- | --- |
| Inline | A top-level `rcx-profiles: {name: profile}` in the subscription YAML, and per `select` group `rcx: {profiles: [...], default: name, chips: [{label, include}]}`. Vanilla mihomo ignores both. |
| Bundle | `reclash-routing: <https url>` as a response header, or a `#reclash-routing: <url>` comment line in the body. The bundle is `{rcx: 1, profiles, groups, scenarios, scenario}`, at most 256 KiB, and binds to groups by name. |

What the subscription declares inline wins over the bundle. Provider profiles are addressed as `provider/<name>`;
`extends` may name `builtin/<name>` or another provider profile. A provider can only narrow a group's pool and
cannot enable `direct-split`. Hosts beyond the provider's own site need the user's [consent](engine.md#consent-for-provider-profiles).

```yaml
# fragment of a subscription (the proxies are omitted)
rcx-profiles:
  fast-de:
    rcx: 1
    title: Fast Germany
    prefer:
      - { label: Germany, when: 'country = DE' }
      - { label: Anything, when: 'not dead' }
proxy-groups:
  - name: Proxy
    type: select
    include-all: true
    rcx: { profiles: [fast-de], default: fast-de }
```

### Scenarios

| Channel | Form |
| --- | --- |
| Inline | A top-level `rcx-scenarios: {name: scenario}` plus `rcx-scenario: <name>` (the default). |
| Bundle | `scenarios: {name: scenario}` and `scenario: <name>`. |

Inline wins over the bundle. The user picks the scenario, or turns auto control off. A provider scenario with
diagnostics to third-party hosts needs consent.

```yaml
# fragment of a subscription (the proxies are omitted)
rcx-scenarios:
  work:
    rcx: 1
    title: Work
    description: Everything via Germany, internal sites direct.
    groups:
      $main: { profile: builtin/fastest }
    routes:
      - name: Intranet
        match: [DOMAIN-SUFFIX,corp.example]
        to: DIRECT
rcx-scenario: work
```

A complete delivery bundle, which `rcxlint` accepts as is:

```yaml
rcx: 1
profiles:
  fast-de:
    rcx: 1
    title: Fast Germany
    prefer:
      - label: Germany
        when: country = DE
      - label: Anything
        when: not dead
scenarios:
  work:
    rcx: 1
    title: Work
    description: Everything via Germany, internal sites direct.
    groups:
      $main: { profile: provider/fast-de }
    routes:
      - name: Intranet
        match: [DOMAIN-SUFFIX,corp.example]
        to: DIRECT
scenario: work
```

## rcx links

A link lets you share a profile or scenario in a chat message. The format is defined in `lib/common/rcx_link.dart`
and `lib/common/url_scheme.dart`.

```text
reclash://routing?p=<payload>
reclash://routing?url=<https url>
```

- `p` carries the YAML itself: raw deflate (level 9) of the UTF-8 text, then base64url without padding. The decoded
  text may be at most 64 KiB, enforced while inflating, so a small payload cannot expand into a huge one.
- `url` is an `https://` address of a file with the document. The downloaded file is at most 64 KiB.
- The link takes exactly one parameter, `p` or `url`. Anything else (a path, a fragment, extra parameters) is rejected
  as an invalid link.
- A pasted link works in the import field too; the app decodes it before reading the text.

The link opens the import review, not the library: the user sees the lint result and the consent prompt before
anything is saved.

## JSON schema and editors

`rcx-profile.schema.json` at the repository root describes a profile (at the root of the schema) and a bundle
(under `$defs.bundle`). It follows JSON Schema 2020-12 and is kept in sync with `core/rcx/profile.go` by a test that
compares key sets.

To get completion and inline errors in an editor that understands YAML schemas (VS Code with the YAML extension, for
example), map the schema to your files. In VS Code settings:

```json
{
  "yaml.schemas": {
    "./rcx-profile.schema.json": "*.rcx.yaml"
  }
}
```

Two cautions:

- The schema checks structure and value shapes. It cannot parse conditions; it only caps a condition's length at
  2048 characters, the same limit as the app.
- The schema describes profiles and bundles; for a scenario, rely on `rcxlint`.

## The rcxlint tool

`rcxlint` validates files the way the app does on import: same parser, same limits, same messages, with line
numbers.

```text
cd core
go run ./rcx/cmd/rcxlint <file.yaml>...
```

or, from the repository root:

```text
dart run tool/rcx.dart lint <file.yaml>...
```

It accepts three kinds of file, detected automatically:

| File | Detected by |
| --- | --- |
| Bundle | a top-level `profiles` or `scenarios` key |
| Scenario | a top-level `groups`, `routes` or `mode` key |
| Profile | anything else |

For a plain file, the id used is `provider/<file name>`. A file with `kind: bundle` is checked the way the app
imports it, with its profiles as `user/<name>`. A provider bundle without `kind` has profiles as `provider/<name>`, and
the tool also checks that the default scenario exists and that every group binding names a defined profile.

The exit code is 0 when no file has an error, 1 when any has, and 2 for wrong usage. Output is one line per issue:

```text
bad.yaml:3: error: prefer 1 (): unknown field "bogus"
profiles.yaml: warning: profile provider/p contacts example.com; allow them first
```

Warnings (for example an unused check, or hosts that need consent) do not fail the run. Because the
provider's form is checked, a profile that contacts third-party hosts always prints the consent warning; that is
expected, and the user decides at import.
