//
//  HomeViewController.swift
//  etoile
//
//  Created by Juliette Bernheisel on 8/22/24.
//

import EtoileKit
import Foundation
import OSLog
import UIKit

class HomeViewController: UIViewController {

  let largeMargin = 20
  let hiLabel = UILabel()
  let distanceFromLeft = 20
  let yourAlbumsLabel = UILabel()
  let albumsListVc = AlbumsListViewController()
  let recentlyPlayedLabel = UILabel()
  let recentlyPlayedListVc = RecentlyPlayedViewController()
  var order = HomeViewModel.order()

  override func loadView() {
    super.loadView()

    // Hi label:)
    hiLabel.text = "Hi\(HomeViewModel.getUsernameSafely())"
    hiLabel.accessibilityLabel = "hiLabel"
    hiLabel.font = .systemFont(ofSize: 20)
    hiLabel.textColor = .etoileTextColor()

    self.view.addSubview(hiLabel)

    hiLabel.sizeToFit()

    hiLabel.snp.makeConstraints { make in
      make.top.equalTo(self.view).offset(60)
      make.left.equalTo(self.view).offset(distanceFromLeft)
    }

    let albumsHeld = UILongPressGestureRecognizer(target: self, action: #selector(yourAlbumsHeld))
    albumsHeld.minimumPressDuration = 0.5
    // Your albums label
    yourAlbumsLabel.text = "Your albums"
    yourAlbumsLabel.accessibilityLabel = "yourAlbumsLabel"
    yourAlbumsLabel.font = .systemFont(ofSize: 14)
    yourAlbumsLabel.textColor = .etoileTextColor()
    yourAlbumsLabel.addGestureRecognizer(albumsHeld)
    yourAlbumsLabel.isUserInteractionEnabled = true

    self.view.addSubview(yourAlbumsLabel)

    yourAlbumsLabel.sizeToFit()

    self.view.addSubview(albumsListVc.view)
    self.addChild(albumsListVc)
    albumsListVc.didMove(toParent: self)

    // Recently played
    let recentlyPlayedHeld = UILongPressGestureRecognizer(
      target: self, action: #selector(recentlyPlayedHeld))
    recentlyPlayedHeld.minimumPressDuration = 0.5
    recentlyPlayedLabel.isUserInteractionEnabled = true
    recentlyPlayedLabel.text = "Recently Played"
    recentlyPlayedLabel.accessibilityLabel = "recentlyPlayedLabel"
    recentlyPlayedLabel.font = .systemFont(ofSize: 14)
    recentlyPlayedLabel.textColor = .etoileTextColor()
    recentlyPlayedLabel.addGestureRecognizer(recentlyPlayedHeld)

    self.view.addSubview(recentlyPlayedLabel)

    recentlyPlayedLabel.sizeToFit()

    self.view.addSubview(recentlyPlayedListVc.view)
    self.addChild(recentlyPlayedListVc)
    recentlyPlayedListVc.didMove(toParent: self)

    orderView()

    recentlyPlayedListVc.view.snp.makeConstraints { make in
      make.height.equalTo(120)  // size of the album view. like the exact right size
      make.width.equalTo(self.view)
      make.left.equalTo(self.view).offset(distanceFromLeft)
      make.top.equalTo(recentlyPlayedLabel).offset(20)

    }

    yourAlbumsLabel.snp.makeConstraints { make in
      make.left.equalTo(hiLabel)
    }

    albumsListVc.view.snp.makeConstraints { make in
      make.height.equalTo(120)  // size of the album view. like the exact right size
      make.width.equalTo(self.view)
      make.top.equalTo(yourAlbumsLabel).offset(20)
      make.left.equalTo(self.view).offset(distanceFromLeft)
    }

    // Mini player
    let miniPlayer = MiniPlayerViewController()

    view.addSubview(miniPlayer.view)
    addChild(miniPlayer)
    miniPlayer.didMove(toParent: self)

    miniPlayer.view.snp.makeConstraints { make in
      make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-10)
      make.height.equalTo(64)
      make.width.equalTo(view.safeAreaLayoutGuide.snp.width).offset(-40)
      make.left.equalTo(view.safeAreaLayoutGuide.snp.left).offset(20)
    }

    let refreshButton = UIBarButtonItem(
      image: UIImage(systemName: "gear"), style: .plain, target: self,
      action: #selector(refreshTapped))
    refreshButton.tintColor = .etoileTextColor()
    refreshButton.accessibilityLabel = "settingsButton"

    navigationItem.rightBarButtonItem = refreshButton

  }

  func orderView() {
    recentlyPlayedLabel.snp.removeConstraints()
    yourAlbumsLabel.snp.removeConstraints()
    switch order.first {
    case .albums:
      yourAlbumsLabel.snp.makeConstraints { make in
        make.left.equalTo(self.view).offset(distanceFromLeft)
        make.top.equalTo(hiLabel.snp.bottom).offset(20)
      }
      recentlyPlayedLabel.snp.makeConstraints { make in
        make.left.equalTo(self.view).offset(distanceFromLeft)
        make.top.equalTo(albumsListVc.view.snp.bottom).offset(20)
      }

    case .recents:
      recentlyPlayedLabel.snp.makeConstraints { make in
        make.left.equalTo(self.view).offset(distanceFromLeft)
        make.top.equalTo(hiLabel.snp.bottom).offset(20)
      }
      yourAlbumsLabel.snp.makeConstraints { make in
        make.left.equalTo(self.view).offset(distanceFromLeft)
        make.top.equalTo(recentlyPlayedListVc.view.snp.bottom).offset(20)
      }

    case .none:
      print("none")
      yourAlbumsLabel.snp.makeConstraints { make in
        make.left.equalTo(self.view).offset(distanceFromLeft)
        make.top.equalTo(hiLabel.snp.bottom).offset(20)
      }
      recentlyPlayedLabel.snp.makeConstraints { make in
        make.left.equalTo(self.view).offset(distanceFromLeft)
        make.top.equalTo(albumsListVc.view.snp.bottom).offset(20)
      }
    }
  }

  @objc func refreshTapped() {
    let settingsVc = SettingsViewController()
    navigationController?.pushViewController(settingsVc, animated: true)
  }

  @objc func yourAlbumsHeld() {
    let customization = CustomizationTooltip {
      Task {
        print("up")
        do {
          self.order = [.albums, .recents]
          try HomeViewModel.set(order: self.order)
        } catch {
          Logger().error("Error setting position \(error)")
        }

        await MainActor.run {
          self.orderView()
        }
      }
    } down: {
      Task {
        print("down")
        do {
          self.order = [.recents, .albums]
          try HomeViewModel.set(order: self.order)
        } catch {
          Logger().error("Error setting position \(error)")
        }

        await MainActor.run {
          self.orderView()
        }
      }
    }

    if let sheet = customization.sheetPresentationController {
      sheet.detents = [.medium()]
      sheet.largestUndimmedDetentIdentifier = .medium
      sheet.prefersScrollingExpandsWhenScrolledToEdge = false
      sheet.prefersEdgeAttachedInCompactHeight = true
      sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
    }

    present(customization, animated: true)
  }

  @objc func recentlyPlayedHeld() {
    let customization = CustomizationTooltip {
      Task {
        do {
          self.order = [.recents, .albums]
          try HomeViewModel.set(order: self.order)
        } catch {
          Logger().error("Error setting position \(error)")
        }

        await MainActor.run {
          self.orderView()
        }
      }
    } down: {
      Task {
        do {
          self.order = [.albums, .recents]
          try HomeViewModel.set(order: self.order)
        } catch {
          Logger().error("Error setting position \(error)")
        }

        await MainActor.run {
          self.orderView()
        }
      }

    }

    if let sheet = customization.sheetPresentationController {
      sheet.detents = [.medium()]
      sheet.largestUndimmedDetentIdentifier = .medium
      sheet.prefersScrollingExpandsWhenScrolledToEdge = false
      sheet.prefersEdgeAttachedInCompactHeight = true
      sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
    }

    present(customization, animated: true)
  }

}
