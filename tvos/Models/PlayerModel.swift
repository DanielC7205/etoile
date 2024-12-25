//
//  PlayerModel.swift
//  etoile
//
//  Created by Juliette Bernheisel on 8/25/24.
//

import Foundation
import JellyfinAPI
import AVFoundation
import OSLog
import EtoileKit
import SimpleKeychain

class PlayerModel {
    
    private var client: JellyfinClient? = nil
    
    public init() {
        let name = NSNotification.Name("etoileDidStartPlaying")
        NotificationCenter.default.addObserver(self, selector: #selector(addToRecentlyPlayed), name: name, object: nil)

    }
    
    @objc func addToRecentlyPlayed() {
        do {
            let library = EtoileLibrary()
            guard let playing = ConfigurationSingleton.shared.player.playingSong else { return }
            try library.addToRecentlyPlayed(song: playing)
        } catch {
            Logger().error("Error adding to recently played \(error)")
        }
    }
    

    private func setupClient() async throws {
        if client == nil {
            let keychain = SimpleKeychain(service: "etoile")
            let instanceAsString = try keychain.string(forKey: "instance")
            guard let instance = URL(string: instanceAsString) else { throw EtoileBasicErrors.whatTheFuck }
            let token = try keychain.string(forKey: "token")
            
            let configuration = JellyfinClient.Configuration(url: instance, client: "Etoile", deviceName: "Tv", deviceID: UUID().uuidString, version: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")
            let jellyfinClient = JellyfinClient(configuration: configuration, accessToken: token)
            self.client = jellyfinClient
        }
    }
    
    func play(song: Song) async throws {
        
        if client == nil {
            try await setupClient()
        }
        
        let songId = song.id

        let parameters = Paths.GetUniversalAudioStreamParameters(container: ["mp3", "flac", "aac"], audioCodec: "aac", maxStreamingBitrate: 999999999, transcodingContainer: "ts", transcodingProtocol: .hls, enableRedirection: true)
        let path = Paths.getUniversalAudioStream(itemID: songId, parameters: parameters)
        guard let fullUrl = client?.fullURL(with: path)?.appending(queryItems: [URLQueryItem(name: "api_key", value: client?.accessToken)]) else { throw EtoileBasicErrors.cantStream}
        
        ConfigurationSingleton.shared.player = EtoilePlayer()

        ConfigurationSingleton.shared.player.playSong(item: AVPlayerItem(url: fullUrl), forSong: song)
        ConfigurationSingleton.shared.player.playingSong = song
        
        // Telling jellyfin we're playing music:)
        let info = PlaybackStartInfo(itemID: songId)
        let pathStart = Paths.reportPlaybackStart(info)
        try await client?.send(pathStart)
        
        // We gotta keep this thread open to continue playing
//        while (true) {
//            // But we don't want to keep this task open if it stops playing
//            if songId != ConfigurationSingleton.shared.player?.playingSong?.id ?? "" {
//                break
//            }
//
//            try await Task.sleep(nanoseconds: 3_000_000_000) // Sleep for ten seconds
//        }
    }
    
    func startPlayingSongsAndAddToQueueWithoutClearing(song: Song, queue: [Song]) async throws {
        try await play(song: song)
        
        for queueSong in queue {
            try await addToQueue(song: queueSong)
        }
    }
    
    func clearQueue() {
        ConfigurationSingleton.shared.player.clearQueue()
    }
    
    func startPlayingSongsAndAddToQueueWithClearing(song: Song, queue: [Song]) async throws {
        clearQueue()
        try await play(song: song)
        
        for queueSong in queue {
            try await addToQueue(song: queueSong)
        }
    }
    
    func addToQueue(song: Song) async throws {
        let songId = song.id
        
        // Setup client
        if client == nil {
            try await setupClient()
        }

        let parameters = Paths.GetUniversalAudioStreamParameters(container: ["mp3", "flac", "aac"], audioCodec: "aac", maxStreamingBitrate: 999999999, transcodingContainer: "ts", transcodingProtocol: .hls, enableRedirection: true)
        let path = Paths.getUniversalAudioStream(itemID: songId, parameters: parameters)
        guard let fullUrl = client?.fullURL(with: path)?.appending(queryItems: [URLQueryItem(name: "api_key", value: client?.accessToken)]) else { throw EtoileBasicErrors.cantStream}

        ConfigurationSingleton.shared.player.appendToQueue(item: AVPlayerItem(url: fullUrl), song: song)
    }
    
    func reportStop(song: Song) {
        Task {
            do {
                // Setup client
                if self.client == nil {
                    try await setupClient()
                }
                                
                // Telling jellyfin we stopped playing music:)
                let info = PlaybackStartInfo(isPaused: true, itemID: song.id)
                let pathStart = Paths.reportPlaybackStart(info)
                try await client?.send(pathStart)
            } catch {
                // Too late to do anything!
                // But we still write to log
                Logger().error("\(#file):\(#line): error reporting playback \(error)")
            }
        }
    }
    
    func reportStartedPlaying(song: Song) {
        Task {
            do {
                // Setup client
                if client == nil {
                    try await setupClient()
                }
                                
                // Telling jellyfin we started playing music:)
                let info = PlaybackStartInfo(isPaused: false, itemID: song.id)
                let pathStart = Paths.reportPlaybackStart(info)
                try await client?.send(pathStart)
            } catch {
                // Too late to do anything!
                // But we still write to log
                Logger().error("\(#file):\(#line): error reporting playback \(error)")
            }
        }
    }
    
    func reportFullStop() {
        Task {
            do {
                // Setup client
                if client == nil {
                    try await setupClient()
                }
                                
                // Telling jellyfin we started playing music:)
                let pathStart = Paths.reportPlaybackStopped()
                try await client?.send(pathStart)
            } catch {
                // Too late to do anything!
                // But we still write to log
                Logger().error("\(#file):\(#line): error reporting playback \(error)")
            }
        }
    }
}
