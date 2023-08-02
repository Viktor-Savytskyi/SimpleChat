//
//  CurrentUser.swift
//  SimpleChat
//
//  Created by Developer on 02.08.2023.
//

import Foundation

class CurrentUser {
    
    static let shared = CurrentUser()
    
    init() { }
    
    var currentUser: User!
}
