import MusicTheoryCore
import SwiftUI

public struct EarTrainingGameView: View {
    @StateObject private var viewModel: EarTrainingViewModel
    private let onPlayChord: ([PitchClass]) -> Void

    public init(
        viewModel: @autoclosure @escaping () -> EarTrainingViewModel = EarTrainingViewModel(),
        onPlayChord: @escaping ([PitchClass]) -> Void = { _ in }
    ) {
        _viewModel = StateObject(wrappedValue: viewModel())
        self.onPlayChord = onPlayChord
    }

    public var body: some View {
        PracticeScreen {
            VStack(alignment: .leading, spacing: 24) {
                Text("Major or Minor?")
                    .font(.largeTitle.bold())
                    .accessibilityAddTraits(.isHeader)

                Text(viewModel.roundText)
                    .font(.headline)
                    .accessibilityIdentifier("ear.round")

                Text(viewModel.scoreText + " · " + viewModel.accuracyText)
                    .font(.subheadline.monospacedDigit())
                    .accessibilityIdentifier("ear.score")

                Text(viewModel.promptText)
                    .font(.title3.weight(.semibold))
                    .accessibilityIdentifier("ear.prompt")

                Button {
                    onPlayChord(viewModel.targetPitchClasses)
                } label: {
                    Label("Play chord", systemImage: "speaker.wave.2.fill")
                        .frame(maxWidth: .infinity, minHeight: 54)
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("ear.play")
                .accessibilityHint("Replay the current chord without revealing its identity")

                HStack(spacing: 16) {
                    Button("Major") { viewModel.answer(isMajor: true) }
                        .accessibilityIdentifier("ear.major")
                    Button("Minor") { viewModel.answer(isMajor: false) }
                        .accessibilityIdentifier("ear.minor")
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.roundedRectangle)
                .controlSize(.large)
                .disabled(viewModel.isAnswered)

                Text(viewModel.feedbackText)
                    .font(.body)
                    .accessibilityIdentifier("ear.feedback")

                Button("Next chord") {
                    viewModel.nextChord()
                }
                .buttonStyle(.bordered)
                .accessibilityIdentifier("ear.next")
                .disabled(!viewModel.isAnswered)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .navigationTitle("Ear Training")
    }
}

#Preview {
    NavigationStack { EarTrainingGameView() }
}
