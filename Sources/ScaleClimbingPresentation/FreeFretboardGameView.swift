import MusicTheoryCore
import SwiftUI

/// Unscored, direct-touch exploration; the domain mapping is shared with future exercises.
public struct FreeFretboardGameView: View {
    @AppStorage("freeFretboard.showNoteNames") private var showNoteNames = true
    @State private var start = 0
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.colorScheme) private var colorScheme

    private let onNoteOn: (Int, Pitch) -> Void
    private let onNoteOff: (Int) -> Void
    private let onAllNotesOff: () -> Void
    private let onPrepare: ([Pitch]) -> Void
    private let onAudition: (Pitch) -> Void

    public init(onNoteOn: @escaping (Int, Pitch) -> Void = { _, _ in },
                onNoteOff: @escaping (Int) -> Void = { _ in },
                onAllNotesOff: @escaping () -> Void = {},
                onPrepare: @escaping ([Pitch]) -> Void = { _ in },
                onAudition: @escaping (Pitch) -> Void = { _ in }) {
        self.onNoteOn = onNoteOn
        self.onNoteOff = onNoteOff
        self.onAllNotesOff = onAllNotesOff
        self.onPrepare = onPrepare
        self.onAudition = onAudition
    }

    public var body: some View {
        GeometryReader { proxy in
            let width = max(0, Double(proxy.size.width) - 24)
            let window = FretboardWindow(start: start, width: width)
            let wide = width >= 480
            VStack(spacing: 8) {
                if wide {
                    HStack { rangeControls(window); Spacer(minLength: 8); noteToggle }
                } else {
                    rangeControls(window)
                    noteToggle
                }
                if !wide { Spacer(minLength: 0) }
                #if os(iOS)
                FreeFretboardTouchSurface(window: window, showNoteNames: showNoteNames,
                    isActive: scenePhase == .active, onEvent: handle, onAudition: onAudition)
                    .frame(height: max(80, min(wide ? 360 : 320, proxy.size.height - (wide ? 82 : 145))))
                    .accessibilityIdentifier("fretboard.surface")
                #else
                ScrollView {
                    VStack(spacing: 4) {
                        ForEach(1...6, id: \.self) { string in
                            HStack {
                                ForEach(Array(window.frets), id: \.self) { fret in
                                    if let pitch = InstrumentMapping.standardGuitar.pitch(at: .fret(string: string, fret: fret)) {
                                        Button(showNoteNames ? pitch.description : "\(fret)") { onAudition(pitch) }
                                            .accessibilityLabel(String(format: AppCopy.text("String %d, fret %d, %@"), string, fret, pitch.description))
                                    }
                                }
                            }
                        }
                    }
                }
                #endif
                Text(AppCopy.text("Tap or hold a note. Slide across strings or frets to play."))
                    .font(.footnote).foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .accessibilityIdentifier("fretboard.help")
                if !wide { Spacer(minLength: 0) }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .onAppear {
                onPrepare(InstrumentMapping.standardGuitar.positions.compactMap { InstrumentMapping.standardGuitar.pitch(at: $0) })
            }
            .onChange(of: window) { _, newWindow in
                onAllNotesOff()
                if start != newWindow.start { start = newWindow.start }
            }
            .onChange(of: scenePhase) { _, phase in if phase != .active { onAllNotesOff() } }
            .onDisappear { onAllNotesOff() }
        }
        .background(ScaleClimbingPalette.canvas(for: colorScheme).ignoresSafeArea())
        .navigationTitle(AppCopy.text("Free Fretboard"))
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    private var noteToggle: some View {
        Toggle(AppCopy.text("Note names"), isOn: $showNoteNames)
            .font(.subheadline)
            .accessibilityIdentifier("fretboard.noteNames")
    }

    private func rangeControls(_ window: FretboardWindow) -> some View {
        HStack(spacing: 10) {
            Button { start = window.previousStart } label: {
                Image(systemName: "chevron.left").frame(minWidth: 44, minHeight: 44)
            }
            .disabled(window.start == 0)
            .accessibilityLabel(AppCopy.text("Lower frets"))
            .accessibilityIdentifier("fretboard.lower")
            VStack(spacing: 2) {
                Text(String(format: AppCopy.text("Frets %d–%d"), window.start, window.frets.upperBound))
                    .font(.subheadline.monospacedDigit().weight(.semibold))
                    .accessibilityIdentifier("fretboard.range")
                Text(AppCopy.text("Standard tuning")).font(.caption).foregroundStyle(.secondary)
            }
            Button { start = window.nextStart } label: {
                Image(systemName: "chevron.right").frame(minWidth: 44, minHeight: 44)
            }
            .disabled(window.frets.upperBound == 24)
            .accessibilityLabel(AppCopy.text("Higher frets"))
            .accessibilityIdentifier("fretboard.higher")
        }
    }

    private func handle(_ event: FretboardNoteEvent) {
        switch event {
        case .on(let string, let pitch): onNoteOn(string, pitch)
        case .off(let string): onNoteOff(string)
        }
    }
}
