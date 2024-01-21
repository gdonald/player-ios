
import SwiftUI

struct PlaylistsView: View {
    let playlists: [Playlist]

    var body: some View {
        VStack {
            NavigationView {
                List(playlists) { playlist in
                    NavigationLink(destination: PlaylistView(playlist: playlist)) {
                        PlaylistListItem(playlist: playlist)
                    }
                }.padding(0)
            }.padding(0)
        }
    }
}
