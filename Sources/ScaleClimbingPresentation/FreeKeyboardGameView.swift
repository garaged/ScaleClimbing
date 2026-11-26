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
            let model = FreeKeyboardRange.keyboard(
                startingOctave: startingOctave,
                viewportWidth: Double(proxy.size.width)
            )
            VStack(spacing: 10) {
                controls(visibleOctaves: FreeKeyboardRange.octaveCount(forWidth: Double(proxy.size.width)))

                #if os(iOS)
                FreeKeyboardTouchSurface(
                    model: model,
                    showNoteNames: showNoteNames,
                    isActive: scenePhase == .active,
                    onNoteEvent: handleNoteEvent,
                    onAccessibleAudition: onAccessibleAudition
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityIdentifier("playground.keyboard")
                #else
                PianoKeyboardView(model: model, highlightedPitches: [], onKeyTap: { key in
                    onAccessibleAudition(key.pitch)
                })
                #endif

                Text(AppCopy.text("Hold keys to sustain notes. Use several fingers for chords."))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                    .accessibilityIdentifier("playground.help")
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .onAppear { onPrepare(model.keys.map(\.pitch)) }
            .onChange(of: startingOctave) { _, _ in
                onAllNotesOff()
                onPrepare(model.keys.map(\.pitch))
            }
            .onChange(of: proxy.size.width) { _, _ in
                onAllNotesOff()
                onPrepare(model.keys.map(\.pitch))
            }
            .onDisappear { onAllNotesOff() }
            .onChange(of: scenePhase) { _, phase in
                if phase != .active {
                    onAllNotesOff()
                }
            }
        }
        .background(ScaleClimbingPalette.canvas(for: colorScheme).ignoresSafeArea())
        .navigationTitle(AppCopy.text("Free Keyboard"))
    }

    private func handleNoteEvent(_ event: FreeKeyboardNoteEvent) {
        switch event {
        case .on(let pitch): onNoteOn(pitch)
        case .off(let pitch): onNoteOff(pitch)
        }
    }

    private func controls(visibleOctaves: Int) -> some View {
        HStack(spacing: 10) {
            Button {
                startingOctave = max(2, startingOctave - 1)
            } label: {
                Image(systemName: "minus.circle")
                    .font(.title3)
            }
            .disabled(startingOctave <= 2)
            .accessibilityLabel(AppCopy.text("Lower octave"))
            .accessibilityIdentifier("playground.lower")

            Text("C\(startingOctave)–B\(startingOctave + visibleOctaves - 1)")
                .font(.subheadline.monospacedDigit().weight(.semibold))
                .accessibilityIdentifier("playground.range")

            Button {
                startingOctave = min(6 - visibleOctaves + 1, startingOctave + 1)
            } label: {
                Image(systemName: "plus.circle")
                    .font(.title3)
            }
            .disabled(startingOctave + visibleOctaves - 1 >= 6)
            .accessibilityLabel(AppCopy.text("Higher octave"))
            .accessibilityIdentifier("playground.higher")

            Spacer(minLength: 4)

            Toggle(AppCopy.text("Note names"), isOn: $showNoteNames)
                .font(.subheadline)
                .fixedSize(horizontal: true, vertical: false)
                .accessibilityIdentifier("playground.noteNames")
        }
        .controlSize(.regular)
        .frame(minHeight: 44)
    }
}
