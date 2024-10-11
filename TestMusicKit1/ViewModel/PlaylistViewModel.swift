//
//  PlaylistViewModel.swift
//  TestMusicKit1
//
//  Created by a on 10.10.24.
//

import SwiftUI
import MediaPlayer
import Combine
import MusicKit

class PlaylistViewModel: ObservableObject {
    @Published var playlists: [Playlist] = []
    @Published var currentSong: MPMediaItem? = nil
    @Published var isPlaying: Bool = false
    @Published var favoriteSongs: Set<String> = [] // 使用歌曲的 persistentID 作为标识

    private var mediaQuery: MPMediaQuery
    private var musicPlayer = MPMusicPlayerController.applicationMusicPlayer
    private var cancellables = Set<AnyCancellable>()
    
    var currentPlaylist: Playlist? = nil
    var currentIndex: Int? = nil
    
    init() {
        self.mediaQuery = MPMediaQuery.playlists()
        requestAuthorization()
        
        // 监听播放状态变化
        NotificationCenter.default.publisher(for: .MPMusicPlayerControllerPlaybackStateDidChange, object: musicPlayer)
            .sink { [weak self] _ in
                self?.isPlaying = self?.musicPlayer.playbackState == .playing
                if self?.isPlaying == true {
                    self?.currentSong = self?.musicPlayer.nowPlayingItem
                }
            }
            .store(in: &cancellables)
        
        musicPlayer.beginGeneratingPlaybackNotifications()
    }
    
    deinit {
        musicPlayer.endGeneratingPlaybackNotifications()
    }
    
    /// 请求媒体库访问权限
    func requestAuthorization() {
        let status = MPMediaLibrary.authorizationStatus()
        if status == .notDetermined {
            MPMediaLibrary.requestAuthorization { [weak self] newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized {
                        self?.fetchPlaylists()
                    } else {
                        print("用户拒绝访问媒体库。")
                    }
                }
            }
        } else if status == .authorized {
            fetchPlaylists()
        } else {
            print("无法访问媒体库。请在设置中授权。")
        }
    }
    
    /// 获取用户的歌单
    func fetchPlaylists() {
        guard let items = mediaQuery.collections else {
            print("没有找到任何歌单。")
            return
        }
        
        var fetchedPlaylists: [Playlist] = []
        
        for collection in items {
            let playlist = Playlist(
                id: String(collection.persistentID),
                name: collection.value(forProperty: MPMediaPlaylistPropertyName) as? String ?? "未知歌单",
                items: collection.items
            )
            fetchedPlaylists.append(playlist)
        }
        
        self.playlists = fetchedPlaylists
    }
    
    /// 播放选中的歌曲
    func playSong(_ song: MPMediaItem, in playlist: Playlist) {
        musicPlayer.setQueue(with: MPMediaItemCollection(items: [song]))
        musicPlayer.play()
        print("正在播放: \(song.title ?? "未知歌曲")")
        DispatchQueue.main.async {
            self.currentSong = song
            self.isPlaying = true
            self.currentPlaylist = playlist
            self.currentIndex = playlist.items.firstIndex(of: song)
        }
    }
    
    /// 播放或暂停
    func togglePlayPause() {
        if isPlaying {
            musicPlayer.pause()
        } else {
            musicPlayer.play()
        }
    }
    
    /// 播放下一首
    func playNext() {
        guard let playlist = currentPlaylist,
              let currentIndex = currentIndex,
              currentIndex + 1 < playlist.items.count else {
            print("已经是最后一首歌曲。")
            return
        }
        
        let nextSong = playlist.items[currentIndex + 1]
        playSong(nextSong, in: playlist)
    }
    
    /// 播放上一首
    func playPrevious() {
        guard let playlist = currentPlaylist,
              let currentIndex = currentIndex,
              currentIndex - 1 >= 0 else {
            print("已经是第一首歌曲。")
            return
        }
        
        let previousSong = playlist.items[currentIndex - 1]
        playSong(previousSong, in: playlist)
    }
    
    /// 收藏或取消收藏歌曲
    func toggleFavorite(song: MPMediaItem) {
        let id = String(song.persistentID)
            if favoriteSongs.contains(id) {
                favoriteSongs.remove(id)
            } else {
                favoriteSongs.insert(id)
            }
    }
    
    /// 检查歌曲是否被收藏
    func isFavorite(song: MPMediaItem) -> Bool {
        let id = String(song.persistentID)
        return favoriteSongs.contains(id)
    }
    
    /// 删除歌曲
    func deleteSong(_ song: MPMediaItem, from playlist: Playlist) {
        // 注意：MPMediaQuery 不支持删除歌曲，您需要使用 MPMediaLibrary 进行修改
        // 但 Apple Music API 可能有限制，请确保您的应用有权限进行此操作
        print("删除歌曲功能尚未实现。")
    }
    
    /// 将歌曲添加到其他歌单
    func addSong(_ song: MPMediaItem, to newPlaylist: Playlist) {
        // 注意：MPMediaQuery 不支持直接添加歌曲到歌单，您需要使用 MPMediaLibrary 进行修改
        // 但 Apple Music API 可能有限制，请确保您的应用有权限进行此操作
        print("添加歌曲功能尚未实现。")
    }
}
