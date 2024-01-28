
import Foundation

struct Playlists: Decodable {
    let playlists: [Playlist]
}

struct Playlist: Identifiable, Decodable {
    let id: Int
    let mp3s_count: Int
    let name: String
}
