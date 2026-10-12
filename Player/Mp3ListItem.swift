
import SwiftUI

struct Mp3ListItem: View {
    let theme: Theme
    let mp3: Mp3

    var body: some View {
        HStack(spacing: 0) {
            Text(mp3.title)
                .font(Theme.text(13, relativeTo: .body))
                .foregroundStyle(theme.listText)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(mp3.artist_name)
                .font(Theme.text(13, relativeTo: .body))
                .foregroundStyle(theme.listText)
                .lineLimit(1)
                .frame(width: 130, alignment: .leading)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 6)
        .listRowLine(theme)
    }
}
