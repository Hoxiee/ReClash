---
name: release
description: Use when bumping the ReClash version, preparing or tagging a prerelease or stable release, writing release notes or the in-app update summary, regenerating CHANGELOG.md, or fixing the notes of a published GitHub release.
---

# Release

Every tag ships two authored texts, written from the same digest in one prepare commit:

| File | Reader | Shape |
| --- | --- | --- |
| `release_notes/<tag>.md` | GitHub release page, update sheet details, `CHANGELOG.md` | English Markdown, complete but compact |
| `release_summaries/<tag>.json` | update sheet and Telegram post | `en` + `ru`, headline, spotlight, ≤10 highlights |

Commits are raw material only. Nothing reaches users without someone rewriting it.

## Workflow

Run this on `dev` with a clean tree, as a task of its own, never inside a feature branch or worktree.

1. `tool/release.sh prepare pre` (or `stable`, `--version X.Y.Z` for a minor or major bump). It bumps `pubspec.yaml`
   to the next tag, creates both skeletons when missing and prints the digest. It commits nothing, and an authored file
   that already exists stays as it is.
2. Write `release_notes/<tag>.md` from the digest, then `release_summaries/<tag>.json` from the notes. Read the body
   with `git log -1 --format=%B <hash>` when an entry is unclear, and its diff only when the body leaves the outcome open.
3. `dart run tool/changelog.dart changelog && dart run tool/changelog.dart verify`. Show the user both texts (the notes
   and the `en` and `ru` summary) and wait for their verdict on the wording.
4. Once the user asks for the commit: `git add pubspec.yaml CHANGELOG.md release_notes/<tag>.md release_summaries/<tag>.json`
   and `git commit -m "chore(release): prepare <tag>"`. The bump and both texts always land in this one commit.
5. Once the user asks for the publication: `tool/release.sh tag --push`. It refuses unless HEAD carries both committed
   files for the pubspec version, then tags and pushes the branch and the tag by name. CI renders the body from the
   tag and publishes it.

`prepare` can run again on the same untagged tag; it only advances the build number. To abandon a prepare, restore
`pubspec.yaml` and delete the skeletons it created.

## Notes

Range: a prerelease covers the commits since the previous tag; a stable release covers everything since the previous
stable and restates it from the cycle's prerelease notes, which `digest` prints first.

- Describe the net change across the range. A feature added and removed inside the range never existed; a fix for a
  bug the same range introduced is not a fix; a feature reworked three times is one entry in its final shape.
- Leave out what no user can observe: CI, tests, tooling, fork and upstream sync, the website, refactors, internal
  renames. A dependency or Core update counts only for its visible effect, named with the new version.
- Optional lead line: one sentence on what the release is about. Then the sections, in this order, each only when it
  has entries: `### Breaking changes`, `### New`, `### Improved`, `### Fixed`, `### Known issues`.
- New and Improved bullets read `- **Feature**: what the user can do now.` Fixed bullets name the symptom that is
  gone: `- Web dashboards no longer close on a back swipe.` Breaking changes say what breaks and what to do.
- One bullet per user-visible outcome; merge the commits behind it. Name the platform when it is not every platform.
  Usually 5–20 bullets; past 25, merge further.
- No commit hashes, scopes, class or provider names, ticket numbers, "various improvements" or "refactor". Wrap
  continuation lines with two spaces. `verify` enforces the headings, the bullets and the absence of hashes.

## Summary

The summary is a short cut of the notes for a phone screen; every highlight must trace back to a notes bullet. Write
what changed for the user, never a commit list. One headline, one spotlight, usually five highlights. Warnings only
for something the user must act on, and each one matches a Breaking changes or Known issues bullet. Write `en` first,
then a natural `ru`, with the same warning count, order and platforms. The schema and limits live in
`release_summaries/README.md`.

## Agents

The leading session writes both texts: they are product copy. For a stable digest longer than about 150 lines, hand it
to `scout` and ask it to cluster the entries into user-visible outcomes, citing the hashes; write the notes from its
clusters, not from its wording. A feature session that finishes work leaves the release alone; trailers on its commits
are its only release copy.

`Changelog:` trailers still help: the digest prints the trailer instead of the subject, and `Changelog: skip` moves a
commit to the "Other commits" list. See the trailer rules in `.agents/rules.md`.

## Fixing a Published Release

Edit `release_notes/<tag>.md` (and the summary when it is wrong), regenerate `CHANGELOG.md`, commit as
`docs(release): correct <tag> notes`, then, with the user's approval for the publication:

```bash
tag=v0.1.0-pre.4
dart run tool/changelog.dart render release --tag "$tag" --out release.md
sed "s|VERSION|${tag#v}|g" .github/release_template.md >> release.md
gh release edit "$tag" --notes-file release.md && rm release.md
```

The update sheet reads the edited body on its next check; the Telegram post stays as sent.

## Never

- Bump `pubspec.yaml`, create a release file or tag outside `prepare` and `tag`.
- Edit `CHANGELOG.md` by hand; it is generated from `release_notes/`.
- Paste the digest, or let a summary highlight appear without a notes bullet behind it.
- Commit, tag or push without the user asking for that step.
