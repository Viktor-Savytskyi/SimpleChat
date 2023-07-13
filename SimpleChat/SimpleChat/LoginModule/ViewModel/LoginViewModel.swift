//
//  LoginPresenter.swift
//  SimpleChat
//
//  Created by Developer on 10.07.2023.
//

import UIKit




protocol LoginViewModelDelegate {
    
}

class LoginViewModel {
    var delegate: LoginViewModelDelegate!
    var imagePickerManager: ImagePickerManager!
    
    init(currentController: ViewControllerPickerPresentable) {
        self.imagePickerManager = ImagePickerManager(currentViewController: currentController)
    }

    func showImagePickerAler(completion: @escaping ((UIImage) -> Void)) {
        imagePickerManager.showImagePickerAler(completion: completion)
    }
}
