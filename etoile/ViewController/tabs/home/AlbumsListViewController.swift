//
//  AlbumsListViewController.swift
//  etoile
//
//  Created by Juliette Bernheisel on 8/23/24.
//

import Foundation
import UIKit
import OSLog
import EtoileKit

class AlbumsListViewController: UIViewController {
    weak var collectionView: UICollectionView!
    var albums: [Album] = []
    
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

        view.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.register(
            AlbumViewCell.self,
            forCellWithReuseIdentifier: "albumViewCell"
        )
        
        Task.detached {
            do {
                // Check if we already made library model, if we haven't create it and reload
                // Then we set all albums to either the in memory value or the reloaded value
                let libraryModel = EtoileLibrary()
                let (albums, _) = try await libraryModel.reloadNoPull() ?? ([], [:])
                
                await MainActor.run {
                    self.albums = albums
                    self.collectionView.reloadData()
                }
            } catch {
                Logger().error("\(#file):\(#line) > \(error)")
            }
        }
    }
}

extension AlbumsListViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "albumViewCell",
            for: indexPath
        ) as! AlbumViewCell

        cell.albumView.album = albums[indexPath.item]
        cell.albumView.refresh()
        cell.accessibilityLabel = albums[indexPath.item].name
        return cell
    }
}

extension AlbumsListViewController: UICollectionViewDelegate {

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let albumInfoViewController = AlbumInfoViewController(album: albums[indexPath.item])
        navigationController?.show(albumInfoViewController, sender: self)
    }
}
