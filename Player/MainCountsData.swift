
import Foundation

struct MainCounts: Decodable {
    let mp3s_count: Int
    let playlists_count: Int
    let queued_mp3s_count: Int
    let sources_count: Int

    init(mp3s_count: Int, playlists_count: Int, queued_mp3s_count: Int, sources_count: Int) {
        self.mp3s_count = mp3s_count
        self.playlists_count = playlists_count
        self.queued_mp3s_count = queued_mp3s_count
        self.sources_count = sources_count
    }
}
