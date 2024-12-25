//
//  HostingTabViewController.swift
//  etoile
//
//  Created by Juliette Bernheisel on 8/27/24.
//

import Foundation
import UIKit
import StoreKit
import SwiftUI

class HostingTabViewController: UITabBarController {
    let app = UINavigationBarAppearance()
    let homeViewController = UINavigationController()
    let albumsViewController = UINavigationController()
    let searchVC = UINavigationController()
    let playlistVc = UINavigationController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .etoileBackground()
        
        setup()
    }
    
    func setup() {
        UITabBar.appearance().tintColor = .etoileTextColor()
        UITabBar.appearance().barTintColor = .etoileBackground()
        UITabBar.appearance().tintColor = .etoileTextColor()
        UITabBar.appearance().unselectedItemTintColor = .etoileSecondaryTextColor()
        
        homeViewController.viewControllers = [HomeViewController()]
        homeViewController.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
        homeViewController.tabBarItem.accessibilityIdentifier = "homeTabBarItem"
        
        albumsViewController.viewControllers = [AlbumsVerticalListViewController()]
        albumsViewController.tabBarItem = UITabBarItem(title: "Albums", image: UIImage(systemName: "rectangle.stack"), tag: 1)
        albumsViewController.tabBarItem.accessibilityIdentifier = "albumsTabBarItem"
        
        searchVC.viewControllers = [SearchViewController()]
        searchVC.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 0)
        searchVC.tabBarItem.accessibilityIdentifier = "searchTabBarItem"
        
        playlistVc.viewControllers = [PlayListHomeViewController()]
        playlistVc.tabBarItem = UITabBarItem(title: "Playlists", image: UIImage(systemName: "text.line.first.and.arrowtriangle.forward"), tag: 0)
        playlistVc.tabBarItem.accessibilityIdentifier = "playlistTabBarItem"
        
        viewControllers = [homeViewController, albumsViewController, playlistVc, searchVC]
        
        let center = NotificationCenter.default
        center.addObserver(
            self, selector: #selector(didStartPlaying), name: Notification.Name("etoileDidStartPlaying"),
            object: nil)
        
    }
    
    @objc func didStartPlaying() {
        Task {
            await MainActor.run {
                // oh my god
                UIView.animate(withDuration: 2.0, animations: {
                    for view in self.view.subviews {
                        view.backgroundColor = .etoileBackground()
                    }
                    for vc in self.children {
                        vc.view.backgroundColor = .etoileBackground()
                    }
                    UITabBar.appearance().tintColor = .etoileTextColor()
                    UITabBar.appearance().barTintColor = .etoileBackground()
                    UITabBar.appearance().tintColor = .etoileTextColor()
                    UITabBar.appearance().unselectedItemTintColor = .etoileSecondaryTextColor()
                    self.app.backgroundColor = .etoileBackground()
                    self.homeViewController.navigationController?.navigationBar.barTintColor = .etoileBackground()
                    self.homeViewController.tabBarController?.tabBar.backgroundColor = .etoileBackground()
                    self.albumsViewController.navigationController?.navigationBar.barTintColor = .etoileBackground()
                    self.albumsViewController.tabBarController?.tabBar.backgroundColor = .etoileBackground()
                    self.searchVC.navigationController?.navigationBar.barTintColor = .etoileBackground()
                    self.searchVC.tabBarController?.tabBar.backgroundColor = .etoileBackground()
                    self.playlistVc.navigationController?.navigationBar.barTintColor = .etoileBackground()
                    self.playlistVc.tabBarController?.tabBar.backgroundColor = .etoileBackground()
                    
                })
            }
        }
    }
    
}
