
import Foundation

struct PlaylistMp3s: Decodable {
    let playlist_mp3s: [PlaylistMp3]
}

struct PlaylistMp3: Identifiable, Decodable {
    let id: Int
    let first: Bool
    let last: Bool
    let mp3: Mp3
}
