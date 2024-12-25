//
//  etoile_watchApp.swift
//  etoile-watch Watch App
//
//  Created by Juliette Bernheisel on 8/28/24.
//

import SwiftUI
import SimpleKeychain
import OSLog
import StoreKit

@main
struct etoile_watch_Watch_AppApp: App {
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
