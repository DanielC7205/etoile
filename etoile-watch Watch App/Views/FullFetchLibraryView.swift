//
//  FullFetchLibraryView.swift
//  etoile
//
//  Created by Juliette Bernheisel on 9/4/24.
//

import SwiftUI
import EtoileKit

struct FullFetchLibraryView: View {
    
    @State var page: FullFetchPage = .albums
    @State var albumName = ""
    var callback: () -> ()
    
    var body: some View {
        VStack {
            Text("One sec as we fetch your library...")
                .foregroundStyle(Color(uiColor: .etoileTextColor()))
            if page == .albums {
                Text("Getting your albums")
                    .foregroundStyle(Color(uiColor: .etoileTextColor()))
                ProgressView()
                    .foregroundStyle(Color(uiColor: .etoileTextColor()))
            } else if page == .songs {
                Text("Getting songs from album: \(albumName)")
                    .foregroundStyle(Color(uiColor: .etoileTextColor()))
            } else if page == .playlists {
                Text("Getting your playlists")
            } else if page == .songsPlaylist {
                Text("Getting songs from playlist: \(albumName)")
                    .foregroundStyle(Color(uiColor: .etoileTextColor()))
            } else if page == .done {
                Text("Done!")
                    .foregroundStyle(Color(uiColor: .etoileTextColor()))
                Button(action: {
                    callback()
                }) {
                    Text("Tap me to start using Etoile!")
                        .foregroundStyle(Color(uiColor: .etoileTextColor()))
                        .backgroundStyle(Color(uiColor: .etoileButtonBackground()))
                }
                .accessibilityLabel("done")
            } else if page == .error {
                Text("Error getting your library!")
                    .foregroundStyle(Color(uiColor: .etoileTextColor()))
            }
        }
        .task {
            do {
                let library = EtoileLibrary()
                let (albums, _) = try await library.refresh(deviceName: "Watch")
                
                self.page = .songs
                
                for album in albums {
                    self.albumName = album.name
                    try await library.getSongsInAlbum(albumId: album.id, deviceName: "Watch")
                }
                
                page = .playlists
                
                let playlists = try await library.pullPlaylistsFromFin()
                
                page = .songsPlaylist
                
                for playlist in playlists {
                    self.albumName = playlist.name
                    try await library.getSongsFromPlaylist(playlistId: playlist.id)
                }
                
                page = .done
            } catch {
                page = .error
            }
        }
    }
}

enum FullFetchPage {
    case albums, songs, playlists, songsPlaylist, done, error
}
