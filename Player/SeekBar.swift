
import SwiftUI

struct SeekBar: View {
    let theme: Theme
    let value: Double
    let upperBound: Double
    let onSeek: (Double) -> Void

    @State private var draggedValue: Double?

    private let thumbWidth: CGFloat = 28
    private let height: CGFloat = 14

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let travel = max(width - thumbWidth, 0)
            let thumbX = travel * fraction
            let shape = RoundedRectangle(cornerRadius: theme.panelRadius)

            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(theme.seekEmpty)

                Rectangle()
                    .fill(theme.seekFilled)
                    .frame(width: thumbX + thumbWidth / 2)

                shape
                    .fill(
                        LinearGradient(
                            colors: [theme.thumbTop, theme.thumbBottom],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(shape.stroke(theme.thumbEdge, lineWidth: 1))
                    .frame(width: thumbWidth, height: height - 2)
                    .offset(x: thumbX, y: 1)
            }
            .clipShape(shape)
            .overlay(BevelBorder(light: theme.bevelLight, dark: theme.bevelDark, raised: false))
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        draggedValue = seconds(at: gesture.location.x, travel: travel)
                    }
                    .onEnded { gesture in
                        let target = seconds(at: gesture.location.x, travel: travel)
                        draggedValue = nil
                        onSeek(target)
                    }
            )
        }
        .frame(height: height)
    }

    private var fraction: CGFloat {
        guard upperBound > 0 else { return 0 }

        let shown = draggedValue ?? value
        return CGFloat(min(max(shown / upperBound, 0), 1))
    }

    private func seconds(at locationX: CGFloat, travel: CGFloat) -> Double {
        guard travel > 0 else { return 0 }

        let position = min(max((locationX - thumbWidth / 2) / travel, 0), 1)
        return Double(position) * upperBound
    }
}
