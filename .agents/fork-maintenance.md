# Fork Maintenance

ReClash keeps an append-only `vendor/flclash` of normalized snapshots and a separate `refs/reclash/product-base/current`
pointer. `dev` is a linear product history rooted at a parentless normalized product-base commit; its tree matches the
accepted vendor snapshot, but the product base has no vendor ancestry. Raw upstream ancestry is provenance only. Existing
`main`, tags and release conventions are not replaced by this protocol.

## Ordinary Development

Before editing known paths, run `dart run tool/fork.dart context --paths <path>` (repeat `--paths` as needed).
Use `--changed` for working changes or `--staged` for the index, including staged contract contents.
Read the returned contracts, not the entire registry. Overflow prints exact per-ID follow-ups; global `--json`
before the command returns the complete report. Text packets are limited to 6144 UTF-8 bytes, not tokenizer tokens.
Unknown paths are `unclassified`, never implicitly safe. Watches and sentinels are an impact index, not proof of isolation.

Update the relevant contract when intended behavior changes. Prefer feature-owned code with narrow integration seams
when useful; do not add generic adapters, duplicate subsystems, or refactor unrelated hotspots to avoid merge conflicts.
Keep intentionally removed behavior represented by a `removal` contract. No mandatory commit trailers are introduced.

For product work, follow [Feature Branches and Commit Shape](rules.md#feature-branches-and-commit-shape): use short-lived
feature branches/worktrees and integrate one thematic feature commit. `vendor/flclash` snapshots remain append-only; sync may
rewrite local `dev` so a parentless product-base commit from each accepted snapshot sits beneath the downstream stack.

## Contract Format

One `.fork/features/<stable.id>.yaml` per independent behavior; filenames supply IDs.

```yaml
v: 1
kind: feature
state: active
risk: routine
must:
  enabled: An already stored trimmed subscription URL cannot be imported twice when prevention is enabled.
watch: [lib/providers/actions/profiles.dart, lib/models/config.dart]
checks:
  profiles: [enabled]
drop: Upstream preserves the behavior and preference without our implementation.
```

Required keys: `v`, `kind`, `state`, `risk`, `must`, `watch`, `checks`.
Optional keys: `why`, `deps`, `drop`, `evidence`.
Kinds: `feature`, `fix`, `removal`, `identity`, `integration`, `meta`.
States: `active`, `upstream`, `retired`. Risks: `routine`, `critical`.
`deps` contains contract IDs; `checks` maps named config check groups to invariant IDs.
`upstream` requires observation-specific evidence and retains its checks. `retired` is a tombstone, not deletion of intent.
Paths are repository-relative; only `*` and `**` globs are supported. Normalization replacements/path mappings cannot chain. No aliases, tags, duplicate or unknown keys.
Check argv/cwd/host definitions live once in `.fork/config.yaml`; no shell command strings.

Audit actual assertions before claiming coverage. `check` reports schema validity and unmapped invariants separately;
`valid` is not a readiness verdict. Affected critical coverage gaps block verification. Routine gaps stay visible.

## Authority

An explicit sync request authorizes preparation, not acceptance, publication, releases or arbitrary production commits.
Resolve routine conflicts autonomously with decisions `keep`, `adapt`, `adopt`, `reduce`, `retire`, preserving contracts.
Stop for identity/storage compatibility, privacy/security, migrations, lifecycle/protocol, Core-source changes,
normalization/ownership/check-policy changes, weakened or retired intent, uncovered critical invariants, and unexplained
bootstrap deltas. Send affected IDs, the exact invariant/decision, evidence and a recommendation; at most two alternatives.
`--reviewed` records authorized review labels, not an independent approval mechanism or a test pass.
`--waive-check` requires explicit maintainer authority and records `waived`, never passed.

## Inspect and Bootstrap

First commit the maintenance layer and intended contracts through the normal reviewed development process.
Do not activate bootstrap while unrelated work is uncommitted or the baseline audit is unexplained.

```bash
dart run tool/fork.dart check
dart run tool/fork.dart --json bootstrap --inspect --source <full-local-raw-oid>
```

Inspection is read-only: no fetch, object writes, refs or checkout changes. Review every residual against committed
intended changes, not just matching filenames. WIP is counted separately. Existing conflict markers and release-line
identity/version disagreements are blockers, not rules to normalize away. Inspect reports are not an explanation ledger:
the reviewed audit must actually account for residuals before supplying its digest.

After explicit authorization:

```bash
dart run tool/fork.dart bootstrap --prepare --source <full-raw-oid> --id <unique-id> --audit <inspection-digest>
```

Preparation creates the initial V0 vendor snapshot and a separate parentless product-base commit with the same normalized
tree, then a locked candidate worktree. Bootstrap requires the exact source commit to be on the first-parent history of
captured `dev`; commits after it must be linear. The candidate starts at the product base and replays those downstream
commits. Review the replay and resulting tree before verification. This checks graph consistency, not the correctness of
the audited baseline. Preparation never advances `dev`, vendor or the accepted product-base ref. All writes are new owned
objects, refs, locked candidate worktrees and receipts.

## Normal Sync

```bash
dart run tool/fork.dart sync prepare --id <unique-id>
dart run tool/fork.dart --json impact --from vendor/flclash --to refs/reclash/prepared/<id>
dart run tool/fork.dart --json stats --vendor vendor/flclash --downstream dev
```

The source URL and branch are explicit in config; the remote named `upstream` is not guessed.
Fetch uses no tags, pruning or submodule recursion, into create-only `refs/reclash/upstream/<id>`.
Optional `--source <local-oid>` avoids fetch. Same raw tree and recipe produces a bundled history-only observation.
Vnext has only V as its parent; raw OID/tree and normalizer digest are provenance trailers, not raw-history parents. Sync
also creates a parentless product-base commit P whose tree and provenance match Vnext; `refs/reclash/product-base/current`
tracks the accepted P independently of `vendor/flclash`. The product base must never inherit vendor ancestry.
Every vendor commit has `Changelog: skip` because the existing generator traverses non-merge vendor ancestors. Product
notes belong on ordinary product commits, not only merge bodies excluded by that generator.

Candidate: `sync/<id>`, normally `.claude/worktrees/fork-<id>`. It is prepared by rebasing commits after the accepted
product-base ref onto the new parentless product base; commits after the accepted base must be linear. Inspect the replay
inventory and resulting tree. Resolve rebase conflicts in the locked candidate, continue the rebase, then commit any
ownership or policy adaptations before verification. Changes use endpoint trees and typed path reports; rename recognition
is deliberately disabled, so both sides appear as delete/add. Run focused tests per compilable cluster, then finish the
candidate only within granted authority. Deferred tests must run after assembly.
Global Git settings are not modified; per-command rerere autoupdate is disabled. Unknown executable merge/filter drivers
block checkout; standard git-lfs filters are allowed with smudge downloads disabled.

Normalization preserves modes, binaries, symlinks and upstream gitlink semantics. It may rename `core/Clash.Meta` to
`core/mihomo`, but never substitutes our engine fork/branch/SHA. Core source changes require review even on clean merges.
Ownership policy restores our `CHANGELOG.md`, `changelog.json` and only the `pubspec.yaml` version field, not dependencies.
Do not blanket-keep upstream manifests/workflows or invent branding replacements to hide behavioral changes.

For an approved recipe change, first use the exact accepted `Upstream-Commit`, inspect with the new recipe, then:

```bash
dart run tool/fork.dart sync prepare --id <id> --source <accepted-raw-oid> --recipe-migration --audit <digest>
```

This creates a separate vendor observation with the same raw source. It cannot mix a new source and recipe migration.
Review label `normalization-policy` is additionally required. Reproduce old normalization using the archived downstream
implementation/config revision, not today's script.

## Verify and Accept

```bash
dart run tool/fork.dart sync verify --id <id> --reviewed <authorized-label>
dart run tool/fork.dart sync accept --id <id>
```

Repeat/comma-separate authorized labels as needed. Special labels: `bootstrap-audit`, `unclassified`, `core-source`,
`normalization-policy`; affected critical contract IDs are also required. No label is supplied automatically.
Verification requires a committed clean candidate whose first-parent chain starts at the prepared product base, with no
rebase in progress or merge commits above it. The prepared base must be parentless, have the prepared vendor tree, and
carry matching provenance. Verification also requires unchanged expected refs/policy, no markers, preserved release
fields and complete replay inventory. It runs full baseline checks plus affected feature/platform checks and stores
candidate commit/tree, replay input/output lists, digests, argv, tool versions, logs and results outside source.
Wrong-host checks block unless explicitly waived. Native/device gaps are not made green by passing Dart tests.

Acceptance needs separate authority and the exact verified candidate. It compare-and-swaps local `dev` from the captured
old OID, even when the update is non-fast-forward; a checked-out `dev` must be clean and is reset only after that CAS.
Then it advances `vendor/flclash` and `refs/reclash/product-base/current` with expected-old validation. If interrupted
after `dev` advanced, retry accept; recovery completes either metadata-ref update only when each ref still has its
captured old or expected new OID. Never roll `dev` back or touch `main`/tags. If `dev` advanced differently, prepare a
new candidate.

## Archives and Recovery

`git rev-parse --path-format=absolute --git-common-dir` locates shared state, including linked checkouts.
Receipts/check logs and `snapshot.bundle` live under `<common-dir>/reclash-fork/<id>/`.
Bundles contain declared raw/prepared vendor, accepted/prepared product-base, and candidate refs and are verified on creation; tests import them into a fresh bare repo.
They do **not** contain submodule objects or LFS payloads. Offline Core recovery needs its own explicitly created archive.
Never upload or prune archives/worktrees automatically.

```bash
git bundle verify <snapshot.bundle>
git init --bare <new-empty-recovery-directory>
git -C <new-empty-recovery-directory> fetch <absolute-snapshot.bundle> 'refs/*:refs/*'
git worktree list --porcelain
git -C <candidate-path> status
git log --first-parent vendor/flclash
```

Use a fresh destination for recovery. Do not overwrite current refs to restore a bundle.
Locked candidates remain available after failures. Inspect ordinary Git state and the receipt before retrying;
IDs are create-only and deliberately not recycled. Cleanup is a separate explicit operation.
Divergence metrics report observed vendor intervals (up to 20), not raw rewritten commit activity or a magic health score.

## Baseline and Daily Loop

The initial source audit and intentional delta groups are documented in [fork-baseline.md](fork-baseline.md).
Commit the prepared maintenance changes separately from unrelated feature WIP, then inspect that exact committed dev.
Working-tree fixes do not erase markers from the old committed revision inspected by the tool.

For each feature: obtain path-scoped context, implement the smallest useful integration seam, add/update invariants and
focused tests, then run the mapped checks and `dart run tool/fork.dart check`. New navigation and localization have
separate contracts; do not hide them inside a generic UI/rebrand record. Source-tree formatting uses
`dart tool/check_format.dart`, which checks handwritten tracked/unignored source without rewriting generated output.
Local ignored `project/` research is excluded from analyzer input, not from product tests or source checks.

For each sync: prepare a unique observation, read impact and unknowns, resolve dependency clusters, run focused tests,
finish the candidate, verify the assembled commit, and accept only within explicit authority. Verification recomputes
impact from candidate edits as well as source paths; an adaptation cannot skip critical/platform checks merely because
upstream did not touch that path. Reuse existing candidates for investigation, not IDs for fresh preparations.

Localization sync relocates upstream ARBs to `arb_upstream/` and upstream-generated Dart to `upstream_l10n/`; only ARBs
are inputs to the fragment assembler. ReClash feature fragments live under `arb/fragments/`, and the assembler generates flat
`arb/intl_<locale>.arb` inputs for app localization codegen. A recipe path change requires a reviewed recipe migration;
never resolve an upstream locale conflict by editing assembled outputs alone.

The normalized product line starts at `0.1.0-pre.1`; ReClash-Alpha version history is unrelated. No release tags exist before `v0.1.0-pre.1`; the earlier tags and GitHub releases were removed.
Website/package destinations and their external availability remain product policy; no test here claims that a hosting
account, F-Droid signing fingerprint, app store or update channel is actually published or controlled.
No fixed sync schedule, new release topology, replay queue, release ledger, automatic agent fan-out or automatic
publication is introduced. Root tests do not replace native builds on affected platforms.

## Engine Fork (mihomo)

The engine fork (`Hoxiee/mihomo`, branch `ReClash`) always has exactly this history, top first, regardless of what is
patched or why:

```
feat: support ReClash
feat: support FlClash
<upstream release tag>
```

New engine changes are folded into one of the two commits, never added as a third. An upstream bump rebases both
commits onto the new release tag. After any history rewrite, check that `git log --oneline <tag>..HEAD` lists exactly two
commits, keep a local backup branch, and push with `--force-with-lease` pinned to the previous remote SHA.

## Operator Quick Start

1. Inspect the exact released raw commit, not an upstream development branch guessed from a tag name.
2. Review the residuals and use `report` for owners, invariants, dependencies and check argv.
3. Prepare once with a unique ID. Preparation creates objects and a candidate but never accepts it.
4. Resolve replay conflicts in the assigned candidate. Keep release identity and Core ownership separate.
5. Run focused checks, then inspect `status`. Missing checks and missing platform hosts remain missing evidence.
6. Commit the candidate only with separate authority. `verify` requires a clean committed candidate and authorized reviews.
7. Accept and publish only after separate explicit authorization. A valid schema or green report grants neither.

```bash
dart run tool/fork.dart --json report --changed
dart run tool/fork.dart --json report --from vendor/flclash --to refs/reclash/prepared/<id>
dart run tool/fork.dart --json status --id <id>
```

`status` is read-only: it compares captured refs, candidate cleanliness, current verification, release identity,
review labels and platform/check evidence. It never executes checks, refreshes receipts, issues waivers or accepts.
`check` validates schema only. `report` describes impact only. `verified` describes evidence for one exact commit.
External checks recorded outside a verification receipt are not silently imported as proof.

### Maintenance Metadata

`.fork/maintenance.yaml` extends reporting without changing the existing feature schema or normalization algorithm.
Feature entries declare path ownership (`upstream`, `downstream`, `shared`), evidence types per existing invariant,
and review guidance. Types describe required evidence, not assertions that it exists. Unmatched paths remain unclassified.
`release` names downstream identity fields or complete files to compare with captured development state; it does not
rewrite them. The normalizer still preserves upstream gitlinks; the downstream replay owns the selected engine pin.
`paths` classifies non-Dart changes and lists external checks. The changed-test selector prints those checks but does
not run them or label them passed. Add real checks before adding classification; do not hide unknown changes as docs.

### Database Compatibility Cookbook

The SQLite `user_version` is scoped to a product lineage, not a global compatibility number. FlClash schema 21 and
ReClash schema 21 have different columns. `.fork/maintenance.yaml` records supported source shapes, target schema,
fixture tests and downgrade policy. A supported shape has migration and backup tests; a matching integer alone is not proof.

- Local upgrade: run the normal Drift transaction, adding only missing columns/tables in the next release step.
- Foreign backup: extract and migrate the staging copy, validate all rows, then apply through the existing restore owner.
- Source archive: never rewrite it or stamp its schema number to bypass incompatibility.
- Unknown newer schema: reject explicitly; inspect the new release and add a tested source shape before supporting it.
- Same-number collision: converge the two known shapes in a higher ReClash migration, preserving existing fields.

```bash
dart run tool/database_schema.dart inspect <staged-database>
dart run tool/database_schema.dart diff <before-database> <after-database>
dart run tool/check_generated_contracts.dart
```

The inspector opens SQLite read-only. Compare schema shape and rows in regression tests; a schema diff alone cannot
prove semantic preservation. Generated-binding checks catch mismatched Dart/Rust generation identity, while native
builds remain required for ABI, toolchain and platform integration.

### Recipe Migration and Chained Preparation

Finish and commit a standalone recipe-migration candidate first, with separate commit authority. A following sync may
use that exact clean candidate without temporarily accepting the recipe into development:

```bash
dart run tool/fork.dart sync prepare --id <next-id> --source <released-raw-commit> --after <recipe-id>
dart run tool/fork.dart --json lineage --id <next-id>
dart run tool/fork.dart --markdown status --id <next-id>
```

The predecessor must be an unaccepted standalone recipe migration with matching policy, protected refs and recovery
bundle. Its receipt digest and exact candidate are captured and checked again; a create-only predecessor ref is included
in the child bundle. Accepted development/vendor/product-base refs are not moved. `--after` cannot combine with
bootstrap, audit or recipe migration. Final chain verification validates the captured predecessor again, unions predecessor and final candidate impact, and
requires `normalization-policy` plus all affected critical/Core review labels. It binds predecessor metadata into the
verification receipt and checks it again after tests. Accept revalidates the exact predecessor before any development
change; only the final child is accepted. The predecessor receipt stays immutable, preserving the captured digest.
Interrupted acceptance tolerates only the original or expected final vendor/product-base refs; it never accepts an
unrelated ref movement. Do not edit receipts to bypass stale inputs.

For overlap triage, compare normalized upstream snapshots and the corresponding downstream product range, not unrelated
raw and branded trees. Both ranges are explicit; shared path names prioritize review but do not prove semantic conflicts:

```bash
dart run tool/fork.dart --markdown report --from <old-vendor> --to <new-prepared-vendor> --downstream-from <old-product-base> --downstream-to <candidate>
```

The existing `specs` and `tools` checks exercise setting destinations, nested navigation and rendered workspace behavior.
When upstream moves a setting, keep its stable ID, update its actual page and catalog parent, and test scrolling and taps
at the real viewport. A source-pattern scan or a matching route object alone is not visual or interaction evidence.

### Managed Development Archives

Every acceptance creates `archive/dev-before-<sync-id>` at the captured old `dev`, before moving development. Use
unique descriptive sync IDs such as `flclash-v0.9.2-20261024`; the corresponding archive is
`archive/dev-before-flclash-v0.9.2-20261024`. Archive names are stable, not rotating `previous-1`/`previous-2` aliases.
The accepted receipt records its ref, exact commit and acceptance order. A verified `development-before.bundle` in
the observation directory preserves that history independently of retention. Submodules still need separate bundles.

Keep the latest **two** receipt-managed accepted archive branches, ordered by acceptance, not commit date or name.
After acceptance succeeds, prune older managed refs using expected-old OIDs. Never prune unknown/manual branches,
release tags, vendor snapshots, receipts or recovery bundles. An archive collision, changed OID or checked-out archive
blocks the affected operation instead of overwriting or force-deleting it. A retention failure after acceptance is
reported as an error; inspect refs and retry the same acceptance, never silently roll development back.
This local policy neither pushes nor deletes remote branches. Remote archive publication/pruning needs explicit
publication authority and must preserve the old remote development OID before a force-with-lease update.

### Current Native Host Limitation

The maintainer currently has no Windows or macOS host and accepts deferring their native checks. For verification,
record explicit waivers for `windows-build` and `macos-build` only when selected and unavailable; do not remove these
checks from contracts or call them passed. Record the missing hosts and residual packaging/service/ABI risk in the
handoff. This allowance does not waive Linux, Android, portable tests, critical reviews, commit, acceptance or push
authority. A later available host must run the native checks before claiming platform verification.
