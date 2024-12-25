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
    @Binding var done: Bool

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
            done = false
        } label: {
            Text("Logout")
        }
    }
}
