//
//  ChatsViewModel.swift
//  SimpleChat
//
//  Created by Developer on 16.07.2023.
//

import Foundation

struct RoomData {
    let messages: [UserMessage]
    let users: [User]
}

final class UserChatsViewModel {
    
    private let networkingManager = NetworkingManager()
    private var users = [User]()
    private var rooms = [UserRoom]()
    var roomsData = [RoomData]()
    
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
    
    func getRoomsData() {
        roomsData = []
        rooms.forEach { room in
            var localUsers = [User]()
            print("Room =", room.users)
            users.forEach { user in
                print("User =", user.id)
                if room.users.contains(user.id) {
                    localUsers.append(user)
                }
            }
            roomsData.append(RoomData(messages: room.messages, users: localUsers))
        }
    }
    
    func fetchRooms(completion: @escaping () -> Void) {
        networkingManager.fetchRooms { response in
            switch response {
            case .success(let rooms):
                self.rooms = rooms
            case .error(let error):
                print(error)
            }
            self.getRoomsData()
            completion()
        }
    }
    
    func moveToChat(with oponentID: String) {
        GlobalRouter.shared.moveTo(screen: .chat, oponentID: oponentID)
    }
}
