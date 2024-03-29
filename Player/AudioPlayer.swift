
import AVFoundation
import Combine
import SwiftUI

class AudioPlayer: NSObject, ObservableObject {
    @ObservedObject var networkManager = NetworkManager()
    private var audioPlayer: AVPlayer?
    private var timeObserverToken: Any?
    private var playerItem: AVPlayerItem?

    @Published var isPlaying = false
    @Published var ended = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0

    deinit {
        if let timeObserverToken = timeObserverToken {
            audioPlayer?.removeTimeObserver(timeObserverToken)
        }
        NotificationCenter.default.removeObserver(self)
    }

    func newMp3(mp3: Mp3?) {
        if let safeMp3 = mp3 {
            if let localURL = localFileURL(for: safeMp3) {
                setupPlayer(with: localURL)
            } else {
                let urlString = "\(networkManager.baseUrl)/api/mp3s/\(safeMp3.id)/play"

                dowloadMp3(from: urlString) { [weak self] tempURL in
                    guard let self = self, let tempURL = tempURL else { return }

                    self.saveMP3Locally(originalURL: tempURL, mp3: safeMp3) { localURL in
                        guard let localURL = localURL else { return }

                        self.setupPlayer(with: localURL)
                    }
                }
            }
        } else {
            print("New queued mp3 error: MP3 or MP3 ID is nil")
        }
    }

    private func setupPlayer(with url: URL) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session category. Error: \(error)")
        }

        DispatchQueue.main.async {
            self.playerItem = AVPlayerItem(url: url)
            self.audioPlayer = AVPlayer(playerItem: self.playerItem)
            self.addPeriodicTimeObserver()
            self.addObserver()

            self.playerItem?.addObserver(self, forKeyPath: "status", options: [.new, .old], context: nil)
            self.playPause()
        }
    }

    func playPause() {
        if isPlaying {
            audioPlayer?.pause()
        } else {
            audioPlayer?.play()
            ended = false
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
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem, queue: .main
        ) { [weak self] _ in
            self?.isPlaying = false
            self?.seek(to: 0)
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerItemDidReachEnd),
            name: .AVPlayerItemDidPlayToEndTime,
            object: playerItem
        )
    }

    @objc func playerItemDidReachEnd(notification: Notification) {
        DispatchQueue.main.async {
            self.ended = true
        }
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status", let playerItem = object as? AVPlayerItem {
            if playerItem.status == .readyToPlay {
                audioPlayer?.play()
            } else if playerItem.status == .failed {
                print("Player item failed to load")
            }
        }
    }

    func localFileURL(for mp3: Mp3) -> URL? {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(mp3.nameForFile())

        return fileManager.fileExists(atPath: fileURL.path) ? fileURL : nil
    }

    func saveMP3Locally(originalURL: URL, mp3: Mp3, retryCount: Int = 0, completion: @escaping (URL?) -> Void) {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationURL = documentsDirectory.appendingPathComponent(mp3.nameForFile())

        do {
            try fileManager.copyItem(at: originalURL, to: destinationURL)
            completion(destinationURL)
        } catch {
            if retryCount < Constants.maxRetryAttempts {
                let delayInSeconds = pow(Double(Constants.initialDelayInSeconds), Double(retryCount))

                DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds) {
                    self.saveMP3Locally(
                        originalURL: originalURL,
                        mp3: mp3,
                        retryCount: retryCount + 1,
                        completion: completion
                    )
                }
            } else {
                completion(nil)
            }
        }
    }

    func dowloadMp3(from urlString: String, retryCount: Int = 0, completion: @escaping (URL?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        let task = URLSession.shared.downloadTask(with: url) { localURL, _, error in
            if let localURL = localURL {
                completion(localURL)
            } else {
                print("Failed to download mp3: \(error?.localizedDescription ?? "Unknown error"), retries count \(retryCount)")

                if retryCount < Constants.maxRetryAttempts {
                    let delayInSeconds = pow(Double(Constants.initialDelayInSeconds), Double(retryCount))

                    DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds) {
                        self.dowloadMp3(
                            from: urlString,
                            retryCount: retryCount + 1,
                            completion: completion
                        )
                    }
                } else {
                    print("Mp3 download maximum retries reached, giving up.")
                    completion(nil)
                }
            }
        }

        task.resume()
    }
}
