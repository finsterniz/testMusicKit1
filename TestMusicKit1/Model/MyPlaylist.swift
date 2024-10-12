//
//  Playlist.swift
//  TestMusicKit1
//
//  Created by a on 10.10.24.
//

import MediaPlayer

struct Playlist: Identifiable {
    let id: String
    let name: String
    let items: [MPMediaItem]
}
