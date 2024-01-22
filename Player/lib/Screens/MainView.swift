
import SwiftUI

struct MainView: View {
    @ObservedObject var networkManager = NetworkManager()

    init() {
        UITabBarItem.appearance().badgeColor = UIColor.blue
    }

    var body: some View {
        VStack {
            TabView {
                Mp3sView(networkManager: networkManager)
                    .badge(networkManager.mp3s.count)
                    .tabItem {
                        Label("Mp3s", systemImage: "music.note")
                    }

                PlaylistsView(networkManager: networkManager)
                    .badge(networkManager.playlists.count)
                    .tabItem {
                        Label("Playlists", systemImage: "music.note.list")
                    }

                QueuedMp3sView(networkManager: networkManager)
                    .badge(networkManager.queuedMp3s.count)
                    .tabItem {
                        Label("Queue", systemImage: "text.insert")
                    }
            }
        }
        .accentColor(.white)
        .task {
            self.networkManager.fetch()
        }
    }
}

#Preview {
    MainView()
}
