//
//  SongView.swift
//  etoile
//
//  Created by Juliette Bernheisel on 8/24/24.
//

import Foundation
import UIKit
import EtoileKit

class SongViewCell: UICollectionViewCell {
    var songView: SongView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let songView = SongView()
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

class SongView: UIView {
    var songUnsafe: Song?
    let songNameLabel = UILabel()
    
    func refresh() {
        guard let song = songUnsafe else { return }
        songNameLabel.text = song.name
        songNameLabel.accessibilityLabel = song.name + " songViewSongNameLabel"
        songNameLabel.font = .systemFont(ofSize: 16)
        songNameLabel.textColor = .etoileTextColor()
        
        self.addSubview(songNameLabel)
        
        songNameLabel.sizeToFit()
        songNameLabel.numberOfLines = 1
        
            
            songNameLabel.snp.makeConstraints { make in
                make.top.equalTo(self)
                make.left.equalTo(self)
            }

    }
    
}

