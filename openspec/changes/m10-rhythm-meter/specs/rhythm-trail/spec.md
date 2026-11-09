# Rhythm Trail requirements

## Rhythm domain
The domain SHALL define note/rest durations, beat subdivisions and 2/4, 3/4, 4/4 and 6/8 meter patterns.

- Each meter SHALL expose beat count, subdivision grouping, accented pulse positions and a stable identifier.
- Simple meters SHALL group subdivisions in twos; 6/8 SHALL group six eighth notes as 3+3.
- Generated click patterns SHALL be deterministic and retain accent information.

## Rhythm Trail practice
- **Explore** SHALL disclose the selected meter's grouping and pulse pattern.
- **Listen** SHALL play the click pattern without revealing the target meter, score only the first answer, then explain the grouping.
- **Tap** SHALL show a visual pulse and collect the required number of taps; feedback SHALL distinguish complete/incomplete patterns and invite retry.
- Mode or meter changes SHALL reset stale attempts and score state.
- The UI SHALL expose stable accessibility identifiers and remain usable on an iPhone simulator.

## Validation
- Tests SHALL cover meter grouping, accents, deterministic click generation and presentation score/retry state.
- iPhone UI coverage SHALL prove route entry, blind listening and tap retry.
- Manual acceptance SHALL check audible accents, visual pulse and VoiceOver.
