//
//  GlobalRouter.swift
//  SimpleChat
//
//  Created by Developer on 10.07.2023.
//

import UIKit

enum Screens {
    case login
    case chats
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
        let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        navigationController.pushViewController(loginVC, animated: true)
    }
    
    private func openChatsScreen() {
        let chatsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatsViewController") as! ChatsViewController
        navigationController.pushViewController(chatsVC, animated: true)
    }
}
