# M1 Manual Testing

## Purpose

Confirm that the first iOS-facing visual keyboard and shell flow are usable before audio work starts.

## Automated prerequisite

- [ ] Run `make check` and confirm specs, docs, architecture, security, Swift tests, and smoke pass.

## Source-level app shell checklist

- [ ] Open `Apps/iOS/ScaleClimbingApp.swift` and confirm the app composition root only launches `ScaleClimbingRootView`.
- [ ] Confirm `ScaleClimbingRootView` presents a home list with `Note Hunter` under `Note Harbor`.
- [ ] Confirm route definitions live in `AppRoute` and do not embed music-theory business rules in the app target.

## Note Hunter checklist

- [ ] Confirm the beginner keyboard spans C4 through C6.
- [ ] Confirm natural and accidental keys are visually distinct.
- [ ] Confirm tapping any matching pitch class across octaves is accepted.
- [ ] Confirm tapping a different pitch class is rejected and keeps the player in the same prompt.
- [ ] Confirm `Next note` advances to a new target without clearing the cumulative score.
- [ ] Confirm feedback text and key labels have VoiceOver-friendly labels rather than symbol-only labels.

## Non-goals to re-check

- [ ] No microphone permission, network service, account flow, analytics, payment, cloud sync, or licensed song content is present.

## Expected result

M1 source-level acceptance passes when the app has an explicit home-to-Note-Hunter route, a usable accessible keyboard model, deterministic answer evaluation, and documented architecture boundaries. A full Xcode project/build scheme remains deferred to the app-packaging milestone.
