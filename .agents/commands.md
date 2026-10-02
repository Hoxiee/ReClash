# Commands

## Building

Update submodules first. The mihomo Go core lives in `core/mihomo/`.

```bash
git submodule update --init --recursive
```

Full package build, including Go core, Flutter, and packaging, runs through `setup.dart`:

```bash
dart setup.dart macos
dart setup.dart linux
dart setup.dart windows
dart setup.dart android
```

Build only the Go core and skip Flutter packaging:

```bash
make core-macos
make core-linux
make core-windows
make core-android
```

Pass `ARCH` or `TARGET_PLATFORM` through `make` when needed, for example:

```bash
make core-macos ARCH=arm64
make core-android TARGET_PLATFORM=android-arm64
```

Core builds use setup's input fingerprint cache. Pass `FORCE=1` to bypass it,
for example `make core-macos ARCH=arm64 FORCE=1`.

The Makefile wraps `plugins/setup/buildkit/run_build_tool.sh`; prefer the `make` entry points unless debugging the build tool itself.

## Flutter Development

Use the default Flutter SDK directly:

```bash
flutter pub get
flutter run
flutter test
```

Use `flutter test`, not `dart test`, because models pull in Flutter types.

## Code Generation

Run code generation after modifying models, providers, or database schema:

```bash
dart run build_runner build --delete-conflicting-outputs
dart run build_runner watch
```

Code generation covers:

- Riverpod providers through `riverpod_generator`.
- Models through `freezed` and `json_serializable`.
- Database tables through `drift_dev`.

Generated output paths, configured in `build.yaml`:

- `lib/models/generated/*.g.dart`, `*.freezed.dart`.
- `lib/providers/generated/*.g.dart`.
- `lib/database/generated/*.g.dart`.

## Testing

Tests use `package:test/test.dart` for pure Dart logic and `flutter_test` for provider and widget tests. `mocktail` is the mocking framework.

```bash
flutter test test/models/
flutter test test/core/
flutter test test/core/desktop/
flutter test test/providers/
flutter test test/common/
flutter test test/database/
flutter test test/widgets/
flutter test test/setup_test.dart
flutter test plugins/proxy/test/proxy_test.dart
```

Root `flutter test` only discovers the root package's `test/` directory by default. Include bundled plugin Dart tests by passing paths explicitly, or run `flutter test` from that plugin package directory, or run `bash tool/check_plugins.sh` to analyze and test every plugin package the way CI does. Native plugin tests under platform folders are not run by `flutter test`.

For the current Core/service architecture, useful focused checks are:

```bash
flutter test test/core/desktop/
flutter test test/core/service_test.dart
flutter test test/core/protocol_contract_test.dart
flutter test test/manager/core_manager_test.dart
flutter test test/providers/action_test.dart test/providers/system_action_test.dart
flutter test test/widgets/core_status_button_test.dart
```

What those suites own:

- `test/core/desktop/`: replaceable IPC transport, RPC request correlation/failure, direct/Helper/UAC process leases,
  pending launch cancellation and latest-intent desktop lifecycle convergence.
- `test/core/service_test.dart`: `CoreService` composition and terminal close behavior.
- `test/core/protocol_contract_test.dart`: shared Dart/Go method and event-envelope compatibility, including event batches.
- `test/providers/action_test.dart`: Core start/restart orchestration and overlapping restart requests.
- `test/providers/system_action_test.dart`: ordered, idempotent exit cleanup and watchdog behavior.
- `test/widgets/core_status_button_test.dart`: 600-millisecond connecting presentation hold, immediate failure display,
  long-running connecting state, and disconnected restart.

## Native Component Verification

The CI Go-wrapper checks can be reproduced without CGO:

```bash
cd core
CGO_ENABLED=0 go test .
CGO_ENABLED=0 go vet .
```

Windows x64 and ARM64 CI execute the Rust managed-launch/pipe/job tests and Go Windows bootstrap tests natively.
CI sets `RECLASH_REQUIRE_WINDOWS_BOOTSTRAP=1`, so a non-elevated test host fails instead of skipping bootstrap ownership checks.
The same Rust crate's host-independent tests also run on Linux:

```bash
cargo fmt --manifest-path plugins/rust_api/rust/Cargo.toml -- --check
cargo test --manifest-path plugins/rust_api/rust/Cargo.toml
```

The unshipped legacy Windows Helper retains its loopback/session protocol tests. Windows CI additionally compiles its
service implementation:

```bash
cargo fmt --manifest-path services/helper/Cargo.toml -- --check
cargo test --manifest-path services/helper/Cargo.toml
cargo test --manifest-path services/helper/Cargo.toml --features windows-service
```

The last command requires Windows for meaningful service coverage. Native Android lifecycle edits should at minimum
compile the modules they touch; use JDK 17 in this checkout:

```bash
cd android
JAVA_HOME=/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home ./gradlew :service:compileDebugKotlin
JAVA_HOME=/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home ./gradlew :app:compileDebugKotlin
```

Always-on VPN entry, system VPN revoke, actual permission UI, and rapid device start/stop still require Android device or
emulator validation; Kotlin compilation cannot prove those system callbacks.

## Changelog And Release

The changelog is derived from Conventional Commits by `tool/changelog.dart` and written to two committed files:
`CHANGELOG.md` for readers and `changelog.json` for the renderers. See `.agents/rules.md` for the `Changelog:` trailers
that decide the wording.

The app ships no changelog of its own. `render release` appends the released version as JSON inside an HTML comment
(`<!-- reclash:changelog:json … -->`), so the release body GitHub already returns to `checkForUpdate` carries the
notes shown in the update dialog. `parseReleaseChangelog` reads that block and falls back to the English
bullets when a release predates it.

```bash
dart run tool/changelog.dart verify                  # what CI checks
dart run tool/changelog.dart release --version 0.8.96
dart run tool/changelog.dart build --unreleased      # changelog.json only, includes untagged work
dart run tool/changelog.dart render release --out release.md
dart run tool/changelog.dart render telegram --out telegram.md
```

Releasing a stable version, in order:

```bash
tool/bump_version.sh all
dart run tool/changelog.dart release --version 0.8.96
git commit -am "chore(release): v0.8.96"
git tag v0.8.96
git push origin main && git push origin v0.8.96
```

Push the tag by name. Every release tag here is lightweight, and `--follow-tags` carries annotated tags only: it skips a
lightweight one silently, so the branch lands, the tag does not, and the release workflow never fires.

`tool/release.sh` drives both paths so the ordering below cannot be got wrong by hand. It resolves the version (bumping
the patch when pubspec still names an already tagged one), prints the notes the tag would ship, and only pushes with
`--push`:

```bash
tool/release.sh pre --dry-run     # plan and notes, changes nothing
tool/release.sh pre --push        # bump, tag vX.Y.Z-pre.N, push
tool/release.sh stable --push     # changelog, chore(release) commit, tag, push
```

The release commit comes before the tag on purpose: the generated wording is reviewable in the diff before it ships, and
the tag is what `render release` reads. CI never writes back to the repository; it only runs `verify`. Wording in
`changelog.json` may be edited by hand as long as no derivable entry disappears and every entry still points at a commit
inside that version's range.

Entries at or below `v0.8.95` are frozen: they predate the pipeline, live under the `<!-- changelog:frozen -->` marker
in `CHANGELOG.md`, and are never regenerated.

`verify` compares a version only when its tag is reachable from `HEAD`, because that is the same scope the builder walks
(`git tag --merged`). A branch cut before the newest release cannot derive that version at all, so `verify` names it as
skipped and moves on instead of reporting drift that does not exist. Checking mere tag existence is what made every such
branch fail on an unrelated release.

Prerelease tags (`vX.Y.Z-pre.N`) publish a GitHub prerelease with packages and checksums; CI renders their notes with
`build --unreleased`. The release script commits the version/build-number bump but does not rewrite the stable changelog.
It selects the next prerelease number from existing tags and keeps `pubspec.yaml` consistent with the new tag.

The publish job uses the protected GitHub environment `release`. Configure a required reviewer there: an environment
name in YAML alone does not require approval. Build artifacts remain available for one day; complete the Windows
installer, UAC/TUN and cleanup check and approve the deployment in Actions before they expire. Approval publishes those
same artifacts without rebuilding; do not approve a run whose Windows check failed. The Telegram announcement follows
publication when its credentials are configured.

## Verify

The tag-triggered release workflow runs these root-package checks in order:

```bash
flutter pub get
flutter analyze --no-fatal-infos
dart run tool/changelog.dart verify
flutter test --reporter expanded
bash tool/check_commit_msg_test.sh
bash tool/check_comment_density_test.sh
```

Run `flutter analyze` locally before committing when practical.

The workflow runs its validation jobs for pull requests targeting `main`,
pushes to `main`, and `v*` tags. Packaging and release publishing run only
for tags.
Root analysis excludes `plugins/**`, and root tests do not discover nested
plugin packages, so CI also validates local Flutter packages, the setup build
tool, the Go wrapper, and Rust components from their own package directories. A
Windows x64/ARM64 matrix runs native managed-launch and Go bootstrap tests, plus the legacy helper's `windows-service`
feature, before release builds can start. Windows package validation then installs and checks each architecture before
publishing; its logs are retained as separate artifacts.

`bash tool/check_plugins.sh` is that plugin gate, and CI runs the same script.
It discovers every `plugins/*/pubspec.yaml`, analyzes each package, and runs
`flutter test` wherever `test/*_test.dart` exists. Adding a plugin package needs
no workflow edit; enumerating packages by hand in the workflow is what
previously left `plugins/tray` unanalyzed and untested.

## Worktree Tooling

```bash
bash tool/worktrees.sh list       # every worktree with owner tool and dirty/clean state
bash tool/worktrees.sh prune      # remove clean worktrees; add --force to drop dirty ones too
```
