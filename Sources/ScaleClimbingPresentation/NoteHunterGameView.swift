import SwiftUI

public struct NoteHunterGameView: View {
    @StateObject private var viewModel: NoteHunterViewModel

    public init(viewModel: @autoclosure @escaping () -> NoteHunterViewModel = NoteHunterViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            header
            keyboard
            feedback
            controls
            Spacer(minLength: 0)
        }
        .padding(.vertical)
        .navigationTitle("Note Hunter")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.title)
                .font(.largeTitle.bold())
            Text(viewModel.instructions)
                .font(.headline)
            Text(viewModel.scoreText)
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
    }

    private var keyboard: some View {
        PianoKeyboardView(
            model: viewModel.keyboard,
            highlightedPitchClass: viewModel.selectedPitchClass,
            onKeyTap: { key in viewModel.submit(key) }
        )
    }

    private var feedback: some View {
        Text(viewModel.feedbackText)
            .font(.body)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal)
            .accessibilityLabel(viewModel.feedbackText)
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
