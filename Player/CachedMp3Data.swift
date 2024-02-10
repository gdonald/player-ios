
import Foundation

struct CachedMp3: Identifiable {
    let id: Int
    let fileURL: URL

    func nameForList(networkManager: NetworkManager) -> String {
        let mp3 = networkManager.mp3s.first(where: { $0.id == id })
        return mp3?.title ?? "unknown"
    }
}
