//
//  RecentlyPlayedView.swift
//  etoile.EtoileIos
//
//  Created by Juliette Bernheisel on 8/31/24.
//

import SwiftUI
import EtoileKit
import OSLog

struct RecentlyPlayedView: View {
    
    @State var songs: [Song] = []
    @Binding var tab: Tabs
    
    var body: some View {
        if songs.count == 0 {
            Text("No recently played songs")
        }
        List($songs.reversed(), id: \.id) { song in
            Button(action: {
                Task {
                    do {
                        let player = PlayerModel()
                        try await player.play(song: song.wrappedValue)
                        await MainActor.run {
                            self.tab = .nowPlaying
                        }
                    } catch {
                        Logger().error("\(#file):\(#line) error playing: \(error)")
                    }
                }
            }) {
                VStack {
                    if let songImage = song.wrappedValue.art {
                        Image(uiImage: UIImage(data: songImage) ?? UIImage(systemName: "questionmark")!)
                            .resizable()
                            .aspectRatio(9 / 9, contentMode: .fit)
                            .accessibilityIdentifier("recentsAlbumArt")

                    }
                    Text(song.wrappedValue.name)
                        .fontWeight(.bold)
                        .accessibilityIdentifier("recentsSongName")
                    Text(song.wrappedValue.artist)
                }
            }
//            .listStyle(.plain)
//            .frame(height: 128)
            
            
        }
        .onAppear {
            do {
                let library = EtoileLibrary()
                songs = try library.getRecentlyPlayed()
            } catch {
                Logger().error("Error getting recently played: \(error)")
            }
        }
        
        
    }
}

