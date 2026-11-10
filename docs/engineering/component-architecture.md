# Component Architecture

## Architecture enforcement

Every component must declare its pattern, allowed dependencies, forbidden dependencies, and validation surface. `make architecture` enforces the current dependency rules.

## Components

| Component | Pattern | Responsibility | Allowed dependencies | Forbidden dependencies | Enforcement |
|---|---|---|---|---|---|
| `MusicTheoryCore` | Functional Core / Domain Model | Notes, written notation, pitches, intervals, scales, chords, exercises, deterministic evaluation | Swift standard library and Foundation only where value normalization requires it | SwiftUI, AVFoundation/AVFAudio, StoreKit, CloudKit, CoreData, SwiftData, app/UI modules | `scripts/check-architecture.sh`, Swift unit tests |
| `ScaleClimbingProgress` | Adapter / Local Persistence | Local progress and accessibility-preference persistence behind a domain protocol | Foundation, `MusicTheoryCore` | SwiftUI, AVFoundation/AVFAudio, networking, cloud SDKs | Persistence tests, architecture review |
| `ScaleClimbingPresentation` | MVVM + Unidirectional View Events | View models, display models, SwiftUI views, accessibility labels, user-intent methods | SwiftUI, Combine, Foundation, `MusicTheoryCore`, `ScaleClimbingProgress` | AVFoundation/AVFAudio, StoreKit, CloudKit, CoreData, SwiftData, direct persistence/network ownership | `scripts/check-architecture.sh`, presentation tests |
| `ScaleClimbingApp` | Composition Root | App entry point, scene composition, top-level dependency wiring | SwiftUI, `ScaleClimbingPresentation` | Direct domain reach-through, business rules, persistence/audio/security policy decisions | `scripts/check-architecture.sh`, future app build checks |
| `ScaleClimbingAudio` | Adapter / Generated Playback | Synthesize deterministic note, chord, rhythm and spectral PCM; AVAudioEngine audio-only playback | MusicTheoryCore, AVFoundation | SwiftUI, microphone capture, networking, persistence | Deterministic sample tests and iOS simulator build |
| Future `AudioEngine` | Adapter / Port Implementation | Generated note/chord playback and later input adapters | AVFAudio, domain ports | UI ownership, learning decisions, persistence policy | Future OpenSpec and tests |
| Future `LearningEngine` | Policy Engine / Functional Core | Skill graph, mastery, adaptive scheduling | Domain models, local value types | SwiftUI, audio frameworks, network, persistence implementation | Future OpenSpec and tests |

## Dependency direction

```text
ScaleClimbingApp -> ScaleClimbingPresentation -> MusicTheoryCore\nScaleClimbingPresentation -> ScaleClimbingProgress -> MusicTheoryCore
```

Future platform adapters may depend inward on domain contracts, but domain code never imports platform frameworks.

## Pattern details

### Functional Core / Domain Model

Domain objects are immutable value types where practical. They expose deterministic behavior and are tested without UI, audio, network, persistence, or permissions.

### MVVM + Unidirectional View Events

SwiftUI views render state from view models and send explicit user intents such as `submit(key)`. Views must not duplicate answer-evaluation rules.

### Local Persistence Adapter

The progress adapter owns encoding and UserDefaults access. It implements the domain store protocol, keeps data device-local and is injected into presentation view models so tests use an in-memory store.

### Composition Root

The app target wires root views and future concrete dependencies. It should remain thin and should not contain music-theory or learning-policy behavior.
