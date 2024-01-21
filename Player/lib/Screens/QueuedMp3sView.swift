
import SwiftUI

struct QueuedMp3sView: View {
    let queuedMp3s: [QueuedMp3]
    var currentMp3: QueuedMp3?

    @StateObject private var playerManager: AudioPlayerManager

    init(queuedMp3s: [QueuedMp3]) {
        self.queuedMp3s = queuedMp3s

        if !queuedMp3s.isEmpty {
            self.currentMp3 = queuedMp3s.first
        }

        let mp3 = Mp3(
            id: currentMp3?.mp3_id ?? 0,
            track: currentMp3?.track ?? 0,
            length: currentMp3?.length ?? 0,
            title: currentMp3?.title ?? "",
            album_name: currentMp3?.album_name ?? "",
            artist_name: currentMp3?.artist_name ?? ""
        )
        _playerManager = StateObject(wrappedValue: AudioPlayerManager(mp3: mp3))
    }

    var body: some View {
        VStack {
            List(queuedMp3s) { queuedMp3 in
                QueuedMp3ListItem(queuedMp3: queuedMp3)
                    .listRowInsets(EdgeInsets())
            }
            .listStyle(PlainListStyle())
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
                ), in: 0 ... Double(currentMp3?.length ?? 0))
                Text("\(formatTime(Int(self.playerManager.currentTime))) / \(formatTime(currentMp3?.length ?? 0))")
            }
        }
        .padding(0)
    }
}
