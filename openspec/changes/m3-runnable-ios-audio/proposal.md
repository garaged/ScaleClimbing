# M3 — Runnable iOS Application

## Intent
Deliver a reproducible, first-class Xcode application that can be launched on an iPhone simulator without temporary host projects or manual package wiring.

## Requirements
- The repository SHALL include a shared Xcode project and scheme referencing the local ScaleClimbingPresentation Swift package.
- The app SHALL launch ScaleClimbingRootView on iOS 18+.
- CI SHALL build the iOS Simulator application without signing credentials.
- Manual M2 and M3 acceptance MAY be combined after M3's simulator build is green.
- Maintain one draft PR for M3, stacked on unmerged M2, and merge in dependency order after acceptance.

## Follow-up
Generated playback/audio remains a separate M3 implementation slice on this same PR; do not declare milestone complete on project packaging alone.
