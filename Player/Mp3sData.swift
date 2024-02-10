
import CryptoKit
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
    let file_hash: String

    func nameForFile() -> String {
        return "\(id).mp3"
    }

    func localFileHash() -> String? {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let localURL = documentsDirectory.appendingPathComponent(nameForFile())

        guard let fileData = try? Data(contentsOf: localURL) else { return nil }

        let hash = SHA256.hash(data: fileData)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}
