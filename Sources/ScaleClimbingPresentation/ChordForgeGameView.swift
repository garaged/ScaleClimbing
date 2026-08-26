import SwiftUI

public struct ChordForgeGameView: View {
    @StateObject private var viewModel: ChordForgeViewModel

    public init(viewModel: @autoclosure @escaping () -> ChordForgeViewModel = ChordForgeViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            header
            keyboard
            selectedSummary
            feedback
            controls
            Spacer(minLength: 0)
        }
        .padding(.vertical)
        .navigationTitle("Chord Forge")
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
            highlightedPitchClasses: viewModel.selectedPitchClasses,
            onKeyTap: { key in viewModel.toggle(key) }
        )
    }

    private var selectedSummary: some View {
        Text(viewModel.selectedSummaryText)
            .font(.subheadline.monospaced())
            .padding(.horizontal)
            .accessibilityLabel(viewModel.selectedSummaryText)
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
        HStack(spacing: 12) {
            Button("Check chord") {
                viewModel.submitSelection()
            }
            .buttonStyle(.borderedProminent)

            Button("Clear") {
                viewModel.clearSelection()
            }
            .buttonStyle(.bordered)

            Button("Next chord") {
                viewModel.advanceToNextChord()
            }
            .buttonStyle(.bordered)
        }
        .padding(.horizontal)
    }
}

#Preview {
    ChordForgeGameView()
}
