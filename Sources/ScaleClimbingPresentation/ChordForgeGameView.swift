import MusicTheoryCore
import SwiftUI

public struct ChordForgeGameView: View {
    @StateObject private var viewModel: ChordForgeViewModel
    private let onPlayChord: ([PitchClass]) -> Void

    public init(
        viewModel: @autoclosure @escaping () -> ChordForgeViewModel = ChordForgeViewModel(),
        onPlayChord: @escaping ([PitchClass]) -> Void = { _ in }
    ) {
        _viewModel = StateObject(wrappedValue: viewModel())
        self.onPlayChord = onPlayChord
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            header
            keyboard
            selectedSummary
            feedback
            roundSummary
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
            Text(viewModel.roundProgressText)
                .font(.subheadline.weight(.semibold))
            Text(viewModel.sessionSummaryText)
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
        .accessibilityElement(children: .combine)
    }

    private var keyboard: some View {
        PianoKeyboardView(
            model: viewModel.keyboard,
            highlightedPitchClasses: viewModel.selectedPitchClasses,
            onKeyTap: { key in viewModel.toggle(key) }
        )
    }

    private var selectedSummary: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(viewModel.selectionProgressText)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(viewModel.selectedSummaryText)
                .font(.subheadline.monospaced())
        }
        .padding(.horizontal)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(viewModel.selectionProgressText). \(viewModel.selectedSummaryText)")
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

    private var roundSummary: some View {
        Text(viewModel.roundSummaryText)
            .font(.callout.weight(.semibold))
            .padding(.horizontal)
            .accessibilityLabel(viewModel.roundSummaryText)
    }

    private var controls: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            Button("Hear chord") {
                onPlayChord(viewModel.targetPitchClasses)
            }
            .buttonStyle(.bordered)
            .accessibilityHint("Play the target chord using generated tones")

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
        .controlSize(.large)
        .padding(.horizontal)
        .accessibilityIdentifier("chord.controls")
    }

}

#Preview {
    ChordForgeGameView()
}
