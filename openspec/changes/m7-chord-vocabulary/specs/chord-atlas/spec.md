# Chord Atlas requirements

## Chord vocabulary
The music domain SHALL define interval structures for major, minor, diminished, augmented, sus2, sus4, power, dominant seventh, major seventh, minor seventh, half-diminished seventh and fully diminished seventh.

- Each chord SHALL expose interval offsets from root, a name, a stable ID, and pitch classes.
- All four seventh structures must use correct semitone offsets: dominant [0,4,7,10], major [0,4,7,11], minor [0,3,7,10], half-diminished [0,3,6,10], fully diminished [0,3,6,9].
- A two-tone power chord SHALL not be mistaken for a three-tone triad.
- Harmonic function requires context and is NOT inferred from an isolated chord.

## Chord Atlas listening
- **GIVEN** an unanswered round in a selected family, **WHEN** a learner presses Hear chord, **THEN** offline generated tones play together without revealing answer or modifying score.
- Answers SHALL be chosen from that family's named chord qualities; root and selected family are visible; chord quality stays undisclosed until answer.
- Exactly one answer per listening round SHALL count. Feedback SHALL name the correct quality and display interval and pitch-class details after answering.

## Chord Atlas construction
- **GIVEN** a chord quality and root, the learner SHALL select pitch classes on the keyboard, check and hear the attempted chord, compare with the reference, and retry a wrong answer.
- Correctness SHALL depend on set equality, with missing and added notes rejected and with scoring tracking attempts.
- Round change and family change SHALL clear old selections, feedback and replay snapshots.
- Audio and UI callback boundaries SHALL remain free of microphone access and external resources.

## Validation
- Domain catalog coverage for each interval pattern and transpositions.
- Presentation tests for blind answers, scoring lock, retry, family/mode resets.
- iPhone simulator UI regression for route entry, playable controls and answer feedback.
- Short manual check of audio quality, layout and accessibility required before merge.
