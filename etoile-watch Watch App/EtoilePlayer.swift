//
//  EtoilePlayer.swift
//  etoile
//
//  Created by Juliette Bernheisel on 8/26/24.
//

import Foundation
import AVFoundation
import OSLog
import EtoileKit
import MediaPlayer
import UIKit

class EtoilePlayer {
    private let player = AVQueuePlayer()
    
    private var hasBeenSetup = false
    private var songs: [Song] = []
    private var playerItems: [AVPlayerItem] = []
    private var position = 0
    
    
    var startedPlaying: [() -> ()] = []
    var playingSong: Song? = nil
    
    init() {
        do {
            // Telling apple that we're an audio app :)
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            

            NotificationCenter.default.addObserver(self, selector: #selector(didFinishPlaying), name: AVPlayerItem.didPlayToEndTimeNotification, object: player.currentItem)
        } catch {
            Logger().error("\(#file):\(#line) \(error)")
        }
    }
    
    func isPlaying() -> Bool {
        return player.rate != 0 && player.error == nil
    }
    
    func play() {
            player.play()
            tellThatWerePlaying()
    }
    
    func pause() {
        player.pause()
        let center = NotificationCenter.default
        let notification = Notification(name: Notification.Name("etoileDidStopPlaying"))
        center.post(notification)
    }
    
    func getSongs() -> [Song] {
        return songs
    }
    
    func getPosition() -> Int {
        return position
    }
    
    /// Adds to queue but does not play it
    func appendToQueue(item: AVPlayerItem, song: Song) {
        songs.append(song)
        
        playerItems.append(item)
        player.insert(item, after: nil)
        playerItems.append(item)
        
    }
    
    /// Inserts a song in the queue at the position of that song
    func insert(item: AVPlayerItem, forSong song: Song, index: Int) {
        let items = player.items()
        let songToAppendAfter = items[index]
        songs.insert(song, at: index)
        
        playerItems.insert(item, at: index)
        player.insert(item, after: songToAppendAfter)
        
    }
    
    /// Replaces currently playing and plays it
    func playSong(item: AVPlayerItem, forSong song: Song) {
        Task.detached { [self] in
            player.pause()
            songs.insert(song, at: position)
            
            playerItems.insert(item, at: position)
            player.replaceCurrentItem(with: item)
            player.play()
            
            playingSong = song
            
            tellThatWerePlaying()
            
            while (playingSong == song) {
                try await  Task.sleep(nanoseconds: 10000000000)
            }
        }
    }
    
    func nextSong() {
        if position + 1 >= songs.count {
            return
        }
        player.advanceToNextItem()
        position = position + 1
        playingSong = songs[position]
        tellThatWerePlaying()
    }
    
    func previousSong() {
        position -= 1
        if position < 0 {
            position = 0
            return
        }
        playingSong = songs[position]
        player.replaceCurrentItem(with: playerItems[position])
        tellThatWerePlaying()
    }
    
    fileprivate func tellThatWerePlaying() {
        // Posting internal notification
        let center = NotificationCenter.default
        let notification = Notification(name: Notification.Name("etoileDidStartPlaying"))
        center.post(notification)
        
        // Nowplaying
        guard let art = playingSong?.art else { return }
        guard let uiArt = UIImage(data: art) else { return }
        let mediaArtwork = MPMediaItemArtwork(boundsSize: uiArt.size) { (size: CGSize) -> UIImage in
            return uiArt
        }
                
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPMediaItemPropertyArtist: playingSong?.artist,
            MPMediaItemPropertyTitle: playingSong?.name,
            MPMediaItemPropertyArtwork: mediaArtwork,
            MPNowPlayingInfoPropertyIsLiveStream: false
        ]
        Logger().info("Set nowplaying info")
    }

    
    @objc private func didFinishPlaying() {
        position += 1
        if position > songs.count - 1 {
            position -= 1
            return
        }
        playingSong = songs[position]
        tellThatWerePlaying()
    }
    
    func clearQueue() {
        position = 0
        songs = []
        playerItems = []
        playingSong = nil
        player.removeAllItems()
    }
}
