//
//  File.swift
//  EtoileKit
//
//  Created by Juliette Bernheisel on 8/28/24.
//

import Foundation
import JellyfinAPI

 public struct SignInModel: Sendable {
    public func signIn(deviceName: String, username: String, password: String, instance: URL, callBack: @escaping (String) async -> ()) async throws {
        // Login with jellyfin
        let configuration = JellyfinClient.Configuration(url: instance, client: "Etoile", deviceName: deviceName, deviceID: UUID().uuidString, version: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "ERROR")
        let jellyfinClient = JellyfinClient(configuration: configuration)
        let response = try await jellyfinClient.signIn(username: username, password: password)
        // Checking if we got token
        if let token = response.accessToken {
            // And save to the singleton
            await callBack(token)
        }
    }
    
    public init() {}
}

