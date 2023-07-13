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
    case chats = "ChatsViewController"
}

final class GlobalRouter {
    
    private var navigationController: UINavigationController
    static let shared = GlobalRouter()
    
    init() {
        self.navigationController = .init()
    }
    
    func getNavigationController() -> UINavigationController {
        moveTo(screen: .login)
        return navigationController
    }
    
    func moveTo(screen: Screens) {
        switch screen {
        case .login:
            openLoginScreen()
        case .chats:
            openChatsScreen()
        }
    }
    
    private func openLoginScreen() {
        let loginVC = UIStoryboard(name: Storyboards.main.rawValue, bundle: nil).instantiateViewController(withIdentifier: Screens.login.rawValue) as! LoginViewController
        navigationController.pushViewController(loginVC, animated: true)
    }
    
    private func openChatsScreen() {
        let chatsVC = UIStoryboard(name: Storyboards.main.rawValue, bundle: nil).instantiateViewController(withIdentifier: Screens.chats.rawValue) as! ChatsViewController
        navigationController.pushViewController(chatsVC, animated: true)
    }
}
