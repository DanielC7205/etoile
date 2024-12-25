//
//  ConfigurationSingleton.swift
//  EtoileIos
//
//  Created by Juliette Bernheisel on 8/30/24.
//

import Foundation
import Bonjour
import UIKit
import EtoileKit

class ConfigurationSingleton {
    public static let shared = ConfigurationSingleton()
    
    public var player: EtoilePlayer = EtoilePlayer()
    public var bonjour: BonjourSession = BonjourSession(configuration: .init(serviceType: "etoileplayback", peerName: UIDevice.current.name, defaults: UserDefaults.standard, security: .default, invitation: .automatic))
    public var username: String? = nil
    public var externalData: ExternalPlayback? = nil
    public var backgroundColors: [UIColor] = []
}
