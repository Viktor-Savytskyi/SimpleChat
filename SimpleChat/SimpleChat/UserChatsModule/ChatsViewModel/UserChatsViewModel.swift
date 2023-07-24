//
//  ChatsViewModel.swift
//  SimpleChat
//
//  Created by Developer on 16.07.2023.
//

import Foundation

final class UserChatsViewModel {
    
    private let networkingManager = NetworkingManager()
    private var users = [User]()
    
    func fetchUsers(completion: @escaping () -> Void) {
        networkingManager.fetchUsers { response in
            switch response {
            case .success(let users):
                self.users = users
            case .error(let error):
                print(error)
            }
            completion()
        }
    }
    
    func getUsers() -> [User] {
        users
    }
    
    func moveToChat(with oponentID: String) {
        GlobalRouter.shared.moveTo(screen: .chat, oponentID: oponentID)
    }
}
