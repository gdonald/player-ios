
import SwiftUI

struct PlaylistListItem: View {
    var playlist: Playlist

    var body: some View {
        HStack(spacing: 0) {
            Text(playlist.name)
                .font(.system(size: 17))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(5).padding(.leading, 6)

            Spacer()

            Text(String(playlist.mp3s_count))
                .font(.system(size: 17))
                .frame(alignment: .trailing)
                .padding(5).padding(.trailing, 6)
        }.padding(5)
    }
}
