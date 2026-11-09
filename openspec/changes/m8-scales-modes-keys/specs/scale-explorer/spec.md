# Scale Explorer requirements

## Scale vocabulary
The domain SHALL model major, natural minor, harmonic minor, melodic minor, major pentatonic, minor pentatonic, blues, Ionian, Dorian, Phrygian, Lydian, Mixolydian, Aeolian and Locrian definitions.

- Each definition SHALL have a stable identifier, human-readable name and deterministic ordered ascending interval offsets from its root.
- Ionian SHALL share the major pattern and Aeolian SHALL share the natural-minor pattern while retaining their pedagogical names.
- Melodic minor SHALL ascend [0,2,3,5,7,9,11] and descend using natural-minor offsets [0,2,3,5,7,8,10].
- A scale's pitch classes SHALL express identity without octave. Its ordered pitches SHALL preserve octave transitions, beginning and ending on the tonic.
- Construction correctness SHALL use pitch-class set equality; melodic playback and recognition SHALL use the ordered pitch sequence.

## Keys and circle of fifths
The domain SHALL expose conventional major and natural-minor key-signature metadata and circle-of-fifths position.

- Key-signature metadata SHALL report tonic, mode, accidental kind/count and ordered accidental spellings.
- Circle-of-fifths presentation SHALL identify the selected key and its adjacent fifth relationships without network data.
- Key signature is educational context; it SHALL not silently alter pitch-class computation.

## Offline melodic audio
- **GIVEN** an ordered scale pitch sequence, **WHEN** playback is requested, **THEN** the adapter SHALL synthesize each note in sequence with a deliberate gap and no microphone, file or network dependency.
- Ascending and descending playback SHALL be deterministic and remain off the UI thread.
- Generated sample tests SHALL validate frame structure for arbitrary ordered sequences, not only two-note intervals.

## Scale Explorer practice
- **Explore** SHALL show selected root, scale/mode, interval formula, highlighted keyboard notes, key-signature/circle context and an accessible control to hear the scale.
- **Listen** SHALL play an ordered scale, accept a named scale/mode answer, hide the target name until the first answer, score once per round, and give explanatory feedback.
- **Build** SHALL let the learner select pitch classes, hear a submitted ordered attempt, compare it to the reference set, correct an incorrect attempt and retry.
- Mode, scale family or round changes SHALL reset stale selections, answer state and replay snapshot.
- Controls SHALL have stable accessibility identifiers and remain usable on an iPhone 17 simulator.

## Validation
- Swift tests SHALL cover scale patterns, mode equivalences, melodic-minor direction, octave crossings, key-signature metadata and circle ordering.
- Audio tests SHALL cover ordered multi-note sample generation.
- Presentation and iPhone UI tests SHALL cover Explore information, blind Listen disclosure, score locking, Build retry and navigation.
- A brief in-app audio/accessibility manual check SHALL be required before merge.
