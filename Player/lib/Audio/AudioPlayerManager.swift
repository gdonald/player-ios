
import AVFoundation
import Combine
import SwiftUI

class AudioPlayerManager: NSObject, ObservableObject {
    private var audioPlayer: AVPlayer?
    private var timeObserverToken: Any?
    private var playerItem: AVPlayerItem?

    @Published var isPlaying = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0

    init(mp3: Mp3) {
        super.init()
        playerItem = AVPlayerItem(url: URL(string: "\(Constants.baseUrl)/mp3s/\(mp3.id)/play")!)
        audioPlayer = AVPlayer(playerItem: playerItem)
        addPeriodicTimeObserver()
        addObserver()
    }

    deinit {
        if let timeObserverToken = timeObserverToken {
            audioPlayer?.removeTimeObserver(timeObserverToken)
        }
        NotificationCenter.default.removeObserver(self)
    }

    func playPause() {
        if isPlaying {
            audioPlayer?.pause()
        } else {
            audioPlayer?.play()
        }
        isPlaying.toggle()
    }

    func seek(to seconds: Double) {
        audioPlayer?.seek(to: CMTime(seconds: seconds, preferredTimescale: 1000))
    }

    private func addPeriodicTimeObserver() {
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = audioPlayer?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.currentTime = time.seconds
        }
    }

    private func addObserver() {
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: playerItem, queue: .main) { [weak self] _ in
            self?.isPlaying = false
            self?.seek(to: 0)
        }
        playerItem?.addObserver(self, forKeyPath: "duration", options: [.new, .initial], context: nil)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        //
    }
}
