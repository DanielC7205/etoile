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
    @State var showDevSheet = false
    
    var body: some Scene {
        WindowGroup {
            HStack {
                    if !done {
                        SignInViewController(done: $done, showDevSheet: $showDevSheet)
                    } else {
                        ContentView(done: $done, showDevSheet: $showDevSheet)
                    }
            }
            .sheet(isPresented: $showDevSheet) {
                DeveloperView()
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
