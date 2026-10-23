# Nix Linux Development

`flake.nix` exposes `devShells.default` for `x86_64-linux` and `aarch64-linux`.
It does not expose an application package, overlay, installer, or NixOS service.
The shell has not been evaluated or built locally: Nix is unavailable on the
implementation host. The separate Nix workflow evaluates both architectures
and builds/inspects the shell on x86_64; it does not build or launch ReClash.

## First Use

Run from the repository root with Nix flakes enabled:

```bash
git submodule update --init --recursive
nix flake lock
nix develop
reclash-prepare
flutter analyze --no-fatal-infos
flutter build linux --release
```

For a host launch, use only safe mode:

```bash
flutter run -d linux --dart-define=SAFE_MODE=true
```

The shell does not download dependencies, initialize submodules, edit manifests,
or start the application on entry. `reclash-prepare` explicitly downloads the
pinned Rust toolchain for the native host, resolves Pub dependencies, and runs
`tool/assemble_l10n.dart` to create the ignored flat ARBs. That Dart invocation
also runs the normal Go/Helper and Rust hooks; it may compile native artifacts
and fetch Go modules and Cargo crates. Leave both `build_assets` defines enabled.
Tracked localization Dart output is already present; after changing messages,
follow the normal localization generation commands in `.agents/commands.md`.

## Toolchains And Host Integration

- The Nixpkgs input is pinned to an exact revision, not a floating branch. Generate
  `flake.lock` with real Nix before committing it; no hand-written lock or guessed
  content hash is supplied. CI generates its own lock in a disposable checkout.
- Nixpkgs supplies Flutter 3.47.4 / Dart 3.13.3, including only universal and Linux
  artifacts. This meets the editor's Dart 3.13.2 minimum, but is not release CI's
  Flutter 3.47.6. Use the release CI SDK for release parity; do not silently
  substitute an older Flutter or assume an arbitrary newer major is compatible.
- Go comes from `go_1_27` (1.27.3 at the pinned revision), satisfying `core/go.mod`.
  `GOTOOLCHAIN=local` prevents Go from silently downloading a different compiler.
- Rust comes through Nixpkgs' Linux-patched `rustup`, not an unrelated Nixpkgs
  `rustc`. `RUSTUP_TOOLCHAIN` is read from the editor/IPC crate's exact
  `rust-toolchain.toml` pin (currently 1.99.0), also selecting it for the Helper.
  This preserves the native hook's `rustup run <channel>` contract. Rustup and
  Cargo caches live under the root's ignored `.dart_tool/nix/`; enter the shell
  from the root. `flutter clean` removes these caches. There is no global Rust
  override or installation, and first use requires access to Rust distribution
  servers. Other target toolchains are outside this Linux-only shell's scope.
- Clang, CMake, Ninja, pkg-config, GTK, AppIndicator, libsecret, X11 and runtime
  libraries support both the Flutter runner and the Rust editor/script/IPC/hotkey
  library. There is no separate code_forge Rust artifact to fetch.
- A graphical session and its D-Bus/keyring are host services, not supplied by the
  shell. Global hotkeys require X11/XWayland. Hardware graphics drivers remain a
  host concern; on non-NixOS, a host-compatible graphics wrapper such as nixGL
  may be necessary. Neither native graphics nor Wayland behavior is verified.
- Privileged TUN additionally requires the real host's systemd and polkit. The
  shell does not install, enable, or bypass the protocol-9 Helper. Safe mode must
  remain the default for local launches next to an installed ReClash.

## Packaging Boundary

A reproducible `nix build` application is intentionally not advertised. Completing
it requires real Nix builds and fixed-output dependency materialization for Pub
(including the remaining `launch_at_startup` Git pin), Go's local mihomo submodule,
and both Cargo lockfiles. Native hook downloads, including SQLite assets, must
also be made sandbox-safe without disabling the editor's Rust code assets.

The application build must preserve the existing hook contract: Core first,
Helper embedding the final Core SHA256, and a manifest containing final Core and
Helper hashes plus string protocol `9`. It must assemble the ignored ARBs and
include submodule assets. Post-build ELF patching cannot invalidate those embedded
hashes. It must not stub an obsolete buildkit script, invent Helper Cargo features,
ship placeholder hashes, or claim the dev shell is an offline/reproducible app
package. Actual systemd/polkit and both native architectures still need acceptance.

## Verification

Locally performed checks are recorded in the implementation handoff, not implied
by this document. On a Nix host, run:

```bash
nix flake lock
nix flake check --all-systems --no-build --no-update-lock-file
nix eval --raw --no-update-lock-file .#devShells.x86_64-linux.default.drvPath
nix eval --raw --no-update-lock-file .#devShells.aarch64-linux.default.drvPath
nix develop --no-update-lock-file --command nixfmt --check flake.nix
nix develop --no-update-lock-file --command actionlint .github/workflows/nix.yaml
```

Nix ignores untracked files in a Git flake. Before using these commands on an
uncommitted implementation, stage the new Nix files or use `path:.` as the flake
reference. The latter copies the working directory, including ignored caches,
so a clean throwaway checkout is preferable. Never commit build outputs or SDK
caches. Once Nix is installed elsewhere, the two architecture evaluations are
not substitutes for native application builds and runtime checks.
