//
//  ContentView.swift
//  TestMusicKit1
//
//  Created by a on 09.10.24.
//

import SwiftUI
import MusicKit

struct Item: Identifiable, Hashable{
    var id = UUID()
    let name: String
    let artist: String
    let imageURL: URL?
}

struct ContentView: View {
    @State var songs = [Item]()
    var body: some View {
        NavigationView(content: {
            List(songs){song in
                HStack{
                    AsyncImage(url: song.imageURL)
                        .frame(width: 75, height: 75, alignment: .center)
                    
                    VStack(alignment: .leading, content: {
                        Text(song.name)
                            .font(.title3)
                        Text(song.artist)
                            .font(.footnote)
                    })
                }
                .padding()
            }
        })
        .onAppear(perform: {
            fetchMusic()
        })
    }
    
    private let request: MusicCatalogSearchRequest = {
        var request = MusicCatalogSearchRequest(
            term: "Happy",
            types: [Song.self]
        )
        request.limit = 25
        return request
    }()
    
    private func fetchMusic(){
        // 请求permission
        Task{
            
            let status = await MusicAuthorization.request()
            switch status {
            case .authorized:
                print("Authorized")
                // Request -> Response
                do{
                    let result = try await request.response()
                    // Assign songs
                    self.songs = result.songs.compactMap({
                        return .init(name: $0.title, artist: $0.artistName, imageURL: $0.artwork?.url(width: 75, height: 75))
                    })
                    print(String(describing: songs[0]))
                }catch{
                    print(String(describing: error))
                }
                
                
            default:
                print("Unauthorized")
                break
            }
        }
        
        
    }
}

#Preview {
    ContentView()
}
