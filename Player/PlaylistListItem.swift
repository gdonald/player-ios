
import SwiftUI

struct PlaylistListItem: View {
    let theme: Theme
    let playlist: Playlist

    var body: some View {
        HStack(spacing: 0) {
            Text(playlist.name)
                .font(Theme.text(13, relativeTo: .body))
                .foregroundStyle(theme.listText)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(String(playlist.mp3s_count))
                .font(Theme.digits(13, relativeTo: .body))
                .foregroundStyle(theme.listText)
                .frame(width: 60, alignment: .leading)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 6)
        .listRowLine(theme)
    }
}
