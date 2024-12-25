//
//  AlbumView.swift
//  etoile
//
//  Created by Juliette Bernheisel on 8/23/24.
//

import Foundation
import UIKit
import EtoileKit

class AlbumView: UIView {
    
    // Since we call refresh multiple times we MUST have the ui definitions here!!!!!!
    var album: Album? = nil
    let albumArtImage = UIImageView()
    let albumNameLabel = UILabel()
    let artistNameLabel = UILabel()

    func refresh() {
        guard let albumSafe = album else { return }
        albumNameLabel.text = albumSafe.name
        albumNameLabel.accessibilityLabel = "albumNameLabel"
        albumNameLabel.font = .systemFont(ofSize: 16)
        albumNameLabel.textColor = .etoileTextColor()
        
        self.addSubview(albumNameLabel)
        
        albumNameLabel.sizeToFit()
        albumNameLabel.numberOfLines = 1
        
        if let albumArtUrlSafe = albumSafe.art {
            albumArtImage.image = UIImage(data: albumArtUrlSafe)
            albumArtImage.layer.cornerRadius = 10
            albumArtImage.layer.masksToBounds = true
            albumArtImage.accessibilityLabel = "albumArtImage"
            
            self.addSubview(albumArtImage)
            
            albumArtImage.snp.makeConstraints { make in
                make.width.equalTo(64)
                make.height.equalTo(64)
                make.top.equalTo(self)
                make.left.equalTo(self)
            }
            
            albumNameLabel.snp.makeConstraints { make in
                make.top.equalTo(albumArtImage.snp.bottom).offset(10)
                make.width.equalTo(64)
                make.left.equalTo(self)
            }
        } else {
            albumNameLabel.snp.makeConstraints { make in
                make.top.equalTo(self)
                make.left.equalTo(self)
            }
        }
        
        artistNameLabel.text = albumSafe.artist
        artistNameLabel.accessibilityLabel = "artistNameLabel"
        artistNameLabel.font = .systemFont(ofSize: 16)
        artistNameLabel.textColor = .etoileTextColor().withAlphaComponent(0.50)
        artistNameLabel.numberOfLines = 1
        
        
        self.addSubview(artistNameLabel)
        
        artistNameLabel.sizeToFit()
        
        artistNameLabel.snp.makeConstraints { make in
            make.top.equalTo(albumNameLabel.snp.bottom).offset(5)
            make.width.equalTo(64)
            make.left.equalTo(self)
        }
    }
}
