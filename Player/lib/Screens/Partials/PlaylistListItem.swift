
import SwiftUI

struct PlaylistListItem: View {
    var playlist: Playlist

    var body: some View {
        VStack(spacing: 0) {
            Text(playlist.name)
                .font(.system(size: 15))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .padding(2)
            Text(String(playlist.mp3s_count))
                .font(.system(size: 11))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .padding(3)
        }.padding(5)
    }
}
