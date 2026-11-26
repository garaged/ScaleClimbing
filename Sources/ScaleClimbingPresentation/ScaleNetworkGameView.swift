import Foundation
import MusicTheoryCore
import SwiftUI

public struct ScaleNetworkGameView: View {
    @State private var root: PitchClass = .c
    @State private var shapeIndex = 0
    @State private var overlay: CAGEDOverlay = .majorScale
    @State private var bridge: CAGEDBridgeSession?
    @State private var start = 0
    @State private var selected: InstrumentPosition?
    @AppStorage("learningAssistanceLevel") private var assistanceRaw = LearningAssistanceLevel.standard.rawValue
    @Environment(\.scenePhase) private var scenePhase
    private let onNote: (Pitch) -> Void
    private let onChord: ([Pitch]) -> Void
    private let onStop: () -> Void
    private let guitar = InstrumentMapping.standardGuitar

    public init(onNote: @escaping (Pitch) -> Void, onChord: @escaping ([Pitch]) -> Void, onStop: @escaping () -> Void) {
        self.onNote = onNote; self.onChord = onChord; self.onStop = onStop
    }

    private var shapes: [CAGEDShape] { CAGEDShape.catalog(root: root) }
    private var shape: CAGEDShape { shapes[min(shapeIndex, shapes.count - 1)] }
    private var nextShape: CAGEDShape? { shapeIndex + 1 < shapes.count ? shapes[shapeIndex + 1] : nil }
    private var novice: Bool { assistanceRaw == LearningAssistanceLevel.novice.rawValue }
    private var markers: [InstrumentPosition: String] {
        let positions: [InstrumentPosition]
        if let bridge {
            positions = novice ? guitar.positions.filter { bridge.answers.contains($0) } : []
        } else {
            positions = CAGEDNetwork.positions(in: shape, overlay: overlay)
        }
        return Dictionary(uniqueKeysWithValues: positions.compactMap { position in
            guard let pitch = guitar.pitch(at: position), let degree = overlay.degree(for: pitch.pitchClass, root: root) else { return nil }
            return (position, degree)
        })
    }
    public var body: some View {
        GeometryReader { proxy in
            let window = FretboardWindow(start: start, width: max(0, Double(proxy.size.width) - 40))
            PracticeScreen {
                VStack(alignment: .leading, spacing: 12) {
                    PracticeCard {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Picker(AppCopy.text("Root"), selection: Binding(get: { root }, set: { root = $0; shapeIndex = 0; reset() })) {
                                    ForEach(PitchClass.allCases, id: \.self) { note in Text(note.sharpName).tag(note) }
                                }.accessibilityIdentifier("scaleNetwork.root")
                                Picker(AppCopy.text("Overlay"), selection: Binding(get: { overlay }, set: { overlay = $0; reset() })) {
                                    ForEach(CAGEDOverlay.allCases, id: \.self) { value in Text(overlayTitle(value)).tag(value) }
                                }.accessibilityIdentifier("scaleNetwork.overlay")
                            }.pickerStyle(.menu)
                            Text(String(format: AppCopy.text("%@ major — %@ form"), root.sharpName, shape.form.rawValue))
                                .font(.title2.bold()).accessibilityIdentifier("scaleNetwork.shape")
                            Text(String(format: AppCopy.text("Region: frets %d–%d"), shape.region.lowerBound, shape.region.upperBound))
                            Text(String(format: AppCopy.text("Overlay tonic: %@"), overlay.tonic(for: root).sharpName))
                                .font(.subheadline).foregroundStyle(.secondary)
                            HStack {
                                Button(AppCopy.text("Previous shape")) { shapeIndex -= 1; reset() }.disabled(shapeIndex == 0)
                                Spacer()
                                Button(AppCopy.text("Next shape")) { shapeIndex += 1; reset() }.disabled(nextShape == nil)
                                    .accessibilityIdentifier("scaleNetwork.nextShape")
                            }.buttonStyle(.bordered)
                        }
                    }
                    if let bridge {
                        Text(String(format: AppCopy.text("Find a shared tone between %@ and %@ forms."), bridge.from.form.rawValue, bridge.to.form.rawValue))
                            .font(.headline).accessibilityIdentifier("scaleNetwork.bridgePrompt")
                        Text(String(format: AppCopy.text("Shared region: frets %d–%d"), max(bridge.from.region.lowerBound, bridge.to.region.lowerBound), min(bridge.from.region.upperBound, bridge.to.region.upperBound)))
                            .font(.caption)
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
                    FretboardSelectionView(window: window, showNames: false,
                        selected: bridge?.selected ?? selected, result: bridge?.result,
                        locked: bridge?.result == true, identifierPrefix: "scaleNetwork",
                        overlayLabels: markers, shapePositions: bridge == nil ? Set(shape.positions) : [], onSelect: choose)
                    if bridge == nil {
                        Text(AppCopy.text("R marks the overlay tonic; outlined notes are the major chord shape.")).font(.caption).foregroundStyle(.secondary)
                    }
                    Text(feedback).practiceFeedbackCard().accessibilityIdentifier("scaleNetwork.feedback")
                    HStack {
                        Button(AppCopy.text("Hear shape")) {
                            onStop(); onChord(shape.positions.compactMap(guitar.pitch(at:)).sorted())
                        }.buttonStyle(.bordered).disabled(bridge != nil)
                        Spacer()
                        if bridge != nil {
                            Button(AppCopy.text("Exit bridge")) { reset() }.buttonStyle(.bordered)
                        } else {
                            Button(AppCopy.text("Bridge challenge")) { beginBridge() }.practicePrimaryAction()
                                .disabled(nextShape == nil || nextShape.map { CAGEDNetwork.bridge(from: shape, to: $0, overlay: overlay).isEmpty } == true)
                                .accessibilityIdentifier("scaleNetwork.bridge")
                        }
                    }
                }
            }.onChange(of: window) { _, new in if start != new.start { start = new.start } }
        }
        .navigationTitle(AppCopy.text("Scale Network"))
        .onDisappear { onStop() }
        .onChange(of: scenePhase) { _, phase in if phase != .active { onStop() } }
    }

    private func overlayTitle(_ value: CAGEDOverlay) -> String {
        switch value {
        case .majorScale: return AppCopy.text("Major scale")
        case .majorPentatonic: return AppCopy.text("Major pentatonic")
        case .relativeMinorPentatonic: return AppCopy.text("Relative minor pentatonic")
        case .arpeggio: return AppCopy.text("Major arpeggio")
        }
    }
    private func reset() { bridge = nil; selected = nil; start = shape.region.lowerBound }
    private func beginBridge() {
        guard let nextShape else { return }
        let session = CAGEDBridgeSession(from: shape, to: nextShape, overlay: overlay)
        guard !session.answers.isEmpty else { return }
        bridge = session
        selected = nil
        start = max(shape.region.lowerBound, nextShape.region.lowerBound)
    }
    private func choose(_ position: InstrumentPosition) {
        guard let pitch = guitar.pitch(at: position) else { return }
        if var session = bridge {
            guard session.submit(position) != nil else { return }
            bridge = session
        } else { selected = position }
        onNote(pitch)
    }
    private var feedback: String {
        if let bridge {
            if bridge.result == true { return AppCopy.text("Correct. This position connects both regions.") }
            if bridge.result == false { return AppCopy.text("Not yet. Choose a tone in both regions.") }
            return AppCopy.text("Find one position that belongs to both regions.")
        }
        if let selected, let pitch = guitar.pitch(at: selected) {
            return String(format: AppCopy.text("You played %@."), pitch.description)
        }
        return AppCopy.text("Explore the chord shape and surrounding scale tones.")
    }
}
