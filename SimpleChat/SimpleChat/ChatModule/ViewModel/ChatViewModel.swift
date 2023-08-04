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
        ChatManager.shared.sendMessage(receiverID: receiverID, message: message)
    }
    
    func setupWebSocket(userID: String, oponentID: String, completion: @escaping (() -> Void)) {
        ChatManager.shared.completion = completion
        ChatManager.shared.setupWebSocket(userID: userID)
    }
    
    func getMessages() -> [UserMessage] {
        ChatManager.shared.messagesArray ?? []
    }
    
    func createMessageArray(userID: String, opponentID: String) {
        ChatManager.shared.getRoomMessages(userID: userID, opponentID: opponentID)
    }
    
    func closeWebSocket() {
        ChatManager.shared.closeWebSocket()
    }
}
