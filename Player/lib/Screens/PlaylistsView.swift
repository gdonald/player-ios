
import SwiftUI

struct PlaylistsView: View {
    @ObservedObject var networkManager: NetworkManager

    var body: some View {
        NavigationView {
            List(networkManager.playlists) { playlist in
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
