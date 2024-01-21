
import Foundation

struct QueuedMp3s: Decodable {
    let queued_mp3s: [QueuedMp3]
}

struct QueuedMp3: Identifiable, Decodable {
    let id: Int
    let mp3_id: Int
    let position: Int
    let length: Int
    let track: Int
    let title: String
    let artist_name: String
    let album_name: String
}
