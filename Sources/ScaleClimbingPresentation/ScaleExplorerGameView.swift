import MusicTheoryCore
import SwiftUI

public struct ScaleExplorerGameView: View {
    @StateObject private var viewModel: ScaleExplorerViewModel
    private let onPlayScale: ([Pitch]) -> Void

    public init(
        viewModel: @autoclosure @escaping () -> ScaleExplorerViewModel = ScaleExplorerViewModel(),
        onPlayScale: @escaping ([Pitch]) -> Void = { _ in }
    ) {
        _viewModel = StateObject(wrappedValue: viewModel())
        self.onPlayScale = onPlayScale
    }

    public var body: some View {
        PracticeScreen {
            VStack(alignment: .leading, spacing: 16) {
                Picker("Scale family", selection: Binding(
                    get: { viewModel.family },
                    set: { viewModel.selectFamily($0) }
                )) {
                    ForEach(ScaleExplorerFamily.allCases) { family in
                        Text(family.title).tag(family)
                    }
                }
                .pickerStyle(.menu)
                .accessibilityIdentifier("scale.family")

                Picker("Scale", selection: Binding(
                    get: { viewModel.definition },
                    set: { viewModel.selectDefinition($0) }
                )) {
                    ForEach(viewModel.availableDefinitions) { definition in
                        Text(definition.name).tag(definition)
                    }
                }
                .pickerStyle(.menu)
                .accessibilityIdentifier("scale.definition")

                Picker("Root", selection: Binding(
                    get: { viewModel.root },
                    set: { viewModel.selectRoot($0) }
                )) {
                    ForEach(PitchClass.allCases, id: \.self) { root in
                        Text(root.sharpName).tag(root)
                    }
                }
                .pickerStyle(.menu)
                .accessibilityIdentifier("scale.root")

                Picker("Practice style", selection: Binding(
                    get: { viewModel.mode },
                    set: { viewModel.selectMode($0) }
                )) {
                    ForEach(ScaleExplorerMode.allCases) { mode in
                        Text(mode.title).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .accessibilityIdentifier("scale.mode")

                Text(viewModel.roundText + " · " + viewModel.scoreText)
                    .font(.subheadline.monospacedDigit())
                    .accessibilityIdentifier("scale.progress")
                Text(AppCopy.learnerText(viewModel.promptText))
                    .font(.title3.weight(.semibold))
                    .accessibilityIdentifier("scale.prompt")

                Button {
                    onPlayScale(viewModel.referencePitches)
                } label: {
                    Label("Hear scale", systemImage: "speaker.wave.2.fill")
                        .frame(maxWidth: .infinity, minHeight: 52)
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("scale.hear")
                .accessibilityHint("Play the scale ascending and descending without changing the answer")

                if viewModel.mode == .explore {
                    Text(AppCopy.learnerText(viewModel.intervalText))
                        .accessibilityIdentifier("scale.intervals")
                    Text(AppCopy.learnerText(viewModel.noteText))
                        .accessibilityIdentifier("scale.notes")
                    Text(AppCopy.learnerText(viewModel.keyContextText))
                        .foregroundStyle(.secondary)
                        .accessibilityIdentifier("scale.key-context")
                    PianoKeyboardView(
                        model: viewModel.keyboard,
                        highlightedPitchClasses: Set(viewModel.currentScale.pitchClasses),
                        onKeyTap: { _ in }
                    )
                    .allowsHitTesting(false)
                } else if viewModel.mode == .listen {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(viewModel.availableDefinitions) { definition in
                            Button(definition.name) { viewModel.chooseDefinition(definition) }
                                .buttonStyle(.bordered)
                                .controlSize(.large)
                                .disabled(viewModel.isAnswered)
                                .accessibilityIdentifier("scale.answer.\(definition.id)")
                        }
                    }
                } else {
                    PianoKeyboardView(
                        model: viewModel.keyboard,
                        highlightedPitchClasses: viewModel.selectedPitchClasses,
                        onKeyTap: { key in viewModel.toggle(key.pitchClass) }
                    )
                    Text(AppCopy.learnerText(viewModel.selectionText))
                        .font(.callout.monospaced())
                        .accessibilityIdentifier("scale.selection")
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        Button("Check scale") {
                            viewModel.checkConstruction()
                            if let attempt = viewModel.submittedPitches {
                                onPlayScale(attempt)
                            }
                        }
                        .disabled(!viewModel.canCheck)
                        .buttonStyle(.borderedProminent)
                        .accessibilityIdentifier("scale.check")

                        Button("Replay attempt") {
                            if let attempt = viewModel.submittedPitches {
                                onPlayScale(attempt)
                            }
                        }
                        .disabled(viewModel.submittedPitches == nil)
                        .accessibilityIdentifier("scale.replay")

                        Button("Clear") { viewModel.clear() }
                            .accessibilityIdentifier("scale.clear")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }

                Text(AppCopy.learnerText(viewModel.feedbackText))
                    .practiceFeedbackCard()
                    .accessibilityIdentifier("scale.feedback")

                Button("Next scale") { viewModel.nextRound() }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .accessibilityIdentifier("scale.next")
                    .disabled(viewModel.mode == .listen && !viewModel.isAnswered)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical)
        }
        .navigationTitle("Scale Explorer")
    }
}

#Preview {
    NavigationStack { ScaleExplorerGameView() }
}
