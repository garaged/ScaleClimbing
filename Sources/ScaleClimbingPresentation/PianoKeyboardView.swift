import MusicTheoryCore
import SwiftUI

public struct PianoKeyboardView: View {
    public let model: PianoKeyboardModel
    public let highlightedPitchClass: PitchClass?
    public let onKeyTap: (PianoKeyModel) -> Void

    public init(
        model: PianoKeyboardModel,
        highlightedPitchClass: PitchClass? = nil,
        onKeyTap: @escaping (PianoKeyModel) -> Void
    ) {
        self.model = model
        self.highlightedPitchClass = highlightedPitchClass
        self.onKeyTap = onKeyTap
    }

    public var body: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .top, spacing: 4) {
                ForEach(model.keys) { key in
                    PianoKeyButton(
                        key: key,
                        isHighlighted: highlightedPitchClass == key.pitchClass,
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
            VStack(spacing: 8) {
                Text(key.shortLabel)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(key.isNatural ? .primary : .white)
                Spacer(minLength: 0)
            }
            .frame(width: key.isNatural ? 48 : 36, height: key.isNatural ? 160 : 108)
            .background(key.isNatural ? Color.white : Color.black)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(isHighlighted ? Color.accentColor : Color.secondary.opacity(0.35), lineWidth: isHighlighted ? 3 : 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(key.accessibilityLabel)
        .accessibilityHint("Tap to answer \(key.pitchClass.accessibilityName)")
        .accessibilityAddTraits(isHighlighted ? [.isSelected] : [])
    }
}
