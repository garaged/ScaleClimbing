#!/usr/bin/env bash
set -euo pipefail

root="openspec"
required=(
  "$root/project.md"
  "$root/specs/product-mvp/spec.md"
  "$root/specs/music-theory-core/spec.md"
  "$root/specs/learning-gameplay/spec.md"
  "$root/specs/security-privacy/spec.md"
  "$root/specs/validation/spec.md"
  "$root/changes/m0-foundation/proposal.md"
  "$root/changes/m0-foundation/tasks.md"
  "$root/changes/m16-physical-device-stabilization/proposal.md"
  "$root/changes/m16-physical-device-stabilization/tasks.md"
  "$root/changes/m16-physical-device-stabilization/issues.md"
  "$root/changes/m22-caged-scale-networks/proposal.md"
  "$root/changes/m22-caged-scale-networks/tasks.md"
  "$root/changes/m22-caged-scale-networks/specs/learning-gameplay/spec.md"
  "$root/changes/m21-guitar-triads-voicings/proposal.md"
  "$root/changes/m21-guitar-triads-voicings/tasks.md"
  "$root/changes/m21-guitar-triads-voicings/specs/learning-gameplay/spec.md"
  "$root/changes/m20-fretboard-foundations/proposal.md"
  "$root/changes/m20-fretboard-foundations/tasks.md"
  "$root/changes/m20-fretboard-foundations/specs/learning-gameplay/spec.md"
  "$root/changes/m20-fretboard-foundations/specs/learning-path/spec.md"
  "$root/changes/m19-free-fretboard/proposal.md"
  "$root/changes/m19-free-fretboard/tasks.md"
  "$root/changes/m19-free-fretboard/specs/instrument-playground/spec.md"
  "$root/changes/m18-musical-relational-core/proposal.md"
  "$root/changes/m18-musical-relational-core/tasks.md"
  "$root/changes/m18-musical-relational-core/specs/music-theory-core/spec.md"
  "$root/changes/m17-instrument-playground/proposal.md"
  "$root/changes/m17-instrument-playground/tasks.md"
  "$root/changes/m17-instrument-playground/specs/instrument-playground/spec.md"
  "$root/specs/instrument-playground/spec.md"
  "$root/changes/m16-physical-device-stabilization/specs/device-stabilization/spec.md"
)

for file in "${required[@]}"; do
  if [[ ! -s "$file" ]]; then
    echo "Missing required OpenSpec file: $file" >&2
    exit 1
  fi
done

for spec in "$root"/specs/*/spec.md; do
  grep -q '^## Requirements' "$spec" || { echo "$spec missing ## Requirements" >&2; exit 1; }
  grep -q '^### Requirement:' "$spec" || { echo "$spec missing at least one requirement" >&2; exit 1; }
  grep -q '^#### Scenario:' "$spec" || { echo "$spec missing at least one scenario" >&2; exit 1; }
done

for change_spec in "$root"/changes/m0-foundation/specs/*/spec.md "$root"/changes/m18-musical-relational-core/specs/*/spec.md "$root"/changes/m19-free-fretboard/specs/*/spec.md "$root"/changes/m20-fretboard-foundations/specs/*/spec.md "$root"/changes/m21-guitar-triads-voicings/specs/*/spec.md "$root"/changes/m22-caged-scale-networks/specs/*/spec.md; do
  [[ -e "$change_spec" ]] || continue
  grep -Eq '^## (ADDED|MODIFIED|REMOVED) Requirements' "$change_spec" || {
    echo "$change_spec missing change requirement section" >&2
    exit 1
  }
done

echo "OpenSpec structure OK"
