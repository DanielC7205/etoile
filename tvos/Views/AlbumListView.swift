//
//  AlbumListView.swift
//  etoile-watch Watch App
//
//  Created by Juliette Bernheisel on 8/27/24.
//

import Foundation
import SwiftUI
import OSLog
import EtoileKit

struct AlbumListView: View {
    
    @Binding var tab: Tabs
    @State
    var albums: [Album] = []
    
    var body: some View {
        
            NavigationView {
                if albums.count == 0 {
                    ProgressView()
                } else {
                    List(albums) {album in
                        NavigationLink(destination: {
                            SongListView(album: album, tab: $tab)
                        }) {
                            AlbumView(album: album)
                                .frame(height: 256)
                        }
                    }
                }
            }
            .task {
                do {
                    let library = EtoileLibrary()
                    var (albums, _) = try await library.reloadNoPull() ?? ([], [:])
                    self.albums = albums
                    Logger().info("Done getting albums")
                } catch {
                    Logger().error("\(#file):\(#line) error getting library \(error)")
                }
            }
        }
}

