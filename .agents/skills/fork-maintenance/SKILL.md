---
name: fork-maintenance
description: Use when auditing the ReClash fork baseline, preparing or resolving FlClash vendor syncs, changing fork contracts or normalization, inspecting upstream impact, or verifying and accepting a sync candidate.
---

# Fork Maintenance

Read `.agents/fork-maintenance.md` before changing maintenance policy or preparing a sync.
Use `dart run tool/fork.dart context --paths <path>` for relevant contracts, not broad repository research.
Separate routine preparation from explicit authority for critical review, production commits, acceptance and publication.
Use disposable Git repositories for tool regression tests. Never activate a real bootstrap as an implementation test.
Keep caller WIP untouched. Preserve downstream behavior, release metadata and Core-source ownership.
Finish with schema/tool/affected feature checks and the applicable full/platform verification; report missing checks plainly.
