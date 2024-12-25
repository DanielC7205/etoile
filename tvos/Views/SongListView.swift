//
//  SongListView.swift
//  etoile-watch Watch App
//
//  Created by Juliette Bernheisel on 8/27/24.
//

import Foundation
import SwiftUI
import OSLog
import EtoileKit

struct SongListView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    let album: Album
    
    @Binding var tab: Tabs
    
    @State var songs: [Song] = []
    
    var body: some View {
        HStack {
            VStack {
                Image(uiImage: UIImage(data: album.art ?? Data()) ?? UIImage(systemName: "questionmark")!)
                Text(album.name)
                    .accessibilityIdentifier("albumName")
                    .fontWeight(.bold)
                Text(album.artist)
            }
            List(songs.sorted(by: { $0.positionInAlbum < $1.positionInAlbum})) {song in
                Button(action: {
                    Task {
                        do {
                            let player = PlayerModel()
                            let indexAfterThis = songs.firstIndex(of: song) ?? 0 + 1
                            let songsAfterSong = songs[indexAfterThis...]
                            try await player.startPlayingSongsAndAddToQueueWithClearing(song: song, queue: Array(songsAfterSong))
                            await MainActor.run {
                                self.tab = .nowPlaying
                            }
                        } catch {
                            Logger().error("\(#file):\(#line) error playing: \(error)")
                        }
                    }
                }) {
                    Text(song.name)
                }
            }
            .task {
                do {
                    let library = EtoileLibrary()
                    var (_, albums) = try library.reloadNoPull() ?? ([], [:])
                    
                    var songs: [Song] = []
                    if albums[album.id] == nil || albums[album.id] == [] {
                        songs = try await library.getSongsInAlbum(albumId: album.id, deviceName: "TV")
                    } else {
                        songs = albums[album.id] ?? []
                    }
                    self.songs = songs
                } catch {
                    Logger().error("\(#file):\(#line) error getting songs in album: \(error)")
                }
            }
        }
    }
}
