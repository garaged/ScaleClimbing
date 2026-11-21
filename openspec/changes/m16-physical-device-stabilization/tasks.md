# M16 task ledger

## Intake and foundation
- [x] Inspect M15 OpenSpec, release settings, tests, manuals, CI and the current main baseline.
- [x] Define M16 intent, constraints, scenarios and acceptance criteria in OpenSpec before implementation.
- [x] Add persistent device-issue intake template and acceptance script.
- [x] Wire `make manual-m16` and documentation integrity checks.
- [x] Document Guideline 2.1 submitted-build evidence and owner-only review actions.
- [x] Open one dedicated draft PR (#18); keep draft until automated and owner acceptance gates pass.

## Physical-device findings
- [x] Record first observations M16-001 (dark keyboard/note hints) and M16-002 (repeated playback), with evidence and unknown device context.
- [ ] For each accepted finding: reproduce; classify and prioritize; add a failing objective test where possible; minimally fix; run focused + baseline gates; record manual evidence and release impact.
- [ ] Re-run relevant audio, accessibility, rotation, localization, offline and persistence flows after fixes.

## Final validation and review gate
- [ ] `make ci`, `make ios-build`, `make ios-ui-test` and `make ios-release-build` pass on a supported macOS/Xcode runner or equivalent.
- [ ] Owner completes `make manual-m16` on physical iPhone and iPad, with explicit exceptions logged.
- [ ] Owner confirms matching Guideline 2.1 recording, review notes, submitted build, and any necessary App Store Connect action.
- [ ] Owner explicitly approves taking the PR out of draft and eventual merge.

## M16-001 / M16-002 focused repair
- [x] Triage reported dark-mode keyboard and repeated-play audio symptoms; record evidence and uncertainty in OpenSpec.
- [x] Add focused keyboard model/layout/label policy, fixed-key contrast and audio latest-request/simultaneous-chord tests before or with implementation.
- [x] Implement contrast-safe piano key appearance and layered natural/accidental geometry using documented M14 extension.
- [x] Add localized and persistent Standard / Novice learning-assistance selector; Standard hides labels in Note Hunter by default, Novice reveals them; no impact on VoiceOver, core theory or scoring.
- [x] Move audio synthesis off main actor, coalesce superseded queued audio, and avoid repeat session activation in a running engine.
- [ ] Validate all hosted package, iOS simulator, UI and Release gates; repair failures.
- [ ] Owner manual dark/light iPhone/iPad keyboard and repeated playback / interruption acceptance.
