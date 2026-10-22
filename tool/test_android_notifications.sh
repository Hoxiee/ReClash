#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../android"
gradle_runner="${RECLASH_GRADLE:-gradle}"
if [ -x ./gradlew ]; then
  gradle_runner=./gradlew
fi
"$gradle_runner" :core:compileDebugKotlin :service:compileDebugKotlin :app:compileDebugKotlin \
  :service:testDebugUnitTest :app:testDebugUnitTest \
  -Ptarget-platform=android-arm64 --console=plain
