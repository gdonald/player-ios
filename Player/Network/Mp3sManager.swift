
import Foundation

class Mp3sManager: ObservableObject {
    @Published var mp3s = [Mp3]()

    func fetch() {
        if let url = URL(string: "http://10.0.0.33:3000/api/mp3s.json") {
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
}
