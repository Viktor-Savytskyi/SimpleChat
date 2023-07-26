//
//  KeyChainManager.swift
//  SimpleChat
//
//  Created by Developer on 25.07.2023.
//

import Foundation
import Locksmith

class KeyChainManager {
    private let firstNameKey = "firstName"
    private let lastNameKey = "lastName"
    private let imageURLKey = "imageURLKey"
    private let userKey = "user"
    
    func save(user: User)  {
        do {
            try Locksmith.saveData(data: [firstNameKey : user.firstName,
                                           lastNameKey : user.lastName,
                                           imageURLKey : user.imageUrl],
                                   forUserAccount: user.id)
            UserDefaults.standard.set(user.id , forKey: userKey)
            CurrentUser.shared.currentUser = user
        } catch {
            print("cant save data \(error)")
        }
    }
    
    func get() -> User? {
        if let id = UserDefaults.standard.string(forKey: userKey),
            let user = Locksmith.loadDataForUserAccount(userAccount: id) {
            return User(id: id,
                        firstName: user[firstNameKey] as! String,
                        lastName: user[lastNameKey] as! String,
                        imageUrl: user[imageURLKey] as! String)
        } else {
            print("error to get account")
            return nil
        }
    }
}

