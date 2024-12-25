//
//  PlayListHomeViewController.swift
//  etoile
//
//  Created by Juliette Bernheisel on 9/17/24.
//

import Foundation
import UIKit
import EtoileKit

class PlayListHomeViewController: UIViewController {
    let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
                
        // Hi label:)
        let hiLabel = UILabel()
        hiLabel.text = "Hi\(HomeViewModel.getUsernameSafely())"
        hiLabel.accessibilityLabel = "hiLabel"
        hiLabel.font = .systemFont(ofSize: 20)
        hiLabel.textColor = .etoileTextColor()
        
        self.view.addSubview(hiLabel)
        
        hiLabel.sizeToFit()
        
        hiLabel.snp.makeConstraints { make in
            make.top.equalTo(self.view).offset(60)
            make.left.equalTo(self.view).offset(20)
        }
        
        // Your albums label
        let yourPlaylistsLabel = UILabel()
        yourPlaylistsLabel.text = "Your playlists"
        yourPlaylistsLabel.accessibilityLabel = "yourPlaylistsLabel"
        yourPlaylistsLabel.font = .systemFont(ofSize: 14)
        yourPlaylistsLabel.textColor = .etoileTextColor()
        
        self.view.addSubview(yourPlaylistsLabel)
        
        yourPlaylistsLabel.sizeToFit()
        
        yourPlaylistsLabel.snp.makeConstraints { make in
            make.top.equalTo(hiLabel.snp.bottom).offset(5)
            make.left.equalTo(hiLabel)
        }

        // Playlist list
        let playListVc = PlaylistListViewController()
        
        self.view.addSubview(playListVc.view)
        self.addChild(playListVc)
        playListVc.didMove(toParent: self)
                
        playListVc.view.snp.makeConstraints { make in
            make.height.equalTo(120) // size of the album view. like the exact right size
            make.width.equalTo(self.view)
            make.top.equalTo(yourPlaylistsLabel.snp.bottom).offset(64)
            make.left.equalTo(self.view).offset(20)
        }
        
    }
    
}
