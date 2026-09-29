---
name: provider-standard
description: Use when adding, changing, or removing a subscription-response HTTP header, dashboard widget, or appearance token in ReClash, so the generated provider standard (PROVIDER_HEADERS.md + provider_standard.g.json) and the vendored site copy stay in sync.
---

# Provider Standard

## When To Use

Use this whenever you touch the provider wire contract: a `reclash-*` (or alias) response
header, a `DashboardWidget`, or an appearance token (`reclash-view`/`hex`/`background`/
`heroring`/`heroeffect`). The contract is **generated**, not hand-written, and the site
vendors a copy — skipping a step leaves users and the site guessing.

Do not hand-edit `PROVIDER_HEADERS.md` or `provider_standard.g.json`; they carry a
`do not edit by hand` banner and are overwritten on every regenerate.

## Mental Model

Three model files are the single source of truth for **structure**:

- `lib/models/panel_headers.dart` — the `_panelHeaderConverters` list (`sourceKeys`,
  `canonicalKey`, optional `convertValue`).
- `lib/enum/enum.dart` — `DashboardWidget` (+ platform/mode gating lists).
- `lib/models/panel_appearance.dart` — the appearance token maps and constraints.

`tool/gen_provider_standard.dart` text-parses those, merges human prose from
`tool/provider_standard_docs.dart`, and writes both artefacts. A coverage guard
(`_requireCoverage`) **fails the build** if a derived header/widget/external key has no
prose entry — so the docs can never silently drift.

## Add A Header

1. Add a converter entry to `_panelHeaderConverters` in `lib/models/panel_headers.dart`.
   List `sourceKeys` in priority order (canonical `reclash-*` first, then aliases). Set
   `canonicalKey` to a camelCase id. Attach `convertValue` only if the value needs
   decoding/transforming.

   ```dart
   _PanelHeaderConverter(
     sourceKeys: ['reclash-example', 'flclashx-example'],
     canonicalKey: 'exampleHeader',
     convertValue: _decodeBase64Header, // optional
   ),
   ```

2. If you introduce a **new** `convertValue` function, register its stable tag in
   `_transformTags` in `tool/gen_provider_standard.dart` (else the generator throws
   `unknown transform`). Existing tags: `_decodeBase64Header` -> `base64`,
   `_decodeTrimmedBase64Header` -> `base64-trimmed`, `_hoursToMinutes` -> `hours-to-minutes`.

3. Add the prose entry to `headerDocs` in `tool/provider_standard_docs.dart`, keyed by the
   **canonicalKey**. `value` and `purpose` are required; `example` (a full wire line) is
   optional and, when present, is emitted in the Response-example block in converter order.

   ```dart
   'exampleHeader': {
     'value': 'Plain text or Base64',
     'purpose': 'What it does and any HTTPS/format constraint.',
     'example': 'ReClash-Example: some-value',
   },
   ```

4. Regenerate the artefacts:

   ```bash
   dart run tool/gen_provider_standard.dart
   ```

5. Verify (all must pass):

   ```bash
   dart run tool/gen_provider_standard.dart --check   # artefacts up to date
   flutter test test/tool/provider_standard_test.dart # model<->artefact match
   tool/check_comment_density.sh                      # docs file is data, stays <5%
   flutter analyze --no-fatal-infos
   ```

6. Vendor into the site and commit there too (site has no fork clone):

   ```bash
   python tools/check_fork_headers.py --sync   # run from the reclash-site repo
   ```

   Then commit the fork (all four: `panel_headers.dart`, `provider_standard_docs.dart`,
   `provider_standard.g.json`, `PROVIDER_HEADERS.md`) and, separately, the site's
   re-vendored `gen/provider_standard.g.json`.

## Add A Widget Or Appearance Token

- **Widget:** add the value to `DashboardWidget` in `lib/enum/enum.dart` (with its
  `platforms:`/`modes:` gating), then add a one-line entry to `widgetDocs` in
  `tool/provider_standard_docs.dart`. Regenerate + verify as above.
- **Appearance token:** add it to the relevant map in `lib/models/panel_appearance.dart`
  (`_proxiesTypes`, `_sortTypes`, `_layouts`, `_iconStyles`, `_cardTypes`,
  `_schemeVariants`, `_heroEffects`). Token lists are derived automatically; only edit the
  section prose in `provider_standard_docs.dart` if the explanation changes.

## Pitfalls

- The coverage guard is bidirectional: a `headerDocs`/`widgetDocs` entry with **no**
  matching converter/enum value is also a failure (`stale: ...`). Remove prose when you
  remove a header.
- Angle-bracket values (`upload=<bytes>`) are auto-wrapped in code spans in markdown by
  `_cell()`; keep them plain in the docs strings (no manual backticks).
- Prose strings with an apostrophe (`user's`) must use double-quoted Dart literals.
- `tool/provider_standard_docs.dart` is pure `const` data — no Flutter/package imports, so
  it keeps the generator runnable with `dart` alone.
- The site's `check_fork_headers.py` compares the **full JSON text** for freshness; it
  reads only structural keys, so added `value`/`purpose` never break its shape check but a
  missing `--sync` will flag the vendored copy as stale.
