//
//  SceneDelegate.swift
//  etoile
//
//  Created by Juliette Bernheisel on 8/22/24.
//

import UIKit
import SimpleKeychain
import EtoileKit
import OSLog
import Bonjour

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        let stopName = Notification.Name("etoileDidStopPlaying")
        NotificationCenter.default.addObserver(self, selector: #selector(didStopPlaying), name: stopName, object: nil)
        
        // Bonjourno (https://www.youtube.com/watch?v=5EwgxMT1EWA)
        ConfigurationSingleton.shared.bonjour.start()
        
        
        // If we start playing on a different device then broadcast did start playing
        ConfigurationSingleton.shared.bonjour.onReceive = { data, peer in
            do {
                let decoder = JSONDecoder()
                let decoded = try decoder.decode(ExternalPlayback.self, from: data)
                if decoded.user == ConfigurationSingleton.shared.username ?? "Unknown user" {
                    let name = Notification.Name("etoileDidExternalStartPlaying")
                    NotificationCenter.default.post(name: name, object: decoded)
                    ConfigurationSingleton.shared.externalData = decoded
                    Logger().info("Got media playback from external")
                }
            } catch {
                do {
                    let decoder = JSONDecoder()
                    let decoded = try decoder.decode(ExternalAction.self, from: data)
                    if ConfigurationSingleton.shared.username ?? "Unknown user" != decoded.user {
                        return
                    }
                    if let play = decoded.play {
                        if play {
                            ConfigurationSingleton.shared.player.play()
                        } else {
                            ConfigurationSingleton.shared.player.pause()
                        }
                    }
                    
                    if let next = decoded.next {
                        if next {
                            Task.detached {
                                ConfigurationSingleton.shared.player.nextSong()
                            }
                        }
                    }
                    
                    if let previous = decoded.previous {
                        if previous {
                            Task.detached {
                                ConfigurationSingleton.shared.player.previousSong()
                            }
                        }
                    }
                } catch {
                    let strData = String(data: data, encoding: .ascii)
                    Logger().error("Error finding what to do \(error) \(strData ?? "")")
                }
            }
        }
        
        // If we have a token go to main vc
        let keychain = SimpleKeychain(service: "etoile")
        
        do {
            if try keychain.hasItem(forKey: "token") {                
                let viewController = HostingTabViewController()
                viewController.view.backgroundColor = .etoileBackground()
                window?.rootViewController = viewController
                window?.makeKeyAndVisible()
            
                ConfigurationSingleton.shared.username = try keychain.string(forKey: "username")
            } else {
                let viewController = UINavigationController(rootViewController: LoginViewController())
                viewController.view.backgroundColor = .etoileBackground()
                window?.rootViewController = viewController
                window?.makeKeyAndVisible()
            }
        } catch {
            let viewController = UINavigationController(rootViewController: LoginViewController())
            viewController.view.backgroundColor = .etoileBackground()
            window?.rootViewController = viewController
            window?.makeKeyAndVisible()
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    
    @objc func didStopPlaying() {
        Task.detached {
            do {
                // Sending to bonjour
                let encoder = JSONEncoder()
                guard let playing = ConfigurationSingleton.shared.player.playingSong else { return }
                let external = await ExternalPlayback(isPlaying: false, song: playing, deviceName: UIDevice.current.name, user: ConfigurationSingleton.shared.username ?? "Unknown user")
                let data = try encoder.encode(external)
                ConfigurationSingleton.shared.bonjour.broadcast(data)
            } catch {
                Logger().error("Error sending now playing info to peers \(error)")
            }
        }
    }
    
}
