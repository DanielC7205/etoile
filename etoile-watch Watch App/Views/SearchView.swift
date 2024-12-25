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
        TextField("Search", text: $searchTerm)
            .onSubmit {
                items = []
                do {
                    let library = EtoileLibrary()
                    let (albums, songs) = try library.reloadNoPull() ?? ([], [:])
                    
                    for album in albums {
                        if album.name.lowercased().contains(searchTerm.lowercased()) {
                            items.append(MixedSongAndAlbum(id: album.id, name: album.name, artist: album.artist, isSong: false))
                        }
                        for song in songs[album.id] ?? [] {
                            if song.name.lowercased().contains(searchTerm.lowercased()) {
                                items.append(MixedSongAndAlbum(id: song.id, name: song.name, artist: song.artist, art: song.art, isSong: true))
                            }
                        }
                    }
                } catch {
                    didError = true
                    Logger().error("Error getting library for search, \(error)")
                }

            }
        ScrollView(.vertical) {
            if items.count == 0 {
                Text("No results")
            } else {
                ForEach($items) { asset in
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
                        AlbumInfoView(album: Album(name: asset.wrappedValue.name, artist: asset.wrappedValue.artist, art: asset.wrappedValue.art, id: asset.wrappedValue.id))
                    }
                    .sheet(isPresented: $showSheet) {
                            SongListView(album:  Album(name: asset.wrappedValue.name, artist: asset.wrappedValue.artist, art: asset.wrappedValue.art, id: asset.wrappedValue.id))
                    }
                }

                
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
