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
    private var rooms = [UserRoom]()
    
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
    
    func getRooms() -> [UserRoom] {
        rooms
    }
    func fetchRooms(completion: @escaping () -> Void) {
        networkingManager.fetchRooms { response in
            switch response {
            case .success(let rooms):
                self.rooms = rooms
            case .error(let error):
                print(error)
            }
            completion()
        }
    }
    
    func moveToChat(with oponentID: String) {
        GlobalRouter.shared.moveTo(screen: .chat, oponentID: oponentID)
    }
}
