
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            TabView {
                Mp3sView()
                    .badge(2223)
                    .tabItem {
                        Label("Mp3s", systemImage: "music.note")
                    }
                PlaylistsView()
                    .badge(8)
                    .tabItem {
                        Label("Playlists", systemImage: "music.note.list")
                    }
                QueueView()
                    .badge("!")
                    .tabItem {
                        Label("Queue", systemImage: "text.insert")
                    }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
