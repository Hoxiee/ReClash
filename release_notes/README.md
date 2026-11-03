# Release notes

One authored file per tag, `<exact-tag>.md`, in English. CI renders it on the GitHub release page, the update sheet
shows it under release details, and `dart run tool/changelog.dart changelog` assembles `CHANGELOG.md` from these files.
The workflow and writing rules live in [the release skill](../.agents/skills/release/SKILL.md).

```markdown
The simple dashboard becomes the default and forecasts your traffic.

### New

- **Traffic forecast**: the traffic card estimates when your quota runs out, based on recent
  daily usage.

### Fixed

- Web dashboards no longer close on a back swipe.
```

- An optional lead paragraph, then `###` sections in this order, each only when it has entries: `Breaking changes`,
  `New`, `Improved`, `Fixed`, `Known issues`.
- Sections hold `- ` bullets; a continuation line starts with two spaces. No other headings, no HTML comments, no
  commit hashes. `dart run tool/changelog.dart verify` enforces this.
- `CHANGELOG.md` keeps every stable release and drops a version's prereleases once its stable notes exist.
