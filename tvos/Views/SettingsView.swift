//
//  SettingsView.swift
//  etoile.EtoileIos
//
//  Created by Juliette Bernheisel on 8/31/24.
//

import SwiftUI
import EtoileKit
import OSLog

struct SettingsView: View {
    @State var showSheet = false
    @State var showLogoutSheet = false
    @Binding var done: Bool
    @Binding var showDevSheet: Bool
    var body: some View {
        Button(action: {
            showSheet = true
        }) {
            Text("Refreshes albums AND songs from Jellyfin, this will take awhile depending on library size!!")
        }
        .sheet(isPresented: $showSheet) {
            FullFetchLibraryView(callback: {
                
            })
        }
        
        Button {
            showLogoutSheet = true
        } label: {
            Text("Logout")
        }
        .alert(isPresented: $showLogoutSheet) {
            Alert(title: Text("Logout"), message: Text("Are you sure you want to logout?"), primaryButton: .destructive(Text("Logout")) {
                let auth = EtoileAuth()
                do {
                    try auth.logout() // Logout
                    done = false
                } catch {
                    os_log(.error, "Error logging out: %@", error.localizedDescription)
                }
            }, secondaryButton: .cancel())
        }
        
        #if DEBUG
        Button {
            showDevSheet = true
        } label: {
            Image(systemName: "gear")
            Text("Developer Settings")
        }
        #endif
            
    }
}
