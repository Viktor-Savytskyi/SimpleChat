//
//  ChatViewModel.swift
//  SimpleChat
//
//  Created by Developer on 18.07.2023.
//

import Foundation

class ChatViewModel {
    private let chatManager = ChatManager()
    private let networkingManager = NetworkingManager()
    private var oponent: User?
    
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
    
    func getOponent() -> User {
        oponent ?? User(firstName: "", lastName: "", imageUrl: "")
    }
    
    func sendMessage(receiverID: String, message: String) {
        chatManager.sendMessage(receiverID: receiverID, message: message)
    }
    
    func setupWebSocket(userID: String, oponentID: String, completion: @escaping (() -> Void)) {
        chatManager.completion = completion
        chatManager.setupWebSocket(userID: userID, oponentID: oponentID)
    }
    
    func getMessages() -> [UserMessage] {
        chatManager.messagesArray
    }
    
    func closeWebSocket() {
        chatManager.closeWebSocket()
    }
}
