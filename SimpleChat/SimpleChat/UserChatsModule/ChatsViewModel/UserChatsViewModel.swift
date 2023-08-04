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
    
    private let chatManager = ChatManager()
    private let networkingManager = NetworkingManager()
    private var users = [User]()
    private var rooms = [UserRoom]()
    private var roomsData = [RoomData]()
    private var oponent: User?
    
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
    
    func getChatManager() -> ChatManager {
        chatManager
    }
    
    func getRoomsData() -> [RoomData] {
        return roomsData
    }
    
    func createRoomsDataArray() {
        roomsData = []
        chatManager.roomsArray.forEach { room in
            var localUsers = [User]()
            print("Room =", room.users)
            users.forEach { user in
                if room.users.contains(user.id) {
                    if room.users.first == room.users.last {
                        localUsers = [user, user]
                    } else {
                        localUsers.append(user)
                    }
                }
            }
            roomsData.append(RoomData(messages: room.messages, users: localUsers))
        }
        roomsData = roomsData.sorted { room1, room2 in
            let lastMessageDate1 = room1.messages.last?.createdAt ?? Date.distantPast
            let lastMessageDate2 = room2.messages.last?.createdAt ?? Date.distantPast
            return lastMessageDate1 > lastMessageDate2
        }
    }
    
    func fetchRooms(completion: @escaping () -> Void) {
        networkingManager.fetchRoomsForUser(id: CurrentUser.shared.currentUser.id) { response in
            switch response {
            case .success(let rooms):
                self.rooms = rooms
            case .error(let error):
                print(error)
            }
            self.createRoomsDataArray()
            completion()
        }
    }
    
    func moveToChat(with oponentID: String, chatManager: ChatManager?) {
        GlobalRouter.shared.moveTo(screen: .chat, oponentID: oponentID, chatManager: chatManager)
    }
}

extension UserChatsViewModel {
    func setupWebSocket(userID: String, completion: @escaping (() -> Void)) {
        chatManager.completion = completion
        chatManager.setupWebSocket(userID: userID)
    }
}
