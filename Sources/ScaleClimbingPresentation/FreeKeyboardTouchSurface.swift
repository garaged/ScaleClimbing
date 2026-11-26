#if os(iOS)
import MusicTheoryCore
import SwiftUI
import UIKit

/// UIKit supplies simultaneous UITouch identities; SwiftUI Button gestures
/// alone cannot reliably provide piano-style polyphonic touch and glissandos.
struct FreeKeyboardTouchSurface: UIViewRepresentable {
    let model: PianoKeyboardModel
    let showNoteNames: Bool
    let onNoteEvent: (FreeKeyboardNoteEvent) -> Void
    let onAccessibleAudition: (Pitch) -> Void

    func makeUIView(context: Context) -> FreeKeyboardCanvasView {
        let view = FreeKeyboardCanvasView(frame: .zero)
        view.configure(
            model: model,
            showsNoteNames: showNoteNames,
            onNoteEvent: onNoteEvent,
            onAccessibleAudition: onAccessibleAudition
        )
        return view
    }

    func updateUIView(_ view: FreeKeyboardCanvasView, context: Context) {
        view.configure(
            model: model,
            showsNoteNames: showNoteNames,
            onNoteEvent: onNoteEvent,
            onAccessibleAudition: onAccessibleAudition
        )
    }
}

final class FreeKeyboardCanvasView: UIView {
    private final class AccessiblePianoKey: UIAccessibilityElement {
        var onActivate: (() -> Void)?

        override func accessibilityActivate() -> Bool {
            onActivate?()
            return true
        }
    }

    private var model = PianoKeyboardModel(keys: [])
    private var showsNoteNames = true
    private var tracker = FreeKeyboardTouchTracker()
    private var touchIdentifiers: [ObjectIdentifier: Int] = [:]
    private var nextTouchID = 1
    private var lastSize: CGSize = .zero
    private var onNoteEvent: (FreeKeyboardNoteEvent) -> Void = { _ in }
    private var onAccessibleAudition: (Pitch) -> Void = { _ in }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        isMultipleTouchEnabled = true
        isOpaque = false
        backgroundColor = .clear
        isAccessibilityElement = false
        accessibilityLabel = AppCopy.text("Free Keyboard")
    }

    func configure(
        model: PianoKeyboardModel,
        showsNoteNames: Bool,
        onNoteEvent: @escaping (FreeKeyboardNoteEvent) -> Void,
        onAccessibleAudition: @escaping (Pitch) -> Void
    ) {
        if self.model != model {
            releaseTouches()
            self.model = model
            setNeedsDisplay()
            rebuildAccessibilityElements()
        }
        if self.showsNoteNames != showsNoteNames {
            self.showsNoteNames = showsNoteNames
            setNeedsDisplay()
        }
        self.onNoteEvent = onNoteEvent
        self.onAccessibleAudition = onAccessibleAudition
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if bounds.size != lastSize {
            releaseTouches()
            lastSize = bounds.size
            rebuildAccessibilityElements()
            setNeedsDisplay()
        }
    }

    private var keyboardGeometry: FreeKeyboardGeometry {
        FreeKeyboardGeometry(
            model: model,
            width: Double(bounds.width),
            height: Double(bounds.height)
        )
    }

    private func key(at point: CGPoint) -> PianoKeyModel? {
        keyboardGeometry.key(atX: Double(point.x), y: Double(point.y))
    }

    private func emit(_ changes: [FreeKeyboardNoteEvent]) {
        for change in changes {
            onNoteEvent(change)
        }
        if !changes.isEmpty {
            setNeedsDisplay()
        }
    }

    private func advanceTouches(_ touches: Set<UITouch>, ending: Bool) {
        for touch in touches {
            let identity = ObjectIdentifier(touch)
            let id: Int
            if let existing = touchIdentifiers[identity] {
                id = existing
            } else {
                guard !ending else { continue }
                id = nextTouchID
                nextTouchID += 1
                touchIdentifiers[identity] = id
            }
            let pitch = ending ? nil : key(at: touch.location(in: self))?.pitch
            emit(tracker.update(touch: id, pitch: pitch))
            if ending {
                touchIdentifiers.removeValue(forKey: identity)
            }
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        advanceTouches(touches, ending: false)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        advanceTouches(touches, ending: false)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        advanceTouches(touches, ending: true)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        advanceTouches(touches, ending: true)
    }

    private func releaseTouches() {
        emit(tracker.releaseAll())
        touchIdentifiers.removeAll()
    }

    private func rebuildAccessibilityElements() {
        let geometry = keyboardGeometry
        accessibilityElements = model.keys.compactMap { key -> UIAccessibilityElement? in
            guard let local = geometry.rect(for: key) else { return nil }
            let element = AccessiblePianoKey(accessibilityContainer: self)
            element.accessibilityTraits = .button
            element.accessibilityLabel = key.accessibilityLabel
            element.accessibilityHint = AppCopy.text("Hear this note")
            element.accessibilityFrameInContainerSpace = CGRect(
                x: local.x, y: local.y, width: local.width, height: local.height
            )
            element.onActivate = { [weak self] in
                self?.onAccessibleAudition(key.pitch)
            }
            return element
        }
    }

    override func draw(_ rect: CGRect) {
        let geometry = keyboardGeometry
        guard geometry.width > 0, geometry.height > 0,
              let context = UIGraphicsGetCurrentContext() else { return }

        for (index, key) in geometry.layout.naturalKeys.enumerated() {
            render(
                key: key,
                rectangle: geometry.naturalRect(at: index),
                context: context
            )
        }
        for placement in geometry.layout.accidentals {
            render(
                key: placement.key,
                rectangle: geometry.accidentalRect(for: placement),
                context: context
            )
        }
    }

    private func render(
        key: PianoKeyModel,
        rectangle: FreeKeyboardRect,
        context: CGContext
    ) {
        let keyRect = CGRect(
            x: rectangle.x, y: rectangle.y,
            width: rectangle.width, height: rectangle.height
        ).insetBy(dx: 0.5, dy: 1)
        let radius: CGFloat = key.isNatural ? 7 : 5
        let shape = UIBezierPath(roundedRect: keyRect, cornerRadius: radius)
        let top = key.isNatural ? PianoKeyPalette.naturalTop : PianoKeyPalette.accidentalTop
        let bottom = key.isNatural ? PianoKeyPalette.naturalBottom : PianoKeyPalette.accidentalBottom

        context.saveGState()
        shape.addClip()
        let colors: [CGColor] = [
            UIColor(red: top.red, green: top.green, blue: top.blue, alpha: 1).cgColor,
            UIColor(red: bottom.red, green: bottom.green, blue: bottom.blue, alpha: 1).cgColor
        ]
        if let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: colors as CFArray,
            locations: [0, 1]
        ) {
            context.drawLinearGradient(
                gradient,
                start: CGPoint(x: keyRect.midX, y: keyRect.minY),
                end: CGPoint(x: keyRect.midX, y: keyRect.maxY),
                options: []
            )
        }
        context.restoreGState()

        let held = tracker.heldPitches.contains(key.pitch)
        let outline: UIColor = held ? .systemTeal : (key.isNatural
            ? UIColor.black.withAlphaComponent(0.2)
            : UIColor.white.withAlphaComponent(0.23))
        outline.setStroke()
        shape.lineWidth = held ? 3 : 1
        shape.stroke()

        guard showsNoteNames else { return }
        let font = UIFont.systemFont(ofSize: min(14, keyRect.width * 0.28), weight: .semibold)
        let ink = key.isNatural ? PianoKeyPalette.naturalInk : PianoKeyPalette.accidentalInk
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor(red: ink.red, green: ink.green, blue: ink.blue, alpha: 1)
        ]
        let label = key.shortLabel as NSString
        let measured = label.size(withAttributes: attributes)
        label.draw(
            in: CGRect(
                x: keyRect.midX - measured.width / 2,
                y: keyRect.maxY - measured.height - 12,
                width: measured.width + 1,
                height: measured.height + 1
            ),
            withAttributes: attributes
        )
    }
}
#endif
