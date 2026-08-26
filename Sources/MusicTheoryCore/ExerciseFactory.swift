public enum ExerciseFactory {
    public static func noteHunter(target: PitchClass) -> ExercisePrompt {
        ExercisePrompt(
            id: "note-hunter-\(target.sharpName)",
            kind: .noteHunter,
            title: "Find \(target.sharpName)",
            instructions: "Tap the matching note on the keyboard.",
            expectedAnswer: .pitchClass(target),
            choices: PitchClass.allCases.map { .pitchClass($0) },
            explanation: "\(target.sharpName) can appear in multiple octaves, but it always has the same pitch class."
        )
    }

    public static func scaleBuilder(root: PitchClass, scale: ScaleDefinition) -> ExercisePrompt {
        let builtScale = Scale(root: root, definition: scale)
        return ExercisePrompt(
            id: "scale-builder-\(root.sharpName)-\(scale.id)",
            kind: .scaleBuilder,
            title: "Build \(root.sharpName) \(scale.name)",
            instructions: "Select every pitch class in the scale.",
            expectedAnswer: .pitchClasses(builtScale.pitchClasses),
            choices: PitchClass.allCases.map { .pitchClass($0) },
            explanation: "A \(scale.name) scale from \(root.sharpName) uses semitone offsets \(scale.intervalsFromRoot)."
        )
    }

    public static func chordForge(root: PitchClass, chord: ChordDefinition) -> ExercisePrompt {
        let builtChord = Chord(root: root, definition: chord)
        return ExercisePrompt(
            id: "chord-forge-\(root.sharpName)-\(chord.id)",
            kind: .chordForge,
            title: "Forge \(root.sharpName) \(chord.name)",
            instructions: "Select the chord tones.",
            expectedAnswer: .pitchClasses(builtChord.pitchClasses),
            choices: PitchClass.allCases.map { .pitchClass($0) },
            explanation: "A \(chord.name) uses semitone offsets \(chord.intervalsFromRoot) from the root."
        )
    }

    public static func majorOrMinor(root: PitchClass, isMajor: Bool) -> ExercisePrompt {
        let expected = isMajor ? "major" : "minor"
        return ExercisePrompt(
            id: "chord-quality-\(root.sharpName)-\(expected)",
            kind: .chordQuality,
            title: "Major or minor?",
            instructions: "Listen to the chord and choose its quality.",
            expectedAnswer: .text(expected),
            choices: [.text("major"), .text("minor")],
            explanation: "Major triads have a major third above the root. Minor triads have a minor third above the root."
        )
    }
}
