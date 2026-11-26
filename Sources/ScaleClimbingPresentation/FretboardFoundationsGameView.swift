import Foundation
import MusicTheoryCore
import SwiftUI

public struct FretboardFoundationsGameView: View {
    @State private var session = GuitarFoundationSession()
    @State private var start = 0
    @AppStorage("learningAssistanceLevel") private var assistanceRaw = LearningAssistanceLevel.standard.rawValue
    private let onGuitarAudition: (Pitch) -> Void
    private let onPianoAudition: (Pitch) -> Void

    public init(onGuitarAudition: @escaping (Pitch) -> Void = { _ in },
                onPianoAudition: @escaping (Pitch) -> Void = { _ in }) {
        self.onGuitarAudition = onGuitarAudition
        self.onPianoAudition = onPianoAudition
    }

    private var guitar: InstrumentMapping { .standardGuitar }
    private var namesVisible: Bool {
        PianoKeyboardLabelPolicy.showsNames(for: .noteIdentification,
            assistance: LearningAssistanceLevel(rawValue: assistanceRaw) ?? .standard)
    }

    public var body: some View {
        GeometryReader { proxy in
            let width = max(0, Double(proxy.size.width) - 40)
            let window = FretboardWindow(start: start, width: width)
            PracticeScreen {
                VStack(alignment: .leading, spacing: 14) {
                    PracticeCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Picker(AppCopy.text("Practice mode"), selection: Binding(
                                get: { session.mode }, set: { mode in session.select(mode); resetWindow() })) {
                                ForEach(GuitarFoundationMode.allCases, id: \.self) { mode in
                                    Text(modeTitle(mode)).tag(mode)
                                }
                            }
                            .pickerStyle(.menu)
                            .accessibilityIdentifier("fretPractice.mode")
                            Text(prompt).font(.title2.bold()).accessibilityIdentifier("fretPractice.prompt")
                            Text(String(format: AppCopy.text("Round %d of %d"), session.index + 1, session.roundCount))
                                .font(.caption).foregroundStyle(.secondary)
                            Text(String(format: AppCopy.text("%d/%d correct"), session.correct, session.attempts))
                                .font(.subheadline.monospacedDigit()).accessibilityIdentifier("fretPractice.score")
                            if let anchor = session.round.anchor {
                                anchorView(anchor)
                            }
                        }
                    }
                    HStack {
                        Button { start = window.previousStart } label: {
                            Image(systemName: "chevron.left").frame(minWidth: 44, minHeight: 44)
                        }.disabled(window.start == 0)
                            .accessibilityLabel(AppCopy.text("Lower frets"))
                            .accessibilityIdentifier("fretPractice.lower")
                        Spacer()
                        Text(String(format: AppCopy.text("Frets %d–%d"), window.start, window.frets.upperBound))
                            .font(.subheadline.monospacedDigit().weight(.semibold))
                            .accessibilityIdentifier("fretPractice.range")
                        Spacer()
                        Button { start = window.nextStart } label: {
                            Image(systemName: "chevron.right").frame(minWidth: 44, minHeight: 44)
                        }.disabled(window.frets.upperBound == 24)
                            .accessibilityLabel(AppCopy.text("Higher frets"))
                            .accessibilityIdentifier("fretPractice.higher")
                    }
                    FretboardSelectionView(window: window, showNames: namesVisible,
                        anchor: guitarAnchor, selected: session.selected?.position,
                        result: session.lastResult, locked: session.lastResult == true,
                        onSelect: submit)
                    if guitarAnchor != nil {
                        Text(AppCopy.text("Blue marks the starting position.")).font(.caption).foregroundStyle(.secondary)
                    }
                    Text(feedback).practiceFeedbackCard().accessibilityIdentifier("fretPractice.feedback")
                    HStack {
                        Button(AppCopy.text("Hear reference")) { hearReference() }
                            .buttonStyle(.bordered).disabled(referencePitch == nil)
                            .accessibilityIdentifier("fretPractice.hear")
                        Spacer()
                        Button(AppCopy.text("Next round")) { session.next(); resetWindow() }
                            .practicePrimaryAction().accessibilityIdentifier("fretPractice.next")
                    }
                }
            }
            .onChange(of: window) { _, value in if start != value.start { start = value.start } }
        }
        .navigationTitle(AppCopy.text("Fretboard Foundations"))
    }

    private var guitarAnchor: InstrumentPosition? {
        guard let anchor = session.round.anchor, anchor.instrument == guitar else { return nil }
        return anchor.position
    }

    private func resetWindow() {
        if case .fret(_, let fret) = guitarAnchor { start = max(0, fret - 2) }
        else { start = 0 }
    }

    private func submit(_ position: InstrumentPosition) {
        guard session.submit(position) != nil, let pitch = session.selected?.pitch else { return }
        onGuitarAudition(pitch)
    }

    private var referencePitch: Pitch? {
        if let anchor = session.round.anchor { return anchor.pitch }
        switch session.round.criterion {
        case .absolutePitch(let pitch): return pitch
        case .pitchClass(let note): return Pitch(note, octave: 4)
        default: return nil
        }
    }

    private func hearReference() {
        guard let pitch = referencePitch else { return }
        if session.mode == .transfer { onPianoAudition(pitch) }
        else { onGuitarAudition(pitch) }
    }

    private func anchorView(_ anchor: ResolvedInstrumentPosition) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            if case .fret(let string, let fret) = anchor.position {
                Text(String(format: AppCopy.text("String %d, fret %d, %@"), string, fret, anchor.pitch.description))
                    .font(.subheadline).accessibilityIdentifier("fretPractice.anchor")
            } else {
                Text(String(format: AppCopy.text("Piano reference: %@"), anchor.pitch.description))
                    .font(.subheadline).accessibilityIdentifier("fretPractice.anchor")
                PianoKeyboardView(model: .chromaticRange(from: Pitch(.c, octave: 4), through: Pitch(.b, octave: 4)),
                    highlightedPitches: [anchor.pitch], onKeyTap: { key in onPianoAudition(key.pitch) })
            }
        }
    }

    private func modeTitle(_ mode: GuitarFoundationMode) -> String {
        switch mode {
        case .noteClass: return AppCopy.text("Guitar Note Hunter")
        case .exactPitch: return AppCopy.text("Exact pitch")
        case .unison: return AppCopy.text("Unison Explorer")
        case .octave: return AppCopy.text("Octave Explorer")
        case .interval: return AppCopy.text("Interval Navigator")
        case .transfer: return AppCopy.text("Piano to guitar")
        }
    }

    private var prompt: String {
        switch session.round.criterion {
        case .pitchClass(let note):
            return String(format: AppCopy.text("Find any %@ on the guitar."), note.sharpName)
        case .absolutePitch(let pitch):
            let key = session.mode == .transfer ? "Find the same piano pitch on guitar: %@." : "Find exactly %@ on the guitar."
            return String(format: AppCopy.text(key), pitch.description)
        case .distinctUnison:
            return AppCopy.text("Find the same pitch at a different position.")
        case .directedInterval(_, let semitones):
            if session.mode == .octave {
                return AppCopy.text(semitones > 0 ? "Find one octave above the starting note." : "Find one octave below the starting note.")
            }
            return String(format: AppCopy.text(semitones > 0 ? "Find %d semitones above the starting note." : "Find %d semitones below the starting note."), abs(semitones))
        default: return AppCopy.text("Choose a fretboard position.")
        }
    }

    private var feedback: String {
        guard let selected = session.selected, let result = session.lastResult else {
            return AppCopy.text("Choose a fretboard position.")
        }
        let prefix = AppCopy.text(result ? "Correct." : "Not yet. Try another position.")
        let actual = String(format: AppCopy.text("You played %@."), selected.pitch.description)
        if let anchor = session.round.anchor {
            let interval = MusicalRelations.interval(from: anchor, to: selected)
            return "\(prefix) \(actual) " + String(format: AppCopy.text("Distance: %+d semitones."), interval.signedSemitones)
        }
        return "\(prefix) \(actual)"
    }
}
