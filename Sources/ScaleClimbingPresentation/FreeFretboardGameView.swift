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
            let layout = InstrumentPlaygroundLayout(width: Double(proxy.size.width), height: Double(proxy.size.height))
            VStack(spacing: layout.showsHelp ? 8 : 4) {
                PlaygroundControlStrip(showNoteNames: $showNoteNames, identifier: "fretboard.noteNames") {
                    rangeControls(window)
                }
                GeometryReader { canvas in
                    let height = layout.fretboardHeight(availableHeight: Double(canvas.size.height))
                    #if os(iOS)
                    FreeFretboardTouchSurface(window: window, showNoteNames: showNoteNames,
                        isActive: scenePhase == .active, onEvent: handle, onAudition: onAudition)
                        .frame(width: canvas.size.width, height: CGFloat(height))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    #endif
                }
                if layout.showsHelp {
                    Text(AppCopy.text("Tap or hold a note. Slide across strings or frets to play."))
                        .font(.footnote).foregroundStyle(.secondary)
                        .multilineTextAlignment(.center).lineLimit(2)
                        .accessibilityIdentifier("fretboard.help")
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, layout.showsHelp ? 6 : 2)
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

    private func rangeControls(_ window: FretboardWindow) -> some View {
        HStack(spacing: 4) {
            Button { start = window.previousStart } label: {
                Image(systemName: "chevron.left").frame(minWidth: 44, minHeight: 44)
            }
            .disabled(window.start == 0)
            .accessibilityLabel(AppCopy.text("Lower frets"))
            .accessibilityIdentifier("fretboard.lower")
            Text(String(format: AppCopy.text("Frets %d–%d"), window.start, window.frets.upperBound))
                .font(.subheadline.monospacedDigit().weight(.semibold))
                .lineLimit(1).minimumScaleFactor(0.65)
                .accessibilityIdentifier("fretboard.range")
                .accessibilityHint(AppCopy.text("Standard tuning"))
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
