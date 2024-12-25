//
//  FullFetchLibraryView.swift
//  etoile
//
//  Created by Juliette Bernheisel on 9/4/24.
//

import SwiftUI
import EtoileKit
import OSLog

struct FullFetchLibraryView: View {
    
    @State var page: FullFetchPage = .albums
    @State var albumName = ""
    var callback: () -> ()
    
    var body: some View {
        VStack {
            Text("One sec as we fetch your library...")
                .foregroundStyle(Color(uiColor: .etoileTextColor()))
            if page == .albums {
                Text("Getting your albums")
                    .foregroundStyle(Color(uiColor: .etoileTextColor()))
                ProgressView()
                    .foregroundStyle(Color(uiColor: .etoileTextColor()))
            } else if page == .songs {
                Text("Getting songs from album: \(albumName)")
                    .foregroundStyle(Color(uiColor: .etoileTextColor()))
                
            } else if page == .done {
                Text("Done!")
                    .foregroundStyle(Color(uiColor: .etoileTextColor()))
                Button(action: {
                    callback()
                }) {
                    Text("Tap me to start using Etoile!")
                        .foregroundStyle(Color(uiColor: .etoileTextColor()))
                        .backgroundStyle(Color(uiColor: .etoileButtonBackground()))
                }
                .accessibilityLabel("done")
            } else if page == .error {
                Text("Error getting your library!")
                    .foregroundStyle(Color(uiColor: .etoileTextColor()))
            }
        }
        .task {
            do {
                let library = EtoileLibrary()
                let (albums, _) = try await library.refresh(deviceName: UIDevice.current.name)
                
                self.page = .songs
                
                for album in albums {
                    self.albumName = album.name
                    try await library.getSongsInAlbum(albumId: album.id, deviceName: UIDevice.current.name)
                }
                
                page = .done
            } catch {
                Logger().error("Error getting library: \(error)")
                page = .error
            }
        }
    }
}

enum FullFetchPage {
    case albums, songs, done, error
}
