
import SwiftUI

struct PlaylistsView: View {
    @ObservedObject var networkManager: NetworkManager
    @State private var searchText = ""

    var filteredItems: [Playlist] {
        if searchText.isEmpty {
            return networkManager.playlists
        } else {
            return networkManager.playlists.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                List(filteredItems) { playlist in
                    PlaylistListItem(playlist: playlist)
                        .listRowInsets(EdgeInsets())
                }
                .searchable(text: $searchText)
            }
        }
    }
}
