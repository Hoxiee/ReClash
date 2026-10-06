{
  description = "ReClash: a multi-platform Mihomo-based proxy client, open source and ad-free.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    # The desktop app and the Rust helper are Linux-only; restricting the
    # systems keeps `nix flake check` from evaluating unsupported platforms.
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" ] (
      system:
      let
        pkgs = import nixpkgs { inherit system; };

        version = self.shortRev or self.dirtyShortRev or "unknown";

        # mihomo engine version baked into the core (constant.Version, shown as
        # the engine version in-app). The native build reads it from
        # `git describe --tags --match 'v[0-9]*'` of the core/mihomo submodule
        # with the leading `v` stripped; the Nix sandbox has no Git metadata, so
        # mirror the pinned tag here and bump it alongside the submodule.
        coreVersion = "1.19.31-2-gf77b7475";

        # HASHES — fill from the first build (temporarily set to lib.fakeHash,
        # build, copy the real `got:` value back). See README "NixOS".
        # ==========================================================
        vendorHash = pkgs.lib.fakeHash;
        gitHashes = {
          launch_at_startup = pkgs.lib.fakeHash;
          yaml_writer = pkgs.lib.fakeHash;
        };
        # ==========================================================

        src = pkgs.lib.cleanSource ./.;

        # Standalone desktop core: CGO off, gvisor TUN in. The cgo/android
        # entrypoints are excluded by Go build tags, so no C toolchain is needed.
        reclashCore = pkgs.buildGoModule {
          pname = "reclash-core";
          inherit version src vendorHash;
          modRoot = "core";
          env.CGO_ENABLED = "0";
          buildPhase = ''
            runHook preBuild
            go build \
              -tags=with_gvisor \
              -trimpath \
              -ldflags="-w -s -X github.com/metacubex/mihomo/constant.Version=${coreVersion}" \
              -o ReClashCore .
            runHook postBuild
          '';
          installPhase = ''
            runHook preInstall
            install -Dm755 ReClashCore $out/bin/ReClashCore
            runHook postInstall
          '';
          doCheck = false;
        };

        # The privileged helper bakes the core's digest in at compile time
        # (build.rs reads CORE_SHA256) and verifies it before launching the core.
        reclashHelper = pkgs.rustPlatform.buildRustPackage {
          pname = "reclash-helper";
          inherit version;
          src = ./services/helper;
          cargoLock.lockFile = ./services/helper/Cargo.lock;
          buildNoDefaultFeatures = true;
          buildFeatures = [ "linux-service" ];
          CORE_NAME = "ReClashCore";
          preBuild = ''
            export CORE_SHA256=$(sha256sum ${reclashCore}/bin/ReClashCore | cut -d' ' -f1)
          '';
          postInstall = ''
            mv $out/bin/helper $out/bin/ReClashHelperService
          '';
          doCheck = false;
        };

        # manifest.json pins the digests the runtime re-checks before staging
        # the helper into /opt (lib/core/desktop/linux_helper.dart).
        reclashManifest = pkgs.runCommand "reclash-core-manifest" { } ''
          core=$(sha256sum ${reclashCore}/bin/ReClashCore | cut -d' ' -f1)
          helper=$(sha256sum ${reclashHelper}/bin/ReClashHelperService | cut -d' ' -f1)
          printf '{"coreSha256":"%s","helperSha256":"%s"}\n' "$core" "$helper" > $out
        '';

        reclash = pkgs.flutter.buildFlutterApplication {
          pname = "reclash";
          inherit version src gitHashes;
          pubspecLock = builtins.fromJSON (
            builtins.readFile (
              pkgs.runCommand "pubspec.lock.json" { } ''
                ${pkgs.yq-go}/bin/yq -o=json ${./pubspec.lock} > $out
              ''
            )
          );
          # Pre-stage the native artifacts and neuter the in-build Go/Rust
          # compile (buildkit): the Nix sandbox has no network, and the three
          # files below are all the setup plugin's install() rules need.
          preBuild = ''
            mkdir -p libclash/linux
            cp ${reclashCore}/bin/ReClashCore libclash/linux/ReClashCore
            cp ${reclashHelper}/bin/ReClashHelperService libclash/linux/ReClashHelperService
            cp ${reclashManifest} libclash/linux/manifest.json
            chmod -R u+w libclash/linux
            printf '#!/usr/bin/env bash\nexit 0\n' > plugins/setup/buildkit/run_build_tool.sh
            chmod +x plugins/setup/buildkit/run_build_tool.sh
          '';
          nativeBuildInputs = with pkgs; [
            pkg-config
            wrapGAppsHook3
          ];
          buildInputs = with pkgs; [
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
            keybinder3
            libX11
            libXcursor
            libXrandr
            libXinerama
            libXi
          ];
          meta = with pkgs.lib; {
            description = "Multi-platform Mihomo-based proxy client";
            homepage = "https://github.com/Hoxiee/ReClash";
            license = licenses.gpl3Only;
            mainProgram = "ReClash";
            platforms = platforms.linux;
          };
        };
      in
      {
        packages = {
          default = reclash;
          inherit reclash;
          reclash-core = reclashCore;
          reclash-helper = reclashHelper;
        };
        devShells.default = pkgs.mkShell {
          inputsFrom = [ reclash ];
          nativeBuildInputs = with pkgs; [
            flutter
            go
            rustc
            cargo
            yq-go
          ];
        };
      }
    )
    // {
      overlays.default = final: prev: {
        reclash = self.packages.${final.system}.reclash;
      };
    };
}
