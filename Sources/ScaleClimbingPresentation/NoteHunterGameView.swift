import MusicTheoryCore
import SwiftUI

public struct NoteHunterGameView: View {
    @StateObject private var viewModel: NoteHunterViewModel
    private let onPlayPitch: (Pitch) -> Void

    public init(
        viewModel: @autoclosure @escaping () -> NoteHunterViewModel = NoteHunterViewModel(),
        onPlayPitch: @escaping (Pitch) -> Void = { _ in }
    ) {
        _viewModel = StateObject(wrappedValue: viewModel())
        self.onPlayPitch = onPlayPitch
    }

    public var body: some View {
        PracticeScreen {
            VStack(alignment: .leading, spacing: 20) {
            header
            keyboard
            feedback
            controls
            Spacer(minLength: 0)
        }
            .padding(.vertical)
        }
        .navigationTitle("Note Hunter")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(AppCopy.learnerText(viewModel.title))
                .font(.largeTitle.bold())
            Text(AppCopy.learnerText(viewModel.instructions))
                .font(.headline)
            Text(AppCopy.learnerText(viewModel.scoreText))
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
    }

    private var keyboard: some View {
        PianoKeyboardView(
            model: viewModel.keyboard,
            highlightedPitchClass: viewModel.selectedPitchClass,
            onKeyTap: { key in
                onPlayPitch(key.pitch)
                viewModel.submit(key)
            }
        )
    }

    private var feedback: some View {
        Text(AppCopy.learnerText(viewModel.feedbackText))
            .font(.body)
            .practiceFeedbackCard()
            .padding(.horizontal)
            .accessibilityLabel(AppCopy.learnerText(viewModel.feedbackText))
    }

    private var controls: some View {
        Button("Next note") {
            viewModel.advanceToNextPrompt()
        }
        .buttonStyle(.borderedProminent)
        .padding(.horizontal)
        .accessibilityHint("Move to the next note hunter prompt")
    }
}
