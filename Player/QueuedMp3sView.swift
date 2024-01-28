
import SwiftUI

struct QueuedMp3sView: View {
    @StateObject private var audioPlayer = AudioPlayer()
    @ObservedObject var networkManager: NetworkManager
    @State private var searchText: String = UserDefaults.standard.string(forKey: "savedQueuedMp3sSearchText") ?? ""

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
                .onChange(of: searchText) { _, newValue in
                    UserDefaults.standard.set(newValue, forKey: "savedQueuedMp3sSearchText")
                }
                .refreshable {
                    networkManager.fetchQueuedMp3s()
                }
                .onAppear {
                    if !self.audioPlayer.isPlaying {
                        if let mp3 = networkManager.currentMp3?.mp3 {
                            self.audioPlayer.newMp3(mp3: mp3)
                        }
                    }

                    if networkManager.needToFetchQueuedMp3s {
                        networkManager.needToFetchQueuedMp3s = false
                        networkManager.fetchQueuedMp3s()
                    }
                }

                VStack {
                    Button(action: {
                        if networkManager.currentMp3 != nil {
                            self.audioPlayer.playPause()
                        }
                    }) {
                        Image(systemName: self.audioPlayer.isPlaying ? "pause.circle" : "play.circle")
                            .resizable()
                            .frame(width: 50, height: 50)
                    }
                    Slider(
                        value: Binding(
                            get: { self.audioPlayer.currentTime },
                            set: { newTime in self.audioPlayer.seek(to: newTime) }
                        ),
                        in: 0 ... Double(networkManager.currentMp3?.mp3.length ?? 0)
                    )
                    Text("\(formatTime(Int(self.audioPlayer.currentTime))) / \(formatTime(networkManager.currentMp3?.mp3.length ?? 0))")
                }
                .padding(.horizontal, 30).padding(.vertical, 10)
                .onChange(of: networkManager.currentMp3) {
                    if let mp3 = networkManager.currentMp3?.mp3 {
                        self.audioPlayer.newMp3(mp3: mp3)
                    }
                }
                .onChange(of: audioPlayer.ended) {
                    if audioPlayer.ended {
                        self.networkManager.nextQueuedMp3()
                    }
                }
                .onChange(of: networkManager.queuedMp3s) {
                    if !networkManager.queuedMp3s.isEmpty {
                        if !self.audioPlayer.isPlaying {
                            if let mp3 = networkManager.queuedMp3s.first?.mp3 {
                                self.audioPlayer.newMp3(mp3: mp3)
                                self.audioPlayer.playPause()
                            }
                        }
                    }
                }
            }
        }
    }
}
