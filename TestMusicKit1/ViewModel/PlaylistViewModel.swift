//
//  PlaylistViewModel.swift
//  TestMusicKit1
//
//  Created by a on 10.10.24.
//

import SwiftUI
import MediaPlayer
import Combine

class PlaylistViewModel: ObservableObject {
    @Published var playlists: [Playlist] = []
    private var mediaQuery: MPMediaQuery
    private var musicPlayer = MPMusicPlayerController.applicationMusicPlayer
    
    init() {
        self.mediaQuery = MPMediaQuery.playlists()
        requestAuthorization()
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
    func playSong(_ song: MPMediaItem) {
        musicPlayer.setQueue(with: MPMediaItemCollection(items: [song]))
        musicPlayer.play()
        print("正在播放: \(song.title ?? "未知歌曲")")
    }
}
