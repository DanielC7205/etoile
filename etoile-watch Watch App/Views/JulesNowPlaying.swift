//
//  JulesNowPlaying.swift
//  etoile.EtoileWatchos
//
//  Created by Juliette Bernheisel on 9/9/24.
//

import SwiftUI
import EtoileKit

struct JulesNowPlaying: View {
    let stopPub = NotificationCenter.default
            .publisher(for: NSNotification.Name("etoileDidStopPlaying"))
    let startPub = NotificationCenter.default
            .publisher(for: NSNotification.Name("etoileDidStartPlaying"))

    @State var song: Song? = nil
    @State var playing = true
    var body: some View {
        VStack {
            if let image = song?.art {
                Image(uiImage: UIImage(data: image) ?? UIImage(systemName: "questionmark")!)
                    .resizable()
                    .aspectRatio(9 / 9, contentMode: .fit)
//                    .frame(height: 128)

            }
            Text(song?.name ?? "Not playing")
            Text(song?.artist ?? "")
                .font(.caption)
            HStack {
                Button {
                    ConfigurationSingleton.shared.player.previousSong()
                } label: {
                    Image(systemName: "backward")
                }
                Button {
                    if playing {
                        ConfigurationSingleton.shared.player.pause()
                    } else {
                        ConfigurationSingleton.shared.player.play()
                    }
                } label: {
                    if playing {
                        Image(systemName: "play.circle.fill")
                    } else {
                        Image(systemName: "pause.circle.fill")
                    }
                }
                Button {
                    ConfigurationSingleton.shared.player.nextSong()
                } label: {
                    Image(systemName: "forward")
                }
            }
        }
        .onAppear {
            guard let song = ConfigurationSingleton.shared.player.playingSong else { return }
            self.song = song
            
        }
        .onReceive(startPub) {_ in 
            playing = true
            guard let song = ConfigurationSingleton.shared.player.playingSong else { return }
            self.song = song
        }
        .onReceive(stopPub) {_ in 
            playing = false
            guard let song = ConfigurationSingleton.shared.player.playingSong else { return }
            self.song = song
        }
    }
}
