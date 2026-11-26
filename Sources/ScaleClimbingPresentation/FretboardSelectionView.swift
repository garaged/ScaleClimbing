import MusicTheoryCore
import SwiftUI

/// A reusable discrete-selection fretboard for scored practice (not a live touch instrument).
/// Coordinates and paging reuse M19; standard assistance hides visual answer labels.
public struct FretboardSelectionView: View {
    public let window: FretboardWindow
    public let showNames: Bool
    public let anchor: InstrumentPosition?
    public let selected: InstrumentPosition?
    public let result: Bool?
    public let locked: Bool
    public let selectedPositions: Set<InstrumentPosition>
    public let allowedStrings: Set<Int>
    public let identifierPrefix: String
    public let overlayLabels: [InstrumentPosition: String]
    public let shapePositions: Set<InstrumentPosition>
    public let onSelect: (InstrumentPosition) -> Void
    private let guitar = InstrumentMapping.standardGuitar

    public init(window: FretboardWindow, showNames: Bool, anchor: InstrumentPosition? = nil,
                selected: InstrumentPosition? = nil, result: Bool? = nil, locked: Bool = false,
                selectedPositions: Set<InstrumentPosition> = [], allowedStrings: Set<Int> = Set(1...6),
                identifierPrefix: String = "fretPractice", overlayLabels: [InstrumentPosition: String] = [:],
                shapePositions: Set<InstrumentPosition> = [], onSelect: @escaping (InstrumentPosition) -> Void) {
        self.window = window
        self.showNames = showNames
        self.anchor = anchor
        self.selected = selected
        self.result = result
        self.locked = locked
        self.selectedPositions = selectedPositions
        self.allowedStrings = allowedStrings
        self.identifierPrefix = identifierPrefix
        self.overlayLabels = overlayLabels
        self.shapePositions = shapePositions
        self.onSelect = onSelect
    }

    public var body: some View {
        VStack(spacing: 2) {
            HStack(spacing: 0) {
                Color.clear.frame(width: 30)
                ForEach(Array(window.frets), id: \.self) { fret in
                    Text("\(fret)").font(.caption.monospacedDigit()).frame(maxWidth: .infinity)
                }
            }.accessibilityHidden(true)
            VStack(spacing: 0) {
                ForEach(1...6, id: \.self) { string in
                    HStack(spacing: 0) {
                        Text(guitar.pitch(at: .fret(string: string, fret: 0))?.pitchClass.sharpName ?? "")
                            .font(.caption.weight(.semibold)).frame(width: 30)
                            .accessibilityHidden(true)
                        ForEach(Array(window.frets), id: \.self) { fret in
                            cell(string: string, fret: fret)
                        }
                    }
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("\(identifierPrefix).board")
    }

    private func cell(string: Int, fret: Int) -> some View {
        let position = InstrumentPosition.fret(string: string, fret: fret)
        let pitch = guitar.pitch(at: position)
        let isSelected = position == selected || selectedPositions.contains(position)
        let isAnchor = position == anchor
        let overlay = overlayLabels[position]
        let isShape = shapePositions.contains(position)
        return Button { onSelect(position) } label: {
            ZStack {
                Rectangle().fill(Color(red: 0.25, green: 0.17, blue: 0.12))
                Rectangle().fill(.white.opacity(0.65)).frame(height: CGFloat(string) * 0.3 + 0.6)
                HStack {
                    Spacer(minLength: 0)
                    Rectangle().fill(.white.opacity(0.6)).frame(width: fret == 0 ? 3 : 1)
                }
                if isSelected || isAnchor || showNames || overlay != nil || isShape {
                    Circle().fill(isSelected ? (result == nil ? ScaleClimbingPalette.sky : result == true ? Color.green.opacity(0.85) : Color.orange.opacity(0.9))
                        : isAnchor ? ScaleClimbingPalette.sky : overlay == "R" ? ScaleClimbingPalette.emerald : overlay != nil ? ScaleClimbingPalette.violet : Color.black.opacity(0.8))
                        .frame(width: 27, height: 27)
                        .overlay(Circle().strokeBorder(isShape ? Color.white : Color.clear, lineWidth: 2))
                    if showNames || isAnchor || isSelected || overlay != nil || isShape {
                        Text(isSelected ? pitch?.pitchClass.sharpName ?? "" : overlay ?? pitch?.pitchClass.sharpName ?? "").font(.caption2.bold()).foregroundStyle(.white)
                    }
                } else if [3,5,7,9,12,15,17,19,21,24].contains(fret) && string == 3 {
                    Circle().fill(.white.opacity(0.4)).frame(width: 5, height: 5)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain).disabled(locked || !allowedStrings.contains(string))
        .opacity(allowedStrings.contains(string) ? 1 : 0.5)
        .accessibilityLabel(String(format: AppCopy.text("String %d, fret %d, %@"), string, fret, pitch?.description ?? ""))
        .accessibilityAddTraits(isSelected || isAnchor ? [.isSelected] : [])
        .accessibilityIdentifier("\(identifierPrefix).position.\(string).\(fret)")
    }
}
