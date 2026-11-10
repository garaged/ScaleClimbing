import MusicTheoryCore
import SwiftUI

struct StaffNoteView: View {
    let note: WrittenNote
    let clef: StaffClef

    var body: some View {
        Canvas { context, size in
            let horizontalInset = 26.0
            let lineSpacing = size.height / 8.0
            let bottomLineY = size.height - (lineSpacing * 1.5)
            let noteY = bottomLineY - (Double(note.staffStep(in: clef)) * lineSpacing / 2.0)
            let noteX = size.width * 0.58

            for line in 0..<5 {
                let y = bottomLineY - (Double(line) * lineSpacing)
                var path = Path()
                path.move(to: CGPoint(x: horizontalInset, y: y))
                path.addLine(to: CGPoint(x: size.width - horizontalInset, y: y))
                context.stroke(path, with: .color(.primary), lineWidth: 1)
            }

            for step in note.ledgerLineSteps(in: clef) {
                let y = bottomLineY - (Double(step) * lineSpacing / 2.0)
                var path = Path()
                path.move(to: CGPoint(x: noteX - 20, y: y))
                path.addLine(to: CGPoint(x: noteX + 20, y: y))
                context.stroke(path, with: .color(.primary), lineWidth: 1)
            }

            let noteRect = CGRect(
                x: noteX - 10,
                y: noteY - 7,
                width: 20,
                height: 14
            )
            context.fill(Path(ellipseIn: noteRect), with: .color(.primary))

            if note.spelling.accidental != .natural {
                context.draw(
                    Text(note.spelling.accidental.symbol)
                        .font(.title2.weight(.semibold)),
                    at: CGPoint(x: noteX - 28, y: noteY)
                )
            }
        }
        .frame(height: 150)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(note.accessibilityPositionDescription(in: clef))
        .accessibilityIdentifier("notation.staff")
    }
}
