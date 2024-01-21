
import SwiftUI

struct MainView: View {
    @ObservedObject var networkManager = NetworkManager()

    var body: some View {
        VStack {
            TabView {
                Mp3sView(mp3s: networkManager.mp3s)
                    .badge(networkManager.mainCounts.mp3s_count)
                    .tabItem {
                        Label("Mp3s", systemImage: "music.note")
                    }
                    .padding(0)

                PlaylistsView(playlists: networkManager.playlists)
                    .badge(networkManager.mainCounts.playlists_count)
                    .tabItem {
                        Label("Playlists", systemImage: "music.note.list")
                    }
                    .padding(0)

                QueuedMp3sView(queuedMp3s: networkManager.queuedMp3s)
                    .badge(networkManager.mainCounts.queued_mp3s_count)
                    .tabItem {
                        Label("Queue", systemImage: "text.insert")
                    }
                    .padding(0)
            }
            .padding(0)
        }
        .padding(0)
        .task {
            self.networkManager.fetch()
        }
    }
}

#Preview {
    MainView()
}
