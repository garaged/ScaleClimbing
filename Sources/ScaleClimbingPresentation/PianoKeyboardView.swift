import MusicTheoryCore
import SwiftUI

/// Shared piano keyboard, with accidentals raised above the boundaries of natural keys.
/// All practice routes use the same appearance, geometry, and learning-assistance policy.
public struct PianoKeyboardView: View {
    @AppStorage("learningAssistanceLevel") private var assistanceRaw = LearningAssistanceLevel.standard.rawValue

    public let model: PianoKeyboardModel
    public let purpose: PianoKeyboardPurpose
    public let highlightedPitchClasses: Set<PitchClass>
    public let highlightedPitches: Set<Pitch>
    public let onKeyTap: (PianoKeyModel) -> Void

    public init(
        model: PianoKeyboardModel,
        highlightedPitchClass: PitchClass? = nil,
        purpose: PianoKeyboardPurpose = .construction,
        onKeyTap: @escaping (PianoKeyModel) -> Void
    ) {
        self.model = model
        self.purpose = purpose
        self.highlightedPitchClasses = highlightedPitchClass.map { [$0] } ?? []
        self.highlightedPitches = []
        self.onKeyTap = onKeyTap
    }

    public init(
        model: PianoKeyboardModel,
        highlightedPitchClasses: Set<PitchClass>,
        purpose: PianoKeyboardPurpose = .construction,
        onKeyTap: @escaping (PianoKeyModel) -> Void
    ) {
        self.model = model
        self.purpose = purpose
        self.highlightedPitchClasses = highlightedPitchClasses
        self.highlightedPitches = []
        self.onKeyTap = onKeyTap
    }

    public init(
        model: PianoKeyboardModel,
        highlightedPitches: Set<Pitch>,
        purpose: PianoKeyboardPurpose = .construction,
        onKeyTap: @escaping (PianoKeyModel) -> Void
    ) {
        self.model = model
        self.purpose = purpose
        self.highlightedPitchClasses = []
        self.highlightedPitches = highlightedPitches
        self.onKeyTap = onKeyTap
    }

    private var layout: PianoKeyboardLayout { PianoKeyboardLayout(model: model) }

    private var showsNoteNames: Bool {
        PianoKeyboardLabelPolicy.showsNames(
            for: purpose,
            assistance: LearningAssistanceLevel(rawValue: assistanceRaw) ?? .standard
        )
    }

    public var body: some View {
        ScrollView(.horizontal) {
            ZStack(alignment: .topLeading) {
                HStack(alignment: .top, spacing: 0) {
                    ForEach(layout.naturalKeys) { key in
                        keyButton(for: key)
                    }
                }

                ForEach(layout.accidentals, id: \.key.id) { placement in
                    keyButton(for: placement.key)
                        .offset(
                            x: CGFloat(placement.precedingNaturalIndex + 1) * PianoKeyButton.naturalWidth
                                - PianoKeyButton.accidentalHitWidth / 2
                        )
                        .zIndex(1)
                }
            }
            .frame(
                width: CGFloat(layout.naturalKeys.count) * PianoKeyButton.naturalWidth,
                height: PianoKeyButton.naturalHeight,
                alignment: .topLeading
            )
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .scrollIndicators(.hidden)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(AppCopy.text("Piano keyboard"))
    }

    private func keyButton(for key: PianoKeyModel) -> some View {
        PianoKeyButton(
            key: key,
            isHighlighted: highlightedPitchClasses.contains(key.pitchClass)
                || highlightedPitches.contains(key.pitch),
            showsNoteName: showsNoteNames,
            onTap: { onKeyTap(key) }
        )
    }
}

public struct PianoKeyButton: View {
    public static let naturalWidth: CGFloat = 52
    public static let naturalHeight: CGFloat = 180
    public static let accidentalHitWidth: CGFloat = 44

    public let key: PianoKeyModel
    public let isHighlighted: Bool
    public let showsNoteName: Bool
    public let onTap: () -> Void

    public init(
        key: PianoKeyModel,
        isHighlighted: Bool = false,
        showsNoteName: Bool = true,
        onTap: @escaping () -> Void
    ) {
        self.key = key
        self.isHighlighted = isHighlighted
        self.showsNoteName = showsNoteName
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: onTap) {
            keyFace
                .frame(
                    width: key.isNatural ? Self.naturalWidth : Self.accidentalHitWidth,
                    height: key.isNatural ? Self.naturalHeight : 114,
                    alignment: .top
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(key.accessibilityLabel)
        .accessibilityHint(AppCopy.text("Tap to choose a key"))
        .accessibilityAddTraits(isHighlighted ? [.isSelected] : [])
    }

    private var keyFace: some View {
        VStack {
            Spacer(minLength: 0)
            if showsNoteName {
                Text(key.shortLabel)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(
                        key.isNatural
                            ? Color(red: 0.13, green: 0.16, blue: 0.22)
                            : Color(red: 0.97, green: 0.98, blue: 1.00)
                    )
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
                    .accessibilityHidden(true)
            }
        }
        .padding(.bottom, key.isNatural ? 12 : 9)
        .frame(width: key.isNatural ? Self.naturalWidth : 36, height: key.isNatural ? Self.naturalHeight : 108)
        .background(
            LinearGradient(
                colors: key.isNatural
                    ? [Color(red: 1.0, green: 1.0, blue: 0.99),
                       Color(red: 0.89, green: 0.91, blue: 0.94)]
                    : [Color(red: 0.25, green: 0.28, blue: 0.34),
                       Color(red: 0.06, green: 0.08, blue: 0.12)],
                startPoint: .top,
                endPoint: .bottom
            ),
            in: UnevenRoundedRectangle(
                topLeadingRadius: 3,
                bottomLeadingRadius: key.isNatural ? 7 : 5,
                bottomTrailingRadius: key.isNatural ? 7 : 5,
                topTrailingRadius: 3
            )
        )
        .overlay {
            RoundedRectangle(cornerRadius: key.isNatural ? 6 : 4)
                .strokeBorder(
                    isHighlighted ? ScaleClimbingPalette.sky
                        : (key.isNatural ? Color.black.opacity(0.22) : Color.white.opacity(0.17)),
                    lineWidth: isHighlighted ? 3 : 1
                )
        }
        .shadow(color: .black.opacity(key.isNatural ? 0.12 : 0.36), radius: key.isNatural ? 2 : 3, y: 3)
    }
}
