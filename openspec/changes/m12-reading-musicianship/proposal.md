# M12 — Reading and Musicianship

## Intent
Connect the sounds learners already recognise to compact written music. Notation Trail presents readable staff positions, spelling choices and short melodic dictation as one loop: inspect → hear → answer → understand → retry.

## Scope
- Model treble and bass clef positions, written note spellings, accidentals/enharmonic pairs, beginner solfège degrees and short ordered melodic phrases.
- Render an accessible five-line staff with noteheads, accidentals and ledger lines for a deliberately bounded beginner range.
- Introduce **Notation Trail** with Explore, Read and Dictate flows.
- Explore explains clefs, staff position, enharmonic spellings and common major/minor/dominant-seventh chord symbols.
- Read asks for a written note name without playing the answer automatically. Dictate plays a short generated phrase and asks learners to build the ordered movable-Do solfège sequence.
- Add deterministic domain/presentation/audio-route tests, focused iPhone UI coverage and concise manual acceptance.

## Decisions
- M12 teaches staff literacy before engraving: the staff is a pedagogic display, not a complete notation renderer.
- Written identity stays separate from pitch-class identity. C sharp and D flat can sound alike but remain different spellings with different staff positions.
- Solfège uses a movable-Do major scale in this milestone; chromatic solfège, rhythm dictation and arbitrary key changes are deferred.
- Chord symbols are explanatory vocabulary (major, minor and dominant seventh) rather than a second construction game.

## Non-goals
- Full score import/export, MusicXML/MIDI notation, arbitrary key signatures, complex rhythms, sight-reading performance timing, microphone transcription, persistence, cloud services or a desktop notation editor.
