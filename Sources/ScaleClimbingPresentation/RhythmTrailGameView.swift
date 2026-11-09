import MusicTheoryCore
import SwiftUI

public struct RhythmTrailGameView: View {
    @StateObject private var viewModel: RhythmTrailViewModel
    private let onPlayRhythm: (RhythmPattern) -> Void
    public init(viewModel: @autoclosure @escaping () -> RhythmTrailViewModel = RhythmTrailViewModel(), onPlayRhythm: @escaping (RhythmPattern) -> Void = { _ in }) {
        _viewModel = StateObject(wrappedValue: viewModel()); self.onPlayRhythm = onPlayRhythm
    }
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Rhythm Trail").font(.largeTitle.bold()).accessibilityAddTraits(.isHeader)
                Picker("Meter", selection: Binding(get: { viewModel.meter }, set: { viewModel.selectMeter($0) })) {
                    ForEach(RhythmMeter.allCases) { Text($0.title).tag($0) }
                }.pickerStyle(.menu).accessibilityIdentifier("rhythm.meter")
                Picker("Practice style", selection: Binding(get: { viewModel.mode }, set: { viewModel.selectMode($0) })) {
                    ForEach(RhythmTrailMode.allCases) { Text($0.title).tag($0) }
                }.pickerStyle(.segmented).accessibilityIdentifier("rhythm.mode")
                Text(viewModel.scoreText).font(.subheadline.monospacedDigit()).accessibilityIdentifier("rhythm.score")
                Text(viewModel.promptText).font(.title3.weight(.semibold)).accessibilityIdentifier("rhythm.prompt")
                Text(viewModel.pulseText).font(.largeTitle).accessibilityLabel("Pulse pattern \(viewModel.pulseText)").accessibilityIdentifier("rhythm.pulse")
                Button { onPlayRhythm(viewModel.pattern) } label: {
                    Label("Hear pulse", systemImage: "speaker.wave.2.fill").frame(maxWidth: .infinity, minHeight: 52)
                }.buttonStyle(.borderedProminent).accessibilityIdentifier("rhythm.hear")
                if viewModel.mode == .explore {
                    Text(viewModel.meter.explanation).foregroundStyle(.secondary).accessibilityIdentifier("rhythm.explanation")
                } else if viewModel.mode == .listen {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(RhythmMeter.allCases) { meter in
                            Button(meter.title) { viewModel.chooseMeter(meter) }.buttonStyle(.bordered).controlSize(.large).disabled(viewModel.isAnswered).accessibilityIdentifier("rhythm.answer.\(meter.rawValue.replacing("/", with: "-"))")
                        }
                    }
                } else {
                    Text("Taps: \(viewModel.tapCount) / \(viewModel.meter.pulseCount)").accessibilityIdentifier("rhythm.taps")
                    Button("Tap pulse") { viewModel.tapPulse() }.buttonStyle(.borderedProminent).controlSize(.large).accessibilityIdentifier("rhythm.tap")
                    HStack {
                        Button("Check taps") { viewModel.checkTapPattern() }.disabled(viewModel.tapCount == 0).accessibilityIdentifier("rhythm.check")
                        Button("Clear") { viewModel.clear() }.accessibilityIdentifier("rhythm.clear")
                    }.buttonStyle(.bordered).controlSize(.large)
                }
                Text(viewModel.feedbackText).padding().frame(maxWidth: .infinity, alignment: .leading).background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14)).accessibilityIdentifier("rhythm.feedback")
                Button("Next meter") { viewModel.nextMeter() }.buttonStyle(.bordered).accessibilityIdentifier("rhythm.next").disabled(viewModel.mode == .listen && !viewModel.isAnswered)
            }.frame(maxWidth: .infinity, alignment: .leading).padding(.vertical)
        }.navigationTitle("Rhythm Trail")
    }
}
