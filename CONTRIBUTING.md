# Contributing to ReClash

Thank you for taking the time to improve ReClash. Small, focused changes are easier to review and more likely to ship than broad rewrites. A good contribution explains the user problem, changes only what is needed, and includes the check that proves it works.

## Before you start

- Search existing issues and pull requests when repository Issues are available.
- You may send a pull request directly for a clear bug fix, test, translation, or documentation correction.
- Discuss large UI changes, new platform integrations, dependency replacements, and public API changes before investing in an implementation.
- Report security problems privately as described in [SECURITY.md](SECURITY.md).
- ReClash does not maintain or recommend proxy providers. Provider-specific account and subscription problems are outside the project scope.

## Development setup

Clone the repository with its mihomo submodule:

```bash
git clone --recurse-submodules https://github.com/Hoxiee/ReClash.git
cd ReClash
flutter pub get
```

Release CI pins Flutter 3.47.1 and Go 1.26.4. Android work requires JDK 17 and NDK r28c. Rust is needed for native helper components. Platform packaging must run on the target operating system.

Install the repository hooks once:

```bash
pre-commit install --hook-type pre-commit --hook-type pre-push --hook-type commit-msg
```

## Make the change

Follow the patterns already used near the code you touch. In particular:

- Use `flutter test`, not `dart test`, for application tests.
- Do not edit files under generated directories by hand.
- After changing models, Riverpod providers, or database schema, run:

  ```bash
  dart run build_runner build --delete-conflicting-outputs
  ```

- Keep platform lifecycle ownership in its existing layer. UI code requests transitions; desktop and Android platform code remain the source of truth.
- Add comments only for constraints that the code cannot express. Tests are preferred when behavior can be asserted.
- Keep pull requests focused. Unrelated cleanup belongs in a separate change.

The detailed architecture and repository rules live under `.agents/`. They are concise maintainer documentation, not generated policy.

## Verify the result

Run the narrowest relevant test while working, then the common gates before submitting:

```bash
dart format --output=none --set-exit-if-changed lib test tool plugins setup.dart
flutter analyze --no-fatal-infos
flutter test --reporter expanded
bash tool/check_plugins.sh
```

Native changes need their own checks:

```bash
cd core && CGO_ENABLED=0 go test . && CGO_ENABLED=0 go vet .
cargo test --manifest-path services/helper/Cargo.toml
```

A full platform build is welcome but not required when the change cannot affect packaging. In the pull request, state exactly what you ran and what you could not run.

## Commit messages and changelog

Commit subjects use Conventional Commits:

```text
<type>[(scope)][!]: <lower-case description>
```

Common types are `feat`, `fix`, `docs`, `refactor`, `perf`, `test`, `build`, `ci`, and `chore`. Keep the subject under 100 characters and do not add automated `Co-authored-by` trailers.

User-visible changes can provide release wording with a trailer:

```text
feat(profiles): support per-profile override scripts

Changelog: Per-profile override scripts
```

Use `Changelog: skip` when a collected commit has no user-visible effect. The commit hook validates the complete format.

## Pull request checklist

- The title is concise and follows the commit subject format.
- The description explains the problem and the resulting behavior.
- User-facing changes include screenshots or a short recording when useful.
- New behavior has focused tests, or the pull request explains why automation is not practical.
- Generated files are updated only through the documented generators.
- Logs, profiles, subscriptions, credentials, and personal data have been removed from the diff.

By participating, you agree to follow the [Code of Conduct](CODE_OF_CONDUCT.md).
