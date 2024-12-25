//
//  PlaylistView.swift
//  iosTests
//
//  Created by Juliette Bernheisel on 9/19/24.
//

import SwiftUI
import EtoileKit
import OSLog

struct PlaylistView: View {
    
    var playlist: Playlist
    
    @State var songs: [Song] = []
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        List($songs) { song in
            Button {
                Task {
                    do {
                        let player = PlayerModel()
                        let indexAfterThis = songs.firstIndex(of: song.wrappedValue) ?? 0 + 1
                        let songsAfterSong = songs[indexAfterThis...]
                        try await player.startPlayingSongsAndAddToQueueWithClearing(song: song.wrappedValue, queue: Array(songsAfterSong))
                        await MainActor.run {
                            presentationMode.wrappedValue.dismiss()
                        }
                    } catch {
                        Logger().error("\(#file):\(#line) error playing: \(error)")
                    }
                }
            } label: {
                Text(song.wrappedValue.name)
            }
        }
        .task {
            do {
                let library = EtoileLibrary()
                self.songs = try await library.getSongsFromPlaylist(playlistId: playlist.id)
            } catch {
                Logger().error("Playlist view \(error)")
            }
        }

    }
}

