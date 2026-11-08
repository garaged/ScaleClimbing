# M3 Manual Acceptance — Combined M2 + M3

## One-time setup
1. From the M3 branch, open `Apps/iOS/ScaleClimbing.xcodeproj` in Xcode.
2. Select the **ScaleClimbing** scheme and an installed iPhone simulator; press Cmd-R.
3. Home shows **Note Hunter** and **Chord Forge**. No temporary host or package wiring is required.

## Short acceptance for both milestones
1. Open **Chord Forge**. Tap **Hear chord**. Expect audible generated notes for the displayed triad (turn on Mac output, and unmute Simulator if needed).
2. Choose C, E, G; tap **Check chord**. Expect correct feedback and score **1/1**.
3. Tap **Next chord**. Expect A minor and preserved score. Tap **Hear chord** again and listen for a different triad.
4. Return home, open **Note Hunter**, tap target note, and tap **Next note**.
5. No microphone permission, login, network or cloud sync, payment, or licensed media prompts should appear.

## Build gate
`make ios-build` builds the checked-in project. GitHub CI runs this gate separately from `make check`.

## Longer M2 scenarios
The detailed optional manual scenarios remain in `docs/engineering/manual-testing-m2.md`. Record issues during the combined M2+M3 simulator acceptance. Merge only after user approval.

## Xcode GUI / destination regression
The app's Debug build configurations explicitly use `ONLY_ACTIVE_ARCH = YES` and `SWIFT_OPTIMIZATION_LEVEL = -Onone`. This prevents the app target from attempting both x86_64 and arm64 while the local Swift packages are compiled for the selected arm64 simulator. Select a concrete iPhone simulator and use Product > Build (Cmd-B), then Run (Cmd-R). If old artifacts interfere, use Product > Clean Build Folder once.
