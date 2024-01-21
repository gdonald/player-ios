
import SwiftUI

struct QueuedMp3sView: View {
    @StateObject private var playerManager = AudioPlayerManager()
    @ObservedObject var networkManager: NetworkManager

    var body: some View {
        VStack {
            List(networkManager.queuedMp3s) { queuedMp3 in
                QueuedMp3ListItem(queuedMp3: queuedMp3)
                    .listRowInsets(EdgeInsets())
            }
            .listStyle(PlainListStyle())
            .onAppear {
                if !self.playerManager.isPlaying {
                    self.playerManager.newMp3(mp3: networkManager.currentMp3?.mp3)
                }
            }
            if networkManager.currentMp3 != nil {
                VStack {
                    Text(self.playerManager.isPlaying ? "Playing" : "Paused")
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
        .padding(0)
    }
}
