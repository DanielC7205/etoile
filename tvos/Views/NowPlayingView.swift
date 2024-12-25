//
//  NowPlayingView.swift
//  etoile.EtoileIos
//
//  Created by Juliette Bernheisel on 8/31/24.
//

import SwiftUI

struct NowPlayingView: View {
    
    let pub = NotificationCenter.default
            .publisher(for: NSNotification.Name("etoileDidStartPlaying"))

    @State var songName = "Junio"
    @State var artistName = "Clairo"
    @State var albumArt = UIImage(systemName: "questionmark")
    
    var body: some View {
        HStack {
            VStack {
                Image(uiImage: albumArt ?? UIImage(systemName: "questionmark")!)
                Text(songName)
                    .accessibilityIdentifier("songName")
                    .fontWeight(.bold)
                Text(artistName)
            }
            LyricsView()
            
        }
        .task {
            await MainActor.run {
                updateUI()
            }
        }
        .onReceive(pub) {_ in
            Task {
                await MainActor.run {
                    updateUI()
                }
            }
        }
        .onPlayPauseCommand {
            ConfigurationSingleton.shared.player.togglePlayback()
        }
        .focusable()
    }
    
    func updateUI() {
        guard let song = ConfigurationSingleton.shared.player.playingSong else { return }
        
        if let art = song.art {
            let image = UIImage(data: art)
            self.albumArt = image
        }
        
        self.songName = song.name
        self.artistName = song.artist
    }
}
