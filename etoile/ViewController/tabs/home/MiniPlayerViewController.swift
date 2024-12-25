//
//  MiniPlayerViewController.swift
//  etoile
//
//  Created by Juliette Bernheisel on 8/26/24.
//

import Foundation
import UIKit
import EtoileKit
import OSLog

// TODO: add this as a subview for navigation view
class MiniPlayerViewController: UIViewController {
    let songNameLabel = UILabel()
    let albumArtImageView = UIImageView()
    var playbackLocationLabel = UILabel()
    var externalData: ExternalPlayback? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Background and outline
        view.backgroundColor = .clear
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.etoileTextColor().cgColor
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        
        // Album art
        albumArtImageView.layer.cornerRadius = 10
        albumArtImageView.layer.masksToBounds = true
        
        view.addSubview(albumArtImageView)
        
        albumArtImageView.snp.makeConstraints { make in
            make.left.equalTo(view).offset(20)
            make.top.equalTo(view).offset(20)
            make.centerY.equalTo(view)
            make.width.equalTo(view.snp.height).offset(-40)
        }
        
        songNameLabel.accessibilityIdentifier = "miniPlayerSongNameLabel"
        songNameLabel.font = .systemFont(ofSize: 16)
        songNameLabel.textColor = .etoileTextColor()
        
        view.addSubview(songNameLabel)
        
        songNameLabel.snp.makeConstraints { make in
            make.left.equalTo(albumArtImageView.snp.right).offset(10)
            make.centerY.equalTo(view)
        }
        
        updateUI()

        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(didStartPlaying), name: Notification.Name("etoileDidStartPlaying"), object: nil)
        center.addObserver(self, selector: #selector(externalDidStartPlaying), name: Notification.Name("etoileDidExternalStartPlaying"), object: nil)

        // Media controls
        let mediaControls = MediaControlsViewController()
        
        view.addSubview(mediaControls.view)
        addChild(mediaControls)
        mediaControls.didMove(toParent: self)
        
        mediaControls.view.snp.makeConstraints { make in
            make.right.equalTo(view.snp.right).offset(20)
            make.centerY.equalTo(view)
            make.left.equalTo(songNameLabel.snp.right).offset(5)
        }
        
        let gestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(tapped))
        gestureRecognizer.direction = .up
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(gestureRecognizer)
        
        view.addSubview(playbackLocationLabel)
        playbackLocationLabel.textColor = .etoileTextColor()
        
        playbackLocationLabel.snp.makeConstraints { make in
            make.top.equalTo(view)
            make.left.equalTo(albumArtImageView)
        }

    }
    
    @objc func didStartPlaying() {
        Task.detached {
            await MainActor.run {
                self.updateUI()
            }
        }
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
    
    func updateUI() {        
        if let song = ConfigurationSingleton.shared.player.playingSong {
            
            if let art = song.art {
                let image = UIImage(data: art)
                albumArtImageView.image = image
            }
            
            songNameLabel.text = song.name
            playbackLocationLabel.text = ""
        } else {
            guard let song = externalData?.song else { return }
            if let art = song.art {
                let image = UIImage(data: art)
                albumArtImageView.image = image
            }
            
            songNameLabel.text = song.name
            
            playbackLocationLabel.text = externalData?.deviceName ?? "Unknown device"
            playbackLocationLabel.sizeToFit()
        }

    }
    
    @objc private func tapped() {
        let big = BigMediaPlayerViewController()
        
        present(big, animated: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(Notification.Name("etoileDidStartPlaying"))
    }
}
