
import Foundation

class NetworkManager: ObservableObject {
    @Published var mainCounts = MainCounts(mp3s_count: 0, playlists_count: 0, queued_mp3s_count: 0, sources_count: 0)
    @Published var mp3s = [Mp3]()
    @Published var playlists = [Playlist]()
    @Published var queuedMp3s = [QueuedMp3]()

    func fetchCounts() {
        if let url = URL(string: "\(Constants.baseUrl)/counts.json") {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, _, error in
                if error == nil {
                    let decoder = JSONDecoder()
                    if let safeData = data {
                        do {
                            let results = try decoder.decode(MainCounts.self, from: safeData)
                            DispatchQueue.main.async {
                                self.mainCounts = results
                            }
                        } catch {
                            print(error)
                        }
                    }
                }
            }
            task.resume()
        }
    }

    func fetchMp3s() {
        if let url = URL(string: "\(Constants.baseUrl)/mp3s.json") {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, _, error in
                if error == nil {
                    let decoder = JSONDecoder()
                    if let safeData = data {
                        do {
                            let results = try decoder.decode(Mp3s.self, from: safeData)
                            DispatchQueue.main.async {
                                self.mp3s = results.mp3s
                            }
                        } catch {
                            print(error)
                        }
                    }
                }
            }
            task.resume()
        }
    }

    func fetchQueuedMp3s() {
        if let url = URL(string: "\(Constants.baseUrl)/queued_mp3s.json") {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, _, error in
                if error == nil {
                    let decoder = JSONDecoder()
                    if let safeData = data {
                        do {
                            let results = try decoder.decode(QueuedMp3s.self, from: safeData)
                            DispatchQueue.main.async {
                                self.queuedMp3s = results.queued_mp3s
                            }
                        } catch {
                            print(error)
                        }
                    }
                }
            }
            task.resume()
        }
    }

    func fetchPlaylists() {
        if let url = URL(string: "\(Constants.baseUrl)/playlists.json") {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, _, error in
                if error == nil {
                    let decoder = JSONDecoder()
                    if let safeData = data {
                        do {
                            let results = try decoder.decode(Playlists.self, from: safeData)
                            DispatchQueue.main.async {
                                self.playlists = results.playlists
                            }
                        } catch {
                            print(error)
                        }
                    }
                }
            }
            task.resume()
        }
    }

    func fetch() {
        fetchMp3s()
        fetchCounts()
        fetchPlaylists()
        fetchQueuedMp3s()
    }
}
