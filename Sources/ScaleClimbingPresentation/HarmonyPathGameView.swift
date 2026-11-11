import MusicTheoryCore
import SwiftUI

public struct HarmonyPathGameView: View {
    @StateObject private var viewModel: HarmonyPathViewModel
    private let onPlayProgression: ([[Pitch]]) -> Void

    public init(
        viewModel: @autoclosure @escaping () -> HarmonyPathViewModel = HarmonyPathViewModel(),
        onPlayProgression: @escaping ([[Pitch]]) -> Void = { _ in }
    ) {
        _viewModel = StateObject(wrappedValue: viewModel())
        self.onPlayProgression = onPlayProgression
    }

    public var body: some View {
        PracticeScreen {
            VStack(alignment: .leading, spacing: 16) {
                Picker("Key", selection: Binding(get: { viewModel.tonic }, set: { viewModel.selectTonic($0) })) {
                    ForEach(PitchClass.allCases, id: \.self) { Text($0.sharpName).tag($0) }
                }
                .pickerStyle(.menu)
                .accessibilityIdentifier("harmony.key")

                Picker("Cadence", selection: Binding(get: { viewModel.cadence }, set: { viewModel.selectCadence($0) })) {
                    ForEach(CadenceKind.allCases) { Text($0.title).tag($0) }
                }
                .pickerStyle(.menu)
                .accessibilityIdentifier("harmony.cadence")

                Picker("Practice style", selection: Binding(get: { viewModel.mode }, set: { viewModel.selectMode($0) })) {
                    ForEach(HarmonyPathMode.allCases) { Text($0.title).tag($0) }
                }
                .pickerStyle(.segmented)
                .accessibilityIdentifier("harmony.mode")

                Text(AppCopy.learnerText(viewModel.scoreText)).font(.subheadline.monospacedDigit()).accessibilityIdentifier("harmony.score")
                Text(AppCopy.learnerText(viewModel.promptText)).font(.title3.weight(.semibold)).accessibilityIdentifier("harmony.prompt")

                Button {
                    onPlayProgression(viewModel.progression.voicedChords)
                } label: {
                    Label("Hear cadence", systemImage: "speaker.wave.2.fill").frame(maxWidth: .infinity, minHeight: 52)
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("harmony.hear")

                if viewModel.mode == .explore {
                    Text(AppCopy.learnerText(viewModel.diatonicText)).accessibilityIdentifier("harmony.diatonic")
                    Text("Cadence: " + viewModel.targetRomanNumerals.joined(separator: "–"))
                        .font(.headline)
                        .accessibilityIdentifier("harmony.target")
                    Text(AppCopy.learnerText(viewModel.inversionContextText)).foregroundStyle(.secondary).accessibilityIdentifier("harmony.inversions")
                } else if viewModel.mode == .listen {
                    LazyVGrid(columns: [GridItem(.flexible())], spacing: 10) {
                        ForEach(CadenceKind.allCases) { cadence in
                            Button(cadence.title) { viewModel.chooseCadence(cadence) }
                                .buttonStyle(.bordered)
                                .controlSize(.large)
                                .disabled(viewModel.isAnswered)
                                .accessibilityIdentifier("harmony.answer.\(cadence.rawValue)")
                        }
                    }
                } else {
                    Text(viewModel.selectedRomanNumerals.isEmpty ? "No numerals selected." : "Selected: " + viewModel.selectedRomanNumerals.joined(separator: "–"))
                        .accessibilityIdentifier("harmony.selection")
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(["I", "IV", "V"], id: \.self) { numeral in
                            Button(numeral) { viewModel.appendRomanNumeral(numeral) }
                                .buttonStyle(.bordered)
                                .accessibilityIdentifier("harmony.roman.\(numeral)")
                        }
                    }
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        Button("Check progression") {
                            viewModel.checkConstruction()
                            if let attempt = viewModel.attemptVoicedChords { onPlayProgression(attempt.count >= 2 ? attempt : viewModel.progression.voicedChords) }
                        }
                        .disabled(viewModel.selectedRomanNumerals.isEmpty)
                        .buttonStyle(.borderedProminent)
                        .accessibilityIdentifier("harmony.check")
                        Button("Replay attempt") {
                            if let attempt = viewModel.attemptVoicedChords { onPlayProgression(attempt.count >= 2 ? attempt : viewModel.progression.voicedChords) }
                        }
                        .disabled(viewModel.attemptVoicedChords == nil)
                        .accessibilityIdentifier("harmony.replay")
                        Button("Undo") { viewModel.removeLastRomanNumeral() }.accessibilityIdentifier("harmony.undo")
                        Button("Clear") { viewModel.clear() }.accessibilityIdentifier("harmony.clear")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }

                Text(AppCopy.learnerText(viewModel.feedbackText))
                    .padding().frame(maxWidth: .infinity, alignment: .leading)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))
                    .accessibilityIdentifier("harmony.feedback")

                Button("Next cadence") { viewModel.nextCadence() }
                    .buttonStyle(.bordered).controlSize(.large)
                    .disabled(viewModel.mode == .listen && !viewModel.isAnswered)
                    .accessibilityIdentifier("harmony.next")
            }
            .frame(maxWidth: .infinity, alignment: .leading).padding(.vertical)
        }
        .navigationTitle("Harmony Path")
    }
}
