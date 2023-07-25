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
    
    func save(user: User)  {
        do {
            try Locksmith.saveData(data: [firstNameKey : user.firstName,
                                           lastNameKey : user.lastName],
                                   forUserAccount: user.id)
            UserDefaults.standard.set(true , forKey: "user")
            CurrentUser.shared.currentUser = user
        } catch {
            print("cant save data \(error)")
        }
    }
    
    func get() -> User? {
        if let id = UserDefaults.standard.value(forKey: "user") as! String?, let user = Locksmith.loadDataForUserAccount(userAccount: id) {
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

