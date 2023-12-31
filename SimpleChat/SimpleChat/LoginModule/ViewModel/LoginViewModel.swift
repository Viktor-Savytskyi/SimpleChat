//
//  LoginPresenter.swift
//  SimpleChat
//
//  Created by Developer on 10.07.2023.
//

import UIKit

protocol LoginViewModelDelegate {
    //need to use Combine binding
}

class LoginViewModel {
    var delegate: LoginViewModelDelegate!
    var imagePickerManager: ImagePickerManager!
    let networkingManager = NetworkingManager()
    let userValidator = UserValidator()
    var users: [User] = []
    let keyChainManager = KeyChainManager()
    
    init(currentController: ViewControllerPickerPresentable) {
        self.imagePickerManager = ImagePickerManager(currentViewController: currentController)
    }

    func showImagePickerAler(completion: @escaping ((String) -> Void)) {
        imagePickerManager.showImagePickerAler(completion: completion)
    }
    
    func loginWith(firstName: String?, lastName: String?, imageUrl: String?) {
        guard let user = validatedUser(firstName: firstName, lastName: lastName, imageUrl: imageUrl) else { return }
        
//        CurrentUser.shared.createUser(firstName: firstName!)
//        print ("Current user: \(String(describing: CurrentUser.shared.currentUser))")
//        GlobalRouter.shared.moveTo(screen: .userChats)
        networkingManager.createUser(user: user) {
            DispatchQueue.main.async {
                self.keyChainManager.save(user: user)
                GlobalRouter.shared.moveTo(screen: .userChats)
            }
        }
    }

    private func validatedUser(firstName: String?, lastName: String?, imageUrl: String?) -> User? {
        do {
            return try userValidator.validateUser(firstName: firstName, lastName: lastName, imageUrl: imageUrl)
        } catch {
            print((error as! ValidationError).description)
        }
       return nil
    }
}
