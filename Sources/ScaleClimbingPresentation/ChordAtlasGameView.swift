import MusicTheoryCore
import SwiftUI

public struct ChordAtlasGameView: View {
    @StateObject private var viewModel: ChordAtlasViewModel
    private let onPlayVoicing: ([Pitch]) -> Void

    public init(
        viewModel: @autoclosure @escaping () -> ChordAtlasViewModel = ChordAtlasViewModel(),
        onPlayVoicing: @escaping ([Pitch]) -> Void = { _ in }
    ) {
        _viewModel = StateObject(wrappedValue: viewModel())
        self.onPlayVoicing = onPlayVoicing
    }

    public var body: some View {
        PracticeScreen {
            VStack(alignment: .leading, spacing: 16) {
                Picker("Chord family", selection: Binding(
                    get: { viewModel.family },
                    set: { viewModel.selectFamily($0) }
                )) {
                    ForEach(ChordAtlasFamily.allCases) { family in
                        Text(family.title).tag(family)
                    }
                }
                .pickerStyle(.menu)
                .accessibilityIdentifier("atlas.family")

                Picker("Practice style", selection: Binding(
                    get: { viewModel.mode },
                    set: { viewModel.selectMode($0) }
                )) {
                    ForEach(ChordAtlasMode.allCases) { mode in
                        Text(mode.title).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .accessibilityIdentifier("atlas.mode")

                Text(viewModel.roundText + " · " + viewModel.scoreText)
                    .font(.subheadline.monospacedDigit())
                    .accessibilityIdentifier("atlas.progress")
                Text(viewModel.promptText)
                    .font(.title3.weight(.semibold))
                    .accessibilityIdentifier("atlas.prompt")

                Button {
                    onPlayVoicing(viewModel.referencePitches)
                } label: {
                    Label("Hear chord", systemImage: "speaker.wave.2.fill")
                        .frame(maxWidth: .infinity, minHeight: 52)
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("atlas.hear")
                .accessibilityHint("Play the reference chord without changing the answer")

                if viewModel.mode == .listen {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(viewModel.availableQualities, id: \.id) { quality in
                            Button(quality.name) { viewModel.chooseQuality(quality) }
                                .buttonStyle(.bordered)
                                .controlSize(.large)
                                .disabled(viewModel.isAnswered)
                                .accessibilityIdentifier("atlas.quality.\(quality.id)")
                        }
                    }
                } else {
                    PianoKeyboardView(
                        model: viewModel.keyboard,
                        highlightedPitchClasses: viewModel.selectedPitchClasses,
                        onKeyTap: { key in viewModel.toggle(key.pitchClass) }
                    )
                    Text(viewModel.selectionText)
                        .font(.callout.monospaced())
                        .accessibilityIdentifier("atlas.selection")
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        Button("Check chord") {
                            viewModel.checkConstruction()
                            if let attempt = viewModel.submittedPitches {
                                onPlayVoicing(attempt)
                            }
                        }
                        .disabled(!viewModel.canCheck)
                        .buttonStyle(.borderedProminent)
                        .accessibilityIdentifier("atlas.check")
                        Button("Replay attempt") {
                            if let attempt = viewModel.submittedPitches {
                                onPlayVoicing(attempt)
                            }
                        }
                        .disabled(viewModel.submittedPitches == nil)
                        .accessibilityIdentifier("atlas.replay")
                        Button("Clear") { viewModel.clear() }
                            .accessibilityIdentifier("atlas.clear")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }

                Text(viewModel.feedbackText)
                    .practiceFeedbackCard()
                    .accessibilityIdentifier("atlas.feedback")

                Button("Next chord") { viewModel.nextRound() }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .accessibilityIdentifier("atlas.next")
                    .disabled(viewModel.mode == .listen && !viewModel.isAnswered)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical)
        }
        .navigationTitle("Chord Atlas")
    }
}

#Preview {
    NavigationStack { ChordAtlasGameView() }
}
