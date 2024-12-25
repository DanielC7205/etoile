//
//  HomeViewModel.swift
//  etoile
//
//  Created by Juliette Bernheisel on 8/22/24.
//

import Foundation
import SimpleKeychain
import Cache

class HomeViewModel {
    class func getUsernameSafely() -> String {
        let keychain = SimpleKeychain(service: "etoile")
        var username = ""
        do {
            username = try keychain.string(forKey: "username")
            username = ", \(username)"
        } catch {
            username = "!"
        }
        return username
    }
    
    class func order() -> [HomeOrder] {
        do {
            let homeDiskConfig = DiskConfig(name: "home")
            let expiry = Calendar.current.date(byAdding: .day, value: 2, to: Date()) ?? Date()
            let homeMemoryConfig = MemoryConfig(expiry: .date(expiry), countLimit: 10, totalCostLimit: 10)
            
            let homeStorage = try Storage<String, [HomeOrder]>(
                diskConfig: homeDiskConfig,
                memoryConfig: homeMemoryConfig, fileManager: FileManager.default,
                transformer: TransformerFactory.forCodable(ofType: [HomeOrder].self)
            )
            
            if homeStorage.objectExists(forKey: "order") {
                return try homeStorage.object(forKey: "order")
            }
        } catch {
        }
        return [.albums, .recents]
    }
    
    class func set(order: [HomeOrder]) throws {
        let homeDiskConfig = DiskConfig(name: "home")
        let expiry = Calendar.current.date(byAdding: .day, value: 2, to: Date()) ?? Date()
        let homeMemoryConfig = MemoryConfig(expiry: .date(expiry), countLimit: 10, totalCostLimit: 10)
        
        let homeStorage = try Storage<String, [HomeOrder]>(
            diskConfig: homeDiskConfig,
            memoryConfig: homeMemoryConfig, fileManager: FileManager.default,
            transformer: TransformerFactory.forCodable(ofType: [HomeOrder].self)
        )
        
        try homeStorage.setObject(order, forKey: "order")
    }
    
}

enum HomeOrder: Codable {
    case albums, recents
}
