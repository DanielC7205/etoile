//
//  SearchViewController.swift
//  etoile
//
//  Created by Juliette Bernheisel on 8/31/24.
//

import Foundation
import UIKit
import EtoileKit
import OSLog

class SearchViewController: UIViewController {

    var items: [AlbumOrSong] = []
    var albums: [Album] = []
    var songs: [Song] = []
    let searchInput = UISearchBar()
    let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Getting library
        Task.detached {
            let library = EtoileLibrary()
            let (albumsTmp, songsTmp) = try await library.reload(deviceName: UIDevice.current.name)
            
                for album in albumsTmp {
                    var songsInAlbums = songsTmp[album.id]
                    // Getting songs from remote if the album is empty
                    if songsTmp[album.id] == [] || songsTmp[album.id] == nil {
                        songsInAlbums = try await library.getSongsInAlbum(albumId: album.id, deviceName: UIDevice.current.name)
                    }
                    
                    await MainActor.run {
                        self.songs.append(contentsOf: songsInAlbums ?? [])
                    }
                }
                
            await MainActor.run {
                self.albums = albumsTmp
            }
        }
        
        searchInput.delegate = self
        searchInput.accessibilityIdentifier = "searchInput"
        searchInput.accessibilityTraits = UIAccessibilityTraits.searchField
        searchInput.searchBarStyle = .minimal
        
        view.addSubview(searchInput)
                
        searchInput.sizeToFit()
        searchInput.searchTextField.textColor = .etoileTextColor()
        
        searchInput.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.left.equalTo(view.safeAreaLayoutGuide.snp.left).offset(20)
            make.right.equalTo(view.safeAreaLayoutGuide.snp.right).offset(-20)
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "richCell")
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.left.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.right.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.top.equalTo(searchInput.snp.bottom).offset(10)
        }
        
        tableView.keyboardDismissMode = .onDrag
    }

}

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        items = []
        
        for album in self.albums {
            if album.name.lowercased().contains(searchText.lowercased()) {
                items.append(AlbumOrSong(song: nil, album: album))
            }
        }
        
        for song in self.songs {
            if song.name.lowercased().contains(searchText.lowercased()) {
                items.append(AlbumOrSong(song: song, album: nil))
            }
        }
        
        tableView.reloadData()
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "richCell", for: indexPath as IndexPath)
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = .etoileTextColor()

        let item = items[indexPath.row]
        
        if item.song != nil {
            cell.textLabel?.text = item.song?.name ?? "Song without name"
            cell.accessibilityIdentifier = (item.song?.name ?? "no name") + " searchCell"
            
            if let art = item.song?.art {
                cell.imageView?.image = UIImage(data: art)
            }
            
        } else {
            cell.textLabel?.text = item.album?.name ?? "Album without name"
            cell.accessibilityIdentifier = (item.album?.name ?? "no name") + " searchCell"

            if let art = item.album?.art {
                cell.imageView?.image = UIImage(data: art)
            }
        }
        
        return cell
    }
    
    
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        // If its a song, play it
        if item.song != nil {
            Task.detached {
                let playerModel = PlayerModel()
                guard let songSafe = item.song else { return }
                do {
                    try await playerModel.play(song: songSafe)
                } catch {
                    Logger().error("Error playing song: \(songSafe.name) with id: \(songSafe.id) because: \(error)")
                }
            }
        } else {
            // If its an album navigate to it
            guard let albumSafe = item.album else { return }
            let albumVC = AlbumInfoViewController(album: albumSafe)
            navigationController?.pushViewController(albumVC, animated: true)
        }
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
        addToQueue.backgroundColor = .etoileBackground()
        
        return UISwipeActionsConfiguration(actions: [addToQueue])
    }
}

struct AlbumOrSong {
    let song: Song?
    let album: Album?
}
