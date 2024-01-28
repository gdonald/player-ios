
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

    func fetchMp3s(retryCount: Int = 0) {
        if let url = URL(string: "\(Constants.baseUrl)/mp3s.json") {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, _, error in
                if let error = error {
                    print("Fetch Mp3s request failed: \(error), retryCount: \(retryCount)")

                    if retryCount < Constants.maxRetryAttempts {
                        let delay = Constants.initialDelayInSeconds * Int(pow(2.0, Double(retryCount)))
                        DispatchQueue.main.asyncAfter(deadline: .now() + Double(delay)) {
                            self.fetchMp3s(retryCount: retryCount + 1)
                        }
                    } else {
                        print("Max fetch mp3s retries reached.")
                    }
                    return
                }

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
            task.resume()
        }
    }

    func fetchQueuedMp3s(retryCount: Int = 0) {
        if let url = URL(string: "\(Constants.baseUrl)/queued_mp3s.json") {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, _, error in
                if let error = error {
                    print("Fetch queued mp3s request failed: \(error), retryCount: \(retryCount)")

                    if retryCount < Constants.maxRetryAttempts {
                        let delay = Constants.initialDelayInSeconds * Int(pow(2.0, Double(retryCount)))
                        DispatchQueue.main.asyncAfter(deadline: .now() + Double(delay)) {
                            self.fetchQueuedMp3s(retryCount: retryCount + 1)
                        }
                    } else {
                        print("Max fetch queued mp3s retries reached.")
                    }
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

    func fetchPlaylists(retryCount: Int = 0) {
        if let url = URL(string: "\(Constants.baseUrl)/playlists.json") {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, _, error in
                if let error = error {
                    print("Fetch playlists request failed: \(error), retryCount: \(retryCount)")

                    if retryCount < Constants.maxRetryAttempts {
                        let delay = Constants.initialDelayInSeconds * Int(pow(2.0, Double(retryCount)))
                        DispatchQueue.main.asyncAfter(deadline: .now() + Double(delay)) {
                            self.fetchPlaylists(retryCount: retryCount + 1)
                        }
                    } else {
                        print("Max fetch playlists retries reached.")
                    }
                    return
                }

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
            task.resume()
        }
    }

    func nextQueuedMp3(retryCount: Int = 0) {
        if currentMp3 == nil {
            return
        }

        if let url = URL(string: "\(Constants.baseUrl)/queued_mp3s/\(currentMp3?.id ?? 0).json") {
            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"

            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Next queued mp3 request failed: \(error), retryCount: \(retryCount)")

                    if retryCount < Constants.maxRetryAttempts {
                        let delay = Constants.initialDelayInSeconds * Int(pow(2.0, Double(retryCount)))
                        DispatchQueue.main.asyncAfter(deadline: .now() + Double(delay)) {
                            self.nextQueuedMp3(retryCount: retryCount + 1)
                        }
                    } else {
                        print("Max next queued mp3 retries reached.")
                    }
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    print("Next queued mp3 error: Invalid response or status code")
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

    func createQueuedMp3(mp3Id: String, retryCount: Int = 0) {
        guard let url = URL(string: "\(Constants.baseUrl)/queued_mp3s") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "queued_mp3": [
                "mp3_id": mp3Id
            ]
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("Create queued mp3 request failed: \(error), retryCount: \(retryCount)")

                if retryCount < Constants.maxRetryAttempts {
                    let delay = Constants.initialDelayInSeconds * Int(pow(2.0, Double(retryCount)))
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(delay)) {
                        self.createQueuedMp3(
                            mp3Id: mp3Id,
                            retryCount: retryCount + 1
                        )
                    }
                } else {
                    print("Max create queued mp3 request retries reached.")
                }
                return
            }

            let decoder = JSONDecoder()
            if let safeData = data {
                do {
                    let results = try decoder.decode(QueuedMp3s.self, from: safeData)

                    // TODO: make this optional behavior:
//                    DispatchQueue.main.async {
//                        self.queuedMp3s = results.queued_mp3s
//                        if self.currentMp3 == nil {
//                            self.currentMp3 = self.queuedMp3s.first
//                        }
//                    }
                } catch {
                    print(error)
                }
            }
        }
        task.resume()
    }

    func createQueuedMp3sFromPlaylist(playlistId: String, retryCount: Int = 0) {
        guard let url = URL(string: "\(Constants.baseUrl)/playlists/\(playlistId)/enqueue") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [:]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("Created queued mp3s from playlist request failed: \(error), retryCount: \(retryCount)")

                if retryCount < Constants.maxRetryAttempts {
                    let delay = Constants.initialDelayInSeconds * Int(pow(2.0, Double(retryCount)))
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(delay)) {
                        self.createQueuedMp3sFromPlaylist(
                            playlistId: playlistId,
                            retryCount: retryCount + 1
                        )
                    }
                } else {
                    print("Max create queued mp3s from playlist request retries reached.")
                }
                return
            }

            let decoder = JSONDecoder()
            if let safeData = data {
                do {
                    let results = try decoder.decode(QueuedMp3s.self, from: safeData)

                    // TODO: make this optional behavior:
//                    DispatchQueue.main.async {
//                        self.queuedMp3s = results.queued_mp3s
//                        if self.currentMp3 == nil {
//                            self.currentMp3 = self.queuedMp3s.first
//                        }
//                    }
                } catch {
                    print(error)
                }
            }
        }
        task.resume()
    }
}
