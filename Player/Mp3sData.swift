
import Foundation

struct Mp3s: Decodable {
    let mp3s: [Mp3]
}

struct Mp3: Identifiable, Decodable {
    let id: Int
    let track: Int
    let length: Int
    let title: String
    let album_name: String
    let artist_name: String

    func nameForFile() -> String {
        let baseName = title
            .lowercased()
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "[^-a-zA-Z_]", with: "", options: [.regularExpression])
            .replacingOccurrences(of: "[_]{2}", with: "_", options: [.regularExpression])

        return "\(id)-\(baseName).mp3"
    }
}
