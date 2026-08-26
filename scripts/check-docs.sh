#!/usr/bin/env bash
set -euo pipefail

required=(
  README.md
  LICENSE
  CONTRIBUTING.md
  SECURITY.md
  docs/product/product-requirements.md
  docs/product/milestones.md
  docs/engineering/architecture.md
  docs/engineering/component-architecture.md
  docs/engineering/validation.md
  docs/engineering/sdd-tdd-idd.md
  docs/engineering/security.md
  docs/engineering/manual-testing.md
  docs/engineering/manual-testing-m1.md
  docs/engineering/decision-log.md
  docs/engineering/adr/0001-ios-first-portable-core.md
)

for file in "${required[@]}"; do
  if [[ ! -s "$file" ]]; then
    echo "Missing required document: $file" >&2
    exit 1
  fi
done

grep -q 'make check' README.md || { echo "README must document make check" >&2; exit 1; }
grep -q 'OpenSpec' README.md || { echo "README must mention OpenSpec" >&2; exit 1; }
grep -q 'Threat model' docs/engineering/security.md || { echo "security.md must include threat model" >&2; exit 1; }
grep -q 'Intent' docs/engineering/sdd-tdd-idd.md || { echo "SDD/TDD/IDD doc must include intent guidance" >&2; exit 1; }
grep -q 'Architecture enforcement' docs/engineering/component-architecture.md || { echo "component architecture doc must define enforcement" >&2; exit 1; }

echo "Documentation structure OK"
