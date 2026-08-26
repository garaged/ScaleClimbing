import MusicTheoryCore
import SwiftUI

public struct PianoKeyboardView: View {
    public let model: PianoKeyboardModel
    public let highlightedPitchClasses: Set<PitchClass>
    public let onKeyTap: (PianoKeyModel) -> Void

    public init(
        model: PianoKeyboardModel,
        highlightedPitchClass: PitchClass? = nil,
        onKeyTap: @escaping (PianoKeyModel) -> Void
    ) {
        self.model = model
        self.highlightedPitchClasses = highlightedPitchClass.map { [$0] } ?? []
        self.onKeyTap = onKeyTap
    }

    public init(
        model: PianoKeyboardModel,
        highlightedPitchClasses: Set<PitchClass>,
        onKeyTap: @escaping (PianoKeyModel) -> Void
    ) {
        self.model = model
        self.highlightedPitchClasses = highlightedPitchClasses
        self.onKeyTap = onKeyTap
    }

    public var body: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .top, spacing: 4) {
                ForEach(model.keys) { key in
                    PianoKeyButton(
                        key: key,
                        isHighlighted: highlightedPitchClasses.contains(key.pitchClass),
                        onTap: { onKeyTap(key) }
                    )
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Piano keyboard")
    }
}

public struct PianoKeyButton: View {
    public let key: PianoKeyModel
    public let isHighlighted: Bool
    public let onTap: () -> Void

    public init(key: PianoKeyModel, isHighlighted: Bool = false, onTap: @escaping () -> Void) {
        self.key = key
        self.isHighlighted = isHighlighted
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: onTap) {
            keyFace
        }
        .buttonStyle(.plain)
        .accessibilityLabel(key.accessibilityLabel)
        .accessibilityHint(accessibilityHint)
        .accessibilityAddTraits(accessibilityTraits)
    }

    private var keyFace: some View {
        VStack(spacing: 8) {
            keyLabel
            Spacer(minLength: 0)
        }
        .frame(width: keyWidth, height: keyHeight)
        .background(keyBackground)
        .overlay(selectionOverlay)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var keyLabel: some View {
        Text(key.shortLabel)
            .font(.caption.weight(.semibold))
            .foregroundStyle(key.isNatural ? Color.primary : Color.white)
    }

    private var keyBackground: Color {
        key.isNatural ? Color.white : Color.black
    }

    private var selectionOverlay: some View {
        RoundedRectangle(cornerRadius: 10)
            .strokeBorder(selectionColor, lineWidth: selectionLineWidth)
    }

    private var selectionColor: Color {
        isHighlighted ? Color.accentColor : Color.secondary.opacity(0.35)
    }

    private var selectionLineWidth: CGFloat {
        isHighlighted ? 3 : 1
    }

    private var keyWidth: CGFloat {
        key.isNatural ? 48 : 36
    }

    private var keyHeight: CGFloat {
        key.isNatural ? 160 : 108
    }

    private var accessibilityHint: String {
        "Tap to answer \(key.pitchClass.accessibilityName)"
    }

    private var accessibilityTraits: AccessibilityTraits {
        isHighlighted ? [.isSelected] : []
    }
}
