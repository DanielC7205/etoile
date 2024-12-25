//
//  EtoilePlayer.swift
//  etoile
//
//  Created by Juliette Bernheisel on 8/26/24.
//

import Foundation
import AVKit
import OSLog
import MediaPlayer
import EtoileKit

class EtoilePlayer {
    public let player = AVQueuePlayer()
    
    private var hasBeenSetup = false
    private var songs: [Song] = []
    private var playerItems: [AVPlayerItem] = []
    private var position = 0
    private var session: MPNowPlayingSession!
    var startedPlaying: [() -> ()] = []
    var playingSong: Song? = nil
    
    init() {
        do {
            // Telling apple that we're an audio app :)
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            

            session = MPNowPlayingSession(players: [player])
            
            // Setting up remote commands (eg: from homepod, lockscreen, control center, siri, another device, etc)
            // Thank you apple (https://developer.apple.com/videos/play/wwdc2022/110338/?time=214)
            MPRemoteCommandCenter.shared().playCommand.addTarget { event in
                self.play()
                return .success
            }
            
            MPRemoteCommandCenter.shared().pauseCommand.addTarget { event in
                self.pause()
                return .success
            }
            
            MPRemoteCommandCenter.shared().nextTrackCommand.addTarget { event in
                self.nextSong()
                return .success
            }
            
            MPRemoteCommandCenter.shared().previousTrackCommand.addTarget { event in
                self.previousSong()
                return .success
            }
            
            
            session.automaticallyPublishesNowPlayingInfo = true
            // TODO: Fast forward
            
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
        let itemWithMetadata = generateMetadata(forItem: item, withSong: song)
        
        playerItems.append(itemWithMetadata)
        player.insert(itemWithMetadata, after: nil)
        playerItems.append(itemWithMetadata)
        
    }
    
    /// Inserts a song in the queue at the position of that song
    func insert(item: AVPlayerItem, forSong song: Song, index: Int) {
        let items = player.items()
        let songToAppendAfter = items[index]
        songs.insert(song, at: index)
        let itemWithMetadata = generateMetadata(forItem: item, withSong: song)
        
        playerItems.insert(itemWithMetadata, at: index)
        player.insert(itemWithMetadata, after: songToAppendAfter)
        
    }
    
    /// Replaces currently playing and plays it
    func playSong(item: AVPlayerItem, forSong song: Song) {
        Task.detached { [self] in
            songs.insert(song, at: position)
            let itemWithMetadata = generateMetadata(forItem: item, withSong: song)
            
            playerItems.insert(itemWithMetadata, at: position)
            player.replaceCurrentItem(with: itemWithMetadata)
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
        // Nowplaying
        if let item = player.currentItem {
            let infoCenter = MPNowPlayingInfoCenter.default()
            infoCenter.nowPlayingInfo = item.nowPlayingInfo
        }
        
        // Posting internal notification
        let center = NotificationCenter.default
        let notification = Notification(name: Notification.Name("etoileDidStartPlaying"))
        center.post(notification)
    }
    
    fileprivate func generateMetadata(forItem item: AVPlayerItem, withSong song: Song) -> AVPlayerItem {
        var info: [String: Any] = [:]
        if let image = UIImage(data: song.art ?? Data()) {
            let artwork = MPMediaItemArtwork(boundsSize: image.size, requestHandler: { size in
                return image
            })
            info[MPMediaItemPropertyArtwork] = artwork
        }
        info[MPMediaItemPropertyTitle] = song.name
        info[MPMediaItemPropertyArtist] = song.artist
        let newItem = item
        newItem.nowPlayingInfo = info
        return newItem
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
    
    func togglePlayback() {
        if self.isPlaying() {
            pause()
        } else {
            play()
        }
    }
}
