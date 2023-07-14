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
    
    init(currentController: ViewControllerPickerPresentable) {
        self.imagePickerManager = ImagePickerManager(currentViewController: currentController)
    }

    func showImagePickerAler(completion: @escaping ((UIImage) -> Void)) {
        imagePickerManager.showImagePickerAler(completion: completion)
    }
    
    func loginWith(firstName: String?, lastName: String?, imageUrl: String?) {
        guard let user = validatedUser(firstName: firstName, lastName: lastName, imageUrl: imageUrl) else { return }
        
        networkingManager.createUser(user: user) {
            DispatchQueue.main.async {
                GlobalRouter.shared.moveTo(screen: .chats)
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
    
    func getUsers() {
        networkingManager.getUsers { response in
            switch response {
            case .success(let users):
                self.users = users
            case .error(let error):
                print(error)
            }
        }
    }
}
