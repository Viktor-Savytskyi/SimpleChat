//
//  LoginPresenter.swift
//  SimpleChat
//
//  Created by Developer on 10.07.2023.
//

import UIKit

protocol LoginPresenterInput {
    func moveToChats()
}

protocol LoginPresenterOutput {
    
}

class LoginPresenter {
    var viewController: LoginViewControllerInput
    var interactor: LoginInteractorInput
    var router: LoginRouterInput
    var imagePickerManager: ImagePickerManager

    init(viewController: LoginViewControllerInput,
         interactor: LoginInteractorInput,
         router: LoginRouterInput,
         imagePickerManager: ImagePickerManager) {
        self.viewController = viewController
        self.interactor = interactor
        self.router = router
        self.imagePickerManager = imagePickerManager
    }
    
}

extension LoginPresenter: LoginPresenterInput {
    func moveToChats() {
        router.moveToChats()
    }
}
