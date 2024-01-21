
import SwiftUI

struct PlaylistsView: View {
    let playlists: [Playlist]

    var body: some View {
        NavigationView {
            List(playlists) { playlist in
                NavigationLink(destination: PlaylistView(playlist: playlist)) {
                    PlaylistListItem(playlist: playlist)
                }
                .listRowInsets(EdgeInsets())
            }
            .listStyle(PlainListStyle())
        }
        .padding(0)
    }
}
