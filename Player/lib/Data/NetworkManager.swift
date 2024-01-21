
import Foundation

class NetworkManager: ObservableObject {
    @Published var mainCounts = MainCounts(mp3s_count: 0, playlists_count: 0, queued_mp3s_count: 0, sources_count: 0)
    @Published var mp3s = [Mp3]()
    @Published var playlists = [Playlist]()
    @Published var queuedMp3s = [QueuedMp3]()
    @Published var currentMp3: QueuedMp3?

    func fetch() {
        fetchMp3s()
        fetchPlaylists()
        fetchQueuedMp3s()
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
                                self.currentMp3 = self.queuedMp3s.first
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

    func nextQueuedMp3() {
        if currentMp3 == nil {
            return
        }

        if let url = URL(string: "\(Constants.baseUrl)/queued_mp3s/\(currentMp3?.id ?? 0).json") {
            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"

            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error making DELETE request: \(error)")
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    print("Error: Invalid response or status code")
                    return
                }

                let decoder = JSONDecoder()
                if let safeData = data {
                    do {
                        let results = try decoder.decode(QueuedMp3s.self, from: safeData)
                        DispatchQueue.main.async {
                            self.queuedMp3s = results.queued_mp3s
                            self.currentMp3 = self.queuedMp3s.first
                        }
                    } catch {
                        print(error)
                    }
                }
            }
            task.resume()
        }
    }
}
