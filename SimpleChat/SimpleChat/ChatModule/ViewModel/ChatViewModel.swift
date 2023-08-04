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
}
