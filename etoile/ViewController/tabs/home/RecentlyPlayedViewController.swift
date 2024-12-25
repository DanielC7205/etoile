//
//  RecentlyPlayedViewController.swift
//  etoile
//
//  Created by Juliette Bernheisel on 8/31/24.
//

import Foundation
import UIKit
import EtoileKit
import OSLog

class RecentlyPlayedViewController: UIViewController {
    
    weak var collectionView: UICollectionView!
    var songs: [Song] = []
    
    override func loadView() {
        super.loadView()
        
        do {
            let library = EtoileLibrary()
            self.songs = try library.getRecentlyPlayed()
        } catch {
            Logger().error("Error getting recently played \(error)")
        }
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        layout.itemSize = CGSize(width: 64, height: 120)
        layout.minimumLineSpacing = 20
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.top.equalTo(view.snp.top)
            make.bottom.equalTo(view.snp.bottom)
        }
        
        self.collectionView = collectionView
        
        // Update
        let name = NSNotification.Name("etoileUpdateRecentlyPlaying")
        NotificationCenter.default.addObserver(self, selector: #selector(addToRecentlyPlayed), name: name, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(RichSongViewCell.self, forCellWithReuseIdentifier: "SongViewCell")
    }
    
    @objc func addToRecentlyPlayed() {
        Task.detached {
            do {
                let library = EtoileLibrary()
                guard let playing = ConfigurationSingleton.shared.player.playingSong else { return }
                try library.addToRecentlyPlayed(song: playing)
            } catch {
                Logger().error("Error adding to recently played \(error)")
            }
            
            do {
                // Sending to bonjour
                let encoder = JSONEncoder()
                guard let playing = ConfigurationSingleton.shared.player.playingSong else { return }
                let external = await ExternalPlayback(isPlaying: true, song: playing, deviceName: UIDevice.current.name, user: ConfigurationSingleton.shared.username ?? "Unknown user")
                let data = try encoder.encode(external)
                ConfigurationSingleton.shared.bonjour.broadcast(data)
            } catch {
                Logger().error("Error sending now playing info to peers \(error)")
            }
            
            await MainActor.run {
                do {
                    let library = EtoileLibrary()
                    self.songs = try library.getRecentlyPlayed()
                    self.collectionView.reloadData()
                } catch {
                    Logger().error("Error updating recently played view \(error)")
                }
            }
        }
    }
}

extension RecentlyPlayedViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return songs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = songs[indexPath.section]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SongViewCell", for: indexPath as IndexPath) as! RichSongViewCell
        cell.songView.songUnsafe = item
        cell.songView.refresh()
        return cell
    }
}

extension RecentlyPlayedViewController: UICollectionViewDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        Task.detached {
            let playerModel = PlayerModel()
            do {
                try await playerModel.play(song: self.songs[indexPath.section])
            } catch {
                Logger().error("Error playing song: \(self.songs[indexPath.section].name) with id: \(self.songs[indexPath.section].id) because: \(error)")
            }
        }
    }
}
