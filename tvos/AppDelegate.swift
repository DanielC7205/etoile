//
//  AppDelegate.swift
//  etoile.EtoileIos
//
//  Created by Juliette Bernheisel on 9/5/24.
//

import Foundation
import UIKit
import SimpleKeychain

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Override point for customization after application launch.
        if CommandLine.arguments.contains("--uitesting-reset") {
            do {
                let keychain = SimpleKeychain(service: "etoile")
                try keychain.deleteAll()
            } catch {
                print("UNABLE TO CLEAR SETTINGS")
            }
        }
        return true
    }
}
