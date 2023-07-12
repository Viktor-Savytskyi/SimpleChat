//
//  LoginRouter.swift
//  SimpleChat
//
//  Created by Developer on 10.07.2023.
//

import UIKit

protocol LoginRouterInput {
    func moveToChats()
}

class LoginRouter: LoginRouterInput {
  
    static func createLoginMoudle() -> UIViewController {
        let viewController = UIStoryboard(name: Storyboards.main.rawValue, bundle: nil).instantiateViewController(withIdentifier: Screens.login.rawValue) as! LoginViewController
        let interactor = LoginInteractor()
        let router = LoginRouter()
        let imagePickerManager = ImagePickerManager()
        let presenter = LoginPresenter(viewController: viewController,
                                       interactor: interactor,
                                       router: router,
                                       imagePickerManager: imagePickerManager)
        viewController.presenter = presenter
        return viewController
    }
    
    func moveToChats() {
        GlobalRouter.shared.moveTo(screen: .chats)
    }
}
