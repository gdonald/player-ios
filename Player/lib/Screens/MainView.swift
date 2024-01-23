
import SwiftUI

struct MainView: View {
    @EnvironmentObject var userAuth: UserAuth
    @ObservedObject var networkManager = NetworkManager()
    @State private var selectedTab = 1

    init() {
        UITabBarItem.appearance().badgeColor = UIColor.blue
    }

    var body: some View {
        Group {
            if self.userAuth.isAuthenticated {
                VStack {
                    TabView(selection: $selectedTab) {
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

                        LogoutView()
                            .tabItem {
                                Label("Logout", systemImage: "arrow.right.square")
                            }

                    }.onAppear {
                        selectedTab = 0
                    }
                }
                .accentColor(.white)
                .task {
                    self.networkManager.fetch()
                }
            } else {
                LoginView()
            }
        }
    }
}

#Preview {
    MainView()
}
