import MusicTheoryCore
import SwiftUI

public struct NotationTrailGameView: View {
    @StateObject private var viewModel: NotationTrailViewModel
    private let onPlayPitch: (Pitch) -> Void
    private let onPlayPhrase: ([Pitch]) -> Void

    public init(
        viewModel: @autoclosure @escaping () -> NotationTrailViewModel = NotationTrailViewModel(),
        onPlayPitch: @escaping (Pitch) -> Void = { _ in },
        onPlayPhrase: @escaping ([Pitch]) -> Void = { _ in }
    ) {
        _viewModel = StateObject(wrappedValue: viewModel())
        self.onPlayPitch = onPlayPitch
        self.onPlayPhrase = onPlayPhrase
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Picker(
                    "Clef",
                    selection: Binding(
                        get: { viewModel.clef },
                        set: { viewModel.selectClef($0) }
                    )
                ) {
                    ForEach(StaffClef.allCases) { clef in
                        Text(clef.title).tag(clef)
                    }
                }
                .pickerStyle(.menu)
                .accessibilityIdentifier("notation.clef")

                Picker(
                    "Practice style",
                    selection: Binding(
                        get: { viewModel.mode },
                        set: { viewModel.selectMode($0) }
                    )
                ) {
                    ForEach(NotationTrailMode.allCases) { mode in
                        Text(mode.title).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .accessibilityIdentifier("notation.mode")

                Text(viewModel.scoreText)
                    .font(.subheadline.monospacedDigit())
                    .accessibilityIdentifier("notation.score")

                Text(viewModel.promptText)
                    .font(.title3.weight(.semibold))
                    .accessibilityIdentifier("notation.prompt")

                if viewModel.mode != .dictate {
                    StaffNoteView(note: viewModel.currentNote, clef: viewModel.clef)

                    Button {
                        onPlayPitch(viewModel.currentNote.soundingPitch)
                    } label: {
                        Label("Hear note", systemImage: "speaker.wave.2.fill")
                            .frame(maxWidth: .infinity, minHeight: 48)
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityIdentifier("notation.hear-note")
                }

                switch viewModel.mode {
                case .explore:
                    exploreContent
                case .read:
                    readContent
                case .dictate:
                    dictateContent
                }

                Text(viewModel.feedbackText)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))
                    .accessibilityIdentifier("notation.feedback")

                if viewModel.mode != .dictate {
                    Button("Next note") {
                        viewModel.nextNote()
                    }
                    .buttonStyle(.bordered)
                    .disabled(viewModel.mode == .read && !viewModel.isAnswered)
                    .accessibilityIdentifier("notation.next")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical)
        }
        .navigationTitle("Notation Trail")
    }

    @ViewBuilder
    private var exploreContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Written: \(viewModel.currentNote.displayName)")
                .accessibilityIdentifier("notation.written")

            Text("Enharmonics can sound alike: C# and Db name the same pitch class but occupy adjacent written positions.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .accessibilityIdentifier("notation.enharmonic")

            Text("Chord symbols")
                .font(.headline)

            ForEach(ChordSymbolExample.beginnerCatalog) { example in
                Text("\(example.symbol) — \(example.meaning)")
                    .accessibilityIdentifier("notation.chord.\(example.symbol)")
            }
        }
    }

    @ViewBuilder
    private var readContent: some View {
        LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
            spacing: 10
        ) {
            ForEach(NotationPromptCatalog.answerChoices) { spelling in
                Button(spelling.description) {
                    viewModel.chooseSpelling(spelling)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .disabled(viewModel.isAnswered)
                .accessibilityIdentifier("notation.answer.\(spelling.description)")
            }
        }
    }

    @ViewBuilder
    private var dictateContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                onPlayPhrase(viewModel.phrase.pitches)
            } label: {
                Label("Hear melody", systemImage: "speaker.wave.2.fill")
                    .frame(maxWidth: .infinity, minHeight: 48)
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier("notation.hear-melody")

            Text(viewModel.selectedText)
                .accessibilityIdentifier("notation.selected")

            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
                spacing: 10
            ) {
                ForEach(SolfegeDegree.allCases) { degree in
                    Button(degree.title) {
                        viewModel.addDegree(degree)
                    }
                    .buttonStyle(.bordered)
                    .disabled(
                        viewModel.selectedDegrees.count
                            == viewModel.phrase.degrees.count
                    )
                    .accessibilityIdentifier("notation.degree.\(degree.rawValue)")
                }
            }

            HStack {
                Button("Check melody") {
                    viewModel.checkDictation()
                }
                .disabled(viewModel.selectedDegrees.isEmpty)
                .accessibilityIdentifier("notation.check")

                Button("Undo") {
                    viewModel.removeLastDegree()
                }
                .disabled(viewModel.selectedDegrees.isEmpty)
                .accessibilityIdentifier("notation.undo")

                Button("Clear") {
                    viewModel.clearDegrees()
                }
                .accessibilityIdentifier("notation.clear")
            }
            .buttonStyle(.bordered)
        }
    }
}
