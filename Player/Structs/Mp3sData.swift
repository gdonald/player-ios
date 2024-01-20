//
//  Mp3sData.swift
//  Player
//
//  Created by Greg Donald on 1/19/24.
//

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
}
