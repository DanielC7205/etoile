//
//  RichSongViewCell.swift
//  etoile
//
//  Created by Juliette Bernheisel on 8/31/24.
//

import Foundation
import EtoileKit
import UIKit

class RichSongViewCell: UICollectionViewCell {
    var songView: RichSongView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let songView = RichSongView()
        contentView.addSubview(songView)
        
        songView.snp.makeConstraints { make in
            make.left.equalTo(contentView.snp.left)
            make.right.equalTo(contentView.snp.right)
            make.top.equalTo(contentView.snp.top)
            make.bottom.equalTo(contentView.snp.bottom)
        }
        
        self.songView = songView
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        fatalError("Interface Builder is not supported!")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        fatalError("Interface Builder is not supported!")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        songView.songUnsafe = nil
    }
    
    
}

class RichSongView: UIView {
    var songUnsafe: Song?
    let songNameLabel = UILabel()
    
    func refresh() {
        guard let song = songUnsafe else { return }
        songNameLabel.text = song.name
        songNameLabel.accessibilityLabel = song.name + " richSongSongNameLabel"
        songNameLabel.font = .systemFont(ofSize: 16)
        songNameLabel.adjustsFontSizeToFitWidth = false
        songNameLabel.numberOfLines = 1
        songNameLabel.lineBreakMode = .byTruncatingTail
        songNameLabel.textColor = .etoileTextColor()
        
        self.addSubview(songNameLabel)
                
        if let art = song.art {
            let albumArtImage = UIImageView()
            
            albumArtImage.image = UIImage(data: art)
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
            
            songNameLabel.snp.makeConstraints { make in
                make.top.equalTo(albumArtImage.snp.bottom).offset(10)
                make.width.equalTo(64)
                make.left.equalTo(self)
            }
        } else {
            songNameLabel.snp.makeConstraints { make in
                make.top.equalTo(self)
                make.width.equalTo(64)
                make.left.equalTo(self)
            }
        }
    }
    
}

