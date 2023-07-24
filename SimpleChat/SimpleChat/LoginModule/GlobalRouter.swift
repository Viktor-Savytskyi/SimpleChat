//
//  GlobalRouter.swift
//  SimpleChat
//
//  Created by Developer on 10.07.2023.
//

import UIKit

enum Storyboards: String {
    case main = "Main"
}
enum Screens: String {
    case login = "LoginViewController"
    case userChats = "UserChatsViewController"
    case chat = "ChatViewController"
}

final class GlobalRouter {
    
    private var navigationController: UINavigationController
    static let shared = GlobalRouter()
    let storyboard = UIStoryboard(name: Storyboards.main.rawValue, bundle: nil)
    
    private init() {
        self.navigationController = .init()
    }
    
    func getNavigationController() -> UINavigationController {
        moveTo(screen: .login)
        return navigationController
    }
    
    func moveTo(screen: Screens, oponentID: String? = nil) {
        switch screen {
        case .login:
            openLoginScreen()
        case .userChats:
            openUserChatsScreen()
        case .chat:
            openChatScreen(oponentID: oponentID)
        }
    }
    
    private func openLoginScreen() {
        let loginVC = storyboard.instantiateViewController(withIdentifier: Screens.login.rawValue) as! LoginViewController
        navigationController.pushViewController(loginVC, animated: true)
    }
    
    private func openUserChatsScreen() {
        let userChatsVC = storyboard.instantiateViewController(withIdentifier: Screens.userChats.rawValue) as! UserChatsViewController
        navigationController.pushViewController(userChatsVC, animated: true)
    }
    
    private func openChatScreen(oponentID: String?) {
        guard let oponentID else { return }
        let chatVC = storyboard.instantiateViewController(withIdentifier: Screens.chat.rawValue) as! ChatViewController
        chatVC.oponentID = oponentID
        chatVC.modalPresentationStyle = .fullScreen
        navigationController.present(chatVC, animated: true)
    }
}
