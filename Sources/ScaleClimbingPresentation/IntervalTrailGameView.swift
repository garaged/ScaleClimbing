import MusicTheoryCore
import SwiftUI

public struct IntervalTrailGameView: View {
    @StateObject private var viewModel: IntervalTrailViewModel
    private let onPlayInterval: ([Pitch]) -> Void

    public init(
        viewModel: @autoclosure @escaping () -> IntervalTrailViewModel = IntervalTrailViewModel(),
        onPlayInterval: @escaping ([Pitch]) -> Void = { _ in }
    ) {
        _viewModel = StateObject(wrappedValue: viewModel())
        self.onPlayInterval = onPlayInterval
    }

    public var body: some View {
        PracticeScreen {
            VStack(alignment: .leading, spacing: 20) {
                Text(viewModel.roundText + " · " + viewModel.modeText)
                    .font(.headline)
                    .accessibilityIdentifier("interval.round")
                Text(viewModel.scoreText)
                    .font(.subheadline.monospacedDigit())
                    .accessibilityIdentifier("interval.score")
                Text(viewModel.promptText)
                    .font(.title3.weight(.semibold))
                    .accessibilityIdentifier("interval.prompt")
                Button {
                    onPlayInterval(viewModel.pitchesToPlay)
                } label: {
                    Label("Play interval", systemImage: "speaker.wave.2.fill")
                        .frame(maxWidth: .infinity, minHeight: 50)
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("interval.play")
                .accessibilityHint("Play the two notes in order without revealing them")

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(viewModel.choices, id: \.self) { choice in
                        Button(viewModel.answerLabel(choice)) {
                            viewModel.answer(choice)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                        .frame(maxWidth: .infinity)
                        .disabled(viewModel.isAnswered)
                        .accessibilityIdentifier("interval.answer.\(viewModel.answerLabel(choice))")
                    }
                }

                Text(viewModel.feedbackText)
                    .accessibilityIdentifier("interval.feedback")
                    .practiceFeedbackCard()
                Button("Next interval") { viewModel.nextRound() }
                    .buttonStyle(.borderedProminent)
                    .disabled(!viewModel.isAnswered)
                    .accessibilityIdentifier("interval.next")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .navigationTitle("Interval Trail")
    }
}

#Preview {
    NavigationStack { IntervalTrailGameView() }
}
