//
//  PlaylistFullViewController.swift
//  etoile
//
//  Created by Juliette Bernheisel on 9/17/24.
//

import Foundation
import UIKit
import EtoileKit
import OSLog

class PlaylistFullViewController: UIViewController {
    internal init(playlist: Playlist) {
        self.playlist = playlist
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var playlist: Playlist
    var songs: [Song] = []
    
    override func loadView() {
        super.loadView()
        
        // Very un-apple-y but we're making navigation bar transparent
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.tintColor = .etoileTextColor()
        
        // Name label
        let playlistNameLabel = UILabel()
        playlistNameLabel.text = playlist.name
        playlistNameLabel.accessibilityIdentifier = "playlistName"
        playlistNameLabel.font = .systemFont(ofSize: 16)
        playlistNameLabel.textColor = .etoileTextColor()
        playlistNameLabel.numberOfLines = 1
        
        view.addSubview(playlistNameLabel)
                
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
        let songListController = SongListController(playlistOrAlbum: PlaylistOrAlbum(isAlbum: false, id: playlist.id))
        
        view.addSubview(songListController.view)
        addChild(songListController)
        songListController.didMove(toParent: self)
        
        
        // playlist Art
        if let playlistArtData = playlist.art {
            let playlistArtImage = UIImageView()
            let artAsImage = UIImage(data: playlistArtData)
            playlistArtImage.image = artAsImage
            playlistArtImage.layer.cornerRadius = 20
            playlistArtImage.layer.masksToBounds = true
            
            view.addSubview(playlistArtImage)
            
            playlistArtImage.snp.makeConstraints { make in
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
                make.left.equalTo(view).offset(20)
                make.width.equalTo(128)
                make.height.equalTo(128)
            }
            
            playlistNameLabel.snp.makeConstraints { make in
                make.left.equalTo(playlistArtImage.snp.right).offset(20)
                make.centerY.equalTo(playlistArtImage.snp.centerY).offset(-20)
            }
            
            playShuffleHostView.snp.makeConstraints { make in
                make.top.equalTo(playlistArtImage.snp.bottom).offset(20)
                make.left.equalTo(view).offset(20)
                make.right.equalTo(view).offset(-20)
                make.height.equalTo(64)
            }
            
            songListController.view.snp.makeConstraints { make in
                make.top.equalTo(playShuffleHostView.snp.bottom).offset(20)
            }
        } else {
            playlistNameLabel.snp.makeConstraints { make in
                make.left.equalTo(view).offset(20)
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            }
            
            playShuffleHostView.snp.makeConstraints { make in
                make.top.equalTo(playlistNameLabel.snp.bottom).offset(20)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task.detached {
            do {
                let library = EtoileLibrary()
                self.songs = try await library.getSongsFromPlaylist(playlistId: self.playlist.id)
            } catch {
                await MainActor.run {
                    let alert = UIAlertController(title: "Error!", message: "Error getting songs from playlist, \(error)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                        alert.dismiss(animated: true)
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    @objc func didPressPlay() {
        
        Task.detached {
            do {
                let sorted = self.songs.sorted(by: { lhs, rhs in
                    lhs.positionInAlbum < rhs.positionInAlbum
                })
                
                guard let firstSong = sorted.first else { return }
                let songsAfterFirst = Array(sorted[1...])
                
                
                let playerModel = PlayerModel()
                try await playerModel.startPlayingSongsAndAddToQueueWithClearing(song: firstSong, queue: songsAfterFirst)
            } catch {
                Logger().error("\(#file):\(#line) > \(error)")
            }
        }
    }
    
    @objc func didPressShuffle() {
        Task.detached {
            do {
                let sorted = self.songs.shuffled()
                
                guard let firstSong = sorted.first else { return }
                let songsAfterFirst = Array(sorted[1...])
                
                let playerModel = PlayerModel()
                try await playerModel.startPlayingSongsAndAddToQueueWithClearing(song: firstSong, queue: songsAfterFirst)
            } catch {
                Logger().error("\(#file):\(#line) > \(error)")
            }
        }

    }

}
