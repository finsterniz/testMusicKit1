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
            .navigationTitle("My lists")
        }
    }
}
