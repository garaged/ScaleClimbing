import SwiftUI

public struct NoteHunterGameView: View {
    @StateObject private var viewModel: NoteHunterViewModel

    public init(viewModel: @autoclosure @escaping () -> NoteHunterViewModel = NoteHunterViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 20) {
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

            PianoKeyboardView(
                model: viewModel.keyboard,
                highlightedPitchClass: viewModel.selectedPitchClass,
                onKeyTap: { key in viewModel.submit(key) }
            )

            Text(viewModel.feedbackText)
                .font(.body)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)
                .accessibilityLiveRegion(.polite)

            Spacer(minLength: 0)
        }
        .padding(.vertical)
        .navigationTitle("Note Hunter")
    }
}

public struct ScaleClimbingRootView: View {
    public init() {}

    public var body: some View {
        NavigationStack {
            NoteHunterGameView()
        }
    }
}

#Preview {
    ScaleClimbingRootView()
}
