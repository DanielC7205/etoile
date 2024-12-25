//
//  ExternalPlayback.swift
//  EtoileKit
//
//  Created by Juliette Bernheisel on 9/3/24.
//
import EtoileKit

public struct ExternalPlayback: Codable, Sendable {
    public init(isPlaying: Bool, song: Song, deviceName: String, user: String) {
        self.isPlaying = isPlaying
        self.song = song
        self.deviceName = deviceName
        self.user = user
    }
    
    
    public var isPlaying: Bool
    public let song: Song
    public let deviceName: String
    public let user: String
}

public struct ExternalAction: Codable, Sendable {
    public init(next: Bool? = nil, play: Bool? = nil, previous: Bool? = nil, user: String) {
        self.next = next
        self.play = play
        self.previous = previous
        self.user = user
    }
    
    public let next: Bool?
    public let play: Bool?
    public let previous: Bool?
    public let user: String
}
