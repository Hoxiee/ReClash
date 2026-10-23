{
  description = "ReClash Linux development environment (not a packaged application)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/02c087f3fe673c9e317f206a627cb6b910336dbe";

  outputs =
    { nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      devShells = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
          lib = pkgs.lib;
          flutter = pkgs.flutter347.override {
            supportedTargetFlutterPlatforms = [
              "universal"
              "linux"
            ];
          };
          rustToolchain =
            (builtins.fromTOML (builtins.readFile ./plugins/rust_api/rust/rust-toolchain.toml))
            .toolchain.channel;
          linuxLibraries = with pkgs; [
            gtk3
            glib
            gdk-pixbuf
            cairo
            pango
            atk
            harfbuzz
            libepoxy
            libayatana-appindicator
            libsecret
            libx11
            libxcursor
            libxrandr
            libxinerama
            libxi
            libxkbcommon
            wayland
            libglvnd
            dbus
            openssl
            zlib
            stdenv.cc.cc.lib
          ];
          prepare = pkgs.writeShellApplication {
            name = "reclash-prepare";
            text = ''
              if [[ ! -f plugins/rust_api/rust/rust-toolchain.toml || ! -f tool/assemble_l10n.dart ]]; then
                echo 'Run reclash-prepare from the ReClash repository root.' >&2
                exit 1
              fi
              if [[ ! -f core/mihomo/go.mod ]]; then
                echo 'Initialize the Core first: git submodule update --init --recursive' >&2
                exit 1
              fi
              rustup toolchain install ${lib.escapeShellArg rustToolchain} --profile minimal
              rustup target add --toolchain ${lib.escapeShellArg rustToolchain} ${lib.escapeShellArg pkgs.stdenv.hostPlatform.rust.rustcTarget}
              flutter pub get
              dart run tool/assemble_l10n.dart
            '';
          };
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              flutter
              go_1_27
              rustup
              clang
              cmake
              ninja
              pkg-config
              git
              curl
              unzip
              which
              yq-go
              nixfmt
              actionlint
              prepare
            ];
            buildInputs = linuxLibraries;
            GOTOOLCHAIN = "local";
            RUSTUP_TOOLCHAIN = rustToolchain;
            LD_LIBRARY_PATH = lib.makeLibraryPath linuxLibraries;
            shellHook = ''
              export RUSTUP_HOME="$PWD/.dart_tool/nix/rustup"
              export CARGO_HOME="$PWD/.dart_tool/nix/cargo"
              printf '%s\n' \
                'ReClash Linux dev shell. First initialize submodules, then run reclash-prepare.' \
                'SDKs and native hooks require network access on first use. See .agents/nix.md.'
            '';
          };
        }
      );
    };
}
