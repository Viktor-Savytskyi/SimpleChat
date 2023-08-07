//
//  SceneDelegate.swift
//  SimpleChat
//
//  Created by Developer on 07.07.2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window?.windowScene = windowScene
        window?.rootViewController = GlobalRouter.shared.getNavigationController()
        window?.makeKeyAndVisible()
        let keyChainManager = KeyChainManager()
        if let user = keyChainManager.get() {
            CurrentUser.shared.currentUser = user
            GlobalRouter.shared.moveTo(screen: .userChats)
        } else {
            GlobalRouter.shared.moveTo(screen: .login)
        }
    }
}

