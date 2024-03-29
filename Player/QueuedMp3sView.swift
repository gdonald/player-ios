
import SwiftUI

struct QueuedMp3sView: View {
    @EnvironmentObject var userAuth: UserAuth
    @StateObject private var audioPlayer = AudioPlayer()
    @ObservedObject var networkManager: NetworkManager
    @State private var searchText: String = UserDefaults.standard.string(forKey: "savedQueuedMp3sSearchText") ?? ""
    @State private var justStarted: Bool = true
    @State private var showMessage = false
    @State private var message = ""

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

    func playNextQueuedMp3IfAvailable() {
        if justStarted && !networkManager.queuedMp3s.isEmpty && !audioPlayer.isPlaying {
            if let mp3 = networkManager.queuedMp3s.first?.mp3 {
                audioPlayer.newMp3(mp3: mp3)
            }
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    List(filteredItems) { queuedMp3 in
                        QueuedMp3ListItem(
                            queuedMp3: queuedMp3,
                            currentMp3: networkManager.currentMp3 ?? nil
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .listRowInsets(EdgeInsets())
                        .onTapGesture {
                            self.message = "\"\(queuedMp3.mp3.title)\"\n removed from queue"
                            self.showMessage = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                self.showMessage = false
                            }
                            DispatchQueue.main.async {
                                networkManager.deleteQueuedMp3(queuedMp3Id: String(queuedMp3.id))
                            }
                        }
                    }
                    .searchable(text: $searchText)
                    .onChange(of: searchText) { _, newValue in
                        UserDefaults.standard.set(newValue, forKey: "savedQueuedMp3sSearchText")
                    }
                    .refreshable {
                        networkManager.fetchQueuedMp3s()
                    }
                    .onAppear {
                        if userAuth.isAuthenticated {
                            if !self.audioPlayer.isPlaying {
                                if let mp3 = networkManager.currentMp3?.mp3 {
                                    self.audioPlayer.newMp3(mp3: mp3)
                                }
                            }

                            justStarted = false
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
                        self.playNextQueuedMp3IfAvailable()
                    }
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
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
            }
        }
    }
}
