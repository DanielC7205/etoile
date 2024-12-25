//
//  SongsQueuedViewController.swift
//  etoile
//
//  Created by Juliette Bernheisel on 8/27/24.
//

import Foundation
import UIKit
import OSLog
import EtoileKit

class SongsQueuedViewController: UIViewController {
    let tableView = UITableView()
    var songsInQueue: [Song] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.top.equalTo(view.snp.top)
            make.bottom.equalTo(view.snp.bottom)
        }

        
        tableView.backgroundColor = .etoileBackground()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "songCell")
        tableView.dataSource = self
        tableView.delegate = self
            
            songsInQueue.append(contentsOf: ConfigurationSingleton.shared.player.getSongs())
            
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(didStartPlaying), name: Notification.Name("etoileDidStartPlaying"), object: nil)

    }
    
    @objc func didStartPlaying() {
        Task.detached {
            await MainActor.run {
                let position = ConfigurationSingleton.shared.player.getPosition()
                let indexPath = IndexPath(row: position, section: 0)
                self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
            }
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(Notification.Name("etoileDidStartPlaying"))
    }
}

extension SongsQueuedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songsInQueue.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath as IndexPath)
        cell.backgroundColor = .etoileBackground()
        cell.textLabel?.textColor = .etoileTextColor()
        cell.textLabel?.text = "\(songsInQueue[indexPath.row].name)"
        return cell
    }
}

extension SongsQueuedViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//        tableView.deselectRow(at: indexPath, animated: true)
//        return
    }
}
