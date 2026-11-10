import MusicTheoryCore
import SwiftUI

public struct VoicingLabGameView: View {
    @StateObject private var viewModel: VoicingLabViewModel
    private let onPlayVoicing: ([Pitch]) -> Void

    public init(
        viewModel: @autoclosure @escaping () -> VoicingLabViewModel = VoicingLabViewModel(),
        onPlayVoicing: @escaping ([Pitch]) -> Void = { _ in }
    ) {
        _viewModel = StateObject(wrappedValue: viewModel())
        self.onPlayVoicing = onPlayVoicing
    }

    public var body: some View {
        PracticeScreen {
            VStack(alignment: .leading, spacing: 16) {

                Picker("Practice range", selection: Binding(
                    get: { viewModel.mode },
                    set: { viewModel.selectMode($0) }
                )) {
                    ForEach(VoicingPracticeMode.allCases) { mode in
                        Text(mode.title).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .accessibilityIdentifier("voicing.mode")

                Text(viewModel.roundText + " · " + viewModel.scoreText)
                    .font(.subheadline.monospacedDigit())
                    .accessibilityIdentifier("voicing.progress")

                Text(viewModel.target.label)
                    .font(.title3.weight(.semibold))
                    .accessibilityIdentifier("voicing.target")

                Text("Find the exact keys and octave positions. Lowest note determines inversion.")
                    .font(.callout)
                    .foregroundStyle(.secondary)

                PianoKeyboardView(
                    model: viewModel.keyboard,
                    highlightedPitches: viewModel.selectedPitches,
                    onKeyTap: { key in viewModel.toggle(key.pitch) }
                )

                Text(viewModel.selectedText)
                    .font(.callout.monospaced())
                    .accessibilityIdentifier("voicing.selected")
                Text(viewModel.feedbackText)
                    .font(.body)
                    .practiceFeedbackCard()
                    .accessibilityIdentifier("voicing.feedback")

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    Button("Hear voicing") { onPlayVoicing(viewModel.targetPitches) }
                        .accessibilityIdentifier("voicing.hear")
                    Button("Check voicing") {
                        viewModel.submit()
                        if let attempt = viewModel.lastAttempt { onPlayVoicing(attempt) }
                    }
                    .disabled(!viewModel.canCheck)
                    .accessibilityIdentifier("voicing.check")
                    .buttonStyle(.borderedProminent)

                    Button("Replay attempt") {
                        if let attempt = viewModel.lastAttempt { onPlayVoicing(attempt) }
                    }
                    .disabled(viewModel.lastAttempt == nil)
                    .accessibilityIdentifier("voicing.replay")

                    Button("Clear") { viewModel.clear() }
                        .accessibilityIdentifier("voicing.clear")
                    Button("Next voicing") { viewModel.next() }
                        .accessibilityIdentifier("voicing.next")
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical)
        }
        .navigationTitle("Voicing Lab")
    }
}

#Preview {
    NavigationStack { VoicingLabGameView() }
}
