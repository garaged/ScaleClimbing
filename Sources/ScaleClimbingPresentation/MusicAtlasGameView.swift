import Foundation
import MusicTheoryCore
import SwiftUI

/// One shared structure and sounding focus; neither instrument owns the musical concept.
public struct MusicAtlasGameView: View {
    private enum Mode: String, CaseIterable { case note, interval, chord, scale, key }
    @State private var atlas = MusicAtlas()
    @State private var mode: Mode = .note
    @State private var interval = 7
    @State private var chord = ChordDefinition.majorTriad
    @State private var scale = ScaleDefinition.major
    @State private var direction = ScaleDirection.ascending
    @State private var equivalence = AtlasEquivalence.exactPitch
    @State private var octave = 4
    @State private var start = 0
    @State private var details = false
    @State private var comparisonRoot: PitchClass = .c
    @State private var comparisonChord = ChordDefinition.minorTriad
    @Environment(\.scenePhase) private var scenePhase
    private let guitar = InstrumentMapping.standardGuitar
    private let onPiano: (Pitch) -> Void
    private let onGuitar: (Pitch) -> Void
    private let onSequence: ([Pitch]) -> Void
    private let onChord: ([Pitch]) -> Void
    private let onStop: () -> Void

    public init(onPiano: @escaping (Pitch) -> Void, onGuitar: @escaping (Pitch) -> Void,
                onSequence: @escaping ([Pitch]) -> Void, onChord: @escaping ([Pitch]) -> Void,
                onStop: @escaping () -> Void) {
        self.onPiano = onPiano; self.onGuitar = onGuitar; self.onSequence = onSequence
        self.onChord = onChord; self.onStop = onStop
    }

    public var body: some View {
        GeometryReader { proxy in
            let window = FretboardWindow(start: start, width: max(0, Double(proxy.size.width) - 40))
            PracticeScreen {
                VStack(alignment: .leading, spacing: 16) {
                    PracticeCard { structureControls }
                    PracticeCard { focusControls }
                    pianoPanel
                    guitarPanel(window)
                    DisclosureGroup(AppCopy.text("Explore relationships"), isExpanded: $details) {
                        relationshipDetails
                    }.accessibilityIdentifier("atlas.details")
                }
            }
            .onChange(of: window) { _, new in if start != new.start { start = new.start } }
        }
        .navigationTitle(AppCopy.text("Music Atlas"))
        .onChange(of: mode) { _, _ in updateStructure() }
        .onChange(of: interval) { _, _ in updateStructure() }
        .onChange(of: chord) { _, _ in updateStructure() }
        .onChange(of: scale) { _, _ in updateStructure() }
        .onChange(of: direction) { _, _ in updateStructure() }
        .onDisappear { onStop() }
        .onChange(of: scenePhase) { _, phase in if phase != .active { onStop() } }
    }

    private var structureControls: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(AppCopy.text("One musical idea, two instruments")).font(.title2.bold())
            Picker(AppCopy.text("Root"), selection: $atlas.root) {
                ForEach(PitchClass.allCases, id: \.self) { Text($0.sharpName).tag($0) }
            }.accessibilityIdentifier("atlas.root")
            Picker(AppCopy.text("Musical structure"), selection: $mode) {
                ForEach(Mode.allCases, id: \.self) { Text(modeTitle($0)).tag($0) }
            }.accessibilityIdentifier("atlas.structure")
            switch mode {
            case .note, .key: EmptyView()
            case .interval:
                Picker(AppCopy.text("Directed interval"), selection: $interval) {
                    ForEach(-12...12, id: \.self) { n in Text(String(format: AppCopy.text("%+d semitones"), n)).tag(n) }
                }
            case .chord:
                Picker(AppCopy.text("Chord quality"), selection: $chord) {
                    ForEach(ChordDefinition.chordAtlasCatalog, id: \.id) { Text(AppCopy.text($0.name)).tag($0) }
                }
            case .scale:
                Picker(AppCopy.text("Scale"), selection: $scale) {
                    ForEach(ScaleDefinition.scaleExplorerCatalog) { Text(AppCopy.text($0.name)).tag($0) }
                }
                Picker(AppCopy.text("Direction"), selection: $direction) {
                    Text(AppCopy.text("Ascending")).tag(ScaleDirection.ascending)
                    Text(AppCopy.text("Descending")).tag(ScaleDirection.descending)
                }.pickerStyle(.segmented)
            }
            Text(atlas.tones.map(\.sharpName).joined(separator: " · "))
                .font(.headline).accessibilityIdentifier("atlas.tones")
            Button(AppCopy.text("Hear structure")) {
                onStop()
                if mode == .chord { onChord(atlas.referencePitches) }
                else { onSequence(atlas.referencePitches) }
            }.buttonStyle(.bordered).accessibilityIdentifier("atlas.hear")
        }.pickerStyle(.menu)
    }

    private var focusControls: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(String(format: AppCopy.text("Focus pitch: %@"), atlas.focus.description))
                .font(.headline).accessibilityIdentifier("atlas.focus")
            Picker(AppCopy.text("Matching positions"), selection: $equivalence) {
                Text(AppCopy.text("Exact pitch")).tag(AtlasEquivalence.exactPitch)
                Text(AppCopy.text("Pitch class")).tag(AtlasEquivalence.pitchClass)
            }.pickerStyle(.segmented).accessibilityIdentifier("atlas.equivalence")
            Text(String(format: AppCopy.text("Guitar matches: %d"), atlas.matches(on: guitar, equivalence: equivalence).count))
                .font(.subheadline).accessibilityIdentifier("atlas.matchCount")
            Text(AppCopy.text("Tap either instrument to follow the same sounding note. Outlines mark matches; colored markers show structure tones."))
                .font(.caption).foregroundStyle(.secondary)
        }
    }

    private var pianoPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(AppCopy.text("Piano")).font(.headline)
                Spacer()
                Stepper(String(format: AppCopy.text("Octave %d"), octave), value: $octave, in: 2...6)
                    .fixedSize()
            }
            let keyboard = PianoKeyboardModel.chromaticRange(from: Pitch(.c, octave: octave), through: Pitch(.b, octave: octave))
            let members = Set(atlas.tones)
            let highlights = Set(keyboard.keys.filter { members.contains($0.pitchClass) }.map(\.pitch))
            let matches = Set(atlas.matches(on: MusicAtlas.piano, equivalence: equivalence).compactMap(MusicAtlas.piano.pitch(at:)))
            PianoKeyboardView(model: keyboard, highlightedPitches: highlights, focusedPitches: matches) { key in
                guard atlas.select(.pianoKey(midi: key.pitch.midiNumber), on: MusicAtlas.piano) else { return }
                onStop(); onPiano(key.pitch)
                if let first = atlas.matches(on: guitar, equivalence: .exactPitch).first, case .fret(_, let fret) = first {
                    start = max(0, fret - 1)
                }
            }.accessibilityIdentifier("atlas.piano")
        }
    }

    private func guitarPanel(_ window: FretboardWindow) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(AppCopy.text("Guitar")).font(.headline)
            HStack {
                Button { start = window.previousStart } label: { Image(systemName: "chevron.left").frame(minWidth: 44, minHeight: 44) }
                    .disabled(window.start == 0).accessibilityLabel(AppCopy.text("Lower frets"))
                Spacer()
                Text(String(format: AppCopy.text("Frets %d–%d"), window.start, window.frets.upperBound))
                Spacer()
                Button { start = window.nextStart } label: { Image(systemName: "chevron.right").frame(minWidth: 44, minHeight: 44) }
                    .disabled(window.frets.upperBound == 24).accessibilityLabel(AppCopy.text("Higher frets"))
            }
            let labels = Dictionary(uniqueKeysWithValues: atlas.positions(on: guitar).compactMap { position -> (InstrumentPosition, String)? in
                guard let pitch = guitar.pitch(at: position), let degree = atlas.degree(for: pitch.pitchClass) else { return nil }
                return (position, degree)
            })
            FretboardSelectionView(window: window, showNames: false, identifierPrefix: "atlas",
                overlayLabels: labels, shapePositions: Set(atlas.matches(on: guitar, equivalence: equivalence))) { position in
                guard atlas.select(position, on: guitar) else { return }
                octave = min(6, max(2, atlas.focus.octave))
                onGuitar(atlas.focus)
            }
        }
    }

    private var relationshipDetails: some View {
        VStack(alignment: .leading, spacing: 10) {
            let signature = KeySignature.major(for: atlas.root)
            if mode == .key {
                Text(signature.title).font(.headline)
                Text(String(format: AppCopy.text("Key signature: %@"), signature.accidentals.isEmpty ? AppCopy.text("None") : signature.accidentals.map(\.description).joined(separator: " ")))
                ForEach(atlas.keyChords) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(item.romanNumeral) · \(item.root.sharpName) \(AppCopy.text(item.definition.name))")
                            Text(AppCopy.text(item.function.title)).font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button(AppCopy.text("Hear chord")) { onStop(); onChord(item.pitches) }.buttonStyle(.bordered)
                    }
                }
            } else if mode == .chord {
                Text(AppCopy.text("Compare chords")).font(.headline)
                Picker(AppCopy.text("Comparison root"), selection: $comparisonRoot) {
                    ForEach(PitchClass.allCases, id: \.self) { Text($0.sharpName).tag($0) }
                }
                Picker(AppCopy.text("Comparison quality"), selection: $comparisonChord) {
                    ForEach(ChordDefinition.chordAtlasCatalog, id: \.id) { Text(AppCopy.text($0.name)).tag($0) }
                }
                let other = Chord(root: comparisonRoot, definition: comparisonChord)
                if let result = atlas.compare(with: other) {
                    comparisonLine("Shared tones: %@", result.shared)
                    comparisonLine("First chord only: %@", result.primaryOnly)
                    comparisonLine("Second chord only: %@", result.comparisonOnly)
                    Button(AppCopy.text("Hear comparison chord")) { onStop(); onChord(other.closePositionPitches()) }.buttonStyle(.bordered)
                }
            } else {
                Text(AppCopy.text("Structure tones are pitch classes. Matching an exact pitch also requires the same octave."))
            }
            Text(String(format: AppCopy.text("Focus distance from root in octave 4: %+d semitones."), atlas.focus.midiNumber - Pitch(atlas.root, octave: 4).midiNumber))
                .font(.subheadline)
        }.padding(.vertical, 8)
    }

    private func comparisonLine(_ format: String, _ tones: [PitchClass]) -> some View {
        Text(String(format: AppCopy.text(format), tones.isEmpty ? AppCopy.text("None") : tones.map(\.sharpName).joined(separator: " · ")))
    }
    private func modeTitle(_ value: Mode) -> String {
        switch value {
        case .note: return AppCopy.text("Note")
        case .interval: return AppCopy.text("Interval")
        case .chord: return AppCopy.text("Chord")
        case .scale: return AppCopy.text("Scale")
        case .key: return AppCopy.text("Major key")
        }
    }
    private func updateStructure() {
        switch mode {
        case .note: atlas.structure = .note
        case .interval: atlas.structure = .interval(interval)
        case .chord: atlas.structure = .chord(chord)
        case .scale: atlas.structure = .scale(scale, direction)
        case .key: atlas.structure = .majorKey
        }
    }
}
