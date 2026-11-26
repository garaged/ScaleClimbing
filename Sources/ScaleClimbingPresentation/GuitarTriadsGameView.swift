import Foundation
import MusicTheoryCore
import SwiftUI

public struct GuitarTriadsGameView: View {
    @State private var session = GuitarTriadSession()
    @State private var start = 0
    private let onNote: (Pitch) -> Void
    private let onChord: ([Pitch]) -> Void
    private let onStop: () -> Void
    @Environment(\.scenePhase) private var scenePhase
    public init(onNote: @escaping (Pitch) -> Void, onChord: @escaping ([Pitch]) -> Void, onStop: @escaping () -> Void) {
        self.onNote = onNote; self.onChord = onChord; self.onStop = onStop
    }

    public var body: some View {
        GeometryReader { proxy in
            let window = FretboardWindow(start: start, width: max(0, Double(proxy.size.width) - 40))
            PracticeScreen {
                VStack(alignment: .leading, spacing: 12) {
                    PracticeCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Picker(AppCopy.text("Practice mode"), selection: Binding(get: { session.mode }, set: { session.select($0); resetWindow() })) {
                                ForEach(GuitarTriadMode.allCases, id: \.self) { mode in Text(title(mode)).tag(mode) }
                            }.pickerStyle(.menu).accessibilityIdentifier("guitarTriad.mode")
                            Text(prompt).font(.title2.bold()).accessibilityIdentifier("guitarTriad.prompt")
                            Text(String(format: AppCopy.text("Strings %d–%d"), session.round.reference.firstString, session.round.reference.firstString + 2))
                            Text(String(format: AppCopy.text("%d/%d correct"), session.correct, session.attempts))
                                .accessibilityIdentifier("guitarTriad.score")
                            Text(AppCopy.text("Use three adjacent strings; fretted notes span at most four frets.")).font(.caption).foregroundStyle(.secondary)
                        }
                    }
                    HStack {
                        Button { start = window.previousStart } label: { Image(systemName: "chevron.left").frame(minWidth: 44, minHeight: 44) }
                            .disabled(window.start == 0).accessibilityLabel(AppCopy.text("Lower frets"))
                        Spacer()
                        Text(String(format: AppCopy.text("Frets %d–%d"), window.start, window.frets.upperBound))
                        Spacer()
                        Button { start = window.nextStart } label: { Image(systemName: "chevron.right").frame(minWidth: 44, minHeight: 44) }
                            .disabled(window.frets.upperBound == 24).accessibilityLabel(AppCopy.text("Higher frets"))
                    }
                    FretboardSelectionView(window: window, showNames: true, result: session.lastResult,
                        locked: session.lastResult == true, selectedPositions: Set(session.selection),
                        allowedStrings: Set(session.round.reference.firstString...session.round.reference.firstString + 2),
                        identifierPrefix: "guitarTriad", onSelect: { position in
                            session.toggle(position)
                            if session.selection.contains(position), let pitch = InstrumentMapping.standardGuitar.pitch(at: position) { onNote(pitch) }
                        })
                    Text(session.pitches.map(\.description).joined(separator: " · ")).accessibilityIdentifier("guitarTriad.selection")
                    Text(feedback).practiceFeedbackCard().accessibilityIdentifier("guitarTriad.feedback")
                    HStack {
                        Button(AppCopy.text("Hear reference")) { onStop(); onChord(session.round.reference.pitches) }
                        Spacer()
                        Button(AppCopy.text("Replay attempt")) { onStop(); onChord(session.pitches) }.disabled(session.pitches.isEmpty)
                    }.buttonStyle(.bordered)
                    HStack {
                        Button(AppCopy.text("Clear")) { session.clear() }.disabled(session.lastResult == true)
                        Spacer()
                        Button(AppCopy.text("Check chord")) { _ = session.check() }.practicePrimaryAction()
                            .disabled(session.selection.count != 3 || session.lastResult == true).accessibilityIdentifier("guitarTriad.check")
                        Button(AppCopy.text("Next round")) { session.next(); resetWindow() }.buttonStyle(.bordered)
                    }
                }
            }.onChange(of: window) { _, new in if start != new.start { start = new.start } }
        }
        .navigationTitle(AppCopy.text("Guitar Triads"))
        .onAppear { resetWindow() }
        .onDisappear { onStop() }
        .onChange(of: scenePhase) { _, phase in if phase != .active { onStop() } }
    }
    private func resetWindow() {
        let positions = session.round.source?.positions ?? session.round.reference.positions
        let frets = positions.compactMap { position -> Int? in if case .fret(_, let f) = position { return f }; return nil }
        start = max(0, (frets.min() ?? 0) - 1)
    }
    private func title(_ mode: GuitarTriadMode) -> String {
        switch mode {
        case .construction: return AppCopy.text("Construct triad")
        case .inversion: return AppCopy.text("Find inversion")
        case .transformation: return AppCopy.text("Change major/minor")
        }
    }
    private func chordName(_ chord: Chord) -> String {
        chord.root.sharpName + " " + AppCopy.text(chord.definition == .majorTriad ? "Major" : "Minor")
    }
    private var prompt: String {
        let target = chordName(session.round.chord)
        switch session.mode {
        case .construction: return String(format: AppCopy.text("Build %@."), target)
        case .inversion: return String(format: AppCopy.text("Build %@ — %@."), target, AppCopy.text(session.round.reference.inversion.title))
        case .transformation: return String(format: AppCopy.text("Change %@ to %@ by moving only the third."), session.round.source.map { chordName($0.chord) } ?? "", target)
        }
    }
    private var feedback: String {
        if session.lastResult == true { return AppCopy.text("Correct. The chord and requested shape agree.") }
        if session.lastResult == false {
            let identity = RelationalAnswerCriterion.chordIdentity(session.round.chord).accepts(session.selection, on: .standardGuitar)
            return AppCopy.text(identity ? "Right chord tones; check the inversion, span or requested transformation." : "Not yet. Check the root, third and fifth.")
        }
        return AppCopy.text("Choose one position on each requested string.")
    }
}
