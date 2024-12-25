//
//  ContentView.swift
//  tvos
//
//  Created by Juliette Bernheisel on 8/29/24.
//

import SwiftUI

struct ContentView: View {
    
    @State var tab: Tabs = .albums
    @Binding var done: Bool

    
    var body: some View {
        TabView(selection: $tab) {
            Tab("Now Playing", systemImage: "music.note", value: .nowPlaying) {
                NowPlayingView()
            }
            Tab("Albums", systemImage: "square.stack", value: .albums) {
                AlbumListView(tab: $tab)
            }
            Tab("Recents", systemImage: "clock", value: .recents) {
                RecentlyPlayedView(tab: $tab)
            }
            Tab("Search", systemImage: "magnifyingglass", value: .search ) {
                SearchView(tab: $tab)
            }
            Tab("Settings", systemImage: "gear", value: .settings) {
                SettingsView(done: $done)
            }
        }
    }
}

enum Tabs {
    case nowPlaying, albums, recents, settings, search
}

