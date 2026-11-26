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
            let octaves = FreeKeyboardRange.octaveCount(forWidth: Double(proxy.size.width))
            let compact = octaves == 1
            let keyHeight = FreeKeyboardSizing.keyboardHeight(
                viewportWidth: Double(proxy.size.width),
                viewportHeight: Double(proxy.size.height)
            )
            VStack(spacing: 10) {
                controls(visibleOctaves: octaves, compact: compact)

                // Center the proportionally sized piano in portrait rather than
                // stretching the key faces to fill unused vertical space.
                if compact {
                    Spacer(minLength: 0)
                }

                #if os(iOS)
                FreeKeyboardTouchSurface(
                    model: model,
                    showNoteNames: showNoteNames,
                    isActive: scenePhase == .active,
                    onNoteEvent: handleNoteEvent,
                    onAccessibleAudition: onAccessibleAudition
                )
                .frame(maxWidth: .infinity)
                .frame(height: CGFloat(keyHeight))
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

                if compact {
                    Spacer(minLength: 0)
                }
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

    @ViewBuilder
    private func controls(visibleOctaves: Int, compact: Bool) -> some View {
        if compact {
            // One readable control per row avoids compressed Spanish labels on
            // portrait phones and leaves the octave controls easy to operate.
            VStack(spacing: 6) {
                HStack {
                    octaveControls(visibleOctaves: visibleOctaves)
                    Spacer(minLength: 0)
                }
                noteNamesToggle
                    .frame(maxWidth: .infinity)
            }
            .controlSize(.regular)
        } else {
            HStack(spacing: 10) {
                octaveControls(visibleOctaves: visibleOctaves)
                Spacer(minLength: 4)
                noteNamesToggle
                    .fixedSize(horizontal: true, vertical: false)
            }
            .controlSize(.regular)
        }
    }

    private var noteNamesToggle: some View {
        Toggle(AppCopy.text("Note names"), isOn: $showNoteNames)
            .font(.subheadline)
            .accessibilityIdentifier("playground.noteNames")
    }

    private func octaveControls(visibleOctaves: Int) -> some View {
        HStack(spacing: 12) {
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
        }
        .frame(minHeight: 44)
    }
}
