#!/usr/bin/env bash
set -euo pipefail

secret_scan_paths=(Package.swift Sources Tests Apps .github Makefile)

secret_patterns=(
  'AKIA[0-9A-Z]{16}'
  'BEGIN RSA PRIVATE KEY'
  'BEGIN OPENSSH PRIVATE KEY'
  'ghp_[A-Za-z0-9_]{30,}'
  'xox[baprs]-[A-Za-z0-9-]{10,}'
  'api[_-]?key\s*=\s*["'"'"'"'][^"'"'"'"']+["'"'"'"']'
  'password\s*=\s*["'"'"'"'][^"'"'"'"']+["'"'"'"']'
)

for path in "${secret_scan_paths[@]}"; do
  [[ -e "$path" ]] || continue
  for pattern in "${secret_patterns[@]}"; do
    if grep -RInE "$pattern" "$path"; then
      echo "Potential secret detected in $path. Remove it or explicitly redesign the check." >&2
      exit 1
    fi
  done
done

if grep -RIn 'http://' Sources Tests Apps Package.swift 2>/dev/null; then
  echo "Plain HTTP URL found in source/package files. Use HTTPS or document a test-only exception." >&2
  exit 1
fi

if grep -RInE 'NSAllowsArbitraryLoads\s*</key>\s*<true/>' Apps Sources Tests 2>/dev/null; then
  echo "ATS arbitrary loads must not be enabled by default." >&2
  exit 1
fi

echo "Security baseline OK"
