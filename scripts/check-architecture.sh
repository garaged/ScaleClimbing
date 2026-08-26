#!/usr/bin/env bash
set -euo pipefail

required=(
  docs/engineering/component-architecture.md
  openspec/specs/component-architecture/spec.md
)

for file in "${required[@]}"; do
  if [[ ! -s "$file" ]]; then
    echo "Missing architecture governance file: $file" >&2
    exit 1
  fi
done

grep -q 'MusicTheoryCore.*Functional Core' docs/engineering/component-architecture.md || { echo "MusicTheoryCore pattern must be documented" >&2; exit 1; }
grep -q 'ScaleClimbingPresentation.*MVVM' docs/engineering/component-architecture.md || { echo "Presentation pattern must be documented" >&2; exit 1; }
grep -q 'ScaleClimbingApp.*Composition Root' docs/engineering/component-architecture.md || { echo "App composition pattern must be documented" >&2; exit 1; }

if grep -RInE 'import (SwiftUI|AVFoundation|AVFAudio|StoreKit|CloudKit|CoreData|SwiftData)' Sources/MusicTheoryCore 2>/dev/null; then
  echo "MusicTheoryCore must stay platform independent" >&2
  exit 1
fi

if grep -RInE 'import (AVFoundation|AVFAudio|StoreKit|CloudKit|CoreData|SwiftData)' Sources/ScaleClimbingPresentation 2>/dev/null; then
  echo "ScaleClimbingPresentation must not own audio, payment, cloud, or persistence dependencies" >&2
  exit 1
fi

if [[ -d Apps/iOS ]] && grep -RIn 'import MusicTheoryCore' Apps/iOS 2>/dev/null; then
  echo "iOS app target should use presentation root, not reach into MusicTheoryCore directly" >&2
  exit 1
fi

echo "Architecture rules OK"
