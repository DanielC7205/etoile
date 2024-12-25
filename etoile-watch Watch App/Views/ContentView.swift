//
//  ContentView.swift
//  etoile-watch Watch App
//
//  Created by Juliette Bernheisel on 8/28/24.
//

import SwiftUI
import WatchKit

struct ContentView: View {
    @State var tab: Tabs = .albums
    @Binding var done: Bool

    var body: some View {
        if #available(watchOS 11.0, *) {
            TabView(selection: $tab) {
                Tab("Now Playing", systemImage: "music.note", value: .nowPlaying) {
                    JulesNowPlaying()
                }
                Tab("Albums", systemImage: "square.stack", value: .albums) {
                    AlbumListView()
                }
                Tab("Recents", systemImage: "clock", value: .recents) {
                    RecentlyPlayedView(tab: $tab)
                }
                Tab("Playlists", systemImage: "text.line.first.and.arrowtriangle.forward", value: .recents) {
                    PlaylistList()
                }
                Tab("Search", systemImage: "magnifyingglass", value: .search ) {
                    SearchView(tab: $tab)
                }
                Tab("Settings", systemImage: "gear", value: .settings) {
                    SettingsView(done: $done)
                }
            }
        } else {
            NavigationView {
                switch tab {
                case .nowPlaying:
                    ScrollView {
                        Button {
                            tab = .none
                        } label: {
                            Text("Home")
                        }
                        JulesNowPlaying()
                    }
                case .albums:
                    ScrollView {
                        Button {
                            tab = .none
                        } label: {
                            Text("Home")
                        }
                        AlbumListView()
                    }
                case .recents:
                    ScrollView {
                        Button {
                            tab = .none
                        } label: {
                            Text("Home")
                        }
                        RecentlyPlayedView(tab: $tab)
                    }
                case .settings:
                    ScrollView {
                        Button {
                            tab = .none
                        } label: {
                            Text("Home")
                        }
                        
                        SettingsView(done: $done)
                    }
                case .search:
                    ScrollView {
                        Button {
                            tab = .none
                        } label: {
                            Text("Home")
                        }
                        SearchView(tab: $tab)
                    }
                case .none:
                    ScrollView {
                        NavigationLink(destination: JulesNowPlaying()) {
                            Text("Now Playing")
                        }
                        NavigationLink(destination: AlbumListView()) {
                            Text("Albums")
                        }
                        NavigationLink(destination: RecentlyPlayedView(tab: $tab)) {
                            Text("Recents")
                        }
                        NavigationLink(destination: PlaylistList()) {
                            Text("Playlists")
                        }
                        NavigationLink(destination: SearchView(tab: $tab)) {
                            Text("Search")
                        }
                        NavigationLink(destination: SettingsView(done: $done)) {
                            Text("Settings")
                        }
                    }
                }

            }
        }
    }
}


enum Tabs {
    case nowPlaying, albums, recents, settings, search, none
}

