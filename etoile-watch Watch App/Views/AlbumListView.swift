//
//  AlbumListView.swift
//  etoile-watch Watch App
//
//  Created by Juliette Bernheisel on 8/27/24.
//

import Foundation
import WatchKit
import SwiftUI
import OSLog
import EtoileKit

struct AlbumListView: View {
    
    @State
    var albums: [Album] = []
    
    var body: some View {
        NavigationView {
            List(albums) {album in
                NavigationLink(destination: {
                    SongListView(album: album)
                }) {
                    AlbumInfoView(album: album)
                }
            }
        }
        .task {
            do {
                let library = EtoileLibrary()
                guard let (albums, _) = try await library.reloadNoPull() else { throw EtoileBasicErrors.noFile }
                self.albums = albums
                Logger().info("Done getting albums")
            } catch {
                Logger().error("\(#file):\(#line) error getting library \(error)")
            }
        }
    }
}

