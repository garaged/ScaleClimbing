import MusicTheoryCore
import SwiftUI

/// A separate unscored destination for exploration. The live audio boundary
/// exposes note-on/off events so future fretted instruments can reuse it.
public struct FreeKeyboardGameView: View {
    @AppStorage("freeKeyboard.startingOctave") private var startingOctave = 4
    @AppStorage("freeKeyboard.showNoteNames") private var showNoteNames = true
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.colorScheme) private var colorScheme

    private let onNoteOn: (Pitch) -> Void
    private let onNoteOff: (Pitch) -> Void
    private let onAllNotesOff: () -> Void
    private let onPrepare: ([Pitch]) -> Void
    private let onAccessibleAudition: (Pitch) -> Void

    public init(
        onNoteOn: @escaping (Pitch) -> Void = { _ in },
        onNoteOff: @escaping (Pitch) -> Void = { _ in },
        onAllNotesOff: @escaping () -> Void = {},
        onPrepare: @escaping ([Pitch]) -> Void = { _ in },
        onAccessibleAudition: @escaping (Pitch) -> Void = { _ in }
    ) {
        self.onNoteOn = onNoteOn
        self.onNoteOff = onNoteOff
        self.onAllNotesOff = onAllNotesOff
        self.onPrepare = onPrepare
        self.onAccessibleAudition = onAccessibleAudition
    }

    public var body: some View {
        GeometryReader { proxy in
            let width = Double(proxy.size.width)
            let layout = InstrumentPlaygroundLayout(width: width, height: Double(proxy.size.height))
            let range = FreeKeyboardRange(startingOctave: startingOctave, surfaceWidth: width - 24)
            let model = range.model
            VStack(spacing: layout.showsHelp ? 8 : 4) {
                PlaygroundControlStrip(showNoteNames: $showNoteNames, identifier: "playground.noteNames") {
                    octaveControls(range)
                }
                GeometryReader { canvas in
                    let height = layout.keyboardHeight(surfaceWidth: Double(canvas.size.width),
                        availableHeight: Double(canvas.size.height), naturalKeyCount: range.naturalKeyCount)
                    #if os(iOS)
                    FreeKeyboardTouchSurface(model: model, showNoteNames: showNoteNames,
                        isActive: scenePhase == .active, onNoteEvent: handleNoteEvent,
                        onAccessibleAudition: onAccessibleAudition)
                        .frame(width: canvas.size.width, height: CGFloat(height))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    #else
                    PianoKeyboardView(model: model, highlightedPitches: [], onKeyTap: { key in
                        onAccessibleAudition(key.pitch)
                    })
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    #endif
                }
                if layout.showsHelp {
                    Text(AppCopy.text("Hold keys to sustain notes. Use several fingers for chords."))
                        .font(.footnote).foregroundStyle(.secondary)
                        .multilineTextAlignment(.center).lineLimit(2)
                        .accessibilityIdentifier("playground.help")
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, layout.showsHelp ? 6 : 2)
            .onAppear { onPrepare(model.keys.map(\.pitch)) }
            .onChange(of: model) { _, newModel in
                onAllNotesOff()
                onPrepare(newModel.keys.map(\.pitch))
            }
            .onDisappear { onAllNotesOff() }
            .onChange(of: scenePhase) { _, phase in
                if phase != .active { onAllNotesOff() }
            }
        }
        .background(ScaleClimbingPalette.canvas(for: colorScheme).ignoresSafeArea())
        .navigationTitle(AppCopy.text("Free Keyboard"))
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    private func handleNoteEvent(_ event: FreeKeyboardNoteEvent) {
        switch event {
        case .on(let pitch): onNoteOn(pitch)
        case .off(let pitch): onNoteOff(pitch)
        }
    }

    private func octaveControls(_ range: FreeKeyboardRange) -> some View {
        HStack(spacing: 4) {
            Button {
                if let lower = range.lowerOctave { startingOctave = lower }
            } label: {
                Image(systemName: "minus.circle")
                    .font(.title3)
                    .frame(minWidth: 44, minHeight: 44)
            }
            .disabled(range.lowerOctave == nil)
            .accessibilityLabel(AppCopy.text("Lower octave"))
            .accessibilityIdentifier("playground.lower")

            Text(range.rangeLabel)
                .font(.subheadline.monospacedDigit().weight(.semibold))
                .lineLimit(1).minimumScaleFactor(0.65)
                .accessibilityIdentifier("playground.range")

            Button {
                if let higher = range.higherOctave { startingOctave = higher }
            } label: {
                Image(systemName: "plus.circle")
                    .font(.title3)
                    .frame(minWidth: 44, minHeight: 44)
            }
            .disabled(range.higherOctave == nil)
            .accessibilityLabel(AppCopy.text("Higher octave"))
            .accessibilityIdentifier("playground.higher")
        }
        .frame(minHeight: 44)
    }
}
