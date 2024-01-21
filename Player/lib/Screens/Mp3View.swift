
import SwiftUI

struct Mp3View: View {
    let mp3: Mp3

    @StateObject private var playerManager: AudioPlayerManager

    init(mp3: Mp3) {
        self.mp3 = mp3
        _playerManager = StateObject(wrappedValue: AudioPlayerManager(mp3: mp3))
    }

    func formatTime(_ length: Int) -> String {
        return String(format: "%02d:%02d", length / 60, length % 60)
    }

    var body: some View {
        VStack {
            Text(self.playerManager.isPlaying ? "Playing" : "Paused")
            Button(action: {
                self.playerManager.playPause()
            }) {
                Image(systemName: self.playerManager.isPlaying ? "pause.circle" : "play.circle")
                    .resizable()
                    .frame(width: 50, height: 50)
            }
            Slider(value: Binding(
                get: { self.playerManager.currentTime },
                set: { newTime in
                    self.playerManager.seek(to: newTime)
                }
            ), in: 0 ... Double(mp3.length))
            Text("\(self.formatTime(Int(self.playerManager.currentTime))) / \(self.formatTime(mp3.length))")
        }.onAppear {
            self.playerManager.playPause()
            print(self.playerManager.duration)
        }
    }
}
