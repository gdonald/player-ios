
import SwiftUI

struct QueuedMp3sView: View {
    @StateObject private var playerManager = AudioPlayerManager()
    @ObservedObject var networkManager: NetworkManager
    @State private var searchText = ""

    var filteredItems: [QueuedMp3] {
        if searchText.isEmpty {
            return networkManager.queuedMp3s.sorted { $0.position < $1.position }
        } else {
            return networkManager.queuedMp3s.filter {
                $0.mp3.title.localizedCaseInsensitiveContains(searchText)
                    ||
                    $0.mp3.artist_name.localizedCaseInsensitiveContains(searchText)
            }.sorted { $0.position < $1.position }
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                List(filteredItems) { queuedMp3 in
                    QueuedMp3ListItem(
                        queuedMp3: queuedMp3,
                        currentMp3: networkManager.currentMp3 ?? nil
                    )
                    .listRowInsets(EdgeInsets())
                }
                .searchable(text: $searchText)
                .onAppear {
                    if !self.playerManager.isPlaying {
                        self.playerManager.newMp3(mp3: networkManager.currentMp3?.mp3)
                    }
                }

                if networkManager.currentMp3 != nil {
                    VStack {
                        Button(action: {
                            self.playerManager.playPause()
                        }) {
                            Image(systemName: self.playerManager.isPlaying ? "pause.circle" : "play.circle")
                                .resizable()
                                .frame(width: 50, height: 50)
                        }
                        Slider(
                            value: Binding(
                                get: { self.playerManager.currentTime },
                                set: { newTime in self.playerManager.seek(to: newTime) }
                            ),
                            in: 0 ... Double(networkManager.currentMp3?.mp3.length ?? 0)
                        )
                        Text("\(formatTime(Int(self.playerManager.currentTime))) / \(formatTime(networkManager.currentMp3?.mp3.length ?? 0))")
                    }
                    .padding(.horizontal, 30).padding(.vertical, 10)
                    .onChange(of: playerManager.ended) {
                        if playerManager.ended {
                            self.networkManager.nextQueuedMp3()
                        }
                    }
                    .onChange(of: networkManager.queuedMp3s) {
                        if !networkManager.queuedMp3s.isEmpty {
                            if !self.playerManager.isPlaying {
                                self.playerManager.newMp3(mp3: networkManager.currentMp3?.mp3)
                                self.playerManager.playPause()
                            }
                        }
                    }
                }
            }
        }
    }
}
