//
//  tvosApp.swift
//  tvos
//
//  Created by Juliette Bernheisel on 8/29/24.
//

import SwiftUI
import SimpleKeychain
import EtoileKit
import OSLog
import StoreKit

@main
struct tvosApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State var purchased = false
    @State var done = false
    
    var body: some Scene {
        WindowGroup {
            HStack {
                    if !done {
                        SignInViewController(done: $done)
                    } else {
                        ContentView(done: $done)
                    }
            }
            .onAppear {
                do {
                    let keychain = SimpleKeychain(service: "etoile")
                    let instanceAsString = try keychain.string(forKey: "instance")
                    let token = try keychain.string(forKey: "token")
                    
                    self.done = true
                } catch {
                    Logger().info("Error getting login details")
                }
            }
        }
    }
    
    
}
