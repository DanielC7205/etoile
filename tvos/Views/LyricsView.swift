//
//  LyricsView.swift
//  etoile.EtoileIos
//
//  Created by Juliette Bernheisel on 8/31/24.
//

import SwiftUI
import EtoileKit
import JellyfinAPI
import OSLog
import CoreMedia

struct LyricsView: View {
    
    @State var lyrics: [LyricLine] = []
    @State var isPlain = true
    @State var error = false
    @State private var position = ScrollPosition(edge: .top)
    @State var highlighted = 0
    
    var body: some View {
        VStack {
            if !error || !isPlain {
                List($lyrics, id: \.start) { line in
                    if highlighted == lyrics.firstIndex(where: { $0.text == line.text.wrappedValue}) {
                        Text(line.wrappedValue.text ?? "")
                            .fontWeight(.heavy)
                    } else {
                        Text(line.wrappedValue.text ?? "")
                    }
                }
                .scrollPosition($position)
            }
        }
        .task {
            await getLyrics()
        }
    }
    
    func getLyrics() async {
        do {
            guard let song = ConfigurationSingleton.shared.player.playingSong else { return }
            let lyricsTmp = try await song.getLyrics(deviceName: "TV")
            
            if !(lyricsTmp.synced ?? true) {
                Logger().info("Lyrics for \(song.name) are NOT synced")
                await MainActor.run {
                    self.isPlain = true
                }
                return
            }
            
            
            await MainActor.run {
                self.lyrics = lyricsTmp.lines ?? []
            }
            

            // Jellyfin gives us the timecode in ticks
            // One tick = .00000001 of a second
            let divider = 10000000
            var index = 0
            for lyric in lyricsTmp.lines ?? [] {
                guard let start = lyric.start else { return }
                let startTime = CMTimeMake(value: Int64(start), timescale: Int32(divider))
                let endTime = CMTimeMake(value: Int64(start + 1), timescale: Int32(divider))

                var internalIndex = index
                ConfigurationSingleton.shared.player.player.addBoundaryTimeObserver(forTimes: [NSValue(time: startTime), NSValue(time: endTime)], queue: DispatchQueue.main, using: {
                    self.position.scrollTo(id: start)
                    self.highlighted = internalIndex
                    
                })
                index += 1
            }
            
//            guard let timeBase = ConfigurationSingleton.shared.player.player.currentItem?.timebase else { return } // Getting the time base of the song
//            for lyric in lyricsTmp {
//
//                guard let start = lyric.start else { return }
//                let time = CMTime(value: Int64(start), timescale: CMTimeScale(exactly: timeBase.rate) ?? 0)
//            }
        } catch {
            await MainActor.run {
                self.error = true
            }
        }
    }
}
