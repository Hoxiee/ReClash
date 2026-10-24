---
name: fork-maintenance
description: Use when auditing the ReClash fork baseline, preparing or resolving FlClash vendor syncs, changing fork contracts or normalization, inspecting upstream impact, or verifying and accepting a sync candidate.
---

# Fork Maintenance

Read `.agents/fork-maintenance.md` for protocol details and `.agents/rules.md` for commit/safe-run rules.
Run `dart run tool/fork.dart context --paths <path>` before edits. Work only in the assigned checkout, preserve caller
WIP, and test tooling in disposable repositories. Never activate a real bootstrap as an implementation test.

## Authority and History

Preparation, commits, critical reviews, acceptance and publication are separate permissions. A sync request alone
permits preparation, not commits or acceptance. Never invent `--reviewed` labels or treat green tests as authority.
`vendor/flclash` is append-only normalized snapshots. Product bases are parentless with the corresponding vendor tree;
`dev` is a linear downstream replay above the current product base. Accept replaces development history, not a merge.
Keep release tags unchanged. Never merge an old product base back into the new development line.

## Required Sequence

1. Read captured refs, caller state, exact released raw commit and normalization policy. Use `bootstrap --inspect`
   only for the first audited baseline; existing initialized history uses `sync prepare`.
2. Inspect `--json report` and contract dependencies; separate identity/storage/privacy/lifecycle/Core/policy decisions
   for authorized review. Preserve downstream release metadata and engine-source ownership.
3. Prepare once with a unique descriptive ID, for example `flclash-v0.9.2-20261024`. Resolve replay in the assigned
   candidate; do not change accepted development/vendor/product-base refs. Do not reuse observation IDs.
4. If normalization changed, prepare a standalone recipe migration on the accepted raw source with its reviewed audit.
   Finish that candidate first. Prepare the release child with `sync prepare --id <child> --source <raw> --after <recipe>`.
   The predecessor must be clean, committed, standalone and unaccepted, with matching policy, refs and verified bundle.
   Do not accept the recipe separately once a child captures it. Multi-hop chains are unsupported.
5. Run focused checks per cluster; commit only with authority. A changed policy invalidates preparation: reconcile
   and prepare again, never alter receipt fingerprints. Keep engine history at exactly two support commits.
6. Inspect `status --id` and `lineage --id`. Run formal `sync verify` only on the complete clean committed candidate.
   Chain verification includes predecessor impact, requires authorized `normalization-policy` and affected critical/Core
   labels, and binds exact predecessor inputs. Both missing evidence and stale inputs must remain visible.
7. Windows/macOS native hosts are currently unavailable. The maintainer permits explicitly recorded waivers for
   selected unavailable `windows-build`/`macos-build`; never mark them passed. All available-host checks and critical
   reviews still apply. Report native gaps; do not invent external evidence.
8. Stop before `sync accept` unless separately authorized. It must archive original development first, validate exact
   verification and predecessor, then advance only captured dev/vendor/product-base refs. Moved dev requires reconciliation.
9. If acceptance is interrupted, inspect status and refs, then retry the same ID with acceptance authority. Do not
   roll back development, edit receipts, or manually fast-forward intermediate chain observations.
10. Push only with separate authority. Publish the old development archive before rewriting remote development;
    use force-with-lease pinned to the inspected remote OID, never blind force. Acceptance itself is local only.

## Archive Contract

Use `archive/dev-before-<sync-id>`; names never rotate. Retain the latest **two** accepted receipt-managed archive
branches by acceptance order. Acceptance creates a verified `development-before.bundle` before moving dev, then prunes
older matching managed refs after success. Never overwrite collisions, delete checked-out archives, prune manual refs,
move release tags, or delete receipts/bundles as retention. Local pruning does not authorize remote deletion.
A pruning error after refs moved is an interrupted operation: inspect and retry, do not claim nothing changed.

## Tools and Completion

- `--json report --changed`: owners, invariants, dependencies, check argv and host requirements.
- `--markdown report --from <old-vendor> --to <new-vendor> --downstream-from <old-base> --downstream-to <candidate>`:
  explicit path overlap for review; not semantic-conflict proof.
- `--json status --id <id>` / `--json lineage --id <id>`: read-only freshness/blockers and captured ancestry.
- `dart run tool/database_schema.dart inspect <db>` / `diff <before> <after>`: read-only schema diagnosis.
  Same schema number across products is not compatibility; backup migration stays in staging, newer unknowns reject.
- `dart run tool/check_generated_contracts.dart`: FRB identity/sibling consistency; not a native ABI test.

Finish with `flutter pub get`, `flutter analyze --no-fatal-infos`, changed tests, relevant tool/platform checks,
format/schema/l10n/comment-density gates. Check actual output, not a wrapper exit code alone. Non-Dart classifications
list external checks without running them. Report exact tests, missing hosts, waivers and authority boundaries.
Preserve tracked and untracked recovery material. Do not claim acceptance or publication without actually performing it.
