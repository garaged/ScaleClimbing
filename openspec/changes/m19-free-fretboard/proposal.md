# M19 — Guitar Instrument Playground: Free Fretboard

## Intent
Let learners explore the guitar as an unscored instrument using the M18 relational mapping and M17 live audio architecture. Deliver an offline six-string 24-fret standard-tuned guitar with responsive fret windows, visible/hidden labels, independent sounding positions and accessible audition.

## Delivery
Stack on M18 PR #20 (`6f8fdae588ad8ce2662f7bb33ddde086debc25bd`), not main. Keep separate draft PR and diff. Owner explicitly defers manual acceptance until related milestones are implemented; neither milestone is approved for merge yet. Automated gates remain required.

## Scope
- Separate Home Free Fretboard route alongside Free Keyboard; no practice-zone scoring or Learning Path mutation.
- High E at top, low E at bottom; open strings at fret zero; horizontal bounded fret-window paging. Equal-width educational cells, fret markers, string gauges and dark wood styling. Portrait uses fewer frets, landscape/iPad more; no forced orientation.
- Direct tap/hold to sound a position, slide across frets or strings to articulate notes, simultaneous finger chords. Most recent contact wins on one physical string; releasing it restores an older held contact. Distinct strings sounding one pitch remain independent. Release on touch end/cancel, resize, paging, background and navigation.
- Reuse live audio worker with a separate typed guitar voice namespace and locally generated, decaying harmonic pluck (not sampled guitar or full physical model). Accessible single-position audition. No permission, account, network, dependency or App Store changes.
- Persist label preference, not active notes. English/es-MX controls and accessible position descriptions.

## Non-goals
Physical guitar sensing, realistic picking-hand/fretting-hand simulation, bends, capo/tuning editor, recordings, chord recognition, ergonomic fingering, CAGED or scored exercises. Swipe is sequential touch articulation, not a realistic simultaneous strum simulation.

## Acceptance
Pure geometry, contact/voice identity, tuning and range tests; route/localization and iPhone UI tests; make check, simulator and release builds. Owner combined physical-device acceptance before merge.
