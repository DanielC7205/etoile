//
//  AlbumInfoView.swift
//  etoile.EtoileIos
//
//  Created by Juliette Bernheisel on 9/5/24.
//

import SwiftUI
import EtoileKit

struct AlbumInfoView: View {
    @State var album: Album
    var body: some View {
        HStack {
            Image(uiImage: (UIImage(data: album.art ?? Data()) ?? UIImage(systemName: "questionmark"))!)
                .resizable()
                .aspectRatio(9 / 9, contentMode: .fit)
            Text(album.name)
        }
    }
}
