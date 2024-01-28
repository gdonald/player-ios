
import SwiftUI

struct PlaylistsView: View {
    @ObservedObject var networkManager: NetworkManager
    @State private var searchText = ""
    @State private var showMessage = false
    @State private var message = ""

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
            ZStack {
                VStack {
                    List(filteredItems) { playlist in
                        PlaylistListItem(playlist: playlist)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                            .listRowInsets(EdgeInsets())
                            .onTapGesture {
                                self.message = "\"\(playlist.name)\"\nadded to queue"
                                self.showMessage = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    self.showMessage = false
                                }
                                DispatchQueue.main.async {
                                    networkManager.createQueuedMp3sFromPlaylist(playlistId: String(playlist.id))
                                }
                            }
                    }
                    .searchable(text: $searchText)
                }

                if showMessage {
                    Text(message)
                        .padding(20)
                        .background(Color.black.opacity(0.85))
                        .foregroundColor(Color.white)
                        .cornerRadius(10)
                        .transition(.opacity)
                        .animation(.easeInOut, value: showMessage)
                        .zIndex(1)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
            }
        }
    }
}
