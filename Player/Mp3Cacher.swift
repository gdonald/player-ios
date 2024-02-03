
import Foundation

class Mp3Cacher: ObservableObject {
    @Published var cachedMp3s = [CachedMp3]()
    let fileManager = FileManager.default
    let documentsDirectory: URL

    fileprivate func populateCachedMp3s() {
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil)
            let mp3Files = fileURLs.filter { $0.pathExtension == "mp3" }

            var id = 0
            cachedMp3s = mp3Files.map { fileURL -> CachedMp3 in
                id += 1
                return CachedMp3(id: id, fileURL: fileURL)
            }
        } catch {
            print("Error while enumerating files \(documentsDirectory.path): \(error.localizedDescription)")
        }
    }

    init() {
        documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        populateCachedMp3s()
    }

    func refreshList() {
        populateCachedMp3s()
    }

    func removeMp3(cachedMp3: CachedMp3) {
        do {
            try fileManager.removeItem(at: cachedMp3.fileURL)
        } catch {
            print("Error while removing file \(cachedMp3.fileURL): \(error.localizedDescription)")
        }

        populateCachedMp3s()
    }
}
