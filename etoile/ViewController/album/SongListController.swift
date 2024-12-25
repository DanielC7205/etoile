//
//  SongListController.swift
//  etoile
//
//  Created by Juliette Bernheisel on 8/25/24.
//

import Foundation
import UIKit
import OSLog
import EtoileKit
import SwiftUI

class SongListController: UIViewController {
    
    let tableView = UITableView()
    
    init(songs: [Song] = [], playlistOrAlbum: PlaylistOrAlbum) {
        self.songs = songs
        self.playlistOrAlbum = playlistOrAlbum
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var songs: [Song] = []
    var playlistOrAlbum: PlaylistOrAlbum
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.top.equalTo(view.snp.top)
            make.bottom.equalTo(view.snp.bottom)
        }

        
        tableView.backgroundColor = .clear
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "songCell")
        tableView.dataSource = self
        tableView.delegate = self
        
        reloadData()
    }
    
    func reloadData() {
        Task.detached {
            do {
                if self.playlistOrAlbum.isAlbum {
                    let library = EtoileLibrary()
                    let (_, songsForAllAlbums) = try await library.reloadNoPull() ?? ([], [:])
                    var songsTmp = songsForAllAlbums[self.playlistOrAlbum.id]
                    if songsTmp == nil || songsTmp == [] {
                        songsTmp = try await library.getSongsInAlbum(albumId: self.playlistOrAlbum.id, deviceName: UIDevice.current.name)
                    }
                    await MainActor.run {
                        let sorted = songsTmp?.sorted(by: { lhs, rhs in
                            lhs.positionInAlbum < rhs.positionInAlbum
                        })
                        self.songs.append(contentsOf: sorted ?? [])
                        self.tableView.reloadData()
                    }
                } else {
                    let library = EtoileLibrary()
                    let songsTmp = try await library.getSongsFromPlaylist(playlistId: self.playlistOrAlbum.id)
                    let sorted = songsTmp.sorted(by: { lhs, rhs in
                        lhs.positionInAlbum < rhs.positionInAlbum
                    })

                    await MainActor.run {
                        self.songs.append(contentsOf: sorted ?? [])
                        self.tableView.reloadData()
                    }
                }
            } catch {
                Logger().error("\(#file):\(#line) > \(error)")
            }
        }

    }
}

extension SongListController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath as IndexPath)
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = .etoileTextColor()
        cell.accessibilityIdentifier = songs[indexPath.row].name ?? "no name song"
        cell.textLabel?.text = "\(songs[indexPath.row].name)"
        return cell
    }
}

extension SongListController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Task.detached { [self] in
            let playerModel = PlayerModel()
            do {                
                let indexAfterThis = indexPath.section + 1
                let songsAfterSong = songs[indexAfterThis...]
                try await playerModel.startPlayingSongsAndAddToQueueWithClearing(song: songs[indexPath.row], queue: Array(songsAfterSong))
            } catch {
                Logger().error("Error playing song: \(self.songs[indexPath.row].name) with id: \(self.songs[indexPath.row].id) because: \(error)")
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        return
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let addToQueue = UIContextualAction(style: .normal, title: "Add to queue") { (action, view, completion) in
            Task.detached { [self] in
                let playerModel = PlayerModel()
                do {
                    try await playerModel.addToQueue(song: songs[indexPath.row])
                } catch {
                    Logger().error("Error adding to queue song: \(self.songs[indexPath.row].name) with id: \(self.songs[indexPath.row].id) because: \(error)")
                }
            }
        }
        
        addToQueue.image = UIImage(systemName: "text.append")
        addToQueue.image?.withTintColor(.etoileTextColor())
        addToQueue.backgroundColor = .clear
        
        return UISwipeActionsConfiguration(actions: [addToQueue])
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        if playlistOrAlbum.isAlbum {
            return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { suggestions in
                let addToPlaylistAction = UIAction(title: "Add To Playlist", image: UIImage(systemName: "plus"), handler: { action in
                    let hostingVc = UIHostingController(rootView: PlaylistAdderView(song: self.songs[indexPath.item]))
                    hostingVc.view.backgroundColor = .etoileBackground()
                    hostingVc.modalPresentationStyle = .formSheet
                    self.present(hostingVc, animated: true)
                })
                
                return UIMenu(title: "", children: [addToPlaylistAction])
            })
        } else {
            return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { suggestions in
                let addToPlaylistAction = UIAction(title: "Remove from playlist", image: UIImage(systemName: "trash"), handler: { action in
                    Task.detached {
                        do {
                            let library = EtoileLibrary()
                            try await library.removeSongFromPlaylist(playlistId: self.playlistOrAlbum.id, song: self.songs[indexPath.item])
                            
                            await MainActor.run {
                                self.reloadData()
                            }
                        } catch {
                            let alert = UIAlertController(title: "Error!", message: "Error removing from playlist!", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                                alert.dismiss(animated: true)
                            }))
                            self.present(alert, animated: true, completion: nil)
                            Logger().error("\(#file):\(#line) \(error)")
                        }
                    }
                })
                
                return UIMenu(title: "", children: [addToPlaylistAction])
            })

        }
    }
}

struct PlaylistOrAlbum {
    let isAlbum: Bool
    let id: String
}
