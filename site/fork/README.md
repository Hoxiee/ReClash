# Fork Atlas

A local, read-only maintenance workspace for ReClash, using the release site's design tokens and the existing Dart fork registry.

## Run

From the repository root, with the root Flutter dependencies already resolved:

```bash
dart run site/fork/server.dart
```

Open `http://127.0.0.1:8788/fork/`. Use `--port 8789` for another port, or `--root /path/to/ReClash` to inspect another checkout. Stop the server with Ctrl+C.

The release landing page is unchanged. Opening the Atlas HTML through a static server cannot read Git: the local Dart server supplies a session token and the read-only API. No repository snapshots or receipts are embedded in browser source or written under `site/`.

## Workspace

- **Contracts:** explicit dependency graph, searchable registry, invariant/check mappings, watch patterns, matching checkout files, sentinels and source YAML.
- **Impact:** working changes, staged changes, downstream/vendor comparisons, two refs, or one inspected path. Staged comparisons read contract metadata from the index. Reasons distinguish direct watch/sentinel matches from transitive impact.
- **Sync:** existing receipts, raw/normalized/product comparisons, separate vendor and product histories, available replay inventories, reviews, waivers and bounded logs. Older receipts remain historical records; missing fields are not inferred.
- **Checks:** declared commands and mappings, host requirements, and archived results. Commands can be copied, never executed by Atlas.
- **Attention:** source/base problems, normalizer drift, unmapped invariants and unclassified downstream paths. A stale-data banner appears when the checkout changes.

Search with `/`. Select a graph node with click or Enter. Drag the map to pan, use Ctrl/Command + scroll to zoom, and use the fit button to reset. The relation list provides the same dependency information without a diagram.

A watch relationship is not a code call. Mapped checks are not proof of assertion quality. Archived passes are not current readiness. Waivers are not passes, and review labels do not grant authority.

## Read boundary

The server binds only to IPv4 loopback, validates Host and Origin, and requires a per-process token for API requests. It exposes GET only and an explicit asset allowlist. Repository paths and revisions are validated; file, diff and log previews are bounded. Symlinked parent paths are not followed. Git optional locks, hooks, LFS smudge and external diff/textconv execution are disabled by the existing Git reader and the Atlas diff options.

Atlas never fetches upstream, runs mapped checks, prepares or accepts a sync, edits contracts, or writes repository refs/index. The API uses `Registry`, `VendorSync` read helpers and the existing impact clustering function rather than a second JavaScript implementation of fork policy. Expensive repository reads run outside the HTTP isolate.

## Verify

```bash
node --test site/fork/test/model_test.mjs
flutter test site/fork/test/server_test.dart
dart format --output=none --set-exit-if-changed site/fork/server.dart site/fork/src site/fork/test
dart analyze site/fork
```

The Dart tests use disposable Git repositories, not the live maintenance baseline. Browser smoke checks require an existing Playwright installation and a running local Atlas server:

```bash
node site/fork/test/browser.mjs \
  --url http://127.0.0.1:8788/fork/ \
  --playwright /path/to/playwright/index.mjs \
  --out /tmp/reclash-atlas-browser
```

Omit `--playwright` if Node can already resolve the package. Keep `--out` outside the repository: screenshots contain local checkout data. The smoke test reads real contracts, comparisons and existing receipts; stale/error presentation uses intercepted responses without editing the checkout. Missing historical receipts are reported as skipped, never fabricated.
