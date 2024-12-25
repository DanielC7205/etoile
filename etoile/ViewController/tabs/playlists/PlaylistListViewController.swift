//
//  PlaylistListViewController.swift
//  etoile
//
//  Created by Juliette Bernheisel on 9/17/24.
//

import Foundation
import UIKit
import EtoileKit
import OSLog

class PlaylistListViewController: UIViewController {
    weak var collectionView: UICollectionView!
    var playlists: [Playlist] = []
    
    override func loadView() {
        super.loadView()
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 20
        layout.estimatedItemSize = CGSize(width: 64, height: 120)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.top.equalTo(view.snp.top)
            make.bottom.equalTo(view.snp.bottom)
        }
        
        self.collectionView = collectionView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(
            AlbumViewCell.self,
            forCellWithReuseIdentifier: "albumViewCell"
        )
                
        NotificationCenter.default.addObserver(self, selector: #selector(reloadPlaylists), name: Notification.Name("etoileDidCreateNewPlaylist"), object: nil)
        
        reloadPlaylists()
    }
    
    @objc func reloadPlaylists() {
        Task.detached {
            do {
                let library = EtoileLibrary()
                let tmpPlaylists = try library.reloadNoPullPlaylist()
                
                if tmpPlaylists == nil {
                    self.playlists = try await library.pullPlaylistsFromFin()
                } else {
                    self.playlists = tmpPlaylists!
                }
                
                await self.collectionView.reloadData()
            } catch {
                Logger().error("\(#file):\(#line) > \(error)")
            }
        }
    }
}

extension PlaylistListViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return playlists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "albumViewCell",
            for: indexPath
        ) as! AlbumViewCell

        let playlist = playlists[indexPath.item]
        let fakeAlbum = Album(name: playlist.name, artist: "", art: playlist.art, id: playlist.id)
        cell.albumView.album = fakeAlbum
        cell.albumView.refresh()
        cell.accessibilityLabel = fakeAlbum.name
        return cell
    }

}

extension PlaylistListViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let info = PlaylistFullViewController(playlist: playlists[indexPath.item])
        navigationController?.show(info, sender: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { suggestions in
            let addToPlaylistAction = UIAction(title: "Delete playlist", image: UIImage(systemName: "trash"), handler: { action in
                if let item = indexPaths.first {
                    Task.detached {
                        do {
                            let playlist = self.playlists[item.item]
                            let library = EtoileLibrary()
                            try await library.deletePlaylist(playlist: playlist)
                            
                            await MainActor.run {
                                let alert = UIAlertController(title: "Deleted playlist", message: "", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                                    alert.dismiss(animated: true)
                                }))
                                self.present(alert, animated: true, completion: nil)
                                self.reloadPlaylists()
                            }
                        } catch {
                            let alert = UIAlertController(title: "Error!", message: "Error deleting playlist!", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                                alert.dismiss(animated: true)
                            }))
                            self.present(alert, animated: true, completion: nil)
                            Logger().error("\(#file):\(#line) \(error)")
                        }
                    }
                }
            })
            
            return UIMenu(title: "", children: [addToPlaylistAction])
        })
    }
}
