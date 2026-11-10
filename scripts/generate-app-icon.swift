import AppKit
import Foundation

// Reproducible 1024x1024 app icon, generated without external image tools.
// An upright white note rises above three ascending cyan-to-violet steps.
let size = 1024
let target = CommandLine.arguments.dropFirst().first ?? "AppIcon.png"
let image = NSImage(size: NSSize(width: size, height: size), flipped: false) { rect in
    let background = NSGradient(colors: [
        NSColor(calibratedRed: 0.06, green: 0.16, blue: 0.44, alpha: 1),
        NSColor(calibratedRed: 0.24, green: 0.09, blue: 0.55, alpha: 1)
    ])!
    background.draw(in: rect, angle: 0)

    // A quiet halo separates the mark without making it look like a button.
    NSColor.white.withAlphaComponent(0.08).setFill()
    NSBezierPath(ovalIn: CGRect(x: 236, y: 348, width: 560, height: 560)).fill()

    // Rounded steps progress upward in pitch and learning.
    let steps: [(CGRect, NSColor, NSColor)] = [
        (CGRect(x: 145, y: 190, width: 250, height: 135),
         NSColor(calibratedRed: 0.17, green: 0.83, blue: 0.96, alpha: 1),
         NSColor(calibratedRed: 0.19, green: 0.55, blue: 0.97, alpha: 1)),
        (CGRect(x: 340, y: 190, width: 260, height: 225),
         NSColor(calibratedRed: 0.27, green: 0.68, blue: 0.99, alpha: 1),
         NSColor(calibratedRed: 0.17, green: 0.33, blue: 0.90, alpha: 1)),
        (CGRect(x: 550, y: 190, width: 260, height: 310),
         NSColor(calibratedRed: 0.73, green: 0.39, blue: 1.00, alpha: 1),
         NSColor(calibratedRed: 0.37, green: 0.18, blue: 0.88, alpha: 1))
    ]
    for (frame, top, bottom) in steps {
        let shape = NSBezierPath(roundedRect: frame, xRadius: 30, yRadius: 30)
        NSGradient(starting: bottom, ending: top)!.draw(in: shape, angle: 90)
    }

    // A vertical stem and level head make the note unambiguous at home-screen size.
    NSColor.white.setFill()
    NSBezierPath(ovalIn: CGRect(x: 356, y: 486, width: 158, height: 112)).fill()

    NSColor.white.setStroke()
    let stem = NSBezierPath()
    stem.lineWidth = 34
    stem.lineCapStyle = .round
    stem.move(to: CGPoint(x: 500, y: 550))
    stem.line(to: CGPoint(x: 500, y: 774))
    stem.stroke()

    // The flag is a single gentle curve, not a skewed beam.
    let flag = NSBezierPath()
    flag.lineWidth = 30
    flag.lineCapStyle = .round
    flag.move(to: CGPoint(x: 500, y: 774))
    flag.curve(
        to: CGPoint(x: 664, y: 665),
        controlPoint1: CGPoint(x: 574, y: 792),
        controlPoint2: CGPoint(x: 662, y: 758)
    )
    flag.curve(
        to: CGPoint(x: 636, y: 616),
        controlPoint1: CGPoint(x: 684, y: 646),
        controlPoint2: CGPoint(x: 666, y: 626)
    )
    flag.stroke()
    return true
}
guard let bitmap = NSBitmapImageRep(
    bitmapDataPlanes: nil,
    pixelsWide: size,
    pixelsHigh: size,
    bitsPerSample: 8,
    samplesPerPixel: 4,
    hasAlpha: true,
    isPlanar: false,
    colorSpaceName: .deviceRGB,
    bytesPerRow: 0,
    bitsPerPixel: 0
) else { fatalError("Cannot initialize bitmap") }
guard let graphics = NSGraphicsContext(bitmapImageRep: bitmap) else {
    fatalError("Cannot initialize graphics")
}
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = graphics
image.draw(in: CGRect(x: 0, y: 0, width: size, height: size))
graphics.flushGraphics()
NSGraphicsContext.restoreGraphicsState()
guard let data = bitmap.representation(using: .png, properties: [:]) else {
    fatalError("Cannot encode PNG")
}
try FileManager.default.createDirectory(
    at: URL(fileURLWithPath: target).deletingLastPathComponent(),
    withIntermediateDirectories: true
)
try data.write(to: URL(fileURLWithPath: target), options: .atomic)
print("Generated ScaleClimbing app icon at \(target)")
