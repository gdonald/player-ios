
import Foundation

struct QueuedMp3s: Decodable {
    let queued_mp3s: [QueuedMp3]
}

struct QueuedMp3: Identifiable, Decodable {
    let id: Int
    let position: Int
    let mp3: Mp3
}
