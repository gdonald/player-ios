
import SwiftUI

struct MainView: View {
    var body: some View {
        VStack {
            TabView {
                Mp3sView()
                    .badge(2223)
                    .tabItem {
                        Label("Mp3s", systemImage: "music.note")
                    }.padding(0)
                PlaylistsView()
                    .badge(8)
                    .tabItem {
                        Label("Playlists", systemImage: "music.note.list")
                    }.padding(0)
                QueueView()
                    .badge("!")
                    .tabItem {
                        Label("Queue", systemImage: "text.insert")
                    }.padding(0)
            }.padding(0)
        }
        .padding(0)
    }
}
