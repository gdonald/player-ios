
import SwiftUI

struct QueuedMp3ListItem: View {
    let theme: Theme
    let number: Int
    let queuedMp3: QueuedMp3
    let isCurrent: Bool

    var body: some View {
        let color = isCurrent ? theme.listCurrent : theme.listText

        HStack(spacing: 6) {
            Text("\(number). \(queuedMp3.mp3.artist_name) - \(queuedMp3.mp3.title)")
                .font(Theme.text(13, weight: isCurrent ? .bold : .regular, relativeTo: .body))
                .foregroundStyle(color)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(formatTime(queuedMp3.mp3.length))
                .font(Theme.text(13, relativeTo: .body))
                .foregroundStyle(color)

            Image(systemName: "xmark")
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(theme.displayDim)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 5)
    }
}
