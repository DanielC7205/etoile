//
//  AlbumInfoViewController.swift
//  etoile
//
//  Created by Juliette Bernheisel on 8/25/24.
//

import Foundation
import UIKit
import EtoileKit
import OSLog

class AlbumInfoViewController: UIViewController {
    internal init(album: Album) {
        self.album = album
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var album: Album
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Very un-apple-y but we're making navigation bar transparent
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.tintColor = .etoileTextColor()
        
        // Name label
        let albumNameLabel = UILabel()
        albumNameLabel.text = album.name
        albumNameLabel.accessibilityIdentifier = "albumName"
        albumNameLabel.font = .systemFont(ofSize: 16)
        albumNameLabel.textColor = .etoileTextColor()
        albumNameLabel.numberOfLines = 1
        
        view.addSubview(albumNameLabel)
        
        // Artist label
        let artistNameLabel = UILabel()
        artistNameLabel.text = album.artist
        artistNameLabel.font = .systemFont(ofSize: 16)
        artistNameLabel.textColor = .etoileTextColor()
        
        view.addSubview(artistNameLabel)
        
        // Play / shuffle host
        let playShuffleHostView = UIView()
        
        view.addSubview(playShuffleHostView)
        
        // Play button
        let playButton = UIButton()
        playButton.setImage(UIImage(systemName: "play"), for: .normal)
        playButton.setTitle("Play", for: .normal)
        playButton.tintColor = .etoileTextColor()
        playButton.addTarget(self, action: #selector(didPressPlay), for: .touchUpInside)
        
        playShuffleHostView.addSubview(playButton)
        
        playButton.sizeToFit()
        playButton.snp.makeConstraints { make in
            make.left.equalTo(playShuffleHostView)
            make.height.equalTo(playShuffleHostView)
        }
        
        // Shuffle button
        let shuffleButton = UIButton()
        shuffleButton.setImage(UIImage(systemName: "shuffle"), for: .normal)
        shuffleButton.setTitle("Shuffle", for: .normal)
        shuffleButton.tintColor = .etoileTextColor()
        shuffleButton.addTarget(self, action: #selector(didPressShuffle), for: .touchUpInside)
        
        playShuffleHostView.addSubview(shuffleButton)
        
        shuffleButton.sizeToFit()
        shuffleButton.snp.makeConstraints { make in
            make.right.equalTo(playShuffleHostView)
            make.height.equalTo(playShuffleHostView)
        }
        
        
        // Songs list
        let songListController = SongListController(playlistOrAlbum: PlaylistOrAlbum(isAlbum: true, id: album.id))
        
        view.addSubview(songListController.view)
        addChild(songListController)
        songListController.didMove(toParent: self)
        
        
        // Album Art
        if let albumArtData = album.art {
            let albumArtImage = UIImageView()
            let artAsImage = UIImage(data: albumArtData)
            albumArtImage.image = artAsImage
            albumArtImage.layer.cornerRadius = 20
            albumArtImage.layer.masksToBounds = true
            
            view.addSubview(albumArtImage)
            
            albumArtImage.snp.makeConstraints { make in
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
                make.left.equalTo(view).offset(20)
                make.width.equalTo(128)
                make.height.equalTo(128)
            }
            
            albumNameLabel.snp.makeConstraints { make in
                make.left.equalTo(albumArtImage.snp.right).offset(20)
                make.centerY.equalTo(albumArtImage.snp.centerY).offset(-20)
            }
            
            artistNameLabel.snp.makeConstraints { make in
                make.left.equalTo(albumArtImage.snp.right).offset(20)
                make.centerY.equalTo(albumArtImage.snp.centerY).offset(20)
            }
            
            playShuffleHostView.snp.makeConstraints { make in
                make.top.equalTo(albumArtImage.snp.bottom).offset(20)
                make.left.equalTo(view).offset(20)
                make.right.equalTo(view).offset(-20)
                make.height.equalTo(64)
            }
            
            songListController.view.snp.makeConstraints { make in
                make.top.equalTo(playShuffleHostView.snp.bottom).offset(20)
            }
        } else {
            albumNameLabel.snp.makeConstraints { make in
                make.left.equalTo(view).offset(20)
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            }
            
            artistNameLabel.snp.makeConstraints { make in
                make.left.equalTo(view).offset(20)
                make.top.equalTo(albumNameLabel.snp.bottom).offset(20)
            }
            
            playShuffleHostView.snp.makeConstraints { make in
                make.top.equalTo(artistNameLabel.snp.bottom).offset(20)
                make.left.equalTo(view).offset(20)
                make.right.equalTo(view).offset(-20)
                make.height.equalTo(64)
            }
            
            songListController.view.snp.makeConstraints { make in
                make.top.equalTo(playShuffleHostView.snp.bottom).offset(20)
            }
        }
        
        songListController.view.snp.makeConstraints { make in
            make.left.equalTo(view).offset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.right.equalTo(view)
        }
    }
    
    @objc func didPressPlay() {
        Task.detached { [self] in
            do {
                let library = EtoileLibrary()
                let (_, songsForAllAlbums) = try library.reloadNoPull() ?? ([], [:])
                var songsTmp = await songsForAllAlbums[album.id]
                if songsTmp == nil || songsTmp == [] {
                    songsTmp = try await library.getSongsInAlbum(albumId: album.id, deviceName: UIDevice.current.name)
                }
                let sorted = songsTmp?.sorted(by: { lhs, rhs in
                    lhs.positionInAlbum < rhs.positionInAlbum
                })
                
                guard let firstSong = sorted?.first else { return }
                guard let songsAfterFirst = sorted?[1...] else { return }
                
                
                let playerModel = PlayerModel()
                try await playerModel.startPlayingSongsAndAddToQueueWithClearing(song: firstSong, queue: Array(songsAfterFirst))
            } catch {
                Logger().error("\(#file):\(#line) > \(error)")
            }
        }
    }
    
    @objc func didPressShuffle() {
        Task.detached { [self] in
            do {
                let library = EtoileLibrary()
                let (_, songsForAllAlbums) = try library.reloadNoPull() ?? ([], [:])
                var songsTmp = await songsForAllAlbums[album.id]
                if songsTmp == nil || songsTmp == [] {
                    songsTmp = try await library.getSongsInAlbum(albumId: album.id, deviceName: UIDevice.current.name)
                }
                let sorted = songsTmp?.shuffled()
                
                guard let firstSong = sorted?.first else { return }
                guard let songsAfterFirst = sorted?[1...] else { return }
                
                
                let playerModel = PlayerModel()
                try await playerModel.startPlayingSongsAndAddToQueueWithClearing(song: firstSong, queue: Array(songsAfterFirst))
            } catch {
                Logger().error("\(#file):\(#line) > \(error)")
            }
        }
    }
}
