
import Foundation

struct CachedMp3: Identifiable {
    let id: Int
    let fileURL: URL

    func nameForList() -> String {
        return fileURL.lastPathComponent
    }
}
