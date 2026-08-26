# M2 Triad Visual Gameplay

## Intent

Add the first triad-focused visual construction game so players can build major and minor triads on the keyboard before audio work starts.

## Scope

- Add Chord Forge as a route in the app shell.
- Add a Chord Forge view model that tracks selected pitch classes, evaluates chord-tone submissions, and advances through beginner triads.
- Add a SwiftUI Chord Forge screen using the reusable keyboard.
- Support multi-note key highlighting for selected chord tones.
- Add tests for route exposure, pitch-class toggling, correct/wrong triad evaluation, and next-chord progression.
- Document M2 manual acceptance and the milestone PR cadence.

## Non-goals

- Generated audio playback.
- MIDI or microphone input.
- Persistence, accounts, cloud sync, analytics, payments, network services, or licensed song content.
- Full generated Xcode project.