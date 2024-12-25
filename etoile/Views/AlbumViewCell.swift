//
//  AlbumViewCell.swift
//  etoile
//
//  Created by Juliette Bernheisel on 8/25/24.
//

import Foundation
import UIKit

class AlbumViewCell: UICollectionViewCell {
    var albumView: AlbumView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        let albumView = AlbumView()
        contentView.addSubview(albumView)
        
        albumView.snp.makeConstraints { make in
            make.left.equalTo(contentView.snp.left)
            make.right.equalTo(contentView.snp.right)
            make.top.equalTo(contentView.snp.top)
            make.bottom.equalTo(contentView.snp.bottom)
        }
        
        self.albumView = albumView
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

        albumView.album = nil
    }
}
