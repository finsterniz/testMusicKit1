import SwiftUI
import MediaPlayer

struct PlaylistDetailView: View {
    var playlist: Playlist
    @ObservedObject var viewModel: PlaylistViewModel
    
    var body: some View {
        VStack {
            // 当前播放歌曲信息
            if let currentSong = viewModel.currentSong {
                VStack {
                    Text("当前播放:")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text(currentSong.title ?? "未知歌曲")
                        .font(.headline)
                    Text(currentSong.artist ?? "未知艺术家")
                        .font(.subheadline)
                }
                .padding()
            }
            
            // 歌曲列表
            List {
                ForEach(playlist.items, id: \.persistentID) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.title ?? "未知歌曲")
                                .font(.headline)
                            Text(item.artist ?? "未知艺术家")
                                .font(.subheadline)
                        }
                        
                        Spacer()
                        
                        // 收藏按钮
                        Button(action: {
                            viewModel.toggleFavorite(song: item)
                        }) {
                            Image(systemName: viewModel.isFavorite(song: item) ? "heart.fill" : "heart")
                                .foregroundColor(viewModel.isFavorite(song: item) ? .red : .gray)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .foregroundStyle(item == viewModel.currentSong ? .red : .blue)
                    .contentShape(Rectangle()) // 让整个行可点击
                    .onTapGesture {
                        viewModel.playSong(item, in: playlist)
                    }
                    .contextMenu {
                        Button(action: {
                            // 删除歌曲
                            viewModel.deleteSong(item, from: playlist)
                        }) {
                            Text("删除歌曲")
                            Image(systemName: "trash")
                        }
                        
                        Button(action: {
                            // 将歌曲添加到其他歌单
                            viewModel.addSong(item, to: playlist)
                        }) {
                            Text("将歌曲添加到列表")
                            Image(systemName: "plus.circle")
                        }
                    }
                }
            }
            
            // 播放控制
            HStack {
                Button(action: {
                    viewModel.playPrevious()
                }) {
                    Image(systemName: "backward.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .padding()
                }
                .disabled(viewModel.currentIndex == nil || viewModel.currentIndex == 0)
                
                Button(action: {
                    viewModel.togglePlayPause()
                }) {
                    Image(systemName: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .padding()
                }
                
                Button(action: {
                    viewModel.playNext()
                }) {
                    Image(systemName: "forward.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .padding()
                }
                .disabled(viewModel.currentPlaylist == nil || (viewModel.currentIndex ?? 0) >= (viewModel.currentPlaylist?.items.count ?? 1) - 1)
            }
            .padding(.bottom, 20)
        }
        .navigationTitle(playlist.name)
    }
}

struct PlaylistDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let samplePlaylist = Playlist(id: "1", name: "Sample Playlist", items: [])
        let viewModel = PlaylistViewModel()
        PlaylistDetailView(playlist: samplePlaylist, viewModel: viewModel)
    }
}
