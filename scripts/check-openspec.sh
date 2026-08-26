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

for change_spec in "$root"/changes/m0-foundation/specs/*/spec.md; do
  [[ -e "$change_spec" ]] || continue
  grep -Eq '^## (ADDED|MODIFIED|REMOVED) Requirements' "$change_spec" || {
    echo "$change_spec missing change requirement section" >&2
    exit 1
  }
done

echo "OpenSpec structure OK"
