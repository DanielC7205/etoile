//
//  MediaControlsViewController.swift
//  etoile
//
//  Created by Juliette Bernheisel on 8/26/24.
//

import Foundation
import UIKit
import OSLog
import EtoileKit

class MediaControlsViewController: UIViewController {
    
    var previousImageButton: UIButton? = nil
    var playingImageButton: UIButton? = nil
    var nextImageButton: UIButton? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Previous
        let previousImage = UIImage(systemName: "backward")
        let previousTapped = UIImage(systemName: "backward.fill")
        
        previousImageButton = UIButton()
        previousImageButton?.setImage(previousImage, for: .normal)
        previousImageButton?.setImage(previousTapped, for: .highlighted)
        previousImageButton?.addTarget(self, action: #selector(previousButtonTapped), for: .touchUpInside)
        
        view.addSubview(previousImageButton!)
        
        previousImageButton?.snp.makeConstraints { make in
            make.height.equalTo(view.snp.height)
            make.width.equalTo(view.snp.height)
            make.left.equalTo(view)
            make.top.equalTo(view)
        }
        
        // Playing
        var playingImage = UIImage(systemName: "questionmark")
        
        if ConfigurationSingleton.shared.player.isPlaying() {
            playingImage = UIImage(systemName: "play")
            playingImageButton?.setImage(playingImage, for: .normal)
        } else {
            playingImage = UIImage(systemName: "pause")
            playingImageButton?.setImage(playingImage, for: .normal)
        }
        
        playingImageButton = UIButton()
        playingImageButton?.addTarget(self, action: #selector(playingButtonTapped), for: .touchUpInside)
        
        view.addSubview(playingImageButton!)
        
        playingImageButton?.snp.makeConstraints { make in
            make.height.equalTo(view.snp.height)
            make.width.equalTo(view.snp.height)
            make.left.equalTo(previousImageButton!.snp.right).offset(5)
            make.top.equalTo(view)
        }
        
        // Next
        let nextImage = UIImage(systemName: "forward")
        nextImageButton = UIButton()
        nextImageButton?.setImage(nextImage, for: .normal)
        nextImageButton?.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        
        view.addSubview(nextImageButton!)
        
        nextImageButton!.snp.makeConstraints { make in
            make.height.equalTo(view.snp.height)
            make.width.equalTo(view.snp.height)
            make.left.equalTo(playingImageButton!.snp.right).offset(5)
            make.top.equalTo(view)
        }
        
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(didStartPlaying), name: Notification.Name("etoileDidStartPlaying"), object: nil)
        
        center.addObserver(self, selector: #selector(didStartPlaying), name: Notification.Name("etoileDidExternalStartPlaying"), object: nil)

        
        if ConfigurationSingleton.shared.player.isPlaying() {
            let pauseImage = UIImage(systemName: "pause")
            playingImageButton?.setImage(pauseImage, for: .normal)
        } else if ConfigurationSingleton.shared.externalData?.isPlaying ?? false {
            let pauseImage = UIImage(systemName: "pause")
            playingImageButton?.setImage(pauseImage, for: .normal)
        }
    }
    
    @objc func didStartPlaying() {
        Task.detached {
            await MainActor.run {
                let pauseImage = UIImage(systemName: "pause")
                self.playingImageButton?.setImage(pauseImage, for: .normal)
            }
        }
    }
    
    @objc func previousButtonTapped() {
        if ConfigurationSingleton.shared.externalData != nil {
            do {
                let action = ExternalAction(previous: true, user: ConfigurationSingleton.shared.username ?? "Unknown user")
                let encoder = JSONEncoder()
                let data = try encoder.encode(action)
                ConfigurationSingleton.shared.bonjour.broadcast(data)
            } catch {
                Logger().error("Error sending previous \(error)")
            }
        } else {
            ConfigurationSingleton.shared.player.previousSong()
        }
    }
    
    // Playing Button Tapped calls stoppedPlaying()
    @objc func playingButtonTapped() {
        if ConfigurationSingleton.shared.externalData != nil {
            do {
                ConfigurationSingleton.shared.externalData?.isPlaying.toggle()
                let action = ExternalAction(play: ConfigurationSingleton.shared.externalData?.isPlaying ?? false, user: ConfigurationSingleton.shared.username ?? "Unknown user")
                let encoder = JSONEncoder()
                let data = try encoder.encode(action)
                ConfigurationSingleton.shared.bonjour.broadcast(data)
            } catch {
                Logger().error("Error sending previous \(error)")
            }
        } else {
            let playerModel = PlayerModel()
            if ConfigurationSingleton.shared.player.isPlaying() {
                // Pause
                ConfigurationSingleton.shared.player.pause()
                // Report
                if let song = ConfigurationSingleton.shared.player.playingSong {
                    playerModel.reportStartedPlaying(song: song)
                }
                let pauseImage = UIImage(systemName: "play")
                playingImageButton?.setImage(pauseImage, for: .normal)
            } else {
                // Play
                ConfigurationSingleton.shared.player.play()
                // Report
                if let song = ConfigurationSingleton.shared.player.playingSong {
                    playerModel.reportStop(song: song)
                }
                // UI
                let pauseImage = UIImage(systemName: "pause")
                playingImageButton?.setImage(pauseImage, for: .normal)
            }
        }

    }
    
    @objc func nextButtonTapped() {
        if ConfigurationSingleton.shared.externalData != nil {
            do {
                let action = ExternalAction(next: true, user: ConfigurationSingleton.shared.username ?? "Unknown user")
                let encoder = JSONEncoder()
                let data = try encoder.encode(action)
                ConfigurationSingleton.shared.bonjour.broadcast(data)
            } catch {
                Logger().error("Error sending next \(error)")
            }
        } else {
            ConfigurationSingleton.shared.player.nextSong()
        }
    }
}
