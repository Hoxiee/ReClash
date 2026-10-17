cask "reclash" do
  version "VERSION"

  on_macos do
    arch arm: "arm64", intel: "amd64"

    sha256 arm:   "ARM_SHA256",
           intel: "AMD_SHA256"

    url "https://github.com/Hoxiee/ReClash/releases/download/v#{version}/ReClash-#{version}-macos-#{arch}.dmg"
  end

  name "ReClash"
  desc "Multi-platform proxy client based on ClashMeta"
  homepage "https://github.com/Hoxiee/ReClash"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on :macos

  app "ReClash.app"

  postflight_steps do
    run "/usr/bin/xattr",
        args:           ["-rd", "com.apple.quarantine", "{{appdir}}/ReClash.app"],
        writable_paths: ["ReClash.app"],
        writable_base:  :appdir
  end

  uninstall quit: "com.reclash"

  zap trash: [
    "~/Library/Application Support/com.reclash",
    "~/Library/Caches/com.reclash",
    "~/Library/Preferences/com.reclash.plist",
    "~/Library/Saved Application State/com.reclash.savedState",
  ]
end
