//
//  PlaylistAdderView.swift
//  etoile
//
//  Created by Juliette Bernheisel on 9/18/24.
//

import SwiftUI
import EtoileKit
import OSLog

struct PlaylistAdderView: View {
    var song: Song
    @Environment(\.presentationMode) var presentationMode
    @State var playlists: [Playlist] = []
    @State var isError = false
    @State var showAdd = false
    @State var playlistName = ""
    
    var body: some View {
        VStack {
            Text("Add to playlist")
                .foregroundStyle(Color(uiColor: .etoileTextColor()))
                .font(.title)
            Button("Create a playlist") {
                showAdd.toggle()
            }
            .alert("Playlist name", isPresented: $showAdd, actions: {
                TextField("Playlist Name", text: $playlistName)
                Button {
                    Task.detached {
                        do {
                            let library = EtoileLibrary()
                            self.playlists = try await library.createPlaylist(name: playlistName)
                            self.showAdd = false
                        } catch {
                            Logger().error("\(#file):\(#line) > \(error)")
                            await MainActor.run {
                                self.isError = true
                            }
                        }
                    }
                } label: {
                    Text("Submit")
                }
            })
            List($playlists) { playlist in
                Button {
                    Task.detached {
                        do {
                            let library = EtoileLibrary()
                            try await library.addSongToPlaylist(playlist: playlist.wrappedValue, song: song)
                            await MainActor.run {
                                presentationMode.wrappedValue.dismiss()
                            }
                        } catch {
                            Logger().error("\(#file):\(#line) > \(error)")
                            await MainActor.run {
                                self.isError = true
                            }
                        }
                    }
                } label: {
                    HStack {
                        if let art = playlist.wrappedValue.art {
                            Image(uiImage: UIImage(data: art)!)
                                .resizable()
                                .aspectRatio(9 / 9, contentMode: .fit)
                        }
                        Text(playlist.wrappedValue.name)
                            .tint(Color(uiColor: UIColor.etoileTextColor()))
                    }
                }
                .listRowBackground(Color(uiColor: UIColor.etoileBackground()))
            }
            .scrollContentBackground(.hidden)
        }
        .onAppear {
            do {
                let library = EtoileLibrary()
                self.playlists = try library.reloadNoPullPlaylist() ?? []
            } catch {
                self.isError = true
                Logger().error("\(#file):\(#line) > \(error)")
            }
        }
        .alert("Error", isPresented: $isError, actions: {
            Button("Ok") {
                isError = false
            }
        })
    }
}
