import MusicTheoryCore
import SwiftUI

public struct TimbreLabGameView: View {
    @StateObject private var viewModel: TimbreLabViewModel
    private let onPlayTimbre: (TimbrePlayback) -> Void

    public init(
        viewModel: @autoclosure @escaping () -> TimbreLabViewModel = TimbreLabViewModel(),
        onPlayTimbre: @escaping (TimbrePlayback) -> Void = { _ in }
    ) {
        _viewModel = StateObject(wrappedValue: viewModel())
        self.onPlayTimbre = onPlayTimbre
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Picker(
                    "Spectrum",
                    selection: Binding(
                        get: { viewModel.profile },
                        set: { viewModel.selectProfile($0) }
                    )
                ) {
                    ForEach(TimbreProfile.allCases) { profile in
                        Text(profile.title).tag(profile)
                    }
                }
                .pickerStyle(.menu)
                .accessibilityIdentifier("timbre.profile")

                Picker(
                    "Practice style",
                    selection: Binding(
                        get: { viewModel.mode },
                        set: { viewModel.selectMode($0) }
                    )
                ) {
                    ForEach(TimbreLabMode.allCases) { mode in
                        Text(mode.title).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .accessibilityIdentifier("timbre.mode")

                Text(viewModel.scoreText)
                    .font(.subheadline.monospacedDigit())
                    .accessibilityIdentifier("timbre.score")

                Text(viewModel.promptText)
                    .font(.title3.weight(.semibold))
                    .accessibilityIdentifier("timbre.prompt")

                Button {
                    onPlayTimbre(viewModel.playback)
                } label: {
                    Label("Hear reference", systemImage: "speaker.wave.2.fill")
                        .frame(maxWidth: .infinity, minHeight: 52)
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("timbre.hear")

                if viewModel.mode == .explore {
                    exploreContent
                } else if viewModel.mode == .listen {
                    listenContent
                } else {
                    buildContent
                }

                Text(viewModel.feedbackText)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))
                    .accessibilityIdentifier("timbre.feedback")

                Button("Next spectrum") {
                    viewModel.nextProfile()
                }
                .buttonStyle(.bordered)
                .disabled(viewModel.mode == .listen && !viewModel.isAnswered)
                .accessibilityIdentifier("timbre.next")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical)
        }
        .navigationTitle("Timbre Lab")
    }

    @ViewBuilder
    private var exploreContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(viewModel.partialText)
                .accessibilityIdentifier("timbre.partials")
            Text(viewModel.harmonicSeriesText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .accessibilityIdentifier("timbre.series")

            Text(viewModel.tuningText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .accessibilityIdentifier("timbre.tuning")

            Text("An octave doubles frequency while keeping the same note name.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button("Hear octave displacement") {
                onPlayTimbre(.octave)
            }
            .buttonStyle(.bordered)
            .accessibilityIdentifier("timbre.octave")

            HStack {
                Button("Hear equal fifth") {
                    onPlayTimbre(.tuning(.equalTemperedFifth))
                }
                .accessibilityIdentifier("timbre.equal-fifth")

                Button("Hear just fifth") {
                    onPlayTimbre(.tuning(.justFifth))
                }
                .accessibilityIdentifier("timbre.just-fifth")
            }
            .buttonStyle(.bordered)

            Button("Hear beating example") {
                onPlayTimbre(.beating)
            }
            .buttonStyle(.bordered)
            .accessibilityIdentifier("timbre.beating")

            Text("Beating is the audible rise and fall from two nearby frequencies.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private var listenContent: some View {
        LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible())],
            spacing: 10
        ) {
            ForEach(TimbreProfile.allCases) { profile in
                Button(profile.title) {
                    viewModel.chooseProfile(profile)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .disabled(viewModel.isAnswered)
                .accessibilityIdentifier("timbre.answer.\(profile.rawValue)")
            }
        }
    }

    @ViewBuilder
    private var buildContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(
                "Selected: " + viewModel.selectedHarmonics.sorted()
                    .map(String.init)
                    .joined(separator: ", ")
            )
            .accessibilityIdentifier("timbre.selected")

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible()), count: 3),
                spacing: 10
            ) {
                ForEach(viewModel.harmonicSeries.partials) { partial in
                    let selected = viewModel.selectedHarmonics.contains(
                        partial.harmonicNumber
                    )
                    Button("Partial \(partial.harmonicNumber)") {
                        viewModel.toggleHarmonic(partial.harmonicNumber)
                    }
                    .buttonStyle(selected ? .borderedProminent : .bordered)
                    .accessibilityIdentifier(
                        "timbre.partial.\(partial.harmonicNumber)"
                    )
                }
            }

            Button("Hear attempt") {
                onPlayTimbre(viewModel.attemptPlayback)
            }
            .buttonStyle(.bordered)
            .disabled(viewModel.selectedHarmonics.isEmpty)
            .accessibilityIdentifier("timbre.hear-attempt")

            HStack {
                Button("Check recipe") {
                    viewModel.checkRecipe()
                }
                .disabled(viewModel.selectedHarmonics.isEmpty)
                .accessibilityIdentifier("timbre.check")

                Button("Clear") {
                    viewModel.clearRecipe()
                }
                .accessibilityIdentifier("timbre.clear")
            }
            .buttonStyle(.bordered)
        }
    }
}
