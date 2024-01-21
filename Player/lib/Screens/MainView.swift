
import SwiftUI

struct MainView: View {
    @ObservedObject var networkManager = NetworkManager()

    var body: some View {
        VStack {
            TabView {
                Mp3sView(networkManager: networkManager)
                    .badge(networkManager.mp3s.count)
                    .tabItem {
                        Label("Mp3s", systemImage: "music.note")
                    }
                    .padding(0)

                PlaylistsView(networkManager: networkManager)
                    .badge(networkManager.playlists.count)
                    .tabItem {
                        Label("Playlists", systemImage: "music.note.list")
                    }
                    .padding(0)

                QueuedMp3sView(networkManager: networkManager)
                    .badge(networkManager.queuedMp3s.count)
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
