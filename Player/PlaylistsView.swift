
import SwiftUI

struct PlaylistsView: View {
    @EnvironmentObject var themeStore: ThemeStore
    @ObservedObject var networkManager: NetworkManager
    @State private var searchText: String = UserDefaults.standard.string(forKey: "savedPlaylistsSearchText") ?? ""
    @State private var message: String?

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
        let theme = themeStore.theme

        WinampWindow(theme: theme, title: "Playlists") {
            VStack(spacing: 4) {
                LCDField(theme: theme, prompt: "Search", text: $searchText)

                VStack(spacing: 0) {
                    ColumnHeaders(theme: theme, columns: [("Name", nil), ("Mp3s", 60)])

                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(filteredItems) { playlist in
                                PlaylistListItem(theme: theme, playlist: playlist)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        enqueue(playlist)
                                    }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .lcdPanel(theme, background: theme.listBackground)
            }
        }
        .frame(maxHeight: .infinity)
        .onChange(of: searchText) { _, newValue in
            UserDefaults.standard.set(newValue, forKey: "savedPlaylistsSearchText")
        }
        .overlay(Toast(theme: theme, message: message))
        .animation(.easeInOut, value: message)
    }

    private func enqueue(_ playlist: Playlist) {
        flash("\"\(playlist.name)\"\nadded to queue")
        networkManager.createQueuedMp3sFromPlaylist(playlistId: String(playlist.id))
    }

    private func flash(_ text: String) {
        message = text
        Task {
            try? await Task.sleep(for: .seconds(2))
            message = nil
        }
    }
}
