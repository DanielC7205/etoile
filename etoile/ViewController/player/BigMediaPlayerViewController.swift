//
//  BigMediaPlayerViewController.swift
//  etoile
//
//  Created by Juliette Bernheisel on 8/26/24.
//

import Foundation
import UIKit
import EtoileKit
import SwiftUI

class BigMediaPlayerViewController: UIViewController {
    private var song: Song? = nil
    
    var albumArtView = UIImageView()
    var songNameLabel = UILabel()
    var artistNameLabel = UILabel()
    var playbackLocationLabel = UILabel()
    let mediaControls = MediaControlsViewController()
    let queueButton = UIButton()
    let lyricsButton = UIButton()
    let queueViewController = SongsQueuedViewController()
    var externalData: ExternalPlayback? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .etoileBackground()
        
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(didStartPlaying), name: Notification.Name("etoileDidStartPlaying"), object: nil)
        center.addObserver(self, selector: #selector(externalDidStartPlaying), name: Notification.Name("etoileDidExternalStartPlaying"), object: nil)
        
        albumArtView.layer.cornerRadius = 50
        albumArtView.layer.masksToBounds = true
        
        view.addSubview(albumArtView)
        
        albumArtView.snp.makeConstraints { make in
            make.height.equalTo(view.snp.width).offset(-40)
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).offset(-20)
            make.top.equalTo(view).offset(100)
        }
        
        songNameLabel.font = .systemFont(ofSize: 20)
        songNameLabel.textColor = .etoileTextColor()
        
        view.addSubview(songNameLabel)
        
        songNameLabel.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(albumArtView.snp.bottom).offset(40)
        }
        
        artistNameLabel.font = .systemFont(ofSize: 20)
        artistNameLabel.textColor = .etoileSecondaryTextColor()
        
        view.addSubview(artistNameLabel)
        
        artistNameLabel.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(songNameLabel.snp.bottom).offset(10)
        }
        
        view.addSubview(mediaControls.view)
        addChild(mediaControls)
        mediaControls.didMove(toParent: self)
        
        mediaControls.view.snp.makeConstraints { make in
            make.top.equalTo(artistNameLabel).offset(10)
            make.centerX.equalTo(view)
            make.width.equalTo(view)
            make.height.equalTo(128)
        }
        
        let secondRow = UIView()
        
        let queueImage = UIImage(systemName: "text.line.first.and.arrowtriangle.forward")
        queueButton.setImage(queueImage, for: .normal)
        queueButton.addTarget(self, action: #selector(didTapQueue), for: .touchUpInside)
        
        secondRow.addSubview(queueButton)
        
        queueButton.snp.makeConstraints { make in
            make.top.equalTo(secondRow)
            make.left.equalTo(secondRow).offset(20)
            make.width.equalTo(32)
            make.height.equalTo(32)
        }
        
        let lyricsImage = UIImage(systemName: "music.microphone")
        lyricsButton.setImage(lyricsImage, for: .normal)
        lyricsButton.addTarget(self, action: #selector(didPressLyricsButton), for: .touchUpInside)
        
        secondRow.addSubview(lyricsButton)
        
        lyricsButton.snp.makeConstraints { make in
            make.top.equalTo(secondRow)
            make.right.equalTo(secondRow).offset(-20)
            make.width.equalTo(32)
            make.height.equalTo(32)
        }
        
        view.addSubview(secondRow)
        
        secondRow.snp.makeConstraints { make in
            make.top.equalTo(mediaControls.view.snp.bottom).offset(10)
            make.centerX.equalTo(view)
            make.width.equalTo(view)
            make.height.equalTo(32)
        }
        
        view.addSubview(playbackLocationLabel)
        playbackLocationLabel.textColor = .etoileTextColor()
        
        playbackLocationLabel.snp.makeConstraints { make in
            make.top.equalTo(view)
            make.left.equalTo(albumArtView)
        }
        
        updateUI()
    }
    
    @objc func externalDidStartPlaying(_ notification: NSNotification) {
        Task.detached {
            ConfigurationSingleton.shared.player.clearQueue()
            guard let external = notification.object as? ExternalPlayback else { return }
            await MainActor.run {
                self.externalData = external
                self.updateUI()
            }
        }
    }
    
    
    @objc func didPressLyricsButton() {
        let hostingVc = UIHostingController(rootView: LyricsView())
        hostingVc.view.backgroundColor = .clear
        present(hostingVc, animated: true)
    }
    
    @objc func didStartPlaying() {
        Task.detached {
            await MainActor.run {
                self.updateUI()
            }
        }
    }
    
    private func updateUI() {
        if let song = ConfigurationSingleton.shared.player.playingSong {
            
            if let art = song.art {
                let image = UIImage(data: art)
                albumArtView.image = image
            }
            
            songNameLabel.text = song.name
            artistNameLabel.text = song.artist
        } else {
            guard let song = externalData?.song else { return }
            if let art = song.art {
                let image = UIImage(data: art)
                albumArtView.image = image
            }
            
            songNameLabel.text = song.name
            artistNameLabel.text = song.artist
            
            playbackLocationLabel.text = externalData?.deviceName ?? "Unknown device"
            playbackLocationLabel.sizeToFit()
        }
    }
    
    @objc private func didTapQueue() {
        present(queueViewController, animated: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(Notification.Name("etoileDidStartPlaying"))
    }
}
