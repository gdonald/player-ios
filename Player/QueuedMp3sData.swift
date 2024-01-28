
import Foundation

struct QueuedMp3s: Decodable {
    let queued_mp3s: [QueuedMp3]
}

struct QueuedMp3: Identifiable, Decodable, Equatable {
    let id: Int
    let position: Int
    let mp3: Mp3

    static func ==(lhs: QueuedMp3, rhs: QueuedMp3) -> Bool {
        return lhs.id == rhs.id
    }
}
