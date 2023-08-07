//
//  ChatViewModel.swift
//  SimpleChat
//
//  Created by Developer on 18.07.2023.
//

import Foundation

class ChatViewModel {
    private let networkingManager = NetworkingManager()
    private var oponent: User?
    private var chatManager: ChatManager!
    var onlineUserCompletion: (() -> Void)?
    
    init(oponent: User? = nil, chatManager: ChatManager) {
        self.oponent = oponent
        self.chatManager = chatManager
    }
    
    func fetchUser(by id: String, completion: @escaping () -> Void) {
        networkingManager.fetchUserBy(id: id) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let user):
                self.oponent = user
            case .error(let error):
                print(error)
            }
            completion()
        }
    }
    
    func getOnlineUsers() -> [String : String?]? {
        chatManager.onlineUsers
    }
    
    func setupUsersOnlineCompletion(onlineUserCompletion: (() -> Void)?) {
        chatManager.onlineUserCompletion = { 
            _ = self.getOnlineUsers()
            onlineUserCompletion?()
        }
    }
    
    func getRoomMessages(userID: String, oponentID: String) {
        chatManager.getRoomMessages(userID: CurrentUser.shared.currentUser.id, opponentID: oponentID)
    }
    
    func showNewMessages(completion: @escaping (() -> Void)) {
        chatManager.tableViewCompletion = completion
    }
    
    func getOponent() -> User {
        oponent ?? User(firstName: "", lastName: "", imageUrl: "")
    }
    
    func sendMessage(receiverID: String, message: String) {
        chatManager.sendMessage(receiverID: receiverID, message: message)
    }
    
    func getMessages() -> [UserMessage] {
        chatManager.messagesArray ?? []
    }
    
    func sendTypingState(userID: String, oponentID: String, userTypingState: UserTypingState) {
        chatManager.sendTypingState(userID: userID, oponentID: oponentID, userTypingState: userTypingState)
    }
    
    func isOponentTyping(isOponentTypingCompletion: ((Bool) -> Void)?) {
        chatManager.isOponentTypingCompletion = isOponentTypingCompletion
    }
}
