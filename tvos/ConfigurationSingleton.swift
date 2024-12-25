//
//  ConfigurationSingleton.swift
//  EtoileIos
//
//  Created by Juliette Bernheisel on 8/30/24.
//

import Foundation

class ConfigurationSingleton {
    public static let shared = ConfigurationSingleton()
    
    public var player: EtoilePlayer = EtoilePlayer()
}
