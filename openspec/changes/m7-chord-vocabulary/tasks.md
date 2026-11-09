# M7 tasks
- [x] Author spec and acceptance before implementation
- [x] Complete chord quality catalog and domain tests
- [x] Implement Chord Atlas listening/construction modes and tests
- [x] Wire audio and home route
- [x] Add iPhone UI regression
- [x] Update roadmap and short manual acceptance
- [ ] Validate exact PR head with all CI jobs
- [ ] User acceptance before merge

## M7 Xcode regression hardening
- [x] Give the home NavigationLink a stable accessibility ID and avoid assuming it is a StaticText in XCTest
- [x] Move AVAudioSession activation and AVAudioEngine playback onto a dedicated serial audio worker rather than the main actor
- [ ] Verify both fixes on the final PR head in CI and locally in the iPhone 17 simulator
