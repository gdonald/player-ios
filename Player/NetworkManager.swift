
import Foundation

class NetworkManager: ObservableObject {
    var baseUrl: String = ""
    @Published var mainCounts = MainCounts(mp3s_count: 0, playlists_count: 0, queued_mp3s_count: 0, sources_count: 0)
    @Published var mp3s = [Mp3]()
    @Published var playlists = [Playlist]()
    @Published var queuedMp3s = [QueuedMp3]()
    @Published var currentMp3: QueuedMp3?
    @Published var syncingPlaylists: Bool = false

    init() {
        if let receivedData = KeychainHelper.load(key: "baseUrl"),
           let value = String(data: receivedData, encoding: .utf8)
        {
            self.baseUrl = value
        }
    }

    func fetch() {
        fetchMp3s()
        fetchPlaylists()
        fetchQueuedMp3s()
    }

    func fetchMp3s(retryCount: Int = 0) {
        if let url = URL(string: "\(baseUrl)/api/mp3s.json") {
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
        if let url = URL(string: "\(baseUrl)/api/queued_mp3s.json") {
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
        if let url = URL(string: "\(baseUrl)/api/playlists.json") {
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
                            self.syncPlaylists()
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
        let mp3ToDequeue = currentMp3

        // update local data manually instead of waiting for a network request
        if queuedMp3s.count >= 2 {
            currentMp3 = queuedMp3s[1]
            queuedMp3s.removeFirst()
        } else if queuedMp3s.count == 1 {
            currentMp3 = nil
            queuedMp3s.removeFirst()
        } else if queuedMp3s.isEmpty || mp3ToDequeue == nil {
            return
        }

        if let url = URL(string: "\(baseUrl)/api/queued_mp3s/\(mp3ToDequeue?.id ?? 0).json") {
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
        guard let url = URL(string: "\(baseUrl)/api/queued_mp3s") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "queued_mp3": [
                "mp3_id": mp3Id
            ]
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
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

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Create queued mp3 error: Invalid response or status code")
                return
            }

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
        task.resume()
    }

    func createQueuedMp3sFromPlaylist(playlistId: String, retryCount: Int = 0) {
        guard let url = URL(string: "\(baseUrl)/api/playlists/\(playlistId)/enqueue") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [:]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
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

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Create queued mp3s from playlist error: Invalid response or status code")
                return
            }

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
        task.resume()
    }

    func deleteQueuedMp3(queuedMp3Id: String, retryCount: Int = 0) {
        guard let url = URL(string: "\(baseUrl)/api/queued_mp3s/\(queuedMp3Id)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [:]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Delete queued mp3 request failed: \(error), retryCount: \(retryCount)")

                if retryCount < Constants.maxRetryAttempts {
                    let delay = Constants.initialDelayInSeconds * Int(pow(2.0, Double(retryCount)))
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(delay)) {
                        self.deleteQueuedMp3(
                            queuedMp3Id: queuedMp3Id,
                            retryCount: retryCount + 1
                        )
                    }
                } else {
                    print("Max delete queued mp3 request retries reached.")
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Delete queued mp3 error: Invalid response or status code")
                return
            }

            let decoder = JSONDecoder()
            if let safeData = data {
                do {
                    let results = try decoder.decode(QueuedMp3s.self, from: safeData)
                    DispatchQueue.main.async {
                        self.queuedMp3s = results.queued_mp3s

                        if results.queued_mp3s.isEmpty {
                            return
                        }

                        if let firstQueuedMp3Id = results.queued_mp3s.first?.id {
                            if let currentMp3Id = self.currentMp3?.id {
                                if firstQueuedMp3Id != currentMp3Id {
                                    self.currentMp3 = results.queued_mp3s.first
                                }
                            }
                        }
                    }
                } catch {
                    print(error)
                }
            }
        }
        task.resume()
    }

    func syncPlaylists() {
        if syncingPlaylists {
            return
        }

        syncingPlaylists = true

        for playlist in playlists {
            syncPlaylist(id: String(playlist.id))
        }

        syncingPlaylists = false
    }

    func syncPlaylist(id: String, retryCount: Int = 0) {
        if let url = URL(string: "\(baseUrl)/api/playlists/\(id)/playlist_mp3s.json") {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, _, error in
                if let error = error {
                    print("Fetch playlists request failed: \(error), retryCount: \(retryCount)")

                    if retryCount < Constants.maxRetryAttempts {
                        let delay = Constants.initialDelayInSeconds * Int(pow(2.0, Double(retryCount)))
                        DispatchQueue.main.asyncAfter(deadline: .now() + Double(delay)) {
                            self.syncPlaylist(id: id, retryCount: retryCount + 1)
                        }
                    } else {
                        print("Max sync playlist retries reached.")
                    }
                    return
                }

                let decoder = JSONDecoder()
                if let safeData = data {
                    do {
                        let results = try decoder.decode(PlaylistMp3s.self, from: safeData)
                        DispatchQueue.main.async {
                            for playlist_mp3 in results.playlist_mp3s {
                                self.dowloadMp3(mp3: playlist_mp3.mp3)
                            }
                        }
                    } catch {
                        print(error)
                    }
                }
            }
            task.resume()
        }
    }

    func dowloadMp3(mp3: Mp3, retryCount: Int = 0) {
        guard let url = URL(string: "\(baseUrl)/api/mp3s/\(mp3.id)/play") else { return }

        let task = URLSession.shared.downloadTask(with: url) { localURL, _, error in
            if let localURL = localURL {
                self.saveMP3Locally(originalURL: localURL, mp3: mp3)
            } else {
                print("Failed to download mp3: \(error?.localizedDescription ?? "Unknown error"), retries count \(retryCount)")

                if retryCount < Constants.maxRetryAttempts {
                    let delayInSeconds = pow(Double(Constants.initialDelayInSeconds), Double(retryCount))

                    DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds) {
                        self.dowloadMp3(
                            mp3: mp3,
                            retryCount: retryCount + 1
                        )
                    }
                } else {
                    print("Mp3 download maximum retries reached, giving up.")
                }
            }
        }
        task.resume()
    }

    func saveMP3Locally(originalURL: URL, mp3: Mp3, retryCount: Int = 0) {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationURL = documentsDirectory.appendingPathComponent(mp3.nameForFile())

        do {
            try fileManager.copyItem(at: originalURL, to: destinationURL)
        } catch {
            if retryCount < Constants.maxRetryAttempts {
                let delayInSeconds = pow(Double(Constants.initialDelayInSeconds), Double(retryCount))

                DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds) {
                    self.saveMP3Locally(
                        originalURL: originalURL,
                        mp3: mp3,
                        retryCount: retryCount + 1
                    )
                }
            }
        }
    }
}
