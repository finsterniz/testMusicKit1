//
//  PlaylistView.swift
//  TestMusicKit1
//
//  Created by a on 11.10.24.
//

import SwiftUI

struct PlaylistView: View {
    @ObservedObject var viewModel = PlaylistViewModel()
    
    var body: some View {
        NavigationView {
            List(viewModel.playlists) { playlist in
                NavigationLink(destination: PlaylistDetailView(playlist: playlist, viewModel: viewModel)) {
                    Text(playlist.name)
                }
            }
            .navigationTitle("我的歌单")
        }
    }
}

import SwiftUI
import MediaPlayer

struct PlaylistDetailView: View {
    var playlist: Playlist
    @ObservedObject var viewModel: PlaylistViewModel
    
    var body: some View {
        List(playlist.items, id: \.persistentID) { item in
            VStack(alignment: .leading) {
                Text(item.title ?? "未知歌曲")
                    .font(.headline)
                Text(item.artist ?? "未知艺术家")
                    .font(.subheadline)
            }
            .onTapGesture {
                viewModel.playSong(item)
            }
        }
        .navigationTitle(playlist.name)
    }
}

#Preview {
    PlaylistView()
}
