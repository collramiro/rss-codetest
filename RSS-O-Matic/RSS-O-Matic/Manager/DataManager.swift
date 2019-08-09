//
//  DataManager.swift
//  RSS-O-Matic
//
//  Created by Ramiro Coll Doñetz on 09/08/2019.
//  Copyright © 2019 Ramiro Coll Doñetz. All rights reserved.
//

import UIKit

class DataManager {
    
    // MARK: - Properties
    
    private static var sharedDataManager: DataManager = {
        let dataManager = DataManager()
        
        // Configuration
        // ...
        
        return dataManager
    }()
    
    // MARK: -
    
    var user: User?
    
    // Initialization
    
    private init() {
        self.user = DataManager.loadUser()
    }
    
    // MARK: - Accessors
    
    class func shared() -> DataManager {
        return sharedDataManager
    }
    
    // MARK: - User Management
    private static func loadUser() -> User? {
        if let savedUser = UserDefaults.standard.object(forKey: "SavedUser") as? Data {
            let decoder = JSONDecoder()
            if let loadedUser = try? decoder.decode(User.self, from: savedUser) {
                print(loadedUser.authToken)
                return loadedUser
            }
        }
        
        return nil
    }
    
    func saveUser(user: User) {
        self.user = user

        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(user) {
            UserDefaults.standard.set(encoded, forKey: "SavedUser")
        }
    }
    
    func clearUser() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.standard.synchronize()
    }
}
