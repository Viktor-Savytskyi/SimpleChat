//
//  LoginPresenter.swift
//  SimpleChat
//
//  Created by Developer on 10.07.2023.
//

import Foundation

protocol LoginPresenterInput {
    
}

protocol LoginPresenterOutput {
    
}

class LoginPresenter {
    var LoginViewController: LoginViewControllerInput!
    var LoginInteractor: LoginInteractorInput!
    var imagePickerManager: ImagePickerManager!

    init(imagePickerManager: ImagePickerManager!) {
        self.imagePickerManager = imagePickerManager
    }
    
}
