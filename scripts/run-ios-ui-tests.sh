#!/usr/bin/env bash
set -euo pipefail

project="Apps/iOS/ScaleClimbing.xcodeproj"
scheme="ScaleClimbing"

# Prefer an available arm64-capable iPhone simulator already installed on the runner.
device_id="$(xcrun simctl list devices available -j | python3 -c '
import json, sys
data = json.load(sys.stdin)["devices"]
for runtime, devices in sorted(data.items(), reverse=True):
    for device in devices:
        if device.get("isAvailable") and "iPhone" in device.get("name", ""):
            print(device["udid"])
            sys.exit(0)
sys.exit(1)
')"

echo "Running ScaleClimbing UI tests on simulator $device_id"
xcodebuild -project "$project" -scheme "$scheme" \
  -configuration Debug \
  -destination "platform=iOS Simulator,id=$device_id" \
  -parallel-testing-enabled NO \
  CODE_SIGNING_ALLOWED=NO test
