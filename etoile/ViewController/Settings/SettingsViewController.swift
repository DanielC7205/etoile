//
//  SettingsViewController.swift
//  etoile
//
//  Created by Juliette Bernheisel on 9/14/24.
//

import Foundation
import UIKit
import SimpleKeychain
import SwiftUI

class SettingsViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let settingsLabel = UILabel()
        settingsLabel.text = "Settings"
        settingsLabel.accessibilityIdentifier = "settingsLabel"
        settingsLabel.font = .preferredFont(forTextStyle: .headline)
        
        view.addSubview(settingsLabel)
        
        settingsLabel.sizeToFit()
        
        settingsLabel.snp.makeConstraints { make in
            make.left.equalTo(view).offset(20)
            make.top.equalTo(view).offset(100)
        }
        
        let refreshButton = UIButton()
        refreshButton.accessibilityIdentifier = "refreshButton"
        refreshButton.setTitle("Refresh Library | This could take awhile!", for: .normal)
        refreshButton.layer.cornerRadius = 5
        refreshButton.addTarget(self, action: #selector(refreshButtonTapped), for: .touchUpInside)
        refreshButton.backgroundColor = .etoileButtonBackground()
        refreshButton.tintColor = .etoileTextColor()
        
        view.addSubview(refreshButton)
        
        refreshButton.sizeToFit()
        
        refreshButton.snp.makeConstraints { make in
            make.left.equalTo(view).offset(20)
            make.top.equalTo(settingsLabel.snp.bottom).offset(30)
        }
        
        let logoutButton = UIButton()
        logoutButton.setTitle("Logout", for: .normal)
        logoutButton.accessibilityIdentifier = "logoutButton"
        logoutButton.backgroundColor = .etoileButtonBackground()
        logoutButton.tintColor = .etoileTextColor()
        logoutButton.layer.cornerRadius = 5
        logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        
        view.addSubview(logoutButton)
        
        logoutButton.sizeToFit()
        
        logoutButton.snp.makeConstraints { make in
            make.left.equalTo(view).offset(20)
            make.top.equalTo(refreshButton.snp.bottom).offset(30)
        }
        
        let creditsButton = UIButton()
        creditsButton.setTitle("Credits", for: .normal)
        creditsButton.accessibilityIdentifier = "logoutButton"
        creditsButton.backgroundColor = .etoileButtonBackground()
        creditsButton.tintColor = .etoileTextColor()
        creditsButton.layer.cornerRadius = 5
        creditsButton.addTarget(self, action: #selector(creditsButtonTapped), for: .touchUpInside)
        
        view.addSubview(creditsButton)
        
        creditsButton.sizeToFit()
        
        creditsButton.snp.makeConstraints { make in
            make.left.equalTo(view).offset(20)
            make.top.equalTo(logoutButton.snp.bottom).offset(30)
        }

    }
    
    @objc func creditsButtonTapped() {
        let hostingVc = UIHostingController(rootView: CreditsView())
        hostingVc.view.backgroundColor = .etoileBackground()
        hostingVc.modalPresentationStyle = .formSheet
        present(hostingVc, animated: true)

    }
    
    @objc func refreshButtonTapped() {
        self.navigationController?.setViewControllers([FullFetchViewController()], animated: true)
    }
    
    @objc func logoutButtonTapped() {
        do {
            let keychain = SimpleKeychain(service: "etoile")
            try keychain.deleteAll()
            
            Task {
                await MainActor.run {
                    self.tabBarController?.tabBar.isHidden = true
                    self.navigationController?.setViewControllers([LoginViewController()], animated: true)
                }
            }
        } catch {
            Task {
                await MainActor.run {
                    let alert = UIAlertController(title: "Error!", message: "Unable to sign out, try again!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                        alert.dismiss(animated: true)
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}
