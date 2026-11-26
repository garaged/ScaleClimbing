# M17 — Instrument Playground: free keyboard (stacked on M16)

## Intent
Let learners freely play music on their iPhone—especially in landscape—without exercise prompts, scoring, or progress updates. Start with an expressive, offline polyphonic piano. Guitar fretboard and other instruments remain future work, but use a minimal note-on/note-off interface so those surfaces can share the live-sound service later.

## Delivery boundary
- Branch: `agent/m17-instrument-playground`, originally stacked on M16; M16 PR #18 merged as `42448e03`. Draft PR #19 now targets `main` directly. Preserve the separate M17 diff and history.
- M16 is a stabilization PR. M17 MUST NOT modify M16 issue decisions, audio regressions, submitted 0.3.0 build, or App Store account state.
- Navigation: a prominent **Free Keyboard** entry on Home, separate from graded practice zones and Learning Path.
- Interactive on-device piano: press and hold to sustain notes, multiple simultaneous touches for chords, glide between adjacent keys, release on finger-up/cancel/scene-background/navigation.
- Piano geometry, correct black-key hit precedence, label contrast and names reuse the M16 shared palette/model; meaningful VoiceOver keyboard labels and an accessible single-note audition action.
- Responsive register: 1 octave in portrait phone width, 2 on wide phone, up to 3 on large iPad; choose starting octave without changing scoring. Persist optional visual note labels independently of Standard/Novice exercise assistance.
- Live sound is generated locally from accurate MIDI pitches with independent polyphonic voices; no use of M16's latest-request-wins exercise player for touch-and-hold polyphony. A bounded attack/release avoids clicks; cache simple loopable tones and cap voice count.
- Secure, privacy-preserving: no network calls, microphone, MIDI device access, sample downloads, accounts, ads, recording, or permission prompts.
- No feature flags for unavailable future instruments, no new dependency, no route migration.

## Out of scope
- Guitar fretboard, MIDI import/output, sustain pedal, recording/export, instrument samples, pitch capture, scoring, lessons, velocity sensitivity, sophisticated timbre presets, automatic orientation lock.
- Full keyboard across every octave simultaneously; choose the visible starting register.

## Exit / release
Swift package and simulator/Release build + XCUITest green, owner acceptance on physical iPhone in portrait and landscape and iPad, rapid polyphonic audio smooth on speaker and alternate route if possible. Do not mark this complete solely on hosted compilation. App Store replacement build/recording remains owner-operated.

## M17-UI-001 portrait polish
The first iPhone 17 portrait simulator screenshot exposed stretched keys: the canvas expanded vertically without respecting natural-key width. Treat the key shape and narrow controls as a focused layout polish task; keep audio, multitouch, instrument range and landscape semantics unchanged. Test sizing as pure presentation logic and re-check touch geometry after any layout adjustment.
