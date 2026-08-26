# Architecture Foundation

## Architecture style

ScaleClimbing starts as an iOS-first Swift application with a portable Swift package core.

## Module boundaries

- `MusicTheoryCore`: pure domain model for notes, pitches, intervals, scales, chords, exercises, and answer evaluation.
- Future `LearningEngine`: mastery, review scheduling, and adaptive sessions.
- Future `AudioEngine`: generated note, interval, chord, and scale playback.
- Future `ScaleClimbingApp`: SwiftUI presentation, navigation, input, accessibility, and local persistence.

## Dependency rule

Domain modules must not import SwiftUI, AVFoundation, StoreKit, CloudKit, or platform permission APIs. Platform modules may depend on domain modules.

## Security architecture

M0 is local/offline and contains no account, cloud, analytics, payment, network, microphone, or licensed-content dependency. Any future capability in those areas requires OpenSpec coverage and a security/privacy review.
