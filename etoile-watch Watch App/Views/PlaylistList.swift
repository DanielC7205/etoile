//
//  PlaylistList.swift
//  iosTests
//
//  Created by Juliette Bernheisel on 9/19/24.
//

import SwiftUI
import EtoileKit
import OSLog

struct PlaylistList: View {
    
    @State var playlists: [Playlist] = []
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List(playlists) { playlist in
                NavigationLink {
                    PlaylistView(playlist: playlist)
                } label: {
                    HStack {
                        Image(uiImage: (UIImage(data: playlist.art ?? Data()) ?? UIImage(systemName: "questionmark"))!)
                            .resizable()
                            .aspectRatio(9 / 9, contentMode: .fit)
                        Text(playlist.name)
                    }
                }
            }
            .task {
                do {
                    let library = EtoileLibrary()
                    self.playlists = try library.reloadNoPullPlaylist() ?? []
                } catch {
                    Logger().error("\(#file) : \(error)")
                }
            }
        }
    }
}
