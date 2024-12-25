//
//  SearchView.swift
//  etoile.EtoileIos
//
//  Created by Juliette Bernheisel on 9/5/24.
//

import SwiftUI
import EtoileKit
import OSLog

struct SearchView: View {
    @Binding var tab: Tabs
    @State var searchTerm = ""
    @State var didError = false
    @State var items: [MixedSongAndAlbum] = []
    @State var showSheet = false
    @State var albumToShow: Album? = nil
    
    var body: some View {
        if didError == true {
            Text("Error grabbing library")
        }
        ScrollView(.vertical) {
            LazyVGrid(
                columns: Array(repeating: .init(.flexible(), spacing: 40), count: 4),
                spacing: 40
            ) {
                ForEach($items.filter({
                    if searchTerm == "" {
                        return true
                    } else {
                        return $0.wrappedValue.name.lowercased().contains(searchTerm.lowercased())
                    }
                })) { asset in
                    Button {
                        albumToShow = Album(name: asset.wrappedValue.name, artist: asset.wrappedValue.artist, art: asset.wrappedValue.art, id: asset.wrappedValue.id)
                        if asset.wrappedValue.isSong {
                            Task {
                                do {
                                    let player = PlayerModel()
                                    try await player.play(song: Song(name: asset.wrappedValue.name, artist: asset.wrappedValue.artist, id: asset.wrappedValue.id, art: asset.wrappedValue.art, positionInAlbum: -1))
                                    await MainActor.run {
                                        self.tab = .nowPlaying
                                    }
                                } catch {
                                    Logger().error("\(#file):\(#line) error playing: \(error)")
                                }
                            }
                        } else {
                            showSheet = true
                        }
                    } label: {
                        AlbumView(album: Album(name: asset.wrappedValue.name, artist: asset.wrappedValue.artist, art: asset.wrappedValue.art, id: asset.wrappedValue.id))
                    }
                    .sheet(isPresented: $showSheet) {
                            SongListView(album:  Album(name: asset.wrappedValue.name, artist: asset.wrappedValue.artist, art: asset.wrappedValue.art, id: asset.wrappedValue.id), tab: $tab)
                    }
                }
            }
            
        }
        .buttonStyle(.plain)
        .scrollClipDisabled()
        .searchable(text: $searchTerm)
        .searchSuggestions {
            ForEach(items.filter({
                $0.name.lowercased().contains(searchTerm.lowercased())
            }), id: \.id) { suggestion in
                Text(suggestion.name)
            }
        }
        .task {
            do {
                let library = EtoileLibrary()
                let (albums, songs) = try library.reloadNoPull() ?? ([], [:])
                
                for album in albums {
                    items.append(MixedSongAndAlbum(id: album.id, name: album.name, artist: album.artist, art: album.art, isSong: false))
                    for song in songs[album.id] ?? [] {
                        items.append(MixedSongAndAlbum(id: song.id, name: song.name, artist: song.artist, art: song.art, isSong: true))
                    }
                }
            } catch {
                didError = true
                Logger().error("Error getting library for search, \(error)")
            }
        }
    }
    
}

struct MixedSongAndAlbum: Identifiable, Hashable {
    var id: String
    var name: String
    var artist: String
    var art: Data?
    var isSong: Bool
}
