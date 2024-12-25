//
//  AlbumsVerticalListViewController.swift
//  etoile
//
//  Created by Juliette Bernheisel on 8/27/24.
//

import Foundation
import UIKit
import OSLog
import EtoileKit

class AlbumsVerticalListViewController: UIViewController {
    
    let tableView = UITableView()
    
    var albums: [Album] = []
    
//    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.top.equalTo(view.snp.top)
            make.bottom.equalTo(view.snp.bottom)
        }
        
        
        tableView.accessibilityIdentifier = "albumVerticalTableView"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "albumCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 64
        tableView.separatorEffect = .none
        tableView.backgroundColor = .clear
        
        Task.detached { [self] in
            do {
                // Check if we already made library model, if we haven't create it and reload
                // Then we set all albums to either the in memory value or the reloaded value
                let libraryModel = EtoileLibrary()
                let (albums, _) = try await libraryModel.reloadNoPull() ?? ([], [:])
                
                await MainActor.run(body: {
                    self.albums = albums
                    self.tableView.reloadData()
                })
                
            } catch {
                Logger().error("\(#file):\(#line) > \(error)")
            }
            
            
//            await refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
//            await tableView.addSubview(refreshControl)
            
        }
    }
//    
//    @objc private func refresh() {
//        Task.detached { [self] in
//            do {
//                // Check if we already made library model, if we haven't create it and reload
//                // Then we set all albums to either the in memory value or the reloaded value
//                let libraryModel = EtoileLibrary()
//                let (albums, _) = try await libraryModel.refresh(deviceName: UIDevice.current.name)
//                
//                await MainActor.run(body: {
//                    self.albums = albums
//                    self.tableView.reloadData()
//                    self.refreshControl.endRefreshing()
//                })
//                
//            } catch {
//                Logger().error("\(#file):\(#line) > \(error)")
//            }
//            
//            
////            await refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
//            await tableView.addSubview(refreshControl)
//            
//        }
//
//    }
}


extension AlbumsVerticalListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "albumCell", for: indexPath as IndexPath)
        var content = cell.defaultContentConfiguration()
        
        cell.backgroundColor = .clear
        cell.accessibilityIdentifier = albums[indexPath.row].name + " verticalAlbumCell"
        content.textProperties.color = .etoileTextColor()
        content.secondaryTextProperties.color = .etoileBackground()
        content.text = albums[indexPath.row].name
        content.image = UIImage(data: albums[indexPath.row].art ?? Data())
        content.secondaryText = albums[indexPath.row].artist
        cell.contentConfiguration = content
        
        return cell
    }
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        var didHandleEvent = false
        
        for press in presses {
            
            // Get the pressed key.
            guard let key = press.key else { continue }
            
            if key.charactersIgnoringModifiers == UIKeyCommand.f1 {
                // Someone pressed the left arrow key.
                // Respond to the key-press event.
                didHandleEvent = true
            }
            if key.charactersIgnoringModifiers == UIKeyCommand.inputRightArrow {
                // Someone pressed the right arrow key.
                // Respond to the key-press event.
                didHandleEvent = true
            }
        }
        
        if didHandleEvent == false {
            // If someone presses a key that you're not handling,
            // pass the event to the next responder.
            super.pressesBegan(presses, with: event)
        }
    }
}

extension AlbumsVerticalListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let albumInfoViewController = AlbumInfoViewController(album: albums[indexPath.item])
        navigationController?.show(albumInfoViewController, sender: self)
    }
}
